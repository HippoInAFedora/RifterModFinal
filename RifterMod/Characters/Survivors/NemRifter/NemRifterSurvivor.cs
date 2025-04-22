using BepInEx.Configuration;
using EntityStates;
using RifterMod.Modules;
using RifterMod.Modules.Characters;
using RoR2;
using System.Collections.Generic;
using UnityEngine;
using RoR2.Skills;
using R2API;
using RifterMod.Characters.Survivors.NemRifter.Components.Old;
using RifterMod.Characters.Survivors.NemRifter.SkillStates.Old;
using RifterMod.Survivors.NemRifter.SkillStates;
using RifterMod.Characters.Survivors.NemRifter.SkillStates;

namespace RifterMod.Survivors.NemRifter
{
    public class NemRifterSurvivor : SurvivorBase<NemRifterSurvivor>
    {
        //used to load the assetbundle for this character. must be unique
        public override string assetBundleName => "rifterassetbundle"; //if you do not change this, you are giving permission to deprecate the mod

        //the name of the prefab we will create. conventionally ending in "Body". must be unique
        public override string bodyName => "NemRifterBody"; //if you do not change this, you get the point by now

        //name of the ai master for vengeance and goobo. must be unique
        public override string masterName => "NemRifterMonsterMaster"; //if you do not

        //the names of the prefabs you set up in unity that we will use to build your character
        public override string modelPrefabName => "mdlNemRifter";
        public override string displayPrefabName => "NemRifterDisplay";

        public const string NEM_RIFTER_PREFIX = RifterPlugin.DEVELOPER_PREFIX + "_NEM_RIFTER_";

        //used when registering your survivor's language tokens
        public override string survivorTokenPrefix => NEM_RIFTER_PREFIX;

        public override BodyInfo bodyInfo => new BodyInfo
        {
            bodyName = bodyName,
            bodyNameToken = NEM_RIFTER_PREFIX + "NAME",
            subtitleNameToken = NEM_RIFTER_PREFIX + "SUBTITLE",

            characterPortrait = assetBundle.LoadAsset<Texture>("texNemRifterIcon"),
            bodyColor = new Color(0.329f, 0.42f, 0.651f),
            sortPosition = 100,

            crosshair = RifterMod.Modules.MyCharacterAssets.LoadCrosshair("SimpleDot"),
            podPrefab = LegacyResourcesAPI.Load<GameObject>("Prefabs/NetworkedObjects/SurvivorPod"),

            maxHealth = 130f,
            healthRegen = 1.5f,
            armor = 0f,

            jumpCount = 1,

            aimOriginPosition = new Vector3(0,1.5f,0)
    };

        public override CustomRendererInfo[] customRendererInfos => new CustomRendererInfo[]
        {
                new CustomRendererInfo
                {
                    childName = "HeadPiece"
                },
                new CustomRendererInfo
                {
                    childName = "GlassArm"
                },
                new CustomRendererInfo
                {
                    childName = "GlassLeg"
                },
                new CustomRendererInfo
                {
                    childName = "MainBody",
                },
                //new CustomRendererInfo
                //{
                //    childName = "BackVentTransparent"
                //}
        };

        public override UnlockableDef characterUnlockableDef => NemRifterUnlockables.characterUnlockableDef;

        public override ItemDisplaysBase itemDisplays => new NemRifterItemDisplays();

        //set in base classes
        public override AssetBundle assetBundle { get; protected set; }

        public override GameObject bodyPrefab { get; protected set; }
        public override CharacterBody prefabCharacterBody { get; protected set; }
        public override GameObject characterModelObject { get; protected set; }
        public override CharacterModel prefabCharacterModel { get; protected set; }
        public override GameObject displayPrefab { get; protected set; }

        public override void Initialize()
        {
            //uncomment if you have multiple characters
            //ConfigEntry<bool> characterEnabled = Config.CharacterEnableConfig("Survivors", "NemRifter");

            //if (!characterEnabled.Value)
            //    return;

            base.Initialize();
        }

