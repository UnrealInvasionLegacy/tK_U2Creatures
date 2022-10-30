//=============================================================================
// DummyPlayerActor - This is the visual representation of the pawn when it is 
// being eaten by the spider. Cheap and crappy. Should be redone.
// (c) milk@rbthinktank.com
//=============================================================================

class U2DummyPlayerActor extends VMeshActor;

var pawn PawnOwner;
var Rotator RotationIncrement;
var xEmitter BloodJetLeet;
var int TimerI;
var float TimeToDestroy;

replication
{
	reliable if ( bNetDirty && (Role == Role_Authority) )
		PawnOwner;
}

Simulated function PostBeginPlay()
{

	Super.PreBeginPlay();
	TimerI=0;
	SetTimer(0.1, true);
	TimeToDestroy=Level.TimeSeconds+1;//+20;

}

simulated function timer()
{
	local Actor Other;
	local Vector X, Start, End, HitLocation, HitNormal, RandVec;
	local Rotator Dir;
	//local monster MPoo;
	
	If(PawnOwner != None)
	{
	
    LinkMesh(PawnOwner.Mesh,false);
    SetDrawScale(PawnOwner.DrawScale);
	Skins = PawnOwner.Skins;
	PawnOwner.Weapon = None;
	
	}
	If(Timeri < 16)
	{
		Dir = Rot(-16384,0,0);
		Start = Location;
		X=Vector(Dir);
		End = Start + 5000 * X;
		Other=Trace(HitLocation, HitNormal, End, Start, true);
		//Spawn(class'SpiderMunchBloodSplatter',self,,HitLocation, rotator(-HitNormal));
		
	}
	If(Timeri > 13)
	{
		if(Level.Netmode != NM_DedicatedServer)
		{
			if(frand() < 0.5)
			{
					RandVec.X=RandRange(-10,10);
					RandVec.Y=RandRange(-10,10);
					RandVec.Z=RandRange(-10,10);
					BloodJetLeet = Spawn(class'BloodJet', self,, self.Location + RandVec, self.Rotation);
					BloodJetLeet.SetPhysics(PHYS_Trailer);
					BloodJetLeet.SetBase(self);
					/*if(Venom(Instigator) != None)
					{
						Venom(Instigator).MyJaws.PlayBite();
						Venom(Instigator).MyJaws.Spawn(class'BloodJet',,, Venom(Instigator).MyJaws.Location + RandVec, Venom(Instigator).MyJaws.Rotation);
					}*/
			}
		}
	}
	TimerI++;
	SetRelativeRotation(RelativeRotation-RotationIncrement);
	If(PawnOwner != None)
	{
		PawnOwner.StopWeaponFiring();
		PawnOwner.SetDrawType(DT_None);
		PawnOwner.SetPhysics(PHYS_None);
		PawnOwner.SetCollision(False,False,False);
		PawnOwner.bCollideWorld=False;
		PawnOwner.bNoTeamBeacon=True;
	}
	/*if(Frand() > 0.8 && Instigator != None)
	{
		foreach Instigator.CollidingActors (Class'Monster', MPoo, 1000)
		{
			if(MPoo != Instigator)
				MPoo.AddVelocity( (10.0 * (MPoo.Location - Instigator.Location )));
		}
	}*/
	if(Level.TimeSeconds >= TimeToDestroy )
		Destroy();
	//enable('tick');
}

Simulated function tick(Float deltatime)
{
	Super.Tick(deltatime);
	if(Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		PawnOwner.bNoTeamBeacon=True;
	}
}

simulated function Destroyed()
{
	If(PawnOwner != None)
	{
		PawnOwner.SetLocation((Location));
		PawnOwner.SetDrawType(DT_Mesh);
		PawnOwner.SetPhysics(PHYS_Falling);
		PawnOwner.SetCollision(True,True,True);
		PawnOwner.bCollideWorld=True;
		if(PawnOwner.Controller != None)
			PawnOwner.Controller.bGodMode=False;
		PawnOwner.TakeDamage(1000000, Instigator, PawnOwner.Location, vect(0,0,0), class'MeleeDamage');
	}
	//if(Level.NetMode != NM_DedicatedServer && Venom(Instigator) != None)
	//	Venom(Instigator).MyJaws.PlayIdle();
	Super.Destroyed();

}

defaultproperties
{
     RotationIncrement=(Yaw=1000)
     StartAnim="HitB"
     bAlwaysRelevant=True
     bReplicateInstigator=True
     RemoteRole=ROLE_SimulatedProxy
     Skins(0)=TexEnvMap'EpicParticles.PlasmaCube.PlasmEnv1'
     Skins(1)=TexEnvMap'EpicParticles.PlasmaCube.PlasmEnv1'
     Skins(2)=TexEnvMap'EpicParticles.PlasmaCube.PlasmEnv1'
     bNetNotify=True
     bEdShouldSnap=True
}
