class AraknidLight extends U2Creatures;

var(Combat) int BiteDamage, LungeDamage, StingDamage, LungeRange, LungeRangeMin;
var(Combat) bool bLunging;
var() name DeathAnims[8];

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('AraknidLight') ||  P.IsA('AraknidMedium') || P.IsA('AraknidHeavy') || P.IsA('AraknidAlpha')) );
}


function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = True;
    MonsterController(Controller).CombatStyle = 1.0;
    MonsterController(Controller).MinHitWall = 0.0;
}

simulated function Step()
{
    Super(U2Creatures).Step();
    PlaySound(sound'tk_U2Creatures.MovementSkitterWalkLoud', SLOT_Interact);
}

function ServerStep()
{
    Super(U2Creatures).ServerStep();
    PlaySound(sound'tk_U2Creatures.MovementSkitterWalkLoud', SLOT_Interact);
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Falling);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z,duckdir;

    GetAxes(Rotation,X,Y,Z);
    if (DoubleClickMove == DCLICK_Forward)
        duckdir = X;
    else if (DoubleClickMove == DCLICK_Back)
        duckdir = -1*X;
    else if (DoubleClickMove == DCLICK_Left)
        duckdir = Y;
    else if (DoubleClickMove == DCLICK_Right)
        duckdir = -1*Y;

    SetPhysics(PHYS_Falling);
    if ( !bShotAnim && (FRand() < 0.3) )
    {
        bShotAnim = true;
        SetAnimAction('Jump');
    }
    Controller.Destination = Location + 200 * duckDir;
    Velocity = GroundSpeed * duckDir;
    Controller.GotoState('TacticalMove', 'DoMove');
    return true;
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

    PlayAnim(DeathAnims[Rand(8)], 0.7, 0.1);

}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local name Anim;
    local float frame,rate;
        local Vector X,Y,Z, Dir;

    if ( bShotAnim )
        return;

    GetAnimParams(0, Anim,frame,rate);

    if ( Anim == 'Jump' || Anim == 'Jumpbite' )
        return;

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


    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
                PlayAnim('Wound',, 0.1);
        }
        else if ( Dir Dot X < -0.7 )
        {
            PlayAnim('Wound03',, 0.1);
        }
        else
        {
            PlayAnim('Wound04',, 0.1);
        }


}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    if ( FRand() < 0.50)
        SetAnimAction('Threat');
    else
        SetAnimAction('Threat02');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function BiteDamageTarget()
{
    if ( MeleeDamageTarget(BiteDamage, (5000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tK_U2Creatures.MeleeImpactPoint1', SLOT_Interact);
}

singular function Bump(actor Other)
{
    local name Anim;
    local float frame,rate;

    if ( /*bShotAnim &&*/ bLunging )
    {
        bLunging = false;
        GetAnimParams(0, Anim,frame,rate);
        if ( Anim == 'JumpBite' )
            MeleeDamageTarget(12, (20000.0 * Normal(Controller.Target.Location - Location)));
    }
    Super.Bump(Other);
}


function RangedAttack(Actor A)
{
    local float Dist;
    //local name Anim;
    //local float frame,rate;

    if ( bShotAnim || isLeaping() || (Controller != None && Controller.Enemy == None) )
        return;

    if (LeapOdds > 0 && !bDoingLeapCheck) //Tick handles leaping
    {
        bDoingLeapCheck = true;
        Enable('Tick');
    }

    Dist = VSize(A.Location - Location);

    /*if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        return;
    }*/

    //bShotAnim = true;
    if ( Physics == PHYS_Swimming )
    {
        SetAnimAction('RunBite');
        bShotAnim = true;
    }
    else if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        bShotAnim = true;
        SetAnimAction('Bite');
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        return;
    }
    else
        Controller.GotoState('Charging');
    /*else if ( VSize(Velocity) == 0 )
    {
        SetAnimAction('Zap');
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }*/
    /*else if ( FRand() <= LeapOdds && VSize(A.Location - Location) <= LungeRange + CollisionRadius + A.CollisionRadius )
    {

        SetAnimAction('JumpBite');
        PlaySound(sound'tK_U2Creatures.MeleeImpactPoint2', SLOT_Interact);
        bLunging = true;
        Enable('Bump');
        //SetAnimAction('Lunge');
        Velocity = 500 * Normal(A.Location + A.CollisionHeight * vect(0,0,0.75) - Location);
        if ( dist > CollisionRadius + A.CollisionRadius + 35 )
            Velocity.Z += 0.7 * dist;
        SetPhysics(PHYS_Falling);
        return;
    }*/

}

simulated function Tick(float DeltaTime)
{
    local float dist;

    if (!bDoingLeapCheck || Level.TimeSeconds - LastLeapCheckTime < 0.25  || IsLeaping() )
        return;

    if (Controller != None && Controller.Enemy == None)
    {
        bDoingLeapCheck = false;
        Disable('Tick');
        return;
    }

    LastLeapCheckTime = Level.TimeSeconds;

    //log("LastLeapCheckTime:"$LastLeapCheckTime);
    if (Controller != None && U2MonsterController(Controller) != None && Controller.Enemy != None)
    {
        dist = VSize(Controller.Enemy.Location - Location);
        if (dist >= LeapMinRange && dist <= LeapMaxRange)
        {
            U2MonsterController(Controller).EnemyInLeapRange(dist);
        }
    }
}

function SpawnShot()
{
    if ( MeleeDamageTarget(BiteDamage, (25000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tK_U2Creatures.MeleeImpactPoint1', SLOT_Interact);
}


simulated function AnimEnd(int Channel)
{

    AnimAction = '';

    if ( bVictoryNext && (Physics != PHYS_Falling) )
    {
        bVictoryNext = false;
        PlayVictory();
    }
    if ( bShotAnim )
    {
        bShotAnim = false;
        Controller.bPreparingMove = false;
    }


    Super(XPawn).AnimEnd(Channel);
}

function PlayLeapAnim()
{
    bShotAnim = true;
    SetAnimAction('JumpBite');
}

defaultproperties
{
     BiteDamage=10
     LungeDamage=10
     StingDamage=15
     LungeRange=100
     DeathAnims(0)="Death"
     DeathAnims(1)="Death03"
     DeathAnims(2)="Death04"
     DeathAnims(3)="Death05"
     DeathAnims(4)="Death06"
     DeathAnims(5)="Death07"
     DeathAnims(6)="Death08"
     DeathAnims(7)="Crispy"
     LeapMinRange=256.000000
     LeapMaxRange=512.000000
     LeapOdds=0.350000
     LeapLowSpeed=1024.000000
     LeapToMeleeOdds=1.000000
     LeapDelayFailure=0.500000
     LeapDelayLand=0.100000
     LeapDelayPreJump=0.000000
     LeapDelaySuccess=2.000000
     LeapMaxDamage=10
     LeapMaxMomentumTransfer=10000.000000
     DodgeSkillAdjust=3.000000
     HitSound(0)=Sound'tk_U2Creatures.AraknidLightA_HitSoft.HitSoft1'
     HitSound(1)=Sound'tk_U2Creatures.AraknidLightA_HitSoft.HitSoft2'
     HitSound(2)=Sound'tk_U2Creatures.AraknidLightA_HitHard.HitHard1'
     HitSound(3)=Sound'tk_U2Creatures.AraknidLightA_HitHard.HitHard2'
     DeathSound(0)=Sound'tk_U2Creatures.AraknidLightA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.AraknidLightA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.AraknidLightA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.AraknidLightA_Idle.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.AraknidLightA_Idle.Idle1'
     ChallengeSound(1)=Sound'tk_U2Creatures.AraknidLightA_Idle.Idle2'
     ChallengeSound(2)=Sound'tk_U2Creatures.AraknidLightA_Idle.Idle1'
     ChallengeSound(3)=Sound'tk_U2Creatures.AraknidLightA_Idle.Idle2'
     FireSound=Sound'tk_U2Creatures.AraknidLightA_MeleeImpactPoint.MeleeImpactPoint1'
     AmmunitionClass=Class'tk_U2Creatures.AraknidLightAmmo'
     Species=Class'tk_U2Creatures.SPECIES_AraknidLight'
     GibGroupClass=Class'tk_U2Creatures.AraknidLightGibGroup'
     WallDodgeAnims(0)="Jump"
     WallDodgeAnims(1)="Jump"
     WallDodgeAnims(2)="Jump"
     WallDodgeAnims(3)="Jump"
     IdleHeavyAnim="Idle04"
     IdleRifleAnim="Idle04"
     FireHeavyRapidAnim="Zap"
     FireHeavyBurstAnim="Zap"
     FireRifleRapidAnim="Zap"
     FireRifleBurstAnim="Zap"
     bCrawler=True
     bCanStrafe=False
     MeleeRange=20.000000
     GroundSpeed=200.000000
     AirSpeed=450.000000
     SoundDampening=0.550000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="Run"
     MovementAnims(1)="Run"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"
     TurnLeftAnim="BambiWalk"
     TurnRightAnim="BambiWalk"
     SwimAnims(0)="Run"
     SwimAnims(1)="Run"
     SwimAnims(2)="Run"
     SwimAnims(3)="Run"
     CrouchAnims(0)="Walk"
     CrouchAnims(1)="Walk"
     CrouchAnims(2)="Walk"
     CrouchAnims(3)="Walk"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Walk"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     AirAnims(0)="Run"
     AirAnims(1)="Run"
     AirAnims(2)="Run"
     AirAnims(3)="Run"
     LandAnims(0)="Walk"
     LandAnims(1)="Walk"
     LandAnims(2)="Walk"
     LandAnims(3)="Walk"
     AirStillAnim="Run"
     CrouchTurnRightAnim="BambiWalk"
     CrouchTurnLeftAnim="BambiWalk"
     IdleCrouchAnim="BambiWobble"
     IdleSwimAnim="Run"
     IdleWeaponAnim="Idle04"
     IdleRestAnim="Idle04"
     IdleChatAnim="look"
     Mesh=SkeletalMesh'tk_U2Creatures.AraknidLight'
     DrawScale=0.600000
     PrePivot=(Z=-19.000000)
     Skins(0)=Texture'tk_U2Creatures.AraknidLight'
     TransientSoundVolume=2.000000
     CollisionRadius=28.000000
     CollisionHeight=18.000000
     Mass=10.000000
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
