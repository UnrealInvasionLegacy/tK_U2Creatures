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

class U2CArmorActorRazikLightR extends U2CArmorActor;

defaultproperties
{
     AttachBoneName="rightclaw"
     StaticMesh=StaticMesh'tk_U2Creatures.Weapons.skaarjgloveMMMM'
     RelativeLocation=(X=-5.000000,Z=-15.000000)
     DrawScale=0.687500
}
