class MiniMukhogg extends Mukhogg;

function RamDamageTarget()
{
	if ( MeleeDamageTarget(RamDamage, (45000 * Normal(Controller.Target.Location - Location))) )//2500
		if (FRand() < 0.5)
			PlaySound(sound'tk_U2Creatures.Headbutt1', SLOT_Interact);			
		else
			PlaySound(sound'tk_U2Creatures.Headbutt2', SLOT_Interact);
}	

defaultproperties
{
     RamDamage=10
     StepShakeRadius=0.000000
     StepShakeMagnitude=0.000000
     StepShakeDuration=0.000000
     Species=Class'tk_U2Creatures.SPECIES_MiniMukhogg'
     GroundSpeed=250.000000
     WalkingPct=0.100000
     Health=100
     SoundDampening=0.500000
     DrawScale=0.210000
     PrePivot=(Z=5.000000)
     CollisionRadius=40.000000
     CollisionHeight=31.000000
     Mass=100.000000
     RotationRate=(Yaw=65535)
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
     KParams=KarmaParamsSkel'tk_U2Creatures.MiniMukhogg.PawnKParams'

}
