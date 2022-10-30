class U2EffectB extends Emitter;

//Original EffectB by the Fraghouse Invasion team

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
     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         FadeOutStartTime=0.850000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=5
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Min=0.132000,Max=0.900000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=30.000000,Max=30.000000),Z=(Min=30.000000,Max=30.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'tk_U2Creatures.Assets.Sing_001'
         LifetimeRange=(Min=1.200000,Max=1.200000)
         WarmupTicksPerSecond=20.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(0)=SpriteEmitter'tk_U2Creatures.U2EffectB.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         SpinParticles=True
         UniformSize=True
         FadeOutStartTime=0.200000
         FadeInEndTime=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=5
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=30.000000,Max=30.000000),Z=(Min=30.000000,Max=30.000000))
         InitialParticlesPerSecond=2.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'tk_U2Creatures.Assets.Sing_003'
         LifetimeRange=(Min=0.400000,Max=0.400000)
         WarmupTicksPerSecond=20.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(1)=SpriteEmitter'tk_U2Creatures.U2EffectB.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseDirectionAs=PTDU_Right
         FadeOut=True
         FadeIn=True
         ResetAfterChange=True
         AutoReset=True
         FadeOutStartTime=0.300000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         DetailMode=DM_High
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=50.000000,Max=50.000000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000),Y=(Min=1.500000,Max=1.500000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'tk_U2Creatures.Assets.Sing_001'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRadialRange=(Min=-50.000000,Max=-50.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeTime=1.000000,RelativeVelocity=(X=-1.000000,Y=-1.000000,Z=-1.000000))
         WarmupTicksPerSecond=50.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=SpriteEmitter'tk_U2Creatures.U2EffectB.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=62,G=198,R=181))
         ColorScale(2)=(RelativeTime=1.000000)
         FadeOutStartTime=0.500000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(X=(Min=0.132000,Max=0.900000))
         StartSizeRange=(X=(Min=40.000000,Max=40.000000))
         Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(3)=SpriteEmitter'tk_U2Creatures.U2EffectB.SpriteEmitter7'

     bNoDelete=False
}
