class IzanagiHeavy extends HeavyHuman config(U2CreaturesConfig);


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
	local float SkinVar, FaceVar;

	Super.PostNetBeginPlay();

	SkinVar = FRand();
	Facevar = FRand();

	if (SkinVar <= 0.20)
	{
		Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy1_REDFinal';
		Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy0_REDFinal';
	}	
	else if (SkinVar <= 0.40 && SkinVar > 0.20)
	{
		Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy1_BLUEFinal';
		Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy0_BLUEFinal';
	}
	else if (SkinVar <= 0.60 && SkinVar > 0.40)
	{
		Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy1_GREENFinal';
		Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy0_GREENFinal';
	}	
	else if (SkinVar <= 0.80 && SkinVar > 0.60)
	{
		Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy1_GOLDFinal';
		Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy0_GOLDFinal';
	}
	else 
	{
		Skins[0] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy1Final';
		Skins[1] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy0Final';
	}
	

	if (FaceVar <= 0.33)
		Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_BlackFinal';
	else if (FaceVar <= 0.66)
		Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_PhillipinoFinal';
	else
		Skins[3] = Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapMediumHead_ScarFinal';

}

function bool SameSpeciesAs(Pawn P)
{
	return ( (Monster(P) != None) && (P.IsA('IzanagiLight') || (P.IsA('IzanagiMedium') || (P.IsA('IzanagiHeavy') ) ) ) );
}

/*

	MeleeAnims(0)="MeleeA"
	MeleeAnims(1)="MeleeB"
	MeleeAnims(2)="MeleeC"
	MeleeAnims(3)="MeleeD"
	DeathAnims(0)="DeathBackFlipF01"
        DeathAnims(1)="DeathBlownUpB01"
	DeathAnims(2)="DeathDieSitting01"
	DeathAnims(3)="DeathFoldF01"
	DeathAnims(4)="DeathHeadShotF01"
	DeathAnims(5)="DeathMidHitB01"
	DeathAnims(6)="DeathRiddledF01"
	DeathAnims(7)="DeathSpinF01"
	DeathAnims(8)="DeathStruggleB01"
	VictoryAnims(0)="Taunt01_LG"
	VictoryAnims(1)="Typing01"
	VictoryAnims(2)="Taunt03_LG"
	VictoryAnims(3)="ButtonPress01_LG"
	VictoryAnims(4)="Thrust01_LG"
	VictoryAnims(5)="Victory01_LG"
	VictoryAnims(6)="Victory02_LG"
	VictoryAnims(7)="Victory03_LG"
	VictoryAnims(8)="Wave01_LG"
	VictoryAnims(9)="DialogueTalk01_LG"
	VictoryAnims(10)="LoadGun01_LG"
	VictoryAnims(11)="Victory01_LG"
	VictoryAnims(12)="Taunt01_LG"
	VictoryAnims(13)="Thrust01_LG"
	bMeleeFighter=False
        bTryToWalk=True
	bCanDoubleJump=False
        bBoss=False
        DodgeSkillAdjust=0.000000

*/	

