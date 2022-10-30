class MegaParata extends Parata;

defaultproperties
{
     MeleeDamage=25
     bBoss=True
     ScoringValue=10
     Species=Class'tk_U2Creatures.SPECIES_MegaParata'
     MeleeRange=85.000000
     Health=250
     DrawScale=1.000000
     PrePivot=(Z=-20.000000)
     CollisionRadius=100.000000
     CollisionHeight=45.000000
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
     KParams=KarmaParamsSkel'tk_U2Creatures.MegaParata.PawnKParams'

}
