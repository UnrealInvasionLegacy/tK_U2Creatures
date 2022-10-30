class DrakkLight extends U2Creatures;


//A huge fucking mess, even by my standards
var class<Projectile> ProjectileClass;
var int AimError;
var() float MinChargeDistance;
var() float MaxChargeDistance;
var LinkBeamEffect          BeamA, BeamB;
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
var Sound BeamSounds[4];
var float lastHitTime;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = true;
    Disable('Tick');
}

simulated function DestroyEffects()
{


    if ( Level.NetMode != NM_Client )
    {
        if ( BeamA != None )
            BeamA.Destroy();
    if ( BeamB != None )
        BeamB.Destroy();
    }
    //LockedPawn = None;
}

function Step()
{
    //PlaySound(sound'scuttle1pp', SLOT_Interact);
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Flying);//walking
}



event Landed(vector HitNormal)
{

    SetPhysics(PHYS_Flying);//walking

    Super.Landed(HitNormal);
}

event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Flying);//walking
    Super.HitWall(HitNormal,HitWall);
}



simulated function PlayDirectionalDeath(Vector HitLoc)
{

    PlayAnim('Still');
    /*ArmFallOff(4, 'Bone63', class'XEffects.BotSparks');
    ArmFallOff(4, 'Bone19', class'XEffects.BotSparks');
    ArmFallOff(4, 'Bone02', class'XEffects.BotSparks');
    ArmFallOff(4, 'Bone36', class'XEffects.BotSparks');*/
}

