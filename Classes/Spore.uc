class Spore extends Monster;

// Damage attributes.
var   float    Damage;
var   float    DamageRadius;
var   float    MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var   class<DamageType>    MyDamageType;



var() string ImpactSoundString;
var() bool bMultipleAxes; // rotate on multiple axes simultaneously -- results in "tumbling" effect
var() bool bRandomizeDirection; // if true, rotation directions randomly reversed
var() rotator MinRotationRate, MaxRotationRate; // Should be >= 0




event PreBeginPlay()
{
    local rotator NewRotation;
    local int NumAxes, AxisToUse;

    Super.PreBeginPlay();

    // randomize rotation
    NewRotation.Pitch   = RandRange( 0, 65535 );
    NewRotation.Yaw     = RandRange( 0, 65535 );
    NewRotation.Roll    = RandRange( 0, 65535 );
    SetRotation( NewRotation );

    // randomize ambient rotation rate
    if( bMultipleAxes )
    {
        if( MaxRotationRate.Pitch > 0 )
            RotationRate.Pitch = RandRange( MinRotationRate.Pitch, MaxRotationRate.Pitch );
        if( MaxRotationRate.Yaw > 0 )
            RotationRate.Yaw = RandRange( MinRotationRate.Yaw, MaxRotationRate.Yaw );
        if( MaxRotationRate.Roll > 0 )
            RotationRate.Roll = RandRange( MinRotationRate.Roll, MaxRotationRate.Roll );
    }
    else
    {
        if( MaxRotationRate.Pitch > 0 )
            NumAxes++;
        if( MaxRotationRate.Yaw > 0 )
            NumAxes++;
        if( MaxRotationRate.Roll > 0 )
            NumAxes++;

        AxisToUse = RandRange( 0, NumAxes );

        NumAxes = 0;
        if( MaxRotationRate.Pitch > 0 )
        {
            if( NumAxes == AxisToUse )
                RotationRate.Pitch = RandRange( MinRotationRate.Pitch, MaxRotationRate.Pitch );
            NumAxes++;
        }

        if( MaxRotationRate.Yaw > 0 )
        {
            if( NumAxes == AxisToUse )
                RotationRate.Yaw = RandRange( MinRotationRate.Yaw, MaxRotationRate.Yaw );
            NumAxes++;
        }

        if( MaxRotationRate.Roll > 0 )
        {
            if( NumAxes == AxisToUse )
                RotationRate.Roll = RandRange( MinRotationRate.Roll, MaxRotationRate.Roll );
            NumAxes++;
        }
    }

    if( bRandomizeDirection )
    {
        if( FRand() < 0.5 )
            RotationRate.Pitch = -RotationRate.Pitch;
        if( FRand() < 0.5 )
            RotationRate.Yaw = -RotationRate.Yaw;
        if( FRand() < 0.5 )
            RotationRate.Roll = -RotationRate.Roll;
    }

}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Flying);
}



event Landed(vector HitNormal)
{
    SetPhysics(PHYS_Flying);
    Super.Landed(HitNormal);
}

event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Walking);
    Super.HitWall(HitNormal,HitWall);
}

singular function Falling()
{
    SetPhysics(PHYS_Flying);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{

    Spawn( GibGroupClass.default.BloodGibClass,,,Location );
    //Destroy();
    bHidden = true;

    if( ImpactSoundString != "" )
        PlaySound( Sound(DynamicLoadObject( ImpactSoundString, class'Sound' )), SLOT_Misc );

}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
}


simulated function PlayDirectionalHit(Vector HitLoc)
{
}


function PlayVictory()
{
}



event Bump( Actor Other )
{
    if( Pawn( Other ) != None && Spore( Other ) == None )
    {
        Other.TakeDamage( Damage, Self, Location, vect(0,0,0), class'DamTypeSpore' );
        TakeDamage( Damage, Self, Location, vect(0,0,0), class'DamTypeSpore' );
    }
    else
        Super.Bump( Other );


}

event Destroyed()
{


    Super.Destroyed();




}


state DyingState
{
Begin:
    Destroy();
}

defaultproperties
{
     Damage=10.000000
     ImpactSoundString="tk_U2Creatures.SporeA.SporeImpact"
     bMultipleAxes=True
     bRandomizeDirection=True
     MinRotationRate=(Pitch=2048,Yaw=2048,Roll=2048)
     MaxRotationRate=(Pitch=32767,Yaw=32767,Roll=32767)
     ScoringValue=2
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     bCanFly=True
     bCanStrafe=False
     SightRadius=2048.000000
     MeleeRange=80.000000
     GroundSpeed=100.000000
     WaterSpeed=150.000000
     AirSpeed=250.000000
     Health=1
     UnderWaterTime=-1.000000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     bPhysicsAnimUpdate=False
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'tk_U2Creatures.Creatures.Alien_Spore'
     bActorShadows=False
     AmbientSound=Sound'tk_U2Creatures.SporeA.SporeAmbient_07'
     DrawScale=0.320000
     PrePivot=(Z=2.000000)
     Skins(0)=Shader'tk_U2Creatures.SporeBug_FX'
     SoundRadius=300.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=300.000000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Mass=5.000000
     Buoyancy=5.000000
}
