class U2CreaturesUtil extends actor
	abstract;
/*
//Slight changes from the Unreal 2 version
static final function MakeShake( Actor Context, vector ShakeLocation, float ShakeRadius, float ShakeMagnitude, optional float ShakeDuration )
{
	local Controller C;
	local PlayerController Player;
	local float Dist,Pct;

	if( Context==None || ShakeRadius<=0 || ShakeMagnitude<=0 )
		return;

	for( C=Context.Level.ControllerList; C!=None; C=C.nextController )
	{
		Player = PlayerController(C);
		//NEW (mib) - don't shake a flying / ghosted player (leave shake in for matinee cutscenes)
		if( Player!=None && (Player.Pawn!=None && Player.Pawn.Physics != PHYS_Flying) )
		/*OLD
		if( Player!=None )
		*/
		{
			Dist = VSize(ShakeLocation-Player.Pawn.Location);

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
}*/

/*static final function bool FDecision( float Odds ) // NEW (mdf) returns true if 0.0 < FRand() <= Odds
{
	local float rand;
	
	rand = FRand();
	if ( (0.0 < rand) && (rand <= Odds) )
		return true;
	return false;
}*/

defaultproperties
{
}
