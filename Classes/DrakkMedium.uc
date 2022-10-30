class DrakkMedium extends U2Creatures;





/*
    Variables
*/
var() float ChargeUpTime; // amount of time spent charging up with an armed laser before firing, maximum difficulty setting (lowest time)
var() float ChargeLead; // fraction of ChargeUpTime (between 0.0 and 1.0) where laser leads target by and subsequently locks in at end of charging
var() float RechargeTime; // amount of time (in seconds) spent recharging after a shot is fired, maximum difficulty setting (lowest time)
var() int LaserDamage; // amount of damage caused by laser shot
var() float DeactivationTimeLimit; // time before Drakk self-destructs after being deactivated, maximum difficulty setting (highest time)
var() bool bDamageWhenDeactivated; // allow Drakk to be damaged when collapsed and deactivated
var bool bDeactivated;

var int RefurbishHealth;
var float RefurbishFrac;
var float ServiceTimer;
var Pawn ServiceDroid;
var float DeactivationTimer;
var float SparkTimer;

var class<xEmitter> BeamEffectClass;
var int AimError;
var class<DamageType> BeamDamageType;


function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = False;
    bDeactivated = False;
}

simulated function DrakkDeactivate()
{
    local xEmitter Explosion;

    Explosion = Spawn( class'FastBotSparks', self, , Location, Rotation );
    Explosion.RemoteRole = ROLE_None;


    SetAnimAction('Folded');
    bDeActivated = true;
//  EnableRotation( false );
    RotationRate.Pitch=0;
    RotationRate.Yaw=0;
    RotationRate.Roll=0;

    SetCollisionSize(CollisionRadius, default.CollisionHeight * 0.5);
    //LController.SetFrozen(true);
    //DropToGround();
    SetPhysics(PHYS_Falling);

    // make sure firing mode is also taken care of
    //FireTimer = -RechargeTime;
    /*TracerBeamEffect.bHidden = true;
    TracerEndDummy.AmbientSound = None;
    TracerStartDummy.AmbientSound = None;
    */


    // self-destruct timer
    DeactivationTimer = DeactivationTimeLimit;
}


simulated function DrakkActivate()
{
    //PlaySound(sound'U2C_U2DrakkNew.Laser_Charge_6', SLOT_Misc);

    DeactivationTimer = 0.0;
    ServiceDroid = None;
    if (bDamageWhenDeactivated)
        Health = RefurbishHealth * RefurbishFrac; // restore to intended refurbishing health incase we were damaged while we were down

    /*if (SmokeEffect!=None)
    {
        SmokeEffect.Destroy();
        SmokeEffect = None;
    }*/
    /*if (ElectricEffect!=None)
    {
        ElectricEffect.Destroy();
        ElectricEffect = None;
    }*/


    SetCollisionSize(CollisionRadius, default.CollisionHeight);
    RotationRate.Pitch=Default.RotationRate.Pitch;
    RotationRate.Yaw=Default.RotationRate.Yaw;
    RotationRate.Roll=Default.RotationRate.Roll;
    SetAnimAction('Unfold');
    //MeshAgentSetInputCurValue('State', 'Active');
}

function Step()
{
    //PlaySound(sound'scuttle1pp', SLOT_Interact);
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Walking);
}



event Landed(vector HitNormal)
{
    if (!bDeactivated)
        SetPhysics(PHYS_Walking);
    else
        SetPhysics(PHYS_Falling);
    Super.Landed(HitNormal);
}

event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Walking);
    Super.HitWall(HitNormal,HitWall);
}



simulated function PlayDirectionalDeath(Vector HitLoc)
{

    PlayAnim('Folded');
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
    if ( Health <= Default.Health * 0.5 )
        DrakkDeactivate();
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local name Anim;
    local float frame,rate;
        local Vector X,Y,Z, Dir;

    if ( bShotAnim )
        return;

    GetAnimParams(0, Anim,frame,rate);



    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

     // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
            Dir = VRand();
        }
        // hit location based
        else
        {
            Dir = -Normal(Location - HitLoc);
        }


        PlayAnim('Hit1',, 0.1);





}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    SetAnimAction('Attack1');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



/*function HitDamageTarget()
{
    if ( MeleeDamageTarget(MeleeDamage, (25000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}*/


