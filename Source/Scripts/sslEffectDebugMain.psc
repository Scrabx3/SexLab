Scriptname sslEffectDebugMain extends Quest
{Main script for debug mode in SexLab.}

import PapyrusUtil

SexLabFramework property SexLab auto
sslSystemConfig property Config auto
Actor property PlayerRef auto

Actor[] sceneActors
Actor akSub

String Function Parse_Sex(Actor akTarget)
	If SexLab.GetSex(akTarget) == 0
		Return "Male"
	ElseIf SexLab.GetSex(akTarget) == 1
		return "Female"
	ElseIf SexLab.GetSex(akTarget) == 2
		return "Futa"
	ElseIf SexLab.GetSex(akTarget) == 3
		return "Male creature"
	ElseIf SexLab.GetSex(akTarget) == 4
		return "Female creature"
	EndIf
EndFunction

String Function Parse_Sexes_And_Races(Int[] iSexes, Actor[] akActors)
    String[] sSexesA = PapyrusUtil.StringArray(iSexes.Length)
    String sSexes
    Int index = 0
    
    While index < iSexes.Length
        Int sexIndex = iSexes[index]
	
		Actor currentActor = akActors[index]
		
		If currentActor
			sSexesA[index] = "[" + GetSexString(sexIndex) + ": " + SexLabRegistry.GetRaceKey(currentActor) + "]"
		EndIf
        
        index += 1
    EndWhile
    
    sSexes = PapyrusUtil.StringJoin(sSexesA, ", ")    
    Return sSexes
EndFunction

String Function GetSexString(Int sexIndex)
    If sexIndex == 0
        Return "Male"
    ElseIf sexIndex == 1
        Return "Female"
    ElseIf sexIndex == 2
        Return "Futa"
    ElseIf sexIndex == 3
        Return "Male Creature"
    ElseIf sexIndex == 4
        Return "Female Creature"
    EndIf
    Return ""
EndFunction

; FIXME: Possible to add the same actor twice, this will cause an error
bool Function AddActors(Actor akTarget)
	int i = 0
	
	If (sceneActors.Length == 0)
		sceneActors = PapyrusUtil.ActorArray(5)

	ElseIf (SexLab.ValidateActor(akTarget) < 0)
		Debug.Trace("[SexLab Debug] - Actor " + SexLabUtil.ActorName(akTarget) + " was invalid")
		UnregisterForUpdate()
		Return false
	EndIf

	While i < sceneActors.Length
		If SceneActors.Find(akTarget) < 0
			If sceneActors[i] == none
				sceneActors[i] = akTarget
				Debug.Notification("Added Actor: " + SexLabUtil.ActorName(akTarget))
				Debug.Trace("[SexLab Debug] - Actor " + SexLabUtil.ActorName(akTarget) + " was added to the array.")
				Debug.Trace("[SexLab Debug] - Actor " + SexLabUtil.ActorName(akTarget) + " is considered as: " + Parse_Sex(akTarget))
				RegisterForSingleUpdate(10.0)
				Return true
			Else
				i += 1
			EndIf
		EndIf
	EndWhile
	TriggerSex()
	Return false
EndFunction

Function TriggerSex(Actor[] akPassed = none)
	RegisterForModEvent("HookAnimationStart", "AnimationStarted")
	RegisterForModEvent("HookAnimationEnd", "AnimationEnded")
	

	If (!akPassed.Length == 0)
		sceneActors = akPassed
	EndIf

	sceneActors = PapyrusUtil.RemoveActor(sceneActors, none)
	Debug.Trace("[SexLab Debug] - Received following array: " + sceneActors)

	If (Config.SubmissiveActor)
		GetSubmissiveActor(sceneActors)
	Else
		akSub = none
	EndIf

	String[] availableScenes = SexLabRegistry.LookupScenes(sceneActors, Config.Tags, akSub, 1, none)


	If (availableScenes.Length < 1 && !Config.SubmissiveActor)
		Debug.Trace("[SexLab Debug] - No valid animations found, attempting fallback lookup!", 1)
		GetSubmissiveActor(sceneActors)
		availableScenes = SexLabRegistry.LookupScenes(sceneActors, Config.Tags, akSub, 1, none)
		If availableScenes.Length > 0
			Debug.Trace("[SexLab Debug] - Scenes found with fallback lookup: " + availableScenes.Length)
		EndIf
	EndIf
	If availableScenes.Length > 0
		Debug.Notification("Valid scenes found: " + availableScenes.Length)
		Debug.Trace("[SexLab Debug] - Scenes found: " + availableScenes.Length)
		SexLab.StartScene(sceneActors, Config.Tags, akSub, asHook = "AnimationStart, AnimationEnd")
	Else
		NoValidAnimations(sceneActors)
		Return
	EndIf
EndFunction

Event AnimationStarted(int aiThread, bool abHasPlayer)
	UnregisterForUpdate()
	SexLabThread thread = SexLab.GetThread(aiThread)
	Debug.Notification("Scene started: " + SexLabRegistry.GetSceneName(thread.GetActiveScene()))
	Debug.Trace("[SexLab Debug] - ###### START LOGGING SCENE DATA #####")
	Debug.Trace("[SexLab Debug] - Current thread name: " + thread.GetName())
	Debug.Trace("[SexLab Debug] - Current active stage: " + thread.GetActiveStage())
	Debug.Trace("[SexLab Debug] - Current active scene: " + thread.GetActiveScene())
	Debug.Trace("[SexLab Debug] - Current playing scene: " + thread.GetPlayingScenes())
	Debug.Trace("[SexLab Debug] - Current scene name: " + SexLabRegistry.GetSceneName(thread.GetActiveScene()))
	Debug.Trace("[SexLab Debug] - Current submissive actor(s): " + thread.GetSubmissives())
	Debug.Trace("[SexLab Debug] - ###### END LOGGING SCENE DATA #####")
	sceneActors = PapyrusUtil.ActorArray(5)
	Debug.Trace("[SexLab Debug] - Actor array has been reset")
EndEvent

Event AnimationEnded(int aiThread, bool abHasPlayer)
	SexLabThread thread = SexLab.GetThread(aiThread)
	Debug.Trace("[SexLab Debug] - Scene " + SexLabRegistry.GetSceneName(thread.GetActiveScene()) + " ended successfully")
EndEvent

Event OnUpdate()
	TriggerSex()
EndEvent

Function GetSubmissiveActor(Actor[] actors)
	If (actors.Find(PlayerRef) < 0)
		akSub = actors[1]
	Else
		akSub = PlayerRef
	EndIf
EndFunction

Function NoValidAnimations(Actor[] akActors)
    Debug.Notification("No valid animations found.")
    Debug.Trace("[SexLab Debug] - Actor combination [" + Parse_Sexes_And_Races(SexLab.GetSexAll(sceneActors), sceneActors) + "] has no valid scenes, aborting!")
    sceneActors = PapyrusUtil.ActorArray(5)
EndFunction