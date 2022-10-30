//=============================================================================
// AssaultRiflePickup.
//=============================================================================
class SingularityCannonPickup extends UTWeaponPickup;

defaultproperties
{
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.800000
     InventoryType=Class'tk_U2Creatures.SingularityCannon'
     PickupMessage="You got the Singularity Cannon."
     PickupSound=Sound'PickupSounds.AssaultRiflePickup'
     PickupForce="AssaultRiflePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'tk_U2Creatures.Weapons.SC_TP_W'
     DrawScale=0.650000
}
