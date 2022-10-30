//=============================================================================
// UtilGame.uc
// $Author: Mfox $
// $Date: 1/05/03 8:45p $
// $Revision: 38 $
//=============================================================================
//NEW: file

class UtilGame extends Actor // never instantiated and extending Actor makes things easier
	abstract;

//=============================================================================
// Game-level utility functions, e.g. inventory, actor searching, AI. 
//=============================================================================

const MaxFilteredActors		= 10;

const NonPawnGravityFactor	= 0.500;	// amount we need to scale gravity by for Newtonian physics calculations to work
const PawnGravityFactor		= 1.000;	// pawns seem to fall under 2x the gravity of other actors...?

// debug
const TimeFieldSize			=  8;
const NameFieldSize			= 15;
const StateFieldSize		= 32;
const PrefixFieldSize		=  5;

const MaxPathCheckRadius	= 1300;		// (PathsMaxDist+100)

const Radians45				= 0.785398; // 45 degrees in radians


//=============================================================================

enum ETrajectoryType
{
	TRAJ_None,
	TRAJ_Low,			// only check/return low trajectory
	TRAJ_High,			// only check/return high trajectory
	TRAJ_PreferLow,		// check/return low first, then check/return high if low fails
	TRAJ_PreferHigh,	// check/return high first, then check/return low if high fails
};

enum ELeapResult
{
	LR_None,			// no solution or blocked
	LR_OutOfRange,		// destination is too far to reach
	LR_OutOfAngle,		// angle between vector to destination and Pawn's rotation is too great
	LR_Success,			// found a valid solution
};

enum EDistanceFilterType
{
	DFT_First,
	DFT_Closest,
	DFT_Furthest,
	DFT_Any,
};

enum EVisibilityFilterType
{
	VFT_None,
	VFT_Visible,
	VFT_FOV,
};

var int VerifyTrajectorySamples;
var float VerifyTrajectoryHorizontalExtentPadding;
var float VerifyTrajectoryVerticalExtentPadding;
var int MaxPredictProjectileAttempts;
var float PredictProjectileThreshold;

var float MinTargetBlockedMissMultiplier;
var float MaxTargetBlockedMissMultiplier;
var float MinTargetBlockedPitchError;
var float MaxTargetBlockedPitchError;
var float MinModifyForSpreadDistance;
var float MinPitchError;
var float MaxPitchError;

var private name LastDebugName;

struct Face
{
	var array<vector> Points;
	//tbd: var vector FaceNormal;
};

const CCFloatHeight					= 6.0;		//NEW (mdf) 
//-----------------------------------------------------------------------------
// Spawn and add to inventory if not already present. If an item of the same
// class is present, return that one.

static final function Inventory GiveInventoryClass( Pawn TargetPawn, class<Inventory> InvClass )
{
	local Inventory Inv, InvNew;

	//TargetPawn.DMTNS( "GiveInventoryClass " $ InvClass );
	//class'UtilGame'.static.DumpInventory( TargetPawn, "GiveInventoryClass BEGIN" );
	if( InvClass != None )
	{
		Inv = TargetPawn.FindInventoryType( InvClass );
		if( Inv == None /*|| Inv.bMergesCopies*/ )
		{
			InvNew = TargetPawn.Spawn( InvClass );
			if( InvNew != None )
				InvNew.GiveTo( TargetPawn );
		}
	}
	//class'UtilGame'.static.DumpInventory( TargetPawn, "GiveInventoryClass END" );
	if( Inv != None )
		return Inv;
	else
		return InvNew;
}

//-----------------------------------------------------------------------------
// Spawn and add to inventory if not already present.

static final function Inventory GiveInventoryString( Pawn TargetPawn, coerce string InventoryString )
{
	return GiveInventoryClass( TargetPawn, class<Inventory>(DynamicLoadObject( InventoryString, class'Class' )) );
}

//-----------------------------------------------------------------------------
// Add to inventory if not already present.

static final function bool GiveInventory( Pawn TargetPawn, Inventory Inv )
{
	local Inventory MatchingInv;

	if( Inv != None )
	{
		MatchingInv = TargetPawn.FindInventoryType( Inv.Class );
		if( MatchingInv == None )
		{
			Inv.GiveTo( TargetPawn );
			return true;
		}
	}

	return false;
}

//-----------------------------------------------------------------------------

static final function bool RemoveInventoryString( Pawn TargetPawn, coerce string InventoryString )
{
	local Inventory Inv;
	local class<Inventory> RemovedClass;

	if( InventoryString != "" )
		RemovedClass = class<Inventory>(DynamicLoadObject( InventoryString, class'Class' ));
	else
		RemovedClass = class'Inventory';

	if( RemovedClass != None )
	{
		for( Inv = TargetPawn.Inventory; Inv != None; Inv = Inv.Inventory )
		{
			if( Inv.IsA( RemovedClass.Name ) )
				Inv.Destroy(); //removes inventory as well
		}
	}

	return (RemovedClass != None);
}

//-----------------------------------------------------------------------------
// Return inventory item from holder's inventory matching class 'InventoryType'

static final function Inventory GetInventoryItem( Pawn InventoryHolder, class<Inventory> InventoryType )
{
	local Inventory CurrentInventoryItem;
	local Inventory FoundInventoryItem;

	if( InventoryHolder == None )
		return None;

	for( CurrentInventoryItem = InventoryHolder.Inventory;
			( ( None != CurrentInventoryItem ) && ( None == FoundInventoryItem ) );
			CurrentInventoryItem = CurrentInventoryItem.Inventory )
	{
		if( ClassIsChildOf( CurrentInventoryItem.Class, InventoryType ) )
		{
			FoundInventoryItem = CurrentInventoryItem;
		}
	}
	
	return FoundInventoryItem;
}

//-----------------------------------------------------------------------------

static final function int GetInventoryCount( Pawn InventoryHolder, class<Inventory> InventoryType )
{
	local Inventory CurrentInventoryItem;
	local int InventoryCount;

	for( CurrentInventoryItem = InventoryHolder.Inventory;
			CurrentInventoryItem != None;
			CurrentInventoryItem = CurrentInventoryItem.Inventory )
	{
		if( CurrentInventoryItem.IsA( InventoryType.Name ) )
		{
			InventoryCount++;
		}
	}
	
	return InventoryCount;
}

