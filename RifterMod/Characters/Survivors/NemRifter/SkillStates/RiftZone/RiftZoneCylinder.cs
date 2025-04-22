using EntityStates;
using RoR2;
using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using static RoR2.BuffWard;
using static UnityEngine.ParticleSystem.PlaybackState;
using UnityEngine.Networking;
using RifterMod.Survivors.NemRifter;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.RiftZone
{
    public class RiftZoneCylinder : BaseState
    {
        public BuffWard buffWard;

        public float radius;

        public static float scanInterval = .5f;

        private float scanTimer;

        private TeamFilter teamFilter;

        private GameObject owner;

        public override void OnEnter()
        {
            base.OnEnter();
            owner = base.GetComponent<GenericOwnership>().ownerObject;
            teamFilter = base.GetComponent<TeamFilter>();
            buffWard = base.transform.GetChild(0).GetComponent<BuffWard>();
            if (buffWard != null )
            {
                radius = buffWard.radius;
            }
            float radiusSqr = radius * radius;
            for (TeamIndex teamIndex = TeamIndex.Neutral; teamIndex < TeamIndex.Count; teamIndex++)
            {
                if (teamIndex != teamFilter.teamIndex)
                {
                    DamageTeam(TeamComponent.GetTeamMembers(teamIndex), radiusSqr, base.transform.position);
                }
            }
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            scanTimer += Time.fixedDeltaTime;
            if (scanTimer > scanInterval) 
            {
                if (buffWard != null)
                {
                    radius = buffWard.radius;
                }
                float radiusSqr = radius * radius;
                for (TeamIndex teamIndex = TeamIndex.Neutral; teamIndex < TeamIndex.Count; teamIndex++)
                {
                    if (teamIndex != teamFilter.teamIndex)
                    {
                        DamageTeam(TeamComponent.GetTeamMembers(teamIndex), radiusSqr, base.transform.position);
                    }
                    if (teamIndex == teamFilter.teamIndex)
                    {
                        CheckForDestroy(TeamComponent.GetTeamMembers(teamIndex), radiusSqr, base.transform.position);
                    }
                }
                scanTimer = 0;
            }
        }

        public override void OnExit()
        {
            base.OnExit();
        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Death;
        }

        private void DamageTeam(IEnumerable<TeamComponent> recipients, float radiusSqr, Vector3 currentPosition)
        {
            if (NetworkServer.active)
            {
                foreach (TeamComponent recipient in recipients)
                {
                    Vector3 vector = recipient.transform.position - currentPosition;
                    vector.y = 0f;
                    if (vector.sqrMagnitude <= radiusSqr)
                    {
                        CharacterBody component = recipient.GetComponent<CharacterBody>();
                        if (component != null)
                        {
                            DamageInfo damageInfo = new DamageInfo();
                            damageInfo.damage = owner.GetComponent<CharacterBody>().damage * scanInterval;
                            damageInfo.position = component.corePosition;
                            damageInfo.force = Vector3.zero;
                            damageInfo.damageColorIndex = DamageColorIndex.Default;
                            damageInfo.crit = false;
                            damageInfo.attacker = null;
                            damageInfo.inflictor = null;
                            damageInfo.damageType = DamageType.Silent;
                            damageInfo.procCoefficient = 0f;
                            damageInfo.procChainMask = default(ProcChainMask);
                            component.healthComponent.TakeDamage(damageInfo);
                        }
                    }
                }
            }
        }

        private void CheckForDestroy(IEnumerable<TeamComponent> recipients, float radiusSqr, Vector3 currentPosition)
        {
            if (NetworkServer.active)
            {
                foreach (TeamComponent recipient in recipients)
                {
                    Vector3 vector = recipient.transform.position - currentPosition;
                    vector.y = 0f;
                    if (vector.sqrMagnitude <= radiusSqr)
                    {
                        CharacterBody component = recipient.GetComponent<CharacterBody>();
                        if (component.HasBuff(NemRifterBuffs.collapseRifts))
                        {
                            component.healthComponent.AddBarrier(15f);
                            outer.SetNextState(new CollapseDamageCylinder { owner = owner });
                        }
                    }
                }
            }
        }
    }
}
