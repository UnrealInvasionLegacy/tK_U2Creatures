//=============================================================================
// UScriptAnimMonster - Originally UScriptAnimPawn by Meowcat (last updated 12 June 2014)
// Link: http://wiki.beyondunreal.com/Legacy:UScriptAnimPawn
//=============================================================================

class UScriptAnimMonsterSkaarj extends U2Creatures;// SomeOtherPawnClass will typically be xPawn

// added to get around the const values normally set by the native code
var bool bFootTurning; 
var bool bFootStill;
var int  iFootRot;
var int  iTurnDir;
//var int SmoothViewPitch, SmoothViewYaw;// These two are only needed if this code is for UT2003, UT2004 pawn code already has them
 
simulated function Tick(float DeltaTime)
{
      if(!bPhysicsAnimUpdate) UpdateMovementAnimation(DeltaTime);//added to allow switching between native and scripted animation
      super.tick(deltatime);
}
 
// Epic C++ animation code converted to uscript, with slight optimization
 
simulated function UpdateMovementAnimation( FLOAT DeltaSeconds )
{
    if ( Level.NetMode == NM_DedicatedServer )
		return;
    if( bPlayedDeath )
        return;
 
    if (Level.TimeSeconds - LastRenderTime > 1.0)
    {
        iFootRot = Rotation.Yaw;
        bFootTurning = false;
        bFootStill = false;
        return;
    }
 
    BaseEyeHeight = Default.BaseEyeHeight;
 
    if ( bIsIdle && Physics != OldPhysics )
    {
        bWaitForAnim = false;
    }
 
    if ( !bWaitForAnim )
    {
        // This first option should be selected most often
        if ( Physics == PHYS_Walking || Physics == PHYS_Ladder )
        {
            UpdateOnGround();
        }
        //next most likely physics state for most maps (I'd assume...)
        else if ( Physics == PHYS_Falling || Physics == PHYS_Flying )
        {
            BaseEyeHeight *= 0.7f;
            UpdateInAir();
        }
        // Probably the least likely state... unless you break out PHYS_Ladder and PHYS_Flying separately
        else if ( Physics == PHYS_Swimming )
	{
            BaseEyeHeight *= 0.7f;
            UpdateSwimming();
	}
 
    }
	else if ( !IsAnimating(0) )
		bWaitForAnim = false;
 
    if ( Physics != PHYS_Walking )
        bIsIdle = false;
 
    OldPhysics = Physics;// OldPhysics is not const and can be changed in UScript
    //OldVelocity = Velocity;// is a const, may be used in the ModifyVelocity function!! 
 
    if (bDoTorsoTwist)
        UpdateTwistLook( DeltaSeconds );
}
 
simulated function UpdateSwimming()
{
    if ( (Velocity.X*Velocity.X + Velocity.Y*Velocity.Y) < 2500.0f )
        PlayAnim(IdleSwimAnim, 1.0f, 0.1f, 0);
    else
	    PlayAnim(SwimAnims[Get4WayDirection()], 1.0f, 0.1f, 0);
        //PlayAnim(0, SwimAnims[Get4WayDirection()], 1.0f, 0.1f, true);// native anim call
}
 
simulated function UpdateInAir()
{
   local Name NewAnim;
   local  bool bUp, bDodge;
   local  float DodgeSpeedThresh;
   local int Dir;
   local  float XYVelocitySquared;
 
    XYVelocitySquared = (Velocity.X*Velocity.X)+(Velocity.Y*Velocity.Y);
 
    bDodge = false;
    if ( OldPhysics == PHYS_Walking )
    {
        DodgeSpeedThresh = ((GroundSpeed*DodgeSpeedFactor) + GroundSpeed) * 0.5f;
        if ( XYVelocitySquared > DodgeSpeedThresh*DodgeSpeedThresh )
        {
            bDodge = true;
        }
    }
 
    bUp = (Velocity.Z >= 0.0f);
 
    if (XYVelocitySquared >= 20000.0f)
    {
        Dir = Get4WayDirection();
 
        if (bDodge)
        {
            NewAnim = DodgeAnims[Dir];
            bWaitForAnim = true;
        }
        else if (bUp)
        {
            NewAnim = TakeoffAnims[Dir];
        }
        else
        {
            NewAnim = AirAnims[Dir];
        }
    }
    else
    {
        if (bUp)
        {
            NewAnim = TakeoffStillAnim;
        }
        else
 
        {
            NewAnim = AirStillAnim;
        }
    }
 
    if ( NewAnim != GetAnimSequence() )
    {
    // have not quite added this yet.  Will edit later -meowcat		
    //if ( PhysicsVolume->Gravity.Z > 0.8f * (Cast<APhysicsVolume>(PhysicsVolume->GetClass()->GetDefaultActor()))->Gravity.Z )
    	//	PlayAnim(0, NewAnim, 0.5f, 0.2f, false); // native anim call
		//else
    		//PlayAnim(NewAnim, 1.0, TweenTime, 0); //loopanim looks bad here....
		PlayAnim(NewAnim, 1.0, /*TweenTime,*/ 0.5);
    		//LoopAnim(NewAnim, 1.0f, 0.1f, 0);
            //PlayAnim(0, NewAnim, 1.0f, 0.1f, false); // native anim call
    }
}
 