//-----------------------------------------------------------------------------
// Checks whether P has the given weapon in its inventory, spawning one and
// giving it to P if necessary.

static final function Weapon ForceWeaponIntoInventory( Pawn P, class<Weapon> WeapClass )
{
	local Inventory Inv;
	local Weapon Weap;

	//class'UtilGame'.static.DumpInventory( P, "ForceWeaponIntoInventory BEGIN" );
	// see if already in inventory
	Inv = P.FindInventoryType( WeapClass );
	if( Inv == None )
	{
		//P.DMTNS( "ForceWeaponIntoInventory spawning " $ WeapClass );
		Weap = P.Spawn( WeapClass );
		Weap.GiveTo( P );
	}
	else
	{
		Weap = Weapon( Inv );
	}

	//class'UtilGame'.static.DumpInventory( P, "ForceWeaponIntoInventory END" );
	
	return Weap;
}

//-----------------------------------------------------------------------------
// Note: Weap can be None to specify that the Pawn should be holding no weapon.

static final function MakeWeaponCurrent( Pawn P, Weapon Weap )
{
	//#debug   P.Controller.StopFiring( 0.5, SFI_WeaponSwitch, GetContext() );
	//#release P.Controller.StopFiring( 0.5, SFI_WeaponSwitch );

	P.PendingWeapon = Weap;
	if( P.PendingWeapon == P.Weapon )
		P.PendingWeapon = None;
	if( P.PendingWeapon == None )
		return;

	if( P.Weapon == None )
		P.ChangedWeapon();

	if( P.Weapon != P.PendingWeapon )
		P.Weapon.PutDown();
}

//-----------------------------------------------------------------------------
// Note: can use WeapClass=None to specify that the Pawn shouldn't be holding a
// weapon.

static final function Weapon SetCurrentWeaponClass( Pawn P, class<Weapon> WeapClass )
{
	local Weapon Weap;

 	if( WeapClass != None )
 	{
 		Weap = ForceWeaponIntoInventory( P, WeapClass );
 		
 		if( P.Weapon != Weap )
 			MakeWeaponCurrent( P, Weap );
 	}
 	
	return Weap;
}

//-----------------------------------------------------------------------------
// Makes sure Pawn has the given weapon in his inventory and makes it the 
// currently selected weapon. Makes sure that the Pawn has the default amount
// of ammo for the weapon. Can use WeaponClassString="" to specify that the
// Pawn shouldn't be holding a weapon.

static final function Weapon SetCurrentWeaponString( Pawn P, string WeaponClassString )
{
	local Weapon Weap;
	local class<Weapon> WeapClass;

	if( P != None )
	{
		if( WeaponClassString != "" )
			WeapClass = Class<Weapon>( DynamicLoadObject( WeaponClassString, Class'Class' ) );

		// set even if DynamicLoadObject fails to make problem obvious
		Weap = SetCurrentWeaponClass( P, WeapClass );
	}

	// !!mdf-tbr?:
//	if( Weap == None && WeaponClassString != "" )
//		P.DMTN( "SetCurrentWeaponString -- couldn't set weapon to: " $ WeaponClassString );

	return Weap;
}

//=============================================================================
//@ Misc
//=============================================================================




//-----------------------------------------------------------------------------

