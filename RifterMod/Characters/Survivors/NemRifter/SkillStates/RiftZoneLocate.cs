using EntityStates;
using RifterMod.Survivors.NemRifter;
using RoR2;
using UnityEngine;
using UnityEngine.Networking;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates
{
    internal class RiftZoneLocate : BaseSkillState
    {

        public static GameObject riftZoneLocatorPrefab = NemRifterAssets.riftZonePillarIndicator;
        public static GameObject riftZoneLocatorInstance;

        public Animator modelAnimator;

        private int specialStateHash = Animator.StringToHash("Special Start");
        private int specialPlaybackHash = Animator.StringToHash("Special.playbackRate");

        private int inTimelock = Animator.StringToHash("inTimelock");



        public override void OnEnter()
        {
            base.OnEnter();
            modelAnimator = GetModelAnimator();

            if (modelAnimator)
            {
                modelAnimator.SetBool(inTimelock, true);
                PlayCrossfade("Gesture, Override", specialStateHash, specialPlaybackHash, .1f, .1f);
            }
            if ((bool)riftZoneLocatorPrefab)
            {
                riftZoneLocatorInstance = Object.Instantiate(riftZoneLocatorPrefab);
                riftZoneLocatorInstance.transform.localScale = new Vector3(10f, 10f, 10f);
            }
        }
        public override void FixedUpdate()
        {
            base.FixedUpdate();
            if (isAuthority)
            {
                if (!IsKeyDownAuthority())
                {
                    outer.SetNextState(new NemTeleport());
                }
            }

        }

        public override void Update()
        {
            base.Update();
            UpdateAreaIndicator();
        }

        private void UpdateAreaIndicator()
        {
            if ((bool)riftZoneLocatorInstance)
            {
                float maxDistance = 100f;
                riftZoneLocatorInstance.transform.position = GetAimRay().GetPoint(maxDistance);
                if (Physics.Raycast(GetAimRay(), out var hitInfo, maxDistance, LayerIndex.CommonMasks.bullet))
                {
                    riftZoneLocatorInstance.transform.position = hitInfo.point + hitInfo.normal * 5f;
                }
            }
        }

        public override void OnExit()
        {
            if ((bool)riftZoneLocatorInstance)
            {
                Destroy(riftZoneLocatorInstance);
            }
            if (modelAnimator)
            {
                modelAnimator.SetBool(inTimelock, false);
            }

            base.OnExit();
        }


        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Frozen;
        }

    }
}
