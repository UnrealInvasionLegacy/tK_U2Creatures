class FX_U2CSkaarjBoltHeavy extends Emitter;
 
//emitter for the Skaarj - by Wail of Suicide


/*
defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=255))
         Opacity=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinCCWorCW=(X=0.000000,Y=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.100000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare2_tw256'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'FX_U2CSkaarjBoltHeavy.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.400000),Z=(Min=0.000000,Max=0.000000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.750000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.600000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare1'
         InitialTimeRange=(Max=0.500000)
         LifetimeRange=(Min=0.750000,Max=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'FX_U2CSkaarjBoltHeavy.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(R=202))
         ColorScale(1)=(Color=(R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         DetailMode=DM_High
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.250000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=18.000000,Max=20.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare8_tw128'
         LifetimeRange=(Min=0.750000,Max=0.750000)
     End Object
     Emitters(3)=SpriteEmitter'FX_U2CSkaarjBoltHeavy.SpriteEmitter3'

     bNoDelete=False
}
*/

/*
defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=255))
         Opacity=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinCCWorCW=(X=0.000000,Y=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.100000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare5_tw128'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.400000),Z=(Min=0.000000,Max=0.000000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.750000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.600000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare2_tw256'
         InitialTimeRange=(Max=0.500000)
         LifetimeRange=(Min=0.750000,Max=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(R=255))
         ColorScale(1)=(Color=(R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         DetailMode=DM_High
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.250000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=18.000000,Max=20.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'tk_U2Creatures.Glows.Flare_01'
         LifetimeRange=(Min=0.750000,Max=0.750000)
     End Object
     Emitters(3)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter3'

     bNoDelete=False
}
*/

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=102,G=142,R=255))
         Opacity=0.500000
         FadeOutStartTime=0.750000
         CoordinateSystem=PTCS_Relative
         MaxParticles=4
         SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.700000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=9.000000,Max=10.000000))
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare2_tw256'
         InitialTimeRange=(Max=0.750000)
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         Opacity=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinCCWorCW=(X=1.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.100000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.Flare_01'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.400000),Z=(Min=0.000000,Max=0.000000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Min=0.250000,Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.100000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.750000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.600000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'tk_U2Creatures.Glows.lensflare1'
         InitialTimeRange=(Max=0.500000)
         LifetimeRange=(Min=0.750000,Max=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=15
         SpinsPerSecondRange=(X=(Min=0.500000,Max=0.500000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=8.000000,Max=10.000000))
         InitialParticlesPerSecond=100.000000
         Texture=Texture'tk_U2Creatures.Glows.Flare_01'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(3)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(R=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinCCWorCW=(X=1.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=2.500000,Max=2.500000))
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         ParticlesPerSecond=8.000000
         InitialParticlesPerSecond=8.000000
         Texture=Texture'tk_U2Creatures.Effects.ColourPool_03'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(4)=SpriteEmitter'tk_U2Creatures.FX_U2CSkaarjBoltHeavy.SpriteEmitter5'

     bNoDelete=False
}
