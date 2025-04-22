
using RoR2;
using RoR2.Skills;
using UnityEngine;
using JetBrains.Annotations;
using RifterMod.Characters.Survivors.Rifter.Components;
using R2API.Utils;
using RifterMod.Characters.Survivors.NemRifter.Components.Old;
using RifterMod.Survivors.NemRifter.Components;

namespace RifterMod.Modules
{
    public class NemRifterSkillDef : SkillDef
    {
        protected class InstanceData : BaseSkillInstanceData
        {
            public NemRifterTracker nemRifterTracker;
        }

        public override BaseSkillInstanceData OnAssigned([NotNull] GenericSkill skillSlot)
        {
            return new InstanceData
            {
                nemRifterTracker = skillSlot.GetComponent<NemRifterTracker>()
            };
        }

        private static bool HasTarget([NotNull] GenericSkill skillSlot)
        {
            if (!(((InstanceData)skillSlot.skillInstanceData).nemRifterTracker?.GetTrackingTarget()))
            {
                return false;
            }
            return true;
        }

        public override bool CanExecute([NotNull] GenericSkill skillSlot)
        {
            if (!HasTarget(skillSlot))
            {
                return false;
            }
            return base.CanExecute(skillSlot);
        }

        public override bool IsReady([NotNull] GenericSkill skillSlot)
        {
            if (base.IsReady(skillSlot))
            {
                return HasTarget(skillSlot);
            }
            return false;
        }
    }
}