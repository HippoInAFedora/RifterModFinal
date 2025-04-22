using RoR2;
using EntityStates;
using UnityEngine;
using RifterMod.Survivors.Rifter;
using static UnityEngine.SendMouseEvents;
using System.Collections.Generic;
using Newtonsoft.Json.Utilities;
using R2API;
using UnityEngine.Networking;
using HG;

namespace RifterMod.Survivors.NemRifter.SkillStates
{
    public class NemRifterMain : GenericCharacterMain
    {
        public bool jumpButtonState;

        private bool heldPress;

        private bool jumpToggledState;

        private float oldJumpHeldTime;

        private float jumpButtonHeldTime;

        private bool isFlying;

        public override void FixedUpdate()
        {
            base.FixedUpdate();
            if (NetworkServer.active)
            {
                if (base.characterBody.HasBuff(NemRifterBuffs.negateDebuff))
                {
                    //ICharacterGravityParameterProvider component = base.characterBody.GetComponent<ICharacterGravityParameterProvider>();
                    //if (component != null)
                    //{
                    //    CharacterGravityParameters gravityParameters = component.gravityParameters;
                    //    gravityParameters.environmentalAntiGravityGranterCount++;
                    //    component.gravityParameters = gravityParameters;
                    //}
                    //ICharacterFlightParameterProvider component2 = base.characterBody.GetComponent<ICharacterFlightParameterProvider>();
                    //if (component2 != null)
                    //{
                    //    CharacterFlightParameters flightParameters = component2.flightParameters;
                    //    flightParameters.channeledFlightGranterCount++;
                    //    component2.flightParameters = flightParameters;
                    //}

                    if (base.characterBody.HasBuff(NemRifterBuffs.outsideRiftDebuff))
                    {
                        base.characterBody.RemoveBuff(NemRifterBuffs.outsideRiftDebuff);
                    }
                }
                else
                {
                    //if (base.characterMotor)
                    //{
                    //    ICharacterGravityParameterProvider component = base.characterBody.GetComponent<ICharacterGravityParameterProvider>();
                    //    if (component != null)
                    //    {
                    //        CharacterGravityParameters gravityParameters = component.gravityParameters;
                    //        gravityParameters.environmentalAntiGravityGranterCount--;
                    //        component.gravityParameters = gravityParameters;
                    //    }
                    //    ICharacterFlightParameterProvider component2 = base.characterBody.GetComponent<ICharacterFlightParameterProvider>();
                    //    if (component2 != null)
                    //    {
                    //        CharacterFlightParameters flightParameters = component2.flightParameters;
                    //        flightParameters.channeledFlightGranterCount--;
                    //        component2.flightParameters = flightParameters;
                    //    }
                    //}
                    if (!base.characterBody.HasBuff(NemRifterBuffs.outsideRiftDebuff))
                    {
                        base.characterBody.AddBuff(NemRifterBuffs.outsideRiftDebuff);
                    }                    
                }
            }
            

        }

        public override void ProcessJump()
        {
            if (base.characterBody.HasBuff(NemRifterBuffs.negateDebuff))
            {
                if (hasCharacterMotor && hasInputBank && base.isAuthority)
                {
                    if (NetworkUser.readOnlyLocalPlayersList[0]?.localUser?.userProfile.toggleArtificerHover ?? true)
                    {
                        if (base.inputBank.jump.down)
                        {
                            oldJumpHeldTime = jumpButtonHeldTime;
                            jumpButtonHeldTime += Time.deltaTime;
                            heldPress = oldJumpHeldTime < 0.5f && jumpButtonHeldTime >= 0.5f;
                        }
                        else
                        {
                            oldJumpHeldTime = 0f;
                            jumpButtonHeldTime = 0f;
                            heldPress = false;
                        }
                        if (!base.characterMotor.isGrounded)
                        {
                            if (base.characterMotor.jumpCount == base.characterBody.maxJumpCount)
                            {
                                if (base.inputBank.jump.justPressed)
                                {
                                    jumpButtonState = !jumpButtonState;
                                }
                            }
                            else if (heldPress)
                            {
                                jumpButtonState = !jumpButtonState;
                            }
                        }
                        else
                        {
                            jumpButtonState = false;
                        }
                    }
                    else
                    {
                        jumpButtonState = base.inputBank.jump.down;
                    }
                    bool num = jumpButtonState && base.characterMotor.velocity.y < 0f && !base.characterMotor.isGrounded;
                    bool flag = isFlying;
                    if (num && !flag)
                    {
                        ICharacterGravityParameterProvider component = base.gameObject.GetComponent<ICharacterGravityParameterProvider>();
                        if (component != null)
                        {
                            CharacterGravityParameters gravityParameters = component.gravityParameters;
                            gravityParameters.environmentalAntiGravityGranterCount++;
                            component.gravityParameters = gravityParameters;
                        }
                        ICharacterFlightParameterProvider component2 = base.gameObject.GetComponent<ICharacterFlightParameterProvider>();
                        if (component2 != null)
                        {
                            CharacterFlightParameters flightParameters = component2.flightParameters;
                            flightParameters.channeledFlightGranterCount++;
                            component2.flightParameters = flightParameters;
                        }
                        isFlying = true;
                    }
                    if (!num && flag)
                    {
                        ICharacterFlightParameterProvider component = base.gameObject.GetComponent<ICharacterFlightParameterProvider>();
                        if (component != null)
                        {
                            CharacterFlightParameters flightParameters = component.flightParameters;
                            flightParameters.channeledFlightGranterCount--;
                            component.flightParameters = flightParameters;
                        }
                        ICharacterGravityParameterProvider component2 = base.gameObject.GetComponent<ICharacterGravityParameterProvider>();
                        if (component2 != null)
                        {
                            CharacterGravityParameters gravityParameters = component2.gravityParameters;
                            gravityParameters.environmentalAntiGravityGranterCount--;
                            component2.gravityParameters = gravityParameters;
                        }
                        isFlying = false;
                    }
                }
            }
            base.ProcessJump();
        }
    }
}


