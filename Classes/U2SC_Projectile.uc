class U2SC_Projectile extends Projectile;

//original SC_Projectile ported from Unreal 2 by the Fraghouse team

#exec OBJ LOAD FILE=IndoorAmbience.uax

var()	float	FieldRadius;
var()	float	PainRadius;
var()	float	DistortionRadius;
var()	float	GravityRadius;
var()	float	KillRadius;
var()	float	GravityStrength;
var()	float	DamagePerSecond;

//var  Emitter	Trail;

var  rotator	EffectRotation;
var  Emitter	U2EffectA,U2EffectB;

var bool bExploded;

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	EffectRotation.Pitch = RandRange(20000,40000);

   	U2EffectA = Spawn(class'U2EffectA', self, , Location);

   	if ( U2EffectA != None )
   	{
      		U2EffectA.SetBase(Self);
   	}

   	U2EffectB = Spawn(class'U2EffectB', self, , Location);

   	if ( U2EffectB != None )
   	{
      		U2EffectB.SetBase(Self);
   	} 
}


simulated function Destroyed()
{
	if (U2EffectA != None)
	{
		U2EffectA.Kill();
	}

	if (U2EffectB != None)
	{
		U2EffectB.Kill();
	}
/*
	if (Trail != None)
	{
		Trail.Kill();
	}
*/
		Super.Destroyed();
}


simulated function PostBeginPlay()
{
//    local vector Dir;
    local Rotator R;

//    Dir = vector(Rotation);

    Super.PostBeginPlay();
/*
	if ( Level.NetMode != NM_DedicatedServer)
	{
		Trail = Spawn(class'SC_Trail',,,Location - 15 * Dir);
		Trail.Setbase(self);
	}
*/
	Velocity = Vector(Rotation);
    Acceleration = Velocity * 3000.0;
    Velocity *= Speed;

    R = Rotation;
    R.Roll = Rand(65536);
    SetRotation(R);
    
    if ( Instigator != None )
		InstigatorController = Instigator.Controller;
}


simulated function bool Immune( Pawn P )
{
	if( P == Instigator )
		return true;
}


event Tick( float DeltaTime )
{
	local Pawn P;
	local Projectile A;
	local Vector Delta, AttractionForce;
	local float Distance;
//	local int GravityChannel;
	local int ApplyDamage;

	// Update particle attachments.
	EffectRotation = EffectRotation + (rot(-1800,48000,3150) * DeltaTime);
	if (U2EffectA != None)
		U2EffectA.SetLocation( Location - (vect(0,32,0) >> EffectRotation) );
	if (U2EffectB != None)
	{
	U2EffectB.SetLocation( Location + (vect(0,32,0) >> EffectRotation) );
	U2EffectB.SetRotation( rotator(Location - U2EffectB.Location) );
	}

	foreach VisibleActors( class'Pawn', P, FieldRadius, Location )
	foreach VisibleActors( class'Projectile', A, FieldRadius, Location )
	{
		if( P != Self && !Immune( P ) )
		{
		if( P != Self )
		{

			// suck everything toward Location
			Delta = Location - P.Location;
			Distance = FMax( VSize( Delta ), 1.0 );

					if (true)
					{
						if( Distance < GravityRadius )
						{
							AttractionForce = GravityStrength * DeltaTime * Normal( Delta ) / Distance;
							if (!P.IsPlayerPawn())
								AttractionForce *= 2.0;
							P.Velocity += AttractionForce;
							P.SetPhysics( PHYS_Falling );
						}
					}

					if (Distance < KillRadius)
					{
						// instakill
						ApplyDamage = 9999;
					}
					else
					{
						ApplyDamage = (DamagePerSecond * DeltaTime) / (Distance / PainRadius);
					}
					
					P.TakeDamage( ApplyDamage, Instigator, P.Location, Vect(0,0,0), MyDamageType );
				
		}
				if (P.Health <= 0)
				{
					P.bHidden = true;
				}
		}
	}
}
/*
     FieldRadius=576.000000
     PainRadius=192.000000
     DistortionRadius=576.000000
     GravityRadius=576.000000
     KillRadius=64.000000
*/

defaultproperties
{
     FieldRadius=280.000000
     PainRadius=192.000000
     DistortionRadius=576.000000
     GravityRadius=576.000000
     KillRadius=64.000000
     GravityStrength=500000.000000
     DamagePerSecond=300.000000
     Speed=350.000000
     MaxSpeed=350.000000
     Damage=50.000000
     DamageRadius=1000.000000
     MyDamageType=Class'tk_U2Creatures.U2DamTypeSingularityCannon'
     ExplosionDecal=Class'XEffects.RocketMark'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=65
     LightSaturation=80
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     DrawType=DT_None
     bDynamicLight=True
     LifeSpan=10.000000
     SoundVolume=255
     SoundRadius=150.000000
     bCollideActors=False
}
