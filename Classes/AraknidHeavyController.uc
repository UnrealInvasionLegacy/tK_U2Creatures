//=============================================================================
// Monster Controller - simple AI that always has and hunts down player enemy
//=============================================================================
class AraknidHeavyController extends MonsterController;

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function bool Stopped()
	{
		return true;
	}

	function CancelCampFor(Controller C)
	{
		DoTacticalMove();
	}

	function StopFiring()
	{
		Global.StopFiring();
		if ( bHasFired )
		{
			bHasFired = false;
			WhatToDoNext(32);
		}
	}

	function EnemyNotVisible()
	{
		//let attack animation complete
		WhatToDoNext(33);
	}

	function Timer()
	{
		if ( Monster(Pawn).PreferMelee() )
		{
			SetCombatTimer();
			StopFiring();
			WhatToDoNext(34);
		}
		else
			TimedFireWeaponAtEnemy();
	}

	function DoRangedAttackOn(Actor A)
	{
		Target = A;
		GotoState('RangedAttack');
	}

	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		Pawn.Acceleration = vect(0,0,0); //stop
		if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in ranged attack");
	}

Begin:
	bHasFired = false;
	GoalString = "Ranged attack";
	Focus = Target;
	Sleep(0.0);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
	}
	bHasFired = true;
	if ( Target == Enemy )
		TimedFireWeaponAtEnemy();
	else
		FireWeaponAt(Target);
	Sleep(0.1);
	if ( Monster(Pawn).PreferMelee() || (Target == None) || (Target != Enemy) || Monster(Pawn).bBoss )
		WhatToDoNext(35);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(FMax(Monster(Pawn).RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	WhatToDoNext(36);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

defaultproperties
{
     CombatStyle=1.000000
}