/*

	ScoringValue=5
	bCanFly=False
	MeleeRange=50.000000
	GroundSpeed=300.000000 //100
	AirSpeed=250.000000
	Health=100
	IdleWeaponAnim="IdleWaitBreath01_LG"
	IdleHeavyAnim="IdleWaitBreath02_LG"
	IdleRifleAnim="IdleWaitBreath03_LG"
	TurnRightAnim="TurnRight01_LG"
	TurnLeftAnim="TurnLeft01_LG"
	CrouchAnims(0)="DuckWalk_Fr01_LG"
	CrouchAnims(1)="DuckWalk_Fr01_LG"
	CrouchAnims(2)="DuckWalk_Fr01_LG"
	CrouchAnims(3)="DuckWalk_Fr01_LG"
	CrouchTurnRightAnim="DuckWalk_Fr01_LG"
	CrouchTurnLeftAnim="DuckWalk_Fr01_LG"
	AirStillAnim="Jump_Fr01_LG"
	AirAnims(0)="Jump_Fr01_LG"
	AirAnims(1)="Jump_Fr01_LG"
	AirAnims(2)="Jump_Fr01_LG"
	AirAnims(3)="Jump_Fr01_LG"
	TakeoffStillAnim="JumpNone01_SS"
	TakeoffAnims(0)="JumpStartFrwd01_SS"
	TakeoffAnims(1)="JumpStartBack01_SS"
	TakeoffAnims(2)="JumpStartLeft01_SS"
	TakeoffAnims(3)="JumpStartRight01_SS"
	LandAnims(0)="Land_Fr01_LG"
	LandAnims(1)="LandBack01_SS"
	LandAnims(2)="LandLeft_SS"
	LandAnims(3)="LandRight_SS"
	DodgeAnims(0)="DodgeFrwd_Fr01_LG"
	DodgeAnims(1)="DodgeBack_Fr01_LG"
	DodgeAnims(2)="DodgeLeft_Fr01_LG"
	DodgeAnims(3)="DodgeRight_Fr01_LG"
	DoubleJumpAnims(0)="JumpStartFrwd01_SS"
	DoubleJumpAnims(1)="JumpStartBack01_SS"
	DoubleJumpAnims(2)="JumpStartLeft01_SS"
	DoubleJumpAnims(3)="JumpStartRight01_SS"
	MovementAnims(0)="WalkFrwd_Fr01_LG"
	MovementAnims(1)="WalkBack_Fr01_LG"
	MovementAnims(2)="WalkLeft_Fr01_LG"
	MovementAnims(3)="WalkRight_Fr01_LG"
	SwimAnims(0)="Swim_Fr01_LG"
	SwimAnims(1)="Swim_Fr01_LG"
	SwimAnims(2)="Swim_Fr01_LG"
	SwimAnims(3)="Swim_Fr01_LG"
	WalkAnims(0)="WalkFrwd_Fr01_LG"
	WalkAnims(1)="WalkBack_Fr01_LG"
	WalkAnims(2)="WalkLeft_Fr01_LG"
	WalkAnims(3)="WalkRight_Fr01_LG"
	WallDodgeAnims(0)="DodgeFrwd_Fr01_LG"
	WallDodgeAnims(1)="DodgeBack_Fr01_LG"
	WallDodgeAnims(2)="DodgeLeft_Fr01_LG"
	WallDodgeAnims(3)="DodgeRight_Fr01_LG"
	IdleRestAnim="IdleWaitBreath01_LG"
	IdleCrouchAnim="DuckIdle_Fr01_LG"
	IdleSwimAnim="Tread_Fr01_LG"
	IdleChatAnim="IdleChat01_LG"
	FireHeavyRapidAnim="Still_Fr01_LG"
	FireHeavyBurstAnim="Still_FrRp01_LG"
	FireRifleRapidAnim="Still_Fr01_LG"
	FireRifleBurstAnim="Still_FrRp01_LG"

*/

/*

	TransientSoundVolume=2.000000
	TransientSoundRadius=500.0000000
	CollisionHeight=50.000000
	CollisionRadius=33.000000
	Mass=200.000000 //10
	DrawScale=0.8
	Buoyancy=99.000000
	PrePivot=(X=0.0,Y=0.0,Z=4.0)
	KickDamage=25
	SwingDamage=15
        FireRootBone="Bip01 Spine1"
	RootBone="Bip01"

*/

defaultproperties
{
     WeaponClassName(0)="XWeapons.RocketLauncher"
     FireRateScale=3.000000
     Species=Class'tk_U2Creatures.SPECIES_IzaHeavy'
     Mesh=SkeletalMesh'tk_U2Creatures.MercJapHeavy'
     Skins(0)=Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy1_BLUEFinal'
     Skins(1)=Shader'tk_U2Creatures.CharacterMaterialsIzanagi.MercJapHeavy0_BLUEFinal'
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
     KParams=KarmaParamsSkel'tk_U2Creatures.IzanagiHeavy.PawnKParams'

}
