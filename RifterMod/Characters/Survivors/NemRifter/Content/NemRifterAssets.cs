using R2API;
using RifterMod.Characters.Survivors.NemRifter.Components;
using RifterMod.Characters.Survivors.NemRifter.Components.Old;
using RifterMod.Characters.Survivors.NemRifter.SkillStates.RiftZone;
using RifterMod.Modules;
using RoR2;
using RoR2.Projectile;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Networking;

namespace RifterMod.Survivors.NemRifter
{
    public static class NemRifterAssets
    {
        // particle effects

        internal static List<EffectDef> effectDefs = new List<EffectDef>();

        public static GameObject swordSwingEffect;
        public static GameObject swordHitImpactEffect;

        public static GameObject bombExplosionEffect;

        public static GameObject riftZonePillar;
        public static GameObject riftZonePillarIndicator;
        public static GameObject corridorRift;

        public static GameObject riftZonePillarShotEffect;

        public static GameObject screenSlashEffect;



        private static AssetBundle _assetBundle;

        public static void Init(AssetBundle assetBundle)
        {

            _assetBundle = assetBundle;

            CreateEffects();

            CreateProjectiles();
        }

        private static void CleanChildren(Transform startingTrans)
        {
            for (int num = startingTrans.childCount - 1; num >= 0; num--)
            {
                if (startingTrans.GetChild(num).childCount > 0)
                {
                    CleanChildren(startingTrans.GetChild(num));
                }
                UnityEngine.Object.DestroyImmediate((UnityEngine.Object)(object)((Component)startingTrans.GetChild(num)).gameObject);
            }
        }

        #region effects
        private static void CreateEffects()
        {
            CreateRiftZonePillar();
            CreateRiftCorridor();
            CreateTeleportIndicator();
            CreateScreenSlash();
        }

        private static void CreateRiftZonePillar()
        {
            riftZonePillarIndicator = _assetBundle.LoadAsset<GameObject>("RiftZoneAreaIndicator");
            PrefabAPI.RegisterNetworkPrefab(riftZonePillarIndicator);

            riftZonePillar = _assetBundle.LoadAsset<GameObject>("RiftZoneCylinder");

            //EntityStateManagement
            EntityStateMachine esm = riftZonePillar.GetComponent<EntityStateMachine>();
            esm.initialStateType = new EntityStates.SerializableEntityStateType(typeof(RiftZoneCylinder));
            esm.mainStateType = new EntityStates.SerializableEntityStateType(typeof(RiftZoneCylinder));

            //BuffwardManagement
            BuffWard buffWardTeam = riftZonePillar.transform.GetChild(0).GetComponent<BuffWard>();
            buffWardTeam.removalTime = riftZonePillar.GetComponent<DestroyOnTimer>().duration;

            PrefabAPI.RegisterNetworkPrefab(riftZonePillar);
        }

        private static void CreateRiftCorridor()
        {
            corridorRift = _assetBundle.LoadAsset<GameObject>("RiftZoneCube");

            //EntityStateManagement
            EntityStateMachine esm = corridorRift.GetComponent<EntityStateMachine>();
            esm.initialStateType = new EntityStates.SerializableEntityStateType(typeof(RiftZoneCube));
            esm.mainStateType = new EntityStates.SerializableEntityStateType(typeof(RiftZoneCube));

            //BuffwardManagement
            BuffWard buffWardTeam = corridorRift.transform.GetChild(0).GetComponent<BuffWard>();
            buffWardTeam.removalTime = corridorRift.GetComponent<ProjectileSimple>().lifetime;

            PrefabAPI.RegisterNetworkPrefab(corridorRift);
        }

        private static void CreateTeleportIndicator()
        {
        }

        private static void CreateScreenSlash()
        {
            screenSlashEffect = _assetBundle.LoadAsset<GameObject>("ScreenSlashEffect");
            screenSlashEffect.AddComponent<EffectComponent>();
            Content.CreateAndAddEffectDef(screenSlashEffect);
        }
        #endregion effects

        #region projectiles
        private static void CreateProjectiles()
        {

        }


       
        #endregion projectiles

        internal static void AddNewEffectDef(GameObject effectPrefab)
        {
            AddNewEffectDef(effectPrefab, "");
        }

        internal static void AddNewEffectDef(GameObject effectPrefab, string soundName)
        {
            EffectDef effectDef = new EffectDef();
            effectDef.prefab = effectPrefab;
            effectDef.prefabEffectComponent = effectPrefab.GetComponent<EffectComponent>();
            effectDef.prefabName = effectPrefab.name;
            effectDef.prefabVfxAttributes = effectPrefab.GetComponent<VFXAttributes>();
            effectDef.spawnSoundEventName = soundName;
            effectDefs.Add(effectDef);
        }
    }


}
