class UglyFish extends KillerTadpole;

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
    SetAnimAction('MeleeAttack01');

 // BiteDamageTarget(BiteDamage, (BiteDamage * 1000.0 * Normal(Controller.Target.Location - Location)));
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
        PlaySound(sound'tk_U2Creatures.UglyFishA_DieSoft.DieSoft1', SLOT_Talk, 4 * TransientSoundVolume);
        PlayAnim('DeathFoldDie', 0.7, 0.1);
    }
    else
        TweenAnim('HitGut', 0.35);

    super.PlayDying(DamageType,HitLoc);

}


simulated function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('HitGut', 0.05);
}


simulated function AnimEnd(int Channel)
{
    if(bFlopping)
    {
        if (Physics == PHYS_None)
        {
                TweenAnim('HitGut', 0.2);
        }
        else
            PlayAnim('HitGut', 0.7);
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
        SetAnimAction('HitGut');
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
        TweenAnim('HitGut', 0.3);
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
     BiteDamage=25
     HitSound(0)=Sound'tk_U2Creatures.UglyFishA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.UglyFishA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.UglyFishA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.UglyFishA_HitSoft.Hit1'
     DeathSound(0)=Sound'tk_U2Creatures.UglyFishA_DieSoft.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.UglyFishA_DieSoft.DieSoft2'
     DeathSound(2)=Sound'tk_U2Creatures.UglyFishA_DieSoft.DieSoft3'
     DeathSound(3)=Sound'tk_U2Creatures.UglyFishA_Move.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.UglyFishA_Move.Idle1'
     ChallengeSound(1)=Sound'tk_U2Creatures.UglyFishA_Move.Idle3'
     ChallengeSound(2)=Sound'tk_U2Creatures.UglyFishA_Move.Idle4'
     ChallengeSound(3)=Sound'tk_U2Creatures.UglyFishA_Move.Idle5'
     FireSound=Sound'tk_U2Creatures.UglyFishA_MeleeDamage.MeleeAttack1'
     Species=Class'tk_U2Creatures.SPECIES_Ugly'
     IdleHeavyAnim="WalkFrwd01"
     IdleRifleAnim="WalkFrwd01"
     MeleeRange=40.000000
     WaterSpeed=560.000000
     Health=250
     MovementAnims(0)="RunFrwd01"
     MovementAnims(1)="RunFrwd01"
     MovementAnims(2)="RunFrwd01"
     MovementAnims(3)="RunFrwd01"
     TurnLeftAnim="WalkFrwd01"
     TurnRightAnim="WalkFrwd01"
     SwimAnims(0)="RunFrwd01"
     SwimAnims(1)="RunFrwd01"
     SwimAnims(2)="RunFrwd01"
     SwimAnims(3)="RunFrwd01"
     WalkAnims(0)="RunFrwd01"
     WalkAnims(1)="RunFrwd01"
     WalkAnims(2)="RunFrwd01"
     WalkAnims(3)="RunFrwd01"
     AirAnims(0)="RunFrwd01"
     AirAnims(1)="RunFrwd01"
     AirAnims(2)="RunFrwd01"
     AirAnims(3)="RunFrwd01"
     TakeoffAnims(0)="RunFrwd01"
     TakeoffAnims(1)="RunFrwd01"
     TakeoffAnims(2)="RunFrwd01"
     TakeoffAnims(3)="RunFrwd01"
     DoubleJumpAnims(0)="RunFrwd01"
     DoubleJumpAnims(1)="RunFrwd01"
     DoubleJumpAnims(2)="RunFrwd01"
     DoubleJumpAnims(3)="RunFrwd01"
     DodgeAnims(0)="RunFrwd01"
     DodgeAnims(1)="RunFrwd01"
     DodgeAnims(2)="RunFrwd01"
     DodgeAnims(3)="RunFrwd01"
     AirStillAnim="RunFrwd01"
     TakeoffStillAnim="RunFrwd01"
     IdleSwimAnim="WalkFrwd01"
     IdleWeaponAnim="WalkFrwd01"
     IdleRestAnim="WalkFrwd01"
     IdleChatAnim="WalkFrwd01"
     AmbientSound=Sound'tk_U2Creatures.UglyFishA_Move.Idle2'
     Mesh=SkeletalMesh'tk_U2Creatures.UglyFish'
     PrePivot=(X=-100.000000)
     Skins(0)=Texture'tk_U2Creatures.Uglyfish1'
     Skins(1)=Texture'tk_U2Creatures.Uglyfish1'
     CollisionRadius=150.000000
     CollisionHeight=50.000000
     Mass=150.000000
     Buoyancy=80.000000
     RotationRate=(Pitch=32,Yaw=8000)
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