simulated function UpdateOnGround()
{
    // just landed
    if ( OldPhysics == PHYS_Falling || OldPhysics == PHYS_Flying )
    {
        PlayLand();
    }
    // standing still
    else if ( Vsize(Velocity*Velocity) < 2500.0f  )  /*&& Acceleration.SizeSquared() < 0.01f*/
    {
        if (!bIsIdle || bFootTurning || bIsCrouched != bWasCrouched)
        {
            IdleTime = Level.TimeSeconds;
            PlayIdle();
        }
        PlayIdle();// added this playIdle to force the code to update whatever animation was playing, otherwise the turning anim could potentially continue to loop
        bWasCrouched = bIsCrouched;
        bIsIdle = true;
    }
    // running
    else
    {
        if ( bIsIdle  )
            bWaitForAnim = false;
 
        PlayRunning();
        bIsIdle = false;
    }
}
 
simulated function PlayIdle()
{
    if (bFootTurning)
    {
        if (iTurnDir == 1)
        {
            if (bIsCrouched)
                LoopAnim(CrouchTurnRightAnim, 1.0f, 0.1f, 0);
            else
    		    LoopAnim(TurnRightAnim, 1.0f, 0.1f, 0);
        }
        else
        {
            if (bIsCrouched)
    		    LoopAnim(CrouchTurnLeftAnim, 1.0f, 0.1f, 0);
            else
        	    LoopAnim(TurnLeftAnim, 1.0f, 0.1f, 0);
        }
    }
    else
    {
        if (bIsCrouched)
        {
            LoopAnim(IdleCrouchAnim, 1.0f, 0.1f, 0);
        }
        else
        {
	    if (PlayerController(controller)!=none &&  PlayerController(controller).bIsTyping )
	            PlayAnim(IdleRestAnim, 1.0f, 0.2f, 0);
            else if ( (Level.TimeSeconds - IdleTime < 5.0f) && IdleWeaponAnim != '')
            {
                LoopAnim(IdleWeaponAnim, 1.0f, 0.25f, 0);
            }
            else
            {
	            LoopAnim(IdleRestAnim, 1.0f, 0.25f, 0);
            }
        }
    }
}
 
simulated function PlayRunning()
{
    local Name NewAnim;
    local int NewAnimDir;
    local float AnimSpeed;
 
    NewAnimDir = Get4WayDirection();
 
    AnimSpeed = 1.1f * Default.GroundSpeed;
    if (bIsCrouched)
    {
        NewAnim = CrouchAnims[NewAnimDir];
        AnimSpeed *= CrouchedPct;
    }
    else if (bIsWalking)
    {
        NewAnim = WalkAnims[NewAnimDir];
        AnimSpeed *= WalkingPct;
    }
    else
    {
        NewAnim = MovementAnims[NewAnimDir];
    }
    LoopAnim(NewAnim, (Vsize(Velocity)) / AnimSpeed, 0.1f, 0);
    //PlayAnim(0, NewAnim, Velocity.Size() / AnimSpeed, 0.1f, true); // native anim call
}
 
simulated function PlayLand()
{
    if (!bIsCrouched)
    {
        PlayAnim(LandAnims[Get4WayDirection()], 1.0f, 0.1f, 0);
        bWaitForAnim = true;
    }
}
 
