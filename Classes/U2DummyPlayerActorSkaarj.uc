//=============================================================================
// DummyPlayerActor - This is the visual representation of the pawn when it is 
// being eaten by the spider. Cheap and crappy. Should be redone.
// (c) milk@rbthinktank.com
//=============================================================================

class U2DummyPlayerActorSkaarj extends U2DummyPlayerActor;

Simulated function PostBeginPlay()
{

	Super.PreBeginPlay();
	TimerI=0;
	SetTimer(0.1, true);
	TimeToDestroy=Level.TimeSeconds+4.5;

}

defaultproperties
{
}