        public override void InitializeCharacter()
        {
            //need the character unlockable before you initialize the survivordef
            NemRifterUnlockables.Init();

            base.InitializeCharacter();

            NemRifterConfig.Init();
            NemRifterStates.Init();
            NemRifterTokens.Init();

            NemRifterAssets.Init(assetBundle);
            NemRifterBuffs.Init(assetBundle);
            NemRifterDamage.SetupModdedDamage();

            InitializeEntityStateMachines();
            InitializeSkills();
            InitializeSkins();
            InitializeCharacterMaster();

            AdditionalBodySetup();
            
        }

        private void AdditionalBodySetup()
        {
            AddHitboxes();
            bodyPrefab.AddComponent<NemRifterSelfDamageController>();
        }

        public void AddHitboxes()
        {
            ChildLocator childLocator = characterModelObject.GetComponent<ChildLocator>();
            Transform hitBoxTransform = childLocator.FindChild("ScreenSlashHitbox");
            Prefabs.SetupHitBoxGroup(characterModelObject, "ScreenSlashGroup", hitBoxTransform);
            Transform hitBoxTransform2 = childLocator.FindChild("RiftSwordHitbox");
            Prefabs.SetupHitBoxGroup(characterModelObject, "RiftSwordGroup", hitBoxTransform2);            
            Transform hitBoxTransform3 = childLocator.FindChild("CorridorHitbox");
            Prefabs.SetupHitBoxGroup(characterModelObject, "CorridorGroup", hitBoxTransform3);

        }

        public override void InitializeEntityStateMachines()
        {
            //clear existing state machines from your cloned body (probably commando)
            //omit all this if you want to just keep theirs
            Prefabs.ClearEntityStateMachines(bodyPrefab);

            //if you set up a custom main characterstate, set it up here
            //don't forget to register custom entitystates in your NemRifterStates.cs
            //the main "body" state machine has some special properties
            Prefabs.AddMainEntityStateMachine(bodyPrefab, "Body", typeof(NemRifterMain), typeof(EntityStates.SpawnTeleporterState));

            Prefabs.AddEntityStateMachine(bodyPrefab, "Weapon");
            Prefabs.AddEntityStateMachine(bodyPrefab, "Weapon2");
        }

        #region skills
        public override void InitializeSkills()
        {
            //remove the genericskills from the commando body we cloned
            Skills.ClearGenericSkills(bodyPrefab);
            //add our own
            AddPassiveSkills();
            Skills.CreateSkillFamilies(bodyPrefab);

            AddPrimarySkills();
            AddSecondarySkills();
            AddUtiitySkills();
            AddSpecialSkills();
        }

        //if this is your first look at skilldef creation, take a look at Secondary first
        private void AddPassiveSkills()
        {

        }

        private void AddPrimarySkills()
        {
            SkillDef primarySkillDef1 = Skills.CreateSkillDef<SkillDef>(new SkillDefInfo
                (
                    "NemFracture",
                    NEM_RIFTER_PREFIX + "PRIMARY_NEM_FRACTURE",
                    NEM_RIFTER_PREFIX + "PRIMARY_NEM_FRACTURE_DESCRIPTION",
                    assetBundle.LoadAsset<Sprite>("texFocusedRiftFinal"),
                    new EntityStates.SerializableEntityStateType(typeof(NemShot)),
                    "Weapon",
                    false
                ));
            primarySkillDef1.baseRechargeInterval = .6f;
            primarySkillDef1.beginSkillCooldownOnSkillEnd = true;
            primarySkillDef1.keywordTokens = new[] { Tokens.fractureKeyword };
            //Skills.AddPrimarySkills(bodyPrefab, primarySkillDef1);

            Skills.AddPrimarySkills(bodyPrefab, primarySkillDef1);
        }

