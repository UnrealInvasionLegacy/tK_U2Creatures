//=============================================================================
// LightningBolt.
//=============================================================================
class RedLightningBolt extends NewLightningBolt;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    MakeNoise(0.5);
	PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact', SLOT_Misc,,,,,false);
	if( Level.NetMode != NM_DedicatedServer )
        Spawn(class'BlueSparks',,,Location,Rotation);
}

defaultproperties
{
     Skins(0)=Texture'tk_U2Creatures.Drakk.LightningBoltRedT'
}
