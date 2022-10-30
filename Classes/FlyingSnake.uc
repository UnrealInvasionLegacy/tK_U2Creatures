class FlyingSnake extends U2Creatures;

var int MeleeDamage, BiteDamage;

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('FlyingSnake') ) );
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = True;


    if (Frand() <= 0.45)
        SetPhysics(PHYS_Walking);
    else
        SetPhysics(PHYS_Flying);

    MonsterController(Controller).CombatStyle = 10.0;

}

simulated function PostNetBeginPlay()
{
    local float SkinVar;

    Super.PostNetBeginPlay();

    SkinVar = FRand();

    if (SkinVar <= 0.25)
    {
            Skins[0] = Texture'tk_U2Creatures.FlyingSnakeCorpse';
            Skins[1] = Shader'tk_U2Creatures.FlyingSnakeCorpseWings';
    }
    else
    {
            Skins[0] = Texture'tk_U2Creatures.FlyingSnake';
            Skins[1] = Shader'tk_U2Creatures.FlyingSnakeWings';
    }

}


function Step()
{
    PlaySound(sound'scuttle1pp', SLOT_Interact);
}

function Flap()
{
    PlaySound(sound'fly1m', SLOT_Interact);
}

function SetMovementPhysics()
{
    SetPhysics(PHYS_Flying);
}


