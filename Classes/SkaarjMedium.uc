class SkaarjMedium extends SkaarjLight;


function PostBeginPlay()
{
    Super.PostBeginPlay();
    bMeleeFighter = true;


    MonsterController(Controller).CombatStyle = 0.90;

}

simulated function PostNetBeginPlay()
{
    local float SkinVar;

    Super(U2Creatures).PostNetBeginPlay();
    bMeleeFighter = true;

    SkinVar = FRand();

    if (SkinVar <= 0.20)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumLower_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_DefaultFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_DefaultFinal';
    }
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumLower_BlueFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_BlueFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_BlueFinal';
    }
    else if (SkinVar <= 0.60 && SkinVar > 0.40)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumLower_GoldFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_GoldFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_GoldFinal';
    }
    else if (SkinVar <= 0.80 && SkinVar > 0.60)
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumLower_GreenFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_GreenFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_GreenFinal';
    }
    else
    {
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumLower_RedFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_RedFinal';
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_RedFinal';
    }

    MonsterController(Controller).CombatStyle = 0.90;

}

function RangedAttack(Actor A)
{
    local float Dist;
    local name Anim;
    local float frame,rate;

    Dist = VSize(A.Location - Location);

    //log("want to do ranged attack");
    if ( bShotAnim || IsLeaping() || Controller.Enemy == None )
        return;

    /*if (bDefensiveMode)
    {
        U2SkaarjController(Controller).DoCharge();
        return;
    }*/

    if (Controller != None && Controller.Enemy != None && LeapOdds > 0 && !bDoingLeapCheck) //Tick handles leaping
    {
        bDoingLeapCheck = true;
        Enable('Tick');
    }

    GetAnimParams(0,Anim,frame,rate);

    if (Anim == 'FlipFrwdSlash_Fr01_SM' || Anim == 'FlipFrwdSlash_Fr02_SM' || Anim == 'FlipFrwdSlash_Fr03_SM')
        return;

    if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming)
    {
        if (bDefensiveMode) DefensiveModeEnd(true);
        //log("Play melee?");
        SetAnimAction(ClawAnims[Rand(10)]);
        PlaySound(MeleeSounds[Rand(4)], SLOT_Talk);
        bShotAnim = true;
        return;
    }
    else if ( (VSize(Velocity) <= 100) && FRand() > 0.40 && (Dist > MeleeRange + CollisionRadius + A.CollisionRadius) && IsFacingTarget( /*Instigator*/Controller.Enemy, CosMinDefensiveModeAngle ))
    {
        SetAnimAction(FireAnims[Rand(8)]);
        bShotAnim = true;
        return;
    }
    else if (!IsFacingTarget( Controller.Enemy, CosMinDefensiveModeAngle ))
    {
        bShotAnim = false;
        MonsterController(Controller).DoCharge();
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        bShotAnim = true;
        if (Anim == MovementAnims[2])
            SetAnimAction('RunLeft_Fr01_SM');
        else if (Anim == MovementAnims[3])
            SetAnimAction('RunRight_Fr01_SM');
        else if (Anim == MovementAnims[0] && Frand() >= 0.25)//0.55
            SetAnimAction('RunFrwd05_SM');
        else
        {
            if (Anim == MovementAnims[0] && Frand() < 0.25)//0.55
                SetAnimAction('RunFrwd03_SM');
            bShotAnim = false;
            MonsterController(Controller).DoCharge();
            return;
        }
        //bShotAnim = true;
        return;
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

    AnimAction = '';

    if ( bVictoryNext && (Physics != PHYS_Falling) )
    {
        bVictoryNext = false;
        PlayVictory();
    }
    if ( bShotAnim )
    {
        bShotAnim = false;
        Controller.bPreparingMove = false;
    }

    AirAnims[0] = Default.AirAnims[0];
    Super(XPawn).AnimEnd(Channel);
}

defaultproperties
{
     LungeDamage=35
     SpinDamage=25
     ClawDamage=20
     StabDamage=30
     HeadButtDamage=20
     FireAnims(6)="StillMultiShot05_SM"
     FireAnims(7)="StillMultiShot10_SM"
     LandShakeRadius=768.000000
     LandShakeMagnitude=10.000000
     LandShakeDuration=0.600000
     DodgeSkillAdjust=2.000000
     FireSound=Sound'tk_U2Creatures.WeaponsA_skaarjglove.SG_MediumFire'
     AmmunitionClass=Class'tk_U2Creatures.SkaarjMediumAmmo'
     Species=Class'tk_U2Creatures.SPECIES_SkaarjMedium'
     SoundDampening=0.480000
     Mesh=SkeletalMesh'tk_U2Creatures.SkaarjMedium'
     Skins(0)=Texture'tk_U2Creatures.skaarjglove'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumLower_DefaultFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_DefaultFinal'
     Skins(3)=Shader'tk_U2Creatures.CharacterMaterialsSkaarj.SkaarjMediumUpper_DefaultFinal'
     Mass=300.000000
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
