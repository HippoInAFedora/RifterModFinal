using EntityStates;
using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.Old
{
    public class ChargeGatling : BaseSkillState
    {
        public static float baseMinChargeDuration = .25f;

        public static float baseChargeDuration = 3f;

        public static string muzzleName;

        public static string enterSoundString;

        public static string playChargeSoundString;

        public static string stopChargeSoundString;

        private float chargeDurationBetweenShotCharges;

        private float chargeDurationMax;

        private float stopwatch = 0f;

        private float minChargeDuration;

        private int shotCounter;

        private int shotCounterMin;

        private int shotCounterMax;

        private int baseShotCounterMin = 5;

        private int baseShotCounterMax = 50;

        private bool released;

        public override void OnEnter()
        {
            base.OnEnter();
            minChargeDuration = baseMinChargeDuration / attackSpeedStat;
            shotCounterMin = baseShotCounterMin + (int)attackSpeedStat;
            chargeDurationMax = baseChargeDuration / attackSpeedStat;
            shotCounterMax = baseShotCounterMax + (int)attackSpeedStat;
            chargeDurationBetweenShotCharges = chargeDurationMax / shotCounterMax;
            shotCounter = shotCounterMin;
        }

        public override void OnExit()
        {
            base.OnExit();
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            stopwatch += Time.fixedDeltaTime;
            if (stopwatch > chargeDurationBetweenShotCharges)
            {
                if (shotCounter < shotCounterMax)
                {
                    shotCounter++;
                }
                stopwatch = 0f;
            }
            characterBody.SetAimTimer(1f);
            if (isAuthority)
            {
                if (!released && !IsKeyDownAuthority())
                {
                    released = true;
                }
                if (released)
                {
                    outer.SetNextState(new NemFracture { shotCounter = shotCounter, shotCounterMax = shotCounterMax });
                }
            }
        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Skill;
        }
    }
}
