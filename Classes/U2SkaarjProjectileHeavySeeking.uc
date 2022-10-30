//=============================================================================
// U2SkaarjProjectile.
//=============================================================================
class U2SkaarjProjectileHeavySeeking extends Projectile;

var Actor Seeking;
var vector InitialDir;
var vector Dir;
var FX_U2CSkaarjBoltHeavySeeking SkaarjBoltEffect;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
    {
        SkaarjBoltEffect = Spawn(class'FX_U2CSkaarjBoltHeavySeeking', self);
        SkaarjBoltEffect.SetBase(self);
    }
    Dir = vector(Rotation);
    Velocity = Speed * Vector(Rotation);

   // SetTimer(0.4, false);
       SetTimer(0.1, true);
   // tempStartLoc = Location;
}


replication
{
    reliable if( bNetInitial && (Role==ROLE_Authority) )
        Seeking, InitialDir;
}

simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if ( InitialDir == vect(0,0,0) )
        InitialDir = Normal(Velocity);

    Acceleration = vect(0,0,0);
    Super.Timer();
    if ( (Seeking != None) && (Seeking != Instigator) )
    {
        // Do normal guidance to target.
        ForceDir = Normal(Seeking.Location - Location);

        if( (ForceDir Dot InitialDir) > 0 )
        {
            VelMag = VSize(Velocity);

            // track vehicles better
            if ( Seeking.Physics == PHYS_Karma )
                ForceDir = Normal(ForceDir * 0.8 * VelMag + Velocity);
            else
                ForceDir = Normal(ForceDir * 0.5 * VelMag + Velocity);
            Velocity =  VelMag * ForceDir;
            Acceleration += 5 * ForceDir;
        }
        // Update rocket so it faces in the direction its going.
        SetRotation(rotator(Velocity));
    }
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
        if ( U2SkaarjProjectileHeavySeeking(Other) != None )
            U2SkaarjProjectileHeavySeeking(Other).Explode(HitLocation,Normal(Other.Location - HitLocation));
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
        Spawn(class'FX_U2CSkaarjBoltExplosionHeavy',,, Location);//shockexplosioncore
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
            Spawn(class'FX_U2CSkaarjBoltExplosionHeavy',,, Location);
    }
    SetCollisionSize(0.0, 0.0);
    Destroy();
}

defaultproperties
{
     Speed=2500.000000
     MaxSpeed=2500.000000
     bSwitchToZeroCollision=True
     Damage=250.000000
     DamageRadius=256.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'XWeapons.DamTypeShockBall'
     ImpactSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_HeavyExplode'
     ExplosionDecal=Class'XEffects.ShockImpactScorch'
     MaxEffectDistance=7000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=5.000000
     DrawType=DT_Particle
     CullDistance=4000.000000
     bDynamicLight=True
     bNetTemporary=False
     bOnlyDirtyReplication=True
     AmbientSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_HeavyAmbient'
     LifeSpan=15.000000
     Texture=None
     DrawScale=10.000000
     Style=STY_Translucent
     FluidSurfaceShootStrengthMod=8.000000
     SoundVolume=50
     SoundRadius=60.000000
     TransientSoundRadius=200.000000
     CollisionRadius=20.000000
     CollisionHeight=20.000000
     bProjTarget=True
     bAlwaysFaceCamera=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
