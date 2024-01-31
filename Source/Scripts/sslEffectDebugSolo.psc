Scriptname sslEffectDebugSolo extends ActiveMagicEffect
{A very basic spell effect that starts a SexLab scene in a modern way, but only for one.}

SexLabFramework property SexLab auto
sslEffectDebugMain Property DebugMain Auto

Event OnEffectStart(Actor TargetRef, Actor CasterRef)

    Actor[] sceneActors = new Actor[1]
    sceneActors[0] = CasterRef

	DebugMain.TriggerSex(sceneActors)

    Dispel()
EndEvent