class SkaarjAlpha extends SkaarjMedium;


function PostBeginPlay()
{


    Super(SkaarjLight).PostBeginPlay();
    bMeleeFighter = true;


        Skins[0] = Texture'tk_U2Creatures.MeshU2SkaarjMediumTex0';
        Skins[1] = Texture'tk_U2Creatures.MeshU2SkaarjMediumTex1';
        Skins[2] = Texture'tk_U2Creatures.MeshU2SkaarjMediumTex2';
    Skins[3]=Texture'tk_U2Creatures.skaarjglove';

    MonsterController(Controller).CombatStyle = 0.90;

}

simulated function PostNetBeginPlay()
{
    Super(U2Creatures).PostNetBeginPlay();
}

simulated function AnimEnd(int Channel)
{

    AnimAction = '';
    //if (FRand() < 0.5)
    //  SetAnimAction('Blink');
    if ( bVictoryNext && (Physics != PHYS_Falling) )
    {
        bVictoryNext = false;
        PlayVictory();
    }
    if ( bShotAnim )
    {
        bShotAnim = false;
        Controller.bPreparingMove = false;
    }

    AirAnims[0] = Default.AirAnims[0];
    Super(XPawn).AnimEnd(Channel);
}

function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(TauntSounds[Rand(5)],SLOT_Talk);
    //SetAnimAction('Snarl');
    PlayAnim(VictoryAnims[Rand(14)]);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

function PlayChallengeSound()
{
    //log("PlayChallengeSound");
    Super(U2Creatures).PlayChallengeSound();
    //SetAnimAction('Snarl');
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

simulated function DefensiveModeEnd( bool bCanTaunt )//new - wasn't simulated
{
    //if( bDefensiveMode )
    //{
        //U2P.SetStance( ST_Standing );
        //DMTNS( "clearing special param: " $ DefendingSpecialParamName );
        //U2P.AnimationController.SetSpecialParamAnim( '' );
        //U2P.TacticalMoveType = U2P.default.TacticalMoveType;
        /*CrouchAnims[0]=Default.CrouchAnims[0];
        CrouchAnims[1]=Default.CrouchAnims[1];
        CrouchAnims[2]=Default.CrouchAnims[2];
        CrouchAnims[3]=Default.CrouchAnims[3];
        IdleCrouchAnim=Default.IdleCrouchAnim;
        CrouchTurnRightAnim=Default.CrouchTurnRightAnim;
            CrouchTurnLeftAnim=Default.CrouchTurnLeftAnim;*/
        bDefensiveMode = false;
        ShouldCrouch(false);
        bWantsToCrouch = false;
        bCanCrouch = false;
        //bShotAnim = false;

        if (Level.TimeSeconds - LastTauntTime > 3 &&
            bCanTaunt &&
            Health >= 0.25*Default.Health &&
            FRand() < 0.5)
        {
            LastTauntTime = Level.TimeSeconds;
            PlaySound(TauntSounds[Rand(5)],SLOT_Talk);
            //SetAnimAction('Snarl');//no snarl
        }

    //}
}

//Don't let him play the snarl animation
simulated event SetAnimAction(name NewAction)
{
//log("1");
    if (!bWaitForAnim)
    {
//log("2");
    AnimAction = NewAction;
    if ( AnimAction == 'Weapon_Switch' )
        {//log("3");
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(NewAction,, 0.0, 1);
        }
        else if (((Physics == PHYS_None)|| ((Level.Game != None) && Level.Game.IsInState('MatchOver')))
                && (DrivenVehicle == None) )
        {//log("4");
            PlayAnim(AnimAction,,0.1);
            AnimBlendToAlpha(1,0.0,0.05);
        }
        else if ( (DrivenVehicle != None) || (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
        {//log("5");
            if ( CheckTauntValid(AnimAction) )
            {
                if (FireState == FS_None || FireState == FS_Ready)
                {
                    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                    PlayAnim(NewAction,, 0.1, 1);
                    FireState = FS_Ready;
                }
            }
            else if ( PlayAnim(AnimAction) )
            {
                if ( Physics != PHYS_None )
                    bWaitForAnim = true;
            }
            else
                AnimAction = '';
        }
        else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
        {//log("6");
            PlayAnim(AnimAction,,0.1);
            AnimBlendToAlpha(1,0.0,0.05);
        }
        else // running taunt
        {
//log("7");
            if (FireState == FS_None || FireState == FS_Ready)
            {
                AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);//1st was 1
                PlayAnim(NewAction,, 0.1, 1);
                FireState = FS_Ready;
            }
        }
    }
}

defaultproperties
{
     Species=Class'tk_U2Creatures.SPECIES_SkaarjAlpha'
     Mesh=SkeletalMesh'tk_U2Creatures.SkaarjAlpha'
     Skins(0)=Texture'tk_U2Creatures.MeshU2SkaarjMediumTex0'
     Skins(1)=Texture'tk_U2Creatures.MeshU2SkaarjMediumTex1'
     Skins(2)=Texture'tk_U2Creatures.MeshU2SkaarjMediumTex2'
     Skins(3)=Texture'tk_U2Creatures.skaarjglove'
     Begin Object Class=KarmaParamsSkel Name=PawnKParams
         KConvulseSpacing=(Max=2.200000)
         KLinearDamping=0.150000
         KAngularDamping=0.050000
         KBuoyancy=1.000000
         KStartEnabled=True
         KVelDropBelowThreshold=50.000000
         bHighDetailOnly=False
         KFriction=1.700000
         KRestitution=0.300000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsSkel'PawnKParams'

}