simulated function ArmFallOff(int Slot, name BoneName, class<xEmitter> BreakEffect)
{
    local vector ArmBloodLoc;


    PlaySound(HitSound[0], SLOT_None, 2.0,,,, False);
    SetBoneScale(Slot, 0.0, BoneName);
    ArmBloodLoc = GetBoneCoords(BoneName).Origin;
    if (Level.NetMode != NM_DedicatedServer)
        spawn(BreakEffect,,,ArmBloodLoc);
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{}

simulated function PlayDirectionalHit(Vector HitLoc)
{
}



function PlayVictory()
{
    SetPhysics(PHYS_Flying);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    SetAnimAction('Attack1');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



/*function HitDamageTarget()
{
    if ( MeleeDamageTarget(MeleeDamage, (25000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}*/


function RangedAttack(Actor A)
{
    local float Dist;
    local vector EnemyLocation;

    EnemyLocation = Controller.Enemy.Location;
    dist = VSize(EnemyLocation - Location);

    if (/*!bShotAnim &&*/ dist <= MinChargeDistance)
    {
        Enable('Tick');
        bShotAnim = true;
        DoFireEffect();
        //SetAnimAction('Unfold');
        //LockedPawn = Controller.Enemy;
        AirAnims[0]='IdleWaitBreath';
        AirAnims[1]='IdleWaitBreath';
        AirAnims[2]='IdleWaitBreath';
        AirAnims[3]='IdleWaitBreath';
        MovementAnims[0]='IdleWaitBreath';
        MovementAnims[1]='IdleWaitBreath';
        MovementAnims[2]='IdleWaitBreath';
        MovementAnims[3]='IdleWaitBreath';
    }
    //if ( bShotAnim )
    //  return;

    //Enable('Tick');
    //bShotAnim=true;

    //SetAnimAction(FireHeavyRapidAnim);
    //Controller.bPreparingMove=true;
    //FireProjectile();

}

function FireProjectile()
{
    local vector FireStart,X,Y,Z;
    local name HandA, HandB, HandC, HandD;

    HandA = 'Bone68';
    HandB = 'Bone30';
    HandC = 'Bone48';
    HandD = 'Bone08';

    if ( Controller != None )
    {
        GetAxes(Rotation,X,Y,Z);
        FireStart = GetBoneCoords(HandA).Origin;
        Spawn(ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError));
        PlaySound(FireSound,SLOT_Interact);

        FireStart = GetBoneCoords(HandB).Origin;
        Spawn(ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError));
        PlaySound(FireSound,SLOT_Interact);

        FireStart = GetBoneCoords(HandC).Origin;
        Spawn(ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError));
        PlaySound(FireSound,SLOT_Interact);

        FireStart = GetBoneCoords(HandD).Origin;
        Spawn(ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError));
        PlaySound(FireSound,SLOT_Interact);
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

        if (/*dist < MinChargeDistance ||*/ dist > MinChargeDistance)
        {//log("AnimEnd:1");
            //if ( bShotAnim )
            //  bShotAnim = false;
            Disable('Tick');
            DestroyEffects();
            //LockedPawn = None;
            TweenAnim('Still',0.9);
            //SetAnimAction('Still');
            AirAnims[0]='Still';
            AirAnims[1]='Still';
            AirAnims[2]='Still';
            AirAnims[3]='Still';
            MovementAnims[0]='Still';
            MovementAnims[1]='Still';
            MovementAnims[2]='Still';
            MovementAnims[3]='Still';
        }
        else if (dist <= MinChargeDistance)
        {
            //Enable('Tick');
            //DoFireEffect();

            if (Anim != 'Unfold')
                SetAnimAction('Unfold');
            AirAnims[0]='IdleWaitBreath';
            AirAnims[1]='IdleWaitBreath';
            AirAnims[2]='IdleWaitBreath';
            AirAnims[3]='IdleWaitBreath';
            MovementAnims[0]='IdleWaitBreath';
            MovementAnims[1]='IdleWaitBreath';
            MovementAnims[2]='IdleWaitBreath';
            MovementAnims[3]='IdleWaitBreath';
        }
    }

    Super(XPawn).AnimEnd(Channel);
}

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
    local DrakkLinkBeamEffect LB1, LB2;

    bShouldStop = false;
    if (Controller == None)
        Disable('Tick');

    if (Controller.Enemy != None)
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

    if (Controller.Enemy != None && (dist > MinChargeDistance || Controller.Enemy.health <= 0))
    {
        Uptime = 0;
        if (BeamA != None && BeamB != None)
        {
            BeamA.Destroy();
            BeamB.Destroy();
        }
        if (LB1 != None && LB2 != None)
        {
            LB1 = None;
            LB2 = None;
        }
        bDoHit = false;
        LockedPawn = None;
        AmbientSound = Default.AmbientSound;
        bShotAnim = false;
        Disable('Tick');
        return;
    }
    else if (Controller.Enemy != None && dist <= MinChargeDistance)
    {
        Uptime += dt;
        bDoHit = true;
    }
    //log("dist:"$dist);
    //log("uptime:"$uptime);
    if ( Links < 0 )
    {
    //  log("warning:"@Instigator@"drakk had"@Links@"links");
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
                ForEach DynamicActors(class'DrakkLinkBeamEffect', LB1 )//class'LinkBeamEffect'
                    if ( !LB1.bDeleteMe && (LB1.Instigator != None) && (LB1.Instigator == Self/*Instigator*/) && (LB1 != BeamB ) )
                    {
                        BeamA = LB1;
                        break;
                    }
            if ( BeamB == None )
                ForEach DynamicActors(class'DrakkLinkBeamEffect', LB2 )//class'LinkBeamEffect'
                    if ( !LB2.bDeleteMe && (LB2.Instigator != None) && (LB2.Instigator == Self/*Instigator*/) && (LB2 != BeamA ) )
                    {
                        BeamB = LB2;
                        break;
                    }

            if ( BeamA != None )
            {
                LockedPawn = BeamA.LinkedPawn;
                if (BeamA.LinkedPawn == None)
                    LockedPawn = Controller.Enemy;
            }
            //if ( BeamB != None )
            //  LockedPawn = BeamB.LinkedPawn;

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
        if ( BeamB != None )
            BeamB.EndEffect = EndEffect;

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
                            if ( BeamB != None )
                    BeamB.bLockedOn = false;

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
                    if ( BeamB != None )
                        BeamB.bLockedOn = true;
                }

            }

            if ( bShouldStop )
                B.StopFiring();
            else
            {
                // beam effect is created and destroyed when firing starts and stops
                if ( (BeamA == None && BeamB == None)/* && bShotAnim*/ /*bIsFiring*/ )
                {
                    //Spawn(ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError));
                    FireStart=GetBoneCoords('Bone50').Origin;
                    BeamA = Spawn( BeamEffectClass, Self,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError) );
                    FireStart=GetBoneCoords('Bone10').Origin;
                    BeamB = Spawn( BeamEffectClass, Self,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,AimError) );
                    AttachToBone(BeamA, 'Bone50');
                    AttachToBone(BeamB, 'Bone10');
                    // vary link volume to make sure it gets replicated (in case owning player changed it client side)
                    if ( SentLinkVolume == Default.LinkVolume )
                        SentLinkVolume = Default.LinkVolume + 1;
                    else
                        SentLinkVolume = Default.LinkVolume;
                }

                if ( BeamA != None && BeamB != None )
                {
                    LockedPawn=Controller.Enemy;

                    BeamA.LinkColor = 0;
                    BeamB.LinkColor = 0;

                    BeamA.Links = Links;
                    BeamB.Links = Links;
                    AmbientSound = BeamSounds[Min(BeamA.Links,3)];
                    SoundVolume = SentLinkVolume;
                    BeamA.LinkedPawn = LockedPawn;
                    BeamA.bHitSomething = (Other != None);
                    BeamA.EndEffect = EndEffect;
                    BeamB.LinkedPawn = LockedPawn;
                    BeamB.bHitSomething = (Other != None);
                    BeamB.EndEffect = EndEffect;

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

defaultproperties
{
     aimerror=250
     MinChargeDistance=400.000000
     MaxChargeDistance=600.000000
     BeamEffectClass=Class'tk_U2Creatures.DrakkLinkBeamEffect'
     DamageType=Class'XWeapons.DamTypeLinkShaft'
     Damage=10
     TraceRange=1100.000000
     LinkFlexibility=0.640000
     LinkScale(1)=0.500000
     LinkScale(2)=0.900000
     LinkScale(3)=1.200000
     LinkScale(4)=1.400000
     LinkScale(5)=1.500000
     LinkBreakDelay=0.500000
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     bCanDodge=False
     DodgeSkillAdjust=2.000000
     HitSound(0)=Sound'tk_U2Creatures.Drakk.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.Drakk.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.Drakk.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.Drakk.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.Drakk.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.Drakk.DieSoft2'
     DeathSound(2)=Sound'tk_U2Creatures.Drakk.DieSoft3'
     DeathSound(3)=Sound'tk_U2Creatures.Drakk.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.Drakk.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.Drakk.SeeEnemy2'
     ChallengeSound(2)=Sound'tk_U2Creatures.Drakk.SeeEnemy3'
     ChallengeSound(3)=Sound'tk_U2Creatures.Drakk.SeeEnemy1'
     FireSound=SoundGroup'WeaponSounds.ShockRifle.ShockRifleAltFire'
     ScoringValue=4
     Species=Class'tk_U2Creatures.SPECIES_DrakkLight'
     GibGroupClass=Class'tk_U2Creatures.DrakkDroidGibGroup'
     WallDodgeAnims(0)="Still"
     WallDodgeAnims(1)="Still"
     WallDodgeAnims(2)="Still"
     WallDodgeAnims(3)="Still"
     IdleHeavyAnim="Still"
     IdleRifleAnim="Still"
     FireHeavyRapidAnim="Attack1"
     FireHeavyBurstAnim="Attack1"
     FireRifleRapidAnim="Attack1"
     FireRifleBurstAnim="Attack1"
     bCanFly=True
     bCanStrafe=False
     MeleeRange=40.000000
     GroundSpeed=375.000000
     AirSpeed=375.000000
     JumpZ=0.000000
     Health=400
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="Still"
     MovementAnims(1)="Still"
     MovementAnims(2)="Still"
     MovementAnims(3)="Still"
     TurnLeftAnim="Still"
     TurnRightAnim="Still"
     SwimAnims(0)="Still"
     SwimAnims(1)="Still"
     SwimAnims(2)="Still"
     SwimAnims(3)="Still"
     CrouchAnims(0)="Still"
     CrouchAnims(1)="Still"
     CrouchAnims(2)="Still"
     CrouchAnims(3)="Still"
     WalkAnims(0)="Still"
     WalkAnims(1)="Still"
     WalkAnims(2)="Still"
     WalkAnims(3)="Still"
     AirAnims(0)="Still"
     AirAnims(1)="Still"
     AirAnims(2)="Still"
     AirAnims(3)="Still"
     TakeoffAnims(0)="Still"
     TakeoffAnims(1)="Still"
     TakeoffAnims(2)="Still"
     TakeoffAnims(3)="Still"
     LandAnims(0)="Still"
     LandAnims(1)="Still"
     LandAnims(2)="Still"
     LandAnims(3)="Still"
     DoubleJumpAnims(0)="Still"
     DoubleJumpAnims(1)="Still"
     DoubleJumpAnims(2)="IStil"
     DoubleJumpAnims(3)="Still"
     DodgeAnims(0)="Still"
     DodgeAnims(1)="Still"
     DodgeAnims(2)="Still"
     DodgeAnims(3)="Still"
     AirStillAnim="Still"
     TakeoffStillAnim="Still"
     CrouchTurnRightAnim="Still"
     CrouchTurnLeftAnim="Still"
     IdleCrouchAnim="Still01"
     IdleSwimAnim="Still"
     IdleWeaponAnim="Still"
     IdleRestAnim="Still"
     IdleChatAnim="Still01"
     AmbientSound=Sound'tk_U2Creatures.Drakk.Ambient'
     Mesh=SkeletalMesh'tk_U2Creatures.DrakkLight'
     DrawScale=0.350000
     PrePivot=(Z=-20.000000)
     Skins(0)=Shader'tk_U2Creatures.Drakk.DrakkLight_AFX'
     Skins(1)=Shader'tk_U2Creatures.Drakk.DrakkLight_BFX'
     Skins(2)=Shader'tk_U2Creatures.Drakk.drakkmediumbody3fx'
     SoundVolume=250
     SoundRadius=200.000000
     CollisionRadius=34.000000
     CollisionHeight=30.000000
     Mass=350.000000
     RotationRate=(Pitch=4096,Yaw=52000,Roll=3072)
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
