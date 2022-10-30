class U2SkaarjProjectileHeavyCorona extends Light;//Effects;


auto state Start
{
    simulated function Tick(float dt)
    {
        SetDrawScale(FMin(DrawScale + dt*12.0, 1.5));
        if (DrawScale >= 1.5)
        {
            GotoState('End');
        }
    }
}

state End
{
    simulated function Tick(float dt)
    {
        SetDrawScale(FMax(DrawScale - dt*12.0, 0.9));
        if (DrawScale <= 0.9)
        {
            GotoState('');
        }
    }
}

defaultproperties
{
     bCorona=True
     bStatic=False
     bNoDelete=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     Texture=Shader'tk_U2Creatures.Glows.lensflare5A_TW128_rotatingFX'
     DrawScale=1.200000
     DrawScale3D=(X=0.700000,Y=0.350000,Z=0.350000)
     Skins(0)=Shader'tk_U2Creatures.Glows.lensflare5A_TW128_rotatingFX'
     Style=STY_Translucent
     Mass=13.000000
}
