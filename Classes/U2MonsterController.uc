class U2MonsterController extends MonsterController dependsOn(UtilGame);

const DegreesToRadians                  = 0.0174532925199432;   //NEW (mdf) PI / 180.0
const RadiansToDegrees                  = 57.295779513082321;   //NEW (mdf) 180.0 / PI
const DegreesToRotationUnits            = 182.044;              //NEW (mdf) 65536 / 360
const RotationUnitsToDegrees            = 0.00549;              //NEW (mdf) 360 / 65536
var bool bLeaping;
var float NextLeapTime;
var bool bLeapNotifyTimeSet;
var vector LeapLastHitWallNormal;       // normal of last hit with wall (to prevent multiple hit wall notifications for the same hit)
var float LeapLastHitWallTime;          // last time a wall was hit
var float LeapMinHitWallDelay;          // minimum amount of time before acknowledging hit wall notifications
var float LastBumpDamageTime;
var float StartTurnTime;
var rotator PendingLeapRotation;
var float PendingLeapSpeed;
// these are identical to the above when the NPC has LOS to his enemy but when
// there is no LOS, these might be set based on where the NPC thinks the enemy
// might be (e.g. if NPC heard enemy).
var private vector  LastEnemyDetectedLocation;
var private vector  LastEnemyDetectionLocation;
var private float   LastEnemyDetectedTime;

//Head rotation stuff
var vector      CurrentAimingLocation;          // where the satellite is
var vector      DesiredAimingLocation;          // where we'd like to move the satellite to
var float       MinHitNonPawnDistance;
var int         TrackLevel;
var float       TurningRateDegreesPerSecond;    // rate at which turrent can adjust its aiming direction
var bool        bSettled;

function Possess(Pawn aPawn)
{
    Super.Possess(aPawn);
    if (U2Creatures(Pawn).bHeadTrackingEnabled)
        Enable('Tick');
}

function ReflectNotify( name NotifyName );

function bool CanAttemptLeapAttack()
{
    return( Level.TimeSeconds >= NextLeapTime &&
            Pawn.Physics == PHYS_Walking &&
            Enemy != None &&
            (Enemy.Physics == PHYS_Walking || Enemy.Physics == PHYS_Falling) /*&&
            (!U2Creatures(Pawn).bLeapRequiresLOS || GetTimeSinceEnemyLastDetected() < 0.2)*/ /*&&
            ValidEnemy( Enemy )*/ );
}
//-----------------------------------------------------------------------------
function float GetTimeSinceEnemyLastDetected()
{
    return Level.TimeSeconds - LastEnemyDetectedTime;
}

//-----------------------------------------------------------------------------

event EnemyInLeapRange( float Distance )
{
    if( class'UtilGame'.static.FDecision( U2Creatures(Pawn).LeapOdds ) && CanAttemptLeapAttack() && !U2Creatures(Pawn).bShotAnim )
        GotoState( 'AttackLeapState' );
}

//-----------------------------------------------------------------------------

