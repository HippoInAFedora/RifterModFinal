using RifterMod.Survivors.NemRifter;
using RoR2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

namespace RifterMod.Characters.Survivors.NemRifter.Components.Old
{
    [RequireComponent(typeof(CharacterBody))]
    [RequireComponent(typeof(InputBankTest))]
    [RequireComponent(typeof(TeamComponent))]
    public class NemRifterSelfDamageController : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("The period in seconds in between each tick")]
        private float tickPeriodSeconds = .2f;

        [Range(0f, 1f)]
        [SerializeField]
        [Tooltip("The fraction of combined health to deduct per second.  Note that damage is actually applied per tick, not per second.")]
        private float healthFractionPerSecond = .05f;

        [SerializeField]
        [Tooltip("The coefficient to increase the damage by, for every tick they take outside the zone.")]
        private float healthFractionRampCoefficientPerSecond = .05f;

        [SerializeField]
        [Tooltip("The time it takes to increase the amount of damage for every tick outside the zone.")]
        private float healthFractionRampIncreaseCooldown = 5f;

        private int rampNum = 0;

        private float timerBeforeRamp = 60f;

        private float timerRampDown = 0f;

        private float damageTimer;

        private CharacterBody characterBody;

        private void Start()
        {
            characterBody = GetComponent<CharacterBody>();
        }

        private void FixedUpdate()
        {
            if (!NetworkServer.active) 
            { 
                return; 
            }

            if (characterBody.HasBuff(NemRifterBuffs.outsideRiftDebuff))
            {
                damageTimer += Time.fixedDeltaTime;
                timerBeforeRamp += Time.fixedDeltaTime;
            }
            else
            {
                timerRampDown += Time.fixedDeltaTime;
                if (timerRampDown > tickPeriodSeconds)
                {
                    timerBeforeRamp = timerBeforeRamp > timerRampDown ? timerBeforeRamp - timerRampDown : 0f;
                    rampNum = rampNum > 0 ? rampNum - 1 : 0;
                    timerRampDown = 0f;
                }
                damageTimer = 0f;
            }

            while (damageTimer > tickPeriodSeconds)
            {
                damageTimer -= tickPeriodSeconds;
                float num2 = healthFractionPerSecond * (1f + rampNum * healthFractionRampCoefficientPerSecond * tickPeriodSeconds) * tickPeriodSeconds;
                float originalDamage = num2 * characterBody.healthComponent.fullCombinedHealth;
                if (originalDamage > 0f)
                {
                    characterBody.healthComponent.TakeDamage(new DamageInfo
                    {
                        damage = originalDamage,
                        position = characterBody.corePosition,
                        damageType = (DamageType.BypassArmor | DamageType.BypassBlock),
                        damageColorIndex = DamageColorIndex.Void
                    });
                }
            }
            
        }
    }
}
