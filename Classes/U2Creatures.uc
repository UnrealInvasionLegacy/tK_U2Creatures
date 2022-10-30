class U2Creatures extends Monster config(U2CreaturesConfig);

#EXEC OBJ LOAD FILE=Resources\tk_U2Creatures_rc.usx PACKAGE=tk_U2Creatures
#EXEC OBJ LOAD FILE=Resources\tk_U2Creatures_Snd.uax PACKAGE=tk_U2Creatures

var() config float KillingForce;
var() config float UpKickForce;
var() config bool bHasRagdoll, bUseCustomForces;
var() float leapSpeed;

var() float StepShakeRadius;
var() float StepShakeMagnitude;
var() float StepShakeDuration;
var() float LandShakeRadius;
var() float LandShakeMagnitude;
var() float LandShakeDuration;
var() float DodgeXYVelocityScale;
var() float DodgeJumpZScale;

// leaping
var() float LeapMinRange, LeapMaxRange, LeapOdds;
var() bool  bLeapRequiresLOS;                   // if true, NPCs only leap at visible enemies
var() bool  bTurnToEnemyAfterLeap;              // if true turns to enemy after leap completed (landing + delay)
var() float LeapHighSpeed;                      // speed of high leap
var() float LeapLowSpeed;                       // speed of low leap (determines range) NOTE: Pawns fall faster than other Actors...
var() float LeapHighOdds;                       // odds NPC will use high projectile trajectory (if target inside range)
var() float LeapHighPredictOdds;                // odds NPC will predict target's location with high trajectory
var() float LeapLowPredictOdds;                 // odds NPC will predict target's location with low trajectory
var() float LeapMaxOdds;                        // odds NPC will leap at 45 degrees (max range) when target out of range
var() float LeapToMeleeOdds;                    // odds NPC will go straight to melee attack if enemy bumped during leap
var() float LeapDelayFailure;                   // seconds - time to wait after a failed leap attempt (e.g. something in the way)
var() float LeapDelayLand;                      // delay after leaping NPC lands
var() float LeapDelayPreJump;                   // delay prior to leaping including time to turn towards destination
var() float LeapDelaySuccess;                   // seconds - time to wait after a successful leap before trying again
var() int   LeapMaxDamage;                      // max damage if target hit dead on
var() float LeapMaxMomentumTransfer;            // max MT if target hit dead on
var() float LeapNotifyTime;                     // time between start of leap animation and leap notify (refined with first leap)
var() float OnlyLeapLowRange;                   // distance within which NPC will only do low leaps
var float LastLeapTime;
var() float MinLeapRefireDelay;                 // time to wait after leap before firing
var float LastLeapCheckTime;

var(Movement) int RotationRateYawEnemy;         // yaw rotation rate to use with an enemy (during combat) defaults to RotationRate*X if not set
var(Movement) int RotationRateYawEnemySeen;     // yaw rotation rate to use with an enemy (during combat) defaults to RotationRate*X if not set

var() class<CollisionProxy> CollisionTesterClass;

var bool    bDoingLeapCheck;            //Want to disable tick for leaping pawns when they aren't fighting anyone

//Head rotation stuff
var() name BonePitch;
var() name BoneYaw, BoneYaw2;
var vector ViewOffset;

var vector AimingVector, ClientAimingVector;
var rotator AimingRotation;

var() bool bHeadTrackingEnabled;

replication
{

    reliable if(Role<ROLE_Authority)
        ServerStep, ServerLandThump, ServerDoShake;

    reliable if( bNetDirty && Role == ROLE_Authority )
        AimingVector, AimingRotation;
}



simulated function Step()
{
    if( StepShakeRadius > 0.0 )
        DoShake( Self, Location, StepShakeRadius, StepShakeMagnitude, StepShakeDuration );
        //class'UtilGame'.static.MakeShake( Self, Location, StepShakeRadius, StepShakeMagnitude, StepShakeDuration );
    if ( Level.NetMode == NM_Client )
    {
        ServerStep();
    }
}

