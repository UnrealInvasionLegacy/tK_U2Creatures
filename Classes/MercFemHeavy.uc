class MercFemHeavy extends HeavyHuman config(U2CreaturesConfig);


var() config array<string> WeaponClassName;
var() float FireRateScale;
var() config bool bNoThrowWeapon;

function PlayChallengeSound()
{
    PlaySound(AcquireSounds[Rand(7)],SLOT_Talk);
}

function PlayVictory()
{
    SetPhysics(PHYS_Falling);
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlayAnim(VictoryAnims[Rand(14)]);
    PlaySound(TauntSounds[Rand(8)],SLOT_Talk);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

function TossWeapon(Vector TossVel)
{
    if(bNoThrowWeapon)
        return;
    super.TossWeapon(TossVel);

}

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
    local float SkinVar;

    Super.PostNetBeginPlay();


    SkinVar = FRand();


    if (SkinVar <= 0.20)
    {

        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoRed_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyLimbsRed_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoRed_DefaultOpacity';
    }
    else if (SkinVar <= 0.40 && SkinVar > 0.20)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoBlue_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyLimbsBlue_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoBlue_DefaultOpacity';
    }
    else if (SkinVar <= 0.60 && SkinVar > 0.40)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoGreen_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyLimbsGreen_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoGreen_DefaultOpacity';
    }
    else if (SkinVar <= 0.80 && SkinVar > 0.60)
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoGold_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyLimbsGold_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoGold_DefaultOpacity';
    }
    else
    {
        Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorso_DefaultFinal';
        Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyLimbs_DefaultFinal';
        Skins[2] = Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorso_DefaultOpacity';
    }
}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('MercFemLight') || (P.IsA('MercFemMedium') || (P.IsA('MercFemHeavy')  ) ) ) );
}

defaultproperties
{
     WeaponClassName(0)="XWeapons.RocketLauncher"
     FireRateScale=3.000000
     TauntSounds(0)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011a'
     TauntSounds(1)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011b'
     TauntSounds(2)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011c'
     TauntSounds(3)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011d'
     TauntSounds(4)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011e'
     TauntSounds(5)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011f'
     TauntSounds(6)=Sound'tk_U2Creatures.Female23Voice_KillsTaunts.Pain_01_011g'
     TauntSounds(7)=Sound'tk_U2Creatures.Female23Voice_EndSkirmish.Heat_01_005'
     AcquireSounds(0)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_006'
     AcquireSounds(1)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_006a'
     AcquireSounds(2)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_008'
     AcquireSounds(3)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_009'
     AcquireSounds(4)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_023'
     AcquireSounds(5)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_023a'
     AcquireSounds(6)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_026'
     HitSound(0)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003a'
     HitSound(1)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003k'
     HitSound(2)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_003n'
     HitSound(3)=Sound'tk_U2Creatures.Female23Voice_HitHard.Pain_01_006i'
     DeathSound(0)=Sound'tk_U2Creatures.Female23Voice_DieSoft.Pain_01_005a'
     DeathSound(1)=Sound'tk_U2Creatures.Female23Voice_DieSoft.Pain_01_005c'
     DeathSound(2)=Sound'tk_U2Creatures.Female23Voice_DieHard.Pain_01_008l'
     DeathSound(3)=Sound'tk_U2Creatures.Female23Voice_DieHard.Pain_01_008h'
     ChallengeSound(0)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_006'
     ChallengeSound(1)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_009'
     ChallengeSound(2)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_023'
     ChallengeSound(3)=Sound'tk_U2Creatures.Female23Voice_Acquire.Orders_01_026'
     Species=Class'tk_U2Creatures.SPECIES_MercFemHeavy'
     bIsFemale=True
     Mesh=SkeletalMesh'tk_U2Creatures.MercFemHeavy'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoRed_DefaultFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyLimbsRed_DefaultFinal'
     Skins(2)=Shader'tk_U2Creatures.CharacterMaterialsMercFem.MercFemHeavyTorsoRed_DefaultOpacity'
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
