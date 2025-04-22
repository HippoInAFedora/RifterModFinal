using EntityStates;
using RifterMod.Survivors.NemRifter;
using RoR2;
using System;
using UnityEngine;
using UnityEngine.Networking;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates
{
    public class RiftCollapse : BaseState
    {
        private GameObject riftZonePrefab = NemRifterAssets.riftZonePillar;

        private GameObject riftZoneInstance;

        bool flag;
        public override void OnEnter()
        {
            base.OnEnter();
            if (NetworkServer.active)
            {
                base.characterBody.AddBuff(NemRifterBuffs.collapseRifts);
            }
            if (NetworkServer.active)
            {
                float radius = 15f;
                float expireDuration = 99f;
                riftZoneInstance = UnityEngine.Object.Instantiate(riftZonePrefab, characterBody.corePosition, transform.rotation);
                riftZoneInstance.GetComponent<DestroyOnTimer>().duration = expireDuration;
                riftZoneInstance.GetComponent<GenericOwnership>().ownerObject = base.gameObject;
                TeamFilter teamFilter = riftZoneInstance.GetComponent<TeamFilter>();
                teamFilter.teamIndex = TeamIndex.Player;
                BuffWard buffWardTeam = riftZoneInstance.transform.GetChild(0).GetComponent<BuffWard>();
                if (buffWardTeam != null)
                {
                    buffWardTeam.teamFilter = teamFilter;
                    buffWardTeam.radius = radius;
                    buffWardTeam.buffDef = NemRifterBuffs.negateDebuff;
                    buffWardTeam.expireDuration = expireDuration;
                }
                NetworkServer.Spawn(riftZoneInstance);
            }
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            if (!base.inputBank.skill4.down)
            {
                flag = true;
            }
            if (base.inputBank.skill4.justPressed && flag)
            {
                outer.SetNextStateToMain();
            }
        }

        public override void OnExit()
        {
            if (NetworkServer.active && base.characterBody.HasBuff(NemRifterBuffs.collapseRifts))
            {
                base.characterBody.RemoveBuff(NemRifterBuffs.collapseRifts);
            }
            base.OnExit();
        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Frozen;
        }
    }
}
