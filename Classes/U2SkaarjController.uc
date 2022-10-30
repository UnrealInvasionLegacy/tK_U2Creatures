class U2SkaarjController extends U2BasicMeleeMonsterController;

const INCOMINGCOLLISIONFUDGE				= 2.0;//from U2NPControllerShared

/*function bool CanAttemptLeapAttack()
{
	return(Super.CanAttemptLeapAttack() && !SkaarjLight(Pawn).bDefensiveMode);
}*/

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	if ( Pawn.PhysicsVolume.bWaterVolume
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z)
		|| !Pawn.bCanCrouch )
		return false;

	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent = Pawn.GetCollisionExtent();
	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	}
	if ( !bSuccess )
		return false;

	if ( HitActor == None )
		HitLocation = Pawn.Location + 240 * duckDir;

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return false;

	if ( bDuckLeft )
		UnrealPawn(Pawn).CurrentDir = DCLICK_Left;
	else
		UnrealPawn(Pawn).CurrentDir = DCLICK_Right;
	//UnrealPawn(Pawn).Dodge(UnrealPawn(Pawn).CurrentDir);
	SkaarjLight(Pawn).U2Dodge(UnrealPawn(Pawn).CurrentDir, true);
	return true;
}

state Charging
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{//log("U2SkaarjController: Charging: MayFall");
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{//log("U2SkaarjController: Charging: TryToDuck");
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy )
			return TryStrafe(duckDir);
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;
//("U2SkaarjController: Charging: StrafeFromDamage");
		if (!Pawn.bCanCrouch) return false;
		if ( FRand() * Damage < 0.15 * CombatStyle * Pawn.Health )
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
		if ( (Pawn.Velocity Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{
		
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;
		//log("Charging: TryStrafe");
		if (!Pawn.bCanStrafe) return false;//new

		Extent = Pawn.GetCollisionExtent();
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		}
		if (HitActor != None)
			return false;

		if ( Pawn.Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir - MAXSTEPHEIGHT * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Pawn.Location + 2 * MINSTRAFEDIST * sideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;
log("U2SkaarjController: Charging: NotifyTakeHit");
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);

		bWasOnGround = (Pawn.Physics == PHYS_Walking);
		if ( Pawn.health <= 0 )
			return;
		if ( StrafeFromDamage(damage, damageType, true) )
			return;
		else if ( bWasOnGround && (MoveTarget == Enemy) &&
					(Pawn.Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	event bool NotifyBump(actor Other)
	{
		//log("U2SkaarjController: Charging: NotifyBump");
		if ( Other == Enemy && Other != SkaarjLight(Pawn).IncomingProxy )
		{
			SkaarjLight(Pawn).DefensiveModeEnd(true);
			DoRangedAttackOn(Enemy);
			return false;
		}
		return Global.NotifyBump(Other);
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function EnemyNotVisible()
	{
		WhatToDoNext(15);
	}

	function EndState()
	{
		if ( (Pawn != None) && Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
	}

Begin:
	//log("Charging: Begin");
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		WhatToDoNext(16);
WaitForAnim:
	//log("U2SkaarjController: Charging: WaitForAnim");
	if ( Monster(Pawn).bShotAnim )
	{	//Monster(Pawn).bShotAnim = false;
		Sleep(0.35);
		Goto('WaitForAnim');
	}
	if ( !FindBestPathToward(Enemy, false,true) )
		GotoState('TacticalMove');
Moving:
	//log("U2SkaarjController: Charging: Moving");
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

function HandleIncoming( Actor IncomingActor, vector IncomingDirection, float IncomingSpeed )
{
	local vector PawnToIncomingVector, PawnToIncomingNormal, LeftVector;
	local vector FuturePawnPosition, FutureIncomingPosition;
	local float IncomingDistance, FutureMissDistance;
	local float ApproximateIntersectTime, CosToIntersect;
	local bool bDodgeRight;
	local eDoubleClickDir CurrentDir;//, OldDir;//new
	local name Anim;
	local float frame,rate;

	//AddCylinder( IncomingActor.Location, 4, 4, ColorRed() );
	//DMTNS( "HandleIncoming : " $ IncomingActor $ " projectile speed: " $ IncomingSpeed $ " Pawn speed: " $ VSize( Pawn.Velocity ) );

	if( Pawn == None || Pawn.Physics == PHYS_Falling || !class'UtilGame'.static.FDecision( SkaarjLight(Pawn).DodgeProjectileOdds ) )
		return; // doesn't dodge incoming projectiles

	if( !CanDodge() )
		return;

	Pawn.GetAnimParams(0,Anim,frame,rate);
	//log("Anim is: "$Anim);
	if (Anim == 'FlipFrwd01_SM' || Anim == 'FlipBack01_SM' || Anim == 'FlipLeft01_SM' || Anim == 'FlipRight01_SM')
		return;

	/* tbd:
	if( GetSkill() < FRand() )
		return;
	*/

	PawnToIncomingVector = IncomingActor.Location - Pawn.Location;
	
	//tbd: what's the best approach, add properties for all of these,
	//support dodging by ducking, jumping up etc.
	PawnToIncomingNormal = Normal( PawnToIncomingVector );

	if( PawnToIncomingNormal dot vector(Pawn.Rotation) < 0.10 ) 
	{
		//DMTNS( "NPC not facing incoming" );
		return; // NPC isn't looking enough towards incoming actor
	}

	// if close/fast decrease odds of reacting
	IncomingDistance = VSize( PawnToIncomingVector );
	//DMTNS( "IncomingDistance: " $ IncomingDistance );

	// see if projectile is likely to hit NPC
	// assumes projectile speed much higher than NPC speed and assumes NPC won't change velocity
	ApproximateIntersectTime = IncomingDistance / VSize( IncomingSpeed*IncomingDirection - Pawn.Velocity );
	
	// where will projectile, NPC be at that time?
	FuturePawnPosition = Pawn.Location + ApproximateIntersectTime * Pawn.Velocity;
	FutureIncomingPosition = IncomingActor.Location + ApproximateIntersectTime * IncomingDirection * IncomingSpeed;
	
	//AddCylinder( FuturePawnPosition, 6, 6, ColorCyan() );
	//AddCylinder( FutureIncomingPosition, 8, 8, ColorOrange() );
	
	FutureMissDistance = VSize( FuturePawnPosition - FutureIncomingPosition );
	//DMTNS( "FutureMissDistance: " $ FutureMissDistance );

	if( FutureMissDistance < (FMax( Pawn.CollisionRadius, Pawn.CollisionHeight ) + INCOMINGCOLLISIONFUDGE) )
	{	
		// tbd: decrease odds as angle to actor relative to NPC's view direction increases
				
		LeftVector = Normal( vector(Pawn.Rotation) cross vect(0,0,1) );

		//AddArrow( Pawn.Location, FutureIncomingPosition, ColorRed() );
		//AddArrow( Pawn.Location, Pawn.Location + 256.0*LeftVector, ColorGreen() );
		//AddArrow( Pawn.Location, Pawn.Location + 256.0*vector(Pawn.Rotation), ColorYellow() );
		
		CosToIntersect = Normal( FutureIncomingPosition - Pawn.Location) dot LeftVector;
		//DMTNS( "Cos: " $ CosToIntersect );
		
		bDodgeRight = false;
		if( CosToIntersect < -0.1 )
			bDodgeRight = true; // intercept point to right
		else if( CosToIntersect < 0.1 && FRand() < 0.50 )
			bDodgeRight = true; // intercept point not to left
		
		//OldDir = UnrealPawn(Pawn).CurrentDir;
		//DMTNS( "  calling TryToDodge: " $ bDodgeRight );
		if( bDodgeRight ) // note: LeftVector is wrt Pawn, TryToDodge uses wrt viewer in front of NPC
		{
			//TryToDodge( LeftVector, false );
			/*UnrealPawn(Pawn).*/CurrentDir = DCLICK_Right;
		}
		else
		{
			//TryToDodge( -LeftVector, true );
			/*UnrealPawn(Pawn).*/CurrentDir = DCLICK_Left;
		}
		//UnrealPawn(Pawn).Dodge(UnrealPawn(Pawn).CurrentDir);
		SkaarjLight(Pawn).U2Dodge(CurrentDir, true);
		//UnrealPawn(Pawn).CurrentDir = OldDir;
	}
}

function bool CanDodge()
{
	return ( Pawn != None && Monster(Pawn).bCanDodge && Pawn.Health > 0 && !Pawn.bIsCrouched && Pawn.Physics == PHYS_Walking );
}	


function ExecuteWhatToDoNext()
{
	bHasFired = false;
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	if ( Pawn == None )
	{
		warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
		return;
	}

	if ( bPreparingMove && Monster(Pawn).bShotAnim )
	{
		Pawn.Acceleration = vect(0,0,0);
		GotoState('WaitForAnim');
		return;
	}
	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		Enemy = None;

	if ( Level.Game.bGameEnded && (Enemy != None) && Enemy.Controller.bIsPlayer )
		Enemy = None;

	if ( (Enemy == None) || !EnemyVisible() )
		FindNewEnemy();

	if ( Enemy != None )
	{//log("ChooseAttackMode");
		ChooseAttackMode();
	}
	else
	{
		U2Creatures(Pawn).bDoingLeapCheck = false;
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
}

defaultproperties
{
     StrafingAbility=-1.000000
}
