class DrakkLightningBolt extends NewLightningBolt;

/*simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    MakeNoise(0.5);
	PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact', SLOT_Misc,,,,,false);
}

simulated function PostNetBeginPlay()
{
	local xWeaponAttachment Attachment;
	local vector X,Y,Z;
	
    if ( (xPawn(Instigator) != None) && !Instigator.IsFirstPerson() )
    {
        Attachment = xPawn(Instigator).WeaponAttachment;
        if ( (Attachment != None) && (Level.TimeSeconds - Attachment.LastRenderTime < 0.1) )
        {
			GetAxes(Attachment.Rotation,X,Y,Z);
            SetLocation(Attachment.Location -40*X -10*Z);
        }
    }
}*/

defaultproperties
{
     Skins(0)=Texture'tk_U2Creatures.Drakk.LightningBoltRedT'
}