function ServerStep()
{
    if ( Level.NetMode == NM_Client )
    {
        if( StepShakeRadius > 0.0 )
            DoShake( Self, Location, StepShakeRadius, StepShakeMagnitude, StepShakeDuration );
    }
}

simulated function LandThump()
{
    if( LandShakeRadius > 0.0 )
        DoShake( Self, Location, StepShakeRadius, StepShakeMagnitude, StepShakeDuration );
        //class'UtilGame'.static.MakeShake( Self, Location, LandShakeRadius, LandShakeMagnitude, LandShakeDuration );
    if (Level.NetMode == NM_Client)
        ServerLandThump();
}

function ServerLandThump()
{
    if (Level.NetMode == NM_Client)
    {
        if( LandShakeRadius > 0.0 )
            DoShake( Self, Location, StepShakeRadius, StepShakeMagnitude, StepShakeDuration );
            //class'UtilGame'.static.MakeShake( Self, Location, LandShakeRadius, LandShakeMagnitude, LandShakeDuration );
    }
}


simulated function DoShake( Actor Context, vector ShakeLocation, float ShakeRadius, float ShakeMagnitude, optional float ShakeDuration )
{
    local Controller C;
    local PlayerController Player;
    local float Dist, localDist, Pct;

    //log("Context:" @Context@" ShakeRadius: "@ShakeRadius@" ShakeMagnitude: "@ShakeMagnitude);
    if( Context==None || ShakeRadius<=0 || ShakeMagnitude<=0 )
        return;

    Player = Level.GetLocalPlayerController();
    if (Player != None)
    {
        localDist = VSize(/*Shake*/Location-Player.ViewTarget.Location);
        //log("localDist: "$localDist);
        if( localDist<=ShakeRadius )
        {
            Pct = 1.0 - (Dist / ShakeRadius);
            Player.ShakeView(vect(1,1,1)*ShakeMagnitude,
                            vect(0,1000,0),//1,1,1
                            ShakeDuration*50,
                            vect(1,1,1)*ShakeMagnitude,
                            vect(1000,1000,1000),//1,1,1,1
                            ShakeDuration*50);
        }
    }

    for( C=Context.Level.ControllerList; C!=None; C=C.nextController )
    {
        //Player = PlayerController(C);

        //NEW (mib) - don't shake a flying / ghosted player (leave shake in for matinee cutscenes)
        //if( Player!=None && (Player.Pawn!=None && Player.Pawn.Physics != PHYS_Flying) )
        if ( (PlayerController(C) != None) && (C != Player)  )
        {
            //Dist = VSize(ShakeLocation-Player.Pawn.Location);
            Dist = VSize(Location - PlayerController(C).ViewTarget.Location);

            //log("UtilGame: Dist is: "$Dist);
            if( Dist<=ShakeRadius )
            {
                Pct = 1.0 - (Dist / ShakeRadius);

                C.ShakeView(vect(1,1,1)*ShakeMagnitude,
                                vect(0,1000,0),//1,1,1
                                ShakeDuration*50,
                                vect(1,1,1)*ShakeMagnitude,
                                vect(1000,1000,1000),//1,1,1,1
                                ShakeDuration*50);
            }
        }
    }

    if (Level.NetMode == NM_Client)
        ServerDoShake(Context, ShakeLocation, ShakeRadius, ShakeMagnitude, ShakeDuration);
}