//Slight changes from the Unreal 2 version
simulated static final function MakeShake( Actor Context, vector ShakeLocation, float ShakeRadius, float ShakeMagnitude, optional float ShakeDuration )
{
	local Controller C;
	local PlayerController Player;
	local float Dist, Pct;

	if( Context==None || ShakeRadius<=0 || ShakeMagnitude<=0 )
		return;


	for( C=Context.Level.ControllerList; C!=None; C=C.nextController )
	{
		Player = PlayerController(C);
		
		//NEW (mib) - don't shake a flying / ghosted player (leave shake in for matinee cutscenes)
		if( Player!=None && (Player.Pawn!=None && Player.Pawn.Physics != PHYS_Flying) )
		{
			Dist = VSize(ShakeLocation-Player.Pawn.Location);
			
			//log("UtilGame: Dist is: "$Dist);
			if( Dist<=ShakeRadius )
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
	}
}



//-----------------------------------------------------------------------------

static final function bool VertexWithinDistance( Actor A, array<Face> Faces, float MaxDistance )
{
	local float Distance;
	local int ii, jj;
	
	for( ii=0; ii<Faces.Length; ii++ )
	{
		for( jj=0; jj<Faces[ jj ].Points.Length; jj++ )
		{
			Distance = VSize( A.Location - Faces[ ii ].Points[ jj ] );
			if( Distance < MaxDistance )
				return true;
		}
	}
	
	return false;
}


//-----------------------------------------------------------------------------
// 
static function bool CutsceneIsRunning( actor ContextActor )
{
	local SceneManager SM;
	foreach ContextActor.AllActors( class'SceneManager', SM )
	{
		if( SM.bIsRunning )
			return true;
	}
	return false;
}


//=============================================================================
//@ Projectile Motion 
//=============================================================================

static final function float GetGravityConstant( Actor SourceActor, class<Actor> ProjectileClass )
{
	if( ClassIsChildOf( ProjectileClass, class'Pawn' ) )
		return -PawnGravityFactor * SourceActor.PhysicsVolume.default.Gravity.Z;
	else
		return -NonPawnGravityFactor * SourceActor.PhysicsVolume.default.Gravity.Z;
}

/*-----------------------------------------------------------------------------
The range of a projectile (horizontal distance traveled before the projectile
is back at the starting height is given by:

	Range = speed^2 * sin( 2*theta ) / g

where

	speed = initial speed
	theta = initial angle above horizontal
	g     = gravity
	
Unreal's simulated physics are close enough to Newtonian physics for these
equations to work fine as long as the gravity is scaled by a "magic" fudge
factor to get the gravity "right".
*/

static final function float GetRange( Actor SourceActor, class<Actor> ProjectileClass, float ProjectileSpeed, float Theta )
{
	return ProjectileSpeed * ProjectileSpeed * sin( 2*Theta ) / GetGravityConstant( SourceActor, ProjectileClass );
}

/*-----------------------------------------------------------------------------
The maximum range of a projectile (see GetRange equation) occurs when the
sin( 2*Theta) component is maximized, which will occur when 2*Theta = 90 
degrees since sin(90) = 1.0.
	
	RangeMax = speed^2 / g
*/

static final function float GetMaxRange( Actor SourceActor, class<Actor> ProjectileClass, float ProjectileSpeed )
{
	return ProjectileSpeed * ProjectileSpeed / GetGravityConstant( SourceActor, ProjectileClass );
}

/*-----------------------------------------------------------------------------
The best reference for this is probably "Inverse Trajectory Determination" from
Game Programming Gems 2 (Aaron Nicholls).

If we have

V = initial velocity
X = target distance from start
Y = target elevation relative to start elevation
G = gravity

the angle needed to have the fired projectile pass through X,Y is given by

	Theta = invtan[ V^2[ -X +/- sqrt( (X^2 - G^2*X^4/V^4 + 2G*X^2*Y/V^2) / G*X^2 ) ]]

and the time to the target is given by

	T = X / (V * cos(Theta))

Returns the number of solutions found:

	0: target is outside of projectile's range (try 45 degrees?)
	1: target is at projectile's range
	2: target is inside projectile's range (high and low solutions)
	
Note that if the target is inside the projectile'salways be 2 solutions, one
using a lower/flatter trajectory, the other using a higher/more arcing 
trajectory. In general, the lower trajectory is more desirable as it will get
the projectile to the target more quickly, but there are cases where the higher
trajectory may be desired, e.g. to "mix up" shots or to shoot over an 
obstruction.

Use VerifyTrajectory to check whether the trajectory is likely to intersect
with any geometry.
*/

static final function int GetInverseTrajectory( 
	Actor SourceActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	vector StartLocation, 
	vector TargetLocation, 
	out float ThetaLow, 
	out float ThetaHigh, 
	out float InterceptTimeLow, 
	out float InterceptTimeHigh )
{
	local float V;
	local float G;
	local float X, Y;
	local float Root, SquareRoot;
	local float XSquared, VSquared, GXSquared;
	local float TempFloat;
	local int NumSolutions;

	if( ProjectileSpeed ~= 0.0 )
		return 0;

	V = ProjectileSpeed;
	X = VSize2D( TargetLocation - StartLocation );
	Y = -(TargetLocation.Z - StartLocation.Z);
	
	G = GetGravityConstant( SourceActor, ProjectileClass );

	//SourceActor.DMTNS( "GetInveseTrajectory BEGIN" );
	//SourceActor.DMTNS( "  TargetDistance:  " $ VSize( TargetLocation - StartLocation ) );
	//SourceActor.DMTNS( "  ProjectileSpeed: " $ ProjectileSpeed );
	//SourceActor.DMTNS( "  Gravity:         " $ G );
	//SourceActor.DMTNS( "  MaxRange (flat): " $ GetMaxRange( SourceActor, ProjectileClass, ProjectileSpeed ) );
	
	XSquared = X*X;		
	VSquared = V*V;
	
	Root = XSquared - (G*G*XSquared*XSquared/(VSquared*VSquared)) + (2*G*XSquared*Y/VSquared);
	
	//SourceActor.DMTNS( "  V:    " $ V );
	//SourceActor.DMTNS( "  G:    " $ G );
	//SourceActor.DMTNS( "  X:    " $ X );
	//SourceActor.DMTNS( "  Y:    " $ Y );
	//SourceActor.DMTNS( "  Root: " $ Root );
	
	if( Root < 0 )
	{
		NumSolutions = 0;
	}
	else
	{
		GXSquared = G*XSquared;
			
		if( Root ~= 0 )
		{
			ThetaLow = ATan( -X / G*XSquared, VSize(TargetLocation - StartLocation) );
			ThetaHigh = ThetaLow;

			InterceptTimeLow = X / (V * Cos( ThetaLow ));
			InterceptTimeHigh = InterceptTimeLow;
			
			NumSolutions = 1;
		}
		else
		{
			SquareRoot = Sqrt( Root );
			
			//ThetaLow = ATan( VSquared*(-X + SquareRoot) / GXSquared, VSize(TargetLocation - StartLocation) );
			//ThetaHigh = ATan( VSquared*(-X - SquareRoot) / GXSquared, VSize(TargetLocation - StartLocation) );

			//arctan(x) = arcsin(x / (sqrt(1-(x^2)))
			ThetaLow = ASin( (VSquared*(-X + SquareRoot) / GXSquared)/(Sqrt(1+(Square(VSquared*(-X + SquareRoot) / GXSquared)))) );
			ThetaHigh = ASin( (VSquared*(-X + SquareRoot) / GXSquared)/(Sqrt(1+(Square(VSquared*(-X + SquareRoot) / GXSquared)))) );			
			if( Abs( ThetaHigh ) < Abs( ThetaLow ) )
			{
				//SourceActor.DMT( "  swapping ThetaLo and ThetaHi" );
				TempFloat = ThetaHigh;
				ThetaHigh = ThetaLow;
				ThetaLow = TempFloat;
			}
			
			InterceptTimeLow = X / (V * Cos( ThetaLow ));
			InterceptTimeHigh = X / (V * Cos( ThetaHigh ));
			
			NumSolutions = 2;
		}
	}
	
	//SourceActor.DMTNS( "  ThetaLow:  " $ ThetaLow $  " Time: " $ InterceptTimeLow );
	//SourceActor.DMTNS( "  ThetaHigh: " $ ThetaHigh $ " Time: " $ InterceptTimeHigh );
	//SourceActor.DMTNS( "GetInveseTrajectory END  NumSolutions: " $ NumSolutions );
	
	return NumSolutions;
}

/*-----------------------------------------------------------------------------
Return false if any of several lines along trajectory are blocked by anything
apart from the target actor. Also return false if the projectile won't arive 
before it expires (non-zero LifeSpan).

The location of the projectile at time T is given by:

	X = X0 + Vx * t
	Y = Y0 + Vy * t + 1/2 * gt^2

or, if we shift the projectile start to the origin:

	X = Vx * t
	Y = Vy * t + 1/2 * gt^2	
	
where

X0 = starting X position
Y0 = starting Y position
Vx = horizontal component of initial velocity
Vy = vertical component of initial velocity
G  = gravity

and
	
	Vx = V * cos( Theta )
	Vy = V * sin( Theta )
*/

static final function bool VerifyTrajectory( 
	Actor SourceActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	vector StartLocation, 
	vector TargetLocation, 
	Actor TargetActor, 
	float Theta, 
	optional float InterceptTime, 
	optional vector Extents, 
	optional float MinTimeOutDistance )
{
	local float G;
	local float X, Y;
	local float VX, VY;
	local float SampleTime, TimeIncrement;
	local int ii;
	local vector SampleLocation, PreviousLocation, ProjectileDirection;
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	local bool bValid;
	
	//SourceActor.DMTNS( "VerifyTrajectory BEGIN" );
	//SourceActor.DMTNS( "  Theta: " $ Theta );
	//log( "VerifyTrajectory BEGIN" );
	//log( "  Theta: " $ Theta );
	
	//AddCylinder( StartLocation, 4, 4, ColorWhite() );
	//AddCylinder( TargetLocation, 4, 4, ColorWhite() );

	bValid = true;

	if( InterceptTime <= 0.0 )
	{
		if( ProjectileSpeed ~= 0.0 )
		{
			bValid = false;
		}
		else
		{
			// caller wants us to determine the intercept time
			InterceptTime = VSize2D( TargetLocation - StartLocation) / (ProjectileSpeed * cos( Theta ) );
			//log( "  InterceptTime: " $ InterceptTime );
		}
	}
	
	VX = ProjectileSpeed * cos( Theta );
	VY = ProjectileSpeed * sin( Theta );

	G = GetGravityConstant( SourceActor, ProjectileClass );

	ProjectileDirection = TargetLocation - StartLocation;
	ProjectileDirection.Z = 0;
	ProjectileDirection = Normal( ProjectileDirection );

	// return false if the projectile be within X units of the target before it expires
	if( ProjectileClass != None && ProjectileClass.default.LifeSpan > 0.0 && InterceptTime > ProjectileClass.default.LifeSpan )
	{
		//SourceActor.DMTNS( "  Projectile LifeSpan too short checking timeout distance  InterceptTime: " $ InterceptTime );
		
		SampleTime = ProjectileClass.default.LifeSpan;
		
		X = VX * SampleTime;
		Y = VY * SampleTime + 0.5 * G * SampleTime*SampleTime;

		SampleLocation = StartLocation + X * ProjectileDirection;
		SampleLocation.Z = SampleLocation.Z - Y;
		if( VSize( SampleLocation - TargetLocation ) > MinTimeOutDistance )
			bValid = false;
	}

	if( bValid )
	{
		SampleTime = 0.0;
		TimeIncrement = InterceptTime / default.VerifyTrajectorySamples;

		//AddCylinder( StartLocation, 4, 4, ColorYellow() );
		
		//SourceActor.DMTNS( "  TargetActor: " $ TargetActor $ " Gravity: " $ G $ " target distance: " $ VSize( TargetLocation - StartLocation ) $ " TargetHeight: " $ TargetLocation.Z );
		
		PreviousLocation = StartLocation;
		PreviousLocation.Z += default.VerifyTrajectoryVerticalExtentPadding; // so first trace doesn't hit level below source
		
		// needed since the predicted trajectory isn't exactly what we'll get (should be dead-on in X/Y though)
		Extents.X += default.VerifyTrajectoryHorizontalExtentPadding;
		Extents.Y += default.VerifyTrajectoryHorizontalExtentPadding;
		Extents.Z += default.VerifyTrajectoryVerticalExtentPadding;
		
		for( ii=0; ii<default.VerifyTrajectorySamples; ii++ )
		{
			//!!hack: if "projectile" is a pawn, back up the last sample somewhat
			//if( ii == (default.VerifyTrajectorySamples-1) && ClassIsChildOf( ProjectileClass, class'Pawn' ) )
			//	TimeIncrement *= 0.5;

			SampleTime += TimeIncrement;
			
			X = VX * SampleTime;
			Y = VY * SampleTime + 0.5 * G * SampleTime*SampleTime;

			SampleLocation = StartLocation + X * ProjectileDirection;
			SampleLocation.Z = SampleLocation.Z - Y;

			// for the last sample, shift the location up by vertical padding or else 
			// we'll pbly trace into the world geometry below the target locationa
			if( ii == (default.VerifyTrajectorySamples-1) )
			{
				//SourceActor.DMTNS( "  Shifting SampleLocation up by " $ default.VerifyTrajectoryVerticalExtentPadding );
				SampleLocation.Z += default.VerifyTrajectoryVerticalExtentPadding;
			}
			//SourceActor.DMTNS( "  X: " $ X $ " Y: " $ Y $ " Height: " $ SampleLocation.Z );
			
			//!!mdf-tbd: should we worry about (dynamic) actors when tracing?
			// yes, so we'll hit XMP items?
			HitActor = SourceActor.Trace( HitLocation, HitNormal, SampleLocation, PreviousLocation, false, Extents, /*, TRACE_AllBlocking*/ );
			//HitActor = SourceActor.Trace( HitLocation, HitNormal, SampleLocation, PreviousLocation, false, Extents, , TRACE_World );
			
			if( HitActor == None )
			{
				//!!mdf-tbd: static meshes don't generally block extent traces so try a no-extent trace
				//this might catch some cases but without proper extent collision it won't be perfect
				//this check can be removed if we assume that levels with the GL used by NPCs or
				//leaping NPCs will have extent collision added as needed.
				//!!mdf-tbd: possible optimization, especially in areas with low ceilings
				// check the entire trajectory with single line traces first
				HitActor = SourceActor.Trace( HitLocation, HitNormal, SampleLocation, PreviousLocation, false, vect(0,0,0), /*, TRACE_World*/ );
				
				//if( HitActor != None && HitActor != TargetActor )
				//	SourceActor.DMTNS( "  no-extent trace hit " $ HitActor );
			}
			
			if( HitActor != None && HitActor != TargetActor && Theta ~= -Radians45 )
			{
				//SourceActor.DMTNS( "  checking for max range hit" );
				//SourceActor.DMTNS( "    SampleLocation.Z: " $ SampleLocation.Z );
				//SourceActor.DMTNS( "    TargetLocation.Z: " $ TargetLocation.Z );
				// hack for using maximum range -- allow a hit below or past target location
				if( SampleLocation.Z < TargetLocation.Z )
					HitActor = TargetActor;
			}
		
			//!!tbd: call OKToHit on HitActor instead of just checking if we hit TargetActor?
			if( HitActor != None && HitActor != TargetActor )
			{
				//SourceActor.DMTNS( "  failed - hit: " $ HitActor $ " instead of " $ TargetActor );
				//AddArrow( PreviousLocation, SampleLocation, ColorRed() );
				//AddCylinder( SampleLocation, Extents.X, Extents.Z, ColorRed() );
				bValid = false;
				break;
			}
			else
			{
				//AddArrow( PreviousLocation, SampleLocation, ColorYellow() );
			}
			
			if( HitActor == TargetActor )
				break;
						
			PreviousLocation = SampleLocation;
		}
	}
	
	//SourceActor.DMTNS( "VerifyTrajectory END: " $ bValid );
	
	return bValid;
}

/*-----------------------------------------------------------------------------
Wrapper for GetInverseTrajectory / VerifyTrajectory. Calculates solution for
specified trajectory (low and/or high) then verifies that the trajector is 
valid.
*/

static final function bool GetVerifiedInverseTrajectory( 
	Actor SourceActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	vector StartLocation, 
	vector TargetLocation, 
	Actor TargetActor, 
	ETrajectoryType TrajectoryType, 
	out float Theta, 
	out float InterceptTime, 
	optional vector Extents, 
	optional float MinTimeOutDistance )
{
	local int NumSolutions;
	local float ThetaLow, ThetaHigh, InterceptTimeLow, InterceptTimeHigh;
	local bool bTriedHi;
	local bool bSuccess;
		
	//SourceActor.DMTNS( "GetVerifiedInverseTrajectory BEGIN" );
	NumSolutions = GetInverseTrajectory( SourceActor, ProjectileClass, ProjectileSpeed, StartLocation, TargetLocation, ThetaLow, ThetaHigh, InterceptTimeLow, InterceptTimeHigh );

	//log( "  NumSolutions: " $ NumSolutions );
	if( NumSolutions == 1 )
	{
		// only one trajectory (45 degrees)
		//SourceActor.DMTNS( "  checking only solution (45 degrees)" );
		if( VerifyTrajectory( SourceActor, ProjectileClass, ProjectileSpeed, StartLocation, TargetLocation, TargetActor, ThetaLow, InterceptTimeLow, Extents, MinTimeOutDistance ) )
		{
			Theta = ThetaLow;
			InterceptTime = InterceptTimeLow;
			bSuccess = true;
		}
	}
	else if( NumSolutions == 2 )
	{
		// 2 possible trajectories
		if( TrajectoryType == TRAJ_High || TrajectoryType == TRAJ_PreferHigh )
		{
			// try high first
			//SourceActor.DMTNS( "  checking high solution" );
			Theta = ThetaHigh;
			InterceptTime = InterceptTimeHigh;
			bTriedHi = true;
		}
		else
		{
			// try low first
			//SourceActor.DMTNS( "  checking low solution" );
			Theta = ThetaLow;
			InterceptTime = InterceptTimeLow;
			bSuccess = true;
		}

		bSuccess = VerifyTrajectory( SourceActor, ProjectileClass, ProjectileSpeed, StartLocation, TargetLocation, TargetActor, Theta, InterceptTime, Extents, MinTimeOutDistance );
		
		if( !bSuccess && TrajectoryType != TRAJ_High && TrajectoryType != TRAJ_Low )
		{
			if( bTriedHi )
			{
				// now check low
				//SourceActor.DMTNS( "  checking low solution" );
				Theta = ThetaLow;
				InterceptTime = InterceptTimeLow;
			}
			else
			{
				// now check high
				//SourceActor.DMTNS( "  checking high solution" );
				Theta = ThetaHigh;
				InterceptTime = InterceptTimeHigh;
			}
			
			bSuccess = VerifyTrajectory( SourceActor, ProjectileClass, ProjectileSpeed, StartLocation, TargetLocation, TargetActor, Theta, InterceptTime, Extents, MinTimeOutDistance );
		}
	}
	
	//log( "GetVerifiedInverseTrajectory END  bSuccess: " $ bSuccess );
	return bSuccess;		
}
		
//-----------------------------------------------------------------------------

static final function ELeapResult VerifyLeapParameters( 
	Actor SourceActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	vector TargetLocation, 
	vector StartLocation, 
	Actor TargetActor, 
	ETrajectoryType TrajectoryType, 
	out float Theta, 
	optional vector Extents )
{
	local float InterceptTime;
	local ELeapResult Result;

	//log("SourceActor: "@SourceActor@" ProjectileClass: "@ProjectileClass@" ProjectileSpeed: "@ProjectileSpeed);
	//log("TargetLocation: "@TargetLocation@" StartLocation: "@StartLocation@" TargetActor: "@TargetActor);
	//log("TrajectoryType:"@GetEnum(enum'ETrajectoryType',TrajectoryType)@" Theta: "@Theta@" Extents: "@Extents);
	// don't bother with trajectory calculation if predicted location isn't within range 
	if( VSize( TargetLocation - SourceActor.Location ) > GetMaxRange( SourceActor, ProjectileClass, ProjectileSpeed ) )
	{
		Result = LR_OutOfRange;
	}
	else if( !GetVerifiedInverseTrajectory( 
		SourceActor, 
		ProjectileClass, 
		ProjectileSpeed, 
		SourceActor.Location, 
		TargetLocation, 
		TargetActor, 
		TrajectoryType, 
		Theta, 
		InterceptTime, 
		Extents ) )
	{
		Result = LR_None;
	}
	else if( Normal( TargetLocation - SourceActor.Location ) dot vector( SourceActor.Rotation ) < 0.707 )
	{
		Result = LR_OutOfAngle;
	}
	else
	{
		Result = LR_Success;
	}
	
	//log( "  VerifyLeapParameters returning " $ GetEnum( enum'ELeapResult', Result ) );
	return Result;
}
	
//=============================================================================
//@ Aiming
//=============================================================================

static final function vector GetRotatedFireStart( Pawn SourcePawn, vector SourceLocation, rotator TargetRotation, vector FireOffset )
{
	local vector X, Y, Z;
	local vector ReturnedFireStart;
	
	GetAxes( TargetRotation, X, Y, Z );
	
	ReturnedFireStart = SourceLocation + SourcePawn.EyePosition() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	
	// prone NPCs are getting a fire start that is in the ground?
	ReturnedFireStart.Z = FMax( SourceLocation.Z - 0.5*SourcePawn.CollisionHeight, ReturnedFireStart.Z );
	
	//SourcePawn.DMTNS( "GetRotatedFireStart returning " $ ReturnedFireStart );
	//SourcePawn.DMTNS( "  TargetRotation: " $ TargetRotation );
	//SourcePawn.DMTNS( "  EyePosition:    " $ TargetPawn.EyePosition() );
	return ReturnedFireStart;
}

//-----------------------------------------------------------------------------


/*-----------------------------------------------------------------------------
Determine a good vector along which to intentionally miss the given target
actor based on the direction that the actor is facing. If the actor is an NPC
or if the actor (player) is generally facing the NPC, the NPC shouldn't favor 
missing in either direction (ReverseOdds ~0.50), otherwise, the NPC should try 
to miss along the given vector (ReverseOdds < 0.50) so that the player sees the
shots pass in front of him for greater effect.
*/

static final function vector GetMissVector( 
	Actor AimingActor,
	Actor TargetActor, 
	float LastHitTime,
	float MaxAffectedByHitTime,
	float MaxHitMissMultiplier,
	float MinHitPitchError,
	float MaxHitPitchError,	
	float LastAcquisitionTime,
	float MaxAffectedByAcquisitionTime,
	float MaxAcquireMissMultiplier,
	float MinAcquirePitchError,
	float MaxAcquirePitchError,
	bool bTargetObscured,					// true ==> don't have LOS to target (e.g. smoke in way)
	out int PitchError )
{
	local vector TargetVector;
	local vector TargetFacingVector;
	local vector MissVector;
	local float CosFacingAngle;
	local float ReverseOdds;
	local float TimeSinceLastHit;
	local float TimeSinceLastAcquired;
	local float PitchAdjustMultiplier;
	local int AddedPitchError;
	
	TargetVector = Normal( AimingActor.Location - TargetActor.Location );
	TargetFacingVector = vector(TargetActor.Rotation);
	CosFacingAngle = TargetVector dot TargetFacingVector;
	//DMTNS( "angle: " $ RadiansToDegrees * ACos( CosFacingAngle ) $ "(" $ CosFacingAngle $ ")" );
	
	if( TargetActor.IsA('Pawn') && Pawn(TargetActor).Controller != None && Pawn(TargetActor).Controller.bIsPlayer && Abs( CosFacingAngle ) < 0.866 )
	{
		//DMTNS( "target not facing NPC" );
//		ReverseOdds = 0.25; // player generally facing across firing direction -- favor shots in front 
		ReverseOdds = 0.0; // player generally facing across firing direction -- favor shots in front 
	}
	else
	{
		//DMTNS( "target facing NPC" );
		ReverseOdds = 0.50; // player generally facing along firing direction -- don't favor shots in front 
	}

	//DMTNS( "ReverseOdds: " $ ReverseOdds );
	
	MissVector = Normal( TargetVector cross vect(0,0,1) ); // vector across firing direction
	
	if( (MissVector dot TargetFacingVector) < 0 )
		MissVector = -MissVector;
			
	if( FDecision( ReverseOdds ) )
		MissVector = -MissVector;

	// when missing, miss by more than usual if recently hit?
	TimeSinceLastHit = AimingActor.Level.TimeSeconds - LastHitTime;
	if( TimeSinceLastHit < MaxAffectedByHitTime )
	{
		MissVector *= MaxHitMissMultiplier*(MaxAffectedByHitTime - TimeSinceLastHit);
		AddedPitchError = (MaxHitPitchError - FRand()*(MaxHitPitchError - MinHitPitchError))*(MaxAffectedByHitTime - TimeSinceLastHit);
		PitchError += AddedPitchError;

		//AimingActor.DMTNS( "increased PitchError by " $ AddedPitchError $ " due to taking hit " $ TimeSinceLastHit $ " secs ago" );
	}
	
	// when missing, miss by more than usual if recently acquired?
	TimeSinceLastAcquired = AimingActor.Level.TimeSeconds - LastAcquisitionTime;
	if( TimeSinceLastAcquired < MaxAffectedByAcquisitionTime )
	{
		MissVector *= MaxAcquireMissMultiplier*(MaxAffectedByAcquisitionTime - TimeSinceLastAcquired);
		AddedPitchError = (MaxAcquirePitchError - FRand()*(MaxAcquirePitchError - MinAcquirePitchError))*(MaxAffectedByAcquisitionTime - TimeSinceLastAcquired);
		PitchError += AddedPitchError;
		
		//AimingActor.DMTNS( "increased PitchError by " $ AddedPitchError $ " due to acquired " $ TimeSinceLastAcquired $ " secs ago" );
	}
	
	if( bTargetObscured )
	{
		MissVector *= default.MinTargetBlockedMissMultiplier + default.MaxTargetBlockedMissMultiplier * FRand();
		AddedPitchError = default.MinTargetBlockedPitchError - FRand()*(default.MaxTargetBlockedPitchError - default.MinTargetBlockedPitchError);
		PitchError += AddedPitchError;
		
		//AimingActor.DMTNS( "increased PitchError by " $ AddedPitchError $ " due to target being obscured" );
	}
	
	// scale pitch error depending on how much target is facing aiming actor
	// so shots generally tend to pass in front of the target (more exciting)
	if( TargetActor.IsA('Pawn') && Pawn(TargetActor).Controller != None && Pawn(TargetActor).Controller.bIsPlayer )
	{
		// scale by 1.0 (target facing aiming actor) to 0.1 (target facing completely across firing direction or away from aiming actor)
		PitchAdjustMultiplier = FMax( 0.1, 0.9 * CosFacingAngle + 0.1 );
		PitchError *= PitchAdjustMultiplier;
	}
	
	PitchError = FClamp( PitchError, default.MinPitchError, default.MaxPitchError );
	
	//AddArrow( TargetActor.Location, TargetActor.Location + 64.0*MissVector, ColorCyan() );
	
	return MissVector;
}
	


/*-----------------------------------------------------------------------------
Iterative approach to determining predicted location when using projectile
physics with a moving target. If the location can be predicted it is returned
in PredictedLocation, otherwise the given location is returned unmodified.

!!mdf-tbd: location prediction code should take geometry into account and try
to place the moving actor on the floor if walking (same thing with other
movement prediction code afaik).

!!mdf-tbd: this seems to work really well - is it worth trying to come up with 
a non-iterative equation?
*/

static final function GetBestPredictedProjectileLocation( 
	Actor AimingActor, 
	Actor TargetActor, 
	class<Actor> ProjectileClass, 
	float ProjectileSpeed, 
	float DelayTime,
	vector StartLocation,
	float TargetDistance,
	bool bUseHighTrajectory,
	out vector TargetLocation )
{
	local int NumSolutions;
	local float ThetaLow, ThetaHigh;
	local float InterceptTime, InterceptTimeLow, InterceptTimeHigh;
	local vector CurrentTargetLocation, CurrentPredictedLocation;
	local float DistanceDelta;
	local vector SavedLocation, PredictedMoveVector;
	local int Attempt;	
	
	// note: assumes we are heading towards target actor (e.g. as opposed to a last seen position)
	CurrentTargetLocation = TargetActor.Location;

	for( Attempt=0; Attempt<default.MaxPredictProjectileAttempts; Attempt++ )
	{
		// break when we get an acceptible result or determine that there is no solution?
		NumSolutions = GetInverseTrajectory( AimingActor, ProjectileClass, ProjectileSpeed, StartLocation, CurrentTargetLocation, ThetaLow, ThetaHigh, InterceptTimeLow, InterceptTimeHigh );
		
		//AddCylinder( CurrentTargetLocation, TargetActor.CollisionRadius, TargetActor.CollisionHeight, ColorBlue() );
		if( NumSolutions == 0 )
		{
			if( ProjectileSpeed ~= 0.0 )
			{
				TargetLocation = CurrentTargetLocation;
				return;
			}

			InterceptTime = TargetDistance / (0.5*ProjectileSpeed);
		}
		else if( bUseHighTrajectory )
		{
			InterceptTime = InterceptTimeHigh;
		}
		else
		{
			InterceptTime = InterceptTimeLow;
		}
		
		// use delay + trajectory intercept times to determine where target will be then
		PredictedMoveVector = (InterceptTime + DelayTime) * TargetActor.Velocity;
		
		// see how far target will be able to move in that direction
		SavedLocation = TargetActor.Location;
		TargetActor.Move( PredictedMoveVector/*, true*/ );
		if( TargetActor.Location != (SavedLocation + PredictedMoveVector ) )
		{
			// target will hit a wall or something so aim for that location
			TargetLocation = TargetActor.Location;
			TargetActor.SetLocation( SavedLocation );
			return;
		}
		CurrentPredictedLocation = TargetActor.Location;
		TargetActor.SetLocation( SavedLocation );
		
		//AddCylinder( CurrentPredictedLocation, TargetActor.CollisionRadius, TargetActor.CollisionHeight, ColorCyan() );

		// how far off are we?
		DistanceDelta = VSize( CurrentTargetLocation - CurrentPredictedLocation );

		//AimingActor.DMTNS( "delta for attempt #" $ Attempt $ " is: " $ DistanceDelta );
		if( DistanceDelta <= default.PredictProjectileThreshold )
		{
			TargetLocation = CurrentTargetLocation;		
			return;
		}
		
		// try half way?
		CurrentTargetLocation += 0.5*(CurrentPredictedLocation - CurrentTargetLocation);
	}
}

//=============================================================================
//@ Searching
//=============================================================================

static final function bool VerifyNamedActor( Actor A, bool bAllowUnSafe )
{
	if( bAllowUnSafe )
		return true;

	//A.DMTNS( "Warning: GetFilteredActors used to find a named non-editor placed actor (this is unreliable): " $ A $ "!" );
	return false;
}

//-----------------------------------------------------------------------------
// Search for closest actor to InstanceActor which matches given ClassName 
// (bIsA=false) or IsA(ClassName) (bIsA=true). Returns None if no such actor
// found. Matches with InstanceActor are NOT filtered out.

static final function Actor GetClosestOfClass( Actor InstanceActor, name ClassName, bool bIsA )
{
	local Actor A;
	local float MinDist;
	local float Distance;
	local Actor Closest;

	// try to match closest actor with same class (not including super classes) as given name
	Closest = None;
	MinDist = 999999;

	foreach InstanceActor.AllActors( class'Actor', A )
	{
		if( A.Class.Name == ClassName || (bIsA && A.IsA(ClassName)) )
		{
			Distance = VSize( InstanceActor.Location - A.Location );
			if( Distance < MinDist )
			{
				Closest = A;
				MinDist = Distance;
			}
		}
	}

	return Closest;
}


//-----------------------------------------------------------------------------

static final function bool FindActorByName( Actor SearchingActor, Name ActorName, out Actor FoundActor )
{
	local Actor CurrentActor;
	local bool bFoundActor;
	
	foreach SearchingActor.AllActors( class'Actor', CurrentActor )
	{
		if( CurrentActor.Name == ActorName )
		{
			FoundActor = CurrentActor;
			bFoundActor = true;
			break;
		}
	}

	return bFoundActor;
}

//-----------------------------------------------------------------------------
// GetClosestActor
//
// Returns the Actor of the specified class which is closest to the OriginActor
// and withing the specified MaxSearchRadius (if 0 any distance is valid).
//
// Optimized for NavigationPoints, Controllers and Projectiles (including 
// but this can still be a very slow call).
										 
static final function Actor GetClosestActor( Actor OriginActor, class<Actor> ClassToSearchFor, optional float MaxSearchRadius )
{
	local Controller C;
	local NavigationPoint NP;
	local Actor A;
	local float DistanceBetweenActors;

	local float ClosestDistance;
	local Actor ClosestActor;

	ClosestDistance = 999999.9;

	if( MaxSearchRadius ~= 0.0 )
		MaxSearchRadius = 999999.9;

	// optimize special cases
	if( ClassIsChildOf( ClassToSearchFor, class'Controller' ) )
	{
		// optimization for Controllers
	  	for( C=OriginActor.Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.IsA( ClassToSearchFor.Name ) )
			{
				DistanceBetweenActors = VSize( C.Pawn.Location - OriginActor.Location );	
	
				if( DistanceBetweenActors <= MaxSearchRadius && DistanceBetweenActors < ClosestDistance )
				{
					ClosestActor = C;
					ClosestDistance = DistanceBetweenActors;
				}
			}
		}
	}
	else if( ClassIsChildOf( ClassToSearchFor, class'NavigationPoint' ) )
	{
		// optimization for NavigationPoints
	  	for( NP=OriginActor.Level.NavigationPointList; NP!=None; NP=NP.NextNavigationPoint )
		{
			if( NP.IsA( ClassToSearchFor.Name )	)
			{
				DistanceBetweenActors = VSize( NP.Location - OriginActor.Location );	
	
				if( DistanceBetweenActors <= MaxSearchRadius && DistanceBetweenActors < ClosestDistance )
				{
					ClosestActor = NP;
					ClosestDistance = DistanceBetweenActors;
				}
			}
		}
	}
	else
	{
		//mjl-tbd: have this search the LevelInfo's ActorLists for a thing of the appropriate class, and use it
		// general case -- slooow
	  	foreach OriginActor.AllActors( ClassToSearchFor, A )
		{
			DistanceBetweenActors = VSize( A.Location - OriginActor.Location );	

			if( DistanceBetweenActors <= MaxSearchRadius && DistanceBetweenActors < ClosestDistance )
			{
				ClosestActor = A;
				ClosestDistance = DistanceBetweenActors;
			}
		}
	}

	return ClosestActor;
}