simulated function AnimEnd(int Channel)
{
    if ( bShotAnim )
    {
        bShotAnim = false;
        Controller.bPreparingMove = false;
    }
    if ( Physics == PHYS_Flying )
        LoopAnim('Fly');
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

    SetPhysics(PHYS_Flying);
    if ( !bShotAnim && (FRand() < 0.3) )
    {
        bShotAnim = true;
        SetAnimAction('AirDodgeF');
    }
    Controller.Destination = Location + 200 * duckDir;
    Velocity = AirSpeed * duckDir;
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

singular function Falling()
{
    SetPhysics(PHYS_Flying);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    if (  (Physics == PHYS_Flying || Physics == PHYS_Falling) )
        PlayAnim('Fall');
    else
        PlayAnim('GroundDeath');
}

simulated function PlayFallDeath()
{

    PlayAnim('FallDeath');

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

    if ( Anim == 'AirDodgeB' || Anim == 'AirDodgeF' || Anim == 'AirDodgeL' || Anim == 'AirDodgeR' || Anim == 'GroundDodgeB' || Anim == 'GroundDodgeF' || Anim == 'GroundDodgeL' || Anim == 'GroundDodgeR' )
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

    if (Physics == PHYS_Walking || Physics == PHYS_None)
    {
            if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
            {
                    PlayAnim('GroundHit1',, 0.1);
            }
            else if ( Dir Dot X < -0.7 )
            {
                PlayAnim('GroundHit2',, 0.1);
            }
            else if ( Dir Dot Y > 0 )
            {
                PlayAnim('GroundHit1',, 0.1);
            }
            else
            {
                PlayAnim('GroundHit2',, 0.1);
            }

    }
    else
    {
            if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
            {
                    PlayAnim('AirHit1',, 0.1);
            }
            else if ( Dir Dot X < -0.7 )
            {
                PlayAnim('AirHit2',, 0.1);
            }
            else if ( Dir Dot Y > 0 )
            {
                PlayAnim('AirHit1',, 0.1);
            }
            else
            {
                PlayAnim('AirHit2',, 0.1);
            }
    }


}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    SetAnimAction('GroundAttack1');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function StingDamageTarget()
{
    if ( MeleeDamageTarget(MeleeDamage, (10000 * Normal(Controller.Target.Location - Location))) )//25000
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}

function BiteDamageTarget()
{
    if ( MeleeDamageTarget(BiteDamage, (5000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}


function RangedAttack(Actor A)
{
    local float Dist;

    if ( bShotAnim )
    {
        return;
    }

    Dist = VSize(A.Location - Location);
    if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        Acceleration = AccelRate * Normal(A.Location - Location + vect(0,0,0.8) * A.CollisionHeight);
        return;
    }



    if (Physics == PHYS_Walking || Physics == PHYS_None)
    {
        if ( FRand() < 0.5 )
        {
            SetAnimAction('GroundAttack1');


        }
        else
        {
            SetAnimAction('GroundAttack2');


        }
        bShotAnim = true;
        Acceleration = vect(0,0,0);
    }
    else
    {
        bShotAnim = true;
        //Acceleration = vect(0,0,0);
        if ( FRand() < 0.5 )
        {
            SetAnimAction('AirAttack1');


        }
        else
        {
            SetAnimAction('AirAttack2');

        }
    }

    //Controller.bPreparingMove = true;

}


simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    AmbientSound = None;
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    LifeSpan = RagdollLifeSpan;
        GotoState('Dying');


    SetPhysics(PHYS_Falling);


    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetInvisibility(0.0);
    PlayDirectionalDeath(HitLoc);

    super.PlayDying(DamageType,HitLoc);

}

State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

    function Landed(vector HitNormal)
    {
        SetPhysics(PHYS_None);
        if ( !IsAnimating(0) )
            LandThump();
        PlayAnim('FallDeath');
        Super.Landed(HitNormal);
    }

    simulated function Timer()
    {
        if ( !PlayerCanSeeMe() )
            Destroy();
        else if ( LifeSpan <= DeResTime && bDeRes == false )
            StartDeRes();
        else
            SetTimer(1.0, false);
    }
}

defaultproperties
{
     MeleeDamage=15
     BiteDamage=10
     DodgeSkillAdjust=1.000000
     HitSound(0)=Sound'tk_U2Creatures.FlyingSnakeA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.FlyingSnakeA_HitHard.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.FlyingSnakeA_HitSoft.Hit1'
     HitSound(3)=Sound'tk_U2Creatures.FlyingSnakeA_HitHard.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.FlyingSnakeA_DieSoft.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.FlyingSnakeA_Falling.Falling1'
     DeathSound(2)=Sound'tk_U2Creatures.FlyingSnakeA_DieSoft.DieSoft1'
     DeathSound(3)=Sound'tk_U2Creatures.FlyingSnakeA_HitHard.Hit2'
     ChallengeSound(0)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle1'
     ChallengeSound(1)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle2'
     ChallengeSound(2)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle3'
     ChallengeSound(3)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle1'
     FireSound=Sound'tk_U2Creatures.FlyingSnakeA_MeleeDamage.MeleeAttack1'
     ScoringValue=2
     Species=Class'tk_U2Creatures.SPECIES_Snake'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     WallDodgeAnims(0)="GroundDodgeF"
     WallDodgeAnims(1)="GroundDodgeB"
     WallDodgeAnims(2)="GroundDodgeL"
     WallDodgeAnims(3)="GroundDodgeR"
     IdleHeavyAnim="GroundIdle"
     IdleRifleAnim="GroundIdle"
     FireHeavyRapidAnim="GroundAttack1"
     FireHeavyBurstAnim="GroundAttack2"
     FireRifleRapidAnim="GroundAttack1"
     FireRifleBurstAnim="GroundAttack2"
     bCanFly=True
     MeleeRange=40.000000
     GroundSpeed=250.000000
     AirSpeed=450.000000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="GroundWalk"
     MovementAnims(1)="GroundBackStep"
     MovementAnims(2)="GroundWalk"
     MovementAnims(3)="GroundWalk"
     TurnLeftAnim="GroundBackStep"
     TurnRightAnim="GroundBackStep"
     SwimAnims(0)="GroundWalk"
     SwimAnims(1)="GroundBackStep"
     SwimAnims(2)="GroundWalk"
     SwimAnims(3)="GroundWalk"
     CrouchAnims(0)="GroundIdle"
     CrouchAnims(1)="GroundIdle"
     CrouchAnims(2)="GroundIdle"
     CrouchAnims(3)="GroundIdle"
     WalkAnims(0)="GroundWalk"
     WalkAnims(1)="GroundBackStep"
     WalkAnims(2)="GroundWalk"
     WalkAnims(3)="GroundWalk"
     AirAnims(0)="Fly"
     AirAnims(1)="Fly"
     AirAnims(2)="Fly"
     AirAnims(3)="Fly"
     TakeoffAnims(0)="Fly"
     TakeoffAnims(1)="Fly"
     TakeoffAnims(2)="Fly"
     TakeoffAnims(3)="Fly"
     DoubleJumpAnims(0)="Fly"
     DoubleJumpAnims(1)="Fly"
     DoubleJumpAnims(2)="Fly"
     DoubleJumpAnims(3)="Fly"
     DodgeAnims(0)="AirDodgeF"
     DodgeAnims(1)="AirDodgeB"
     DodgeAnims(2)="AirDodgeL"
     DodgeAnims(3)="AirDodgeR"
     AirStillAnim="Fly"
     TakeoffStillAnim="Fly"
     CrouchTurnRightAnim="GroundBackStep"
     CrouchTurnLeftAnim="GroundBackStep"
     IdleCrouchAnim="GroundIdle"
     IdleSwimAnim="GroundWalk"
     IdleWeaponAnim="GroundIdle"
     IdleRestAnim="GroundIdle"
     IdleChatAnim="GroundIdle"
     Mesh=SkeletalMesh'tk_U2Creatures.FlyingSnake'
     DrawScale=0.750000
     Skins(0)=Texture'tk_U2Creatures.FlyingSnake'
     Skins(1)=Shader'tk_U2Creatures.FlyingSnakeWings'
     TransientSoundVolume=2.000000
     TransientSoundRadius=1200.000000
     CollisionRadius=40.000000
     CollisionHeight=20.000000
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
