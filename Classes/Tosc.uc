class Tosc extends U2Creatures;

//Chargeup effect code and beam attack code by Iniquitous
//Grab/rip apart code by Milk

var float ArmScale;
var Pawn CurrentVictim;
var Vector OffsetVictim;
var xEmitter SpinEffect;
var class<xEmitter> ChargeUpClass;
var xEmitter ChargingEmitter;
var() array<string> WeaponClassName;
var() float FireRateScale;

// Attack damage.
var(Combat) byte
    ClawDamage, // Basic damage done by each claw.
    GrabDamage; // Basic damage done by each grab.



var(Sounds) sound claw;
var(Sounds) sound slice;
var(Sounds) sound Footstep;
var(Sounds) sound Footstep2;
var(Sounds) Sound BeamSounds[4];

var name MeleeAnims[2];
var name WalkMeleeAnims[3];
var name DeathAnims[2];
var name VictoryAnims[7];
var name FireAnims[3];
var name WalkFireAnims[4];
var(Sounds) array<sound> MeleeSounds[12];

//var bool bLeftShot;
var bool bClientLostGunArm;
var bool bLostGunArm;



var() class<xEmitter> BreakEffect;
var() name StepEvent;

var mesh ArmlessMesh;

//More beam stuff
//A huge fucking mess, even by my standards
var int BeamDamage;
var int AimError;
var class<DamageType> BeamDamageType;
var() float MinChargeDistance;
var() float MaxChargeDistance;
var LinkBeamEffect          BeamA;
var class<LinkBeamEffect>   BeamEffectClass;
var() class<DamageType> DamageType;
var() int Damage;
var() float MomentumTransfer;
var bool bDoHit;
var() float TraceRange;
var() float LinkFlexibility;
var() int Links;
var() bool Linking;
var float   LinkScale[6];
var float   UpTime;
var Pawn    LockedPawn;
var() float LinkBreakDelay;
var float   LinkBreakTime;
var byte    LinkVolume;
var byte    SentLinkVolume;
var float lastHitTime;

replication
{
    reliable if(Role==ROLE_Authority)
        /*ServerLoseArm,*/ ServerArmFalloff, ArmlessMesh;
    reliable if( bNetDirty && (Role==ROLE_Authority) )
        ArmScale;
}

function PostBeginPlay()
{
    local class<weapon> weaponclass;
    local int r;

    Super.PostBeginPlay();
    bMeleeFighter = true;

    MonsterController(Controller).CombatStyle = 1.0;

    weaponclass=class<Weapon>(DynamicLoadObject(WeaponClassName[r],class'class'));
    //log(weaponclass);
    if(weaponclass != None)
    {
        Weapon=spawn(weaponclass,self);
    }
    if(Weapon == None)
    {
        return;
    }
    Weapon.ExchangeFireModes = 1;
    Weapon.GiveTo(self);
    //Weapon.AttachToPawn(self);

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = Weapon.AmmoClass[0];
        SavedFireProperties.ProjectileClass = Weapon.AmmoClass[0].default.ProjectileClass;
        SavedFireProperties.WarnTargetPct = Weapon.AmmoClass[0].default.WarnTargetPct;
        SavedFireProperties.MaxRange = Weapon.AmmoClass[0].default.MaxRange;
        SavedFireProperties.bTossed = Weapon.AmmoClass[0].default.bTossed;
        SavedFireProperties.bTrySplash = Weapon.AmmoClass[0].default.bTrySplash;
        SavedFireProperties.bLeadTarget = Weapon.AmmoClass[0].default.bLeadTarget;
        SavedFireProperties.bInstantHit = Weapon.AmmoClass[0].default.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    Weapon.ClientState = WS_ReadyToFire;
    Weapon.GetFireMode(0).FireRate *= FireRateScale;
    Weapon.GetFireMode(1).FireRate *= FireRateScale;
    Weapon.GetFireMode(0).AmmoPerFire = 0;
    Weapon.GetFireMode(1).AmmoPerFire = 0;

}

