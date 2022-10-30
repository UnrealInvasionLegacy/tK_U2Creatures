class SkaarjLight extends U2Creatures;//UScriptAnimMonsterSkaarj;//

//var bool bLunging;
// Attack damage.
var(Combat) byte
    LungeDamage,    // Basic damage done by lunge.
    SpinDamage, // Basic damage done by spin.
    ClawDamage, // Basic damage done by each claw.
    StabDamage, // Basic damage done by each stab.
    KickDamage, // Basic damage done by kick attack.
    HeadButtDamage; // Basic damage done by headbutt


var(Sounds) sound spin;
var(Sounds) sound claw;
var(Sounds) sound slice;
var(Sounds) sound lunge;
var(Sounds) sound headbutt;
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;


var name ClawAnims[10];
var name DeathAnims[9];
var name VictoryAnims[14];
var name FireAnims[8];
var name WalkSlashAnims[2];
var(Sounds) array<sound> MeleeSounds[4];
var(Sounds) array<sound> StepSounds[4];
var(Sounds) array<sound> TauntSounds[5];
//Heavy skaarj variables
var bool bSeekingDir;
var() name StepEvent;


var() float MinDefensiveModeDuration;
var() float CosMinDefensiveModeAngle;
var() float MovementShakeRadius;
var() float MovementShakeMagnitude;
var() float MovementShakeDuration;
var() float DefensiveCloseSpeed;
var() float DodgeProjectileOdds;
var() array<string> DefensiveSounds;
var() array<string> DefensiveRicochetSounds;

var() class<xEmitter> DefensiveEffect;//xEffects.WallSparks
var() xEmitter PreSpawnEffect;
var xEmitter DefensiveParticles;
var vector DefensiveParticlesLocation;

var() bool bCanDefend;

var bool bDefensiveMode;
var float LastDefensiveHitTime;
var float LastTauntTime;


const DefendLeftNotify          = 'defendleft';
const DefendRightNotify         = 'defendright';

// used to support dodging projectiles on-the-fly
var CollisionProxyIncoming IncomingProxy;
var float ProxyRadius;
var float ProxyHeight;  // from ground (including 2x normal collision height)
const EventIncoming = 'Incoming';

var array<string> AmbientSoundStrings;
var int AmbientSoundIndex;



replication
{
    //reliable if( Role<ROLE_Authority )
        ////DefensiveModeBegin, DefensiveModeEnd;

    reliable if( bNetDirty && Health <= 0 && Role==ROLE_Authority )
        DeathAnims;

    reliable if( bNetDirty && (Role==ROLE_Authority) )
        bDefensiveMode, /*bCanDefend,HandleDeflection,*/ GetGloveLocation, GetLeftGloveLocation, GetRightGloveLocation;//, ReflectNotify;
    reliable if(Role<ROLE_Authority)//was ==
        DefensiveParticles, /*DefensiveModeBegin, DefensiveModeEnd,*/ DefensiveParticlesLocation;



}

event PreBeginPlay()
{
    Super.PreBeginPlay();
    SetAmbientSoundIndex();
    SetAmbientSound();
}


function PostBeginPlay()
{

    Super.PostBeginPlay();

    MonsterController(Controller).CombatStyle = 1.0;//0.85;

    // allocate a proxy collision cylinder for detecting when the tentacles are touched without blocking anything
    IncomingProxy = Spawn( class'CollisionProxyIncoming', self );
    IncomingProxy.CP_SetCollision( true, false, false );
    IncomingProxy.CP_SetLocation( Location );
    IncomingProxy.CP_SetCollisionSize( ProxyRadius, ProxyHeight ); //!!mdf-make sure doesn't go below feet?
    IncomingProxy.CP_SetTouchTarget( Self );
    IncomingProxy.AddClass( 'Projectile' );
    IncomingProxy.SetEvent( EventIncoming );
    IncomingProxy.SetBase( Self );

    //Tick handles leaping - U2 normally uses a built-in event to check every 0.25 seconds
    if ( LeapOdds > 0  && !bDoingLeapCheck )
    {
        bDoingLeapCheck = true;
        Enable('Tick');
    }

    AimingRotation = Rotation;

}

simulated function PostNetBeginPlay()
{
    local float SkinVar;

    Super.PostNetBeginPlay();

    SkinVar = FRand();

    if (SkinVar <= 0.20)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightLegs_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightArms_DefaultFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightChest_DefaultFinal';
    }
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightLegs_BlueFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightArms_BlueFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightChest_BlueFinal';
    }
    else if (SkinVar <= 0.60 && SkinVar > 0.40)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightLegs_GoldFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightArms_GoldFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightChest_GoldFinal';
    }
    else if (SkinVar <= 0.80 && SkinVar > 0.60)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightLegs_GreenFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightArms_GreenFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightChest_GreenFinal';
    }
    else
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightLegs_RedFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightArms_RedFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightChest_RedFinal';
    }
}

function LandThump()
{
    PlaySound(StepSounds[Rand(4)], SLOT_Interact);
    Super(U2Creatures).LandThump();
}

event Touch( Actor Other )
{
    if (Other != IncomingProxy && Controller != None && Other == Controller.Enemy && bDefensiveMode)
    {
        DefensiveModeEnd(true);
    }
    super.Touch(Other);
}

simulated function Destroyed()
{
    if (IncomingProxy != None)
        IncomingProxy.Destroy();
    Super.Destroyed();

}


function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('SkaarjLight') || (P.IsA('SkaarjMedium') || (P.IsA('SkaarjHeavy') ) ) ) );
}

simulated function Step()
{
    PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
    ShakeGround( VSize(Velocity) / 500 * Mass / 300 );

    if (Level.NetMode == NM_Client)
    {
        ServerStep();
    }
}

function ServerStep()
{
    if (Level.NetMode == NM_Client)
    {
        PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
        ShakeGround( VSize(Velocity) / 500 * Mass / 300 );
    }
}

