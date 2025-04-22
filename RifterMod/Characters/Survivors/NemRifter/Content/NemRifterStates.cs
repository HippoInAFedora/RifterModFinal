using RifterMod.Characters.Survivors.NemRifter.SkillStates;
using RifterMod.Characters.Survivors.NemRifter.SkillStates.Old;
using RifterMod.Characters.Survivors.NemRifter.SkillStates.RiftZone;
using RifterMod.Survivors.NemRifter.SkillStates;

namespace RifterMod.Survivors.NemRifter
{
    public static class NemRifterStates
    {
        public static void Init()
        {
            Modules.Content.AddEntityState(typeof(NemRifterMain));
            Modules.Content.AddEntityState(typeof(RiftSword));
            Modules.Content.AddEntityState(typeof(ChargeGatling));
            Modules.Content.AddEntityState(typeof(NemFracture));
            Modules.Content.AddEntityState(typeof(Corridor));
            Modules.Content.AddEntityState(typeof(RiftZoneLocate));
            Modules.Content.AddEntityState(typeof(NemTeleport));
            Modules.Content.AddEntityState(typeof(RiftCollapse));
            Modules.Content.AddEntityState(typeof(RiftZoneCylinder));
            Modules.Content.AddEntityState(typeof(RiftZoneCube));
            Modules.Content.AddEntityState(typeof(CollapseDamageCube));
            Modules.Content.AddEntityState(typeof(CollapseDamageCylinder));
        }
    }
}
