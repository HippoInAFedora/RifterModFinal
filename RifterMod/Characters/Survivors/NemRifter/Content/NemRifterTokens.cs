using System;
using RifterMod.Modules;
using RifterMod.Survivors.NemRifter.Achievements;
using RifterMod.Survivors.NemRifter.SkillStates;

namespace RifterMod.Survivors.NemRifter
{
    public static class NemRifterTokens
    {
        public static void Init()
        {
            AddNemRifterTokens();

            ////uncomment this to spit out a lanuage file with all the above tokens that people can translate
            ////make sure you set Language.usingLanguageFolder and printingEnabled to true
            Language.PrintOutput("NemRifter.txt");
            ////refer to guide on how to build and distribute your mod with the proper folders
        }

        public static void AddNemRifterTokens()
        {
            string prefix = NemRifterSurvivor.NEM_RIFTER_PREFIX;

            string desc = "The Nemesis Rifter creates interdimensional pockets to amplify her damage.<color=#CCD3E0>" + Environment.NewLine + Environment.NewLine
             + "<!> Rifts are significantly stronger than fracture lines - positioning is key!" + Environment.NewLine + Environment.NewLine
             + "<!> Utilizing your primary's long-range and mid-range capabilities allow you to mix up your positions." + Environment.NewLine + Environment.NewLine
             + "<!> Certain skills can teleport enemies, while some are conditional. Using this power can keep enemies at bay." + Environment.NewLine + Environment.NewLine
             + "<!> Timelock can be a powerful tool for gathering enemies and blasting them all at once!" + Environment.NewLine + Environment.NewLine;

            string outro = "..and so she left a fractured world behind.";
            string outroFailure = "..and so she vanished from all realms.";

            string lore = "\"...Funny...\"\r\n\r\n\"Yeah. Real funny.\"\r\n\r\n\"It just... appeared?\"\r\n\r\n\"Well that's what they're sticking to, at least.\"\r\n\r\n\"Huh. Never imagined <i>we'd</i> be the ones they'd keep secrets from.\"\r\n\r\n\"I guess they can't have their Science Division knowing everything that comes their way.\"\r\n\r\nHannegan peered through the strange, glassy substance. He wanted to describe it as glass, but his need for concrete evidence got the better of him. He also wanted to tap it.\r\n\r\nHe tapped it.\r\n\r\nIt resonated in a very peculiar frequency, almost... like it was clipping in and out of time? He kept the thought in mind, but hesitated to draw conclusions from it.\r\n\r\n\"Hannegan, you know how much I hate it when you touch samples without permission.\"\r\n\r\n\"Permission to touch it?\"\r\n\r\n\"...Yes... It's not reactive to touch.\"\r\n\r\n\"Did they specify the material of this... glassy stuff?\"\r\n\r\n\"No. And it's not our point of interest.\"\r\n\r\nThe lead scientist, D.O. Harold Schmeuller, gestured toward the glassy substance, but not the substance itself. He pointed at what was <i>inside</i>.\r\n\r\n\"They say they've got readings of a crude, yet incomprehensibly advanced object which has the ability to teleport objects.\"\r\n\r\n\"You make that sound special. We've already worked out a way to teleport things. What's the difference?\"\r\n\r\n\"The intel I have been given suggests it appeared -- not just through space -- but through <i>time</i>.\"\r\n\r\n\"Time? That's impossi-\"\r\n\r\n\"Impossible, yes. Unless it isn't. Our task here is to find out how this thing teleports through time and space, and to replicate it. Project NemRifter, is what they're calling it. Also, remember, Hannegan, we test weapons, <i>not</i> convenience items.";

            Language.Add(prefix + "NAME", "NemesisRifter");
            Language.Add(prefix + "DESCRIPTION", desc);
            Language.Add(prefix + "SUBTITLE", "The Fractured One");
            Language.Add(prefix + "LORE", lore);
            Language.Add(prefix + "OUTRO_FLAVOR", outro);
            Language.Add(prefix + "OUTRO_FAILURE", outroFailure);

            #region Skins
            Language.Add(prefix + "MASTERY_SKIN_NAME", "Survivalist");
            #endregion

            #region Passive

            #endregion

            #region Primary
            Language.Add(prefix + "PRIMARY_NEM_FRACTURE", "Reality Fracture");
            Language.Add(prefix + "PRIMARY_NEM_FRACTURE_DESCRIPTION", $"<style=cIsUtility>Fracture</style>. Shoot a far-ranged rift for <style=cIsDamage>% damage</style>, dealing up to 5 shatter. If secondary skill is held, shoot a mid-range rift for <style=cIsDamage>%</style>.");
            #endregion

            #region Secondary
            Language.Add(prefix + "SECONDARY_FRACTURE", "Fracture Shot");
            Language.Add(prefix + "SECONDARY_FRACTURE_DESCRIPTION", $"Shoot <style=cIsDamage>3 x % damage</style> piercing fracture shots.");
            #endregion

            #region Utility
            Language.Add(prefix + "UTILITY_SLIPSTREAM", "Slipstream");
            Language.Add(prefix + "UTILITY_PRESTIGE_SLIPSTREAM", "Prestige Slipstream");
            Language.Add(prefix + "UTILITY_SLIPSTREAM_DESCRIPTION", "<style=cIsUtility>Teleport</style> a short distance. Replenishes secondary skill stock.");
            #endregion

            #region Special
            Language.Add(prefix + "SPECIAL_TIMELOCK", "Timelock");
            Language.Add(prefix + "SPECIAL_TIMELOCK_DESCRIPTION", $"<style=cIsHealth>Crushing</style>. Create a field that deals 10 shatter and causes rifts to teleport to itself. <style=cIsUtility>Hitting it with a rift</style> collapses the timelock for <style=cIsDamage>500% damage</style>.");     
            #endregion

            #region Achievements
            //Language.Add(Tokens.GetAchievementNameToken(NemRifterMasteryAchievement.identifier), "NemRifter: Mastery");
            //Language.Add(Tokens.GetAchievementDescriptionToken(NemRifterMasteryAchievement.identifier), "As rifter, beat the game or obliterate on monsoon.");
            #endregion
        }
    }
}