simulated function ShakeGround( float ShakeScale )
{
    DoShake(
        Self,
        Location,
        MovementShakeRadius*ShakeScale,
        MovementShakeMagnitude*ShakeScale,
        MovementShakeDuration*ShakeScale );

    /*class'UtilGame'.static.MakeShake(
        Self,
        Location,
        MovementShakeRadius*ShakeScale,
        MovementShakeMagnitude*ShakeScale,
        MovementShakeDuration*ShakeScale );*/

    if (Level.NetMode == NM_Client)
    {
        ServerShakeGround(ShakeScale);
    }
}

function ServerShakeGround( float ShakeScale )
{
    if (Level.NetMode == NM_Client)
    {
        DoShake(
            Self,
            Location,
            MovementShakeRadius*ShakeScale,
            MovementShakeMagnitude*ShakeScale,
            MovementShakeDuration*ShakeScale );
    }
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Falling);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{   //U2Dodge handles dodging
    //local vector X,Y,Z,duckdir;
    return false;
    /*
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

    Controller.Destination = Location + 250 * duckDir;
    Velocity = GroundSpeed * duckDir;
    Controller.GotoState('TacticalMove', 'DoMove');
    return true;*/
}




event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Walking);
    Super.HitWall(HitNormal,HitWall);
}

function TriggerDodge( Actor Other, Pawn EventInstigator, optional name EventName )
{
    if( /*!bShotAnim &&*/ EventName == EventIncoming && Other.Owner != Self && U2SkaarjController(Controller) != None && Physics != PHYS_Falling && !IsLeaping() )
    {
        // trigger is from proxy collision - check for dodge
        U2SkaarjController(Controller).HandleIncoming( Other, Normal( Other.Velocity ), VSize( Other.Velocity ) );
    }
    /*else
    {
        Super.Trigger( Other, EventInstigator, EventName );
    }*/
}


simulated function PlayDirectionalDeath(Vector HitLoc)
{

    PlayAnim(DeathAnims[Rand(9)]);
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local name Anim;
    local float frame,rate;

    GetAnimParams(0, Anim,frame,rate);

    if ( !bShotAnim && !IsLeaping() && Anim != 'FlipFrwdSlash_Fr01_SM' || Anim != 'FlipFrwdSlash_Fr02_SM' )
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

    if ( IsLeaping() || Anim == 'FlipBack01_SM' || Anim == 'FlipFrwd01_SM' || Anim == 'FlipLeft01_SM'
        || Anim == 'FlipRight01_SM' || Anim == 'FlipFrwdSlash_Fr01_SM' || Anim == 'FlipFrwdSlash_Fr02_SM' )
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
                PlayAnim('HitGut01_LG',, 0.1);
        }
        else if ( Dir Dot X < -0.7 )
        {
            PlayAnim('HitHead01_LG',, 0.1);
        }
        else if ( Dir Dot Y > 0 )
        {
            PlayAnim('HitLeft01_LG',, 0.1);
        }
        else
    {
            PlayAnim('HitRight01_LG',, 0.1);
    }
}

/*simulated function TickOld(float DeltaTime)
{
    local float dist, randNum;

    if (Level.TimeSeconds - LastLeapCheckTime < 0.25 || (Controller != None && U2MonsterController(Controller) != None && U2MonsterController(Controller).bLeaping))
        return;
    LastLeapCheckTime = Level.TimeSeconds;
    //log("LastLeapCheckTime:"$LastLeapCheckTime);
    if (Controller != None && U2MonsterController(Controller) != None && Controller.Enemy != None)
    {
        dist = VSize(Controller.Enemy.Location - Location);

        if (EnemyInLeapRange(dist) && (Level.TimeSeconds - LastLeapTime >= MinLeapRefireDelay) )
        {
            //log("Dist:"@Dist@"EnemyInLeapRange:"@EnemyInLeapRange(dist));
            //U2MonsterController(Controller).GotoState( 'AttackLeapState' );
            randNum = FRand();
            if ( randNum <= LeapOdds && !bShotAnim /*&& !bDefensiveMode*/ && Physics != PHYS_Swimming && Physics != PHYS_Falling && (IsFacingTarget(Controller.Enemy, CosMinDefensiveModeAngle) || (VSize(Controller.Enemy.Location - Controller.FocalPoint) < 150)) )
            {
                //U2MonsterController(Controller).GotoState( 'AttackLeapState' );
                //log("RandNum:"$randNum);
                //bRotateToDesired = false;
                Acceleration = vect(0,0,0);
                bLunging = true;
                bShotAnim = true;
                if (randNum < 0.165)
                    SetAnimAction('FlipFrwdSlash_Fr02_SM');
                else
                    SetAnimAction('FlipFrwdSlash_Fr01_SM');
            }

            /*if (U2MonsterController(Controller) != None && !U2MonsterController(Controller).IsInState('AttackLeapState'))
            {
                U2MonsterController(Controller).EnemyInLeapRange(dist);
            }*/
        }
    }
}*/

simulated function Tick(float DeltaTime)
{
    local float dist;

    //if (Controller != None && Controller.Enemy != None && !bDoingLeapCheck)

    if (!bDoingLeapCheck || IsLeaping() || Level.TimeSeconds - LastLeapCheckTime < 0.25 )
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

function PlayLeapAnim()
{
    local float randNum;

    if (randNum < 0.5)
        SetAnimAction('FlipFrwdSlash_Fr02_SM');
    else
        SetAnimAction('FlipFrwdSlash_Fr01_SM');
    bShotAnim = true;
}

function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(TauntSounds[Rand(5)],SLOT_Talk);
    SetAnimAction('Snarl');
    PlayAnim(VictoryAnims[Rand(14)]);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}



function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + CollisionRadius * ( X + 1.0 * Y  * Z );
}



