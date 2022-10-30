class AraknidController extends U2MonsterController;



/*function WhatToDoNext(byte CallingByte)
{
	if ( ChoosingAttackLevel > 0 )
		log("CHOOSEATTACKAGAIN in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);

	if ( ChooseAttackTime == Level.TimeSeconds )
	{
		ChooseAttackCounter++;
		if ( ChooseAttackCounter > 3 )
			log("CHOOSEATTACKSERIAL in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);
	}
	else
	{
		ChooseAttackTime = Level.TimeSeconds;
		ChooseAttackCounter = 0;
	}
	if ( Monster(Pawn).bTryToWalk && (Pawn.Physics == PHYS_Flying) && (ChoosingAttackLevel == 0) && (ChooseAttackCounter == 0) )
		TryToWalk();
	ChoosingAttackLevel++;
	ExecuteWhatToDoNext();
	ChoosingAttackLevel--;
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
*/

defaultproperties
{
}