//-----------------------------------------------------------------------------

function NotifyToscSoundWalkRight()
{
    local pawn Thrown;

    if (Physics != PHYS_Walking)
        return;

    PlaySound(sound'tk_U2Creatures.Tosc.Tosc_Foot_Tri_Hit_3', SLOT_Interact, 12);

    TriggerEvent(StepEvent,Self, Instigator);
    //throw all nearby creatures, and play sound
    foreach CollidingActors( class 'Pawn', Thrown,Mass*0.5)
        ThrowOther(Thrown,Mass/4);
}

//-----------------------------------------------------------------------------

function NotifyToscSoundWalkLeft()
{
    local pawn Thrown;

    if (Physics != PHYS_Walking)
        return;

    PlaySound(sound'tk_U2Creatures.Tosc.Tosc_Foot_Tri_Hit_4', SLOT_Interact, 12);

    TriggerEvent(StepEvent,Self, Instigator);
    //throw all nearby creatures, and play sound
    foreach CollidingActors( class 'Pawn', Thrown,Mass*0.5)
        ThrowOther(Thrown,Mass/4);




}

simulated function DestroyEffects()
{
    if (ChargingEmitter != None)
        ChargingEmitter.Destroy();
    //Super.DestroyEffects();
    if ( BeamA != None )
            BeamA.Destroy();
}

function ThrowOther(Pawn Other,int Power)
{
    local float dist, shake;
    local vector Momentum;

    //log(Power);
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

function Step()
{
    //PlaySound(sound'scuttle1pp', SLOT_Interact);
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Falling);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z,duckdir;

    GetAxes(Rotation,X,Y,Z);
    if (DoubleClickMove == DCLICK_Forward)
        duckdir = X;
    else if (DoubleClickMove == DCLICK_Back)
        duckdir = -1*X;
    else if (DoubleClickMove == DCLICK_Left)
        duckdir = Y;
    else if (DoubleClickMove == DCLICK_Right)
        duckdir = -1*Y;

    SetPhysics(PHYS_Falling);

    Controller.Destination = Location + 250 * duckDir;
    Velocity = GroundSpeed * duckDir;
    Controller.GotoState('TacticalMove', 'DoMove');
    return true;
}



event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Walking);
    Super.HitWall(HitNormal,HitWall);
}



simulated function PlayDirectionalDeath(Vector HitLoc)
{

    PlayAnim(DeathAnims[Rand(2)]);
    StartDeRes();
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
    /*if (Health < Default.Health * 0.5 && !bLostGunArm)
    {
        LoseArm();
    }*/
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    Super.TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType);
    if (Health < Default.Health * 0.5 && !bLostGunArm)
    {
        LoseArm();
    }
}
function LoseArm()
{
    //Acceleration = vect(0,0,0);
    PlayAnim('LoseArm',, 0.1);
        bLostGunArm = True;
    //LinkMesh(ArmlessMesh,true);
    ServerArmFallOff(4, 'Bip01 R ForeArm', class'XEffects.AlienBloodExplosion');
       /* bClientLostGunArm = True;
    //ArmFallOff(4, 'Bip01 R ForeArm', class'XEffects.AlienBloodExplosion');
    ServerArmFallOff(4, 'Bip01 R ForeArm', class'XEffects.AlienBloodExplosion');
    HideBone('rfarm');
    //if (Level.NetMode == NM_Client)
    //  ServerLoseArm();
    */
}

/*function ServerLoseArm()
{
    /*if (Level.NetMode == NM_Client)
    {
        PlayAnim('LoseArm',, 0.1);
        ArmFallOff(4, 'Bip01 R ForeArm', class'XEffects.AlienBloodExplosion');
        HideBone('rfarm');
    }*/
}*/

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local name Anim;
    local float frame,rate;
        local Vector X,Y,Z, Dir;

    if ( bShotAnim )
        return;

    GetAnimParams(0, Anim,frame,rate);



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


}


