class MarineHeavy extends HeavyHuman config(U2CreaturesConfig);


var() config array<string> WeaponClassName;
var() float FireRateScale;
var() config bool bNoThrowWeapon;

function TossWeapon(Vector TossVel)
{
    if(bNoThrowWeapon)
        return;
    super.TossWeapon(TossVel);

}

function PostBeginPlay()
{
    local float SkinVar;
    local class<weapon> weaponclass;
    local int r;

    Super.PostBeginPlay();


    SkinVar = FRand();


    if (SkinVar <= 0.20)
    {

        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_RedFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_RedFinal';
    }
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_BlueFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_BlueFinal';
    }
    else if (SkinVar <= 0.60 && SkinVar > 0.40)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_GreenFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_GreenFinal';
    }
    else if (SkinVar <= 0.80 && SkinVar > 0.60)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_GoldFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_GoldFinal';
    }
    else
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_DefaultFinal';
    }


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
    local float SkinVar;

    Super.PostNetBeginPlay();


    SkinVar = FRand();


    if (SkinVar <= 0.20)
    {

        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_RedFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_RedFinal';
    }
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_BlueFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_BlueFinal';
    }
    else if (SkinVar <= 0.60 && SkinVar > 0.40)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_GreenFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_GreenFinal';
    }
    else if (SkinVar <= 0.80 && SkinVar > 0.60)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_GoldFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_GoldFinal';
    }
    else
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_DefaultFinal';
    }

}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('MarineLight') || (P.IsA('MarineMedium') || (P.IsA('MarineHeavy') || (P.IsA('Marshal') ) ) ) ) );
}

defaultproperties
{
     WeaponClassName(0)="XWeapons.RocketLauncher"
     FireRateScale=3.000000
     Species=Class'tk_U2Creatures.SPECIES_MarineHeavy'
     Mesh=SkeletalMesh'tk_U2Creatures.MarineHeavy'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyBody_DefaultFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineHeavyLimbs_DefaultFinal'
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