function SpinDamageTarget()
{
    if (MeleeDamageTarget(SpinDamage, (SpinDamage * 1000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(slice, SLOT_Interact);
}

function ClawDamageTarget()
{
    if ( MeleeDamageTarget(ClawDamage, (ClawDamage * 900 * Normal(Controller.Target.Location - Location))) )
        PlaySound(claw, SLOT_Interact);
}

function StabDamageTarget()
{
    if ( MeleeDamageTarget(StabDamage, (StabDamage * 800 * Normal(Controller.Target.Location - Location))) )
        PlaySound(slice, SLOT_Interact);
}

function HeadbuttDamageTarget()
{
    if ( MeleeDamageTarget(HeadbuttDamage, (HeadbuttDamage * 1000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(headbutt, SLOT_Interact);
}

function LungeDamageTarget()
{
    if ( MeleeDamageTarget(LungeDamage, (LungeDamage * 1200 * Normal(Controller.Target.Location - Location))) )
        PlaySound(slice, SLOT_Interact);
}

function RangedAttack(Actor A)
{
    local float Dist;
    local name Anim;
    local float frame,rate;

    Dist = VSize(A.Location - Location);

    //log("want to do ranged attack");
    if ( bShotAnim || IsLeaping() || Controller.Enemy == None || bDefensiveMode)
        return;

    /*if (bDefensiveMode)
    {
        U2SkaarjController(Controller).DoCharge();
        return;
    }*/

    if (Controller != None && Controller.Enemy != None && LeapOdds > 0 && !bDoingLeapCheck) //Tick handles leaping
    {
        bDoingLeapCheck = true;
        Enable('Tick');
    }

    GetAnimParams(0,Anim,frame,rate);

    if (Anim == 'FlipFrwdSlash_Fr01_SM' || Anim == 'FlipFrwdSlash_Fr02_SM' || Anim == 'FlipFrwdSlash_Fr03_SM')
        return;

    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming)
    {
        if (bDefensiveMode) DefensiveModeEnd(true);
        //log("Play melee?");
        SetAnimAction(ClawAnims[Rand(10)]);
        PlaySound(MeleeSounds[Rand(4)], SLOT_Talk);
        bShotAnim = true;
        return;
    }
    else if ( /*(VSize(Velocity) <= 100) &&*/ /*FRand() > 0.40 &&*/ (Dist > MeleeRange + CollisionRadius + A.CollisionRadius) && IsFacingTarget( /*Instigator*/Controller.Enemy, CosMinDefensiveModeAngle ))
    {
        SetAnimAction(FireAnims[Rand(6)]);
        bShotAnim = true;
        return;
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        bShotAnim = true;
        if (Anim == MovementAnims[2])
            SetAnimAction('RunLeft_Fr01_SM');
        else if (Anim == MovementAnims[3])
            SetAnimAction('RunRight_Fr01_SM');
        else if (Anim == MovementAnims[0] && Frand() >= 0.45)//0.25//0.55
            SetAnimAction('RunFrwd05_SM');
        else
        {
            if (Anim == MovementAnims[0] && Frand() < 0.45)//0.25//0.55
                SetAnimAction('RunFrwd03_SM');
            bShotAnim = false;
            MonsterController(Controller).DoCharge();
            return;
        }
        //bShotAnim = true;
        return;
    }
    /*else if (!IsFacingTarget( Controller.Enemy, CosMinDefensiveModeAngle ))
    {
        bShotAnim = false;
        MonsterController(Controller).DoCharge();
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        bShotAnim = true;
        if (Anim == MovementAnims[2])
            SetAnimAction('RunLeft_Fr01_SM');
        else if (Anim == MovementAnims[3])
            SetAnimAction('RunRight_Fr01_SM');
        else if (Anim == MovementAnims[0] && Frand() >= 0.45)//0.25//0.55
            SetAnimAction('RunFrwd05_SM');
        else
        {
            if (Anim == MovementAnims[0] && Frand() < 0.45)//0.25//0.55
                SetAnimAction('RunFrwd03_SM');
            bShotAnim = false;
            MonsterController(Controller).DoCharge();
            return;
        }
        //bShotAnim = true;
        return;
    }*/

}

function StartLeapOld()
{
    local vector EnemyLocation;
    local rotator LeapRotation;
    local actor A;
    local float dist;
    local name Anim;
    local float frame,rate;

    GetAnimParams(0,Anim,frame,rate);

    Enable('Bump');
    if (Controller != None && Controller.Enemy != None)
    {
        A = Controller.Enemy;
        EnemyLocation = A.Location;
        EnemyLocation.Z += (CollisionHeight - A.CollisionHeight);
        dist = VSize(EnemyLocation - Location);
        LeapRotation = rotator(EnemyLocation - Location);

        Velocity = LeapLowSpeed * vector(LeapRotation);
        if ( dist > CollisionRadius + A.CollisionRadius )
            Velocity.Z += 0.6 * dist;//0.7
        //SetPhysics(PHYS_Falling);
        bShotAnim = true;
        LastLeapTime = Level.TimeSeconds;
        PlaySound(Sound'tk_U2Creatures.SkaarjA_Leap.Flip', SLOT_Interact);
    }
    SetPhysics(PHYS_Falling);
    //Controller.bPreparingMove = true;
}

function StartLeapSmall()
{
    StartLeap();//holdover from old system
}



simulated event SetAnimAction(name NewAction)
{
    //local rotator newRot;

    //SetBoneRotation(FireRootBone,,,0);
//log("1");
    if (!bWaitForAnim)
    {
//log("2");
    AnimAction = NewAction;
    if ( AnimAction == 'Weapon_Switch' )
        {//log("3");
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(NewAction,, 0.0, 1);
        }
    else if ( AnimAction == 'Snarl' )
    {
        AnimBlendParams(1, 1.0, 0.0, 0.2, HeadBone);
                PlayAnim(NewAction,, 0.0, 1);
    }
    else if ( AnimAction == 'Blink' )
    {
        AnimBlendParams(1, 1.0, 0.0, 0.2, 'EyesLower');
                PlayAnim(NewAction,, 0.0, 1);
        AnimBlendParams(1, 1.0, 0.0, 0.2, 'EyesUpper');
                PlayAnim(NewAction,, 0.0, 1);
    }
    else if ( AnimAction == 'FlipFrwdSlash_Fr01_SM' || AnimAction == 'FlipFrwdSlash_Fr02_SM' || AnimAction == 'FlipFrwdSlash_Fr03_SM' )
    {
        AnimBlendParams(1, 1.0, 0.0, 0.2, RootBone);
                PlayAnim(NewAction,, 0.0, 1);
    }
    /*else if (Velocity != vect(0,0,0) && !bIsWalking && (AnimAction == FireAnims[0] || AnimAction == FireAnims[1] || AnimAction == FireAnims[2] || AnimAction == FireAnims[3] || AnimAction == FireAnims[4] || AnimAction == FireAnims[5] || AnimAction == FireAnims[6] || AnimAction == FireAnims[7]) )
    {
        newRot = rot(0,-4800,0);//GetBoneRotation(FireRootBone);
        //log("newRot:"$newRot);
        //newRot.Roll -= 4800;
        AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);//1st was 1
                PlayAnim(NewAction,, 0.1, 1);
                FireState = FS_Ready;
        SetBoneRotation(FireRootBone, newRot);
    }*/
        else if (((Physics == PHYS_None)|| ((Level.Game != None) && Level.Game.IsInState('MatchOver')))
                && (DrivenVehicle == None) )
        {//log("4");
            PlayAnim(AnimAction,,0.1);
            AnimBlendToAlpha(1,0.0,0.05);
        }
        else if ( (DrivenVehicle != None) || (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
        {//log("5");
            if ( CheckTauntValid(AnimAction) )
            {
                if (FireState == FS_None || FireState == FS_Ready)
                {
                    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                    PlayAnim(NewAction,, 0.1, 1);
                    FireState = FS_Ready;
                }
            }
            else if ( PlayAnim(AnimAction) )
            {
                if ( Physics != PHYS_None )
                    bWaitForAnim = true;
            }
            else
                AnimAction = '';
        }
        else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
        {//log("6");
            PlayAnim(AnimAction,,0.1);
            AnimBlendToAlpha(1,0.0,0.05);
        }
        else // running taunt
        {
//log("7");
            if (FireState == FS_None || FireState == FS_Ready)
            {
                AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);//1st was 1
                PlayAnim(NewAction,, 0.1, 1);
                FireState = FS_Ready;
            }
        }
    }
}


simulated function AnimEnd(int Channel)
{

    AnimAction = '';
    if (FRand() < 0.5)
        SetAnimAction('Blink');
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

    AirAnims[0] = Default.AirAnims[0];
    Super(XPawn).AnimEnd(Channel);
}

function PlayChallengeSound()
{
    //log("PlayChallengeSound");
    Super.PlayChallengeSound();
    SetAnimAction('Snarl');
}

/*singular function Bump(actor Other)
{
    //local name Anim;
    //local float frame,rate;

    log("bShotAnim:"@bShotAnim@"bLunging:"@bLunging);
    if ( /*bShotAnim &&*/ bLunging )
    {
        AirAnims[0] = Default.AirAnims[0];
        bLunging = false;
        bShotAnim = false;
        bRotateToDesired = Default.bRotateToDesired;
        LungeDamageTarget();
    }
    Super.Bump(Other);
}*/
//


function SpawnLeftShot()
{


    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local name LeftHand;

    LeftHand = 'Bip01 L Hand';

    //bLeftShot = true;

    GetAxes(Rotation,X,Y,Z);

        FireStart = GetBoneCoords(LeftHand).Origin;

    //MyAmmo.ProjectileClass = class'U2SkaarjProjectile';
       // MyAmmo.Class=Default.AmmunitionClass;

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    PlaySound(FireSound,SLOT_Interact);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,Self,,FireStart,FireRotation);

}

function SpawnRightShot()
{


    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local name RightHand;


    RightHand = 'Bip01 R Hand';

    //bLeftShot = false;
    GetAxes(Rotation,X,Y,Z);

    FireStart = GetBoneCoords(RightHand).Origin;
     //   MyAmmo.ProjectileClass = MyAmmo.Default.ProjectileClass;
     //   MyAmmo.Class=Default.AmmunitionClass;
    MyAmmo.bLeadTarget = MyAmmo.Default.bLeadTarget;

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    PlaySound(FireSound,SLOT_Interact);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,Self,,FireStart,FireRotation);


}

function SpawnTwoShots()
{
    //FireProj(vect(1.1,0,0.4));
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local name LeftHand, RightHand;

    LeftHand = 'Bip01 L Hand';
    RightHand = 'Bip01 R Hand';

    //bLeftShot = false;
    GetAxes(Rotation,X,Y,Z);
    //FireStart = (vect(1.1,0,0.4));
    FireStart = GetBoneCoords(LeftHand).Origin;
    MyAmmo.bLeadTarget = MyAmmo.Default.bLeadTarget;
  //      MyAmmo.ProjectileClass = MyAmmo.Default.ProjectileClass;
   //     MyAmmo.Class=Default.AmmunitionClass;

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    PlaySound(FireSound,SLOT_Interact);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,Self,,FireStart,FireRotation);

    //bLeftShot = true;

    GetAxes(Rotation,X,Y,Z);
    //FireStart = (vect(1.1,0,0.4));
    FireStart = GetBoneCoords(RightHand).Origin;

    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,Self,,FireStart,FireRotation);
}



