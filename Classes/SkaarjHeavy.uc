class SkaarjHeavy extends SkaarjLight;

var xEmitter SpinEffect;


function PostBeginPlay()
{

    Super(U2Creatures).PostBeginPlay();
    bMeleeFighter = true;

    MonsterController(Controller).CombatStyle = 1.0;

}


simulated function PostNetBeginPlay()
{
    local float SkinVar;

    Super(U2Creatures).PostNetBeginPlay();

    SkinVar = FRand();
    //log("PostNetBegin: SkinVar: "$SkinVar);
    if (SkinVar <= 0.20)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyLegs_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_DefaultFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_DefaultFinal';
    }
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyLegs_BlueFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_BlueFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_BlueFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_BlueFinal';
    }
    else if (SkinVar <= 0.60 && SkinVar > 0.40)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyLegs_GoldFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_GoldFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_GoldFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_GoldFinal';
    }

    else if (SkinVar <= 0.80 && SkinVar > 0.60)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyLegs_GreenFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_GreenFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_GreenFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_GreenFinal';
    }

    else
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyLegs_RedFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_RedFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_RedFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_RedFinal';
    }
}

function TakeDamage( int Damage, Pawn Instigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
    local bool bFilterDamage;

    if( Health > 0 &&
        DefensiveModeDamage( Damage, Instigator, HitLocation, Momentum, DamageType ) &&
        Instigator != None  )
    {
        //DMTNS( "eventTakeDamage: " $ bDefensiveMode );
        LastDefensiveHitTime = Level.TimeSeconds;
        bFilterDamage = true;
        HandleDeflectionHeavy( HitLocation );

    }

    if( !bFilterDamage )
    {
        Super(U2Creatures).TakeDamage( Damage, Instigator, HitLocation, Momentum, DamageType );
    }
}

function HandleDeflectionHeavy( vector HitLocation )
{
    if( DefensiveParticles/*Effect !=*/ == None )
    {
        //DefensiveParticles = class'ParticleGenerator'.static.CreateNew( Self, DefensiveEffect, EffectLocation );
        //DefensiveParticles.Trigger( Self, Instigator );
        //DefensiveParticles.ParticleLifeSpan = DefensiveParticles.GetMaxLifeSpan() + DefensiveParticles.TimerDuration;
        DefensiveParticles = spawn(DefensiveEffect,self,,HitLocation,);
        //AttachToBone(DefensiveParticles, GetGloveName(bLeft));
        //log("DefensiveParticles");
    }

    // play deflection sound
    PlaySound( Sound(DynamicLoadObject( DefensiveSounds[ Rand( DefensiveSounds.Length ) ], class'Sound' )) );

    // sometimes play ricochet sound
    if( FRand() < 0.50 )
        PlaySound( Sound(DynamicLoadObject( DefensiveRicochetSounds[ Rand( DefensiveRicochetSounds.Length ) ], class'Sound' )) );
}

