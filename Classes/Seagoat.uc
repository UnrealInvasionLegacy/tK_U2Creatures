class Seagoat extends U2Creatures config(U2CreaturesConfig);

var int MeleeDamage;
var bool bLunging;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = true;

    MonsterController(Controller).CombatStyle = 1.0;
}

simulated function PostNetBeginPlay()
{
    local float SkinVar;

    Super.PostNetBeginPlay();

    SkinVar = FRand();

    if (SkinVar <= 0.30)
    {
        Skins[0]=Shader'tk_U2Creatures.CharacterMaterials.amphBFinal';
        Skins[1]=Shader'tk_U2Creatures.CharacterMaterials.amphBFinal';
    }
    else
    {
        Skins[0]=Shader'tk_U2Creatures.CharacterMaterials.amphAFinal';
        Skins[1]=Shader'tk_U2Creatures.CharacterMaterials.amphAFinal';
    }
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
    if ( !bShotAnim && (FRand() < 0.3) )
    {
        bShotAnim = true;
        SetAnimAction('DodgeF');
    }
    Controller.Destination = Location + 200 * duckDir;
    Velocity = GroundSpeed * duckDir;
    Controller.GotoState('TacticalMove', 'DoMove');
    return true;
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

    PlayAnim('Death');

    GetAnimParams(0, Anim,frame,rate);

    //if ( frame >= 0.99 )
    //  SetPhysics(PHYS_KarmaRagdoll);


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

    if ( Anim == 'DodgeB' || Anim == 'DodgeF' || Anim == 'DodgeL' || Anim == 'DodgeR'  )
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
                PlayAnim('LeftHit',, 0.1);
        }
        else if ( Dir Dot X < -0.7 )
        {
            PlayAnim('RightHit',, 0.1);
        }
        else if ( Dir Dot Y > 0 )
        {
            PlayAnim('LeftHit',, 0.1);
        }
        else
    {
            PlayAnim('RightHit',, 0.1);
    }




}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    SetAnimAction('Personality');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function BiteDamageTarget()
{
    if ( MeleeDamageTarget(MeleeDamage, (25000 * Normal(Controller.Target.Location - Location))) )
        PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
}


function RangedAttack(Actor A)
{
    local float Dist;

    if ( bShotAnim )
        return;


    Dist = VSize(A.Location - Location);

    if ( Dist > 250 )
        return;

    /*if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        return;
    }*/

    //bShotAnim = true;
    if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        /*if ( FRand() < 0.5 )
        {
            SetAnimAction('Attack1');
            PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);
                //Sleep(0.49);
        }
        else
        {*/
            SetAnimAction('Attack2');
            PlaySound(sound'tk_U2Creatures.MeleeAttack2', SLOT_Interact);
                //Sleep(0.28)
        //}
        //Controller.bPreparingMove = true;
        bShotAnim = true;
        Acceleration = vect(0,0,0);
        return;
    }

    else if ( Dist <= 150 && FRand() < 0.20 )
    {
        bLunging = true;
        Enable('Bump');
        SetAnimAction('Jump');
        Velocity = 500 * Normal(A.Location + A.CollisionHeight * vect(0,0,0.75) - Location);
        if ( dist > CollisionRadius + A.CollisionRadius + 35 )
            Velocity.Z += 0.7 * dist;
        SetPhysics(PHYS_Falling);
        bShotAnim = true;
    }
    //else// if ( Controller.InLatentExecution(Controller.LATENT_MOVETOWARD))
    //{
    //  //SetAnimAction(MovementAnims[0]);
        //return;
    //  Controller.Destination = A.Location;
    //}

    //MeleeDamageTarget(MeleeDamage, (20000.0 * Normal(Controller.Target.Location - Location)) );//MeleeDamage, vect(0,0,0));
    //Controller.bPreparingMove = true;

}

singular function Bump(actor Other)
{
    local name Anim;
    local float frame,rate;

    if ( bShotAnim && bLunging )
    {
        bLunging = false;
        GetAnimParams(0, Anim,frame,rate);
        if ( Anim == 'Jump' )
            MeleeDamageTarget(12, (20000.0 * Normal(Controller.Target.Location - Location)));
    }
    Super.Bump(Other);
}

defaultproperties
{
     MeleeDamage=10
     bTryToWalk=True
     DodgeSkillAdjust=2.000000
     HitSound(0)=Sound'tk_U2Creatures.SeagoatA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.SeagoatA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.SeagoatA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.SeagoatA_HitSoft.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.SeagoatA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.SeagoatA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.SeagoatA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.SeagoatA_Misc.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.SeagoatA_Acquire.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.SeagoatA_Acquire.SeeEnemy2'
     ChallengeSound(2)=Sound'tk_U2Creatures.SeagoatA_Acquire.SeeEnemy3'
     ChallengeSound(3)=Sound'tk_U2Creatures.SeagoatA_Misc.Idle3'
     FireSound=Sound'tk_U2Creatures.SeagoatA_MeleeMotion.MeleeAttack1'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_Seagoat'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     WallDodgeAnims(0)="DodgeF"
     WallDodgeAnims(1)="DodgeB"
     WallDodgeAnims(2)="DodgeL"
     WallDodgeAnims(3)="DodgeR"
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     FireHeavyRapidAnim="Attack1"
     FireHeavyBurstAnim="Attack2"
     FireRifleRapidAnim="Attack1"
     FireRifleBurstAnim="Attack2"
     bCrawler=True
     bCanStrafe=False
     MeleeRange=20.000000
     GroundSpeed=250.000000
     AirSpeed=450.000000
     SoundDampening=0.500000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="Run"
     MovementAnims(1)="BackStep"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"
     TurnLeftAnim="BackStep"
     TurnRightAnim="BackStep"
     SwimAnims(0)="Walk"
     SwimAnims(1)="BackStep"
     SwimAnims(2)="Walk"
     SwimAnims(3)="Walk"
     CrouchAnims(0)="Walk"
     CrouchAnims(1)="Walk"
     CrouchAnims(2)="Walk"
     CrouchAnims(3)="Walk"
     WalkAnims(0)="Walk"
     WalkAnims(1)="BackStep"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     AirAnims(0)="Run"
     AirAnims(1)="Run"
     AirAnims(2)="Run"
     AirAnims(3)="Run"
     LandAnims(0)="Walk"
     LandAnims(1)="Walk"
     LandAnims(2)="Walk"
     LandAnims(3)="Walk"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Run"
     CrouchTurnRightAnim="BackStep"
     CrouchTurnLeftAnim="BackStep"
     IdleCrouchAnim="Personality"
     IdleSwimAnim="Walk"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     IdleChatAnim="Personality"
     Mesh=SkeletalMesh'tk_U2Creatures.Seagoat'
     DrawScale=0.550000
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterials.amphAFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterials.amphAFinal'
     TransientSoundVolume=2.000000
     CollisionRadius=28.000000
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