function ServerDoShake( Actor Context, vector ShakeLocation, float ShakeRadius, float ShakeMagnitude, optional float ShakeDuration )
{
    local Controller C;
    local PlayerController Player;
    local float Dist, localDist, Pct;

    if (Level.NetMode == NM_Client)
    {
        //log("Context:" @Context@" ShakeRadius: "@ShakeRadius@" ShakeMagnitude: "@ShakeMagnitude);
        if( Context==None || ShakeRadius<=0 || ShakeMagnitude<=0 )
            return;

        Player = Level.GetLocalPlayerController();
        if (Player != None)
        {
            localDist = VSize(/*Shake*/Location-Player.ViewTarget.Location);
            //log("localDist: "$localDist);
            if( localDist<=ShakeRadius )
            {
                Pct = 1.0 - (Dist / ShakeRadius);
                Player.ShakeView(vect(1,1,1)*ShakeMagnitude,
                                vect(0,1000,0),//1,1,1
                                ShakeDuration*50,
                                vect(1,1,1)*ShakeMagnitude,
                                vect(1000,1000,1000),//1,1,1,1
                                ShakeDuration*50);
            }
        }

        for( C=Context.Level.ControllerList; C!=None; C=C.nextController )
        {
            //Player = PlayerController(C);

            //NEW (mib) - don't shake a flying / ghosted player (leave shake in for matinee cutscenes)
            //if( Player!=None && (Player.Pawn!=None && Player.Pawn.Physics != PHYS_Flying) )
            if ( (PlayerController(C) != None) && (C != Player)  )
            {
                //Dist = VSize(ShakeLocation-Player.Pawn.Location);
                Dist = VSize(Location - PlayerController(C).ViewTarget.Location);

                //log("UtilGame: Dist is: "$Dist);
                if( Dist<=ShakeRadius )
                {
                    Pct = 1.0 - (Dist / ShakeRadius);

                    C.ShakeView(vect(1,1,1)*ShakeMagnitude,
                                vect(0,1000,0),//1,1,1
                                ShakeDuration*50,
                                vect(1,1,1)*ShakeMagnitude,
                                vect(1000,1000,1000),//1,1,1,1
                                ShakeDuration*50);
                }
            }
        }
    }
}