/*simulated event ArmFallOff(int Slot, name BoneName, class<xEmitter> BreakEffect)
{
    local vector ArmBloodLoc;

    PlaySound(HitSound[0], SLOT_None, 2.0,,,, False);
    ArmScale = 0.01;
    SetBoneScale(Slot, ArmScale, BoneName);
        ArmBloodLoc = GetBoneCoords('ToscRForeArmCannonEnd').Origin;

    if (Level.NetMode != NM_DedicatedServer)
            spawn(BreakEffect,,,ArmBloodLoc);

    SpawnArm();

    if (Level.NetMode == NM_Client)
        ServerArmFallOff(Slot, BoneName, BreakEffect);
}*/

function ServerArmFallOff(int Slot, name BoneName, class<xEmitter> BreakEffect)
{
    local vector ArmBloodLoc;

    //if (Level.NetMode == NM_Client)
    //{
        PlaySound(HitSound[0], SLOT_None, 2.0,,,, False);
        SetBoneScale(Slot, ArmScale, BoneName);
        //SetHeadScale(0.0);
        ArmBloodLoc = GetBoneCoords('ToscRForeArmCannonEnd').Origin;
        SpawnArm();
        //if (Level.NetMode != NM_DedicatedServer)
                spawn(BreakEffect,,,ArmBloodLoc);
    //}
}


function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Tosc.Tosc_Taunt_2',SLOT_Interact);
    PlayAnim(VictoryAnims[Rand(7)]);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}



function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + CollisionRadius * ( X + 1.0 * Y  * Z );
}




function ClawDamageTarget()
{
    if ( MeleeDamageTarget(ClawDamage, (ClawDamage * 900 * Normal(Controller.Target.Location - Location))) )
        PlaySound(slice, SLOT_Interact);
}

function GrabDamageTarget()
{
    if ( MeleeDamageTarget(GrabDamage, (GrabDamage * -800 * Normal(Controller.Target.Location - Location))) )
        PlaySound(slice, SLOT_Interact);
}





function RangedAttack(Actor A)
{
    local float Dist;
    local name Anim;
    local float frame,rate;


    if ( bShotAnim  )
        return;


    Dist = VSize(A.Location - Location);
    GetAnimParams(0,Anim,frame,rate);


    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming)
    {
        SetAnimAction(MeleeAnims[Rand(2)]);
        PlaySound(MeleeSounds[Rand(12)], SLOT_Interact);
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        return;
    }
    else if ( Velocity == vect(0,0,0) && Anim != 'Melee02' && !bLostGunArm )
    {
        SetAnimAction(FireAnims[Rand(3)]);
        CreateChargeUpEffect();
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        return;
    }
    else if ( !bLostGunArm )
    {
        GetAnimParams(0,Anim,frame,rate);
        CreateChargeUpEffect();
        bShotAnim = true;

        if ( Anim == 'WalkFrwd01' )
            SetAnimAction('WalkFrwd_Fr01');
        else if ( Anim == 'WalkFrwd02' )
            SetAnimAction('WalkFrwd_Fr02');
        else if (Frand() < 0.55)
            SetAnimAction('WalkFrwd_Fr03');
        else
            SetAnimAction('WalkFrwd_Fr04');

    }
    else if ( bLostGunArm && dist <= MinChargeDistance ) //&& FastTrace(A.Location,Location) == true )
    {
        //FireBeam();
        Enable('Tick');
        bShotAnim = true;
        DoFireEffect();
    }
    else
        return;

    //bShotAnim = true;
    //Controller.bPreparingMove = true;

}





function SpawnShot()
{


    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local name RightHand;

    if (bLostGunArm)
        return;

    DeactivateChargeUpEffect();

    RightHand = 'ToscRForeArmCannonEnd';

    //bLeftShot = true;

    GetAxes(Rotation,X,Y,Z);

        FireStart = GetBoneCoords(RightHand).Origin;

    //MyAmmo.ProjectileClass = class'U2SkaarjProjectile';
       // MyAmmo.Class=Default.AmmunitionClass;

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    PlaySound(FireSound,SLOT_Interact);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);

}

