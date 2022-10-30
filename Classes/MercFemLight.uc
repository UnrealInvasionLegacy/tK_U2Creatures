class MercFemLight extends LightHumanAngel config(U2CreaturesConfig);


var() config array<string> WeaponClassName;
var() float FireRateScale;
var() config bool bNoThrowWeapon;


function PostBeginPlay()
{
    local class<weapon> weaponclass;
    local int r;

    Super.PostBeginPlay();

    r=Rand(WeaponClassName.Length);

    weaponclass=class<Weapon>(DynamicLoadObject(WeaponClassName[r],class'class'));

    if(weaponclass != None)
    {
        Weapon=spawn(weaponclass,self);
    }
    if(Weapon == None)
    {
        return;
    }
    Weapon.ExchangeFireModes = 1;
    Weapon.GiveTo(self);
    Weapon.AttachToPawn(self);

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = Weapon.AmmoClass[0];
        SavedFireProperties.ProjectileClass = Weapon.AmmoClass[0].default.ProjectileClass;
        SavedFireProperties.WarnTargetPct = Weapon.AmmoClass[0].default.WarnTargetPct;
        SavedFireProperties.MaxRange = Weapon.AmmoClass[0].default.MaxRange;
        SavedFireProperties.bTossed = Weapon.AmmoClass[0].default.bTossed;
        SavedFireProperties.bTrySplash = Weapon.AmmoClass[0].default.bTrySplash;
        SavedFireProperties.bLeadTarget = Weapon.AmmoClass[0].default.bLeadTarget;
        SavedFireProperties.bInstantHit = Weapon.AmmoClass[0].default.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    Weapon.ClientState = WS_ReadyToFire;
    Weapon.GetFireMode(0).FireRate *= FireRateScale;
    Weapon.GetFireMode(1).FireRate *= FireRateScale;
    Weapon.GetFireMode(0).AmmoPerFire = 0;
    Weapon.GetFireMode(1).AmmoPerFire = 0;

    if(Weapon.bMeleeWeapon == true)
    {
        bMeleeFighter = true;
    }
    if(Weapon.bSniping == true)
    {
        bMeleeFighter = false;
    }


}

simulated function PostNetBeginPlay()
{
    local float SkinVar, FaceVar, MeshVar;

    Super.PostNetBeginPlay();

    SkinVar = FRand();
    Facevar = FRand();
    MeshVar = FRand();

    if (MeshVar < 0.25)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemLightBald');

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal';

        }

        if (FaceVar <= 0.5)
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
        else
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
    }
    else if (Meshvar < 0.5)
    {

        LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemLightHair');

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal';

        }

        if (FaceVar <= 0.5)
        {
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
        }
        else
        {
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
        }
    }
    else if (Meshvar < 0.75)
    {
        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedOpacity';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueOpacity';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenOpacity';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldOpacity';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultOpacity';

        }

        if (FaceVar <= 0.5)
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';

        else
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';

    }
    else
    {
        if (MeshVar >= 0.916)
            LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemLightHelmPackLight');
        else if (MeshVar >= 0.833)
            LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemLightHelmPackMedium');
        else
            LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemLightHelmPackHeavy');
        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_RedOpacity';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_BlueOpacity';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GreenOpacity';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_GoldOpacity';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultOpacity';

        }
        Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBackpacksFinal';

        if (FaceVar <= 0.5)
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';

        else
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';

    }
}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('MercFemLight') || (P.IsA('MercFemMedium') || (P.IsA('MercFemHeavy')  ) ) ) );
}



function TossWeapon(Vector TossVel)
{
    if(bNoThrowWeapon)
        return;
    super.TossWeapon(TossVel);

}

defaultproperties
{
     WeaponClassName(0)="XWeapons.RocketLauncher"
     FireRateScale=3.000000
     Species=Class'tk_U2Creatures.SPECIES_MercFemLight'
     Health=75
     Mesh=SkeletalMesh'tk_U2Creatures.MercFemLightHelm'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightBody_DefaultFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal'
     Skins(3)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultFinal'
     Skins(4)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightLimbs_DefaultOpacity'
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
