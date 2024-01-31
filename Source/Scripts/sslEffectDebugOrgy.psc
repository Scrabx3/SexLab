Scriptname sslEffectDebugOrgy extends ActiveMagicEffect
{A very basic spell effect that checks if the actor is valid for SexLab and triggers Sex upon expiring.}

SexLabFramework property SexLab auto
sslEffectDebugMain Property DebugMain Auto

Event OnEffectStart(Actor TargetRef, Actor CasterRef)
    If SexLab.ValidateActor(TargetRef) > 0
		DebugMain.AddActors(TargetRef)
    Else
        Debug.Notification("Could not add Actor: " + SexLabUtil.ActorName(TargetRef))
    EndIf
EndEvent