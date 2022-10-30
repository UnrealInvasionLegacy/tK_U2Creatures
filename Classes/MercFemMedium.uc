class MercFemMedium extends LightHumanAngel config(U2CreaturesConfig);


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

    if (MeshVar <= 0.5)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemMediumBald');

        if (SkinVar <= 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
        }
        else if (SkinVar <= 0.50 && SkinVar > 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
        }

        else if (SkinVar <= 0.75 && SkinVar > 0.50)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
        }

        if (FaceVar <= 0.5)
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
        else
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
    }

    else
    {
        if (SkinVar <= 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';

        }
        else if (SkinVar <= 0.50 && SkinVar > 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';

        }

        else if (SkinVar <= 0.75 && SkinVar > 0.50)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';


        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';


        }

        if (FaceVar <= 0.5)
        {
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
            Skins[6] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
            Skins[7] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
        }
        else
        {
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
            Skins[6] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
            Skins[7] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
        }
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

    Super.PostNetBeginPlay();



    SkinVar = FRand();
    Facevar = FRand();
    MeshVar = FRand();

    if (MeshVar <= 0.5)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.MercFemMediumBald');

        if (SkinVar <= 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
        }
        else if (SkinVar <= 0.50 && SkinVar > 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
        }

        else if (SkinVar <= 0.75 && SkinVar > 0.50)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
        }

        if (FaceVar <= 0.5)
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
        else
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
    }

    else
    {
        if (SkinVar <= 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_RedFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_RedFinal';

        }
        else if (SkinVar <= 0.50 && SkinVar > 0.25)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_BlueFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal';

        }

        else if (SkinVar <= 0.75 && SkinVar > 0.50)
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_GoldFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_GoldFinal';


        }
        else
        {
            Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_DefaultFinal';
            Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';
            Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_DefaultFinal';


        }

        if (FaceVar <= 0.5)
        {
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
            Skins[6] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
            Skins[7] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal';
        }
        else
        {
            Skins[5] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
            Skins[6] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
            Skins[7] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsBFinal';
        }
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

function RangedAttack(Actor A)
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
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        return;
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
}

defaultproperties
{
     WeaponClassName(0)="XWeapons.RocketLauncher"
     FireRateScale=3.000000
     Species=Class'tk_U2Creatures.SPECIES_MercFemMedium'
     Mesh=SkeletalMesh'tk_U2Creatures.MercFemMediumHair'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumBody_BlueFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal'
     Skins(3)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemMediumLimbs_BlueFinal'
     Skins(4)=Shader'tk_U2Creatures.MercFemLightVisor1Shader'
     Skins(5)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal'
     Skins(6)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal'
     Skins(7)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemLightHeadsAFinal'
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
