//=============================================================================
// SingularityCannon.
//=============================================================================
class SingularityCannon extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx
//,Pitch=16384
//     PlayerViewPivot=(Yaw=-16384)
//     PlayerViewOffset=(X=-5.000000,Y=-3.000000)
//     PlayerViewPivot=(Yaw=500)

defaultproperties
{
     FireModeClass(0)=Class'tk_U2Creatures.SingularityCannonFire'
     FireModeClass(1)=Class'tk_U2Creatures.SingularityCannonAltFire'
     IdleAnim="SC_FPAmbientBase"
     RestAnim="SC_FPAmbientBase"
     AimAnim="SC_FPAmbientBase"
     RunAnim="SC_FPAmbientBase"
     SelectAnim="SC_FPSelect"
     PutDownAnim="SC_FPDown"
     IdleAnimRate=0.500000
     RestAnimRate=0.500000
     AimAnimRate=0.500000
     RunAnimRate=0.500000
     SelectAnimRate=0.800000
     PutDownAnimRate=0.800000
     PutDownTime=1.400000
     BringUpTime=0.800000
     SelectSound=Sound'tk_U2Creatures.WeaponsA_SingularityCannon.SC_Select'
     SelectForce="SwitchToMiniGun"
     AIRating=1.000000
     CurrentRating=1.000000
     bNoInstagibReplace=True
     bNoAmmoInstances=False
     Description="Singularity Cannon"
     EffectOffset=(X=100.000000,Y=25.000000,Z=-3.000000)
     DisplayFOV=60.000000
     Priority=13
     HudColor=(R=0)
     SmallViewOffset=(X=-2.000000,Z=-13.000000)
     CenteredOffsetY=-6.000000
     CenteredRoll=0
     CenteredYaw=-500
     CustomCrosshair=11
     CustomCrossHairScale=0.666700
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=0
     PickupClass=Class'tk_U2Creatures.SingularityCannonPickup'
     PlayerViewOffset=(X=4.000000,Y=5.500000,Z=-6.000000)
     PlayerViewPivot=(Yaw=-16384)
     BobDamping=2.250000
     AttachmentClass=Class'tk_U2Creatures.SingularityCannonAttachment'
     IconMaterial=Texture'tk_U2Creatures.Icons.SmallIconSC'
     IconCoords=(X2=128,Y2=32)
     ItemName="Singularity Cannon"
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     Mesh=SkeletalMesh'tk_U2Creatures.SC_FP'
     SoundRadius=400.000000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
