class IzarianBase extends U2Creatures
    abstract;

// Attack damage.
var(Combat) byte
    StabDamage, HitDamage; //basic damage done by melee attacks

var Pawn CurrentVictim;
var Vector OffsetVictim;
var xEmitter SpinEffect;


var name MeleeAnims[4];
var name DeathAnims[9];
var name VictoryAnims[6];
var() class<Weapon> WeaponType;

var(Sounds) array<sound> MeleeSounds[4];
var(Sounds) sound hit;

var() bool bHasAdded;


function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;

    if (FRand() < 0.5)
        PlaySound(sound'tk_U2Creatures.Taunt1',SLOT_Interact);
    else
        PlaySound(sound'tk_U2Creatures.Taunt2',SLOT_Interact);

    PlayAnim(VictoryAnims[Rand(6)]);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}



function StabDamageTarget()
{
    if (MeleeDamageTarget(StabDamage, (StabDamage * 400 * Normal(Controller.Target.Location - Location))) )
        PlaySound(hit, SLOT_Interact);
}


function HitDamageTarget()
{
    if ( MeleeDamageTarget(HitDamage, (HitDamage * 850 * Normal(Controller.Target.Location - Location))) )
        PlaySound(hit, SLOT_Interact);
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
        PlayAnim('DeathHeadShotDieF01',, 0.2);
    else if ( Dir Dot X < -0.7 )
         PlayAnim('DeathMidHitDieB01',, 0.2);
    else if ( Dir Dot Y > 0 )
        PlayAnim('DeathMidHitDieB02',, 0.2);
    else if ( HasAnim('DeathMidHitDieF01') )
        PlayAnim('DeathMidHitDieF01',, 0.2);
    else
        PlayAnim('DeathSpinDieF01',, 0.2);
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

/*simulated function AttachVictim()
{
    local U2DummyPlayerActorIzarian DPA;
    Local PlayerController VictimController;
    if(CurrentVictim != None)
    {
        VictimController = PlayerController(CurrentVictim.Controller);
        if( VictimController != None)
        {
            VictimController.ClientSetViewTarget(self);
                VictimController.SetViewTarget(self);
                VictimController.ClientSetBehindView(true);

        }
        Controller.Target = None;
        Controller.StopFiring();
        DPA = Spawn(class'U2DummyPlayerActorIzarian', CurrentVictim,,  GetBoneCoords('handpointR02').Origin, self.Rotation);
        DPA.SetOwner(CurrentVictim);
        DPA.PawnOwner=CurrentVictim;
        DPA.SetDrawScale(CurrentVictim.DrawScale);
        DPA.LinkMesh(CurrentVictim.Mesh);
        DPA.Skins = CurrentVictim.Skins;
        Self.AttachToBone(DPA, 'handpointR02');
        DPA.SetRelativeLocation( OffsetVictim);
        SpinEffect= Spawn(class'BloodExplosion', self,, GetBoneCoords('handpointR02').Origin, self.Rotation);
        Self.AttachToBone(SpinEffect, 'handpointR02');
        SpinEffect.SetRelativeLocation( OffsetVictim);
        SetPhysics(PHYS_None);
        //SetCollision(False,False);
    }
}



function RipApart()
{
    local U2DummyPlayerActorIzarian Poo;
    local int i;
    CurrentVictim=None;
    //PlaySound(Sound'VenomSounds.LargeSpider.spider-large-roar',SLOT_None,1,,,1000);
    Controller.Target = None;
    for(i=0; i < Attached.Length; i++)
    {
        if(Attached[i].isa('U2DummyPlayerActorIzarian'))
        {
            bWaitForAnim=False;
            AnimAction = '';
            Poo = U2DummyPlayerActorIzarian(Attached[i]);
            //Spawn(class'HeadBloodExplosion', self,, Poo.Location, Poo.Rotation);
            DetachFromBone( Attached[i] );
            Poo.Destroy();
        }

    }
    for(i=0; i < Attached.Length; i++)
    {
        if(Attached[i].isa('U2DummyPlayerActorIzarian'))
        {
            Poo = U2DummyPlayerActorIzarian(Attached[i]);
            //Spawn(class'HeadBloodExplosion', self,, Poo.Location, Poo.Rotation);
            DetachFromBone( Attached[i] );
            Poo.Destroy();
        }
    }
    SetCollision(true,true);
    SetPhysics(PHYS_Falling);

}


function bool IsAlreadyAVictim(Pawn FutureVictim)
{
    Local Controller C;

    For (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.Pawn != None && ( C.Pawn.isA('Izarian') || C.Pawn.isA('IzarianArmored') ) && C.Pawn != Self)
        {
            If( Izarian(C.Pawn).CurrentVictim == FutureVictim )
            {
                return true;
            }
            else if( IzarianArmored(C.Pawn).CurrentVictim == FutureVictim )
            {
                return true;
            }
        }
    }

    return false;

}*/


simulated function StartFiring(bool bHeavy, bool bRapid)
{
    local name FireAnim;
    local name Anim;
    local float frame,rate;

    GetAnimParams(0, Anim,frame,rate);

    if ( (Anim == MovementAnims[0] ) || (Anim == MovementAnims[1]) || (Anim == MovementAnims[2]) || (Anim == MovementAnims[3]) )
    return;

    if ( HasUDamage() && (Level.TimeSeconds - LastUDamageSoundTime > 0.25) )
    {
        LastUDamageSoundTime = Level.TimeSeconds;
        PlaySound(UDamageSound, SLOT_None, 1.5*TransientSoundVolume,,700);
    }

    if (Physics == PHYS_Swimming)
        return;

    if (bHeavy)
    {
        if (bRapid)
            FireAnim = FireHeavyRapidAnim;
        else
            FireAnim = FireHeavyBurstAnim;
    }
    else
    {
        if (bRapid)
            FireAnim = FireRifleRapidAnim;
        else
            FireAnim = FireRifleBurstAnim;
    }

    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

    if (bRapid)
    {
        if (FireState != FS_Looping )
        {
            LoopAnim(FireAnim,, 0.0, 1);
            FireState = FS_Looping;
        }
    }
    else
    {
        PlayAnim(FireAnim,, 0.0, 1);
        FireState = FS_PlayOnce;
    }

    IdleTime = Level.TimeSeconds;
}

function SetStartingState();

//     IdleHeavyAnim="IdleWaitBreath01_LG"
//     IdleRifleAnim="IdleWaitBreath01_LG"

defaultproperties
{
     StabDamage=60
     hitdamage=60
     MeleeAnims(0)="AimDnStab01"
     MeleeAnims(1)="StillLunge_Fr01_LG"
     MeleeAnims(2)="StillThrow_Fr01_LG"
     MeleeAnims(3)="StillThrow_Fr01_LG"
     DeathAnims(0)="DeathBlownUpDieF01"
     DeathAnims(1)="DeathBlownUpDieB01"
     DeathAnims(2)="DeathMidHitDieB01"
     DeathAnims(3)="DeathMidHitDieB02"
     DeathAnims(4)="DeathHeadShotDieF01"
     DeathAnims(5)="DeathMidHitDieF01"
     DeathAnims(6)="DeathMidHitDieF01"
     DeathAnims(7)="DeathSpinDieF01"
     DeathAnims(8)="DeathMidHitDieB01"
     VictoryAnims(0)="Taunt01_LG"
     VictoryAnims(1)="CutScene09"
     VictoryAnims(2)="IdleWaitBreath01_LG"
     VictoryAnims(3)="IdleWaitLook01_LG"
     VictoryAnims(4)="IdleWaitSlouche01_LG"
     VictoryAnims(5)="DuckBreathe_Fr01_LG"
     MeleeSounds(0)=Sound'tk_U2Creatures.IzarianA_MeleeDamage.MeleeAttack1'
     MeleeSounds(1)=Sound'tk_U2Creatures.IzarianA_MeleeDamage.MeleeAttack2'
     MeleeSounds(2)=Sound'tk_U2Creatures.IzarianA_MeleeDamage.MeleeAttack3'
     MeleeSounds(3)=Sound'tk_U2Creatures.IzarianA_MeleeDamage.MeleeAttack1'
     bTryToWalk=True
     DodgeSkillAdjust=1.000000
     HitSound(0)=Sound'tk_U2Creatures.IzarianA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.IzarianA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.IzarianA_HitHard.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.IzarianA_HitHard.Hit1'
     DeathSound(0)=Sound'tk_U2Creatures.IzarianA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.IzarianA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.IzarianA_DieSoft.DieSoft2'
     DeathSound(3)=Sound'tk_U2Creatures.IzarianA_DieSoft.DieSoft3'
     ChallengeSound(0)=Sound'tk_U2Creatures.IzarianA_Misc.Idle3'
     ChallengeSound(1)=Sound'tk_U2Creatures.IzarianA_Misc.Eat1'
     ChallengeSound(2)=Sound'tk_U2Creatures.IzarianA_Misc.Idle4'
     ChallengeSound(3)=Sound'tk_U2Creatures.IzarianA_Misc.Idle5'
     ScoringValue=5
     GibGroupClass=Class'tk_U2Creatures.IzarianGibGroup'
     WallDodgeAnims(0)="DodgeFrwd_Fr01_LG"
     WallDodgeAnims(1)="DodgeBack_Fr01_LG"
     WallDodgeAnims(2)="DodgeLeft_Fr01_LG"
     WallDodgeAnims(3)="DodgeRight_Fr01_LG"
     IdleHeavyAnim="Puppet"
     IdleRifleAnim="Puppet"
     FireHeavyRapidAnim="Still_Fr01_LG"
     FireHeavyBurstAnim="Still_Fr01_LG"
     FireRifleRapidAnim="Still_Fr01_LG"
     FireRifleBurstAnim="Still_Fr01_LG"
     FireRootBone="Bip01 Spine1"
     bCanDoubleJump=False
     MeleeRange=40.000000
     GroundSpeed=450.000000
     WaterSpeed=200.000000
     AirSpeed=280.000000
     WalkingPct=0.176000
     SoundDampening=0.500000
     ControllerClass=Class'tk_U2Creatures.IzarianController'
     MovementAnims(0)="RunFrwd_Fr01_LG"
     MovementAnims(1)="RunBack_Fr01_LG"
     MovementAnims(2)="RunLeft_Fr01_LG"
     MovementAnims(3)="RunRight_Fr01_LG"
     TurnLeftAnim="WalkFrwd_Fr01_LG"
     TurnRightAnim="WalkFrwd_Fr01_LG"
     SwimAnims(0)="RunFrwd_Fr01_LG"
     SwimAnims(1)="RunBack_Fr01_LG"
     SwimAnims(2)="RunLeft_Fr01_LG"
     SwimAnims(3)="RunRight_Fr01_LG"
     CrouchAnims(0)="WalkFrwd_Fr01_LG"
     CrouchAnims(1)="WalkFrwd_Fr01_LG"
     CrouchAnims(2)="WalkFrwd_Fr01_LG"
     CrouchAnims(3)="WalkFrwd_Fr01_LG"
     WalkAnims(0)="WalkFrwd01_LG"
     WalkAnims(1)="WalkFrwd_Fr01_LG"
     WalkAnims(2)="WalkFrwd_Fr01_LG"
     WalkAnims(3)="WalkFrwd_Fr01_LG"
     AirAnims(0)="FallFar_Fr01_LG"
     AirAnims(1)="FallFar_Fr01_LG"
     AirAnims(2)="FallFar_Fr01_LG"
     AirAnims(3)="FallFar_Fr01_LG"
     TakeoffAnims(0)="JumpFrwd01_LG"
     TakeoffAnims(1)="Jump_Fr01_LG"
     TakeoffAnims(2)="Jump01_LG"
     TakeoffAnims(3)="JumpFrwd_Fr01_LG"
     LandAnims(0)="Land_Fr01_LG"
     LandAnims(1)="Land01_LG"
     LandAnims(2)="Land_Fr01_LG"
     LandAnims(3)="Land01_LG"
     DoubleJumpAnims(0)="JumpFrwd01_LG"
     DoubleJumpAnims(1)="Jump_Fr01_LG"
     DoubleJumpAnims(2)="Jump01_LG"
     DoubleJumpAnims(3)="JumpFrwd_Fr01_LG"
     DodgeAnims(0)="DodgeFrwd_Fr01_LG"
     DodgeAnims(1)="DodgeBack_Fr01_LG"
     DodgeAnims(2)="DodgeLeft_Fr01_LG"
     DodgeAnims(3)="DodgeRight_Fr01_LG"
     AirStillAnim="FallFar01_LG"
     TakeoffStillAnim="Jump01_LG"
     CrouchTurnRightAnim="WalkFrwd01_LG"
     CrouchTurnLeftAnim="WalkFrwd01_LG"
     IdleCrouchAnim="DuckBreathe_Fr01_LG"
     IdleSwimAnim="RunFrwd_Fr01_LG"
     IdleWeaponAnim="IdleWaitSlouche01_LG"
     IdleRestAnim="IdleWaitBreath01_LG"
     IdleChatAnim="IdleWaitLook01_LG"
     DrawScale=0.150000
     PrePivot=(Z=9.000000)
     TransientSoundVolume=2.000000
     CollisionRadius=28.000000
     CollisionHeight=54.000000
     Mass=200.000000
}
