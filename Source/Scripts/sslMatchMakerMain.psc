Scriptname sslMatchMakerMain extends Quest
{SexLab MatchMaker Main Script.}

import PapyrusUtil

SexLabFramework property SexLab auto
sslSystemConfig property Config auto
Actor property PlayerRef auto

Actor[] sceneActors
Actor akSub
Actor[] akSubA
String[] availableScenes

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
		Config.Log("[SexLab MatchMaker] - Actor " + SexLabUtil.ActorName(akTarget) + " was invalid")
		UnregisterForUpdate()
		Return false
	EndIf

	While i < sceneActors.Length
		If SceneActors.Find(akTarget) < 0
			If sceneActors[i] == none
				sceneActors[i] = akTarget
				Debug.Notification("Added Actor: " + SexLabUtil.ActorName(akTarget))
				Config.Log("[SexLab MatchMaker] - Actor " + SexLabUtil.ActorName(akTarget) + " was added to the array.")
				Config.Log("[SexLab MatchMaker] - Actor " + SexLabUtil.ActorName(akTarget) + " is considered as: " + Parse_Sex(akTarget))
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
	Config.Log("[SexLab MatchMaker] - Received following array: " + sceneActors)

	; TODO: Ensure to use an index which doesn't correspond to the player
	If (Config.SubmissivePlayer && !Config.SubmissiveTarget)
		akSub = PlayerRef
	ElseIf (Config.SubmissiveTarget && !Config.SubmissivePlayer)
		akSub = sceneActors[1]
	EndIf

	String tags = sslSystemConfig.ParseMMTagString()
	If (Config.SubmissivePlayer && Config.SubmissiveTarget)
		akSubA = PapyrusUtil.ActorArray(2)
		akSubA[0] = PlayerRef
		; TODO: Ensure to not grab the player here
		akSubA[1] = sceneActors[1]
		availableScenes = SexLabRegistry.LookupScenesA(sceneActors, tags, akSubA, 1, none)
	Else
		availableScenes = SexLabRegistry.LookupScenes(sceneActors, tags, akSub, 1, none)
	EndIf


	If (availableScenes.Length < 1 && !Config.SubmissivePlayer)
		Config.Log("[SexLab MatchMaker] - No valid animations found, attempting fallback lookup!", 1)
		GetSubmissiveActor(sceneActors)
		availableScenes = SexLabRegistry.LookupScenes(sceneActors, tags, akSub, 1, none)
		If availableScenes.Length > 0
			Config.Log("[SexLab MatchMaker] - Scenes found with fallback lookup: " + availableScenes.Length)
		EndIf
	EndIf
	If availableScenes.Length > 0
		Debug.Notification("Valid scenes found: " + availableScenes.Length)
		Config.Log("[SexLab MatchMaker] - Scenes found: " + availableScenes.Length)
		SexLab.StartScene(sceneActors, tags, akSub, asHook = "AnimationStart, AnimationEnd")
	Else
		NoValidAnimations(sceneActors)
		Return
	EndIf
EndFunction

Event AnimationStarted(int aiThread, bool abHasPlayer)
	UnregisterForUpdate()
	SexLabThread thread = SexLab.GetThread(aiThread)
	Debug.Notification("Scene started: " + SexLabRegistry.GetSceneName(thread.GetActiveScene()))
	Config.Log("[SexLab MatchMaker] - ###### START LOGGING SCENE DATA #####")
	Config.Log("[SexLab MatchMaker] - Current thread name: " + thread.GetName())
	Config.Log("[SexLab MatchMaker] - Current active stage: " + thread.GetActiveStage())
	Config.Log("[SexLab MatchMaker] - Current active scene: " + thread.GetActiveScene())
	Config.Log("[SexLab MatchMaker] - Current playing scene: " + thread.GetPlayingScenes())
	Config.Log("[SexLab MatchMaker] - Current scene name: " + SexLabRegistry.GetSceneName(thread.GetActiveScene()))
	Config.Log("[SexLab MatchMaker] - Current submissive actor(s): " + thread.GetSubmissives())
	Config.Log("[SexLab MatchMaker] - ###### END LOGGING SCENE DATA #####")
	sceneActors = PapyrusUtil.ActorArray(5)
	Config.Log("[SexLab MatchMaker] - Actor array has been reset")
EndEvent

Event AnimationEnded(int aiThread, bool abHasPlayer)
	SexLabThread thread = SexLab.GetThread(aiThread)
	Config.Log("[SexLab MatchMaker] - Scene " + SexLabRegistry.GetSceneName(thread.GetActiveScene()) + " ended successfully")
EndEvent

Event OnUpdate()
	TriggerSex()
EndEvent

; FIXME: Do I still need this?
Function GetSubmissiveActor(Actor[] actors)
	If (actors.Find(PlayerRef) < 0)
		akSub = actors[1]
	Else
		akSub = PlayerRef
	EndIf
EndFunction

Function NoValidAnimations(Actor[] akActors)
    Debug.Notification("No valid animations found.")
    Config.Log("[SexLab MatchMaker] - Actor combination [" + Parse_Sexes_And_Races(SexLab.GetSexAll(sceneActors), sceneActors) + "] has no valid scenes, aborting!")
    sceneActors = PapyrusUtil.ActorArray(5)
EndFunction