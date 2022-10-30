//=============================================================================
// CollisionProxy.uc
// $Author: Mfox $
// $Date: 4/30/02 12:22p $
// $Revision: 3 $
//=============================================================================

class CollisionProxy extends Actor
	abstract;

//-----------------------------------------------------------------------------

var Actor TouchTarget;

//-----------------------------------------------------------------------------

function CP_SetCollisionSize( float NewCollisionRadius, float NewCollisionHeight )
{
	SetCollisionSize( NewCollisionRadius, NewCollisionHeight );
}

//-----------------------------------------------------------------------------

function CP_SetCollision( optional bool bNewColActors, optional bool bNewBlockActors, optional bool bNewBlockPlayers )
{
	SetCollision( bNewColActors, bNewBlockActors, bNewBlockPlayers );
}

//-----------------------------------------------------------------------------

function CP_SetLocation( vector NewLocation )
{
	SetLocation( NewLocation );
}

//-----------------------------------------------------------------------------

function CP_SetTouchTarget( Actor NewTouchTarget )
{
	TouchTarget = NewTouchTarget;
}

//-----------------------------------------------------------------------------

event Touch( Actor Other )
{
	if( TouchTarget != None )
		TouchTarget.Touch( Other );
}

//-----------------------------------------------------------------------------

event UnTouch( Actor Other )
{
	if( TouchTarget != None )
		TouchTarget.UnTouch( Other );
}

//-----------------------------------------------------------------------------

defaultproperties
{
     bHidden=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
