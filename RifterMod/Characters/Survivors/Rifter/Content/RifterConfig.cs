using BepInEx.Configuration;
using RifterMod.Modules;

namespace RifterMod.Survivors.Rifter
{
    public static class RifterConfig
    {
        public static ConfigEntry<bool> teleportYourFriends;

        public static ConfigEntry<bool> cursed;

        //public static ConfigEntry<float> distanceMultiplier;


        public static void Init()
        {
            string section = "Rifter";

            teleportYourFriends = Config.BindAndOptions(section, "Teleport Your Friends", defaultValue: false, "Teleport your firends!");

            cursed = Config.BindAndOptions(section, "Cursed", defaultValue: false, "Adds sillies, such as blind pests losing the ability to fly once teleported. [Restart Required]");

            //distanceMultiplier = Config.BindAndOptionsSlider(section, "Distance Multiplier", defaultValue: 1.0f, "Adjust the perfect distance for Rifter's primary and primary-secondary ability, 1.0 being default distance (about 50m and 25m).", .1f, 1f, true);
        }
    }
}

