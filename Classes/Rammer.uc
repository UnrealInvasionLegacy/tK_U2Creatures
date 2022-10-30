class Rammer extends U2Creatures;

var int RamDamage;

var(Sounds) array<sound> StepSounds[4];


function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = true;
    MonsterController(Controller).CombatStyle = 1.0;
}

simulated function Step()
{
    Super(U2Creatures).Step();
    PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
}

function ServerStep()
{
    Super(U2Creatures).ServerStep();
    if (Level.NetMode == NM_Client)
        PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
}




function SetMovementPhysics()
{
    SetPhysics(PHYS_Falling);
}

/*function bool Dodge(eDoubleClickDir DoubleClickMove)
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
        SetAnimAction('RunFrwdMid01');
    }
    Controller.Destination = Location + 200 * duckDir;
    Velocity = AirSpeed * duckDir;
    Controller.GotoState('TacticalMove', 'DoMove');
    return true;
}*/

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

    PlayAnim('Deathmidhitdie');
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
            PlayAnim('HitGut01',, 0.1);
        }
        else if ( Dir Dot X < -0.7 )
        {
            PlayAnim('HitGut02',, 0.1);
        }
        else if ( Dir Dot Y > 0 )
        {
            PlayAnim('HitGut01',, 0.1);
        }
        else
    {
            PlayAnim('HitGut02',, 0.1);
    }




}



function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
        PlaySound(sound'tk_U2Creatures.RammerA_Misc.Idle6',SLOT_Interact);
    SetAnimAction('IdleWaitBreath03');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}


function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.5 * CollisionRadius * (X+Z-Y);
}



function RamDamageTarget()
{
    if ( MeleeDamageTarget(RamDamage, (25000 * Normal(Controller.Target.Location - Location))) )
        if (FRand() < 0.5)
            PlaySound(sound'tk_U2Creatures.RammerA_MeleeDamage.Headbutt1', SLOT_Interact);
        else
            PlaySound(sound'tk_U2Creatures.RammerA_MeleeDamage.Headbutt2', SLOT_Interact);
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



    //bShotAnim = true;
    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius )
    {

        SetAnimAction('MeleeAttack01');
        if (FRand() < 0.14 )
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack1', SLOT_Interact);
        else if (FRand() < 0.28 )
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack2', SLOT_Interact);
        else if (FRand() < 0.42 )
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack3', SLOT_Interact);
        else if (FRand() < 0.56 )
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack4', SLOT_Interact);
        else if (FRand() < 0.7 )
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack5', SLOT_Interact);
        else if (FRand() < 0.84 )
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack6', SLOT_Interact);
        else
            PlaySound(sound'tk_U2Creatures.RammerA_Misc.MeleeAttack7', SLOT_Interact);

        //Controller.bPreparingMove = true;
        bShotAnim = true;
        //Acceleration = vect(0,0,0);
        return;
    }
    /*else
    {
        U2MonsterController(Controller).DoCharge();
    }*/
    //else
    //{
    //  Controller.Destination = Controller.Target.Location;
    //  Controller.GotoState('TacticalMove','DoMove');
    //}


}


simulated function AnimEnd(int Channel)
{

    local float  dist;
    local vector EnemyLocation;

    if ( bShotAnim )
    {
        bShotAnim = false;
        Controller.bPreparingMove = false;
    }
    if (Controller.Enemy != None)
    {

        EnemyLocation = Controller.Enemy.Location;
        dist = VSize(EnemyLocation - Location);

        if (dist <= (MeleeRange * 5))
            MovementAnims[0]='RunFrwd01';
        else
            MovementAnims[0]='RunFrwdMid01';
    }

    Super(XPawn).AnimEnd(Channel);
}