event EnemyInMeleeRange()
{
    /*if( class'UtilGame'.static.FDecision( Pawn.MeleeOdds ) || !IsPreparedToFire( true, true, U2Weapon.RatingIneffective ) )
    {
        #debug   BehaviorController.Update( BC_MeleeRange, GetContext() );
        #release BehaviorController.Update( BC_MeleeRange );
    }*/
}
//-----------------------------------------------------------------------------
function UtilGame.ELeapResult GetLeapHighParameters( float TargetDistance, vector Extents, out vector LeapDestination, out float Theta, out float LeapSpeed )
{
    local vector PredictedLocation;
    //local int FitActorAtResult;
    local bool ActorFitsResult;

    //DMTNS( "try to LEAP high" );
    LeapSpeed = U2Creatures(Pawn).LeapHighSpeed;

    PredictedLocation = Enemy.Location;
    if( class'UtilGame'.static.FDecision( U2Creatures(Pawn).LeapHighPredictOdds ) )
    {
        // predict necessary target location
        class'UtilGame'.static.GetBestPredictedProjectileLocation(
            Pawn,
            Enemy,
            class'Pawn',
            LeapSpeed,
            U2Creatures(Pawn).LeapDelayPreJump + U2Creatures(Pawn).LeapNotifyTime,
            Pawn.Location,
            TargetDistance,
            true,
            PredictedLocation );
    }

    //AddCylinder( PredictedLocation, Pawn.CollisionRadius, Pawn.CollisionHeight, ColorCyan() );

    LeapDestination = PredictedLocation;

    // align NPC "feet" with bottom of target location
    LeapDestination.Z += (Pawn.CollisionHeight - Enemy.CollisionHeight);

    //FitActorAtResult = U2Creatures(Pawn).FitActorAt( LeapDestination, Pawn.CollisionRadius + class'UtilGame'.default.VerifyTrajectoryHorizontalExtentPadding, Pawn.CollisionHeight + class'UtilGame'.default.VerifyTrajectoryVerticalExtentPadding );
    ActorFitsResult = U2Creatures(Pawn).ActorFits( Pawn, LeapDestination, CollisionRadius );
    //DMTNS( "FitActorAtResult  #2: " $ FitActorAtResult );
    //FitActorAtResult = 0;
    //if( FitActorAtResult == 0 )
    if (!ActorFitsResult)
    {
        // try aiming directly at enemy
        LeapDestination = Enemy.Location - (Pawn.CollisionRadius - Enemy.CollisionRadius) * Normal( Pawn.Location - Enemy.Location );
        // align NPC "feet" with bottom of target location
        LeapDestination.Z += (Pawn.CollisionHeight - Enemy.CollisionHeight);
    }

    //AddCylinder( LeapDestination, Pawn.CollisionRadius, Pawn.CollisionHeight, ColorOrange() );
    //AddArrow( Pawn.Location, LeapDestination, ColorOrange() );

    return class'UtilGame'.static.VerifyLeapParameters(
                Pawn,
                class'Pawn',
                LeapSpeed,
                LeapDestination,
                Pawn.Location,
                Enemy,
                TRAJ_High,
                Theta,
                Extents );
}

//-----------------------------------------------------------------------------

