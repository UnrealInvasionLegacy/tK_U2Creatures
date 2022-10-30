class MarineLight extends LightHuman config(U2CreaturesConfig);


var() config array<string> WeaponClassName;
var() float FireRateScale;
var() config bool bNoThrowWeapon;


function PostBeginPlay()
{
    local float SkinVar, FaceVar, MeshVar;
    local class<weapon> weaponclass;
    local int r;

    Super.PostBeginPlay();



    SkinVar = FRand();
    Facevar = FRand();
    MeshVar = FRand();

    if (MeshVar <= 0.25)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MarineLightHelm');

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';
        }
    }
    else if (MeshVar <= 0.5)
    {

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RazzRezzFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RhinehartFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_OreillyFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HawkFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RicardoFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_ButchFinal';
        }
    }
    else if (MeshVar <= 0.75)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MarineLightHelmPack');

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';

        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';
        }
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine._bpackaFinal';
    }
    else
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MarineLightPack');
        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RazzRezzFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RhinehartFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_OreillyFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HawkFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RicardoFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_ButchFinal';
        }
        Skins[6] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightPackBFinal';
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
    local float SkinVar, FaceVar, MeshVar;

    Super.PostBeginPlay();



    SkinVar = FRand();
    Facevar = FRand();
    MeshVar = FRand();

    if (MeshVar <= 0.25)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MarineLightHelm');

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';
        }
    }
    else if (MeshVar <= 0.5)
    {

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RazzRezzFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RhinehartFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_OreillyFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HawkFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RicardoFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_ButchFinal';
        }
    }
    else if (MeshVar <= 0.75)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MarineLightHelmPack');

        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';

        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';
        }
        Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine._bpackaFinal';
    }
    else
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MarineLightPack');
        if (SkinVar <= 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else if (SkinVar <= 0.40 && SkinVar > 0.20)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_BlueFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_BlueFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RazzRezzFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RhinehartFinal';
        }
        else if (SkinVar <= 0.60 && SkinVar > 0.40)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GoldFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GoldFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_OreillyFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HawkFinal';
        }
        else if (SkinVar <= 0.80 && SkinVar > 0.60)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_GreenFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_GreenFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_HurstFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_RedFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_RedFinal';

            if (FaceVar <= 0.5)
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_RicardoFinal';
            else
                Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_ButchFinal';
        }
        Skins[6] = Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightPackBFinal';
    }

}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('MarineLight') || (P.IsA('MarineMedium') || (P.IsA('MarineHeavy') || (P.IsA('Marshal') ) ) ) ) );
}



function TossWeapon(Vector TossVel)
{
    if(bNoThrowWeapon)
        return;
    super.TossWeapon(TossVel);

}

/*function RangedAttack(Actor A)
{


    local float Dist;

    if ( bShotAnim )
    {
        return;
    }

    Dist = VSize(A.Location - Location);


    if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming  )
    {
        if ( FRand() < 0.5 )
        {
            SetAnimAction(MeleeAnims[Rand(3)]);
            PlaySound(MeleeSounds[Rand(3)], SLOT_Interact);


        }
        //Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        //return;
    }

    else if ( Physics == PHYS_Swimming )
    {
        SetAnimAction(IdleSwimAnim);
    }

    else if (Dist > MeleeRange + CollisionRadius + A.CollisionRadius && Weapon != None && Controller.Enemy != None && Weapon.CanAttack(Controller.Enemy) && Controller.Enemy.Health > 0)
    {
        Weapon.BotFire(false,);
    }
    else if(Weapon != None && Weapon.IsFiring())
    {
        Weapon.StopFire(0);
        Weapon.StopFire(1);
    }
    bShotAnim = true;
}*/

/*     RootBone="Bip01"
     HeadBone="Bip01 Head"
     SpineBone1="Bip01 Spine"
     SpineBone2="bip01 Spine1"
FireRootBone="Bip01 Spine1"
*/

defaultproperties
{
     WeaponClassName(0)="XWeapons.RocketLauncher"
     FireRateScale=3.000000
     Species=Class'tk_U2Creatures.SPECIES_MarineLight'
     Mesh=SkeletalMesh'tk_U2Creatures.MarineLight'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal'
     Skins(3)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightFaces_KovacsFinal'
     Skins(4)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightHead_DefaultFinal'
     Skins(5)=Shader'tk_U2Creatures.CharacterMaterialsMarine.MarineLightBody_DefaultFinal'
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