function SpawnShotMoving()
{


    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local name RightHand;

    if (bLostGunArm || FRand() <= 0.40)
        return;

    DeactivateChargeUpEffect();
    //if (FRand() <= 0.5)
    //  return;

    RightHand = 'ToscRForeArmCannonEnd';

    //bLeftShot = true;

    GetAxes(Rotation,X,Y,Z);

        FireStart = GetBoneCoords(RightHand).Origin;

    //MyAmmo.ProjectileClass = class'U2SkaarjProjectile';
       // MyAmmo.Class=Default.AmmunitionClass;

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    PlaySound(FireSound,SLOT_Interact);
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);

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


simulated function CreateChargeUpEffect()
{
    local coords BoneLocation;
    local vector ChargeLocation;
    local Rotator ChargeDirection;
    local Rotator NewRot;

    PlaySound(sound'tk_U2Creatures.WeaponsA_SingularityCannon.SC_PreFire', SLOT_Interact);

    if ( Level.NetMode != NM_DedicatedServer)
    {
        NewRot.Pitch = 6000;

        ChargeDirection = GetBoneRotation('CannonEnd',);
        BoneLocation = GetBoneCoords('CannonEnd');
        ChargeLocation = BoneLocation.Origin;
        ChargingEmitter = Spawn(class'XEffects.ShieldCharge',self,,ChargeLocation,ChargeDirection);
        AttachToBone(ChargingEmitter, 'CannonEnd');
    }
}

simulated function DeactivateChargeUpEffect()
{
    if(ChargingEmitter != None)
    {
        ChargingEmitter.Destroy();
    }

}

function SpawnArm()
{
    local Vector            TossVel;

    if ( Weapon != None  )
    {
    if ( Controller != None )
        Controller.LastPawnWeapon = Weapon.Class;
        Weapon.HolderDied();
        TossVel = Vector(GetViewRotation());
        //TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);
    TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,250);
    //log("tossing weapon? - spawnarm func");
        TossWeapon(TossVel);
    }

//  TossWeapon(vect(50,50,50));
}

function TossWeapon(Vector TossVel)
{
    local Vector X,Y,Z;

    Weapon.Velocity = TossVel;
    GetAxes(Rotation,X,Y,Z);
    Weapon.bCanThrow = true;
    Weapon.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
    //Weapon.AmmoClass[0].bTossed = true;
    //log(Weapon);
    //Controller.ClientSwitchToBestWeapon();
}

simulated function bool CanThrowWeapon()
{
    return true;
}


/*function FireBeam()
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local float TraceRange;
    local coords BoneCoords;
    local vector Start;
    local rotator Dir;
    Local xEmitter Beam;
    local bool bReflect;

    GetAxes(Rotation,X,Y,Z);
    BoneCoords = GetBoneCoords('Bip01 Head');
    Start = BoneCoords.Origin;

    Dir = Controller.AdjustAim(SavedFireProperties,Start,AimError);
    TraceRange = 10000;

    while(true)
    {
        bReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;
        Other = Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && Other != Instigator)
        {
            if (Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, BeamDamage * 0.25))
            {
                bReflect = true;
            }
            else if ( Other != mainArcHitTarget )
            {
                if ( !Other.bWorldGeometry )
                {
                    if ( (Pawn(Other) != None))
                    {
                        HitLocation = Other.Location;
                        Other.TakeDamage(BeamDamage, Instigator, HitLocation, X, BeamDamageType);
                    }
                }
                else
                {
                    HitLocation = HitLocation + 2.0 * HitNormal;
                }
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Normal(Start - End);
        }

        if (Beam != None)
            Beam = Spawn(BeamEffectClass ,,, Start,);
        Beam.mSpawnVecA = HitLocation;

        if(bReflect == true)
        {
            Start = HitLocation;
            Dir = Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}*/

