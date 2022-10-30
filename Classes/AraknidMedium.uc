class AraknidMedium extends AraknidLight;

var(Combat) int ClawDamage;
var bool bStomped;
var bool bThrowed;
var int ThrowCount;
var(Combat) name StompEvent;
var(Combat) Sound StompSound;
var(Combat) bool bCanStomp;


var(Combat) sound MeleeSounds[6];
var(Combat) sound StepSounds[4];
var(Combat) sound LandSounds[6];
var(Combat) sound LandThumpSound;
var(Combat) sound LeapImpactSounds[2];



function PostBeginPlay()
{
    Super.PostBeginPlay();

    //Tick handles leaping - U2 normally uses a built-in event to check every 0.25 seconds
    if (LeapOdds > 0)
        Enable('Tick');

}




simulated function Step()
{
    Super(U2Creatures).Step();
    PlaySound(StepSounds[Rand(2)], SLOT_Interact);

    if (Level.NetMode == NM_Client)
        ServerStep();
}

function ServerStep()
{
    if (Level.NetMode == NM_Client)
        PlaySound(StepSounds[Rand(2)], SLOT_Interact);
}

simulated function LandThump()
{
    PlaySound(LandThumpSound);
    Super(U2Creatures).LandThump();
}

function PlayLeapAnim()
{
    bShotAnim = true;

    SetAnimAction('Jump01_Start');

}

function NotifyLeapBegin()
{
        /*LandAnims[0] = 'Jump01_Land';
        LandAnims[1] = 'Jump01_Land';
        LandAnims[2] = 'Jump01_Land';
        LandAnims[3] = 'Jump01_Land';   */
    U2MonsterController(Controller).ReflectNotify( 'LeapBeginNotify' );
}

simulated function Tick(float DeltaTime)
{
    local float dist;

    if (Level.TimeSeconds - LastLeapCheckTime < 0.25 || Controller == None || (Controller != None && U2MonsterController(Controller) != None && U2MonsterController(Controller).bLeaping))
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
        SetAnimAction('Jump01_Start');
        //PlayAnim('Jump01');
    }
    Controller.Destination = Location + 200 * duckDir;
    Velocity = GroundSpeed * duckDir;
    Controller.GotoState('TacticalMove', 'DoMove');
    return true;
}

event Landed(vector HitNormal)
{
    PlaySound(LandSounds[Rand(2)], SLOT_Interact);
    SetPhysics(PHYS_Walking);
    Super(U2Creatures).Landed(HitNormal);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    PlayAnim(DeathAnims[Rand(6)], 0.9, 0.1);
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 && !bShotAnim )
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

    if ( Anim == 'Jump01' || Anim == 'Jump01_MidFrame' || Anim == 'Jump01_Start' || Anim == 'Jump01_Land' )
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
        PlayAnim('WoundMid01',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('WoundMid01',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
    if ( FRand() < 0.5 )
            PlayAnim('WoundRight01',, 0.1);
    else
        PlayAnim('WoundRight02',, 0.1);
    }
    else
    {
    if ( FRand() < 0.5 )
            PlayAnim('WoundLeft01',, 0.1);
    else
        PlayAnim('WoundLeft02',, 0.1);
    }


}

simulated function PlayLand()
{
    if (!bIsCrouched && !bShotAnim)
    {
        PlayAnim(LandAnims[Get4WayDirection()], 1.0f, 0.1f, 0);
        bWaitForAnim = true;
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
        SetAnimAction('IdleLookL01');
    else
        SetAnimAction('IdleLookR01');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function ClawDamageTarget()
{

    if ( MeleeDamageTarget(ClawDamage, (25000 * Normal(Controller.Target.Location - Location))) )
    {
        PlaySound(sound'tk_U2Creatures.MeleeImpactPoint1', SLOT_Interact);
    }
}

/*singular function Bump(actor Other)
{
    local name Anim;
    local float frame,rate;
    log("In bump");
    //log(bShotAnim);
    log("Bump: bLunging:"$bLunging);
    if ( /*bShotAnim &&*/ bLunging )
    {
        bLunging = false;
        GetAnimParams(0, Anim,frame,rate);
        if ( Anim == 'Jump01_Start' || Anim == 'Jump01_MidFrame' || Anim == 'Jump01_Land' || Anim == 'Jump01' )
        {
            MeleeDamageTarget(LungeDamage, (20000.0 * Normal(Controller.Target.Location - Location)));
            PlaySound(LeapImpactSounds[Rand(2)], SLOT_Interact);
            log("Bump: Dealt damage?");
        }
    }
    Super(U2Creatures).Bump(Other);
}*/