        private void AddSecondarySkills()
        {

            SkillDef secondarySkillDef1 = Skills.CreateSkillDef<SkillDef>(new SkillDefInfo
            {
                skillName = "RiftZoneDrop",
                skillNameToken = NEM_RIFTER_PREFIX + "SECONDARY_RIFT_ZONE",
                skillDescriptionToken = NEM_RIFTER_PREFIX + "SECONDARY_RIFT_ZONE_DESCRIPTION",
                skillIcon = assetBundle.LoadAsset<Sprite>("texFractureFinal"),
                keywordTokens = new[] { Tokens.fractureKeyword },
                activationState = new EntityStates.SerializableEntityStateType(typeof(Corridor)),
                activationStateMachineName = "Weapon",
                interruptPriority = InterruptPriority.Any,

                baseMaxStock = 1,

                baseRechargeInterval = 5f,

                stockToConsume = 1,

                mustKeyPress = true,

                beginSkillCooldownOnSkillEnd = false,
                isCombatSkill = true,
                canceledFromSprinting = false,
                cancelSprintingOnActivation = true,
                forceSprintDuringState = false,

            });
            Skills.AddSecondarySkills(bodyPrefab, secondarySkillDef1);
        }

        private void AddUtiitySkills()
        {

            SkillDef utilitySkillDef1 = Skills.CreateSkillDef<SkillDef>(new SkillDefInfo
            {
                skillName = "NemTeleport",
                skillNameToken = NEM_RIFTER_PREFIX + (NemRifterConfig.cursed.Value == true ? "UTILITY_PRESTIGE_SLIPSTREAM" : "UTILITY_SLIPSTREAM"),
                skillDescriptionToken = NEM_RIFTER_PREFIX + "UTILITY_SLIPSTREAM_DESCRIPTION",
                skillIcon = NemRifterConfig.cursed.Value == true ? assetBundle.LoadAsset<Sprite>("texPrestigeSlipstream") : assetBundle.LoadAsset<Sprite>("texSlipstreamFinal"),

                activationState = new EntityStates.SerializableEntityStateType(typeof(RiftZoneLocate)),
                //setting this to the "weapon2" EntityStateMachine allows us to cast this skill at the same time primary, which is set to the "weapon" EntityStateMachine
                activationStateMachineName = "Weapon",
                interruptPriority = InterruptPriority.PrioritySkill,
                //keywordTokens = new[] {},
                baseMaxStock = 1,
                baseRechargeInterval = 20f,

                stockToConsume = 1,

                forceSprintDuringState = true,
                canceledFromSprinting = false,
                isCombatSkill = false,
                mustKeyPress = true,
                beginSkillCooldownOnSkillEnd = true
            });

           
            Skills.AddUtilitySkills(bodyPrefab, utilitySkillDef1);

        }

        private void AddSpecialSkills()
        {
            //a basic skill
            SkillDef specialSkillDef1 = Skills.CreateSkillDef<SkillDef>(new SkillDefInfo
            {
                skillName = "Timelock",
                skillNameToken = NEM_RIFTER_PREFIX + "SPECIAL_TIMELOCK",
                skillDescriptionToken = NEM_RIFTER_PREFIX + "SPECIAL_TIMELOCK_DESCRIPTION",
                skillIcon = assetBundle.LoadAsset<Sprite>("texTimelockFinal"),
                keywordTokens = new[] {Tokens.crushingKeyword},
                activationState = new EntityStates.SerializableEntityStateType(typeof(RiftCollapse)),
                activationStateMachineName = "Weapon2",
                interruptPriority = InterruptPriority.PrioritySkill,

                baseMaxStock = 1,
                baseRechargeInterval = 5f,

                beginSkillCooldownOnSkillEnd = true,
                isCombatSkill = true,
                mustKeyPress = true,
                cancelSprintingOnActivation = true,
            });

            Skills.AddSpecialSkills(bodyPrefab, specialSkillDef1);

           
        }


        private void InitializeScepter()
        {
            //ItemBase<AncientScepterItem>.instance.RegisterScepterSkill(scepterSkillDef1, bodyName, SkillSlot.Special, 0);
        }

        #endregion skills

