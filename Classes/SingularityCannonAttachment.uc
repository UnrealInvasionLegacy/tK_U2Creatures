class SingularityCannonAttachment extends xWeaponAttachment;

var byte OldSpawnHitCount;
var class<xEmitter>     mMuzFlashClass;
var xEmitter            mMuzFlash3rd;
var xEmitter            mMuzFlash3rdAlt;
var float AimAlpha;



simulated function Hide(bool NewbHidden)
{
	bHidden = NewbHidden;

}

simulated function Destroyed()
{

    if (mMuzFlash3rd != None)
        mMuzFlash3rd.Destroy();
    if (mMuzFlash3rdAlt != None)
        mMuzFlash3rdAlt.Destroy();
    Super.Destroyed();
}

simulated function SetOverlayMaterial( Material mat, float time, bool bOverride )
{
	Super.SetOverlayMaterial(mat, time, bOverride);

}

/*simulated function Tick(float deltatime)
{
	local rotator newRot;

	if ( (Level.NetMode == NM_DedicatedServer) )
	{
		Disable('Tick');
		return;
	}
	
	AimAlpha = AimAlpha * ( 1 - 2*DeltaTime);
		
	// point in firing direction
	if ( Instigator != None )
	{
		newRot = Instigator.Rotation;
		if ( AimAlpha < 0.5 )
			newRot.Yaw += 4500 * (1 - 2*AimAlpha);
		Instigator.SetBoneDirection('lfarm', newRot,, 1.0, 1);
	    
		newRot.Roll += 32768;
		Instigator.SetBoneDirection(AttachmentBone, newRot,, 1.0, 1);
	}
}*/

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
	SpawnHitCount++;
	mHitLocation = HitLocation;
	mHitActor = HitActor;
	mHitNormal = HitNormal;
}

simulated function MakeMuzzleFlash()
{
    local rotator r;


	AimAlpha = 1;

    if (mMuzFlash3rd == None)
    {
        mMuzFlash3rd = Spawn(mMuzFlashClass);
        AttachToBone(mMuzFlash3rd, 'GunEnd');
    }
    mMuzFlash3rd.mStartParticles++;
    r.Roll = Rand(65536);
    SetBoneRotation('GunEnd', r, 0, 1.f);
}

simulated event ThirdPersonEffects()
{
	local rotator r;
	local PlayerController PC;
	


    if ( Level.NetMode != NM_DedicatedServer )
	{
		AimAlpha = 1;

        if (FiringMode == 0)
        {
			WeaponLight();
			if ( OldSpawnHitCount != SpawnHitCount )
			{
				OldSpawnHitCount = SpawnHitCount;
				GetHitInfo();
				PC = Level.GetLocalPlayerController();
				if ( ((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000) )
				{
					Spawn(class'HitEffect'.static.GetHitEffect(mHitActor, mHitLocation, mHitNormal),,, mHitLocation, Rotator(mHitNormal));
					CheckForSplash();
				}
			}
			MakeMuzzleFlash();

        }
        else if (FiringMode == 1 && FlashCount > 0)
        {
			WeaponLight();
            if (mMuzFlash3rdAlt == None)
            {
                mMuzFlash3rdAlt = Spawn(mMuzFlashClass);
                AttachToBone(mMuzFlash3rdAlt, 'GunEnd');
            }
            mMuzFlash3rdAlt.mStartParticles++;
            r.Roll = Rand(65536);
            SetBoneRotation('gunEnd', r, 0, 1.f);
        }
    }

    Super.ThirdPersonEffects();
}

//     RelativeRotation=(Pitch=32768)
//     RelativeLocation=(X=-20.000000,Y=-5.000000)
//     RelativeRotation=(Pitch=-5000,Roll=-16384,Yaw=-16384)

defaultproperties
{
     mMuzFlashClass=Class'XEffects.ForceRing'
     bHeavy=True
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'tk_U2Creatures.SC_TP'
     RelativeRotation=(Pitch=32768)
     DrawScale=0.500000
}
