class MegaSnipe extends Snipe;

defaultproperties
{
     MeleeDamage=25
     bBoss=True
     DodgeSkillAdjust=3.000000
     Species=Class'tk_U2Creatures.SPECIES_MegaSnipe'
     bCrawler=False
     MeleeRange=75.000000
     GroundSpeed=350.000000
     Health=150
     DrawScale=3.500000
     CollisionRadius=100.000000
     CollisionHeight=46.000000
     Mass=300.000000
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
     KParams=KarmaParamsSkel'tk_U2Creatures.MegaSnipe.PawnKParams'

}