        #region skins
        public override void InitializeSkins()
        {
            ModelSkinController skinController = prefabCharacterModel.gameObject.AddComponent<ModelSkinController>();
            ChildLocator childLocator = prefabCharacterModel.GetComponent<ChildLocator>();

            CharacterModel.RendererInfo[] defaultRendererinfos = prefabCharacterModel.baseRendererInfos;

            List<SkinDef> skins = new List<SkinDef>();

            #region DefaultSkin
            //this creates a SkinDef with all default fields
            SkinDef defaultSkin = Skins.CreateSkinDef("DEFAULT_SKIN",
                assetBundle.LoadAsset<Sprite>("texNemRifterSkin"),
                defaultRendererinfos,
                prefabCharacterModel.gameObject);

            //these are your Mesh Replacements. The order here is based on your CustomRendererInfos from earlier
            //pass in meshes as they are named in your assetbundle
            //currently not needed as with only 1 skin they will simply take the default meshes
            //uncomment this when you have another skin
            //defaultSkin.meshReplacements = Modules.Skins.getMeshReplacements(assetBundle, defaultRendererinfos,
            //    "meshNemRifterSword",
            //    "meshNemRifterGun",
            //    "meshNemRifter");

            //add new skindef to our list of skindefs. this is what we'll be passing to the SkinController
            skins.Add(defaultSkin);
            #endregion

            //uncomment this when you have a mastery skin
            #region MasterySkin

            ////creating a new skindef as we did before
            //SkinDef masterySkin = Modules.Skins.CreateSkinDef(NEM_RIFTER_PREFIX + "MASTERY_SKIN_NAME",
            //    assetBundle.LoadAsset<Sprite>("texMasteryAchievement"),
            //    defaultRendererinfos,
            //    prefabCharacterModel.gameObject,
            //    NemRifterUnlockables.masterySkinUnlockableDef);

            ////adding the mesh replacements as above. 
            ////if you don't want to replace the mesh (for example, you only want to replace the material), pass in null so the order is preserved
            //masterySkin.meshReplacements = Modules.Skins.getMeshReplacements(assetBundle, defaultRendererinfos,
            //    "meshNemRifterSwordAlt",
            //    null,//no gun mesh replacement. use same gun mesh
            //    "meshNemRifterAlt");

            ////masterySkin has a new set of RendererInfos (based on default rendererinfos)
            ////you can simply access the RendererInfos' materials and set them to the new materials for your skin.
            //masterySkin.rendererInfos[0].defaultMaterial = assetBundle.LoadMaterial("matNemRifterAlt");
            //masterySkin.rendererInfos[1].defaultMaterial = assetBundle.LoadMaterial("matNemRifterAlt");
            //masterySkin.rendererInfos[2].defaultMaterial = assetBundle.LoadMaterial("matNemRifterAlt");

            ////here's a barebones example of using gameobjectactivations that could probably be streamlined or rewritten entirely, truthfully, but it works
            //masterySkin.gameObjectActivations = new SkinDef.GameObjectActivation[]
            //{
            //    new SkinDef.GameObjectActivation
            //    {
            //        gameObject = childLocator.FindChildGameObject("GunModel"),
            //        shouldActivate = false,
            //    }
            //};
            ////simply find an object on your child locator you want to activate/deactivate and set if you want to activate/deacitvate it with this skin

            //skins.Add(masterySkin);

            #endregion

            skinController.skins = skins.ToArray();
        }
        #endregion skins

        //Character Master is what governs the AI of your character when it is not controlled by a player (artifact of vengeance, goobo)
        public override void InitializeCharacterMaster()
        {
            //you must only do one of these. adding duplicate masters breaks the game.

            //if you're lazy or prototyping you can simply copy the AI of a different character to be used
            //Modules.Prefabs.CloneDopplegangerMaster(bodyPrefab, masterName, "Merc");

            //how to set up AI in code
            NemRifterAI.Init(bodyPrefab, masterName);

            //how to load a master set up in unity, can be an empty gameobject with just AISkillDriver components
            //assetBundle.LoadMaster(bodyPrefab, masterName);
        }

    }
}