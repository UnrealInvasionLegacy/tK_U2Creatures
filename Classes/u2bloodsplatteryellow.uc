class U2BloodSplatterYellow extends xScorch;

var texture Splats[3];

simulated function PostBeginPlay()
{
    ProjTexture = splats[Rand(3)];
    Super.PostBeginPlay();
}

defaultproperties
{
     Splats(0)=Texture'tk_U2Creatures.Blood.BloodSplat1Y'
     Splats(1)=Texture'tk_U2Creatures.Blood.BloodSplat2Y'
     Splats(2)=Texture'tk_U2Creatures.Blood.BloodSplat3Y'
     ProjTexture=Texture'tk_U2Creatures.Blood.BloodSplat1Y'
     FOV=6
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
}
