class Mukhogg extends U2Creatures;

var int RamDamage;
var bool bRamming;
var() name StepEvent;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = true;
    MonsterController(Controller).CombatStyle = 1.0;
}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('Mukhogg') || (P.IsA('MiniMukhogg') ) ) );
}

simulated function Step()
{

    //if( Mass >= 300 )
    //  class'UtilGame'.static.MakeShake( Self, Location, Mass/300 * 1024, 7, 0.4 );
    Super.Step();
    if (FRand() < 0.25)
        PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep1', SLOT_Interact);
    else if (FRand() < 0.5)
        PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep2', SLOT_Interact);
    else if (FRand() < 0.75)
        PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep3', SLOT_Interact);
    else if (FRand() < 1.0)
        PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep4', SLOT_Interact);
}

function ServerStep()
{
    Super.ServerStep();
    if (Level.NetMode == NM_Client)
    {
        if (FRand() < 0.25)
            PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep1', SLOT_Interact);
        else if (FRand() < 0.5)
            PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep2', SLOT_Interact);
        else if (FRand() < 0.75)
            PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep3', SLOT_Interact);
        else if (FRand() < 1.0)
            PlaySound(sound'tk_U2Creatures.MukhoggA_Footstep.FootStep4', SLOT_Interact);
    }
}



function ThrowOther(Pawn Other,int Power)
{
    local float dist, shake;
    local vector Momentum;

    //log("ThrowOther: Other.Mass:"$Other.mass);
    if ( Other.mass >= Mass )
        return;

    if (xPawn(Other)==none)
    {//log("power:"$power);
        if ( /*Power<400 ||*/ (Other.Physics != PHYS_Walking) )
            return;
        dist = VSize(Location - Other.Location);
        if (dist > Mass * 10)// was > Mass
            return;
    }
    else
    {

        dist = VSize(Location - Other.Location);
        //shake = 0.4*FMax(500, Mass - dist);
        shake = 0.6*FMax(500, Mass - dist);
        shake=FMin(2000,shake);
        if ( dist > Mass * 10)// was > Mass
            return;
        if(Other.Controller!=none)
            Other.Controller.ShakeView( vect(0.0,0.02,0.0)*shake, vect(0,1000,0),0.003*shake, vect(0.02,0.02,0.02)*shake, vect(1000,1000,1000),0.003*shake);

        if ( Other.Physics != PHYS_Walking )
            return;
    }

    Momentum = 1.1 * Vrand();
    Momentum.Z = FClamp(0,Power,Power - ( 0.4 * dist + Max(10,Other.Mass)*10));
    Other.AddVelocity(Momentum);
}




event Landed(vector HitNormal)
{
    SetPhysics(PHYS_Walking);
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
    PlayAnim('DeathHitDie');
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 && VSize(Velocity) == 0)
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{

    if ( bShotAnim || VSize(Velocity) != 0 )
        return;

        PlayAnim('HitGut01',, 0.1);

}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.MukhoggA_Misc.RevUp',SLOT_Interact);
    SetAnimAction('RevUp');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function RamDamageTarget()
{
    if ( MeleeDamageTarget(RamDamage, (65000 * Normal(Controller.Target.Location - Location))) )//2500
        if (FRand() < 0.5)
            PlaySound(sound'tk_U2Creatures.RammerA_MeleeDamage.Headbutt1', SLOT_Interact);
        else
            PlaySound(sound'tk_U2Creatures.RammerA_MeleeDamage.Headbutt2', SLOT_Interact);
}


function RangedAttack(Actor A)
{
    local float Dist;

    if ( bShotAnim )
        return;


    Dist = VSize(A.Location - Location);

    if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        return;
    }

    if ( Location.Z - A.Location.Z + A.CollisionHeight <= 0 )
        return;
    if ( VSize(A.Location - Location) > MeleeRange + CollisionRadius + A.CollisionRadius - FMax(0, 0.7 * A.Velocity Dot Normal(A.Location - Location)) )
        return;


    Acceleration = AccelRate * Normal(A.Location - Location + vect(0,0,0.8) * A.CollisionHeight);
    Enable('Bump');
    bRamming = true;

    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius )
    {

        SetAnimAction('Attack01');
        if (FRand() <= 0.33 )
            PlaySound(sound'tk_U2Creatures.MukhoggA_MeleeDamage.MeleeAttack1', SLOT_Interact);
        else if (FRand() <= 0.66 )
            PlaySound(sound'tk_U2Creatures.MukhoggA_MeleeDamage.MeleeAttack2', SLOT_Interact);
        else
            PlaySound(sound'tk_U2Creatures.MukhoggA_MeleeDamage.MeleeAttack3', SLOT_Interact);

        //Controller.bPreparingMove = true;
        bShotAnim = true;
        //Acceleration = vect(0,0,0);
        return;
    }


}


singular function Bump(actor Other)
{
    local name Anim;
    local float frame,rate;

    if ( bShotAnim && bRamming )
    {
        bRamming = false;
        GetAnimParams(0, Anim,frame,rate);
        //if ( (Anim == 'Whip') || (Anim == 'Sting') )
        //  RamDamageTarget(18, (20000.0 * Normal(Controller.Target.Location - Location)));
        Velocity *= -0.5;
        Acceleration *= -1;
        if (Acceleration.Z < 0)
            Acceleration.Z *= -1;
    }
    Super.Bump(Other);
}

