using EntityStates;
using RifterMod.Characters.Survivors.Rifter.Components;
using RifterMod.Survivors.NemRifter;
using RifterMod.Survivors.Rifter;
using RoR2;
using UnityEngine;
using UnityEngine.Networking;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.Old
{
    internal class RiftZoneDrop : BaseSkillState
    {
        public float radius = 10f;
        private float duration = .5f;

        public Vector3 position;
        public Quaternion rotation;

        public GameObject riftZonePrefab = NemRifterAssets.riftZonePillar;
        private GameObject riftZoneInstance;

        private BuffWard buffWardTeam;
        private BuffWard buffWardEnemy;
        private TeamFilter teamFilter;
        private EntityLocator entityLocator;

        private int specialStateHash = Animator.StringToHash("Special End");
        private int specialPlaybackHash = Animator.StringToHash("Special.playbackRate");

        private int inTimelock = Animator.StringToHash("inTimelock");

        public Animator modelAnimator;


        public override void OnEnter()
        {
            base.OnEnter();
            float maxDistance = 100f;
            modelAnimator = GetModelAnimator();
            if (modelAnimator)
            {
                modelAnimator.SetBool(inTimelock, false);
                PlayCrossfade("Gesture, Override", specialStateHash, specialPlaybackHash, .1f, .1f);
            }

            position = GetAimRay().GetPoint(maxDistance);
            if (Physics.Raycast(GetAimRay(), out var hitInfo, maxDistance, LayerIndex.CommonMasks.bullet))
            {
                position = hitInfo.point;
            }
            if (NetworkServer.active)
            {
                riftZoneInstance = Object.Instantiate(riftZonePrefab, position, transform.rotation);
                buffWardTeam = riftZoneInstance.transform.GetChild(0).GetComponent<BuffWard>();
                if (buffWardEnemy != null)
                {
                    buffWardEnemy.buffDef = NemRifterBuffs.negateDebuff;
                }
                buffWardEnemy = riftZoneInstance.transform.GetChild(1).GetComponent<BuffWard>();
                teamFilter = riftZoneInstance.GetComponent<TeamFilter>();
                teamFilter.teamIndex = TeamIndex.Player;
                NetworkServer.Spawn(riftZoneInstance);
            }
        }
        public override void FixedUpdate()
        {
            base.FixedUpdate();
            if (fixedAge > duration && isAuthority)
            {
                outer.SetNextStateToMain();
            }
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