simulated function Tick(float dt)
{
    local Vector StartTrace, /*EndTrace, V,*/ X, Y, Z;
    local Vector HitLocation, /*HitNormal,*/ EndEffect, FireStart;
    local Actor Other;
    //local Rotator Aim;
    local float /*Step,*/ ls, dist;
    local bot B;
    local bool bShouldStop/*, bIsHealingObjective*/;
    //local int AdjustedDamage;
    local ToscBeamEffect LB1;

    bShouldStop = false;
    if (Controller == None)
    {
        Disable('Tick');
        return;
    }

    if (Controller != None && Controller.Enemy != None)
        dist = VSize(Controller.Enemy.Location - Location);
    /*if ( bShotAnim/*!bIsFiring*/ )
    {
        return;
    }*/

    /*if (Controller.Enemy == None)
    {
        DestroyEffects();
        bShotAnim = false;
        Disable('tick');
    }*/

    if (Controller != None && Controller.Enemy != None && (dist > MinChargeDistance || Controller.Enemy.health <= 0))
    {
        Uptime = 0;
        if (BeamA != None)
        {
            BeamA.Destroy();
        }
        if (LB1 != None)
        {
            LB1 = None;
        }
        bDoHit = false;
        LockedPawn = None;
        AmbientSound = Default.AmbientSound;
        bShotAnim = false;
        Disable('Tick');
        return;
    }
    else if (Controller != None && Controller.Enemy != None && dist <= MinChargeDistance)
    {
        Uptime += dt;
        bDoHit = true;
    }
    //log("dist:"$dist);
    //log("uptime:"$uptime);
    if ( Links < 0 )
    {
        log("warning:"@Instigator@"drakk had"@Links@"links");
        Links = 0;
    }
    //log("tick");
    ls = LinkScale[Min(Links,5)];

    if ( ((UpTime > 0.0) || (Role <= ROLE_Authority)) )
    {
            //UpTime -= dt;

        // the to-hit trace always starts right in front of the eye
        //GetViewAxes(X, Y, Z);
        GetAxes(Rotation,X,Y,Z);
        StartTrace = GetFireStart( X, Y, Z);
            TraceRange = default.TraceRange + Links*250;

            //if ( Role <= ROLE_Authority )
            //{
            if ( BeamA == None )
                ForEach DynamicActors(class'ToscBeamEffect', LB1 )//class'LinkBeamEffect'
                    if ( !LB1.bDeleteMe && (LB1.Instigator != None) && (LB1.Instigator == Self/*Instigator*/) )
                    {
                        BeamA = LB1;
                        break;
                    }


            if ( BeamA != None )
            {
                LockedPawn = BeamA.LinkedPawn;
                if (BeamA.LinkedPawn == None)
                    LockedPawn = Controller.Enemy;
            }


        //}




            if ( LockedPawn == None )
            {
            //EndTrace = LockedPawn.Location;
                //Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
            Other = Controller.Enemy;
                /*if ( Other != None && Other != Self )
                EndEffect = HitLocation;
            else
                EndEffect = EndTrace;*/
            if ( Other != None )
            {
                EndEffect = Other.Location;
                LockedPawn = Pawn(Other);
            }
            //LockedPawn = Controller.Enemy;
            //EndEffect = LockedPawn.Location;
        }
        if ( BeamA != None )
            BeamA.EndEffect = EndEffect;
        //log("Other:"$Other);
        if (Controller != None)
            Other = Controller.Enemy;
        if ( Other != None && Other != Self )
            {
            //log(bDoHit);
                    if ( lockedpawn != None )
                    {
                        if ( LinkBreakTime <= 0.0 )
                                SetLinkTo( None );
                        else
                                LinkBreakTime -= dt;
                    }
            // beam is updated every frame, but damage is only done based on the firing rate
            if ( bDoHit )
                    {
                            if ( BeamA != None )
                    BeamA.bLockedOn = false;

                            MakeNoise(1.0);
                //log("Other:"$Other);
                if ( !Other.bWorldGeometry )
                            {
                    if (Level.TimeSeconds > lastHitTime + 0.5)
                    {
                        Other.TakeDamage(Damage, Self, HitLocation, MomentumTransfer*X, DamageType);
                        //LockedPawn.TakeDamage(Damage, Self, HitLocation, MomentumTransfer*X, DamageType);
                        lastHitTime = Level.TimeSeconds;
                    }

                    if ( BeamA != None )
                        BeamA.bLockedOn = true;
                }

            }

            if ( bShouldStop )
                B.StopFiring();
            else
            {
                // beam effect is created and destroyed when firing starts and stops
                if ( (BeamA == None)/* && bShotAnim*/ /*bIsFiring*/ )
                {
                    //Spawn(ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError));
                    FireStart=GetBoneCoords(HeadBone).Origin;
                    BeamA = Spawn( BeamEffectClass, Self,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError) );
                    AttachToBone(BeamA, HeadBone);

                    // vary link volume to make sure it gets replicated (in case owning player changed it client side)
                    if ( SentLinkVolume == Default.LinkVolume )
                        SentLinkVolume = Default.LinkVolume + 1;
                    else
                        SentLinkVolume = Default.LinkVolume;
                }

                if ( BeamA != None )
                {
                    LockedPawn=Controller.Enemy;

                    BeamA.LinkColor = 0;


                    BeamA.Links = Links;

                    AmbientSound = BeamSounds[Min(BeamA.Links,3)];
                    SoundVolume = SentLinkVolume;
                    BeamA.LinkedPawn = LockedPawn;
                    BeamA.bHitSomething = (Other != None);
                    BeamA.EndEffect = EndEffect;


                }
            }
        }
    }


    //bStartFire = false;
    //bDoHit = false;
}