function RangedAttack(Actor A)
{
    local float Dist;
    local name Anim;
    local float frame,rate;
    local vector EnemyLocation;

    if ( bShotAnim )
        return;

    GetAnimParams(0,Anim,frame,rate);
    if ( Anim == 'Jump01' || Anim == 'Jump01_Start' || Anim == 'Jump01_Mid' || Anim == 'Jump01_MidFrame' || Anim == 'Jump01_Land' )
        return;

    Enable('Tick');

    EnemyLocation = A.Location;
    Dist = VSize(EnemyLocation - Location);


    //bShotAnim = true;
    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius )
    {

        SetAnimAction('Slash01');
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        PlaySound(MeleeSounds[Rand(4)], SLOT_Interact);

        return;
    }
    /*else if ( (Level.TimeSeconds - LastLeapTime >= MinLeapRefireDelay) && FRand() <= LeapOdds && Physics != PHYS_Falling && (Dist < LungeRange + CollisionRadius + A.CollisionRadius) && (Dist >= LungeRangeMin) )
    {
        LastLeapTime = Level.TimeSeconds;
        LeapRotation = rotator(EnemyLocation - Location);
        SetAnimAction('Jump01_Start');
        bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Leap.Leap1', SLOT_Interact);
        //bLunging = true;
        //Enable('Bump');//800
        //Velocity = 500 * Normal(A.Location + A.CollisionHeight * vect(0,0,0.75) - Location);
        //Velocity = 500 * Normal(EnemyLocation + A.CollisionHeight * vect(0,0,0.75) - Location);

        //Velocity = LeapSpeed * vector(LeapRotation);
        //if ( dist > CollisionRadius + A.CollisionRadius + 35 )
        //  Velocity.Z += 0.7 * dist;
        //SetPhysics(PHYS_Falling);
        return;
    }*/
    else
        U2MonsterController(Controller).DoCharge();
}

