class SingularityCannonFire extends ProjectileFire;


var xEmitter ChargingEmitter;           // emitter class while charging
var Sound ChargingSound;                // charging sound
var bool bAutoRelease;
var float FullyChargedTime;
var bool bStartedChargingForce;

simulated function InitEffects()
{
    if ( Level.NetMode != NM_DedicatedServer )
    {
        ChargingEmitter = Weapon.Spawn(class'XEffects.ShieldCharge');
        ChargingEmitter.mRegenPause = true;
    }
    bStartedChargingForce = false;  // jdf
    Super.InitEffects();
}

simulated function DestroyEffects()
{
    if (ChargingEmitter != None)
        ChargingEmitter.Destroy();
    Super.DestroyEffects();
}


function DrawMuzzleFlash(Canvas Canvas)
{
    if (ChargingEmitter != None && HoldTime > 0.0 && !bNowWaiting)
    {
        ChargingEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( ChargingEmitter, false, false, Weapon.DisplayFOV );
    }

    if (FlashEmitter != None)
    {
        FlashEmitter.SetLocation( Weapon.GetEffectStart() );
        if ( Weapon.WeaponCentered() )
            FlashEmitter.SetRotation(Weapon.Instigator.GetViewRotation());
        else
            FlashEmitter.SetRotation(Weapon.Rotation);
        Canvas.DrawActor( FlashEmitter, false, false, Weapon.DisplayFOV );
    }

    if ( (Instigator.AmbientSound == ChargingSound) && ((HoldTime <= 0.0) || bNowWaiting) )
    {
        Instigator.AmbientSound = None;
        Instigator.SoundVolume = Instigator.Default.SoundVolume;
    }

}

function PlayPreFire()
{
    //Weapon.PlayAnim('SC_FPPreFire', 1.0/FullyChargedTime, 0.1);
    GotoState('Charging');
}


function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Super.SpawnProjectile(Start,Dir);

    return p;
}

simulated state Charging
{
//ignores Fire, AltFire;

Begin:

    //PlayAnim('SC_FPPreFire');
    Weapon.PlayAnim('SC_FPPreFire', 1.0/FullyChargedTime, 0.1);
    Weapon.PlaySound(ChargingSound);
    Weapon.Sleep(0.3);

    //ParticleUnTrigger("ChargeUp");

    Weapon.Sleep(0.3);
    ModeDoFire();


    /*if (Role == ROLE_Authority)
        Super.AuthorityFire();
    Super.EverywhereFire();*/
}

    //DamageType=Class'tk_U2Creatures.U2DamTypeSingularityCannon'

defaultproperties
{
     ChargingSound=Sound'tk_U2Creatures.WeaponsA_SingularityCannon.SC_PreFire'
     ProjSpawnOffset=(X=100.000000,Z=0.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     TransientSoundVolume=1.000000
     PreFireAnim="SC_FPPreFire"
     FireAnim="SC_FPFire"
     FireSound=Sound'tk_U2Creatures.WeaponsA_SingularityCannon.SC_Fire'
     FireForce="redeemer_shoot"
     FireRate=4.366000
     AmmoClass=Class'tk_U2Creatures.ToscAmmo'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'tk_U2Creatures.U2SC_Projectile'
     BotRefireRate=0.990000
}
