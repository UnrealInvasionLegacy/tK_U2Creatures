//=============================================================================
// CollisionProxyIncoming.uc
// $Author: Mfox $
// $Date: 6/25/02 11:38p $
// $Revision: 2 $
//=============================================================================

class CollisionProxyIncoming extends CollisionProxy;

var array<name> TouchClassNames;
var name TouchEvent;

//-----------------------------------------------------------------------------

function AddClass( name TouchClassName )
{
	TouchClassNames[ TouchClassNames.Length ] = TouchClassName;
}

//-----------------------------------------------------------------------------

function SetEvent( name Event )
{
	TouchEvent = Event;
}

//-----------------------------------------------------------------------------

event Touch( Actor Other )
{
	local int ii;
		
	if( TouchTarget != None && TouchTarget.IsA('SkaarjLight') && Other.Owner != TouchTarget )
	{
		for( ii=0; ii<TouchClassNames.Length; ii++ )
		{
			if( Other.IsA( TouchClassNames[ ii ] ) )
			{
				SkaarjLight(TouchTarget).TriggerDodge( Other, None, TouchEvent );
				break;
			}
		}
	}
}

//-----------------------------------------------------------------------------

defaultproperties
{
}