simulated function bool IsLeaping()
{
    return Controller != None && U2MonsterController(Controller) != None && U2MonsterController(Controller).bLeaping;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    local vector shotDir, hitLocRel, deathAngVel, shotStrength;
    local float maxDim, frame, rate;
    local string RagSkelName;
    local KarmaParamsSkel skelParams;
    local name seq;
    local bool PlayersRagdoll;
    local PlayerController pc;
    local LavaDeath LD;

    AmbientSound = None;
    bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    if (CurrentCombo != None)
        CurrentCombo.Destroy();

    HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    if ( (DamageType != None) && DamageType.default.bSkeletize && (SkeletonMesh != None) )
    {
        if (!bSkeletized)
        {
            GetAnimParams( 0, seq, frame, rate );
            LinkMesh(SkeletonMesh, true);
            Skins.Length = 0;
            PlayAnim(seq, 0, 0);
            SetAnimFrame(frame);
            if (Physics == PHYS_Walking)
                Velocity = Vect(0,0,0);
            TearOffMomentum *= 0.25;
            bSkeletized = true;

            if(DamageType == class'FellLava')
            {
                LD = spawn(class'LavaDeath');
                if ( LD != None )
                {
                    LD.SetLocation(Location);
                    LD.SetRotation(Rotation);
                    LD.SetBase(self);
                }
                // This should destroy itself once its finished.

                PlaySound( sound'WeaponSounds.BExplosion5', SLOT_None, 1.5*TransientSoundVolume );
            }
        }
    }

    // stop shooting
    AnimBlendParams(1, 0.0);
    FireState = FS_None;
    LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

    if ( Level.NetMode != NM_DedicatedServer && bHasRagdoll)
    {
        // Is this the local player's ragdoll?
        if(OldController != None)
            pc = PlayerController(OldController);
        if( pc != None && pc.ViewTarget == self )
            PlayersRagdoll = true;

        // In low physics detail, if we were not just controlling this pawn,
        // and it has not been rendered in 3 seconds, just destroy it.
        if(Level.PhysicsDetailLevel == PDL_Low && !PlayersRagdoll && (Level.TimeSeconds - LastRenderTime > 3) )
        {
            Destroy();
            return;
        }

        // Try and obtain a rag-doll setup
        if(Species != None)
            RagSkelName = Species.static.GetRagSkelName(GetMeshName());
        else
            Log("xPawn.PlayDying: No Species");


        // If we managed to find a name, try and make a rag-doll slot availbale.
        if( RagSkelName != "" )
        {
            KMakeRagdollAvailable();
        }

        if( KIsRagdollAvailable() && RagSkelName != "" )
        {
            skelParams = KarmaParamsSkel(KParams);
            skelParams.KSkeleton = RagSkelName;
            KParams = skelParams;
            //Log("RAGDOLL");

            // Stop animation playing.
            StopAnimating(true);

            if(DamageType != None && bUseCustomForces)
            {

//IMPORTANT: Normally the code was written here as if(DamageType != None && DamageType.default.bKUseOwnDeathVel). This wants to say
//that normally the impact strength would only be changed if you're having a weapon that can be charged
//as the Shield Hammer. For e.g. Rockets there wouldn't have been any change.
//Simply change this line back if you'd like to have the original code
//KillingForce is the configurable value, standard: 1

                RagDeathVel *= KillingForce;
                RagDeathUpKick *= UpKickForce;
            }

            else if(DamageType != None && DamageType.default.bKUseOwnDeathVel && !bUseCustomForces)
            {
                        RagDeathVel = DamageType.default.KDeathVel;
                            RagDeathUpKick = DamageType.default.KDeathUpKick;
            }

            // Set the dude moving in direction he was shot in general
            shotDir = Normal(TearOffMomentum);
            shotStrength = RagDeathVel * shotDir;

            // Calculate angular velocity to impart, based on shot location.
            hitLocRel = TakeHitLocation - Location;

            // We scale the hit location out sideways a bit, to get more spin around Z.
            hitLocRel.X *= RagSpinScale;
            hitLocRel.Y *= RagSpinScale;
            deathAngVel = RagInvInertia * (hitLocRel Cross shotStrength);

            // Set initial angular and linear velocity for ragdoll.
            // Scale horizontal velocity for characters - they run really fast!
            skelParams.KStartLinVel.X = 0.6 * Velocity.X;
            skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
            skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
            skelParams.KStartLinVel += shotStrength;

            // If not moving downwards - give extra upward kick
            if(Velocity.Z > -10)
                skelParams.KStartLinVel.Z += RagDeathUpKick;

            skelParams.KStartAngVel = deathAngVel;

            // Set up deferred shot-bone impulse
            maxDim = Max(CollisionRadius, CollisionHeight);

            skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
            skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
            skelParams.KShotStrength = 10;

            // If this damage type causes convulsions, turn them on here.
            if(DamageType != None && DamageType.default.bCauseConvulsions)
            {
                RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
                skelParams.bKDoConvulsions = true;
            }

            // Turn on Karma collision for ragdoll.
            KSetBlockKarma(true);

            // Set physics mode to ragdoll.
            // This doesn't actaully start it straight away, it's deferred to the first tick.
            SetPhysics(PHYS_KarmaRagdoll);
            // If viewing this ragdoll, set the flag to indicate that it is 'important'
            if( PlayersRagdoll )
                skelParams.bKImportantRagdoll = true;

            return;
        }
        // jag
    }

    // non-ragdoll death fallback
    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetTwistLook(0, 0);
    SetInvisibility(0.0);
    PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

//====================================================U2 Pawn Dodging stuff===========================
function PlayLeapAnim();

function StopMovement( bool bKillAcceleration, bool bKillVelocity )
{
    if( bKillAcceleration )
        Acceleration = vect(0,0,0);
    if( bKillVelocity )
        Velocity = vect(0,0,0);
}

function U2Dodge( eDoubleClickDir DoubleClickMove, bool bJumpDodge )
{
    local vector X,Y,Z;

    //!!mdf-tbd:
    StopMovement( true, false );
    //log("U2Dodge: DoubleClickMove:" $DoubleClickMove);
    //PlayDodge( DoubleClickMove );

    if( bJumpDodge )
    {
        GetAxes( Rotation,X,Y,Z );
        if( DoubleClickMove == DCLICK_Forward )
            Velocity = DodgeXYVelocityScale*default.GroundSpeed*X + (Velocity dot Y)*Y;
        else if( DoubleClickMove == DCLICK_Back )
            Velocity = -DodgeXYVelocityScale*default.GroundSpeed*X + (Velocity dot Y)*Y;
        else if( DoubleClickMove == DCLICK_Left )
            Velocity = DodgeXYVelocityScale*default.GroundSpeed*Y + (Velocity dot X)*X;
        else if( DoubleClickMove == DCLICK_Right )
            Velocity = -DodgeXYVelocityScale*default.GroundSpeed*Y + (Velocity dot X)*X;

        Velocity.Z = default.JumpZ * DodgeJumpZScale;

        //Controller.StartFalling(); //!!mdf-tbd: tell controller we started falling
        SetPhysics( PHYS_Falling );
    }
    PlayDodge( DoubleClickMove );

    //HandleJumpSound();
    PlayOwnedSound(GetSound(EST_Dodge), SLOT_Pain, GruntVolume,,80);
}

function PlayDodge(eDoubleClickDir DoubleClickMove)
{
    local name Anim;

    if ( Physics == PHYS_Falling )
    {
        if (DoubleClickMove == DCLICK_Forward)
    {
            Anim = DodgeAnims[0];

    }
        else if (DoubleClickMove == DCLICK_Back)
            Anim = DodgeAnims[1];
        else if (DoubleClickMove == DCLICK_Left)
            Anim = DodgeAnims[2];
        else if (DoubleClickMove == DCLICK_Right)
            Anim = DodgeAnims[3];
    //log("U2Dodge: Anim:"$Anim);
        if ( PlayAnim(Anim, 1.0, 0.1) )
    {
            bWaitForAnim = true;
            AnimAction = Anim;
    }

    }
}


function SetEnemyRotationRates()
{
    if( default.RotationRateYawEnemy == 0 )
        RotationRateYawEnemy = 1.2*default.RotationRate.Yaw;
    else
        RotationRateYawEnemy = default.RotationRateYawEnemy;

    if( default.RotationRateYawEnemySeen == 0 )
        RotationRateYawEnemySeen = 2.0*default.RotationRate.Yaw;
    else
        RotationRateYawEnemySeen = default.RotationRateYawEnemySeen;
}

//-----------------------------------------------------------------------------

function EnableRotation( bool bVal )
{
    if( bVal )
    {
        RotationRate = default.RotationRate;
        SetEnemyRotationRates();
        LandAnims[0] = Default.LandAnims[0];
        LandAnims[1] = Default.LandAnims[1];
        LandAnims[2] = Default.LandAnims[2];
        LandAnims[3] = Default.LandAnims[3];
    }
    else
    {
        RotationRate = rot(0,0,0);
        RotationRateYawEnemy = 0;
        RotationRateYawEnemySeen = 0;
    }
}

static function bool ActorFits( Actor MovingActor, vector DesiredLocation, float ActorFitsRadius )
{
    local Actor IterA;
    local float RadiusDiff, HeightDiff;
    local vector Diff;
    local bool bFits;

    // Filter out bogus data.
    if( MovingActor == None )
    {
        return false;   // Should this return true?  Since a non-existance Actor could theretically fit anywhere - if you could move it.
    }

    bFits = true;

    // Check all blocking actors for overlapping collision cylinders.
    if( MovingActor.bBlockActors || MovingActor.bBlockPlayers )
    {
        foreach MovingActor.RadiusActors(class'Actor', IterA, ActorFitsRadius, DesiredLocation )
        {
            if( IterA != MovingActor && !IterA.IsA( 'Mover' ) )
            {
                if( IterA.bBlockActors || IterA.bBlockPlayers )
                {
                    Diff = IterA.Location - DesiredLocation;
                    HeightDiff = Diff.z;
                    Diff.z = 0;
                    RadiusDiff = VSize( Diff );

                    if
                    (   IterA.CollisionRadius + MovingActor.CollisionRadius >= RadiusDiff   // Using >= to be safe.  > is probably sufficient.
                    &&  IterA.CollisionHeight + MovingActor.CollisionHeight >= HeightDiff
                    )
                    {
                        bFits = false;
                        break;  // No need to go on.
                    }
                }
            }
        }
    }

    return bFits;
}

function NotifyLeapBegin()
{
    U2MonsterController(Controller).ReflectNotify( 'LeapBeginNotify' );
}

function StartLeap()
{
    NotifyLeapBegin();
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

simulated event SetAnimAction(name NewAction)
{
    Super(XPawn).SetAnimAction(NewAction);
}

//-------------------------------Head rotation stuff---------------------------
simulated event PostNetReceive()
{
    // something was replicated to client ForceWall
    Super.PostNetReceive();

    if( AimingVector != ClientAimingVector )
    {
        ClientAimingVector = AimingVector;
        ApplyAimingRotation();
    }
}

simulated function SetPitch( rotator NewRotation )
{
    NewRotation.Yaw = 0;
    NewRotation.Roll = 0;
    //log("NewRotation.Pitch: "$NewRotation.Pitch);
    if (NewRotation.Pitch <= -10000)
        NewRotation.Pitch = NewRotation.Pitch;
    else
        NewRotation.Pitch = NewRotation.Pitch - 5000;//4000
    SetBoneRotation( BonePitch, NewRotation );
}

simulated function SetYaw( rotator NewRotation )
{
    local int dir;

    dir = Get4WayDirection();
    //log("dir: "$dir);
    NewRotation.Pitch = 0;
    NewRotation.Roll = 0;
    //log("SetYaw: NewRotation.Yaw: "$NewRotation.Yaw);

    if (dir == 2 || dir == 3)
        SetBoneRotation( BoneYaw2, NewRotation);
    else
        SetBoneRotation( BoneYaw2, rot(0,0,0), 0);

    if (NewRotation.Yaw < -10000)
        NewRotation.Yaw = -10000;
    else if (NewRotation.Yaw > 12000)
        NewRotation.Yaw = 12000;
    SetBoneRotation/*Direction*/( BoneYaw, NewRotation );


}

simulated function ApplyAimingRotation()
{
    local vector LocalDir, InvertedDir;
    local rotator AimRot;

    LocalDir = AimingVector << Rotation;

    InvertedDir.X = LocalDir.X;
    InvertedDir.Y = -LocalDir.Y;
    InvertedDir.Z = -LocalDir.Z;

    AimRot = rotator(InvertedDir);

    SetYaw( AimRot );
    SetPitch( AimRot );
}

function SetAimingRotation( vector AimVector )
{
    AimingVector = AimVector;
    AimingRotation = rotator(AimingVector);
    if( Level.NetMode != NM_DedicatedServer )
        ApplyAimingRotation();
}

function rotator GetAimingRotation()
{
    return AimingRotation;
}


simulated function vector GetViewLocation()
{
    return Location;//GetBoneCoords( BoneElevatorEnd ).Origin - ViewOffset;
}

defaultproperties
{
     KillingForce=1.000000
     UpKickForce=1.000000
     bHasRagdoll=True
     bUseCustomForces=True
     DodgeXYVelocityScale=2.000000
     bLeapRequiresLOS=True
     LeapHighPredictOdds=1.000000
     LeapLowPredictOdds=1.000000
     LeapMaxOdds=1.000000
     LeapDelayFailure=2.000000
     LeapDelayPreJump=0.250000
     LeapDelaySuccess=5.000000
     LeapNotifyTime=0.250000
     ClientAimingVector=(X=9999999.000000,Y=9999999.000000,Z=9999999.000000)
     ControllerClass=Class'tk_U2Creatures.U2MonsterController'
}