function UtilGame.ELeapResult GetLeapLowParameters( float TargetDistance, vector Extents, out vector LeapDestination, out float Theta, out float LeapSpeed )
{
    local vector PredictedLocation;
    //local int FitActorAtResult;
    local bool ActorFitsResult;

    //DMTNS( "try to LEAP low" );
    LeapSpeed = U2Creatures(Pawn).LeapLowSpeed;

    PredictedLocation = Enemy.Location;
    if( class'UtilGame'.static.FDecision( U2Creatures(Pawn).LeapLowPredictOdds ) )
    {
        // predict necessary target location
        class'UtilGame'.static.GetBestPredictedProjectileLocation(
            Pawn,
            Enemy,
            class'Pawn',
            LeapSpeed,
            U2Creatures(Pawn).LeapDelayPreJump + U2Creatures(Pawn).LeapNotifyTime,
            Pawn.Location,
            TargetDistance,
            false,
            PredictedLocation );
    }

    // aim to leap through enemy somewhat
    LeapDestination = PredictedLocation + vect(0,0,1) * Enemy.CollisionHeight;

    // align NPC "feet" with bottom of target location
    LeapDestination.Z += (Pawn.CollisionHeight - Enemy.CollisionHeight);

    //AddCylinder( LeapDestination, Pawn.CollisionRadius, Pawn.CollisionHeight, ColorGreen() );
    //U2Creatures(Pawn).FitActorAt( LeapDestination, Pawn.CollisionRadius + class'UtilGame'.default.VerifyTrajectoryHorizontalExtentPadding, Pawn.CollisionHeight + class'UtilGame'.default.VerifyTrajectoryVerticalExtentPadding );
    ActorFitsResult = U2Creatures(Pawn).ActorFits( Pawn, LeapDestination, CollisionRadius );
    //AddCylinder( LeapDestination, Pawn.CollisionRadius, Pawn.CollisionHeight, ColorBlue() );

    //log( "FitActorAtResult #1: " $ FitActorAtResult );
    //log("ActorFitsResult #1: "$ActorFitsResult);
    //if( FitActorAtResult == 0 )
    if (!ActorFitsResult)
    {
        // doesn't fit at overshoot location -- back up to predicted location
        LeapDestination = PredictedLocation - (Pawn.CollisionRadius - Enemy.CollisionRadius) * Normal( Pawn.Location - PredictedLocation );

        // align NPC "feet" with bottom of target location
        LeapDestination.Z += (Pawn.CollisionHeight - Enemy.CollisionHeight);
        //FitActorAtResult = U2Creatures(Pawn).FitActorAt( LeapDestination, Pawn.CollisionRadius + class'UtilGame'.default.VerifyTrajectoryHorizontalExtentPadding, Pawn.CollisionHeight + class'UtilGame'.default.VerifyTrajectoryVerticalExtentPadding );
        ActorFitsResult = U2Creatures(Pawn).ActorFits( Pawn, LeapDestination, CollisionRadius );

        //log( "FitActorAtResult  #2: " $ FitActorAtResult );
        //log( "ActorFitsResult #2: " $ActorFitsResult);
        //if( FitActorAtResult == 0 )
        if (!ActorFitsResult)
        {
            // doesn't fit at overshoot location -- aim directly at enemy
            LeapDestination = Enemy.Location - (Pawn.CollisionRadius - Enemy.CollisionRadius) * Normal( Pawn.Location - Enemy.Location );
            // align NPC "feet" with bottom of target location
            LeapDestination.Z += (Pawn.CollisionHeight - Enemy.CollisionHeight);
        }
    }

    //AddCylinder( PredictedLocation, 4, 4, ColorMagenta() );
    //AddCylinder( LeapDestination, 16, 16, ColorGreen() );
    //AddArrow( Pawn.Location, LeapDestination, ColorGreen() );

    return class'UtilGame'.static.VerifyLeapParameters(
                Pawn,
                class'Pawn',
                LeapSpeed,
                LeapDestination,
                Pawn.Location,
                Enemy,
                TRAJ_Low,
                Theta,
                Extents );
}

//-----------------------------------------------------------------------------

function bool GetLeapMaxParameters( out vector LeapDestination, vector Extents, out float Theta, out float LeapSpeed )
{
    //log( "LEAP at 45 degrees?" );

    if (!Pawn.IsA('U2Creatures')) return false;
    LeapDestination = Enemy.Location;
    if( Normal( LeapDestination - Pawn.Location ) dot vector(Pawn.Rotation) < 0.707 )
        return false;

    LeapSpeed = U2Creatures(Pawn).LeapLowSpeed;
    Theta = -45 * DegreesToRadians;
    //log("GetLeapMax: Theta is: "$Theta);
    //AddCylinder( PredictedLocation, 16, 16, ColorRed() );
    //AddArrow( Pawn.Location, PredictedLocation, ColorRed() );

    return class'UtilGame'.static.VerifyTrajectory( Pawn, class'Pawn', LeapSpeed, Pawn.Location, LeapDestination, Enemy, Theta, /*InterceptTime*/, Extents );
}

//-----------------------------------------------------------------------------
// !!mdf-tbd: maybe try different leap speeds depending on the circumstances?

