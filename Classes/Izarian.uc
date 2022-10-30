class Izarian extends IzarianBase config(U2CreaturesConfig);

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
    local float MeshVar;

    Super.PostNetBeginPlay();


    MeshVar = FRand();

    if (MeshVar < 0.45)
    {
        LinkMesh(SkeletalMesh'tk_U2Creatures.IzarianBald');
        Skins[0] = Shader'tk_U2Creatures.Izarian.IzarianHairFX';
        Skins[1] = Shader'tk_U2Creatures.Izarian.IzarianBodyFX';
        Skins[2] = Shader'tk_U2Creatures.Izarian.IzarianHairFX';
    }

}

function bool SameSpeciesAs(Pawn P)
{
    return ( (Monster(P) != None) && (P.IsA('Izarian') || (P.IsA('IzarianArmored') ) ) );
}



function RangedAttack(Actor A)
{

    local name Anim;
    local float frame,rate;
    local float Dist;

    if ( bShotAnim )
    {
        return;
    }

    Dist = VSize(A.Location - Location);
    GetAnimParams(0,Anim,frame,rate);

    if ( Anim == 'StillImpale_Fr01_LG' )
        return;

if ( Dist <= MeleeRange + CollisionRadius + A.CollisionRadius && Physics != PHYS_Swimming  )
    {
        bShotAnim = true;
        SetAnimAction(MeleeAnims[Rand(3)]);
        PlaySound(MeleeSounds[Rand(3)], SLOT_Interact);


        //Controller.bPreparingMove = true;
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
    else if(FRand() <= 0.25 && Weapon != None && Weapon.IsFiring())
    {
        Weapon.StopFire(0);
        Weapon.StopFire(1);
    }

    MonsterController(Controller).DoCharge();
}

defaultproperties
{
     WeaponClassName(0)="XWeapons.SniperRifle"
     FireRateScale=3.000000
     Species=Class'tk_U2Creatures.SPECIES_Izarian'
     Mesh=SkeletalMesh'tk_U2Creatures.Izarian'
     Skins(0)=Shader'tk_U2Creatures.Izarian.IzarianBodyFX'
     Skins(1)=Shader'tk_U2Creatures.Izarian.IzarianBodyFX'
     Skins(2)=Shader'tk_U2Creatures.Izarian.IzarianHairFX'
     Skins(3)=Shader'tk_U2Creatures.Izarian.IzarianHairFX'
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
