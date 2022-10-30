class Parata extends U2Creatures config(U2CreaturesConfig);

var int MeleeDamage;

function PostBeginPlay()
{
    local float SkinVar;

    Super.PostBeginPlay();
    bMeleeFighter = true;

    SkinVar = FRand();

    if (SkinVar <= 0.50)
    {
        Skins[0]=Texture'tk_U2Creatures.Parata';
    }
    else
    {
        Skins[0]=Texture'tk_U2Creatures.Parata3';
    }

    MonsterController(Controller).CombatStyle = 0.75;
}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('Parata') || (P.IsA('MegaParata') ) ) );
}

function Step()
{
    PlaySound(sound'scuttle1pp', SLOT_Interact);
}


function SetMovementPhysics()
{
    SetPhysics(PHYS_Falling);
}


event Landed(vector HitNormal)
{
    SetPhysics(PHYS_Walking);
    Super.Landed(HitNormal);
}

event HitWall( vector HitNormal, actor HitWall )
{
    if ( HitNormal.Z > MINFLOORZ )
        SetPhysics(PHYS_Walking);
    Super.HitWall(HitNormal,HitWall);
}



simulated function PlayDirectionalDeath(Vector HitLoc)
{
    local name Anim;
    local float frame,rate;

    PlayAnim('Deathmidhitdie');

    GetAnimParams(0, Anim,frame,rate);



}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 55 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

simulated function PlayDirectionalHit(Vector HitLoc)
{

        local Vector X,Y,Z, Dir;

    if ( bShotAnim )
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


        PlayAnim('HitGut01',, 0.1);

}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.FlyingSnakeA_Move.Idle3',SLOT_Interact);
    SetAnimAction('IdleWaitBreath01');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}



function BiteDamageTarget()
{
    if ( MeleeDamageTarget(MeleeDamage, (1 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}


function RangedAttack(Actor A)
{
    local float Dist;

    if ( bShotAnim )
        return;

    Dist = VSize(A.Location - Location);

    if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        return;
    }


    if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
    {

        SetAnimAction('MeleeAttack_full');
        PlaySound(sound'tk_U2Creatures.FlyingSnakeA_MeleeDamage.MeleeAttack1', SLOT_Interact);

        //Controller.bPreparingMove = true;
        bShotAnim = true;
        //Acceleration = vect(0,0,0);
        return;
    }

}

defaultproperties
{
     MeleeDamage=10
     bCanDodge=False
     bTryToWalk=True
     HitSound(0)=Sound'tk_U2Creatures.FlyingSnakeA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.FlyingSnakeA_HitHard.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.FlyingSnakeA_HitSoft.Hit1'
     HitSound(3)=Sound'tk_U2Creatures.FlyingSnakeA_HitHard.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.FlyingSnakeA_DieSoft.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.FlyingSnakeA_Falling.Falling1'
     DeathSound(2)=Sound'tk_U2Creatures.FlyingSnakeA_DieSoft.DieSoft1'
     DeathSound(3)=Sound'tk_U2Creatures.FlyingSnakeA_HitHard.Hit2'
     ChallengeSound(0)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle1'
     ChallengeSound(1)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle2'
     ChallengeSound(2)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle3'
     ChallengeSound(3)=Sound'tk_U2Creatures.FlyingSnakeA_Move.Idle1'
     FireSound=Sound'tk_U2Creatures.FlyingSnakeA_MeleeDamage.MeleeAttack1'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_Parata'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     WallDodgeAnims(0)="HitGut01"
     WallDodgeAnims(1)="HitGut01"
     WallDodgeAnims(2)="HitGut01"
     WallDodgeAnims(3)="HitGut01"
     IdleHeavyAnim="IdleWaitBreath01"
     IdleRifleAnim="IdleWaitBreath01"
     FireHeavyRapidAnim="MeleeAttack_full"
     FireHeavyBurstAnim="MeleeAttack_full"
     FireRifleRapidAnim="MeleeAttack_full"
     FireRifleBurstAnim="MeleeAttack_full"
     bCrawler=True
     bCanJump=False
     bCanStrafe=False
     MeleeRange=40.000000
     GroundSpeed=250.000000
     AirSpeed=450.000000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="IdleWaitBreath01"
     MovementAnims(1)="IdleWaitBreath01"
     MovementAnims(2)="IdleWaitBreath01"
     MovementAnims(3)="IdleWaitBreath01"
     TurnLeftAnim="IdleWaitBreath01"
     TurnRightAnim="IdleWaitBreath01"
     SwimAnims(0)="IdleWaitBreath01"
     SwimAnims(1)="IdleWaitBreath01"
     SwimAnims(2)="IdleWaitBreath01"
     SwimAnims(3)="IdleWaitBreath01"
     CrouchAnims(0)="IdleWaitBreath01"
     CrouchAnims(1)="IdleWaitBreath01"
     CrouchAnims(2)="IdleWaitBreath01"
     CrouchAnims(3)="IdleWaitBreath01"
     WalkAnims(0)="IdleWaitBreath01"
     WalkAnims(1)="IdleWaitBreath01"
     WalkAnims(2)="IdleWaitBreath01"
     WalkAnims(3)="IdleWaitBreath01"
     AirAnims(0)="IdleWaitBreath01"
     AirAnims(1)="IdleWaitBreath01"
     AirAnims(2)="IdleWaitBreath01"
     AirAnims(3)="IdleWaitBreath01"
     TakeoffAnims(0)="IdleWaitBreath01"
     TakeoffAnims(1)="IdleWaitBreath01"
     TakeoffAnims(2)="IdleWaitBreath01"
     TakeoffAnims(3)="IdleWaitBreath01"
     LandAnims(0)="IdleWaitBreath01"
     LandAnims(1)="IdleWaitBreath01"
     LandAnims(2)="IdleWaitBreath01"
     LandAnims(3)="IdleWaitBreath01"
     DoubleJumpAnims(0)="HitGut01"
     DoubleJumpAnims(1)="HitGut01"
     DoubleJumpAnims(2)="HitGut01"
     DoubleJumpAnims(3)="HitGut01"
     DodgeAnims(0)="HitGut01"
     DodgeAnims(1)="HitGut01"
     DodgeAnims(2)="HitGut01"
     DodgeAnims(3)="HitGut01"
     AirStillAnim="IdleWaitBreath01"
     TakeoffStillAnim="IdleWaitBreath01"
     CrouchTurnRightAnim="IdleWaitBreath01"
     CrouchTurnLeftAnim="IdleWaitBreath01"
     IdleCrouchAnim="IdleWaitBreath01"
     IdleSwimAnim="IdleWaitBreath01"
     IdleWeaponAnim="IdleWaitBreath01"
     IdleRestAnim="IdleWaitBreath01"
     IdleChatAnim="IdleWaitBreath01"
     Mesh=SkeletalMesh'tk_U2Creatures.Parata'
     DrawScale=0.550000
     Skins(0)=Texture'tk_U2Creatures.Parata'
     CollisionRadius=40.000000
     CollisionHeight=18.000000
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
