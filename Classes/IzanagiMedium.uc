class IzanagiMedium extends LightHuman config(U2CreaturesConfig);


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
	
	if (MeshVar <= 0.50)
	{
		LinkMesh(SkeletalMesh'tk_U2Creatures.MercJapMedium');


		if (SkinVar <= 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_RedFinal';
		}	
		else if (SkinVar <= 0.40 && SkinVar > 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_BlueFinal';
		}
		else if (SkinVar <= 0.60 && SkinVar > 0.40)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GreenFinal';
		}	
		else if (SkinVar <= 0.80 && SkinVar > 0.60)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GoldFinal';
		}
		else 
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_DefaultFinal';
		}

		if (FaceVar <= 0.5)
			Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_CaucasianBeardFinal';
		else
			Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_CaucasianFinal';

	}	
	else
	{
		
	
		if (SkinVar <= 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_RedFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Red';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Red';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}	
		else if (SkinVar <= 0.40 && SkinVar > 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_BlueFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Blue';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Blue';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}
		else if (SkinVar <= 0.60 && SkinVar > 0.40)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GreenFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Green';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Green';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}	
		else if (SkinVar <= 0.80 && SkinVar > 0.60)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GoldFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Gold';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Gold';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}
		else 
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_DefaultFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Default';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Default';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}

		if (FaceVar <= 0.5)
			Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_BlackFinal';
		else
			Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_ScarFinal';

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
	
	if (MeshVar <= 0.50)
	{
		LinkMesh(SkeletalMesh'tk_U2Creatures.MercJapMedium');


		if (SkinVar <= 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_RedFinal';
		}	
		else if (SkinVar <= 0.40 && SkinVar > 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_BlueFinal';
		}
		else if (SkinVar <= 0.60 && SkinVar > 0.40)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GreenFinal';
		}	
		else if (SkinVar <= 0.80 && SkinVar > 0.60)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GoldFinal';
		}
		else 
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_DefaultFinal';
		}

		if (FaceVar <= 0.5)
			Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_CaucasianBeardFinal';
		else
			Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_CaucasianFinal';

	}	
	else
	{
		
	
		if (SkinVar <= 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_RedFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Red';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Red';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}	
		else if (SkinVar <= 0.40 && SkinVar > 0.20)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_BlueFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Blue';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Blue';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}
		else if (SkinVar <= 0.60 && SkinVar > 0.40)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GreenFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Green';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Green';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}	
		else if (SkinVar <= 0.80 && SkinVar > 0.60)
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_GoldFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Gold';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Gold';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}
		else 
		{
			Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_DefaultFinal';
			Skins[1] = Texture'tk_U2Creatures.MercJapMediumHelmA_Default';
			Skins[2] = Texture'tk_U2Creatures.MercJapMediumHelmB_Default';
			Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueShader';
		}

		if (FaceVar <= 0.5)
			Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_BlackFinal';
		else
			Skins[4] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_ScarFinal';

	}
}

function bool SameSpeciesAs(Pawn P)
{
	return ( (Monster(P) != None) && (P.IsA('IzanagiLight') || (P.IsA('IzanagiMedium') || (P.IsA('IzanagiHeavy') ) ) ) );
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
     Species=Class'tk_U2Creatures.SPECIES_IzaMedium'
     Mesh=SkeletalMesh'tk_U2Creatures.MercJapMediumHelm'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumBody_RedFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHelmA_RedFinal'
     Skins(2)=Texture'tk_U2Creatures.MercJapMediumHelmB_Red'
     Skins(3)=FinalBlend'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumVisorBlueFinal'
     Skins(4)=Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_ScarFinal'
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
     KParams=KarmaParamsSkel'tk_U2Creatures.IzanagiMedium.PawnKParams'

}