function SetLinkTo(Pawn Other)
{
    if (LockedPawn != None && Weapon != None)
    {
        RemoveLink(1 + Links, Instigator);
        Linking = false;
    }

    LockedPawn = Other;

    if (LockedPawn != None)
    {
       /* if (!AddLink(1 + Links, Instigator))
        {
            bFeedbackDeath = true;
        }*/
        Linking = true;

  //      LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
    }
}


function bool AddLink(int Size, Pawn Starter)
{

    if (LockedPawn != None /*&& !bFeedbackDeath*/)
    {
        if (LockedPawn == Starter)
        {
            return false;
        }
        else
        {

                if (AddLink(Size, Starter))
                    Links += Size;
                else
                    return false;

        }
    }
    return true;
}

function RemoveLink(int Size, Pawn Starter)
{


}


function DoFireEffect()
{
    bDoHit = true;
    //UpTime += 0.1;
}

simulated function AnimEnd(int Channel)
{

    local float  dist;
    local vector EnemyLocation;
    local name Anim;
    local float frame,rate;

    //log("AnimEnd");

    GetAnimParams(0, Anim,frame,rate);
    if (Controller.Enemy == None)
        Disable('Tick');
    else if (Controller.Enemy != None)
    {

        EnemyLocation = Controller.Enemy.Location;
        dist = VSize(EnemyLocation - Location);

        if (dist > MinChargeDistance)
        {//log("AnimEnd:1");
            //if ( bShotAnim )
            //  bShotAnim = false;
            Disable('Tick');
            DestroyEffects();
            //LockedPawn = None;
        }
        else if (dist <= MinChargeDistance)
        {
            //Enable('Tick');
            //DoFireEffect();
        }
    }

    Super(XPawn).AnimEnd(Channel);
}