simulated event SetAnimAction(name NewAction)
{
//log("1");
    if (!bWaitForAnim)
    {
//log("2");
    AnimAction = NewAction;
    if ( AnimAction == 'Weapon_Switch' )
        {//log("3");
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(NewAction,, 0.0, 1);
        }
    else if ( AnimAction == 'Snarl' )
    {
        AnimBlendParams(1, 1.0, 0.0, 0.2, HeadBone);
                PlayAnim(NewAction,, 0.0, 1);
    }
        else if (((Physics == PHYS_None)|| ((Level.Game != None) && Level.Game.IsInState('MatchOver')))
                && (DrivenVehicle == None) )
        {//log("4");
            PlayAnim(AnimAction,,0.1);
            AnimBlendToAlpha(1,0.0,0.05);
        }
        else if ( (DrivenVehicle != None) || (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
        {//log("5");
            if ( CheckTauntValid(AnimAction) )
            {
                if (FireState == FS_None || FireState == FS_Ready)
                {
                    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                    PlayAnim(NewAction,, 0.1, 1);
                    FireState = FS_Ready;
                }
            }
            else if ( PlayAnim(AnimAction) )
            {
                if ( Physics != PHYS_None )
                    bWaitForAnim = true;
            }
            else
                AnimAction = '';
        }
        else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
        {//log("6");
            PlayAnim(AnimAction,,0.1);
            AnimBlendToAlpha(1,0.0,0.05);
        }
        else // running taunt
        {
//log("7");
            if (FireState == FS_None || FireState == FS_Ready)
            {
                AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);//1st was 1
                PlayAnim(NewAction,, 0.1, 1);
                FireState = FS_Ready;
            }
        }
    }
}

defaultproperties
{
     RamDamage=50
     StepSounds(0)=Sound'tk_U2Creatures.RammerA_Footstep.Footstep1'
     StepSounds(1)=Sound'tk_U2Creatures.RammerA_Footstep.Footstep2'
     StepSounds(2)=Sound'tk_U2Creatures.RammerA_Footstep.FootStep3'
     StepSounds(3)=Sound'tk_U2Creatures.RammerA_Footstep.Footstep4'
     StepShakeRadius=1024.000000
     StepShakeMagnitude=5.000000
     StepShakeDuration=0.400000
     bCanDodge=False
     HitSound(0)=Sound'tk_U2Creatures.RammerA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.RammerA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.RammerA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.RammerA_HitSoft.Hit4'
     DeathSound(0)=Sound'tk_U2Creatures.RammerA_DieSoft.DieSoft1'
     DeathSound(1)=Sound'tk_U2Creatures.RammerA_DieSoft.DieSoft2'
     DeathSound(2)=Sound'tk_U2Creatures.RammerA_HitSoft.Hit5'
     DeathSound(3)=Sound'tk_U2Creatures.RammerA_DieSoft.DieSoft1'
     ChallengeSound(0)=Sound'tk_U2Creatures.RammerA_Acquire.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.RammerA_Acquire.SeeEnemy2'
     ChallengeSound(2)=Sound'tk_U2Creatures.RammerA_Acquire.SeeEnemy3'
     ChallengeSound(3)=Sound'tk_U2Creatures.RammerA_Acquire.SeeEnemy4'
     FireSound=Sound'tk_U2Creatures.RammerA_Misc.MeleeAttack1'
     ScoringValue=5
     Species=Class'tk_U2Creatures.SPECIES_Rammer'
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     WallDodgeAnims(0)="RunFrwdMid01"
     WallDodgeAnims(1)="RunFrwdMid01"
     WallDodgeAnims(2)="RunFrwdMid01"
     WallDodgeAnims(3)="RunFrwdMid01"
     IdleHeavyAnim="IdleWaitBreath02"
     IdleRifleAnim="IdleWaitBreath03"
     FireHeavyRapidAnim="MeleeAttack01"
     FireHeavyBurstAnim="MeleeAttack01"
     FireRifleRapidAnim="MeleeAttack01"
     FireRifleBurstAnim="MeleeAttack01"
     FireRootBone="Neck1"
     bCanStrafe=False
     MeleeRange=100.000000
     GroundSpeed=560.000000
     AirSpeed=450.000000
     AccelRate=1000.000000
     WalkingPct=0.137500
     Health=300
     SoundDampening=0.750000
     MovementAnims(0)="RunFrwdMid01"
     MovementAnims(1)="WalkFrwd01"
     MovementAnims(2)="RunFrwd01"
     MovementAnims(3)="RunFrwd01"
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
     AirAnims(0)="RunFrwd01"
     AirAnims(1)="RunFrwd01"
     AirAnims(2)="RunFrwd01"
     AirAnims(3)="RunFrwd01"
     TakeoffAnims(0)="RunFrwdMid01"
     TakeoffAnims(1)="RunFrwdMid01"
     TakeoffAnims(2)="RunFrwdMid01"
     TakeoffAnims(3)="RunFrwdMid01"
     LandAnims(0)="WalkFrwd01"
     LandAnims(1)="WalkFrwd01"
     LandAnims(2)="WalkFrwd01"
     LandAnims(3)="WalkFrwd01"
     DoubleJumpAnims(0)="RunFrwdMid01"
     DoubleJumpAnims(1)="RunFrwdMid01"
     DoubleJumpAnims(2)="RunFrwdMid01"
     DoubleJumpAnims(3)="RunFrwdMid01"
     DodgeAnims(0)="RunFrwd01"
     DodgeAnims(1)="RunFrwd01"
     DodgeAnims(2)="RunFrwd01"
     DodgeAnims(3)="RunFrwd01"
     AirStillAnim="RunFrwd01"
     TakeoffStillAnim="RunFrwdMid01"
     CrouchTurnRightAnim="WalkFrwd01"
     CrouchTurnLeftAnim="WalkFrwd01"
     IdleCrouchAnim="IdleWaitBreath02"
     IdleSwimAnim="WalkFrwd01"
     IdleWeaponAnim="IdleWaitBreath01"
     IdleRestAnim="IdleWaitBreath01"
     IdleChatAnim="IdleWaitBreath03"
     Mesh=SkeletalMesh'tk_U2Creatures.Rammer'
     DrawScale=1.500000
     PrePivot=(Z=38.000000)
     Skins(0)=Texture'tk_U2Creatures.Rammer'
     TransientSoundVolume=2.000000
     CollisionRadius=75.000000
     CollisionHeight=65.000000
     Mass=250.000000
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
