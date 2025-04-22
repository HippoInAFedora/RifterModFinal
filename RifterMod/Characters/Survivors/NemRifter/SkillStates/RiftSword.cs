using RoR2;
using UnityEngine;
using RifterMod.Modules.BaseStates;
using UnityEngine.Networking;
using RifterMod.Survivors.Rifter;
using System.Collections.Generic;
using RifterMod.Survivors.NemRifter;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates
{
    public class RiftSword : BaseMeleeAttack
    {
        List<Collider> colliders = new List<Collider>();

        List<Collider> riftZoneColliders = new List<Collider>();

        bool flag = false;
        public override void OnEnter()
        {
            hitboxGroupName = "RiftSwordGroup";

            moddedDamageTypeHolder.Add(NemRifterDamage.instabilityTriggerDamage);

            damageCoefficient = NemRifterStaticValues.slashDamageCoefficient;
            damageType = DamageTypeCombo.GenericPrimary;
            procCoefficient = 1f;
            pushForce = 300f;
            bonusForce = Vector3.zero;
            baseDuration = .5f;

            //0-1 multiplier of baseduration, used to time when the hitbox is out (usually based on the run time of the animation)
            //for example, if attackStartPercentTime is 0.5, the attack will start hitting halfway through the ability. if baseduration is 3 seconds, the attack will start happening at 1.5 seconds
            attackStartPercentTime = 0.25f;
            attackEndPercentTime = .7f;

            //this is the point at which the attack can be interrupted by itself, continuing a combo
            earlyExitPercentTime = 1f / attackSpeedStat;

            hitStopDuration = 0.05f;
            attackRecoil = 0.5f;
            hitHopVelocity = 5f;

            //swingSoundString = "HenrySwordSwing";
            hitSoundString = "";
            muzzleString = "Pivot";
            playbackRateParam = "Slash.playbackRate";
            swingEffectPrefab = null;
            hitEffectPrefab = null;

            //impactSound = GlaiveAssets.swordHitSoundEvent.index;

            base.OnEnter();
            StartAimMode(.5f + duration);

        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
        }

        protected override void PlayAttackAnimation()
        {
            PlayCrossfade("Gesture, Override", "Armature_Secondary", playbackRateParam, duration, 0.1f * duration);
        }

        protected override void PlaySwingEffect()
        {
            base.PlaySwingEffect();
        }

        protected override void FireAttack()
        {
            if (isAuthority)
            {
                var direction = GetAimRay().direction;
                //direction.y = Mathf.Max(direction.y, direction.y * .5f);
                FindModelChild("Pivot").rotation = Util.QuaternionSafeLookRotation(direction);
            }
            base.FireAttack();
        }

        protected override void OnHitEnemyAuthority()
        {
            base.OnHitEnemyAuthority();
        }

        public override void OnExit()
        {
            moddedDamageTypeHolder.Clear();
            base.OnExit();
        }
    }
}