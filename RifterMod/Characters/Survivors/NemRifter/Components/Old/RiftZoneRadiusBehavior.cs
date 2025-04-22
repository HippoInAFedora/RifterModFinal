using HG;
using RoR2;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;
using static RoR2.HoldoutZoneController;
using static UnityEngine.UI.Image;

namespace RifterMod.Characters.Survivors.NemRifter.Components.Old
{
    public class RiftZoneRadiusBehavior : MonoBehaviour
    {
        private BuffWard buffWard;

        public TeamIndex teamIndex = TeamIndex.Player;

        public float radiusMin = 10f;

        public float radiusMax = 20f;

        private void Awake()
        {
            buffWard = GetComponent<BuffWard>();
        }

        private void Start()
        {
            buffWard.radius = radiusMin;
        }

        private void FixedUpdate()
        {
            bool teamInRadius = false;
            ReadOnlyCollection<TeamComponent> teamMembers = TeamComponent.GetTeamMembers(teamIndex);
            for (int i = 0; i < teamMembers.Count; i++)
            {
                TeamComponent teamComponent = teamMembers[i];
                if (teamComponent.body.isPlayerControlled && IsBodyInChargingRadius(buffWard, transform.position, buffWard.radius * buffWard.radius, teamComponent.body))
                {
                    teamInRadius = true;
                    break;
                }
            }
            if (teamInRadius)
            {
                buffWard.radius = radiusMax;
            }
            else
            {
                buffWard.radius = radiusMin;
            }

        }



        private static bool IsPointInChargingRadius(BuffWard buffWard, Vector3 origin, float chargingRadiusSqr, Vector3 point)
        {
            switch (buffWard.shape)
            {
                case BuffWard.BuffWardShape.Sphere:
                    if ((point - origin).sqrMagnitude <= chargingRadiusSqr)
                    {
                        return true;
                    }
                    break;
                case BuffWard.BuffWardShape.VerticalTube:
                    point.y = 0f;
                    origin.y = 0f;
                    if ((point - origin).sqrMagnitude <= chargingRadiusSqr)
                    {
                        return true;
                    }
                    break;
            }
            return false;
        }

        private static bool IsBodyInChargingRadius(BuffWard buffWard, Vector3 origin, float chargingRadiusSqr, CharacterBody characterBody)
        {
            return IsPointInChargingRadius(buffWard, origin, chargingRadiusSqr, characterBody.corePosition);
        }

        public bool IsBodyInChargingRadius(CharacterBody body)
        {
            if (!body)
            {
                return false;
            }
            return IsBodyInChargingRadius(buffWard, transform.position, buffWard.radius * buffWard.radius, body);
        }

    }
}
