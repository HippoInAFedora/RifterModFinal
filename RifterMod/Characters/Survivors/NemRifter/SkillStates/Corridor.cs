using EntityStates;
using RifterMod.Characters.Survivors.Rifter.Components;
using RifterMod.Modules.BaseStates;
using RifterMod.Survivors.NemRifter;
using RifterMod.Survivors.Rifter;
using RoR2;
using RoR2.Projectile;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UIElements;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates
{
    public class Corridor : BaseMeleeAttack
    {

        public Vector3 position;

        private int specialStateHash = Animator.StringToHash("Special End");
        private int specialPlaybackHash = Animator.StringToHash("Special.playbackRate");

        private int inTimelock = Animator.StringToHash("inTimelock");

        public Animator modelAnimator;


        public override void OnEnter()
        {
            hitboxGroupName = "CorridorGroup";

            //moddedDamageTypeHolder.Add(NemRifterDamage.instabilityTriggerDamage);

            damageCoefficient = NemRifterStaticValues.corridorDamageCoefficient;
            damageType = DamageTypeCombo.GenericSecondary;
            procCoefficient = 1f;
            pushForce = 300f;
            bonusForce = Vector3.zero;
            baseDuration = .5f;

            //0-1 multiplier of baseduration, used to time when the hitbox is out (usually based on the run time of the animation)
            //for example, if attackStartPercentTime is 0.5, the attack will start hitting halfway through the ability. if baseduration is 3 seconds, the attack will start happening at 1.5 seconds
            attackStartPercentTime = 0f;
            attackEndPercentTime = .2f;

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
            StartAimMode(.5f + duration);
            base.OnEnter();
            modelAnimator = GetModelAnimator();
            if (modelAnimator)
            {
                modelAnimator.SetBool(inTimelock, false);
                PlayCrossfade("Gesture, Override", specialStateHash, specialPlaybackHash, .1f, .1f);
            }

            if (NetworkServer.active)
            {
                GameObject gameObject = Object.Instantiate(NemRifterAssets.corridorRift);
                //float resetInterval = gameObject.GetComponent<ProjectileOverlapAttack>().resetInterval;
                //float lifetime = gameObject.GetComponent<ProjectileSimple>().lifetime;
                //float damageCoefficient = 3f * (float)itemCount12;
                //float damage3 = Util.OnHitProcDamage(damageInfo.damage, component2.damage, damageCoefficient / lifetime * resetInterval;
                float speedOverride = 0f;
                Quaternion rotation2 = Quaternion.identity;
                Vector3 vector = GetAimRay().GetPoint(12f) - GetAimRay().origin;
                vector.y = 0f;
                if (vector != Vector3.zero)
                {
                    speedOverride = -1f;
                    rotation2 = Util.QuaternionSafeLookRotation(vector, Vector3.up);
                }
                ProjectileManager.instance.FireProjectile(new FireProjectileInfo
                {
                    damage = base.characterBody.damage,
                    crit = false,
                    damageColorIndex = DamageColorIndex.Default,
                    position = GetAimRay().origin,
                    force = 0f,
                    owner = base.gameObject,
                    projectilePrefab = gameObject,
                    rotation = rotation2,
                    speedOverride = speedOverride,
                    target = null
                });
            }
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
            base.FireAttack();
        }

        protected override void OnHitEnemyAuthority()
        {
            base.OnHitEnemyAuthority();
        }

        public override void OnExit()
        {
            base.OnExit();
        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Frozen;
        }

    }
}