function bool GetLeapParameters( out rotator LeapRotation, out float LeapSpeed )
{
    local vector LeapDestination;
    local float Theta;
    local float TargetDistance;
    local vector Extents;
    local UtilGame.ELeapResult LeapResult;
    local bool bTriedHigh, bSuccess;

    if( Pawn == None || Enemy == None || !Pawn.IsA('U2Creatures') )
        return false;

    //AddActor( Pawn, ColorRed() );
    //AddActor( Enemy, ColorGreen() );

    Extents.X = Pawn.CollisionRadius;
    Extents.Y = Pawn.CollisionRadius;
    Extents.Z = Pawn.CollisionHeight;

    TargetDistance = VSize( Enemy.Location - Pawn.Location );
    //DMTNS( "TargetDistance: " $ TargetDistance );
    if( TargetDistance > U2Creatures(Pawn).OnlyLeapLowRange && class'UtilGame'.static.FDecision(U2Creatures(Pawn).LeapHighOdds) )
    {
        // try a high leap
        bTriedHigh = true;
        LeapResult = GetLeapHighParameters( TargetDistance, Extents, LeapDestination, Theta, LeapSpeed );
        bSuccess = (LeapResult == LR_Success );
        //log("LeapResult 1: "$LeapResult);
        //log("Theta:"$Theta);
        //if( bSuccess )
            //log("Leap high");
            //DMTNS( "  LEAP HIGH!" );
    }

    if( !bSuccess )
    {
        // try a low leap, then maybe a high leap, then maybe a max leap
        LeapResult = GetLeapLowParameters( TargetDistance, Extents, LeapDestination, Theta, LeapSpeed );
        bSuccess = ( LeapResult == LR_Success );

        //log("LeapResult 2: "$LeapResult);
        //log("Theta:"$Theta);
        //if( bSuccess )
        //  DMTNS( "LEAP LOW!" );

        if( !bSuccess && LeapResult != LR_OutOfRange && !bTriedHigh && TargetDistance > U2Creatures(Pawn).OnlyLeapLowRange && U2Creatures(Pawn).LeapHighOdds > 0.0 )
        {
            LeapResult = GetLeapHighParameters( TargetDistance, Extents, LeapDestination, Theta, LeapSpeed );
            bSuccess = ( LeapResult == LR_Success );
            //if( bSuccess )
                //log("Leap high (low failed");
            //  DMTNS( "LEAP HIGH (low failed)!" );
        }

        if( LeapResult == LR_OutOfRange && class'UtilGame'.static.FDecision( U2Creatures(Pawn).LeapMaxOdds ) )
        {
            bSuccess = GetLeapMaxParameters( LeapDestination, Extents, Theta, LeapSpeed );
            //if( bSuccess )
            //  log("leap max");
            //bSuccess = true;//new, for testing
            //  DMTNS( "  LEAP MAX!" );
        }
    }

    //if( !bSuccess )
    //  log("Leap failed");
    //  DMTNS( "  LEAP FAILED!" );

    if( bSuccess )
    {
        //log("bSuccess - only here for testing");
        // set leap parameters
        LeapRotation = rotator(LeapDestination - Pawn.Location); // rotation to aim directly at target

        // modify the leap pitch
        if( Theta < 0 )
            LeapRotation.Pitch = RadiansToDegrees * -Theta * DegreesToRotationUnits;
        else
            LeapRotation.Pitch = 65535 - RadiansToDegrees * Theta * DegreesToRotationUnits;
    }

    return bSuccess;
}

function EnableRotation( bool bVal )
{
    if( U2Creatures(Pawn) != None )
        U2Creatures(Pawn).EnableRotation( bVal );
}

function StopMovement( bool bKillAcceleration, bool bKillVelocity )
{
    if( U2Creatures(Pawn) != None )
        U2Creatures(Pawn).StopMovement( bKillAcceleration, bKillVelocity );
}


function NotifyLeapBegin();
function FakeNotifyLeapBeginTimer();