//=============================================================================
//@ Visibility
//=============================================================================

//-----------------------------------------------------------------------------
// Allows you to check if an object is in your view.
//-----------------------------------------------------------------------------
// ViewVec:	A vector facing "forward"						(relative to your location.)
// DirVec:	A vector pointing to the object in question.	(relative to your location.)
// FOVCos:	Cosine of how many degrees between ViewVec and DirVec to be seen.
//-----------------------------------------------------------------------------
// REQUIRE: FOVCos > 0
// NOTE: While normalization is not required for ViewVec or DirVec, it helps
// if both vectors are about the same size.
//-----------------------------------------------------------------------------

static final function bool IsInViewCos( vector ViewVec, vector DirVec, float FOVCos )
{
	local float CosAngle;		//cosine of angle from object's LOS to WP
    
    CosAngle = Normal( ViewVec ) dot  Normal( DirVec );

	//The first test makes sure the target is within the firer's front 180o view.
	//The second test might look backwards, but it isn't.  Since cos(0) == 1,
	//as the angle gets smaller, CosAngle *increases*, so an angle less than
	//the max will have a larger cosine value.
	
	return (0 <= CosAngle && FOVCos < CosAngle);
}

//-----------------------------------------------------------------------------
// Allows you to check if an object is in your view.
//-----------------------------------------------------------------------------
// ViewVec:	A vector facing "forward"						(relative to your location.)
// DirVec:	A vector pointing to the object in question.	(relative to your location.)
// FOV:		How many degrees the target must be within to be seen.
//-----------------------------------------------------------------------------
// REQUIRE: FOV < 90
// NOTE: While normalization is not required for ViewVec or DirVec, it helps
// if both vectors are about the same size.
//-----------------------------------------------------------------------------

