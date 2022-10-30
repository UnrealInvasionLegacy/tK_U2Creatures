//=============================================================================
// ArmorActor.
// This mesh is the parent class for all the armor for the Venom. The purpose 
// of using static meshes for the armor is that they are can be cached in the 
// event that copies are spawned. Additionally, the total poly's for the Venom
// skeletal mesh were reduced significantly. Though we could have hardened the
// faces on the Venom skeletal mesh with the editor tools, it would have been 
// less efficient than this method. Additionally, this sets up the ability to
// destroy the armor based on damage. - I'm not coding that right now though.
// (c) milk@rbthinktank.com
//=============================================================================

class U2CArmorActor extends StaticMeshActor;

var name AttachBoneName;

Simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if(Owner != None)
	{
		Owner.AttachToBone(self, AttachBoneName);
	}
}

defaultproperties
{
     bExactProjectileCollision=False
     bUseDynamicLights=False
     bStatic=False
     bWorldGeometry=False
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_None
     DrawScale=1.500000
     Skins(0)=Texture'tk_U2Creatures.skaarjglove'
     bShadowCast=False
     bCollideActors=False
     bBlockActors=False
     bBlockKarma=False
}
