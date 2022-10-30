class KillerTadpole extends U2Creatures;

//code taken from the Satore Monster pack's devilfish class

var float   AirTime;
var(Combat) int BiteDamage;     // Basic damage done by bite.

var() bool bCheckWater; //bool config
var bool bFlopping;

replication
{
    unreliable if(Role == ROLE_Authority)
        bFlopping;
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if(!CheckWater())
        Destroy();
}

function bool CheckWater()
{
    local PhysicsVolume PV;
    local vector HitLoc,HitNorm;


    if(!bCheckWater || PhysicsVolume.bWaterVolume)
        return true;

    foreach TraceActors(class'PhysicsVolume',PV,HitLoc,HitNorm,Location+vect(0,0,-1)*700,Location+vect(0,0,-1)*CollisionHeight/2)
    {
        if(PV!=none && PV.bWaterVolume)
        {
            if(FastTrace(Location,HitLoc))
            if(SetLocation(HitLoc));
                return true;
        }
    }

    return false;

}

function BiteDamageTarget()
{
    if ( MeleeDamageTarget(BiteDamage, (25000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack2', SLOT_Interact);
}

function RangedAttack(Actor A)
{
    local float Dist;
    local float decision;
    if ( bShotAnim )
        return;

    Dist=Vsize(Location-A.Location);
    if (Dist > MeleeRange + CollisionRadius + A.CollisionRadius)
        return;
    bShotAnim = true;
    decision = FRand();
//  PlaySound(bite,SLOT_Interact,,,500);
    Enable('Bump');
    SetAnimAction('Bite');

 // BiteDamageTarget(BiteDamage, (BiteDamage * 1000.0 * Normal(Controller.Target.Location - Location)));
}

simulated event SetAnimAction(name NewAction)
{
    if ( !bWaitForAnim || (Level.NetMode == NM_Client) )
    {
        AnimAction = NewAction;
        if ( PlayAnim(AnimAction,,0.3) )
        {
            if ( Physics != PHYS_None )
                bWaitForAnim = true;
        }
    }
}

singular function Bump(actor Other)
{
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    AmbientSound = None;
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;
    LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);

    if (PhysicsVolume.bWaterVolume)
    {
        PlaySound(sound'tk_U2Creatures.DieSoft1', SLOT_Talk, 4 * TransientSoundVolume);
        PlayAnim('FoldDie', 0.7, 0.1);
    }
    else
        TweenAnim('HitGut01', 0.35);

    super.PlayDying(DamageType,HitLoc);

}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('HitGut01', 0.05);
}

function Landed(vector HitNormal)
{
    if(PhysicsVolume.bWaterVolume)
        return;

    //GotoState('Landed');
    Super.Landed(HitNormal);
}

function PlayVictory()
{
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlayAnim('WalkFwrd01', 0.2, 0.1);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

function SetMovementPhysics()
{
    SetPhysics(PHYS_Swimming);
}

simulated function AnimEnd(int Channel)
{
    if (bShotAnim)
    {
        bShotAnim = false;
        Controller.bPreparingMove = false;
    }
    if(bFlopping)
    {
        if (Physics == PHYS_None)
        {
                TweenAnim('HitGut01', 0.2);
        }
        else
            PlayAnim('HitGut01', 0.7);
    }
    super.AnimEnd(Channel);
}


state Flopping
{
ignores seeplayer, hearnoise, enemynotvisible, hitwall;

    function Timer()
    {

        AirTime += 1;
        if ( AirTime > 25 + 15 * FRand() )
        {
            Health = -1;
            Died(None, class'Drowned', Location);
            return;
        }
        SetPhysics(PHYS_Falling);
        Velocity = 200 * VRand();
        Velocity.Z = 200 + 200 * FRand();
        DesiredRotation.Pitch = Rand(8192) - 4096;
        DesiredRotation.Yaw = Rand(65535);
        SetAnimAction('HitGut01');
    }
    function RangedAttack(Actor A){}

    event PhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        local rotator newRotation;
        if (NewVolume.bWaterVolume)
        {
            newRotation = Rotation;
            newRotation.Roll = 0;
            SetRotation(newRotation);
            SetPhysics(PHYS_Swimming);
            AirTime = 0;
            GotoState(initialstate);
        }
        else
            SetPhysics(PHYS_Falling);
    }

    function Landed(vector HitNormal)
    {
        local rotator newRotation;
        SetPhysics(PHYS_none);
        SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
        newRotation = Rotation;
        newRotation.Pitch = 0;
        newRotation.Roll = Rand(16384) - 8192;
        DesiredRotation.Pitch = 0;
        SetRotation(newRotation);
        //PlaySound(sound'flop1fs',SLOT_Interact,,,400);
        TweenAnim('HitGut01', 0.3);
    }
    simulated event SetAnimAction(name NewAction)
    {
        if ( !bWaitForAnim || (Level.NetMode == NM_Client) )
        {
            AnimAction = NewAction;
            if ( PlayAnim(AnimAction,,0.1) )
            {
                if ( Physics != PHYS_None )
                    bWaitForAnim = true;
            }
        }
    }
        simulated function BeginState()
    {
        bFlopping=true;
    }
    simulated function EndState()
    {

        bFlopping=false;
    }

}

defaultproperties
{
     BiteDamage=10
     bCheckWater=True
     HitSound(0)=Sound'tk_U2Creatures.KillerTadpoleA_HitHard.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.KillerTadpoleA_HitHard.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.KillerTadpoleA_HitHard.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.KillerTadpoleA_HitHard.Hit1'
     DeathSound(0)=Sound'tk_U2Creatures.KillerTadpoleA_DieSoft.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.KillerTadpoleA_DieSoft.DieSoft2'
     DeathSound(2)=Sound'tk_U2Creatures.KillerTadpoleA_DieSoft.DieSoft3'
     DeathSound(3)=Sound'tk_U2Creatures.KillerTadpoleA_Move.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.KillerTadpoleA_Move.Idle1'
     ChallengeSound(1)=Sound'tk_U2Creatures.KillerTadpoleA_Move.Idle3'
     ChallengeSound(2)=Sound'tk_U2Creatures.KillerTadpoleA_Move.Idle4'
     ChallengeSound(3)=Sound'tk_U2Creatures.KillerTadpoleA_Move.Idle5'
     FireSound=Sound'tk_U2Creatures.KillerTadpoleA_MeleeMotion.MeleeAttack1'
     Species=Class'tk_U2Creatures.SPECIES_Tadpole'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     IdleHeavyAnim="WalkFwrd01"
     IdleRifleAnim="WalkFwrd01"
     bCrawler=True
     bCanJump=False
     bCanWalk=False
     bCanStrafe=False
     MeleeRange=14.000000
     GroundSpeed=0.000000
     WaterSpeed=280.000000
     Health=80
     UnderWaterTime=-1.000000
     MovementAnims(0)="RunFwrd01"
     MovementAnims(1)="RunFwrd01"
     MovementAnims(2)="RunFwrd01"
     MovementAnims(3)="RunFwrd01"
     TurnLeftAnim="WalkFwrd01"
     TurnRightAnim="WalkFwrd01"
     SwimAnims(0)="RunFwrd01"
     SwimAnims(1)="RunFwrd01"
     SwimAnims(2)="RunFwrd01"
     SwimAnims(3)="RunFwrd01"
     WalkAnims(0)="RunFwrd01"
     WalkAnims(1)="RunFwrd01"
     WalkAnims(2)="RunFwrd01"
     WalkAnims(3)="RunFwrd01"
     AirAnims(0)="RunFwrd01"
     AirAnims(1)="RunFwrd01"
     AirAnims(2)="RunFwrd01"
     AirAnims(3)="RunFwrd01"
     TakeoffAnims(0)="RunFwrd01"
     TakeoffAnims(1)="RunFwrd01"
     TakeoffAnims(2)="RunFwrd01"
     TakeoffAnims(3)="RunFwrd01"
     LandAnims(0)="Base"
     LandAnims(1)="Base"
     LandAnims(2)="Base"
     LandAnims(3)="Base"
     DoubleJumpAnims(0)="RunFwrd01"
     DoubleJumpAnims(1)="RunFwrd01"
     DoubleJumpAnims(2)="RunFwrd01"
     DoubleJumpAnims(3)="RunFwrd01"
     DodgeAnims(0)="RunFwrd01"
     DodgeAnims(1)="RunFwrd01"
     DodgeAnims(2)="RunFwrd01"
     DodgeAnims(3)="RunFwrd01"
     AirStillAnim="RunFwrd01"
     TakeoffStillAnim="RunFwrd01"
     IdleSwimAnim="WalkFwrd01"
     IdleWeaponAnim="WalkFwrd01"
     IdleRestAnim="WalkFwrd01"
     IdleChatAnim="WalkFwrd01"
     AmbientSound=Sound'tk_U2Creatures.KillerTadpoleA_Move.Idle2'
     Mesh=SkeletalMesh'tk_U2Creatures.KillerTadpole'
     PrePivot=(X=15.000000)
     Skins(0)=Texture'tk_U2Creatures.KillerTadpole'
     CollisionHeight=20.000000
     Mass=80.000000
     Buoyancy=60.000000
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