static final function bool IsInView( vector ViewVec, vector DirVec, float FOV )
{
	return IsInViewCos( ViewVec, DirVec, cos( ( 2 * Pi ) / ( 360 / FOV ) ) );
}

//-----------------------------------------------------------------------------
// Returns true if the first Actor has an uninterrupted LOS to the second actor.

static final function bool SLCActorCanSeeActor( Actor SourceActor, Actor TargetActor )
{
	local vector TraceHitLocation, TraceHitNormal;

	// can we trace a line from the source actor to the target actor?
	return( SourceActor.Trace( 
		   		TraceHitLocation, 
		   		TraceHitNormal,		
		   		TargetActor.Location, 
		   		SourceActor.Location, 
		   		true ) == TargetActor );
}

//-----------------------------------------------------------------------------
// Returns true if Target is in within given FOVCos wrt SeeingActor.
//-----------------------------------------------------------------------------

static final function bool ActorLookingAt( Actor SeeingActor, Actor Target, float FOVCos )
{
	//2002.12.19 (mdf) warning fix
	if( Target == None || SeeingActor == None )
		return false;

	return IsInViewCos( vector(SeeingActor.Rotation), Target.Location - SeeingActor.Location, FOVCos );
}


//-----------------------------------------------------------------------------
// Check for line of sight to target DeltaTime from now. Moved here from 
// Controller hierarchy but not called from anywhere currently (tbr?).