function RangedAttack(Actor A)
{
    local float Dist;
    local name Anim;
    local float frame,rate;


    if ( bShotAnim )
        return;

    Dist = VSize(A.Location - Location);
    GetAnimParams(0,Anim,frame,rate);

    bShotAnim = true;
    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if ( FRand() < 0.5 )
        {
            SetAnimAction(ClawAnims[Rand(9)]);
            //PlayAnim(ClawAnims[Rand(8)]);
            GetAnimParams(0,Anim,frame,rate);

            PlaySound(MeleeSounds[Rand(4)], SLOT_Interact);


        }
        else
        {
            SetAnimAction(WalkSlashAnims[Rand(2)]);
        }
        //Controller.bPreparingMove = true;
        //Acceleration = vect(0,0,0);
        //return;
    }
    else if ( Dist > MeleeRange + CollisionRadius + A.CollisionRadius /*&& FRand() >= 0.45*/ )//( Velocity == vect(0,0,0) )
    {
        if (FRand() >= 0.9)
        {
            SetAnimAction('StillOneShot_SM');
            //Controller.bPreparingMove = true;
            Acceleration = vect(0,0,0);
            return;
        }
        else
            SetAnimAction(FireAnims[Rand(8)]);
        //Controller.bPreparingMove = true;
        //Acceleration = vect(0,0,0);
        //return;
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        Dist = VSize(A.Location - Location);
        if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius )
        {
            SetAnimAction(WalkSlashAnims[Rand(2)]);
        }
    }
    //bShotAnim = true;
    //Controller.bPreparingMove = true;

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
    else if ( AnimAction == 'StillOneShot_SM' )
    {
        AnimBlendParams(1, 1.0, 0.0, 0.2, 'Bip 01 Spine');
                PlayAnim(NewAction,, 0.0, 1);
    }
    else if ( AnimAction == 'Blink' )
    {
        AnimBlendParams(1, 1.0, 0.0, 0.2, 'EyesLower');
                PlayAnim(NewAction,, 0.0, 1);
        AnimBlendParams(1, 1.0, 0.0, 0.2, 'EyesUpper');
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

function SpinDamageTarget()
{
    if (MeleeDamageTarget(SpinDamage, (SpinDamage * 500 * Normal(Controller.Target.Location - Location))) )
        PlaySound(slice, SLOT_Interact);
}



//ControllerClass=Class'tk_U2Creatures.ExecutionerController'

defaultproperties
{
     LungeDamage=40
     SpinDamage=75
     ClawDamage=50
     StabDamage=50
     KickDamage=20
     HeadButtDamage=20
     DeathAnims(0)="DeathFoldF01"
     DeathAnims(1)="DeathMidHitB01"
     DeathAnims(7)="DeathFoldF01"
     FireAnims(6)="StillMultiShot05_SM"
     FireAnims(7)="StillMultiShot10_SM"
     MeleeSounds(0)=Sound'tk_U2Creatures.SkaarjHeavyA_Misc.MeleeAttack1'
     MeleeSounds(1)=Sound'tk_U2Creatures.SkaarjHeavyA_Misc.MeleeAttack2'
     MeleeSounds(2)=Sound'tk_U2Creatures.SkaarjHeavyA_Misc.MeleeAttack3'
     MeleeSounds(3)=Sound'tk_U2Creatures.SkaarjHeavyA_Misc.MeleeAttack4'
     StepSounds(0)=Sound'tk_U2Creatures.PawnsA.HvyArmorStep1'
     StepSounds(1)=Sound'tk_U2Creatures.PawnsA.HvyArmorStep2'
     StepSounds(2)=Sound'tk_U2Creatures.PawnsA.HvyArmorStep3'
     StepSounds(3)=Sound'tk_U2Creatures.PawnsA.HvyArmorStep4'
     TauntSounds(0)=Sound'tk_U2Creatures.SkaarjHeavyA_KillsTaunts.Taunt1'
     TauntSounds(1)=Sound'tk_U2Creatures.SkaarjHeavyA_KillsTaunts.Taunt2'
     TauntSounds(2)=Sound'tk_U2Creatures.SkaarjHeavyA_KillsTaunts.Taunt3'
     TauntSounds(3)=Sound'tk_U2Creatures.SkaarjHeavyA_KillsTaunts.Taunt4'
     TauntSounds(4)=Sound'tk_U2Creatures.SkaarjHeavyA_KillsTaunts.Taunt5'
     bCanDefend=False
     AmbientSoundStrings(0)="tk_U2Creatures.SkaarjHeavyA_Misc.Ambient1"
     AmbientSoundStrings(1)="tk_U2Creatures.SkaarjHeavyA_Misc.Ambient2"
     AmbientSoundStrings(2)="tk_U2Creatures.SkaarjHeavyA_Misc.Ambient3"
     AmbientSoundStrings(3)="tk_U2Creatures.SkaarjHeavyA_Misc.Ambient4"
     StepShakeRadius=1024.000000
     StepShakeMagnitude=7.000000
     StepShakeDuration=0.400000
     LeapOdds=0.000000
     bCanDodge=False
     bBoss=True
     DodgeSkillAdjust=0.000000
     HitSound(0)=Sound'tk_U2Creatures.SkaarjHeavyA_HitSoft.Hit1'
     HitSound(1)=Sound'tk_U2Creatures.SkaarjHeavyA_HitSoft.Hit2'
     HitSound(2)=Sound'tk_U2Creatures.SkaarjHeavyA_HitSoft.Hit3'
     HitSound(3)=Sound'tk_U2Creatures.SkaarjHeavyA_HitSoft.Hit4'
     DeathSound(0)=Sound'tk_U2Creatures.SkaarjHeavyA_DieHard.DieHard1'
     DeathSound(1)=Sound'tk_U2Creatures.SkaarjHeavyA_DieHard.DieHard2'
     DeathSound(2)=Sound'tk_U2Creatures.SkaarjHeavyA_DieHard.DieHard3'
     DeathSound(3)=Sound'tk_U2Creatures.SkaarjHeavyA_DieSoft.DieSoft1'
     ChallengeSound(0)=Sound'tk_U2Creatures.SkaarjHeavyA_Acquire.SeeEnemy1'
     ChallengeSound(1)=Sound'tk_U2Creatures.SkaarjHeavyA_Acquire.SeeEnemy2'
     ChallengeSound(2)=Sound'tk_U2Creatures.SkaarjHeavyA_Acquire.SeeEnemy3'
     ChallengeSound(3)=Sound'tk_U2Creatures.SkaarjHeavyA_Misc.IdleChat3'
     FireSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_HeavyFire'
     AmmunitionClass=Class'tk_U2Creatures.SkaarjHeavyAmmo'
     ScoringValue=10
     Species=Class'tk_U2Creatures.SPECIES_SkaarjHeavy'
     GibGroupClass=Class'tk_U2Creatures.SkaarjGibGroupHeavy'
     bCanJump=False
     GroundSpeed=200.000000
     WalkingPct=1.000000
     Health=600
     SoundDampening=0.500000
     MovementAnims(0)="WalkFrwd02_SM"
     MovementAnims(1)="RunBackHalf_Fr01_SM"
     MovementAnims(2)="WalkFrwd02_SM"
     MovementAnims(3)="WalkFrwd02_SM"
     DodgeAnims(0)="DodgeFrwd_Fr01_SM"
     DodgeAnims(1)="DodgeBack_Fr01_SM"
     DodgeAnims(2)="DodgeLeft_Fr01_SM"
     DodgeAnims(3)="DodgeRight_Fr01_SM"
     AmbientSound=Sound'tk_U2Creatures.SkaarjHeavyA_Misc.Ambient1'
     Mesh=SkeletalMesh'tk_U2Creatures.SkaarjHeavy'
     DrawScale=0.750000
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyLegs_DefaultFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_DefaultFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_DefaultFinal'
     Skins(3)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjHeavyChest_DefaultFinal'
     CollisionRadius=34.000000
     CollisionHeight=70.000000
     Mass=1000.000000
     RotationRate=(Pitch=2000,Yaw=10000,Roll=0)
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
