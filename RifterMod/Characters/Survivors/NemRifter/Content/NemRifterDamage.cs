using R2API;

public static class NemRifterDamage
{
    internal static DamageAPI.ModdedDamageType instabilityTriggerDamage;

    internal static DamageAPI.ModdedDamageType instabilityProcDamage;

    internal static void SetupModdedDamage()
    {
        instabilityTriggerDamage = DamageAPI.ReserveDamageType();
        instabilityProcDamage = DamageAPI.ReserveDamageType();
    }
}