function RangedAttack(Actor A)
{
    //local float Dist;

    if ( bShotAnim )
        return;


    //Dist = VSize(A.Location - Location);





    if ( FastTrace(A.Location,Location) == true )
    {
        FireBeam();
    }
    bShotAnim = true;
    return;



}

function FireBeam()
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local float TraceRange;
    local coords BoneCoords;
    local vector Start;
    local rotator Dir;
    Local xEmitter Beam;
    local bool bReflect;


    GetAxes(Rotation,X,Y,Z);
    BoneCoords = GetBoneCoords('laser01end');
    Start = BoneCoords.Origin;

    Dir = Controller.AdjustAim(SavedFireProperties,Start,AimError);
    TraceRange = 10000;

    while(true)
    {
        bReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;
        Other = Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && Other != Instigator)
        {
            if (Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, LaserDamage * 0.25))
            {
                bReflect = true;
            }
            else if ( Other != mainArcHitTarget )
            {
                if ( !Other.bWorldGeometry )
                {
                    if ( (Pawn(Other) != None))
                    {
                        HitLocation = Other.Location;
                        Other.TakeDamage(LaserDamage, Instigator, HitLocation, X, BeamDamageType);
                    }
                }
                else
                {
                    HitLocation = HitLocation + 2.0 * HitNormal;
                }
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Normal(Start - End);
        }

        Beam = Spawn(BeamEffectClass ,,, Start,);
        Beam.mSpawnVecA = HitLocation;
        PlaySound(FireSound,SLOT_Interact);

        if(bReflect == true)
        {
            Start = HitLocation;
            Dir = Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}

simulated function StartDeRes()
{
    if( Level.NetMode == NM_DedicatedServer )
        return;

    AmbientGlow=254;
    MaxLights=0;

    Skins[0]=DeResMat0;
    Skins[1]=DeResMat1;
    Skins[2]=DeResMat1;
    Skins[3]=DeResMat1;
    Skins[4]=DeResMat1;
    Skins[5]=DeResMat1;

    // Turn off collision when we de-res (avoids rockets etc. hitting corpse!)
    SetCollision(false, false, false);

    // Remove/disallow projectors
    Projectors.Remove(0, Projectors.Length);
    bAcceptsProjectors = false;

    // Remove shadow
    if(PlayerShadow != None)
        PlayerShadow.bShadowActive = false;

    // Remove flames
    RemoveFlamingEffects();

    // Turn off any overlays
    SetOverlayMaterial(None, 0.0f, true);

    bDeRes = true;
}

