class LightHumanAngel extends LightHuman;//U2Creatures;

function PlayChallengeSound()
{
    PlaySound(AcquireSounds[Rand(7)],SLOT_Talk);
}

function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlayAnim(VictoryAnims[Rand(14)]);
    PlaySound(TauntSounds[Rand(8)],SLOT_Talk);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
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

simulated function PlayDirectionalHit(Vector HitLoc)
{
    /*local Vector X,Y,Z, Dir;

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
        PlayAnim('HitGut01_SH',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('HitHead01_SH',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('HitRight01_SH',, 0.1);
    }
    else
    {
        PlayAnim('HitLeft01_SH',, 0.1);
    }*/
}

defaultproperties
{
     MeleeAnims(0)="Melee_Swing_Fr01_LG"
     MeleeAnims(1)="Melee_Swing_Fr01_LG"
     MeleeAnims(2)="Melee_Swing_Fr01_LG"
     DeathAnims(2)="DeathSitting01"
     VictoryAnims(0)="Taunt03_LG"
     VictoryAnims(1)="Taunt03_LG"
     VictoryAnims(2)="Taunt03_LG"
     VictoryAnims(3)="SignalGo_LG"
     VictoryAnims(4)="SignalHurry_LG"
     VictoryAnims(5)="Victory01_LG"
     VictoryAnims(6)="SignalStop_LG"
     VictoryAnims(7)="LoadGun01_LG"
     VictoryAnims(8)="Wave01_LG"
     VictoryAnims(9)="IdleWaitLook01_LG"
     VictoryAnims(10)="IdleWaitLook01_LG"
     VictoryAnims(11)="SignalGo_LG"
     VictoryAnims(12)="Wave01_LG"
     VictoryAnims(13)="LoadGun01_LG"
     TauntSounds(0)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011a'
     TauntSounds(1)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011b'
     TauntSounds(2)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011c'
     TauntSounds(3)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011d'
     TauntSounds(4)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011e'
     TauntSounds(5)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011f'
     TauntSounds(6)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011g'
     TauntSounds(7)=Sound'tk_U2Creatures.Female23Voice_EndSkirmish.Heat_01_005'
     AcquireSounds(0)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_006'
     AcquireSounds(1)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_006a'
     AcquireSounds(2)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_008'
     AcquireSounds(3)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_009'
     AcquireSounds(4)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_023'
     AcquireSounds(5)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_023a'
     AcquireSounds(6)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_026'
     HitSound(0)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003a'
     HitSound(1)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003b'
     HitSound(2)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003g'
     HitSound(3)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003d'
     DeathSound(0)=Sound'tk_U2Creatures.Female23Voice_DieHard.Pain_01_005i'
     DeathSound(1)=Sound'tk_U2Creatures.Female23Voice_DieHard.Pain_01_006l'
     DeathSound(2)=Sound'tk_U2Creatures.Female23Voice_DieHard.Pain_01_006o'
     DeathSound(3)=Sound'tk_U2Creatures.Female23Voice_DieHard.Pain_01_008h'
     ChallengeSound(0)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_006a'
     ChallengeSound(1)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_008'
     ChallengeSound(2)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_026'
     ChallengeSound(3)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_009'
     WallDodgeAnims(0)="DodgeFrwd_Fr01_LG"
     WallDodgeAnims(1)="DodgeBack_Fr01_LG"
     WallDodgeAnims(2)="DodgeLeft_Fr01_LG"
     WallDodgeAnims(3)="DodgeRight_Fr01_LG"
     IdleHeavyAnim="IdleWaitBreathe01_LG"
     IdleRifleAnim="IdleWaitBreathe01_LG"
     FireHeavyRapidAnim="Still_Fr01_LG"
     FireRifleRapidAnim="Still_Fr01_LG"
     bIsFemale=True
     ControllerClass=Class'tk_U2Creatures.MarineController'
     MovementAnims(0)="RunFrwd_Fr01_LG"
     MovementAnims(1)="RunBack01_LG"
     MovementAnims(2)="RunLeft_Fr01_LG"
     MovementAnims(3)="RunRight_Fr01_LG"
     SwimAnims(0)="ProneCrawl_Fr01_LG"
     SwimAnims(1)="ProneCrawl_Fr01_LG"
     SwimAnims(2)="ProneCrawl_Fr01_LG"
     SwimAnims(3)="ProneCrawl_Fr01_LG"
     CrouchAnims(0)="DuckWalk_Fr01_LG"
     CrouchAnims(1)="DuckWalk_Fr01_LG"
     CrouchAnims(2)="DuckWalk_Fr01_LG"
     CrouchAnims(3)="DuckWalk_Fr01_LG"
     WalkAnims(0)="WalkFrwd01_LG"
     WalkAnims(1)="WalkFrwdHalf01_LG"
     WalkAnims(2)="WalkLeft_Fr01_LG"
     WalkAnims(3)="WalkRight_Fr01_LG"
     AirAnims(0)="JumpFrwd01_FT"
     AirAnims(1)="JumpBack01_FT"
     AirAnims(2)="JumpLeft01_FT"
     AirAnims(3)="JumpRight01_FT"
     LandAnims(0)="Land_Fr01_LG"
     DodgeAnims(0)="DodgeFrwd_Fr01_LG"
     DodgeAnims(1)="DodgeBack_Fr01_LG"
     DodgeAnims(2)="DodgeLeft_Fr01_LG"
     DodgeAnims(3)="DodgeRight_Fr01_LG"
     AirStillAnim="Jump01_LG"
     IdleCrouchAnim="DuckBreathe_Fr01_LG"
     IdleSwimAnim="ProneCrawl_Fr01_LG"
     IdleWeaponAnim="IdleWaitBreathe01_LG"
     IdleRestAnim="IdleWaitBreathe01_LG"
     IdleChatAnim="TypeRp01_LG"
     PrePivot=(Z=-6.000000)
     Mass=200.000000
}