simulated function UpdateTwistLook( float DeltaTime )
{
    local int look, Update, UpdateB, PitchDiff, t, YawDiff;
 
    if ( !bDoTorsoTwist || (Level.TimeSeconds - LastRenderTime > 0.5f) )
    {
		SmoothViewPitch = ViewPitch;
		SmoothViewYaw = Rotation.Yaw;
        iFootRot = Rotation.Yaw;
        bFootTurning = false;
        bFootStill = false;
    }
    else
    {
 		YawDiff = (Rotation.Yaw - SmoothViewYaw) & 65535;
		if ( YawDiff != 0 )
		{
			if ( YawDiff > 32768 )
				YawDiff -= 65536;
 
			Update = int(YawDiff * 15.f * DeltaTime);
			if ( Update == 0 ){
				//Update = (YawDiff > 0) ? 1 : -1;
				if (YawDiff>0) Update=1;
				else Update= -1;
			}
			SmoothViewYaw = (SmoothViewYaw + Update) & 65535;
		}
		t = (SmoothViewYaw - iFootRot) & 65535;
        if (t > 32768)
			t -= 65536;
 
        if (((Velocity.X * Velocity.X) + (Velocity.Y * Velocity.Y)) < 1000 && Physics == PHYS_Walking)
        {
            if (!bFootStill)
            {
                bFootStill = true;
				SmoothViewYaw = Rotation.Yaw;
                iFootRot = Rotation.Yaw;
				t = 0;
            }
        }
        else
        {
            if (bFootStill)
            {
                bFootStill = false;
                bFootTurning = true;
            }
        }
 
        if (bFootTurning)
        {
           if (t > 12000)
            {
                iFootRot = SmoothViewYaw - 12000;
                t = 12000;
            }
            else if (t > 2048)
            {
                iFootRot += 16384*DeltaTime;
            }
            else if (t < -12000)
            {
                iFootRot = SmoothViewYaw + 12000;
                t = -12000;
            }
            else if (t < -2048)
            {
                iFootRot -= 16384*DeltaTime;
            }
            else
            {
                if (!bFootStill)
                    t = 0;
                bFootTurning = false;
            }
            iFootRot = iFootRot & 65535;
        }
        else if (bFootStill)
        {
            if (t > 10923)
            {
                iTurnDir = 1;
                bFootTurning = true;
            }
            else if (t < -10923)
            {
                iTurnDir = -1;
                bFootTurning = true;
            }
        }
        else
        {
            t = 0;
        }
		PitchDiff = (256*ViewPitch - SmoothViewPitch) & 65535;
		if ( PitchDiff != 0 )
		{
			if ( PitchDiff > 32768 )
				PitchDiff -= 65536;
 
			UpdateB = int(PitchDiff * 5.f * DeltaTime);
			if ( UpdateB == 0 ){
				//Update = (PitchDiff > 0) ? 1 : -1;
				if (PitchDiff>0) UpdateB=1;
				else UpdateB= -1;
			}
			SmoothViewPitch = (SmoothViewPitch + UpdateB) & 65535;
		}
		look = SmoothViewPitch;
        if (look > 32768)
			look -= 65536;
        //call this native function to actually update the pawn's torso twist
        SetTwistLook(t, look);
        //td_SetTwistLook(t, look);// or call an edited version of the settwistlook so that you can alter how the rotation is applied
    }
}
 
simulated function td_SetTwistLook( int twist, int look)
{
    local rotator r;
    if (!bDoTorsoTwist)
        return;
 
	r.Yaw=-twist + SmoothViewYaw - Rotation.Yaw;
    SetBoneRotation(RootBone, r, 0, 1.0f);
 
    r.Yaw = -twist / 3;
    r.Pitch = 0;
    r.Roll = 0;//look / 4;
    SetBoneDirection(HeadBone, r, Vect(0.0f,0.0f,0.0f), 1.0f, 0);
    SetBoneDirection(SpineBone1, r, Vect(0.0f,0.0f,0.0f), 1.0f, 0);
    SetBoneDirection(SpineBone2, r, Vect(0.0f,0.0f,0.0f), 1.0f, 0);
}

defaultproperties
{
     bPhysicsAnimUpdate=False
}
