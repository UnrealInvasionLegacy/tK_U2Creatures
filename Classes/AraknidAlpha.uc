class AraknidAlpha extends AraknidLight;

function RangedAttack(Actor A)
{
	local float Dist;
	local name Anim;
	local float frame,rate;

	if ( bShotAnim )
		return;
	

	Dist = VSize(A.Location - Location);

	Enable('Tick');
	//bShotAnim = true;
	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('RunBite');
		bShotAnim = true;
	}
	else if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
	{

  		SetAnimAction('Bite');
		bShotAnim = true;
		//Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		return;
	}
	else if ( VSize(A.Location - Location) < LungeRange + CollisionRadius + A.CollisionRadius )
	{
		

		PlaySound(sound'tk_U2Creatures.MeleeImpactPoint2', SLOT_Interact);
		bLunging = true;
		Enable('Bump');
		SetAnimAction('JumpBite');
		Velocity = 500 * Normal(A.Location + A.CollisionHeight * vect(0,0,0.75) - Location);
		if ( dist > CollisionRadius + A.CollisionRadius + 35 )
			Velocity.Z += 0.7 * dist;
		SetPhysics(PHYS_Falling);
		bShotAnim = true;
		return;
	}
	else if ( Velocity == vect(0,0,0) )
	{
		SetAnimAction('Zap');
		//Controller.bPreparingMove = true;
		bShotAnim = true;
		Acceleration = vect(0,0,0);
	}
	else
	{
		if ( FRand() < 0.45 )
			return;
		GetAnimParams(0,Anim,frame,rate);
		if ( Anim == 'Run' || Anim == 'Walk' )
		{
			SetAnimAction('RunBite');
			//Controller.bPreparingMove = true;
			return;
		}
	}


}


function SpawnShot()
{
	
	//FireProj(vect(1.1,0,0.4));
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;
	
	GetAxes(Rotation,X,Y,Z);
	//FireStart = (vect(1.1,0,0.4));
	FireStart = GetFireStart(X,Y,Z);
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = MyAmmo.Class;
		SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
		SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
		SavedFireProperties.MaxRange = MyAmmo.MaxRange;
		SavedFireProperties.bTossed = MyAmmo.bTossed;
		SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
		SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
		SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
		SavedFireProperties.bInitialized = true;
	}
	PlaySound(FireSound,SLOT_Interact);
	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
	Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);
	
	
	
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

defaultproperties
{
     BiteDamage=20
     LungeDamage=15
     StingDamage=20
     LungeRange=150
     DeathAnims(7)="Death"
     DodgeSkillAdjust=2.000000
     GibGroupClass=Class'tk_U2Creatures.GenericGibGroup'
     MeleeRange=25.000000
     GroundSpeed=600.000000
     Health=200
     Mesh=SkeletalMesh'tk_U2Creatures.AraknidAlpha'
     DrawScale=2.000000
     PrePivot=(Z=-66.000000)
     Skins(0)=Texture'tk_U2Creatures.AraknidMP0'
     Skins(1)=Texture'tk_U2Creatures.AraknidMP1'
     Skins(2)=Texture'tk_U2Creatures.AraknidMP2'
     Skins(3)=Texture'tk_U2Creatures.AraknidMP3'
     CollisionRadius=64.000000
     CollisionHeight=68.000000
}
