class HeavyHuman extends LightHuman; //UScriptAnimMonster;

/*
// Attack damage.
var(Combat) byte
	SwingDamage, KickDamage; //basic damage done by melee attacks




var name MeleeAnims[4];
var name DeathAnims[9];
var name VictoryAnims[14];
var() class<Weapon> WeaponType;

var() array<sound> MeleeSounds[4];
var(Sounds) sound hit;

//Used for chossing different Weapons when e.g. "XWeapons.RocketLauncher" is replaced by something else
var() bool bHasAdded;
*/

var() name StepEvent;
var(Sounds) array<sound> StepSounds[4];






function KickDamageTarget()
{
	if (MeleeDamageTarget(KickDamage, (KickDamage * 8000 * Normal(Controller.Target.Location - Location))) )
		PlaySound(HitSounds[Rand(4)], SLOT_Interact);		
}


function SwingDamageTarget()
{
	if ( MeleeDamageTarget(SwingDamage, (SwingDamage * 7000 * Normal(Controller.Target.Location - Location))) )
		PlaySound(HitSounds[Rand(4)], SLOT_Interact);			
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Velocity) < 10.0 && VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // velocity based
    else if ( VSize(Velocity) > 0.0 )
    {
        Dir = Normal(Velocity*Vect(1,1,0));
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
        PlayAnim('DeathFoldF01',, 0.2);
    else if ( Dir Dot X < -0.7 )
         PlayAnim('DeathStruggleB01',, 0.2);
    else if ( Dir Dot Y > 0 )
        PlayAnim('DeathFallL01',, 0.2);
    else if ( HasAnim('DeathSpinF01') )
        PlayAnim('DeathSpinF01',, 0.2);
    else
        PlayAnim('DeathSitting01',, 0.2); 

}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

	if ( DrivenVehicle != None )
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
        PlayAnim('HitRight01_LG',, 0.1);
    }
    else
    {
        PlayAnim('HitLeft01_LG',, 0.1);
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
	Skins[3]=DeResMat1;
	Skins[4]=DeResMat1;
	Skins[5]=DeResMat1;

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

function FireWeapon()
{
    if(Weapon == none)
        return;
    
    Weapon.FillToInitialAmmo();
   
    Weapon.BotFire(false);
    SetTimer(0.50, false);
       
}


simulated function FootStep()
{
	/*local pawn Thrown;

	TriggerEvent(StepEvent,Self, Instigator);
	//throw all nearby creatures, and play sound
	foreach CollidingActors( class 'Pawn', Thrown,Mass*0.5)
		ThrowOther(Thrown,Mass/12);*/
	Super(U2Creatures).Step();
	PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
}

function ServerStep()
{
	Super(U2Creatures).ServerStep();
	PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
}

function ThrowOther(Pawn Other,int Power)
{
	local float dist, shake;
	local vector Momentum;


	if ( Other.mass >= Mass )
		return;

	if (xPawn(Other)==none)
	{
		if ( Power<400 || (Other.Physics != PHYS_Walking) )
			return;
		dist = VSize(Location - Other.Location);
		if (dist > Mass)
			return;
	}
	else
	{

		dist = VSize(Location - Other.Location);
		//shake = 0.4*FMax(500, Mass - dist);
		shake = 0.6*FMax(500, Mass - dist);
		shake=FMin(2000,shake);
		if ( dist > Mass )
			return;
		if(Other.Controller!=none)
			Other.Controller.ShakeView( vect(0.0,0.02,0.0)*shake, vect(0,1000,0),0.003*shake, vect(0.02,0.02,0.02)*shake, vect(1000,1000,1000),0.003*shake);

		if ( Other.Physics != PHYS_Walking )
			return;
	}

	Momentum = 100 * Vrand();
	Momentum.Z = FClamp(0,Power,Power - ( 0.4 * dist + Max(10,Other.Mass)*10));
	Other.AddVelocity(Momentum);
}


//Code from the HL2-Combine-Monster, used for choosing Weapons
simulated function Tick(float Delta)
{
	if(!bHasAdded && Level.NetMode!=NM_Client)
		AddDefaultInventory();

	Super.Tick(Delta);
}

function AddDefaultInventory() // Only give the startup weapon the pawn desires.
{
	if( Level.bStartUp || bHasAdded || Controller==None ) Return;
	bHasAdded = True;
	if ( WeaponType!=None )
	{
		if( Weapon!=None ) // Make sure if some UT2004 RPG adds gun for me, then kill it!
			Weapon.Destroy();
		Controller.bIsPlayer = True; // Temp hack until I get the gun
		CreateInventory(string(WeaponType));
		Controller.bIsPlayer = False;
	}

	// HACK FIXME
	if ( inventory != None )
		inventory.OwnerEvent('LoadOut');

	Controller.ClientSwitchToBestWeapon();
	SetStartingState();
}
function SetStartingState();


function RangedAttack(Actor A)
{


	local float Dist;

	if ( bShotAnim )
	{
		return;
	}

	Dist = VSize(A.Location - Location);

	//bShotAnim = true;
	if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming  )
	{
		bShotAnim = true;
		SetAnimAction(MeleeAnims[Rand(4)]);
		PlaySound(MeleeSounds[Rand(3)], SLOT_Interact);

		//Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		return;
	}

	else if ( Physics == PHYS_Swimming )
	{
		SetAnimAction(IdleSwimAnim);
	}

	else if (Dist > MeleeRange + CollisionRadius + A.CollisionRadius && Weapon != None && Controller.Enemy != None && Weapon.CanAttack(Controller.Enemy) && Controller.Enemy.Health > 0)
	{
		Weapon.BotFire(false,);
	}
	else if(FRand() <= 0.25 && Weapon != None && Weapon.IsFiring())
	{
		Weapon.StopFire(0);
		Weapon.StopFire(1);
	}

	MonsterController(Controller).DoCharge();
	
}

