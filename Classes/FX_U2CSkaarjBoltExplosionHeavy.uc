class FX_U2CSkaarjBoltExplosionHeavy extends Emitter;
 
//emitter for the Skaarj - by Wail of Suicide

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=128,G=128,R=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=64,G=64,R=202))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.500000
         MaxParticles=2
         StartLocationOffset=(X=-2.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000))
         InitialParticlesPerSecond=500.000000
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(0)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltExplosionHeavy.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseDirectionAs=PTDU_Scale
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=128,G=128,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=128,G=128,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         MaxParticles=1
         StartLocationOffset=(X=-4.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(1)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltExplosionHeavy.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=128,G=128,R=224))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=64,R=202))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.125000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         EffectAxis=PTEA_PositiveZ
         DetailMode=DM_High
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=32.000000
         Texture=Texture'AW-2004Particles.Energy.SmoothRing'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(2)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltExplosionHeavy.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=128,G=164,R=202))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=64,R=202))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=8
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=12.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
         LifetimeRange=(Min=0.600000,Max=0.800000)
     End Object
     Emitters(3)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltExplosionHeavy.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         ColorScale(0)=(Color=(B=128,G=192,R=255))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=92,G=128,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=4
         DetailMode=DM_High
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(Y=(Max=65536.000000),Z=(Min=8.000000,Max=16.000000))
         UseRotationFrom=PTRS_Actor
         RotationOffset=(Yaw=16384)
         SpinsPerSecondRange=(X=(Max=0.050000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(Y=(Min=50.000000,Max=150.000000))
         StartVelocityRadialRange=(Min=-100.000000,Max=-200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(4)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltExplosionHeavy.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.650000,Color=(B=64,G=128,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=3
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=16.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
         InitialParticlesPerSecond=500.000000
         Texture=Texture'AW-2004Particles.Fire.GrenadeTest'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.350000,Max=0.350000)
         InitialDelayRange=(Min=0.050000,Max=0.050000)
     End Object
     Emitters(5)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltExplosionHeavy.SpriteEmitter5'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=2.000000
}
