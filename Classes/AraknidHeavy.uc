class AraknidHeavy extends AraknidMedium;

// general ranged attacks properties
var() float ShockwaveToSprayOdds;               // whether to choose the shockwave over the projectile attacks
var() float SpermToPodOdds;                     // which projectile attack to use
//var() class<Projectile> ProjectileClassSperm; // projectile class for sperms spray attack
//var() class<Projectile> ProjectileClassPods;  // projectile class for the pod attack
var() float MinPodRefireDelay;                  // time to wait after pod attack before attacking again.
var() float MinSpermRefireDelay;                // time to wait after sperm attack before attacking again.
var() float MinSpermAttackRange;                // min distance needed for launching sperms spray
var() float MinShockwaveRefireDelay;

// shock wave
var() float ShockwaveLowToHighOdds;             // jump over / duck under shockwaves
var() float MinShockwaveRange;                  // min distance needed for shockwave
var rotator EffectRotation;
var float ShockwaveHeightLow;
var float ShockwaveHeightHigh;
var Emitter ShockwaveEffect;


// attack times
var float LastPodAttackTime;
var float LastShockwaveAttackTime;
var float LastSpermAttackTime;
var float LastAttackTime;                       // any attack (leap, shockwave, spray, or pods

var(Combat) sound PodSounds[5];
var(Combat) sound SpermSounds[2];


function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
}


function ClawDamageTarget()
{
    if ( MeleeDamageTarget(ClawDamage, (25000 * Normal(Controller.Target.Location - Location))) )
    {
        PlaySound(sound'tk_U2Creatures.AraknidLightA_MeleeImpactPoint.MeleeImpactPoint1', SLOT_Interact);
    }
}



function RangedAttack(Actor A)
{
    local float Dist;
    local bool shockwaveTest;
    local name Anim;
    local float frame,rate;
    local vector EnemyLocation;
    //local rotator LeapRotation;

    shockwaveTest = Level.TimeSeconds - LastShockwaveAttackTime < MinShockwaveRefireDelay;


    if ( bShotAnim || (Controller != None && U2MonsterController(Controller).bLeaping) )
        return;

    GetAnimParams(0,Anim,frame,rate);
    if ( Anim == 'Jump01' || Anim == 'Jump01_Start' || Anim == 'Jump01_Mid' || Anim == 'Jump01_MidFrame' || Anim == 'Jump01_Land' )
        return;

    Enable('Tick');

    EnemyLocation = A.Location;
    Dist = VSize(EnemyLocation - Location);


    //bShotAnim = true;
    //log("Shockwavetset:"$shockwaveTest);
    //log("LastShockwaveAttackTime:"$LastShockwaveAttackTime);
    GroundSpeed = Default.GroundSpeed;
    FireRootBone = Default.FireRootBone;
    if ( Physics == PHYS_Swimming )
    {
        SetAnimAction('Bubble01');
        bShotAnim = true;
    }
    else if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        FireRootBone = 'Neck';
        SetAnimAction('Slash01');
        //Controller.bPreparingMove = true;
        //Acceleration = vect(0,0,0);
        bShotAnim = true;
        PlaySound(MeleeSounds[Rand(6)], SLOT_Interact);
    }
    else if ( Physics != Phys_Falling && Dist <= MinShockwaveRange && Level.TimeSeconds - LastShockwaveAttackTime >= MinShockwaveRefireDelay )
    {
        PlaySound(sound'tk_U2Creatures.AraknidHeavyA_GenericC.Shockwave3', SLOT_Misc);
        LastShockwaveAttackTime = Level.TimeSeconds;
        SetAnimAction('Shockwave01');
        bShotAnim = true;
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if ( Physics != Phys_Falling && (Level.TimeSeconds - LastPodAttackTime >= MinPodRefireDelay || Level.TimeSeconds - LastSpermAttackTime >= MinSpermRefireDelay) /*&& Velocity == vect(0,0,0)*/ )
    {
        FireRootBone = 'Neck';
        if (Level.TimeSeconds - LastPodAttackTime >= MinPodRefireDelay && FRand() <= SpermToPodOdds /*&& Velocity == vect(0,0,0)*/)
        {
            SetAnimAction('Suck01');
            LastPodAttackTime = Level.TimeSeconds;
        }
        else if (Level.TimeSeconds - LastSpermAttackTime >= MinSpermRefireDelay /*&& Velocity == vect(0,0,0)*/)
        {
            SetAnimAction('Bubble01');
            LastSpermAttackTime = Level.TimeSeconds;
        }

        bShotAnim = true;
        //Controller.bPreparingMove = true;
        //Acceleration = vect(0,0,0);
        return;
    }
    /*else
    {
        if (Controller != None && Controller.Enemy != None)
        {
            Controller.Destination = Controller.Enemy.Location;
            Controller.GotoState('Charging','Moving');
            //Controller.GotoState('TacticalMove','WaitForAnim');
            //bShotAnim = true;
            GroundSpeed *= 2.5;
            SetAnimAction('RunFlamed01');
            return;
        }
    }*/
    //else
    //  MonsterController(Controller).DoCharge();

}


