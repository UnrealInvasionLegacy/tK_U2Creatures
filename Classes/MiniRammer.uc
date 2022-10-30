class MiniRammer extends Rammer;

function Step()
{

	PlaySound(StepSounds[Rand(4)], SLOT_Interact, 24);
}

defaultproperties
{
     RamDamage=10
     StepShakeRadius=0.000000
     StepShakeMagnitude=0.000000
     StepShakeDuration=0.000000
     DodgeSkillAdjust=1.000000
     Species=Class'tk_U2Creatures.SPECIES_MiniRammer'
     MeleeRange=50.000000
     GroundSpeed=300.000000
     AirSpeed=350.000000
     WalkingPct=0.126000
     Health=100
     SoundDampening=0.450000
     DrawScale=0.750000
     PrePivot=(Z=16.500000)
     CollisionRadius=37.500000
     CollisionHeight=34.000000
     Mass=75.000000
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
     KParams=KarmaParamsSkel'tk_U2Creatures.MiniRammer.PawnKParams'

}
