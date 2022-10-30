class U2BloodSplatterBlue extends xScorch;

var texture Splats[3];

simulated function PostBeginPlay()
{
    ProjTexture = splats[Rand(3)];
    Super.PostBeginPlay();
    Style=STY_Translucent;
}

defaultproperties
{
     Splats(0)=Texture'tk_U2Creatures.Blood.BloodSplat1B'
     Splats(1)=Texture'tk_U2Creatures.Blood.BloodSplat2B'
     Splats(2)=Texture'tk_U2Creatures.Blood.BloodSplat3B'
     ProjTexture=Texture'tk_U2Creatures.Blood.BloodSplat1B'
     FOV=6
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
}
