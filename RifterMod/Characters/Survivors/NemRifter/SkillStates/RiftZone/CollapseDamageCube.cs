using EntityStates;
using RifterMod.Survivors.NemRifter;
using RoR2;
using RoR2.Projectile;
using System;
using UnityEngine;
using UnityEngine.Networking;

namespace RifterMod.Characters.Survivors.NemRifter.SkillStates.RiftZone
{
    public class CollapseDamageCube : BaseState
    {
        public GameObject owner;

        public TeamIndex team;

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
            team = owner.GetComponent<CharacterBody>().teamComponent.teamIndex;
            hurtBoxGroup = base.GetComponent<HurtBoxGroup>();
            scale = new Vector3(5f, 40f, 40f);
            ScaleParticleSystemDuration component = base.transform.GetChild(0).GetChild(0).GetComponent<ScaleParticleSystemDuration>();
            if (component != null)
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
                outer.SetNextStateToMain();
            }
        }

        public override void OnExit()
        {
            Destroy(base.gameObject);
            base.OnExit();
        }

        public override InterruptPriority GetMinimumInterruptPriority()
        {
            return InterruptPriority.Death;
        }

        private void DamageTeam()
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
                    if (FriendlyFireManager.ShouldSplashHitProceed(healthComponent, team))
                    {
                        DamageInfo damageInfo = new DamageInfo
                        {
                            attacker = base.gameObject,
                            damage = owner.GetComponent<CharacterBody>().damage * 10f,
                            position = healthComponent.body.transform.position,
                            procCoefficient = 0f,
                            damageType = DamageTypeCombo.GenericSpecial
                        };
                        //healthComponent.TakeDamageForce(vector3 * (num * num2), alwaysApply: true, disableAirControlUntilCollision: true);
                        healthComponent.TakeDamage(new DamageInfo
                        {
                            attacker = base.gameObject,
                            damage = owner.GetComponent<CharacterBody>().damage * 10f,
                            position = healthComponent.body.transform.position,
                            procCoefficient = 0f,
                            damageType = DamageTypeCombo.GenericSpecial
                        });
                        GlobalEventManager.instance.OnHitEnemy(damageInfo, healthComponent.gameObject);
                    }
                }
                HGPhysics.ReturnResults(colliders);
            }
        }
    }
}