state AttackLeapState
{
    ignores /*SeeEnemy, SeeFriend, SeeOther, SeeAlertFriend,*/ HearNoise, EnemyInLeapRange, EnemyInMeleeRange;

    //-------------------------------------------------------------------------

    function TryToDodge( vector DuckDir, bool bDuckLeft );
    function PlayRandomSound();

    //-------------------------------------------------------------------------

    function int GetLeapDamage( Pawn Other )
    {
        local vector ForwardLocation;
        local float DamageDistance;

        ForwardLocation = Pawn.Location + (Pawn.CollisionRadius + Other.CollisionRadius) * vector(Pawn.Rotation);
        ForwardLocation.Z = Other.Location.Z; // 2D check

        DamageDistance = VSize( Other.Location - ForwardLocation );

        return class'Util'.static.ScaleLinear( DamageDistance, 0.0, 512.0, U2Creatures(Pawn).LeapMaxDamage, 0.0 );
    }

    //-------------------------------------------------------------------------

    function vector GetLeapMomentumTransfer( Pawn Other )
    {
        local vector ForwardLocation;
        local vector MomentumVector;
        local float MomentumDistance;
        local vector Result;

        ForwardLocation = Pawn.CollisionRadius * vector(Pawn.Rotation);
        MomentumVector = Pawn.CollisionRadius * Normal( Other.Location - Pawn.Location );

        MomentumDistance = VSize( MomentumVector - ForwardLocation );

        Result = Normal( MomentumVector ) * class'Util'.static.ScaleLinear( MomentumDistance, 0.0, Pawn.CollisionRadius, U2Creatures(Pawn).LeapMaxMomentumTransfer, 0.0 );

        // Momentum into the ground probably won't move the victim
        if( Result.Z < 0 )
            Result.Z *= -0.5;

        return Result;
    }

    //-------------------------------------------------------------------------

    function eventBumpEnemy( Pawn Other )
    {
        //DMTNS( "BumpEnemy: " $ Other );
        if( Level.TimeSeconds - LastBumpDamageTime > 1.0 )
        {
            //U2Creatures(Pawn).HandleLeapImpactSound();
            Other.TakeDamage( GetLeapDamage( Other ), Pawn, Other.Location, GetLeapMomentumTransfer( Other ), class'DamageTypePhysical' );
            LastBumpDamageTime = Level.TimeSeconds;
        }

        if( Other.Health > 0 )
            /*Global.*/eventBumpEnemy( Other );

        /*if( class'UtilGame'.static.FDecision( U2Creatures(Pawn).LeapToMeleeOdds ) )
        {
            //BehaviorController.SetBCEnabled( true );
            //if( ValidEnemy( Enemy ) )
            //{
                //#debug   BehaviorController.Update( BC_MeleeRange, GetContext() );
                //#release BehaviorController.Update( BC_MeleeRange );
            //}
        }
        else
        {
            //#debug   UpdateBehavior( true, GetContext() );
            //#release UpdateBehavior( true );
        }*/
    }

    //-------------------------------------------------------------------------

    event bool NotifyBump( Actor Other )
    {
        //DMTNS( "BumpEnemy: " $ Other );
        if( Level.TimeSeconds - LastBumpDamageTime > 1.0 && Pawn(Other) != None )
        {
            //XMPU2Creatures(Pawn).HandleLeapImpactSound();
            Other.TakeDamage( GetLeapDamage( Pawn(Other) ), Pawn, Other.Location, GetLeapMomentumTransfer( Pawn(Other) ), class'DamageTypePhysical' );
            LastBumpDamageTime = Level.TimeSeconds;
            return true;
        }
        return false;
        //if( Other.Health > 0 )
        //  /*Global.*/eventBumpEnemy( Other );
    }

    //-------------------------------------------------------------------------

    event bool NotifyHitWall( vector HitNormal, Actor Wall )
    {
        if( LeapLastHitWallNormal != HitNormal ||
            Level.TimeSeconds - LeapLastHitWallTime > LeapMinHitWallDelay )
        {
            U2Creatures(Pawn).Landed(HitNormal);//LandedOnTexture( VSize(Pawn.Velocity) );
            LeapLastHitWallNormal = HitNormal;
            LeapLastHitWallTime = Level.TimeSeconds;
            return Global.NotifyHitWall( HitNormal, Wall );
        }
    }

    //-------------------------------------------------------------------------

    function bool CanFire( bool bTest ) { return false; } //NOTE: leap animation could always contain spawnshot notifies...

    //-------------------------------------------------------------------------

    function NotifyLeapBegin()
    {
        //DMTNS( "NotifyLeapBegin" );
        //RemoveTimer( FakeNotifyLeapBeginTimerName );
        Disable('Timer');
        if( !bLeaping ) // in case 2nd notify comes in somehow
        {
            bLeaping = true;

            //DMTNS( "NotifyLeapBegin" );
            //U2P.DumpAgentInfo();

            //U2Creatures(Pawn).AssetsHelperClass.static.HandleLeapSound( U2P );
            GotoState('AttackLeapState', 'StartLeap');
        }
        else
        {
            //new comment DMTNS( "WARNING: got a 2nd LeapBegin notify while already leaping?!" );
            //U2P.DumpAgentInfo();
            //U2P.MakeErrorObvious( ET_Other );
        }
    }

    //-------------------------------------------------------------------------
    // Sent by Pawn when (if) it receives NotifyLeapBegin.

    function ReflectNotify( name NotifyName )
    {
        if( NotifyName == 'LeapBeginNotify' )
        {
            if( !bLeapNotifyTimeSet )
                U2Creatures(Pawn).LeapNotifyTime = Level.TimeSeconds + U2Creatures(Pawn).LeapNotifyTime;

            NotifyLeapBegin();
        }
        /*else
        {
            Super.ReflectNotify( NotifyName );
        }*/
    }

    //-------------------------------------------------------------------------

    function FakeNotifyLeapBeginTimer()
    {
        //DMTNS( "WARNING: NPC leap animation doesn't have a LeapBegin notification: " $ Pawn );
        //U2P.MakeErrorObvious( ET_Other );
        //U2P.DumpAgentInfo();
        NotifyLeapBegin();
    }

    function Timer()
    {
        if (!bLeaping)
            FakeNotifyLeapBeginTimer();
    }

    //-------------------------------------------------------------------------

    function DoLeapAttack( rotator LeapRotation, float LeapSpeed )
    {
        //log("DoLeapAttack");
        Disable('Timer');
        //AddArrow( Pawn.Location, LeapDestination, ColorYellow() );
        Pawn.Velocity = LeapSpeed * vector(LeapRotation);
        //Pawn.Velocity.Z = Pawn.JumpZ;//new
        Pawn.SetPhysics( PHYS_Falling );
        //DMTNS( "Jump Velocity: " $ Pawn.Velocity $ " VSize: " $ VSize( Pawn.Velocity ) );
        //AddArrow( Pawn.Location, Pawn.Location + Pawn.Velocity, ColorGreen() );
        //Focus = ControllerEnemy;
        //Destination = ControllerEnemy.Location;
        Enable( 'NotifyBump' /*Event_NotifyBump*/ );
    }

    //-------------------------------------------------------------------------

    function AbortedLeap()
    {
        //DMTNS( "AbortedLeap" );
        NextLeapTime = Level.TimeSeconds + U2Creatures(Pawn).LeapDelayFailure;
        GotoState('Hunting');
        //#debug   UpdateBehavior( true, GetContext() );
        //#release UpdateBehavior( true );
    }

    //-------------------------------------------------------------------------

    function FinishedLeap()
    {
        GotoState('Hunting');
        //DMTNS( "FinishedLeap"  );
        //#debug   UpdateBehavior( true, GetContext() );
        //#release UpdateBehavior( true );
    }

    //-------------------------------------------------------------------------

    event BeginState()
    {
        Disable( 'NotifyBump' /*Event_NotifyBump*/ );
        //DMTNS( "BeginState Physics: " $ EnumStr( enum'EPhysics', Pawn.Physics ) $ " Velocity: " $ Pawn.Velocity $ " Health: " $ Pawn.Health );
        //#debug   StopFiring( 0.5, SFI_Behavior, GetContext() );
        //#release StopFiring( 0.5, SFI_Behavior );
        //BehaviorController.SetBCEnabled( false );
        //Pawn.bFallingHitWallNotifications = true;
    }

    //-------------------------------------------------------------------------

    event EndState()
    {
        //if( Pawn != None )
        //  DMTNS( "  Physics: " $ EnumStr( enum'EPhysics', Pawn.Physics ) $ " Velocity: " $ Pawn.Velocity $ " Health: " $ Pawn.Health );
        //CheckBehaviorEnabled();
        //BCStartFiring();
        //Enable( 'NotifyBump' /*Event_NotifyBump*/ );
        Disable( 'NotifyBump' );
        EnableRotation( true );
        //new comment RemoveTimer( FakeNotifyLeapBeginTimerName ); //mdf-tbr:
        //new comment UnLockAnimationController();
        bLeaping = false;
        //new comment if( Pawn != None )
        //  Pawn.bFallingHitWallNotifications = Pawn.default.bFallingHitWallNotifications;
        GotoState('Hunting');
    }

    //-------------------------------------------------------------------------

Begin:
    //log("In attackleapstate");
    //DMTNS( "begin label" );
    //StopMovement( true, true );
    Focus = Enemy;
    //DMTNS( "call FinishRotation" );
    FinishRotation( /*DefaultRotationThreshold*/ );

    //PendingLeapRotation = rotator(Enemy.Location - Pawn.Location);//new
    // only get the leap parameters once the NPC is facing the enemy or could be *way* off
    if( !GetLeapParameters( PendingLeapRotation, PendingLeapSpeed ) )
        AbortedLeap();

    //DMTNS( "final turning delay" );

    // do final turning + delay
    StopMovement( true, true );
    StartTurnTime = Level.TimeSeconds;
    Focus = None;
    FocalPoint = Pawn.Location + 512.0*vector(PendingLeapRotation);
    FinishRotation( /*DefaultRotationThreshold*/ );
    Sleep( U2Creatures(Pawn).LeapDelayPreJump - (Level.TimeSeconds - StartTurnTime) );

    //DMTNS( "start leap animation" );
    bLeaping = false;
    /*new comment if( U2P.AnimationController.SpecialAnimationLeap() == 0.0 )
    {
        DMTNS( "WARNING: NPC doesn't have a leap animation AnimSequence: " $ Pawn.AnimSequence);
        AbortedLeap();
    }*/

    // the first notify will be used to "refine" the LeapNotifyTime for subsequent jumps
    if( !bLeapNotifyTimeSet )
        U2Creatures(Pawn).LeapNotifyTime = -Level.TimeSeconds;

    // in case notify not present...
    //AddTimer( FakeNotifyLeapBeginTimerName, 2.0, false );
    //new comment AddTimer( FakeNotifyLeapBeginTimerName, 1.0, false );
    Enable('Timer');//new
    SetTimer(2.25, false);//new
    //AddTimer( FakeNotifyLeapBeginTimerName, 0.25, false );

    //DMTNS( "wait for LeapBegin notification" );
    if (CanAttemptLeapAttack())
    {
        U2Creatures(Pawn).bShotAnim = true;
        U2Creatures(Pawn).PlayLeapAnim();
    }
    else
        GotoState('Hunting');
    Stop; // wait for leap begin notification

    //Goto('StartLeap');
StartLeap:
    EnableRotation( false );
    //DMTNS( "leaping" );
    DoLeapAttack( PendingLeapRotation, PendingLeapSpeed );
    NextLeapTime = Level.TimeSeconds + U2Creatures(Pawn).LeapDelaySuccess;
    //DMTNS( "wait for landing" );
    WaitForLanding();
    //DMTNS( "landed" );

    //U2Creatures(Pawn).HandleLeapLandSound(); // sounds in addition to landing thump

    //DMTNS( "landed, not moving for a bit" );
    U2Creatures(Pawn).StopMovement( true, true );
    Sleep( U2Creatures(Pawn).LeapDelayLand );
    EnableRotation( true );

    // turn to enemy (while stationary) before leaving state?
    if( U2Creatures(Pawn).bTurnToEnemyAfterLeap )
    {
        Focus = Enemy;
        //DMTNS( "calling FinishRotation" );
        FinishRotation( /*DefaultRotationThreshold*/ );
        //DMTNS( "called FinishRotation" );
    }

    //DMTNS( "FinishedLeap" );
    FinishedLeap();
    GotoState('Hunting');
} // AttackLeapState


