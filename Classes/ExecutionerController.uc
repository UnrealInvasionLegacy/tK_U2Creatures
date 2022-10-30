//=============================================================================
// Executioner Controller - Monster controller that won't track dead players
// Meant to stop monsters like the Skaarj and Tosc from attacking grabbed players
//=============================================================================
class ExecutionerController extends MonsterController;

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
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)  ) )
		Enemy = None;

	if ( Level.Game.bGameEnded && (Enemy != None) && Enemy.Controller.bIsPlayer )
		Enemy = None;

	if ( (Enemy == None) || !EnemyVisible() || (Enemy != None && (Enemy.Health <= 0) ) )
		FindNewEnemy();

	if ( Enemy != None && !(Enemy.Health < 0) )
		ChooseAttackMode();
	else
	{
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
}



state Hunting
{
ignores EnemyNotVisible;

	/* MayFall() called by] engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		if (XPawn(Enemy).Health <= 0)
			return false;
		else
			return true;
	
	}

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup') );
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy && !(Enemy.Health > 0) )
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
	WaitForLanding();
	if ( CanSee(Enemy) && !(Enemy.Health <= 0) )
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



state StakeOut
{
ignores EnemyNotVisible;

	function bool CanAttack(Actor Other)
	{
		return true;
	}

	function bool Stopped()
	{
		return true;
	}

	event SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy && Enemy.Health > 0 )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			if ( FRand() < 0.5 )
			{
				Focus = Enemy;
				FireWeaponAt(Enemy);
			}
			WhatToDoNext(28);
		}
		else if ( SetEnemy(SeenPlayer) )
		{
			if ( Enemy == SeenPlayer && Enemy.Health > 0  )
			{
				VisibleEnemy = Enemy;
				EnemyVisibilityTime = Level.TimeSeconds;
				bEnemyIsVisible = true;
			}
			else
			{
				bEnemyIsVisible = false;
			}
			WhatToDoNext(29);
		}
	}
	/* DoStakeOut()
	called by ChooseAttackMode - if called in this state, means stake out twice in a row
	*/
	function DoStakeOut()
	{
		SetFocus();
		if ( (FRand() < 0.3) || !FastTrace(FocalPoint + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location + vect(0,0,0.8) * Pawn.CollisionHeight) )
			FindNewStakeOutDir();
		GotoState('StakeOut','Begin');
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
		{
			if ( InstigatedBy == Enemy )
				AcquireTime = Level.TimeSeconds;
			WhatToDoNext(30);
		}
	}

	function Timer()
	{
		enable('NotifyBump');
		SetCombatTimer();
	}


	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Pawn.Location);
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			Dir = N.Location - Pawn.Location;
			Dist = VSize(Dir);
			if ( (Dist < MAXSTAKEOUTDIST) && (Dist > MINSTRAFEDIST) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( Level.Game.bTeamgame )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}
		if ( Best != None )
			FocalPoint = Best.Location + 0.5 * Pawn.CollisionHeight * vect(0,0,1);
	}

	function SetFocus()
	{
		if ( bEnemyInfoValid )
			FocalPoint = LastSeenPos;
		else
			FocalPoint = Enemy.Location;
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		SetFocus();
		if ( !bEnemyInfoValid || !ClearShot(FocalPoint,false) || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
			FindNewStakeOutDir();
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

Begin:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	CheckIfShouldCrouch(Pawn.Location,FocalPoint, 1);
	FinishRotation();
	if ( Monster(Pawn).HasRangedAttack() && (FRand() < 0.5) && (VSize(Enemy.Location - FocalPoint) < 150)
		 && (Level.TimeSeconds - LastSeenTime < 4) && ClearShot(FocalPoint,true) )
	{
		FireWeaponAt(Enemy);
	}
	else
		StopFiring();
	Sleep(1 + FRand());
	// check if uncrouching would help
	if ( Pawn.bIsCrouched
		&& !FastTrace(FocalPoint, Pawn.Location + Pawn.EyeHeight * vect(0,0,1))
		&& FastTrace(FocalPoint, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1)) )
	{
		Pawn.bWantsToCrouch = false;
		Sleep(0.15 + 0.05 * (1 + FRand()) * (10 - skill));
	}
	WhatToDoNext(31);
	if ( bSoaking )
		SoakStop("STUCK IN STAKEOUT!");
}

defaultproperties
{
}
