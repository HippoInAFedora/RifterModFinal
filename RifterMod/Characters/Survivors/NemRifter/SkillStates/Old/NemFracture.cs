using RoR2;
using EntityStates;
using UnityEngine;
using RifterMod.Survivors.Rifter;
using static UnityEngine.SendMouseEvents;
using System.Collections.Generic;
using Newtonsoft.Json.Utilities;
using R2API;
using RifterMod.Survivors.NemRifter;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.Old
{
    public class NemFracture : BaseSkillState
    {
        public static GameObject effectPrefab = RifterAssets.hitEffect;

        public static GameObject hitEffectPrefab = RifterAssets.hitEffect;

        public static GameObject tracerEffectPrefab = RifterAssets.fractureLineTracer;

        public static float damageCoefficient = NemRifterStaticValues.basePrimaryDamage;

        public static float force = 25f;

        public static float minSpread = 1f;

        public static float maxSpread = 5f;

        public static float baseDurationBetweenShots = .1f;

        public int shotCounter;

        public int shotCounterMax;

        public static string fireBarrageSoundString;

        public static float recoilAmplitude = 1f;

        public static float spreadBloomValue;

        public static float bulletRadius = .2f;

        public float stopwatchBetweenShots;

        private Animator modelAnimator;

        private Transform modelTransform;

        private float duration;

        private float durationBetweenShots;

        private static int primaryStateHash = Animator.StringToHash("Primary");

        private static int primaryPlaybackHash = Animator.StringToHash("ShootRift.playbackRate");

        private List<Collider> riftZones = new List<Collider>();

        public override void OnEnter()
        {
            base.OnEnter();
            durationBetweenShots = baseDurationBetweenShots / attackSpeedStat;
            duration = durationBetweenShots * shotCounter;
            modelTransform = GetModelTransform();
            modelAnimator = GetModelAnimator();
            if ((bool)characterBody)
            {
                characterBody.SetAimTimer(2f);
            }
        }

        private void FireBullet()
        {
            riftZones.Clear();
            Ray aimRay = GetAimRay();
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
                bulletAttack.maxSpread = spreadBloomValue;
                bulletAttack.minSpread = minSpread;
                bulletAttack.aimVector = aimRay.direction;
                bulletAttack.bulletCount = 1u;
                bulletAttack.damage = characterBody.damage * damageCoefficient;
                bulletAttack.tracerEffectPrefab = tracerEffectPrefab;
                bulletAttack.muzzleName = muzzleName;
                bulletAttack.hitEffectPrefab = hitEffectPrefab;
                bulletAttack.isCrit = Util.CheckRoll(critStat, characterBody.master);
                bulletAttack.radius = bulletRadius;
                bulletAttack.maxDistance = 500f;
                bulletAttack.stopperMask = LayerIndex.world.mask;
                bulletAttack.damageType = DamageTypeCombo.GenericPrimary;
                bulletAttack.queryTriggerInteraction = QueryTriggerInteraction.Collide;
                bulletAttack.hitMask = LayerIndex.CommonMasks.bullet | LayerIndex.projectile.mask;
                bulletAttack.AddModdedDamageType(NemRifterDamage.instabilityProcDamage);
                bulletAttack.modifyOutgoingDamageCallback = delegate (BulletAttack _bulletAttack, ref BulletAttack.BulletHit hitInfo, DamageInfo damageInfo)
                {
                    if (hitInfo.collider != null)
                    {
                        if (hitInfo.collider.gameObject.name == "RiftZoneBuffWard(Clone)")
                        {
                            riftZones.AddDistinct(hitInfo.collider);
                            EffectData effectData = new EffectData
                            {
                                scale = hitInfo.collider.gameObject.GetComponent<BuffWard>().radius,
                                origin = hitInfo.point - hitInfo.surfaceNormal * hitInfo.collider.gameObject.GetComponent<BuffWard>().radius,
                            };
                            EffectManager.SpawnEffect(NemRifterAssets.riftZonePillarShotEffect, effectData, true);
                        }
                    }
                };
                bulletAttack.Fire();

                //for (int i = 0; i < riftZones.Count; i++)
                //{
                //    BulletAttack bulletAttackRiftZone = new BulletAttack();
                //    bulletAttackRiftZone.owner = gameObject;
                //    bulletAttackRiftZone.weapon = gameObject;
                //    bulletAttackRiftZone.origin = riftZones[i].gameObject.transform.position - Vector3.up * 250f;
                //    bulletAttackRiftZone.aimVector = Vector3.up;
                //    bulletAttackRiftZone.bulletCount = 1u;
                //    bulletAttackRiftZone.damage = characterBody.damage * damageCoefficient * 2f;
                //    bulletAttackRiftZone.tracerEffectPrefab = null;
                //    bulletAttackRiftZone.muzzleName = muzzleName;
                //    bulletAttackRiftZone.hitEffectPrefab = hitEffectPrefab;
                //    bulletAttackRiftZone.isCrit = Util.CheckRoll(critStat, characterBody.master);
                //    bulletAttackRiftZone.radius = riftZones[i].gameObject.GetComponent<BuffWard>().radius;
                //    bulletAttackRiftZone.maxDistance = 500f;
                //    bulletAttackRiftZone.stopperMask = LayerIndex.noCollision.mask;
                //    bulletAttackRiftZone.damageType = DamageTypeCombo.GenericPrimary;
                //    bulletAttackRiftZone.Fire();
                //}
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
            spreadBloomValue = Mathf.Lerp(maxSpread, minSpread, fixedAge / duration);
            characterBody.SetSpreadBloom(spreadBloomValue, false);
            if (isAuthority)
            {
                if (fixedAge > duration && !IsKeyDownAuthority())
                {
                    outer.SetNextStateToMain();
                }
                if (stopwatchBetweenShots > durationBetweenShots)
                {
                    stopwatchBetweenShots = 0f;
                    FireBullet();
                }
            }

        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Skill;
        }
    }
}


