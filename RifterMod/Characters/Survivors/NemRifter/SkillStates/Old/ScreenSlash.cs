using RoR2;
using UnityEngine;
using RifterMod.Modules.BaseStates;
using UnityEngine.Networking;
using RifterMod.Survivors.Rifter;
using System.Collections.Generic;
using RifterMod.Survivors.NemRifter;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.Old
{
    public class ScreenSlash : BaseMeleeAttack
    {
        List<Collider> colliders = new List<Collider>();

        List<Collider> riftZoneColliders = new List<Collider>();

        bool flag = false;
        public override void OnEnter()
        {
            hitboxGroupName = "ScreenSlashGroup";

            moddedDamageTypeHolder.Add(NemRifterDamage.instabilityTriggerDamage);

            damageCoefficient = NemRifterStaticValues.slashDamageCoefficient;
            damageType = DamageTypeCombo.GenericPrimary;
            procCoefficient = 1f;
            pushForce = 300f;
            bonusForce = Vector3.zero;
            baseDuration = 1.0f;

            //0-1 multiplier of baseduration, used to time when the hitbox is out (usually based on the run time of the animation)
            //for example, if attackStartPercentTime is 0.5, the attack will start hitting halfway through the ability. if baseduration is 3 seconds, the attack will start happening at 1.5 seconds
            attackStartPercentTime = 0.25f;
            attackEndPercentTime = .3f;

            //this is the point at which the attack can be interrupted by itself, continuing a combo
            earlyExitPercentTime = 1f / attackSpeedStat;

            hitStopDuration = 0.05f;
            attackRecoil = 0.5f;
            hitHopVelocity = 5f;

            //swingSoundString = "HenrySwordSwing";
            hitSoundString = "";
            muzzleString = "Pivot";
            playbackRateParam = "Slash.playbackRate";
            swingEffectPrefab = NemRifterAssets.screenSlashEffect;
            hitEffectPrefab = RifterAssets.swordHitImpactEffect;

            //impactSound = GlaiveAssets.swordHitSoundEvent.index;

            base.OnEnter();
            StartAimMode(.5f + duration);

            SphereSearch search = new SphereSearch();
            search.ClearCandidates();
            search.origin = GetAimRay().GetPoint(250f);
            search.radius = 300f;
            search.mask = LayerIndex.projectile.mask;
            search.RefreshCandidates();
            search.FilterCandidatesByDistinctColliderEntities();
            search.GetColliders(colliders);
            for (int i = 0; i < colliders.Count; i++)
            {
                if (colliders[i].name == "RiftZoneBuffWard(Clone)")
                {
                    riftZoneColliders.Add(colliders[i]);
                }
            }
            colliders.Clear();
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            if (fixedAge > duration * attackStartPercentTime && !flag)
            {
                foreach (var collider in riftZoneColliders)
                {
                    BulletAttack bulletAttackRiftZone = new BulletAttack();
                    bulletAttackRiftZone.owner = gameObject;
                    bulletAttackRiftZone.weapon = gameObject;
                    bulletAttackRiftZone.origin = collider.gameObject.transform.position - Vector3.up * 250f;
                    bulletAttackRiftZone.aimVector = Vector3.up;
                    bulletAttackRiftZone.bulletCount = 1u;
                    bulletAttackRiftZone.damage = characterBody.damage * damageCoefficient * 2;
                    bulletAttackRiftZone.tracerEffectPrefab = null;
                    bulletAttackRiftZone.muzzleName = null;
                    bulletAttackRiftZone.hitEffectPrefab = hitEffectPrefab;
                    bulletAttackRiftZone.isCrit = Util.CheckRoll(critStat, characterBody.master);
                    bulletAttackRiftZone.radius = collider.gameObject.GetComponent<BuffWard>().radius;
                    bulletAttackRiftZone.maxDistance = 500f;
                    bulletAttackRiftZone.stopperMask = LayerIndex.noCollision.mask;
                    bulletAttackRiftZone.damageType = DamageTypeCombo.GenericPrimary;
                    bulletAttackRiftZone.Fire();
                }
                flag = true;
            }
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
            riftZoneColliders.Clear();
            base.OnExit();
        }
    }
}