function SpawnBigShot()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local U2SkaarjProjectileHeavySeeking S;

    //RightHand = 'Skaarj R Hand';


    GetAxes(Rotation,X,Y,Z);

    FireStart = GetFireStart(X,Y,Z);
 //       MyAmmo.ProjectileClass = class'U2SkaarjProjectileHeavySeeking';
    MyAmmo.bLeadTarget = false;

//  AmmunitionClass=class'SkaarjHeavyAmmoSeeking';

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    PlaySound(FireSound,SLOT_Interact);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    /*if ( bSeekingDir )
        FireRotation.Yaw += 3072;
    else
        FireRotation.Yaw -= 3072;*/
    bSeekingDir = !bSeekingDir;
    S = Spawn(class'U2SkaarjProjectileHeavySeeking',,,FireStart,FireRotation);
    S.Seeking = Controller.Enemy;
    //Spawn(MyAmmo.ProjectileClass,Self,,FireStart,FireRotation);
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

//-----------------------------------------------------------------------------
function DefendLeft()//new - wasn't simulated
{
    ReflectNotify( 'defendleft' );
}



function DefendRight()//new - wasn't simulated
{
    ReflectNotify( 'defendright' );

}

simulated function vector GetGloveLocation( bool bLeft )//new - wasn't simulated
{
    if( bLeft )
        return GetLeftGloveLocation();
    else
        return GetRightGloveLocation();
}

