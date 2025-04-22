using RifterMod.Modules;
using RifterMod.Survivors.NemRifter.Achievements;
using RoR2;
using UnityEngine;

namespace RifterMod.Survivors.NemRifter
{
    public static class NemRifterUnlockables
    {
        public static UnlockableDef characterUnlockableDef = null;
        public static UnlockableDef masterySkinUnlockableDef = null;
        //public static UnlockableDef scattershotUnlockableDef = null;

        public static void Init()
        {
            //masterySkinUnlockableDef = Modules.Content.CreateAndAddUnlockbleDef(
            //    NemRifterMasteryAchievement.unlockableIdentifier,
            //    Modules.Tokens.GetAchievementNameToken(NemRifterMasteryAchievement.identifier),
            //    NemRifterSurvivor.instance.assetBundle.LoadAsset<Sprite>("texMasteryAchievement"));
        }
    }
}
