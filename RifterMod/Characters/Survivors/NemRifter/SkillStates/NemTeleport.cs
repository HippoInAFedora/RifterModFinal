using EntityStates;
using EntityStates.Huntress;
using IL.RoR2.Skills;
using RifterMod.Characters.Survivors.NemRifter.Components.Old;
using RifterMod.Characters.Survivors.Rifter.SkillStates;
using RifterMod.Survivors.NemRifter;
using RifterMod.Survivors.Rifter;
using RoR2;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UIElements;
using static UnityEngine.SendMouseEvents;
using static UnityEngine.UI.Image;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates
{
    public class NemTeleport : BaseSkillState
    {
        public static float duration = 0.5f;

        public static float initialSpeedCoefficient = 1f;

        public static float finalSpeedCoefficient = 1f;

        public GameObject riftZonePrefab = NemRifterAssets.riftZonePillar;
        private GameObject riftZoneInstance;


        public Vector3 forwardDirection;

        public static float dodgeFOV = 2f;

        public float speedCoefficient = 25f;

        private CharacterModel characterModel;
        private HurtBoxGroup hurtboxGroup;
        private Transform modelTransform;
        private Animator modelAnimator;
        private int utilityStateHash = Animator.StringToHash("Utility");
        private int utilityPlaybackHash = Animator.StringToHash("Utility.playbackRate");

        private int utilityFullBodyStateHash = Animator.StringToHash("FullBody Descend");

        private int inTimelock = Animator.StringToHash("inTimelock");

        public Vector3 initialPosition;
        public Vector3 currentPosition;
        public Vector3 targetFootPosition;

        private BuffWard buffWardTeam;
        private BuffWard buffWardEnemy;

        public bool hasSnapped;

        public override void OnEnter()
        {
            float maxDistance = 100f;
            modelAnimator = GetModelAnimator();
            targetFootPosition = GetAimRay().GetPoint(maxDistance);
            if (Physics.Raycast(GetAimRay(), out var hitInfo, maxDistance, LayerIndex.CommonMasks.bullet))
            {
                targetFootPosition = hitInfo.point;
            }
            if (modelAnimator)
            {
                modelAnimator.SetBool(inTimelock, false);
                PlayCrossfade("FullBody, Override", utilityFullBodyStateHash, utilityPlaybackHash, .3f, .25f);
                PlayCrossfade("Gesture, Override", utilityStateHash, utilityPlaybackHash, .3f, .25f);
            }
            if ((bool)modelTransform)
            {
                characterModel = modelTransform.GetComponent<CharacterModel>();
                hurtboxGroup = modelTransform.GetComponent<HurtBoxGroup>();
            }
            if ((bool)characterModel)
            {
                characterModel.invisibilityCount++;
            }
            if ((bool)hurtboxGroup)
            {
                HurtBoxGroup hurtBoxGroup = hurtboxGroup;
                int hurtBoxesDeactivatorCounter = hurtBoxGroup.hurtBoxesDeactivatorCounter + 1;
                hurtBoxGroup.hurtBoxesDeactivatorCounter = hurtBoxesDeactivatorCounter;
            }
            CalculateSnapDestination();
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            if ((bool)characterMotor)
            {
                characterMotor.velocity = Vector3.zero;
            }
            if (!hasSnapped)
            {
                SetPosition(Vector3.Lerp(currentPosition, targetFootPosition, fixedAge / duration));
            }
            if (fixedAge >= duration && isAuthority)
            {
                hasSnapped = true;
                outer.SetNextStateToMain();
            }
        }

        public override void OnExit()
        {
            if ((bool)characterModel)
            {
                characterModel.invisibilityCount--;
            }
            if ((bool)hurtboxGroup)
            {
                HurtBoxGroup hurtBoxGroup = hurtboxGroup;
                int hurtBoxesDeactivatorCounter = hurtBoxGroup.hurtBoxesDeactivatorCounter - 1;
                hurtBoxGroup.hurtBoxesDeactivatorCounter = hurtBoxesDeactivatorCounter;
            }
            if ((bool)characterMotor)
            {
                characterMotor.disableAirControlUntilCollision = false;
            }
            if (!outer.destroying)
            {
                modelTransform = GetModelTransform();
                if ((bool)modelTransform)
                {
                    TemporaryOverlayInstance temporaryOverlay = TemporaryOverlayManager.AddOverlay(modelTransform.gameObject);
                    temporaryOverlay.duration = 0.6f;
                    temporaryOverlay.animateShaderAlpha = true;
                    temporaryOverlay.alphaCurve = AnimationCurve.EaseInOut(0f, 1f, 1f, 0f);
                    temporaryOverlay.destroyComponentOnEnd = true;
                    temporaryOverlay.originalMaterial = RifterAssets.matTeleport;
                    temporaryOverlay.AddToCharacterModel(modelTransform.GetComponent<CharacterModel>());
                }
            }

            if (NetworkServer.active)
            {
                float radius = 40f;
                float expireDuration = 30f;
                riftZoneInstance = Object.Instantiate(riftZonePrefab, characterBody.corePosition, transform.rotation);
                riftZoneInstance.GetComponent<DestroyOnTimer>().duration = expireDuration;
                riftZoneInstance.GetComponent<GenericOwnership>().ownerObject = base.gameObject;
                TeamFilter teamFilter = riftZoneInstance.GetComponent<TeamFilter>();
                teamFilter.teamIndex = TeamIndex.Player;
                buffWardTeam = riftZoneInstance.transform.GetChild(0).GetComponent<BuffWard>();
                if (buffWardTeam != null)
                {
                    buffWardTeam.teamFilter = teamFilter;
                    buffWardTeam.radius = radius;
                    buffWardTeam.buffDef = NemRifterBuffs.negateDebuff;
                    buffWardTeam.expireDuration = expireDuration;
                }
                NetworkServer.Spawn(riftZoneInstance);
            }

            //if (isAuthority)
            //{
            //    BulletAttack bulletAttackRiftZone = new BulletAttack();
            //    bulletAttackRiftZone.owner = gameObject;
            //    bulletAttackRiftZone.weapon = gameObject;
            //    bulletAttackRiftZone.origin = characterBody.corePosition - Vector3.up * 250f;
            //    bulletAttackRiftZone.aimVector = Vector3.up;
            //    bulletAttackRiftZone.bulletCount = 1u;
            //    bulletAttackRiftZone.damage = characterBody.damage * NemRifterStaticValues.riftDamagePostTeleport;
            //    bulletAttackRiftZone.tracerEffectPrefab = null;
            //    bulletAttackRiftZone.muzzleName = null;
            //    bulletAttackRiftZone.hitEffectPrefab = null;
            //    bulletAttackRiftZone.isCrit = Util.CheckRoll(critStat, characterBody.master);
            //    bulletAttackRiftZone.radius = 15f;
            //    bulletAttackRiftZone.maxDistance = 500f;
            //    bulletAttackRiftZone.stopperMask = LayerIndex.noCollision.mask;
            //    bulletAttackRiftZone.damageType = DamageTypeCombo.GenericPrimary;
            //    bulletAttackRiftZone.Fire();
            //}

            base.OnExit();
        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Frozen;
        }

        private void SetPosition(Vector3 newPosition)
        {
            if ((bool)characterMotor)
            {
                characterMotor.Motor.SetPositionAndRotation(newPosition, Quaternion.identity);
            }
            if ((bool)rigidbodyMotor)
            {
                rigidbodyMotor.transform.SetPositionAndRotation(newPosition, Quaternion.identity);
            }
        }

        private void CalculateSnapDestination()
        {
            if (characterDirection != null)
            {
                characterDirection.forward = targetFootPosition;
            }
            else
            {
                transform.rotation = Util.QuaternionSafeLookRotation(targetFootPosition);
            }

            if (characterBody.footPosition != null)
            {
                currentPosition = characterBody.footPosition;
            }
            else
            {
                currentPosition = characterBody.corePosition;
            }
            duration = (currentPosition - targetFootPosition).magnitude;
            duration = Util.Remap(duration, 0f, 100f, 0.1f, .25f);
        }

        public override void OnSerialize(NetworkWriter writer)
        {
            base.OnSerialize(writer);
            writer.Write(targetFootPosition);
            writer.Write(currentPosition);
        }

        public override void OnDeserialize(NetworkReader reader)
        {
            base.OnDeserialize(reader);
            targetFootPosition = reader.ReadVector3();
            currentPosition = reader.ReadVector3();
        }



    }

}


