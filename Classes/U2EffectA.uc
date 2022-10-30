class U2EffectA extends Emitter;

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	
	Super.PostNetBeginPlay();
		
	PC = Level.GetLocalPlayerController();
	if ( (PC != None) && ((PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 6000)) )
		Emitters[2].Disabled = true;
}	

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseAbsoluteTimeForSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         FadeOutStartTime=0.850000
         FadeInEndTime=0.800000
         CoordinateSystem=PTCS_Relative
         StartSpinRange=(X=(Min=0.132000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.100000)
         StartSizeRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=80.000000,Max=80.000000),Z=(Min=80.000000,Max=80.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'tk_U2Creatures.Assets.Sing_001'
         LifetimeRange=(Min=1.200000,Max=1.200000)
         WarmupTicksPerSecond=20.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(0)=SpriteEmitter'tk_U2Creatures.U2EffectA.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         SpinParticles=True
         UniformSize=True
         FadeOutStartTime=0.200000
         FadeInEndTime=0.800000
         CoordinateSystem=PTCS_Relative
         MaxParticles=7
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=0.154000,Max=0.913000))
         StartSizeRange=(X=(Min=45.000000,Max=45.000000))
         InitialParticlesPerSecond=2.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'tk_U2Creatures.Assets.Sing_004'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         WarmupTicksPerSecond=20.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(1)=SpriteEmitter'tk_U2Creatures.U2EffectA.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         UniformSize=True
         FadeOutStartTime=0.300000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=25
         DetailMode=DM_High
         StartSizeRange=(X=(Min=4.500000,Max=4.500000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'tk_U2Creatures.Assets.Sing_004'
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-40.000000,Max=40.000000))
         VelocityScale(0)=(RelativeTime=1.000000,RelativeVelocity=(X=-1.000000,Y=-1.000000,Z=-1.000000))
         WarmupTicksPerSecond=50.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=SpriteEmitter'tk_U2Creatures.U2EffectA.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UniformSize=True
         ColorScale(0)=(Color=(B=111,G=206,R=223))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=82,G=224,R=139))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=52,G=158,R=84))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.300000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(X=(Min=0.132000,Max=0.900000))
         Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
         LifetimeRange=(Min=1.300000,Max=1.300000)
     End Object
     Emitters(3)=SpriteEmitter'tk_U2Creatures.U2EffectA.SpriteEmitter3'

     bNoDelete=False
}
