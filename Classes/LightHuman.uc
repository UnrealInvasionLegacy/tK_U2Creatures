class LightHuman extends U2Creatures; //UScriptAnimMonster;

// Attack damage.
var(Combat) byte
    SwingDamage, KickDamage; //basic damage done by melee attacks


var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;

var name MeleeAnims[4];
var name DeathAnims[9];
var name VictoryAnims[14];
var() class<Weapon> WeaponType;

var(Sounds) array<sound> MeleeSounds[4];
var(Sounds) array<sound> TauntSounds[40];
var(Sounds) array<sound> AcquireSounds[9];
var(Sounds) array<sound> HitSounds[4];

var() bool bHasAdded;

function PlayChallengeSound()
{
    PlaySound(AcquireSounds[Rand(9)],SLOT_Talk);
}

function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        //PlaySound(sound'tk_U2Creatures.IdleChat1',SLOT_Interact);
    PlaySound(TauntSounds[Rand(40)],SLOT_Talk);
    PlayAnim(VictoryAnims[Rand(14)]);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}



function KickDamageTarget()
{
    if (MeleeDamageTarget(KickDamage, (KickDamage * 4000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(HitSounds[Rand(4)], SLOT_Interact);
}


function SwingDamageTarget()
{
    if ( MeleeDamageTarget(SwingDamage, (SwingDamage * 5000 * Normal(Controller.Target.Location - Location))) )
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

    FireState = FS_None;
    //AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);



    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
        PlayAnim('DeathFoldF01',, 0.2);
    else if ( Dir Dot X < -0.7 )
         PlayAnim('DeathStruggleB01',, 0.2);
    else if ( Dir Dot Y > 0 )
        PlayAnim('DeathFallL01',, 0.2);
    else if ( HasAnim('DeathR') )
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
    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming  )
    {
        bShotAnim = true;
        SetAnimAction(MeleeAnims[Rand(3)]);
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

simulated function AnimEnd(int Channel)
{
    if ( bShotAnim )
    {
        bShotAnim = false;
        controller.bPreparingMove = false;
    }
    Super(XPawn).AnimEnd(Channel);
}

defaultproperties
{
     SwingDamage=15
     KickDamage=25
     MeleeAnims(0)="Kick_Fr01_SH"
     MeleeAnims(1)="Swing_Fr01_SH"
     MeleeAnims(2)="Swing_FrRp01_SH"
     DeathAnims(0)="DeathBackFlipF01"
     DeathAnims(1)="DeathBlownUpB01"
     DeathAnims(2)="DeathDieSitting01"
     DeathAnims(3)="DeathFoldF01"
     DeathAnims(4)="DeathHeadShotF01"
     DeathAnims(5)="DeathMidHitB01"
     DeathAnims(6)="DeathRiddledF01"
     DeathAnims(7)="DeathSpinF01"
     DeathAnims(8)="DeathStruggleB01"
     VictoryAnims(0)="Taunt01_SH"
     VictoryAnims(1)="Taunt02_SH"
     VictoryAnims(2)="Taunt03_SH"
     VictoryAnims(3)="Taunt04_SH"
     VictoryAnims(4)="Thrust01_SH"
     VictoryAnims(5)="Victory01_SH"
     VictoryAnims(6)="Victory02_SH"
     VictoryAnims(7)="Victory03_SH"
     VictoryAnims(8)="Wave01_SH"
     VictoryAnims(9)="DialogueSalute01_SH"
     VictoryAnims(10)="DialogueSalute02_SH"
     VictoryAnims(11)="DialogueAttention01_SH"
     VictoryAnims(12)="DialogueAttention02_SH"
     VictoryAnims(13)="DialogueEase01_SH"
     TauntSounds(0)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_01_008'
     TauntSounds(1)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_02_002'
     TauntSounds(2)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_02_008'
     TauntSounds(3)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_003'
     TauntSounds(4)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_004'
     TauntSounds(5)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_009'
     TauntSounds(6)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_010'
     TauntSounds(7)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_011'
     TauntSounds(8)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_012'
     TauntSounds(9)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_014'
     TauntSounds(10)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_03_016'
     TauntSounds(11)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_04_012'
     TauntSounds(12)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_04_014'
     TauntSounds(13)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_04_016'
     TauntSounds(14)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_05_004'
     TauntSounds(15)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_05_007'
     TauntSounds(16)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_05_011'
     TauntSounds(17)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_05_016'
     TauntSounds(18)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_06_009'
     TauntSounds(19)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_06_011'
     TauntSounds(20)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_07_005'
     TauntSounds(21)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_07_009'
     TauntSounds(22)=Sound'tk_U2Creatures.Male22Voice_KillsTaunts.KillsTaunts_09_007'
     TauntSounds(23)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_07_014'
     TauntSounds(24)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_07_016'
     TauntSounds(25)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_08_010'
     TauntSounds(26)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_08_011'
     TauntSounds(27)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_08_012'
     TauntSounds(28)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_08_013'
     TauntSounds(29)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_08_015'
     TauntSounds(30)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_09_002'
     TauntSounds(31)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_09_005'
     TauntSounds(32)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_09_006'
     TauntSounds(33)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_09_008'
     TauntSounds(34)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_09_010'
     TauntSounds(35)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_09_011'
     TauntSounds(36)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_10_002'
     TauntSounds(37)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_10_003'
     TauntSounds(38)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_10_005'
     TauntSounds(39)=Sound'tk_U2Creatures.Male22Voice_EndSkirmish.KillsTaunts_10_009'
     AcquireSounds(0)=Sound'tk_U2Creatures.Male22Voice_Acquire.Heat_02_011'
     AcquireSounds(1)=Sound'tk_U2Creatures.Male22Voice_Acquire.Heat_02_012'
     AcquireSounds(2)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_01_014'
     AcquireSounds(3)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_01_016'
     AcquireSounds(4)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_03_005'
     AcquireSounds(5)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_04_007'
     AcquireSounds(6)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_04_008'
     AcquireSounds(7)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_04_010'
     AcquireSounds(8)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_05_003'
     HitSounds(0)=Sound'tk_U2Creatures.WeaponsA_GunButt.GunButt01'
     HitSounds(1)=Sound'tk_U2Creatures.WeaponsA_GunButt.GunButt02'
     HitSounds(2)=Sound'tk_U2Creatures.WeaponsA_GunButt.GunButt03'
     HitSounds(3)=Sound'tk_U2Creatures.WeaponsA_GunButt.GunButt04'
     BonePitch="Bip01 Spine1"
     BoneYaw="bip01 Spine2"
     BoneYaw2="Bip01 Head"
     bHeadTrackingEnabled=True
     bMeleeFighter=False
     bTryToWalk=True
     DodgeSkillAdjust=1.000000
     HitSound(0)=Sound'tk_U2Creatures.Male22Voice_HitSoft.TakeDamage_01_002a'
     HitSound(1)=Sound'tk_U2Creatures.Male22Voice_HitSoft.TakeDamage_01_002d'
     HitSound(2)=Sound'tk_U2Creatures.Male22Voice_HitHard.TakeDamage_01_003b'
     HitSound(3)=Sound'tk_U2Creatures.Male22Voice_HitHard.TakeDamage_01_003d'
     DeathSound(0)=Sound'tk_U2Creatures.Male22Voice_DieHard.TakeDamage_01_006b'
     DeathSound(1)=Sound'tk_U2Creatures.Male22Voice_DieHard.TakeDamage_01_006c'
     DeathSound(2)=Sound'tk_U2Creatures.Male22Voice_DieSoft.TakeDamage_01_003c'
     DeathSound(3)=Sound'tk_U2Creatures.Male22Voice_DieSoft.TakeDamage_01_003g'
     ChallengeSound(0)=Sound'tk_U2Creatures.Male22Voice_Acquire.Heat_02_011'
     ChallengeSound(1)=Sound'tk_U2Creatures.Male22Voice_Acquire.Heat_02_012'
     ChallengeSound(2)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_01_016'
     ChallengeSound(3)=Sound'tk_U2Creatures.Male22Voice_Acquire.KillsTaunts_04_007'
     ScoringValue=5
     GibGroupClass=Class'tk_U2Creatures.HumanFleshGibGroup'
     WallDodgeAnims(0)="DodgeFrwd_Fr01_SH"
     WallDodgeAnims(1)="DodgeBack_Fr01_SH"
     WallDodgeAnims(2)="DodgeLeft_Fr01_SH"
     WallDodgeAnims(3)="DodgeRight_Fr01_SH"
     IdleHeavyAnim="IdleWaitBreathe01_SH"
     IdleRifleAnim="IdleWaitBreathe02_SH"
     FireHeavyRapidAnim="Still_Fr01_SH"
     FireHeavyBurstAnim="Still_FrRp01_LG"
     FireRifleRapidAnim="Still_Fr01_SH"
     FireRifleBurstAnim="Still_FrRp01_LG"
     FireRootBone="Bip01 Spine1"
     bCanDoubleJump=False
     MeleeRange=50.000000
     GroundSpeed=263.000000
     WaterSpeed=140.000000
     AirSpeed=280.000000
     SoundDampening=0.500000
     MovementAnims(0)="RunFrwd_Fr01_SH"
     MovementAnims(1)="RunBack_Fr01_SH"
     MovementAnims(2)="RunLeft_Fr01_SH"
     MovementAnims(3)="RunRight_Fr01_SH"
     TurnLeftAnim="Turn_Fr01_LG"
     TurnRightAnim="Turn_Fr01_LG"
     SwimAnims(0)="Swim_Fr01_LG"
     SwimAnims(1)="Swim_Fr01_LG"
     SwimAnims(2)="Swim_Fr01_LG"
     SwimAnims(3)="Swim_Fr01_LG"
     CrouchAnims(0)="DuckWalk_Fr01_SH"
     CrouchAnims(1)="DuckWalkB_Fr01_SH"
     CrouchAnims(2)="DuckWalkL_Fr01_SH"
     CrouchAnims(3)="DuckWalkR_Fr01_SH"
     WalkAnims(0)="WalkFrwd_Fr01_SH"
     WalkAnims(1)="WalkBack_Fr01_SH"
     WalkAnims(2)="WalkLeft_Fr01_SH"
     WalkAnims(3)="WalkRight_Fr01_SH"
     AirAnims(0)="Jump_Fr01_SH"
     AirAnims(1)="Jump_Fr01_SH"
     AirAnims(2)="Jump_Fr01_SH"
     AirAnims(3)="Jump_Fr01_SH"
     TakeoffAnims(0)="JumpStartFrwd01_SS"
     TakeoffAnims(1)="JumpStartBack01_SS"
     TakeoffAnims(2)="JumpStartLeft01_SS"
     TakeoffAnims(3)="JumpStartRight01_SS"
     LandAnims(0)="Land_Fr01_SH"
     LandAnims(1)="LandBack01_SS"
     LandAnims(2)="LandLeft_SS"
     LandAnims(3)="LandRight_SS"
     DoubleJumpAnims(0)="JumpStartFrwd01_SS"
     DoubleJumpAnims(1)="JumpStartBack01_SS"
     DoubleJumpAnims(2)="JumpStartLeft01_SS"
     DoubleJumpAnims(3)="JumpStartRight01_SS"
     DodgeAnims(0)="DodgeFrwd_Fr01_SH"
     DodgeAnims(1)="DodgeBack_Fr01_SH"
     DodgeAnims(2)="DodgeLeft_Fr01_SH"
     DodgeAnims(3)="DodgeRight_Fr01_SH"
     AirStillAnim="Jump_Fr01_SH"
     TakeoffStillAnim="JumpNone01_SS"
     CrouchTurnRightAnim="DuckWalk_Fr01_SM"
     CrouchTurnLeftAnim="DuckWalk_Fr01_SM"
     IdleCrouchAnim="DuckBreathe_Fr01_SH"
     IdleSwimAnim="Tread_Fr01_SH"
     IdleWeaponAnim="IdleWaitBreathe01_SH"
     IdleRestAnim="IdleChat01_SH"
     IdleChatAnim="IdleChat01_SH"
     DrawScale=0.700000
     PrePivot=(Z=0.000000)
     TransientSoundVolume=2.000000
     CollisionRadius=28.000000
     CollisionHeight=54.000000
     Mass=120.000000
     RotationRate=(Yaw=65000)
}