defaultproperties
{
     StepSounds(0)=Sound'tk_U2Creatures.HvyArmorStep1'
     StepSounds(1)=Sound'tk_U2Creatures.HvyArmorStep2'
     StepSounds(2)=Sound'tk_U2Creatures.HvyArmorStep3'
     StepSounds(3)=Sound'tk_U2Creatures.HvyArmorStep4'
     MeleeAnims(0)="MeleeA"
     MeleeAnims(1)="MeleeB"
     MeleeAnims(2)="MeleeC"
     MeleeAnims(3)="MeleeD"
     VictoryAnims(0)="Taunt01_LG"
     VictoryAnims(1)="Typing01"
     VictoryAnims(2)="Taunt03_LG"
     VictoryAnims(3)="ButtonPress01_LG"
     VictoryAnims(4)="Thrust01_LG"
     VictoryAnims(5)="Victory01_LG"
     VictoryAnims(6)="Victory02_LG"
     VictoryAnims(7)="Victory03_LG"
     VictoryAnims(8)="Wave01_LG"
     VictoryAnims(9)="DialogueTalk01_LG"
     VictoryAnims(10)="LoadGun01_LG"
     VictoryAnims(11)="Salute01_LG"
     VictoryAnims(12)="Taunt01_LG"
     VictoryAnims(13)="Thrust01_LG"
     StepShakeRadius=1024.000000
     StepShakeMagnitude=7.000000
     StepShakeDuration=0.400000
     GibGroupClass=Class'tk_U2Creatures.HumanMetalGibGroup'
     WallDodgeAnims(0)="DodgeFrwd_Fr01_LG"
     WallDodgeAnims(1)="DodgeBack_Fr01_LG"
     WallDodgeAnims(2)="DodgeLeft_Fr01_LG"
     WallDodgeAnims(3)="DodgeRight_Fr01_LG"
     IdleHeavyAnim="IdleWaitBreath02_LG"
     IdleRifleAnim="IdleWaitBreath03_LG"
     FireHeavyRapidAnim="Still_Fr01_LG"
     FireRifleRapidAnim="Still_Fr01_LG"
     MeleeRange=40.000000
     GroundSpeed=105.000000
     AirSpeed=250.000000
     WalkingPct=1.000000
     Health=300
     MovementAnims(0)="WalkFrwd_Fr01_LG"
     MovementAnims(1)="WalkBack_Fr01_LG"
     MovementAnims(2)="WalkLeft_Fr01_LG"
     MovementAnims(3)="WalkRight_Fr01_LG"
     TurnLeftAnim="TurnLeft01_LG"
     TurnRightAnim="TurnRight01_LG"
     CrouchAnims(0)="DuckWalk_Fr01_LG"
     CrouchAnims(1)="DuckWalk_Fr01_LG"
     CrouchAnims(2)="DuckWalk_Fr01_LG"
     CrouchAnims(3)="DuckWalk_Fr01_LG"
     WalkAnims(0)="WalkFrwd_Fr01_LG"
     WalkAnims(1)="WalkBack_Fr01_LG"
     WalkAnims(2)="WalkLeft_Fr01_LG"
     WalkAnims(3)="WalkRight_Fr01_LG"
     AirAnims(0)="Jump_Fr01_LG"
     AirAnims(1)="Jump_Fr01_LG"
     AirAnims(2)="Jump_Fr01_LG"
     AirAnims(3)="Jump_Fr01_LG"
     LandAnims(0)="Land_Fr01_LG"
     LandAnims(1)="Land_Fr01_SS"
     LandAnims(2)="Land_Fr01_LG"
     LandAnims(3)="Land_Fr01_LG"
     DodgeAnims(0)="DodgeFrwd_Fr01_LG"
     DodgeAnims(1)="DodgeBack_Fr01_LG"
     DodgeAnims(2)="DodgeLeft_Fr01_LG"
     DodgeAnims(3)="DodgeRight_Fr01_LG"
     AirStillAnim="Jump_Fr01_LG"
     CrouchTurnRightAnim="DuckWalk_Fr01_LG"
     CrouchTurnLeftAnim="DuckWalk_Fr01_LG"
     IdleCrouchAnim="DuckIdle_Fr01_LG"
     IdleSwimAnim="Tread_Fr01_LG"
     IdleWeaponAnim="IdleWaitBreath01_LG"
     IdleRestAnim="IdleWaitBreath01_LG"
     IdleChatAnim="IdleChat01_LG"
     DrawScale=0.800000
     PrePivot=(Z=8.000000)
     CollisionRadius=34.000000
     CollisionHeight=70.000000
     Mass=1000.000000
     RotationRate=(Pitch=2000,Yaw=10000,Roll=0)
}
