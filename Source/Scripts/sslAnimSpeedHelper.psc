ScriptName sslAnimSpeedHelper Hidden

Function SetAnimationSpeed(Actor akActor, float afScale, float afTransition, bool abAbsolute) global
	AnimSpeedHelper.SetAnimationSpeed(akActor, afScale, afTransition, abAbsolute)
EndFunction

Function SetAnimationSpeedRelative(Actor akActor, float afScale, float afTransition, bool abAbsolute) global
	float fCurrentSpeed = AnimSpeedHelper.GetAnimationSpeed(akActor, 1)
	AnimSpeedHelper.SetAnimationSpeed(akActor, afScale * fCurrentSpeed, afTransition, abAbsolute)
EndFunction

Function ResetAnimationSpeed(Actor akActor) global
	AnimSpeedHelper.SetAnimationSpeed(akActor, 1.0, 0.5, 0)
EndFunction
