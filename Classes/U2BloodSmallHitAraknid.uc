//=============================================================================
// BloodSmallHit.
//=============================================================================
class U2BloodSmallHitAraknid extends BloodSpurt;



simulated function PostNetBeginPlay()
{
	if ( (Role < ROLE_Authority) && class'GameInfo'.Static.UseLowGore() )
	{
		splats[0] = Material'xbiosplat'; 
		splats[1] = Material'xbiosplat';
		splats[2] = Material'xbiosplat';
		BloodDecalClass = class'BioDecal';
		Skins[0] = Material'BloodPuffGreen';
	}
	Super.PostNetBeginPlay();
}

defaultproperties
{
     BloodDecalClass=Class'tk_U2Creatures.u2bloodsplatteryellow'
     Splats(0)=Texture'tk_U2Creatures.Blood.BloodSplat1Y'
     Splats(1)=Texture'tk_U2Creatures.Blood.BloodSplat2Y'
     Splats(2)=Texture'tk_U2Creatures.Blood.BloodSplat3Y'
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.900000
     mDirDev=(X=0.700000,Y=0.700000,Z=0.700000)
     mPosDev=(X=5.000000,Y=5.000000,Z=5.000000)
     mSpeedRange(0)=20.000000
     mSpeedRange(1)=70.000000
     mMassRange(0)=0.100000
     mMassRange(1)=0.200000
     mSizeRange(0)=10.000000
     mSizeRange(1)=15.000000
     mNumTileColumns=1
     mNumTileRows=1
     Skins(0)=Texture'tk_U2Creatures.Fire_Goo.firegoo1_tw128'
}