function StartLeapOld()
{
    local vector EnemyLocation;
    local rotator LeapRotation;
    local actor A;
    local float dist;


    if (Controller.Enemy != None)
    {
        A = Controller.Enemy;
        EnemyLocation = A.Location;
        dist = VSize(EnemyLocation - Location);
        LeapRotation = rotator(EnemyLocation - Location);
        Velocity = LeapSpeed * vector(LeapRotation);
        if ( dist > CollisionRadius + A.CollisionRadius + 35 )
            Velocity.Z += 0.35 * dist;
        SetPhysics(PHYS_Falling);
        bShotAnim = true;
        bLunging = true;
        Enable('Bump');
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

function SpawnShot()
{
    //FireProj(vect(1.1,0,0.4));
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;

    GetAxes(Rotation,X,Y,Z);
    //FireStart = (vect(1.1,0,0.4));
    FireStart = GetFireStart(X,Y,Z);
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
    Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);
}

defaultproperties
{
     ClawDamage=20
     MeleeSounds(0)=Sound'tk_U2Creatures.AraknidMediumA_MeleeMotion.MeleeMotion1'
     MeleeSounds(1)=Sound'tk_U2Creatures.AraknidMediumA_MeleeMotion.MeleeMotion2'
     MeleeSounds(2)=Sound'tk_U2Creatures.AraknidMediumA_MeleeMotion.MeleeMotion3'
     MeleeSounds(3)=Sound'tk_U2Creatures.AraknidMediumA_MeleeMotion.MeleeMotion4'
     StepSounds(0)=Sound'tk_U2Creatures.AraknidMediumA_Move.Move1'
     StepSounds(1)=Sound'tk_U2Creatures.AraknidMediumA_Move.Move2'
     LandSounds(0)=Sound'tk_U2Creatures.AraknidMediumA_Move.Land1'
     LandSounds(1)=Sound'tk_U2Creatures.AraknidMediumA_Move.Land2'
     LandThumpSound=Sound'tk_U2Creatures.AraknidMediumA_Move.LandThump1'
     LeapImpactSounds(0)=Sound'tk_U2Creatures.AraknidMediumA_LeapImpact.LeapImpact1'
     LeapImpactSounds(1)=Sound'tk_U2Creatures.AraknidMediumA_LeapImpact.LeapImpact2'
     DeathAnims(0)="Death01"
     DeathAnims(1)="Death02"
     DeathAnims(2)="Death03"
     DeathAnims(3)="Death04"
     DeathAnims(4)="Death05"
     DeathAnims(5)="Death06"
     leapSpeed=1200.000000
     StepShakeRadius=384.000000
     StepShakeMagnitude=3.000000
     StepShakeDuration=0.300000
     LandShakeRadius=512.000000
     LandShakeMagnitude=8.000000
     LandShakeDuration=0.400000
     LeapMinRange=128.000000
     LeapMaxRange=1024.000000
     LeapOdds=0.750000
     bLeapRequiresLOS=False
     bTurnToEnemyAfterLeap=True
     LeapHighSpeed=1200.000000
     LeapLowSpeed=1200.000000
     LeapHighOdds=0.250000
     LeapDelayLand=0.500000
     LeapMaxDamage=50
     LeapMaxMomentumTransfer=60000.000000
     OnlyLeapLowRange=512.000000
     MinLeapRefireDelay=4.000000
     DodgeSkillAdjust=4.000000
     HitSound(0)=Sound'tk_U2Creatures.AraknidMediumA_HitSoft.HitSoft1'
     HitSound(1)=Sound'tk_U2Creatures.AraknidMediumA_HitSoft.HitSoft2'
     HitSound(2)=Sound'tk_U2Creatures.AraknidMediumA_HitHard.HitHard1'
     HitSound(3)=Sound'tk_U2Creatures.AraknidMediumA_HitHard.HitHard2'
     DeathSound(0)=Sound'tk_U2Creatures.AraknidMediumA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.AraknidMediumA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.AraknidMediumA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.AraknidMediumA_Idle.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.AraknidMediumA_Idle.Idle1'
     ChallengeSound(1)=Sound'tk_U2Creatures.AraknidMediumA_Idle.Idle2'
     ChallengeSound(2)=Sound'tk_U2Creatures.AraknidMediumA_Idle.Idle1'
     ChallengeSound(3)=Sound'tk_U2Creatures.AraknidMediumA_Idle.Idle2'
     FireSound=None
     AmmunitionClass=Class'tk_U2Creatures.AraknidMediumAmmo'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_AraknidMedium'
     GibGroupClass=Class'tk_U2Creatures.AraknidMediumGibGroup'
     WallDodgeAnims(0)="Jump01_Start"
     WallDodgeAnims(1)="Jump01_Start"
     WallDodgeAnims(2)="Jump01_Start"
     WallDodgeAnims(3)="Jump01_Start"
     IdleHeavyAnim="Idle02"
     IdleRifleAnim="Idle03"
     FireHeavyRapidAnim="Bubble01"
     FireHeavyBurstAnim="Bubble01"
     FireRifleRapidAnim="Bubble01"
     FireRifleBurstAnim="Bubble01"
     bCrawler=False
     MeleeRange=40.000000
     GroundSpeed=240.000000
     WalkingPct=1.000000
     Health=200
     MovementAnims(0)="RunFrwd01"
     MovementAnims(1)="RunFrwd03"
     MovementAnims(2)="RunFrwd01"
     MovementAnims(3)="RunFrwd01"
     TurnLeftAnim="TurnLeft01"
     TurnRightAnim="TurnRight01"
     SwimAnims(0)="RunFrwd04"
     SwimAnims(1)="RunFrwd04"
     SwimAnims(2)="RunFrwd04"
     SwimAnims(3)="RunFrwd04"
     CrouchAnims(0)="RunFrwd02"
     CrouchAnims(1)="RunFrwd02"
     CrouchAnims(2)="RunFrwd02"
     CrouchAnims(3)="RunFrwd02"
     WalkAnims(0)="RunFrwd01"
     WalkAnims(1)="RunFrwd01"
     WalkAnims(2)="RunLeft01"
     WalkAnims(3)="RunFrwd01"
     AirAnims(0)="Jump01_MidFrame"
     AirAnims(1)="Jump01_MidFrame"
     AirAnims(2)="Jump01_MidFrame"
     AirAnims(3)="Jump01_MidFrame"
     TakeoffAnims(0)="Jump01_Start"
     TakeoffAnims(1)="Jump01_Start"
     TakeoffAnims(2)="Jump01_Start"
     TakeoffAnims(3)="Jump01_Start"
     LandAnims(0)="Jump01_Land"
     LandAnims(1)="Jump01_Land"
     LandAnims(2)="Jump01_Land"
     LandAnims(3)="Jump01_Land"
     DoubleJumpAnims(0)="Jump01_Start"
     DoubleJumpAnims(1)="Jump01_Start"
     DoubleJumpAnims(2)="Jump01_Start"
     DoubleJumpAnims(3)="Jump01_Start"
     DodgeAnims(0)="Jump01_MidFrame"
     DodgeAnims(1)="Jump01_MidFrame"
     DodgeAnims(2)="Jump01_MidFrame"
     DodgeAnims(3)="Jump01_MidFrame"
     AirStillAnim="Jump01_MidFrame"
     TakeoffStillAnim="Jump01_Start"
     CrouchTurnRightAnim="TurnRight01"
     CrouchTurnLeftAnim="TurnLeft01"
     IdleCrouchAnim="Idle03"
     IdleSwimAnim="RunFrwd04"
     IdleWeaponAnim="Idle01"
     IdleRestAnim="Idle02"
     IdleChatAnim="IdleLookL01"
     Mesh=SkeletalMesh'tk_U2Creatures.AraknidMedium'
     DrawScale=0.700000
     PrePivot=(X=-10.000000,Z=5.000000)
     Skins(0)=Shader'tk_U2Creatures.Araknid.AraknidMedium1FX'
     Skins(1)=Shader'tk_U2Creatures.Araknid.AraknidMedium2FX'
     Skins(2)=Shader'tk_U2Creatures.Araknid.araknidheavybody3FX'
     CollisionRadius=60.000000
     CollisionHeight=45.000000
     Mass=75.000000
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
