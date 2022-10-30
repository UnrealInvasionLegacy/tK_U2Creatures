class AraknidHeavyShockwave extends Emitter;

#exec OBJ LOAD FILE=EpicParticles.utx
var() float Damage, DamageRadius, MomentumTransfer;
var() class<DamageType> MyDamageType;

state Explode 
{
Begin:
    //Sleep(1.5);
   // PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    /*HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);*/
}

defaultproperties
{
     Damage=50.000000
     DamageRadius=2000.000000
     MomentumTransfer=200000.000000
     MyDamageType=Class'tk_U2Creatures.DamTypeAraknidHeavyShockwave'
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionRing'
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(G=20,R=20))
         ColorScale(2)=(RelativeTime=0.600000,Color=(G=20,R=20))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=1.000000
         MaxParticles=1
         StartSpinRange=(Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'EpicParticles.Smoke.FlameGradient'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=MeshEmitter'tk_U2Creatures.AraknidHeavyShockwave.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'ParticleMeshes.Complex.ExplosionSphere'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.300000,Color=(G=20,R=20,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(G=20,R=20,A=128))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=1.000000
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.200000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EpicParticles.Smoke.FlameGradient'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.750000,Max=0.750000)
     End Object
     Emitters(1)=MeshEmitter'tk_U2Creatures.AraknidHeavyShockwave.MeshEmitter1'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bDirectional=True
}
