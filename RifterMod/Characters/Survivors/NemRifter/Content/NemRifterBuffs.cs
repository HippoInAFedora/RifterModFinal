using RoR2;
using UnityEngine;
using RifterMod.Survivors.Rifter;

namespace RifterMod.Survivors.NemRifter
{
    public static class NemRifterBuffs
    {
        // armor buff gained during roll
        public static BuffDef instabilityDebuff;

        public static BuffDef instabilityTriggerDebuff;

        public static BuffDef outsideRiftDebuff;

        public static BuffDef negateDebuff;

        public static BuffDef collapseRifts;

        public static AssetBundle _assetBundle;

        public static void Init(AssetBundle assetBundle)
        {
            instabilityDebuff = Modules.Content.CreateAndAddBuff("InstabilityDebuff",
               RifterAssets.shatterIcon,
               Color.white,
               true,
               true);
            instabilityDebuff.isHidden = false;

            instabilityTriggerDebuff = Modules.Content.CreateAndAddBuff("InstabilityTriggerDebuff",
               RifterAssets.shatterIcon,
               Color.white,
               false,
               false);
            instabilityDebuff.isHidden = true;

            outsideRiftDebuff = Modules.Content.CreateAndAddBuff("OutsideRiftDebuff",
               RifterAssets.shatterIcon,
               Color.white,
               false,
               true);
            outsideRiftDebuff.isHidden = false;

            negateDebuff = Modules.Content.CreateAndAddBuff("NegateOutsideRiftDebuff",
               RifterAssets.shatterIcon,
               Color.white,
               false,
               false);
            negateDebuff.isHidden = true;

            collapseRifts = Modules.Content.CreateAndAddBuff("CollapseRiftsBuff",
               RifterAssets.shatterIcon,
               Color.white,
               false,
               false);
            negateDebuff.isHidden = false;

        }
    }
}
