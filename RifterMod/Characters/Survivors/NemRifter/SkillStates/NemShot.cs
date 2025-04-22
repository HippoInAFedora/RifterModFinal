using RoR2;
using EntityStates;
using UnityEngine;
using RifterMod.Survivors.Rifter;
using static UnityEngine.SendMouseEvents;
using System.Collections.Generic;
using Newtonsoft.Json.Utilities;
using R2API;
using RifterMod.Survivors.NemRifter;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates
{
    public class NemShot : BaseSkillState
    {
        public static GameObject effectPrefab = RifterAssets.hitEffect;

        public static GameObject hitEffectPrefab = RifterAssets.hitEffect;

        public static GameObject tracerEffectPrefab = RifterAssets.fractureLineTracer;

        public static float damageCoefficient = NemRifterStaticValues.basePrimaryDamage;

        public static float force = 25f;

        public static float baseDurationBetweenShots = .6f;

        public float duration;

        public static string fireBarrageSoundString;

        public static float recoilAmplitude = 1f;

        public static float spreadBloomValue;

        public static float bulletRadius = .2f;

        public float stopwatchBetweenShots;

        private Animator modelAnimator;

        private Transform modelTransform;

        private uint shots;

        private uint maxShots;

        private bool hasReleased;

        private float durationBetweenShots;

        private static int primaryStateHash = Animator.StringToHash("Primary");

        private static int primaryPlaybackHash = Animator.StringToHash("ShootRift.playbackRate");

        private List<Collider> riftZones = new List<Collider>();

        public override void OnEnter()
        {
            base.OnEnter();
            shots = 1;
            maxShots = 4 * (uint)attackSpeedStat;
            durationBetweenShots = baseDurationBetweenShots / attackSpeedStat;
            duration = durationBetweenShots;
            modelTransform = GetModelTransform();
            modelAnimator = GetModelAnimator();
            if ((bool)characterBody)
            {
                characterBody.SetAimTimer(2f);
            }
            if (base.isAuthority)
            {
                FireBullet(shots);
                shots++;
            }
        }

        private void FireBullet(uint shots)
        {
            float damage = damageCoefficient / shots;
            Ray aimRay = GetAimRay();
            float proc = 1.0f;
            string muzzleName = "MuzzleRight";
            if ((bool)modelAnimator)
            {
                if ((bool)effectPrefab)
                {
                    EffectManager.SimpleMuzzleFlash(effectPrefab, gameObject, muzzleName, transmit: false);
                }
                PlayCrossfade("Gesture, Override", primaryStateHash, primaryPlaybackHash, .2f, .1f);
            }
            AddRecoil(-0.5f * recoilAmplitude, -1f * recoilAmplitude, -0.1f * recoilAmplitude, 0.15f * recoilAmplitude);
            if (isAuthority)
            {
                BulletAttack bulletAttack = new BulletAttack();
                bulletAttack.owner = gameObject;
                bulletAttack.weapon = gameObject;
                bulletAttack.origin = aimRay.origin;
                bulletAttack.maxSpread = shots * .5f;
                bulletAttack.aimVector = aimRay.direction;
                bulletAttack.bulletCount = shots;
                bulletAttack.damage = characterBody.damage * damage;
                bulletAttack.tracerEffectPrefab = tracerEffectPrefab;
                bulletAttack.muzzleName = muzzleName;
                bulletAttack.hitEffectPrefab = hitEffectPrefab;
                bulletAttack.isCrit = Util.CheckRoll(critStat, characterBody.master);
                bulletAttack.radius = bulletRadius;
                bulletAttack.maxDistance = 500f;
                bulletAttack.stopperMask = LayerIndex.world.mask;
                bulletAttack.damageType = DamageTypeCombo.GenericPrimary;
                bulletAttack.queryTriggerInteraction = QueryTriggerInteraction.Collide;
                bulletAttack.hitMask = LayerIndex.CommonMasks.bullet;
                bulletAttack.AddModdedDamageType(NemRifterDamage.instabilityProcDamage);
                bulletAttack.falloffModel = BulletAttack.FalloffModel.None;
                bulletAttack.procCoefficient = proc;
                bulletAttack.Fire();
            }
            Util.PlaySound(fireBarrageSoundString, gameObject);
        }

        public override void OnExit()
        {
            base.OnExit();
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            stopwatchBetweenShots += Time.fixedDeltaTime;
            characterBody.SetAimTimer(1f);
            if (isAuthority)
            {
                if (!IsKeyDownAuthority())
                {
                    FireBullet(maxShots);
                    outer.SetNextStateToMain();
                }
                if (stopwatchBetweenShots > durationBetweenShots)
                {
                    if (!hasReleased)
                    {
                        stopwatchBetweenShots = 0f;
                        FireBullet(1);
                    }
                }
            }

        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Skill;
        }
    }
}