function SpawnShot()
{
    //FireProj(vect(1.1,0,0.4));
    //local vector X,Y,Z, FireStart;
    local vector FireStart;
    local rotator FireRotation;
    local projectile proj;

    //GetAxes(Rotation,X,Y,Z);
    //FireStart = (vect(1.1,0,0.4));
    //FireStart = GetFireStart(X,Y,Z);
    FireStart = GetBoneCoords('NoseEnd').Origin;

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

    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);

    //else if (Level.TimeSeconds - LastSpermAttackTime >= MinSpermRefireDelay)
    //{
        //LastSpermAttackTime = Level.TimeSeconds;
        proj = Spawn(class'XWeapons.BioGlob',,,FireStart,FireRotation);
        PlaySound(SpermSounds[Rand(2)], SLOT_Interact);
    //}

}

function SpawnPod()
{
    //FireProj(vect(1.1,0,0.4));
    //local vector X,Y,Z, FireStart;
    local vector FireStart;
    local rotator FireRotation;
    local projectile proj;

    //GetAxes(Rotation,X,Y,Z);
    //FireStart = (vect(1.1,0,0.4));
    //FireStart = GetFireStart(X,Y,Z);
    FireStart = GetBoneCoords('NoseEnd').Origin;

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

    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    //if (Level.TimeSeconds - LastPodAttackTime >= MinPodRefireDelay)
    //{
        //LastPodAttackTime = Level.TimeSeconds;
        proj = Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);
        PlaySound(PodSounds[Rand(5)], SLOT_Interact);
    //}
}


