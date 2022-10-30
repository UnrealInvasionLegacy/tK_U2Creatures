class Snipe extends U2Creatures;

var int MeleeDamage;
var name DeathAnims[4];

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('Snipe') || (P.IsA('MegaSnipe') ) ) );
}

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

    if (SkinVar <= 0.20)
        Skins[0] = Texture'tk_U2Creatures.SnipeBloody';
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
        Skins[0] = Texture'tk_U2Creatures.Snipe';
    else
        Skins[0] = Shader'tk_U2Creatures.Creatures.SnipeFX';
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
        SetAnimAction('Jump');
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
    PlayAnim(DeathAnims[Rand(4)], 0.8, 0.1);
    /*if ( FRand() < 0.25 )
        PlayAnim('Death',, 0.1);
    else if ( FRand() < 0.50 )
        PlayAnim('Death2',, 0.1);
    else if ( FRand() < 0.75 )
        PlayAnim('DeathBlownUp');
    else
        PlayAnim('Deathmidhitdie');*/
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

    if ( Anim == 'Jump' || Anim == 'DodgeL' || Anim == 'DodgeR'  )
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
        PlaySound(sound'tk_U2Creatures.Idle1',SLOT_Interact);
    if ( FRand() < 0.50)
        SetAnimAction('Taunt01');
    else
        SetAnimAction('Taunt02');
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
    if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius )
        return;
    //bShotAnim = true;

    if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if ( FRand() < 0.35 )
        {
            SetAnimAction('MeleeAttack01');
            PlaySound(sound'tk_U2Creatures.MeleeAttack1', SLOT_Interact);

        }
        else if ( FRand() < 0.65 )
        {
            SetAnimAction('Bite');
            PlaySound(sound'tk_U2Creatures.MeleeAttack2', SLOT_Interact);

        }
        else
        {
            SetAnimAction('Eating2');
            PlaySound(sound'tk_U2Creatures.MeleeAttack3', SLOT_Interact);

        }
        bShotAnim = true;
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        return;
    }
    //else
    //  return;




}

defaultproperties
{
     MeleeDamage=10
     DeathAnims(0)="Death"
     DeathAnims(1)="Death2"
     DeathAnims(2)="DeathBlownUp"
     DeathAnims(3)="Deathmidhitdie"
     bTryToWalk=True
     DodgeSkillAdjust=2.000000
     HitSound(0)=Sound'tk_U2Creatures.SnipeA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.SnipeA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.SnipeA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.SnipeA_HitSoft.Hit2'
     DeathSound(0)=Sound'tk_U2Creatures.SnipeA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.SnipeA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.SnipeA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.SnipeA_Misc.Idle2'
     ChallengeSound(0)=Sound'tk_U2Creatures.SnipeA_Misc.Idle3'
     ChallengeSound(1)=Sound'tk_U2Creatures.SnipeA_Misc.Idle4'
     ChallengeSound(2)=Sound'tk_U2Creatures.SnipeA_Misc.Idle5'
     ChallengeSound(3)=Sound'tk_U2Creatures.SnipeA_Misc.Idle6'
     FireSound=Sound'tk_U2Creatures.SnipeA_MeleeMotion.MeleeAttack1'
     Species=Class'tk_U2Creatures.SPECIES_Snipe'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     WallDodgeAnims(0)="Jump"
     WallDodgeAnims(1)="Jump"
     WallDodgeAnims(2)="DodgeL"
     WallDodgeAnims(3)="DodgeR"
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     FireHeavyRapidAnim="Bite"
     FireHeavyBurstAnim="Eating1"
     FireRifleRapidAnim="Eating2"
     FireRifleBurstAnim="MeleeAttack01"
     bCrawler=True
     bCanStrafe=False
     MeleeRange=10.000000
     GroundSpeed=215.000000
     AirSpeed=450.000000
     Health=30
     SoundDampening=0.600000
     ControllerClass=Class'tk_U2Creatures.U2BasicMeleeMonsterController'
     MovementAnims(0)="RunFrwd"
     MovementAnims(1)="Backup"
     MovementAnims(2)="RunFrwd"
     MovementAnims(3)="RunFrwd"
     TurnLeftAnim="Backup"
     TurnRightAnim="Backup"
     SwimAnims(0)="Swim"
     SwimAnims(1)="Swim"
     SwimAnims(2)="Swim"
     SwimAnims(3)="Swim"
     CrouchAnims(0)="Walk"
     CrouchAnims(1)="Walk"
     CrouchAnims(2)="Walk"
     CrouchAnims(3)="Walk"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Backup"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     AirAnims(0)="RunFrwd"
     AirAnims(1)="RunFrwd"
     AirAnims(2)="RunFrwd"
     AirAnims(3)="RunFrwd"
     LandAnims(0)="Walk"
     LandAnims(1)="Walk"
     LandAnims(2)="Walk"
     LandAnims(3)="Walk"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Run"
     CrouchTurnRightAnim="Backup"
     CrouchTurnLeftAnim="Backup"
     IdleCrouchAnim="Scratch"
     IdleSwimAnim="Swim"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     IdleChatAnim="Personality"
     Mesh=SkeletalMesh'tk_U2Creatures.Snipe'
     DrawScale=1.750000
     PrePivot=(X=-20.000000,Z=-2.000000)
     Skins(0)=Shader'tk_U2Creatures.Creatures.SnipeFX'
     TransientSoundVolume=2.000000
     CollisionRadius=40.000000
     CollisionHeight=25.000000
     RotationRate=(Yaw=32000)
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
