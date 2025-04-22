using EntityStates;
using RoR2;
using System;
using System.Collections.Generic;
using UnityEngine;
using RoR2.Projectile;
using RifterMod.Survivors.NemRifter;
using UnityEngine.Networking;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.RiftZone
{
    public class RiftZoneCube : BaseState
    {
        public HurtBoxGroup hurtBoxGroup;

        public float radius;

        public Vector3 scale;

        public static float scanInterval = .2f;

        private float scanTimer;

        private bool flag;

        private GameObject killObject;

        public override void OnEnter()
        {
            base.OnEnter();
            hurtBoxGroup = base.GetComponent<HurtBoxGroup>();
            scale = new Vector3 (2.5f, 32.5f, 32.5f);
            ScaleParticleSystemDuration component = base.transform.GetChild(0).GetChild(0).GetComponent<ScaleParticleSystemDuration>();
            if (component != null )
            {
                component.newDuration = GetComponent<ProjectileSimple>().lifetime;
            }
            base.transform.GetChild(0).GetChild(0).localScale = scale;
            base.transform.GetChild(0).GetChild(0).position = base.transform.position + base.transform.forward * 30f;
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            scanTimer += Time.fixedDeltaTime;
            if (scanTimer > scanInterval) 
            {
                BuffTeam();
                scanTimer = 0;
            }
            if (flag)
            {
                outer.SetNextState(new CollapseDamageCube { owner = killObject });
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

        private void BuffTeam()
        {
            if (NetworkServer.active)
            {
                Vector3 forward = base.transform.forward;
                Vector3 halfExtents = scale;
                Vector3 center = base.transform.position + base.transform.forward * 30f;
                //Quaternion orientation = Util.QuaternionSafeLookRotation(forward);
                Collider[] colliders;
                int num2 = HGPhysics.OverlapBox(out colliders, center, halfExtents, base.transform.rotation, LayerIndex.entityPrecise.mask);
                for (int i = 0; i < num2; i++)
                {
                    HurtBox component = colliders[i].GetComponent<HurtBox>();
                    if (!component)
                    {
                        continue;
                    }
                    HealthComponent healthComponent = component.healthComponent;
                    if ((bool)healthComponent)
                    {
                        CharacterBody body = healthComponent.body;
                        if (body.bodyIndex == RifterPlugin.nemRifterIndex)
                        {
                            if (body.HasBuff(NemRifterBuffs.collapseRifts))
                            {
                                killObject = body.gameObject;
                                body.healthComponent.AddBarrier(15f);
                                flag = true;
                            }
                            body.AddTimedBuff(NemRifterBuffs.negateDebuff, .3f);
                        }
                    }
                }
                HGPhysics.ReturnResults(colliders);
            }           
        }
    }
}