defaultproperties
{
     WeaponClassName(0)="tk_U2Creatures.SingularityCannon"
     ClawDamage=232
     GrabDamage=184
     slice=Sound'tk_U2Creatures.Tosc_Melee_1'
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     MeleeAnims(0)="Melee01"
     MeleeAnims(1)="Melee02"
     WalkMeleeAnims(0)="WalkFrwdMelee01"
     WalkMeleeAnims(1)="WalkFrwdMelee02"
     WalkMeleeAnims(2)="WalkFrwdMelee01"
     DeathAnims(0)="Die01"
     DeathAnims(1)="Die01"
     VictoryAnims(0)="Transform"
     VictoryAnims(1)="Idle01"
     VictoryAnims(2)="Idle02"
     VictoryAnims(3)="Idle03"
     VictoryAnims(4)="Idle04"
     VictoryAnims(5)="IdleWaitLookLeft01"
     VictoryAnims(6)="IdleWaitLookRight01"
     FireAnims(0)="Still_Fr01"
     FireAnims(1)="Still_Fr01"
     FireAnims(2)="Still_Fr01"
     WalkFireAnims(0)="WalkFrwd_Fr01"
     WalkFireAnims(1)="WalkFrwd_Fr01"
     WalkFireAnims(2)="WalkFrwd_Fr01"
     WalkFireAnims(3)="WalkFrwd_Fr01"
     MeleeSounds(0)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_1'
     MeleeSounds(1)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_2'
     MeleeSounds(2)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_3'
     MeleeSounds(3)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_4'
     MeleeSounds(4)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_5'
     MeleeSounds(5)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_6'
     MeleeSounds(6)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_7'
     MeleeSounds(7)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_8'
     MeleeSounds(8)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_9'
     MeleeSounds(9)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_10'
     MeleeSounds(10)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_11'
     MeleeSounds(11)=Sound'tk_U2Creatures.Tosc.Tosc_Melee_12'
     BreakEffect=Class'XEffects.AlienBloodExplosion'
     ArmlessMesh=SkeletalMesh'tk_U2Creatures.Tosc_NoArm'
     BeamDamage=25
     aimerror=400
     BeamDamageType=Class'XWeapons.DamTypeLinkShaft'
     MinChargeDistance=400.000000
     MaxChargeDistance=600.000000
     BeamEffectClass=Class'tk_U2Creatures.ToscBeamEffect'
     DamageType=Class'XWeapons.DamTypeLinkShaft'
     bTryToWalk=True
     HitSound(0)=Sound'tk_U2Creatures.Tosc_Hit_1'
     HitSound(1)=Sound'tk_U2Creatures.Tosc_Hit_2'
     HitSound(2)=Sound'tk_U2Creatures.Tosc_Hit_3'
     HitSound(3)=Sound'tk_U2Creatures.Tosc_Hit_4'
     DeathSound(0)=Sound'tk_U2Creatures.Tosc_Die_1'
     DeathSound(1)=Sound'tk_U2Creatures.Tosc_Die_2'
     DeathSound(2)=Sound'tk_U2Creatures.Tosc_Die_3'
     DeathSound(3)=Sound'tk_U2Creatures.Tosc_Die_4'
     ChallengeSound(0)=Sound'tk_U2Creatures.Tosc_Speak_1'
     ChallengeSound(1)=Sound'tk_U2Creatures.Tosc_Speak_17'
     ChallengeSound(2)=Sound'tk_U2Creatures.Tosc_Speak_12'
     ChallengeSound(3)=Sound'tk_U2Creatures.Tosc_Speak_21'
     FireSound=Sound'tk_U2Creatures.WeaponsA_SingularityCannon.SC_Fire'
     AmmunitionClass=Class'tk_U2Creatures.ToscAmmo'
     ScoringValue=100
     Species=Class'tk_U2Creatures.SPECIES_Tosc'
     GibGroupClass=Class'XEffects.xAlienGibGroup'
     WallDodgeAnims(0)="Turn01"
     WallDodgeAnims(1)="Turn02"
     WallDodgeAnims(2)="Turn01"
     WallDodgeAnims(3)="Turn02"
     IdleHeavyAnim="Idle01"
     IdleRifleAnim="Idle02"
     FireHeavyRapidAnim="Still_Fr01"
     FireHeavyBurstAnim="Still_Fr02"
     FireRifleRapidAnim="Still_Fr03"
     FireRifleBurstAnim="Still_Fr01"
     FireRootBone="Bip01 Spine1"
     bCanStrafe=False
     bCanDoubleJump=False
     MeleeRange=80.000000
     GroundSpeed=206.800003
     AirSpeed=250.000000
     JumpZ=0.000000
     WalkingPct=1.000000
     Health=10000
     SoundDampening=0.550000
     MovementAnims(0)="WalkFrwd01"
     MovementAnims(1)="WalkFrwd02"
     MovementAnims(2)="WalkFrwd03"
     MovementAnims(3)="WalkFrwd04"
     TurnLeftAnim="Turn01"
     TurnRightAnim="Turn02"
     SwimAnims(0)="WalkFrwd01"
     SwimAnims(1)="WalkFrwd05"
     SwimAnims(2)="WalkFrwd03"
     SwimAnims(3)="WalkFrwd04"
     CrouchAnims(0)="WalkFrwd01"
     CrouchAnims(1)="WalkFrwd02"
     CrouchAnims(2)="WalkFrwd03"
     CrouchAnims(3)="WalkFrwd04"
     WalkAnims(0)="WalkFrwd01"
     WalkAnims(1)="WalkFrwd02"
     WalkAnims(2)="WalkFrwd03"
     WalkAnims(3)="WalkFrwd04"
     AirAnims(0)="Turn01"
     AirAnims(1)="Turn02"
     AirAnims(2)="Turn01"
     AirAnims(3)="Turn02"
     TakeoffAnims(0)="Turn01"
     TakeoffAnims(1)="Turn02"
     TakeoffAnims(2)="Turn01"
     TakeoffAnims(3)="Turn02"
     LandAnims(0)="WalkFrwd_Fr01"
     LandAnims(1)="WalkFrwd_Fr01"
     LandAnims(2)="WalkFrwd_Fr01"
     LandAnims(3)="WalkFrwd_Fr01"
     DoubleJumpAnims(0)="Turn01"
     DoubleJumpAnims(1)="Turn02"
     DoubleJumpAnims(2)="Turn01"
     DoubleJumpAnims(3)="Turn02"
     DodgeAnims(0)="Turn01"
     DodgeAnims(1)="Turn02"
     DodgeAnims(2)="Turn01"
     DodgeAnims(3)="Turn02"
     AirStillAnim="Turn01"
     TakeoffStillAnim="Turn02"
     CrouchTurnRightAnim="Turn01"
     CrouchTurnLeftAnim="Turn02"
     IdleCrouchAnim="Idle04"
     IdleSwimAnim="Idle01"
     IdleWeaponAnim="Idle02"
     IdleRestAnim="Idle03"
     IdleChatAnim="Idle04"
     AmbientSound=Sound'tk_U2Creatures.Tosc.Tosc_Idle_4'
     Mesh=SkeletalMesh'tk_U2Creatures.Tosc'
     PrePivot=(Z=4.000000)
     Skins(0)=Shader'tk_U2Creatures.Tosc.toscsingcannonmat'
     Skins(1)=Shader'tk_U2Creatures.Tosc.ToscHeadMAT'
     Skins(2)=Shader'tk_U2Creatures.Tosc.tosclegsmat'
     Skins(3)=Shader'tk_U2Creatures.Tosc.toscarmsmat'
     Skins(4)=Shader'tk_U2Creatures.Tosc.toscarmsmat'
     Skins(5)=Shader'tk_U2Creatures.Tosc.ToscHeadMAT'
     TransientSoundVolume=2.000000
     CollisionRadius=80.000000
     CollisionHeight=120.000000
     Mass=1000.000000
     RotationRate=(Yaw=8192)
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

     bNoRepMesh=False
}