simulated function vector GetLeftGloveLocation()//new - wasn't simulated
{
    return GetBoneCoords('LeftClaw').Origin;//leftglove
}

simulated function vector GetRightGloveLocation()//new - wasn't simulated
{
    return GetBoneCoords('RightClaw').Origin;
}

simulated function name GetGloveName( bool bLeft )//new - wasn't simulated
{
    if( bLeft )
        return 'LeftClaw';
    else
        return 'RightClaw';
}

function bool IsFacingTarget( Actor Target, float CosMinFacingAngle )
{
    local vector TargetVector, PawnRotationVector;
    local float CosAngle;

    if( Target == None )
        return false;

    // 2D test
    TargetVector = Target.Location - Location;
    TargetVector.Z = 0;
    PawnRotationVector = vector(Rotation);
    PawnRotationVector.Z = 0;
    CosAngle = Normal( TargetVector ) dot PawnRotationVector;


    return ( CosAngle >= CosMinFacingAngle );
}



function TakeDamage( int Damage, Pawn Instigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
    local bool bFilterDamage;
    local name Anim;
    local float frame,rate;
    local float Dist;

    GetAnimParams(0, Anim,frame,rate);
    Dist = VSize(Instigator.Location - Location);
    //log("dist:"$dist);
    if ( !IsLeaping() &&
        Dist <= MeleeRange + CollisionRadius + Instigator.CollisionRadius &&
        Instigator != Self &&
        Anim != 'FlipFrwdSlash_Fr01_SM' &&
        Anim != 'FlipFrwdSlash_Fr02_SM')
    {
        //DefensiveModeEnd(true);
        bShotAnim = false;
        //RangedAttack(Instigator);
        //Controller.GoToState('Charging');
    }
    if( CanDefend() &&
        Health > 0 &&
        DefensiveModeDamage( Damage, Instigator, HitLocation, Momentum, DamageType ) &&
        Instigator != None &&
        IsFacingTarget( Instigator, CosMinDefensiveModeAngle ) &&
        !IsLeaping() &&
        Anim != 'FlipFrwdSlash_Fr01_SM' &&
        Anim != 'FlipFrwdSlash_Fr02_SM')
    {
        //DMTNS( "eventTakeDamage: " $ bDefensiveMode );

        if( bDefensiveMode || (Level.TimeSeconds - LastDefensiveHitTime) < 1.0 )
        {
            LastDefensiveHitTime = Level.TimeSeconds;
            bFilterDamage = true;
            if( !bDefensiveMode )
            {
                // not using defend animation yet so spawn sparks "manually"
                HandleDeflection( FRand() < 0.5 );
            }
        }
        DefensiveModeBegin(); // reset timer, make sure crouching etc.
    }

    if( !bFilterDamage /*|| Dist < MeleeRange + CollisionRadius + Instigator.CollisionRadius*/ /*|| Anim != 'WalkFrwdDefend_SM'*/ )
    {
        Super.TakeDamage( Damage, Instigator, HitLocation, Momentum, DamageType );
    }
}

function bool DefensiveModeDamage( int Damage, Pawn Instigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
    //return ClassIsChildOf( DamageType, class'DamageTypePhysicalInstant' );
    //return ClassIsChildOf( DamageType, class'DamTypeAssaultBullet' );
    return DamageType.Default.bBulletHit;
    /*tbd:
    return( ClassIsChildOf( DamageType, class'DamageTypePhysicalInstant' ) ||
            //tbd:ClassIsChildOf( DamageType, class'DamageTypeTakkra' ) ||
            ClassIsChildOf( DamageType, class'DamageTypeSniperRifle' ) );
    */
}

function DefensiveModeBegin() //new - wasn't simulated
{
    //AddTimer( DefensiveModeTimerName, MinDefensiveModeDuration, false );
    Enable('Timer');
    SetTimer(MinDefensiveModeDuration, false);//new - provide alternative
    if( !bDefensiveMode )
    {
        //U2P.SetStance( ST_Crouching );
        //DMTNS( "setting special param: " $ DefendingSpecialParamName );
        //U2P.AnimationController.SetSpecialParamAnim( DefendingSpecialParamName );
        //U2P.TacticalMoveType = TMT_None;
        ShouldCrouch(true);
        bWantsToCrouch = true;
        //bShotAnim = false;
        /*CrouchAnims[0]='WalkFrwdDefend_SM';
        CrouchAnims[1]='WalkFrwdDefend_SM';
        CrouchAnims[2]='WalkFrwdDefend_SM';
        CrouchAnims[3]='WalkFrwdDefend_SM';
        IdleCrouchAnim='WalkFrwdDefend_SM';
        CrouchTurnRightAnim='WalkFrwdDefend_SM';
        CrouchTurnLeftAnim='WalkFrwdDefend_SM';*/
        //SetAnimAction('WalkFrwdDefend_SM');
        bDefensiveMode = true;
        bCanCrouch = true;
        U2SkaarjController(Controller).DoCharge();
        //RemoveTimer( 'TauntTimer' );

    }
}