defaultproperties
{
     ChargeupTime=0.800000
     ChargeLead=0.250000
     RechargeTime=2.000000
     LaserDamage=50
     DeactivationTimeLimit=60.000000
     BeamEffectClass=Class'tk_U2Creatures.RedLightningBolt'
     aimerror=350
     BeamDamageType=Class'XWeapons.DamTypeSniperShot'
     bCanDodge=False
     bTryToWalk=True
     DodgeSkillAdjust=2.000000
     HitSound(0)=Sound'tk_U2Creatures.Drakk.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.Drakk.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.Drakk.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.Drakk.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.Drakk.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.Drakk.DieSoft2'
     DeathSound(2)=Sound'tk_U2Creatures.Drakk.DieSoft3'
     DeathSound(3)=Sound'tk_U2Creatures.Drakk.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.Drakk.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.Drakk.SeeEnemy2'
     ChallengeSound(2)=Sound'tk_U2Creatures.Drakk.SeeEnemy3'
     ChallengeSound(3)=Sound'tk_U2Creatures.Drakk.SeeEnemy1'
     FireSound=Sound'tk_U2Creatures.WeaponsA_LaserRifle.LR_Fire'
     ScoringValue=8
     Species=Class'tk_U2Creatures.SPECIES_DrakkMedium'
     GibGroupClass=Class'tk_U2Creatures.DrakkDroidGibGroup'
     WallDodgeAnims(0)="IdleWaitBreathe01"
     WallDodgeAnims(1)="IdleWaitBreathe01"
     WallDodgeAnims(2)="IdleWaitBreathe01"
     WallDodgeAnims(3)="IdleWaitBreathe01"
     IdleHeavyAnim="IdleWaitBreath01"
     IdleRifleAnim="IdleWaitBreath02"
     FireHeavyRapidAnim="Attack1"
     FireHeavyBurstAnim="Attack1"
     FireRifleRapidAnim="Attack1"
     FireRifleBurstAnim="Attack1"
     bCanStrafe=False
     MeleeRange=40.000000
     GroundSpeed=375.000000
     AirSpeed=375.000000
     JumpZ=0.000000
     Health=800
     MovementAnims(0)="IdleWaitBreathe01"
     MovementAnims(1)="IdleWaitBreathe01"
     MovementAnims(2)="IdleWaitBreathe01"
     MovementAnims(3)="IdleWaitBreathe01"
     TurnLeftAnim="IdleWaitBreathe01"
     TurnRightAnim="IdleWaitBreathe01"
     SwimAnims(0)="IdleWaitBreathe01"
     SwimAnims(1)="IdleWaitBreathe01"
     SwimAnims(2)="IdleWaitBreathe01"
     SwimAnims(3)="IdleWaitBreathe01"
     CrouchAnims(0)="IdleWaitBreathe01"
     CrouchAnims(1)="IdleWaitBreathe01"
     CrouchAnims(2)="IdleWaitBreathe01"
     CrouchAnims(3)="IdleWaitBreathe01"
     WalkAnims(0)="IdleWaitBreathe01"
     WalkAnims(1)="IdleWaitBreathe01"
     WalkAnims(2)="IdleWaitBreathe01"
     WalkAnims(3)="IdleWaitBreathe01"
     AirAnims(0)="IdleWaitBreathe01"
     AirAnims(1)="IdleWaitBreathe01"
     AirAnims(2)="IdleWaitBreathe01"
     AirAnims(3)="IdleWaitBreathe01"
     TakeoffAnims(0)="IdleWaitBreathe01"
     TakeoffAnims(1)="IdleWaitBreathe01"
     TakeoffAnims(2)="IdleWaitBreathe01"
     TakeoffAnims(3)="IdleWaitBreathe01"
     LandAnims(0)="IdleWaitBreathe01"
     LandAnims(1)="IdleWaitBreathe01"
     LandAnims(2)="IdleWaitBreathe01"
     LandAnims(3)="IdleWaitBreathe01"
     DoubleJumpAnims(0)="IdleWaitBreathe01"
     DoubleJumpAnims(1)="IdleWaitBreathe01"
     DoubleJumpAnims(2)="IdleWaitBreathe01"
     DoubleJumpAnims(3)="IdleWaitBreathe01"
     DodgeAnims(0)="IdleWaitBreathe01"
     DodgeAnims(1)="IdleWaitBreathe01"
     DodgeAnims(2)="IdleWaitBreathe01"
     DodgeAnims(3)="IdleWaitBreathe01"
     AirStillAnim="IdleWaitBreathe01"
     TakeoffStillAnim="IdleWaitBreathe01"
     CrouchTurnRightAnim="IdleWaitBreathe01"
     CrouchTurnLeftAnim="IdleWaitBreathe01"
     IdleCrouchAnim="IdleWaitBreath01"
     IdleSwimAnim="IdleWaitBreathe01"
     IdleWeaponAnim="IdleWaitBreathe01"
     IdleRestAnim="IdleWaitBreathe01"
     IdleChatAnim="IdleWaitBreath01"
     AmbientSound=Sound'tk_U2Creatures.Drakk.Ambient'
     Mesh=SkeletalMesh'tk_U2Creatures.DrakkMedium'
     DrawScale=0.550000
     PrePivot=(Z=-40.000000)
     Skins(0)=Shader'tk_U2Creatures.Drakk.DrakkMediumBody2FX'
     Skins(1)=Shader'tk_U2Creatures.Drakk.DrakkMediumBody1FX'
     Skins(2)=Shader'tk_U2Creatures.Drakk.drakkmediumbody3fx'
     SoundVolume=250
     SoundRadius=200.000000
     CollisionRadius=39.000000
     CollisionHeight=90.000000
     Mass=350.000000
     RotationRate=(Pitch=4096,Yaw=6500,Roll=3072)
     Begin Object Class=KarmaParamsSkel Name=PawnKParams
         KConvulseSpacing=(Max=2.200000)
         KLinearDamping=0.150000
         KAngularDamping=0.050000
         KBuoyancy=1.000000
         KStartEnabled=True
         KVelDropBelowThreshold=50.000000
         bHighDetailOnly=False
         KFriction=1.700000
         KRestitution=0.300000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsSkel'PawnKParams'

}