function Shockwave()
{
    if( ShockwaveEffect==None )
        ShockwaveEffect = Spawn(class'AraknidHeavyShockwave',,, Location, Rot(0,16384,0));
    ShockwaveEffect.SetBase( Self );
    ShockwaveEffect.SetRotation( Rotation + EffectRotation );

    //ShockwaveEffect.Trigger( Self, Self );
    ShockwaveEffect.GotoState('Explode');
    //class'UtilGame'.static.MakeShake( Self, Location, 10000, 10, 0.5 );
    //LastShockwaveAttackTime = Level.TimeSeconds;
    LastAttackTime = Level.TimeSeconds;
    class'UtilGame'.static.MakeShake( Self, Location, 10000, 10, 0.5 );
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                    vector momentum, class<DamageType> damageType)
{
    if (damageType == Class'DamTypeAraknidHeavyShockwave')
        return;
    super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    if ( FRand() < 0.50)
        SetAnimAction('IdleLookL01');
    else
        SetAnimAction('IdleLookR01');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

simulated function Step()
{
    //PlaySound(sound'tk_U2Creatures.MovementSkitterWalkLoud', SLOT_Interact);
    Super(U2Creatures).Step();
    PlaySound(StepSounds[Rand(4)], SLOT_Interact);
}

event Landed(vector HitNormal)
{
    PlaySound(LandSounds[Rand(6)], SLOT_Interact);
    SetPhysics(PHYS_Walking);
    Super(U2Creatures).Landed(HitNormal);
}
//  FireRootBone="Neck"

defaultproperties
{
     ShockwaveToSprayOdds=0.330000
     SpermToPodOdds=0.500000
     MinPodRefireDelay=8.000000
     MinSpermRefireDelay=5.000000
     MinSpermAttackRange=512.000000
     MinShockwaveRefireDelay=10.000000
     ShockwaveLowToHighOdds=0.670000
     MinShockwaveRange=400.000000
     ShockwaveHeightLow=-60.000000
     ShockwaveHeightHigh=20.000000
     PodSounds(0)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Pod1'
     PodSounds(1)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Pod2'
     PodSounds(2)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Pod3'
     PodSounds(3)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Pod5'
     PodSounds(4)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Pod6'
     SpermSounds(0)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Sperm1'
     SpermSounds(1)=Sound'tk_U2Creatures.AraknidHeavyA_Misc.Sperm2'
     ClawDamage=40
     MeleeSounds(0)=Sound'tk_U2Creatures.AraknidHeavyA_MeleeMotion.MeleeMotion1'
     MeleeSounds(1)=Sound'tk_U2Creatures.AraknidHeavyA_MeleeMotion.MeleeMotion2'
     MeleeSounds(2)=Sound'tk_U2Creatures.AraknidHeavyA_MeleeMotion.MeleeMotion3'
     MeleeSounds(3)=Sound'tk_U2Creatures.AraknidHeavyA_MeleeMotion.MeleeMotion4'
     MeleeSounds(4)=Sound'tk_U2Creatures.AraknidHeavyA_MeleeMotion.MeleeMotion5'
     MeleeSounds(5)=Sound'tk_U2Creatures.AraknidHeavyA_MeleeMotion.MeleeMotion6'
     StepSounds(0)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Move1'
     StepSounds(1)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Move2'
     StepSounds(2)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Move3'
     StepSounds(3)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Move4'
     LandSounds(0)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Land1'
     LandSounds(1)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Land2'
     LandSounds(2)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Land3'
     LandSounds(3)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Land4'
     LandSounds(4)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Land5'
     LandSounds(5)=Sound'tk_U2Creatures.AraknidHeavyA_Move.Land6'
     LungeDamage=75
     StepShakeRadius=1024.000000
     StepShakeMagnitude=7.000000
     StepShakeDuration=0.400000
     LandShakeRadius=1024.000000
     LandShakeMagnitude=10.000000
     LandShakeDuration=0.600000
     LeapMinRange=256.000000
     LeapOdds=0.500000
     LeapDelayFailure=5.000000
     LeapDelaySuccess=15.000000
     LeapMaxDamage=75
     LeapMaxMomentumTransfer=100000.000000
     MinLeapRefireDelay=5.000000
     bBoss=True
     HitSound(0)=Sound'tk_U2Creatures.AraknidHeavyA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.AraknidHeavyA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.AraknidHeavyA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.AraknidHeavyA_HitHard.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.AraknidHeavyA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.AraknidHeavyA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.AraknidHeavyA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.AraknidHeavyA_Idle.Idle3'
     ChallengeSound(0)=Sound'tk_U2Creatures.AraknidHeavyA_Acquire.Acquire1'
     ChallengeSound(1)=Sound'tk_U2Creatures.AraknidHeavyA_Acquire.Acquire2'
     ChallengeSound(2)=Sound'tk_U2Creatures.AraknidHeavyA_Acquire.Acquire5'
     ChallengeSound(3)=Sound'tk_U2Creatures.AraknidHeavyA_Acquire.Acquire6'
     AmmunitionClass=Class'tk_U2Creatures.AraknidHeavyAmmo'
     Species=Class'tk_U2Creatures.SPECIES_AraknidHeavy'
     GibGroupClass=Class'tk_U2Creatures.AraknidHeavyGibGroup'
     GroundSpeed=245.000000
     Health=2000
     ControllerClass=Class'tk_U2Creatures.U2AraknidHeavyController'
     Mesh=SkeletalMesh'tk_U2Creatures.AraknidHeavy'
     DrawScale=1.000000
     PrePivot=(X=10.000000,Z=0.000000)
     Skins(0)=Shader'tk_U2Creatures.Araknid.AraknidHeavyBody1FX'
     Skins(1)=Shader'tk_U2Creatures.Araknid.araknidheavybody2FX'
     CollisionRadius=100.000000
     CollisionHeight=80.000000
     Mass=300.000000
     RotationRate=(Yaw=20000)
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