function DefensiveModeEnd( bool bCanTaunt )//new - wasn't simulated
{
    //if( bDefensiveMode )
    //{
        //U2P.SetStance( ST_Standing );
        //DMTNS( "clearing special param: " $ DefendingSpecialParamName );
        //U2P.AnimationController.SetSpecialParamAnim( '' );
        //U2P.TacticalMoveType = U2P.default.TacticalMoveType;
        /*CrouchAnims[0]=Default.CrouchAnims[0];
        CrouchAnims[1]=Default.CrouchAnims[1];
        CrouchAnims[2]=Default.CrouchAnims[2];
        CrouchAnims[3]=Default.CrouchAnims[3];
        IdleCrouchAnim=Default.IdleCrouchAnim;
        CrouchTurnRightAnim=Default.CrouchTurnRightAnim;
            CrouchTurnLeftAnim=Default.CrouchTurnLeftAnim;*/
        bDefensiveMode = false;
        ShouldCrouch(false);
        bWantsToCrouch = false;
        bCanCrouch = false;
        //bShotAnim = false;

        if (Level.TimeSeconds - LastTauntTime > 3 &&
            bCanTaunt &&
            Health >= 0.25*Default.Health &&
            FRand() < 0.5)
        {
            LastTauntTime = Level.TimeSeconds;
            PlaySound(TauntSounds[Rand(5)],SLOT_Talk);
            SetAnimAction('Snarl');
        }

    //}
}




function HandleDeflection( bool bLeft )
{
    local vector EffectLocation;
    //local xEmitter DefensiveParticles;

    //DMTNS( "HandleDeflection" );
    EffectLocation = GetGloveLocation( bLeft );

    if( DefensiveParticles == None )
    {
        //DefensiveParticles = class'ParticleGenerator'.static.CreateNew( Self, DefensiveEffect, EffectLocation );
        //DefensiveParticles.Trigger( Self, Instigator );
        //DefensiveParticles.ParticleLifeSpan = DefensiveParticles.GetMaxLifeSpan() + DefensiveParticles.TimerDuration;
        DefensiveParticles = spawn(DefensiveEffect,self,,EffectLocation,);
        AttachToBone(DefensiveParticles, GetGloveName(bLeft));
        //log("DefensiveParticles");
    }

    // play deflection sound
    PlayDeflectionSound();

    // sometimes play ricochet sound
    if( FRand() < 0.50 )
        PlayRicochetSound();
}

function PlayDeflectionSound()
{
    PlaySound( Sound(DynamicLoadObject( DefensiveSounds[ Rand( DefensiveSounds.Length ) ], class'Sound' )), SLOT_Interact, 24 );
}

function PlayRicochetSound()
{
    PlaySound( Sound(DynamicLoadObject( DefensiveRicochetSounds[ Rand( DefensiveRicochetSounds.Length ) ], class'Sound' )), SLOT_Interact, 24 );
}

function ReflectNotify( name NotifyName )//new - wasn't simulated
{
    //DMTNS( "ReflectNotify: " $ NotifyName );
    //log("ReflectNotify: NotifyName: "$NotifyName);
    if( NotifyName == DefendLeftNotify && (Level.TimeSeconds - LastDefensiveHitTime) < 0.1 )
        HandleDeflection( true );
    else if( NotifyName == DefendRightNotify && (Level.TimeSeconds - LastDefensiveHitTime) < 0.1 )
        HandleDeflection( false );
}

function bool CanDefend()
{
    local name Anim;
    local float frame,rate;

    GetAnimParams(0, Anim, frame, rate);

    return bCanDefend && Anim != 'FlipFrwdSlash_Fr01_SM' && Anim != 'FlipFrwdSlash_Fr02_SM';
}

function Timer()
{
    DefensiveModeEnd( true );
}

function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{

    if (bDefensiveMode)//prevents animation screwups when in defensive mode, hopefully
            return False;

    return Super.IsHeadShot(loc, ray, AdditionalScale);

}

function SetAmbientSoundIndex()
{
    if( AmbientSoundStrings.Length >= 1 )
        AmbientSoundIndex = Rand( AmbientSoundStrings.Length );
}

//-----------------------------------------------------------------------------

function SetAmbientSound()
{
    if( AmbientSoundIndex >= 0 )
        AmbientSound = Sound(DynamicLoadObject( AmbientSoundStrings[ AmbientSoundIndex ], class'Sound' ));
}


/*
     LandAnims(0)="LandFrwd01_SS"
     LandAnims(1)="LandBack01_SS"
     LandAnims(2)="LandLeft_SS"
     LandAnims(3)="LandRight_SS"
     LandAnims(0)="Land01_SM"
     LandAnims(1)="Land01_LG"
     LandAnims(2)="Land_Fr01_SS"
     LandAnims(3)="Land01_LG"
*/
/*
     MovementAnims(0)="RunFrwd04_SM"//was 04
     MovementAnims(1)="RunBack_Fr01_SM"
     MovementAnims(2)="RunLeft01_SM"
     MovementAnims(3)="RunRight01_SM"
*/
/*
    DefensiveSounds(0)="XEffects.Impact1"
    DefensiveSounds(1)="XEffects.Impact2"
    DefensiveSounds(2)="XEffects.Impact2snd"
    DefensiveSounds(3)="XEffects.Impact3"
    DefensiveRicochetSounds(0)="XEffects.Impact2"
    DefensiveRicochetSounds(1)="XEffects.Impact3snd"
*/
/*
    BonePitch="Bip01 Neck"
    BoneYaw="Bip01 Spine2"//Head
    BoneYaw2="Bip01 Head"
*/
/*
    Seemed to be working okay with this setup:
    BonePitch="Bip01 Spine1"
    BoneYaw="Bip01 Spine2"//Head
    BoneYaw2="Bip01 Head"
*/
//  MinDefensiveModeDuration=0.250000

