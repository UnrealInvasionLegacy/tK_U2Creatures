class U2BasicMeleeMonsterController extends U2MonsterController;

state Hunting
{
ignores EnemyNotVisible;

	/* MayFall() called by] engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		return true;
	}

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup') );
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			if ( Level.timeseconds - ChallengeTime > 7 )
			{
				ChallengeTime = Level.TimeSeconds;
				Monster(Pawn).PlayChallengeSound();
			}
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			Focus = Enemy;
			WhatToDoNext(22);
		}
		else
			Global.SeePlayer(SeenPlayer);
	}

	function Timer()
	{
		SetCombatTimer();
		StopFiring();
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;
		//log("Hunting: PickDestination");
		// If no enemy, or I should see him but don't, then give up
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			Enemy = None;
			WhatToDoNext(23);
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if ( FindBestPathToward(Enemy, true,true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid )
		{
			Enemy = None;
			WhatToDoNext(26);
			return;
		}

		Destination = LastSeeingPos;
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot)
			&& VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

		posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
		{
			Dir = Pawn.Location - LastSeenPos;
			Dir.Z = 0;
			if ( VSize(Dir) < Pawn.CollisionRadius )
			{
				GoalString = "Stakeout 3 from hunt";
				GotoState('StakeOut');
				return;
			}
			Destination = LastSeenPos;
		}
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else
				{
					GoalString = "Stakeout 2 from hunt";
					GotoState('StakeOut');
					return;
				}
			}
		}
	}

	function bool FindViewSpot()
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		// try left and right

		if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}
		if ( FRand() < 0.5 )
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
		else
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
		return true;
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

AdjustFromWall:
	MoveTo(Destination, MoveTarget);

Begin:
	//log("Hunting: Begin");
	WaitForLanding();
	if ( CanSee(Enemy) )
		SeePlayer(Enemy);
WaitForAnim:
	if ( Monster(Pawn).bShotAnim )
	{
		Sleep(0.35);
		Goto('WaitForAnim');
	}
	PickDestination();
	if ( Level.timeseconds - ChallengeTime > 10 )
	{
		ChallengeTime = Level.TimeSeconds;
		Monster(Pawn).PlayChallengeSound();
	}

SpecialNavig:
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget));

	WhatToDoNext(27);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}

function FightEnemy(bool bCanCharge)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle, Aggression;
	local bool bFarAway, bOldForcedCharge;
	local NavigationPoint N;
//log("FightEnemy1");
	if ( (Enemy == None) || (Pawn == None) )
		log("HERE 3 Enemy "$Enemy$" pawn "$Pawn);

	if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
	{//log("FightEnemy2");
		if ( !Enemy.Controller.bIsPlayer )
			FindNewEnemy();

		if ( Enemy == FailedHuntEnemy )
		{
			GoalString = "FAILED HUNT - HANG OUT";
			if ( EnemyVisible() )
				bCanCharge = false;
			else if ( (LastRespawnTime != Level.TimeSeconds) && ((LastSeenTime == 0) || (Level.TimeSeconds - LastSeenTime) > 15) && !Pawn.PlayerCanSeeMe() )
			{
				LastRespawnTime = Level.TimeSeconds;
				EnemyVisibilityTime = 0;
				N = Level.Game.FindPlayerStart(self,1);
				Pawn.SetLocation(N.Location+(Pawn.CollisionHeight - N.CollisionHeight) * vect(0,0,1));
			}
			if ( !EnemyVisible() )
			{
				WanderOrCamp(true);
				return;
			}
		}
	}
//log("FightEnemy3");
	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle;
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle
				+ FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( Enemy.Weapon != None )
		Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;
	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{//log("FightEnemy4");
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
		{
			bFarAway = true;
			Aggression += 0.5;
		}
		else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.CollisionHeight) // below enemy
			Aggression += CombatStyle;
		//log("Aggression:"$Aggression);
	}

	if ( !EnemyVisible() )
	{//log("FightEnemy5");
		GoalString = "Enemy not visible";
		if ( !bCanCharge )
		{//log("6: !bCanCharge");
			GoalString = "Stake Out";
			DoStakeOut();
		}
		else
		{//log("FightEnemy7");
			GoalString = "Hunt";
			GotoState('Hunting');
		}
		return;
	}

	// see enemy - decide whether to charge it or strafe around/stand and fire
	Target = Enemy;
	if( Monster(Pawn).PreferMelee() || (bCanCharge && bOldForcedCharge) )
	{//log("FightEnemy8");
		GoalString = "Charge";
		DoCharge();
		return;
	}

	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{//log("FightEnemy9");
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	if ( !Monster(Pawn).PreferMelee() && (FRand() > 0.17 * (skill - 1)) && !DefendMelee(enemyDist) )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge )
	{//log("FightEnemy10: bCanCharge");
		log("U2BasicMeleeMonsterController: Aggression: "$Aggression);
		if ( Aggression > 1 )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}

	if ( !Pawn.bCanStrafe )
	{//log("FightEnemy11: !bCanStrafe");
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	GoalString = "Do tactical move";
	if ( !Monster(Pawn).RecommendSplashDamage() && Monster(Pawn).bCanDodge && (FRand() < 0.7) && (FRand()*Skill > 3) )
	{//log("FightEnemy12");
		GetAxes(Pawn.Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else
			TryToDuck(Y, false);
	}
	//log("FightEnemy13: DoTacticalMove");
	DoTacticalMove();
}

function WhatToDoNext(byte CallingByte)
{
	//log("WhatToDoNext: CallingByte:"$CallingByte);
	if ( ChoosingAttackLevel > 0 )
		log("CHOOSEATTACKAGAIN in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);

	if ( ChooseAttackTime == Level.TimeSeconds )
	{//log("WhatToDoNext:1");
		ChooseAttackCounter++;
		if ( ChooseAttackCounter > 3 )
			log("CHOOSEATTACKSERIAL in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);
	}
	else
	{//log("WhatToDoNext:2");
		ChooseAttackTime = Level.TimeSeconds;
		ChooseAttackCounter = 0;
	}
	if ( Monster(Pawn).bTryToWalk && (Pawn.Physics == PHYS_Flying) && (ChoosingAttackLevel == 0) && (ChooseAttackCounter == 0) )
	{
		//log("WhatToDoNext:3: TryToWalk");	
		TryToWalk();
	}
	//log("WhatToDoNext:4");
	ChoosingAttackLevel++;
	ExecuteWhatToDoNext();
	ChoosingAttackLevel--;
}


function ExecuteWhatToDoNext()
{
	bHasFired = false;
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	//log("GoalString:"$GoalString);
	if ( Pawn == None )
	{
		warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
		return;
	}

	if ( bPreparingMove && Monster(Pawn).bShotAnim )
	{//log("bPreparingMove and bShotAnim");
		//Pawn.Acceleration = vect(0,0,0);//new comment - want the rammer to attack on the run
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
	{//log("Do ChooseAttackMode");
		ChooseAttackMode();
	}
	else
	{
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
}


function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( Monster(Pawn).bAlwaysStrafe )
		return true;

	if ( !Monster(Pawn).bCanStrafe )
		return false;

	if ( Skill + StrafingAbility < 3 )
		return false;

	if ( WayPoint == Enemy )
	{
		if ( Monster(Pawn).PreferMelee() )
			return false;
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );
	}
	else if ( Pickup(WayPoint) == None )
	{
		N = NavigationPoint(WayPoint);
		if ( (N == None) || N.bNeverUseStrafing )
			return false;

		if ( N.FearCost > 200 )
			return true;
		if ( N.bAlwaysUseStrafing && (FRand() < 0.8) )
			return true;
	}
	if ( Pawn(WayPoint) != None )
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );

	if ( Skill + StrafingAbility < 7 * FRand() - 1 )
		return false;

	if ( Enemy == None )
		return ( FRand() < 0.4 );

	if ( EnemyVisible() )
		return ( FRand() < 0.85 );
	return ( FRand() < 0.6 );
}




/*State WaitForAnim
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	event AnimEnd(int Channel)
	{
		Monster(Pawn).bShotAnim = false;
		Pawn.AnimEnd(Channel);
		if ( !Monster(Pawn).bShotAnim )
			WhatToDoNext(99);
	}
}*/

state Charging
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{//log("Charging: MayFall");
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{//log("Charging: TryToDuck");
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy )
			return TryStrafe(duckDir);
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;
//log("Charging: StrafeFromDamage");
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
		//if (!Pawn.bCanStrafe) return false;//new
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
//log("Charging: NotifyTakeHit");
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
	{//log("Charging: NotifyBump");
		if ( Other == Enemy )
		{
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
	//log("Charging: WaitForAnim");
	if ( Monster(Pawn).bShotAnim )
	{	//Monster(Pawn).bShotAnim = false;
		log("WaitForAnim: bShotAnim");
		Sleep(0.35);
		Goto('WaitForAnim');
	}
	if ( !FindBestPathToward(Enemy, false,true) )
		GotoState('TacticalMove');
Moving:
	//log("Charging: Moving");
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

defaultproperties
{
}