//------------------------------------------Head rotation stuff-------------------------------
simulated function /*event*/ Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (U2Creatures(Pawn).bHeadTrackingEnabled)
    {
        //log("In tick: bHeadTrackingEnabled");
        //UpdateAiming( DeltaTime );
        if( ValidEnemy( Enemy ) && EnemyVisible() )
        {
            //if ( Enemy.GetAimTarget().IsA('XMPRaptor') )  // hack to acct. for offset center
            //  SetDesiredAimingLocation( Enemy.GetAimTarget().Location - vect(0,0,40) );
            //else
                SetDesiredAimingLocation( Enemy.GetAimTarget().Location );
            UpdateAiming( DeltaTime );
        }
        else
            SetDesiredAimingLocation( GetStraightAheadLocation() );
        //else
        //  HandleEnemyLost();
    }
    else
        SetDesiredAimingLocation( GetStraightAheadLocation() );
}



function vector GetStraightAheadLocation()
{
    return ( Pawn.Location + 1024.0*vector(Rotation) );
}

// Returns true if aiming changed, false otherwise.
function UpdateAiming( float DeltaTime )
{
    local vector CurrentAimingDirectionNormal, DesiredAimingDirectionNormal;
    //local vector Axis;
    local float Degrees, MaxDegrees;
    local vector StartLocation;

    // we would like to aim at TargetLocation but we're not allowed to
    // turn faster than a certain rate.
    if( CurrentAimingLocation != DesiredAimingLocation )
    {
        StartLocation = U2Creatures(Pawn).GetViewLocation();
        CurrentAimingDirectionNormal = vector(U2Creatures(Pawn).GetAimingRotation()); //Normal( CurrentAimingLocation - StartLocation );
        DesiredAimingDirectionNormal = Normal( DesiredAimingLocation - StartLocation );

        Degrees = ACos( CurrentAimingDirectionNormal dot DesiredAimingDirectionNormal ) * RadiansToDegrees;
        MaxDegrees = TurningRateDegreesPerSecond*DeltaTime;

        //Normally interpolates the rotation change, but UT2004 doesn't have RotateAngleAxis
        /*if( Degrees > MaxDegrees )
        {
            Axis = Normal( CurrentAimingDirectionNormal cross DesiredAimingDirectionNormal );
            CurrentAimingLocation = StartLocation + 1024*Normal( RotateAngleAxis( CurrentAimingDirectionNormal, Axis, MaxDegrees*DegreesToRotationUnits ) );
        }
        else
        {
            CurrentAimingLocation = DesiredAimingLocation;
        }*/
        CurrentAimingLocation = DesiredAimingLocation;
        U2Creatures(Pawn).SetAimingRotation( CurrentAimingLocation - StartLocation );
    }
}


function SetDesiredAimingLocation( vector NewDesiredAimingLocation )
{
    DesiredAimingLocation = NewDesiredAimingLocation;
    //AddCylinder( DesiredAimingLocation, 8, 8, ColorPink() );
}

function rotator GetAimRotation()
{
    return U2Creatures(Pawn).GetAimingRotation();
}


function rotator GetViewRotation()
{
    return U2Creatures(Pawn).GetAimingRotation();
}

function bool ValidEnemy( Pawn Enemy )
{
    local vector EnemyVector;

    if( Pawn==none ||
        Enemy==none ||
        Pawn.Health <= 0 ||
        Enemy.Health <= 0 ||
        Enemy.Controller == none )
        return false;

    EnemyVector = Normal( Enemy.Location - Pawn.Location );
    if( EnemyVector dot vector(Rotation) < Pawn.PeripheralVision )
        return false;

    return true;
}

//TurningRateDegreesPerSecond=270.000000

defaultproperties
{
     MinHitNonPawnDistance=512.000000
     TurningRateDegreesPerSecond=180.000000
     CombatStyle=1.000000
     ReactionTime=-1.000000
}