defaultproperties
{
     LungeDamage=25
     SpinDamage=20
     ClawDamage=15
     StabDamage=25
     KickDamage=15
     HeadButtDamage=18
     Claw=Sound'tk_U2Creatures.SkaarjA_MeleeDamage.ClawHit2'
     slice=Sound'tk_U2Creatures.SkaarjA_MeleeDamage.ClawHit1'
     headbutt=Sound'SkaarjPack_rc.Gasbag.hit1g'
     ClawAnims(0)="StillSlashLH_Fr01_SM"
     ClawAnims(1)="StillSlashLH_Fr02_SM"
     ClawAnims(2)="StillSlashRH_Fr01_SM"
     ClawAnims(3)="StillSlashRH_Fr02_SM"
     ClawAnims(4)="StillSpinSlash_Fr01_SM"
     ClawAnims(5)="StillStab_Fr01_SM"
     ClawAnims(6)="StillSlashBH_Fr01_SM"
     ClawAnims(7)="StillSlashBH_Fr02_SM"
     ClawAnims(8)="StillSlashLH_Fr01_SM"
     ClawAnims(9)="RunFrwd_HeadButt01_SM"
     DeathAnims(0)="DeathBackFlipF01"
     DeathAnims(1)="DeathBlownUpB01"
     DeathAnims(2)="DeathDieSitting01"
     DeathAnims(3)="DeathFoldF01"
     DeathAnims(4)="DeathHeadShotF01"
     DeathAnims(5)="DeathMidHitB01"
     DeathAnims(6)="DeathRiddledF01"
     DeathAnims(7)="DeathSpinF01"
     DeathAnims(8)="DeathStruggleB01"
     VictoryAnims(0)="Taunt01_LG"
     VictoryAnims(1)="Taunt01_SM"
     VictoryAnims(2)="Taunt02_LG"
     VictoryAnims(3)="Taunt02_SM"
     VictoryAnims(4)="Thrust01_LG"
     VictoryAnims(5)="Thrust01_SM"
     VictoryAnims(6)="Victory01_LG"
     VictoryAnims(7)="Victory01_SM"
     VictoryAnims(8)="Victory02_LG"
     VictoryAnims(9)="Victory02_SM"
     VictoryAnims(10)="Victory03_LG"
     VictoryAnims(11)="Victory03_SM"
     VictoryAnims(12)="Victory05_LG"
     VictoryAnims(13)="Victory05_SM"
     FireAnims(0)="StillBH_Fr01_SM"
     FireAnims(1)="StillBH_Fr02_SM"
     FireAnims(2)="StillLH_Fr01_SM"
     FireAnims(3)="StillLH_Fr02_SM"
     FireAnims(4)="StillRH_Fr01_SM"
     FireAnims(5)="StillRH_Fr02_SM"
     WalkSlashAnims(0)="WalkSlashL_SM"
     WalkSlashAnims(1)="WalkSlashR_SM"
     MeleeSounds(0)=Sound'tk_U2Creatures.SkaarjA_Misc.MeleeAttack1'
     MeleeSounds(1)=Sound'tk_U2Creatures.SkaarjA_Misc.MeleeAttack2'
     MeleeSounds(2)=Sound'tk_U2Creatures.SkaarjA_Misc.MeleeAttack3'
     MeleeSounds(3)=Sound'tk_U2Creatures.SkaarjA_Misc.MeleeAttack4'
     TauntSounds(0)=Sound'tk_U2Creatures.SkaarjA_KillsTaunts.Taunt1'
     TauntSounds(1)=Sound'tk_U2Creatures.SkaarjA_KillsTaunts.Taunt2'
     TauntSounds(2)=Sound'tk_U2Creatures.SkaarjA_KillsTaunts.Taunt3'
     TauntSounds(3)=Sound'tk_U2Creatures.SkaarjA_KillsTaunts.Taunt4'
     TauntSounds(4)=Sound'tk_U2Creatures.SkaarjA_KillsTaunts.Taunt5'
     MinDefensiveModeDuration=2.130000
     MovementShakeRadius=1024.000000
     MovementShakeMagnitude=8.000000
     MovementShakeDuration=0.400000
     DodgeProjectileOdds=1.000000
     DefensiveSounds(0)="tk_U2Creatures.WeaponsA_BulletImpacts.BulletMetal01"
     DefensiveSounds(1)="tk_U2Creatures.WeaponsA_BulletImpacts.BulletMetal02"
     DefensiveSounds(2)="tk_U2Creatures.WeaponsA_BulletImpacts.BulletMetal03"
     DefensiveSounds(3)="tk_U2Creatures.WeaponsA_BulletImpacts.BulletMetal04"
     DefensiveRicochetSounds(0)="tk_U2Creatures.WeaponsA_BulletImpacts.RicMetal01"
     DefensiveRicochetSounds(1)="tk_U2Creatures.WeaponsA_BulletImpacts.RicMetal09"
     DefensiveRicochetSounds(2)="tk_U2Creatures.WeaponsA_BulletImpacts.RicMetal13"
     DefensiveRicochetSounds(3)="tk_U2Creatures.WeaponsA_BulletImpacts.RicMetal14"
     DefensiveEffect=Class'tk_U2Creatures.SkaarjSparks'
     bCanDefend=True
     ProxyRadius=256.000000
     ProxyHeight=128.000000
     AmbientSoundStrings(0)="tk_U2Creatures.SkaarjA_Misc.Ambient1"
     AmbientSoundStrings(1)="tk_U2Creatures.SkaarjA_Misc.Ambient2"
     AmbientSoundStrings(2)="tk_U2Creatures.SkaarjA_Misc.Ambient3"
     AmbientSoundStrings(3)="tk_U2Creatures.SkaarjA_Misc.Ambient4"
     LandShakeRadius=512.000000
     LandShakeMagnitude=8.000000
     LandShakeDuration=0.400000
     DodgeJumpZScale=0.500000
     LeapMinRange=256.000000
     LeapMaxRange=512.000000
     LeapOdds=0.330000
     bTurnToEnemyAfterLeap=True
     LeapLowSpeed=1024.000000
     LeapToMeleeOdds=1.000000
     LeapDelayFailure=0.500000
     LeapDelayLand=0.500000
     LeapDelayPreJump=0.000000
     LeapDelaySuccess=2.000000
     LeapMaxDamage=25
     LeapMaxMomentumTransfer=40000.000000
     MinLeapRefireDelay=4.000000
     CollisionTesterClass=Class'tk_U2Creatures.CollisionTesterSkaarjLight'
     BonePitch="Bip01 Spine1"
     BoneYaw="bip01 Spine2"
     BoneYaw2="Bip01 Head"
     bHeadTrackingEnabled=True
     bTryToWalk=True
     DodgeSkillAdjust=3.000000
     HitSound(0)=Sound'tk_U2Creatures.SkaarjA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.SkaarjA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.SkaarjA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.SkaarjA_HitSoft.Hit4'
     DeathSound(0)=Sound'tk_U2Creatures.SkaarjA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.SkaarjA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.SkaarjA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.SkaarjA_DieSoft.DieSoft1'
     ChallengeSound(0)=Sound'tk_U2Creatures.SkaarjA_Acquire.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.SkaarjA_Acquire.SeeEnemy2'
     ChallengeSound(2)=Sound'tk_U2Creatures.SkaarjA_Acquire.SeeEnemy3'
     ChallengeSound(3)=Sound'tk_U2Creatures.SkaarjA_Misc.IdleChat3'
     FireSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_LightFire'
     AmmunitionClass=Class'tk_U2Creatures.SkaarjLightAmmo'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_SkaarjLight'
     GibGroupClass=Class'tk_U2Creatures.SkaarjGibGroup'
     WallDodgeAnims(0)="DodgeFrwd_Fr01_SM"
     WallDodgeAnims(1)="DodgeBack_Fr01_SM"
     WallDodgeAnims(2)="DodgeLeft_Fr01_SM"
     WallDodgeAnims(3)="DodgeRight_Fr01_SM"
     IdleHeavyAnim="IdleWaitBreath01_LG"
     IdleRifleAnim="IdleWaitBreath02_LG"
     FireHeavyRapidAnim="Still_FrRp01_LG"
     FireHeavyBurstAnim="Still_Fr01_LG"
     FireRifleRapidAnim="Still_FrRp01_SM"
     FireRifleBurstAnim="Still_Fr01_LG"
     FireRootBone="Bip01 Spine1"
     bCanStrafe=False
     bCanDoubleJump=False
     MeleeRange=60.000000
     GroundSpeed=450.000000
     AirSpeed=250.000000
     WalkingPct=0.194000
     Health=150
     SoundDampening=0.450000
     ControllerClass=Class'tk_U2Creatures.U2SkaarjController'
     MovementAnims(0)="RunFrwd04_SM"
     MovementAnims(1)="RunBack_Fr01_SM"
     MovementAnims(2)="RunLeft01_SM"
     MovementAnims(3)="RunRight01_SM"
     TurnLeftAnim="TurnLeft_Fr01_SM"
     TurnRightAnim="TurnRight_Fr01_SM"
     SwimAnims(0)="Swim01_SM"
     SwimAnims(1)="Swim01_SM"
     SwimAnims(2)="Swim01_SM"
     SwimAnims(3)="Swim01_SM"
     CrouchAnims(0)="WalkFrwdDefend_SM"
     CrouchAnims(1)="WalkFrwdDefend_SM"
     CrouchAnims(2)="WalkFrwdDefend_SM"
     CrouchAnims(3)="WalkFrwdDefend_SM"
     WalkAnims(0)="WalkFrwd01_SM"
     WalkAnims(1)="WalkFrwd02_SM"
     WalkAnims(2)="WalkFrwd02_SM"
     WalkAnims(3)="WalkFrwd02_SM"
     AirAnims(0)="FallFar_Fr01_LG"
     AirAnims(1)="FallFar_Fr01_SM"
     AirAnims(2)="FallFar_Fr01_LG"
     AirAnims(3)="FallFar_Fr01_SM"
     TakeoffAnims(0)="JumpStartFrwd01_SS"
     TakeoffAnims(1)="JumpStartBack01_SS"
     TakeoffAnims(2)="JumpStartLeft01_SS"
     TakeoffAnims(3)="JumpStartRight01_SS"
     LandAnims(0)="LandFrwd01_SS"
     LandAnims(1)="LandBack01_SS"
     LandAnims(2)="LandLeft_SS"
     LandAnims(3)="LandRight_SS"
     DoubleJumpAnims(0)="JumpStartFrwd01_SS"
     DoubleJumpAnims(1)="JumpStartBack01_SS"
     DoubleJumpAnims(2)="JumpStartLeft01_SS"
     DoubleJumpAnims(3)="JumpStartRight01_SS"
     DodgeAnims(0)="FlipFrwd01_SM"
     DodgeAnims(1)="FlipBack01_SM"
     DodgeAnims(2)="FlipLeft01_SM"
     DodgeAnims(3)="FlipRight01_SM"
     AirStillAnim="JumpNone01_SS"
     TakeoffStillAnim="JumpNone01_SS"
     CrouchTurnRightAnim="WalkFrwdDefend_SM"
     CrouchTurnLeftAnim="WalkFrwdDefend_SM"
     IdleCrouchAnim="WalkFrwdDefend_SM"
     IdleSwimAnim="Tread01_SM"
     IdleWeaponAnim="IdleWaitBreath01_SM"
     IdleRestAnim="IdleChat02_SM"
     IdleChatAnim="IdleChat01_SM"
     AmbientSound=Sound'tk_U2Creatures.SkaarjA_Misc.Ambient1'
     Mesh=SkeletalMesh'tk_U2Creatures.SkaarjLight'
     DrawScale=0.700000
     PrePivot=(Z=-4.000000)
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightHair_AllFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightLegs_DefaultFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightArms_DefaultFinal'
     Skins(3)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjLightChest_DefaultFinal'
     TransientSoundVolume=2.000000
     CollisionRadius=28.000000
     CollisionHeight=65.000000
     Mass=200.000000
     RotationRate=(Yaw=15000)
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