defaultproperties
{
     RamDamage=50
     StepShakeRadius=2048.000000
     StepShakeMagnitude=7.000000
     StepShakeDuration=0.400000
     bTryToWalk=True
     HitSound(0)=Sound'tk_U2Creatures.MukhoggA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.MukhoggA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.MukhoggA_HitSoft.Hit1'
     HitSound(3)=Sound'tk_U2Creatures.MukhoggA_HitSoft.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.MukhoggA_DieSoft.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.MukhoggA_DieSoft.DieSoft2'
     DeathSound(2)=Sound'tk_U2Creatures.MukhoggA_HitSoft.Hit1'
     DeathSound(3)=Sound'tk_U2Creatures.MukhoggA_DieSoft.DieSoft1'
     ChallengeSound(0)=Sound'tk_U2Creatures.MukhoggA_Acquire.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.MukhoggA_Misc.RevUp'
     ChallengeSound(2)=Sound'tk_U2Creatures.MukhoggA_Misc.Getup1'
     ChallengeSound(3)=Sound'tk_U2Creatures.MukhoggA_Misc.Getup2'
     FireSound=Sound'tk_U2Creatures.MukhoggA_MeleeDamage.MeleeAttack1'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_Mukhogg'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     WallDodgeAnims(0)="RunFwrd01"
     WallDodgeAnims(1)="RunFwrd01"
     WallDodgeAnims(2)="RunFwrd01"
     WallDodgeAnims(3)="RunFwrd01"
     IdleHeavyAnim="Breath02"
     IdleRifleAnim="Breath05"
     FireHeavyRapidAnim="Attack01"
     FireHeavyBurstAnim="Attack01"
     FireRifleRapidAnim="Attack01"
     FireRifleBurstAnim="Attack01"
     bCanStrafe=False
     MeleeRange=100.000000
     GroundSpeed=420.000000
     AirSpeed=450.000000
     AccelRate=1000.000000
     WalkingPct=0.150000
     Health=500
     SoundDampening=0.800000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="RunFwrd01"
     MovementAnims(1)="WalkFrwd01"
     MovementAnims(2)="RunFwrd01"
     MovementAnims(3)="RunFwrd01"
     TurnLeftAnim="TurnLeft"
     TurnRightAnim="TurnRight"
     SwimAnims(0)="WalkFrwd01"
     SwimAnims(1)="WalkFrwd01"
     SwimAnims(2)="WalkFrwd01"
     SwimAnims(3)="WalkFrwd01"
     CrouchAnims(0)="WalkFrwd01"
     CrouchAnims(1)="WalkFrwd01"
     CrouchAnims(2)="WalkFrwd01"
     CrouchAnims(3)="WalkFrwd01"
     WalkAnims(0)="WalkFrwd01"
     WalkAnims(1)="WalkFrwd01"
     WalkAnims(2)="WalkFrwd01"
     WalkAnims(3)="WalkFrwd01"
     AirAnims(0)="RunFwrd01"
     AirAnims(1)="RunFwrd01"
     AirAnims(2)="RunFwrd01"
     AirAnims(3)="RunFwrd01"
     TakeoffAnims(0)="RunFwrd01"
     TakeoffAnims(1)="RunFwrd01"
     TakeoffAnims(2)="RunFwrd01"
     TakeoffAnims(3)="RunFwrd01"
     LandAnims(0)="WalkFrwd01"
     LandAnims(1)="WalkFrwd01"
     LandAnims(2)="WalkFrwd01"
     LandAnims(3)="WalkFrwd01"
     DoubleJumpAnims(0)="RunFwrd01"
     DoubleJumpAnims(1)="RunFwrd01"
     DoubleJumpAnims(2)="RunFwrd01"
     DoubleJumpAnims(3)="RunFwrd01"
     DodgeAnims(0)="RunFwrd01"
     DodgeAnims(1)="RunFwrd01"
     DodgeAnims(2)="RunFwrd01"
     DodgeAnims(3)="RunFwrd01"
     AirStillAnim="RunFwrd01"
     TakeoffStillAnim="RunFwrd01"
     CrouchTurnRightAnim="TurnRight"
     CrouchTurnLeftAnim="TurnLeft"
     IdleCrouchAnim="Breath02"
     IdleSwimAnim="WalkFrwd01"
     IdleWeaponAnim="Breath01"
     IdleRestAnim="Breath01"
     IdleChatAnim="IdleWaitBreath05"
     Mesh=SkeletalMesh'tk_U2Creatures.Mukhogg'
     DrawScale=0.500000
     PrePivot=(Z=10.000000)
     Skins(0)=Texture'tk_U2Creatures.MukhoggBody'
     Skins(1)=Texture'tk_U2Creatures.MukhoggTeeth'
     TransientSoundVolume=2.000000
     CollisionRadius=100.000000
     CollisionHeight=72.000000
     Mass=600.000000
     RotationRate=(Yaw=32000)
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
