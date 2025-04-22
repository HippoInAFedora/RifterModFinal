using RoR2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

namespace RifterMod.Survivors.NemRifter.Components
{
    [RequireComponent(typeof(CharacterBody))]
    [RequireComponent(typeof(InputBankTest))]
    [RequireComponent(typeof(TeamComponent))]
    public class NemRifterTracker : MonoBehaviour
    {
        public GameObject trackingPrefab;

        private Collider collider;

        private Vector3 collisionPoint;

        private Vector3 collisionPointNormal;

        public float trackerUpdateFrequency = 10f;

        private CharacterBody characterBody;

        private InputBankTest inputBank;

        private float trackerUpdateStopwatch;

        private Indicator indicator;


        private void Awake()
        {
            if (trackingPrefab == null)
            {
                trackingPrefab = LegacyResourcesAPI.Load<GameObject>("Prefabs/HuntressTrackingIndicator");
            }
            indicator = new Indicator(base.gameObject, trackingPrefab);
        }

        private void Start()
        {
            characterBody = GetComponent<CharacterBody>();
            inputBank = GetComponent<InputBankTest>();
        }

        public Collider GetTrackingTarget()
        {
            return collider;
        }

        public Vector3 GetCollisionPoint()
        {
            return collisionPoint;
        }

        public Vector3 GetCollisionPointNormal()
        {
            return collisionPoint;
        }

        private void OnEnable()
        {
            indicator.active = true;
        }

        private void OnDisable()
        {
            indicator.active = false;
        }

        private void FixedUpdate()
        {
            MyFixedUpdate(Time.fixedDeltaTime);
        }

        private void MyFixedUpdate(float deltaTime)
        {
            trackerUpdateStopwatch += deltaTime;
            if (trackerUpdateStopwatch >= 1f / trackerUpdateFrequency)
            {
                bool colliderSelected = false;


                Ray aimRay = new Ray(inputBank.aimOrigin, inputBank.aimDirection);
                RaycastHit[] hitInfo = Physics.SphereCastAll(aimRay.origin, 5f, aimRay.direction, NemRifterStaticValues.maxTeleportDistance, LayerIndex.world.mask | LayerIndex.projectile.mask, QueryTriggerInteraction.Collide);
                for (int i = 0; i < hitInfo.Length; i++)
                {
                    if (hitInfo[i].collider.gameObject.name == "RiftZoneBuffWard(Clone)")
                    {
                        collider = hitInfo[i].collider;
                        collisionPoint = hitInfo[i].point;
                        collisionPointNormal = hitInfo[i].normal;
                        colliderSelected = true;
                        break;
                    }
                }
                if (!colliderSelected)
                {
                    collisionPoint = Vector3.zero;
                    collider = null;
                }
            }
        }
    }
}
