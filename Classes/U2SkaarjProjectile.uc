//=============================================================================
// U2SkaarjProjectile.
//=============================================================================
class U2SkaarjProjectile extends Projectile;


var FX_U2CSkaarjBolt SkaarjBoltEffect;
//viewshake
var() float ShakeRadius, ShakeMagnitude, ShakeDuration;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
    {
           SkaarjBoltEffect = Spawn(class'FX_U2CSkaarjBolt', self);
           SkaarjBoltEffect.SetBase(self);
    }

    Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

    SetTimer(0.4, false);
   // tempStartLoc = Location;
}

simulated function Destroyed()
{
    if (SkaarjBoltEffect != None)
    {
        if ( bNoFX )
            SkaarjBoltEffect.Destroy();
        else
            SkaarjBoltEffect.Kill();
    }

    Super.Destroyed();
}

simulated function DestroyTrails()
{
    if (SkaarjBoltEffect != None)
        SkaarjBoltEffect.Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local Vector X, RefNormal, RefDir;

    if (Other == Instigator) return;
        if (Other == Owner) return;
    if (Other.IsA('U2SkaarjProjectile')) return;


    if (Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage*0.25))
    {
        if (Role == ROLE_Authority)
        {
            X = Normal(Velocity);
            RefDir = X - 2.0*RefNormal*(X dot RefNormal);
            RefDir = RefNormal;
            Spawn(Class, Other,, HitLocation+RefDir*20, Rotator(RefDir));
        }
        DestroyTrails();
        Destroy();
    }
    else if ( !Other.IsA('Projectile') || Other.bProjTarget )
    {
        Explode(HitLocation, Normal(HitLocation-Other.Location));
        if ( U2SkaarjProjectile(Other) != None )
            U2SkaarjProjectile(Other).Explode(HitLocation,Normal(Other.Location - HitLocation));
            DestroyTrails();
        Destroy();
    }
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    if ( Role == ROLE_Authority )
    {
        HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    }

    PlaySound(ImpactSound, SLOT_Misc);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'FX_U2CSkaarjBoltExplosion',,, Location);//shockexplosioncore
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
            Spawn(class'FX_U2CSkaarjBoltExplosion',,, Location);
    }
    class'UtilGame'.static.MakeShake( Self, HitLocation, ShakeRadius, ShakeMagnitude, ShakeDuration );
    SetCollisionSize(0.0, 0.0);
    DestroyTrails();
    Destroy();
}

defaultproperties
{
     ShakeRadius=256.000000
     ShakeMagnitude=15.000000
     ShakeDuration=0.600000
     Speed=800.000000
     MaxSpeed=1200.000000
     bSwitchToZeroCollision=True
     Damage=20.000000
     DamageRadius=20.000000
     MomentumTransfer=70000.000000
     MyDamageType=Class'XWeapons.DamTypeShockBall'
     ImpactSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_LightExplode'
     ExplosionDecal=Class'XEffects.ShockImpactScorch'
     MaxEffectDistance=7000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=255
     LightSaturation=255
     LightBrightness=100.000000
     LightRadius=4.000000
     DrawType=DT_Particle
     CullDistance=4000.000000
     bDynamicLight=True
     bNetTemporary=False
     bOnlyDirtyReplication=True
     AmbientSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_LightAmbient'
     LifeSpan=10.000000
     Texture=None
     DrawScale=0.700000
     Style=STY_Translucent
     FluidSurfaceShootStrengthMod=8.000000
     SoundVolume=255
     SoundRadius=100.000000
     TransientSoundRadius=200.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bProjTarget=True
     bAlwaysFaceCamera=True
     ForceType=FT_Constant
     ForceRadius=40.000000
     ForceScale=5.000000
}
