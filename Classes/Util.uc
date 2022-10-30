//=============================================================================
// Util.uc
// $Author: Mfox $
// $Date: 12/14/02 8:26p $
// $Revision: 51 $
//=============================================================================
//NEW: file

class Util extends Actor // never instantiated and extending Actor makes things easier
	abstract;

//=============================================================================
// Low-level utility functions, e.g. string parsing, formatting, generic math
// functions etc.
//=============================================================================

const DefaultGetFloatPrecision	= 3;
//-----------------------------------------------------------------------------
// Linearly scales between MinRangeVal/MaxRangeVal given a value and a 
// corresponding range.
//-----------------------------------------------------------------------------
// Val:				value to scale
// RangeMin:		minimum of range for value			(should be <= RangeMax)
// RangeMax:		maximum of range for value
// MinRangeVal:		value to return at min for range
// MaxRangeVal:		value to return at max for range
//-----------------------------------------------------------------------------
// Returns:			scaled value
//-----------------------------------------------------------------------------

static final function float ScaleLinear( float Val, float RangeMin, float RangeMax, float MinRangeVal, float MaxRangeVal )
{
	local float ReturnedVal;
	local float LinearScaleFactor;
	local float DeltaRange, TempFloat;

	if( Val <= RangeMin )
	{
		ReturnedVal = MinRangeVal;
	}
	else if( Val >= RangeMax )
	{
		ReturnedVal = MaxRangeVal;
	}
	else
	{
		if( MaxRangeVal < MinRangeVal )
		{
			TempFloat = MinRangeVal;
			MaxRangeVal = MinRangeVal;
			MinRangeVal = TempFloat;
			DeltaRange = (RangeMax - Val);
		}
		else
		{
			DeltaRange = (Val - RangeMin);
		}

    	LinearScaleFactor = (MaxRangeVal - MinRangeVal) / (RangeMax - RangeMin);
		ReturnedVal	= DeltaRange*LinearScaleFactor + MinRangeVal;
	}

	return ReturnedVal;
}

defaultproperties
{
}