static final function bool CheckFutureSight( Pawn SourcePawn, Actor TargetActor, float DeltaTime )
{
	local vector FutureLoc;

	if( TargetActor == None )
		return false;

	if( VSize( SourcePawn.Velocity ) ~= 0.0 )
		FutureLoc = SourcePawn.Location;
	else
		FutureLoc = SourcePawn.Location + SourcePawn.GroundSpeed * Normal( SourcePawn.Velocity ) * DeltaTime;

	if( SourcePawn.Base != None ) 
		FutureLoc += SourcePawn.Base.Velocity * DeltaTime;

	//make sure won't run into something
	if( !SourcePawn.FastTrace( FutureLoc, SourcePawn.Location ) && ( SourcePawn.Physics != PHYS_Falling ) )
		return false;

	//check if can still see target actor
	if( SourcePawn.FastTrace( TargetActor.Location + TargetActor.Velocity * DeltaTime, FutureLoc ) )
		return true;

	return false;
}

//-----------------------------------------------------------------------------

static final function bool FDecision( float Odds ) // NEW (mdf) returns true if 0.0 < FRand() <= Odds
{
	local float rand;
	
	rand = FRand();
	if ( (0.0 < rand) && (rand <= Odds) )
		return true;
	return false;
}

static final function float VSize2D( vector V )
{
    return Sqrt(Square(V.X) + Square(V.Y));
}

defaultproperties
{
     VerifyTrajectorySamples=8
     VerifyTrajectoryVerticalExtentPadding=8.000000
     MaxPredictProjectileAttempts=16
     PredictProjectileThreshold=16.000000
     MaxTargetBlockedMissMultiplier=3.000000
     MinTargetBlockedPitchError=-1024.000000
     MaxTargetBlockedPitchError=4096.000000
     MinModifyForSpreadDistance=512.000000
     MinPitchError=-1024.000000
     MaxPitchError=4096.000000
}
