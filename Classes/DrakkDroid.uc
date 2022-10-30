class DrakkDroid extends U2Creatures;

var int MeleeDamage;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = true;
}

function Step()
{

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

    PlayAnim('PowerDown');
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if ( Damage > 50 )
        Super.PlayTakeHit(HitLocation,Damage,DamageType);
}

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


    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
                PlayAnim('HitLeft01',, 0.1);
        }
        else if ( Dir Dot X < -0.7 )
        {
            PlayAnim('HitRght01',, 0.1);
        }
        else if ( Dir Dot Y > 0 )
        {
            PlayAnim('HitHead01',, 0.1);
        }
        else
    {
            PlayAnim('Splayed',, 0.1);
    }




}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    SetAnimAction('IdleWaitBreath02');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function HitDamageTarget()
{
    if ( MeleeDamageTarget(MeleeDamage, (5000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}


function RangedAttack(Actor A)
{
    local float Dist;

    if ( bShotAnim )
        return;


    Dist = VSize(A.Location - Location);

    if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
        return;

    if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
    {

        SetAnimAction('MeleeAttack01');
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
        //Sleep(0.49);

        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        return;
    }


}

defaultproperties
{
     MeleeDamage=15
     bCanDodge=False
     bTryToWalk=True
     bAlwaysStrafe=True
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
     FireSound=Sound'tk_U2Creatures.Drakk.MeleeAttack1'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_DrakkDroid'
     GibGroupClass=Class'tk_U2Creatures.DrakkDroidGibGroup'
     WallDodgeAnims(0)="WalkFrwd01"
     WallDodgeAnims(1)="WalkFrwd01"
     WallDodgeAnims(2)="WalkFrwd01"
     WallDodgeAnims(3)="WalkFrwd01"
     IdleHeavyAnim="IdleWaitBreath01"
     IdleRifleAnim="IdleWaitBreath02"
     FireHeavyRapidAnim="MeleeAttack01"
     FireHeavyBurstAnim="MeleeAttack01"
     FireRifleRapidAnim="MeleeAttack01"
     FireRifleBurstAnim="MeleeAttack01"
     MeleeRange=40.000000
     GroundSpeed=800.000000
     AirSpeed=800.000000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="WalkFrwd01"
     MovementAnims(1)="WalkFrwd01"
     MovementAnims(2)="WalkFrwd01"
     MovementAnims(3)="WalkFrwd01"
     TurnLeftAnim="WalkFrwd01"
     TurnRightAnim="WalkFrwd01"
     SwimAnims(0)="WalkFrwd01"
     SwimAnims(1)="WalkFrwd01"
     SwimAnims(2)="WalkFrwd01"
     SwimAnims(3)="WalkFrwd01"
     CrouchAnims(0)="WalkFrwd01"
     CrouchAnims(1)="WalkFrwd01"
     CrouchAnims(2)="WalkFrwd01"
     CrouchAnims(3)="WalkFrwd01"
     WalkAnims(0)="WalkFrwd01"
     WalkAnims(1)="WalkFrwd01"
     WalkAnims(2)="WalkFrwd01"
     WalkAnims(3)="WalkFrwd01"
     AirAnims(0)="WalkFrwd01"
     AirAnims(1)="WalkFrwd01"
     AirAnims(2)="WalkFrwd01"
     AirAnims(3)="WalkFrwd01"
     TakeoffAnims(0)="WalkFrwd01"
     TakeoffAnims(1)="WalkFrwd01"
     TakeoffAnims(2)="WalkFrwd01"
     TakeoffAnims(3)="WalkFrwd01"
     LandAnims(0)="WalkFrwd01"
     LandAnims(1)="WalkFrwd01"
     LandAnims(2)="WalkFrwd01"
     LandAnims(3)="WalkFrwd01"
     DoubleJumpAnims(0)="WalkFrwd01"
     DoubleJumpAnims(1)="WalkFrwd01"
     DoubleJumpAnims(2)="WalkFrwd01"
     DoubleJumpAnims(3)="WalkFrwd01"
     DodgeAnims(0)="WalkFrwd01"
     DodgeAnims(1)="WalkFrwd01"
     DodgeAnims(2)="WalkFrwd01"
     DodgeAnims(3)="WalkFrwd01"
     AirStillAnim="WalkFrwd01"
     TakeoffStillAnim="WalkFrwd01"
     CrouchTurnRightAnim="WalkFrwd01"
     CrouchTurnLeftAnim="WalkFrwd01"
     IdleCrouchAnim="IdleWaitBreath01"
     IdleSwimAnim="WalkFrwd01"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     IdleChatAnim="IdleWaitBreath02"
     AmbientSound=Sound'tk_U2Creatures.Drakk.Ambient'
     Mesh=SkeletalMesh'tk_U2Creatures.DrakkDroid'
     DrawScale=0.550000
     PrePivot=(Z=15.000000)
     Skins(0)=Shader'tk_U2Creatures.Drakk.drakkdroidFX'
     TransientSoundVolume=2.000000
     CollisionRadius=28.000000
     CollisionHeight=55.000000
     Mass=200.000000
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
