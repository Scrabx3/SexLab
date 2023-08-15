ScriptName sslThreadModel extends SexLabThread Hidden
{
	Internal class for primary scene management. 
	Implements SexLabThread, builds and controls scene-flow and keeps track of scene actors

	To start a scene, please check the functions provided in the main API (SexLabFramework.psc)
	To access, read and write scene related data see sslThreadController.psc
}

; TODO: SFX Sounds are currently not supported
; They should be handled by the dll and will require some registration from the front end to become active

int Function GetThreadID()
	return tid
EndFunction

String Function GetActiveScene()
	return _ActiveScene
EndFunction

String Function GetActiveStage()
	return _ActiveStage
EndFunction

; Set of scenes currently used by the thread
String[] Function GetPlayingScenes()
	return Scenes
EndFunction

; ------------------------------------------------------- ;
; --- Position Access                                 --- ;
; ------------------------------------------------------- ;
;/
	Functions to check if a specific Actor is part of the scene and how they are categorized in that scene
/;

bool Function HasPlayer()
	return HasPlayer
EndFunction
bool Function HasActor(Actor ActorRef)
	return Positions.Find(ActorRef) != -1
EndFunction

; ------------------------------------------------------- ;
; --- Submission                                      --- ;
; ------------------------------------------------------- ;
;/
	Functions to view and manipulate the submissive flag for individual actors
/;

bool Property IsAggressive hidden
	bool Function get()
		return GetAllVictims().Length || _ThreadTags.Find("Forced") > -1
	endfunction
	Function set(bool value)
	EndFunction
EndProperty

Actor[] Function GetAllVictims()
	Actor[] ret = new Actor[5]
	int i = 0
	While(i < Positions.Length)
		If(ActorAlias[i].IsVictim())
			ret[i] = Positions[i]
		EndIf
		i += 1
	EndWhile
	return PapyrusUtil.RemoveActor(ret, none)
EndFunction

Function SetVictim(Actor ActorRef, bool Victimize = true)
	sslActorAlias vic = ActorAlias(ActorRef)
	If(vic)
		vic.SetVictim(Victimize)
	EndIf
EndFunction

bool Function IsVictim(Actor ActorRef)
	sslActorAlias vic = ActorAlias(ActorRef)
	return vic && vic.IsVictim()
EndFunction

bool Function IsAggressor(Actor ActorRef)
	sslActorAlias agr = ActorAlias(ActorRef)
	return agr && agr.IsAggressor()
EndFunction

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;
;/
	Threads store the tags shared with every scene it is allowed to use; I.e. if we have 2 scenes:
	["doggy", "loving", "behind"] and ["doggy", "loving", "hugging", "kissing"], then the thread tags will be ["doggy", "loving"]

	Tags are read only, as they directly represent the underlying available scenes
/;

bool Function HasTag(String Tag)
	return _ThreadTags.Find(Tag) != -1
EndFunction

bool Function CheckTags(String[] CheckTags, bool RequireAll = true, bool Suppress = false)
	int i = 0
	While (i < CheckTags.Length)
		If (HasTag(CheckTags[i]))
			If (!RequireAll || Suppress)
				return !Suppress
			EndIf
		EndIf
		i += 1
	EndWhile
	return !Suppress
EndFunction

String[] Function GetTags()
	return PapyrusUtil.ClearEmpty(_ThreadTags)
EndFunction

; ------------------------------------------------------- ;
; --- Event Hooks                                     --- ;
; ------------------------------------------------------- ;

Function SetHook(string AddHooks)
	string[] newHooks = PapyrusUtil.StringSplit(AddHooks)
	_Hooks = PapyrusUtil.MergeStringArray(_Hooks, newHooks, true)
EndFunction

Function RemoveHook(string DelHooks)
	string[] remove = PapyrusUtil.StringSplit(DelHooks)
	int i = 0
	While (i < remove.Length)
		int where = _Hooks.Find(remove[i])
		If(where > -1)
			_Hooks[where] = ""
		EndIf
		i += 1
	EndWhile
	_Hooks = PapyrusUtil.ClearEmpty(_Hooks)
EndFunction

string[] Function GetHooks()
	return PapyrusUtil.ClearEmpty(_Hooks)
EndFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;        ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗            ;
;        ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║            ;
;        ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║            ;
;        ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║            ;
;        ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗       ;
;        ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝       ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

int thread_id
int Property tid hidden
	int Function get()
		return thread_id
	EndFunction
EndProperty

Actor Property PlayerRef Auto
bool Property HasPlayer Hidden
	bool Function Get()
		return Positions.Find(PlayerRef) > -1
	EndFunction
EndProperty

sslSystemConfig Property Config Auto
Package Property DoNothingPackage Auto	; used in the alias scripts
Message Property InvalidCenterMsg Auto	; Invalid new cewnter -> [0: Keep Old Center, 1: End Scene]

; Constants
int Property POSITION_COUNT_MAX = 5 AutoReadOnly

String Property STATE_IDLE 		= "Unlocked" AutoReadOnly
String Property STATE_SETUP 	= "Making" AutoReadOnly
String Property STATE_SETUP_M	= "Making_M" AutoReadOnly
String Property STATE_PLAYING = "Animating" AutoReadOnly
String Property STATE_END 		= "Ending" AutoReadOnly

; ------------------------------------------------------- ;
; --- Thread Status                                   --- ;
; ------------------------------------------------------- ;

int Property STATUS_UNDEF 	= 0 AutoReadOnly
int Property STATUS_IDLE	 	= 1 AutoReadOnly
int Property STATUS_SETUP 	= 2 AutoReadOnly
int Property STATUS_INSCENE = 3 AutoReadOnly
int Property STATUS_ENDING	= 4 AutoReadOnly

bool Property IsLocked hidden
	bool Function get()
		return GetStatus() != STATUS_IDLE
	EndFunction
EndProperty

; Every valid state will oerwrite this
; Should this ever be called, then the Thread was in an unspecified state and will be reset
int Function GetStatus()
	Fatal("Undefined Status. Resetting thread...")
	return STATUS_UNDEF
EndFunction

; ------------------------------------------------------- ;
; --- Thread Data                                     --- ;
; ------------------------------------------------------- ;

sslActorAlias[] Property ActorAlias Auto
Actor[] Property Positions Auto Hidden
Actor[] Property Submissives Auto Hidden

String _ActiveScene	              ; The currently playing Animation
String _StartScene	              ; The first animation this thread player
String[] _CustomScenes						; animation overrides (will always be used if not empty)
String[] _PrimaryScenes			      ; set of valid animations
String[] _LeadInScenes						; set of valid lead-in (intro) animations
String[] Property Scenes Hidden	  ; currently active set of animation
	String[] Function get()
		If(_CustomScenes.Length > 0)
			return _CustomScenes
		ElseIf(LeadIn)
			return _LeadInScenes
		Else
			return _PrimaryScenes
		EndIf
	EndFunction
EndProperty
float[] _BaseCoordinates
float[] _InUseCoordinates

String _ActiveStage
String[] _StageHistory

int Property FURNI_DISALLOW = 0 AutoReadOnly
int Property FURNI_ALLOW 		= 1 AutoReadOnly
int Property FURNI_PREFER 	= 2 AutoReadOnly
int _furniStatus

ReferenceAlias Property CenterAlias Auto	; the alias referencing _center
ObjectReference Property CenterRef Hidden	; shorthand for CenterAlias
	ObjectReference Function Get()
		return CenterAlias.GetReference()
	EndFunction
	Function Set(ObjectReference akNewCenter)
		CenterOnObject(akNewCenter)
	EndFunction
EndProperty

float Property StartedAt Auto Hidden
float Property TotalTime Hidden
	float Function get()
		return SexLabUtil.GetCurrentGameRealTimeEx() - StartedAt
	EndFunction
EndProperty

bool property DisableOrgasms auto hidden
bool Property AutoAdvance auto hidden
bool Property LeadIn auto hidden

String[] _ThreadTags
String[] _Hooks

; ------------------------------------------------------- ;
; --- Thread IDLE                                     --- ;
; ------------------------------------------------------- ;
;/
	An idle state from which the thread can be started
	Upone calling "Make" the thread will leap into the making state

	Every animation begins and ends in this state
/;
Auto State Unlocked
	sslThreadModel Function Make()
		GoToState(STATE_SETUP)
		return self
	EndFunction

	int Function GetStatus()
		return STATUS_IDLE
	EndFunction
EndState

sslThreadModel Function Make()
	Log("Thread is not idling", "Make()")
	return none
EndFunction

; ------------------------------------------------------- ;
; --- Thread SETUP                                    --- ;
; ------------------------------------------------------- ;
;/
	This State is being entered upon requesting the thread
	It marks the thread as blocked and allows functions to add/remove actors and configure the scene in various other ways
	it is also responsible for making sure an animation exists and sorts the actors appropriately

	Upon completion, this state will switch into the "Aniamting" State
/;

int _prepareAsyncCount
State Making
	Event OnBeginState()
		Log("Entering Setup State")
		RegisterForSingleUpdate(30.0)
	EndEvent
	Event OnUpdate()
		Fatal("Thread has timed out during setup. Resetting thread...")
	EndEvent

	int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
		If(!ActorRef)
			Fatal("Failed to add actor -- Actor is a figment of your imagination", "AddActor(NONE)")
			return -1
		ElseIf(Positions.Length >= POSITION_COUNT_MAX)
			Fatal("Failed to add actor -- Thread has reached actor limit", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		ElseIf(Positions.Find(ActorRef) != -1)
			Fatal("Failed to add actor -- They have been already added to this thread", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		int ERRC = sslActorLibrary.ValidateActorImpl(ActorRef)
		If(ERRC < 0)
			Fatal("Failed to add actor -- They are not a valid target for animation | Error Code: " + ERRC, "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		int i = Positions.Length	; Index of the new actor in array after pushing
		If(!ActorAlias[i].SetActor(ActorRef))
			Fatal("Failed to add actor -- They were unable to fill an actor alias", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		ActorAlias[i].SetVictim(IsVictim)
		ActorAlias[i].SetVoice(Voice, ForceSilent)
		Positions = PapyrusUtil.PushActor(Positions, ActorRef)
		return Positions.Find(ActorRef)
	EndFunction
	bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
		int i = 0
		While(i < ActorList.Length)
			If(AddActor(ActorList[i], ActorList[i] == VictimActor) == -1)
				return false
			EndIf
			i += 1
		EndWhile
    Log("Added " + ActorList + " to thread", "AddActors()")
		return true
	EndFunction

	Function SetScenes(String[] asScenes)
		_PrimaryScenes = SexLabRegistry.SceneExistA(asScenes)
	EndFunction
	Function ClearScenes()
		_PrimaryScenes = Utility.CreateStringArray(0)
	EndFunction
  Function SetForcedScenes(String[] asScenes)
    _CustomScenes = SexLabRegistry.SceneExistA(asScenes)
  EndFunction
	Function ClearForcedScenes()
		_CustomScenes = Utility.CreateStringArray(0)
	EndFunction
  Function SetLeadScenes(String[] asScenes)
    _LeadInScenes = SexLabRegistry.SceneExistA(asScenes)
    LeadIn = _LeadInScenes.Length > 0
  EndFunction
	Function ClearLeadInScenes()
		_LeadInScenes = Utility.CreateStringArray(0)
    LeadIn = false
	EndFunction
  Function SetStartingScene(String asFirstScene)
    If (SexLabRegistry.SceneExists(asFirstScene))
      _StartScene = asFirstScene
    EndIf
  EndFunction

	Function DisableLeadIn(bool disabling = true)
		LeadIn = !disabling
	EndFunction
	Function SetFurnitureStatus(int aiStatus)
		_furniStatus = PapyrusUtil.ClampInt(aiStatus, FURNI_DISALLOW, FURNI_PREFER)
	EndFunction

	Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
		CenterAlias.ForceRefTo(CenterOn)
	EndFunction

  sslThreadController Function StartThread()
		UnregisterForUpdate()
    ; Validate Actors
		Positions = PapyrusUtil.RemoveActor(Positions, none)
		If(Positions.Length < 1 || Positions.Length >= POSITION_COUNT_MAX)
			Fatal("Failed to start Thread -- No valid actors available for animation")
			return none
		EndIf
		; Validate Animations
		_CustomScenes = SexLabRegistry.ValidateScenesA(_CustomScenes, Positions, "", Submissives)
		If(_CustomScenes.Length)
			If(LeadIn)
				Log("LeadIn detected on custom Animations. Disabling LeadIn")
				LeadIn = false
			EndIf
		Else  ; only validate if these arent overwritten by custom scenes
      _PrimaryScenes = SexLabRegistry.ValidateScenesA(_PrimaryScenes, Positions, "", Submissives)
			If(!_PrimaryScenes.Length)
        _PrimaryScenes = SexLabRegistry.LookupScenesA(Positions, "", Submissives, _furniStatus, CenterRef)
				If (!_PrimaryScenes.Length)
					Fatal("Failed to start Thread -- No valid animations for given actors")
					return none
				EndIf
			EndIf
			If(LeadIn)
				_LeadInScenes = SexLabRegistry.ValidateScenesA(_LeadInScenes, Positions, "", Submissives)
				If(!_LeadInScenes.Length)
					_LeadInScenes = SexLabRegistry.LookupScenesA(Positions, "LeadIn", Submissives, _furniStatus, CenterRef)
					LeadIn = _LeadInScenes.Length
				EndIf
			EndIf
		EndIf
		; Start Animation
		return StartThreadUnchecked()
	EndFunction

  sslThreadController Function StartThreadUnchecked()
		UnregisterForUpdate()
		SendThreadEvent("AnimationStarting")
		; ThreadHooks = Config.GetThreadHooks()	; TODO: Rewire this
		RunHook(Config.HOOKID_STARTING)
		If(_StartScene && Scenes.Find(_StartScene) == -1)
			AddScene(_StartScene)
		EndIf
		String[] out = new String[16]
		CenterRef = FindCenter(Scenes, _StartScene, out, _furniStatus)
		int where = out.Find("")
		If (where == -1)
			where = out.Length - 1
		EndIf
		_ActiveScene = out[Utility.RandomInt(0, where)]
		If (!_ActiveScene)
			Fatal("Failed to start Thread -- No valid animation applicable to current environment")
			return none
		ElseIf (!SexLabRegistry.SortByScene(Positions, _ActiveScene, true))
			Fatal("Failed to start Thread -- Actors arent compatible with the requested animation")
			return none
		EndIf
		GoToState(STATE_SETUP_M)
    return self as sslThreadController
  EndFunction
	
	Function EndAnimation(bool Quickly = false)
		Initialize()
	EndFunction

	int Function GetStatus()
		return STATUS_SETUP
	EndFunction
EndState

; An immediate state to disallow setting additional data while aliases process setup
State Making_M
	Event OnBeginState()
		; Send event to all local aliases and have them prepare asynch. Also finidh remaining (private) setup tasks here
		_prepareAsyncCount = 0
		; TODO: Change to HasPlayer && Config.FadeoutMode ---------v
		CenterRef.SendModEvent("SSL_PREPARE_Thread" + tid, "", HasPlayer as float)
		; TODO: Additional fade out settings

		_BaseCoordinates = GetBaseCoordinates(_ActiveScene)
		_InUseCoordinates = new float[4]	; Copy to trace back changes made by the user during scene
		_InUseCoordinates[0] = _BaseCoordinates[0]
		_InUseCoordinates[1] = _BaseCoordinates[1]
		_InUseCoordinates[2] = _BaseCoordinates[2]
		_InUseCoordinates[3] = _BaseCoordinates[3]
		SortAliasesToPositions()
		If (_CustomScenes.Length)
			_ThreadTags = SexLabRegistry.GetCommonTags(_CustomScenes)
		Else
			_ThreadTags = SexLabRegistry.GetCommonTags(_PrimaryScenes)
		EndIf
		PrepareDone()
	EndEvent

	; Invoked n times by Aliases and once by StartThreadUnchecked, then continue to next state
	Function PrepareDone()
		If(_prepareAsyncCount <= Positions.Length)
			_prepareAsyncCount += 1
			return
		ElseIf (HasPlayer)
			Config.ApplyFade()
			If(IsVictim(PlayerRef) && Config.DisablePlayer)
				AutoAdvance = true
			Else
				AutoAdvance = Config.AutoAdvance
				; Inheritance is kinda backwards
				(Self as sslThreadController).EnableHotkeys()
			EndIf
		ElseIf (Config.ShowInMap && PlayerRef.GetDistance(CenterRef) > 750)
			SetObjectiveDisplayed(0, True)
		EndIf
		GoToState(STATE_PLAYING)
		; TODO: RemoveFade should become unnecessary
		If (HasPlayer)
			Config.RemoveFade()
		EndIf
	EndFunction
	
	Function EndAnimation(bool Quickly = false)
		_prepareAsyncCount = -2147483648
		Initialize()
	EndFunction

	int Function GetStatus()
		return STATUS_SETUP
	EndFunction
EndState

sslThreadController Function StartThread()
	Log("Cannot start thread outside of setup phase", "StartThread()")
	return none
EndFunction
sslThreadController Function StartThreadUnchecked()
	Log("Cannot start thread outside of setup phase", "StartThreadUnchecked()")
	return none
EndFunction
int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
	Log("Cannot add an actor to a locked thread", "AddActor()")
	return -1
EndFunction
bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
	Log("Cannot add a list of actors to a locked thread", "AddActors()")
	return false
EndFunction
Function SetScenes(String[] asScenes)
	Log("Primary scenes can only be set during setup", "SetScenes()")
EndFunction
Function ClearScenes()
	Log("Primary scenes can only be cleared during setup", "SetScenes()")
EndFunction
Function SetForcedScenes(String[] asScenes)
	Log("Forced animations can only be set during setup", "SetForcedScenes()")
EndFunction
Function ClearForcedScenes()
	Log("Forced animations can only be cleared during setup", "SetForcedScenes()")
EndFunction
Function SetLeadScenes(String[] asScenes)
	Log("LeadIn animations can only be set during setup", "SetLeadScenes()")
EndFunction
Function ClearLeadInScenes()
	Log("LeadIn animations can only be cleared during setup", "SetLeadScenes()")
EndFunction
Function SetStartingScene(String asFirstAnimation)
	Log("Start animations can only be set during setup", "SetStartingScene()")
EndFunction
Function DisableLeadIn(bool disabling = true)
	Log("Lead in status can only be set during setup", "DisableLeadIn()")
EndFunction
Function SetFurnitureStatus(int aiStatus)
	Log("Furniture status can only be set during setup", "SetFurnitureStatus()")
EndFunction

; Given an array of Scenes, select some valid Scene within the array, using the currently selected center as comparable
; If all scenes are incompatible with the selected center, will return a new center. asOut contains all available animations
ObjectReference Function FindCenter(String[] asSceneIDs, String asScenePrefered, String[] asOut, int aiFurniStatus) native
float[] Function GetBaseCoordinates(String asScene) native

; --- Legacy

Function SetAnimations(sslBaseAnimation[] AnimationList)
	If (AnimationList.Length && AnimationList.Find(none) == -1)
		SetScenes(sslBaseAnimation.AsSceneIDs(AnimationList))
	EndIf
EndFunction
Function ClearAnimations()
	ClearScenes()
EndFunction
Function SetForcedAnimations(sslBaseAnimation[] AnimationList)
	If (AnimationList.Length && AnimationList.Find(none) == -1)
		SetForcedScenes(sslBaseAnimation.AsSceneIDs(AnimationList))
	EndIf
EndFunction
Function ClearForcedAnimations()
	ClearForcedScenes()
EndFunction
Function SetLeadAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList.Length && AnimationList.Find(none) == -1
		SetLeadScenes(sslBaseAnimation.AsSceneIDs(AnimationList))
	endIf
EndFunction
Function ClearLeadAnimations()
	ClearLeadInScenes()
EndFunction
Function SetStartingAnimation(sslBaseAnimation FirstAnimation)
	SetStartingScene(FirstAnimation.PROXY_ID)
EndFunction
Function DisableBedUse(bool disabling = true)
	SetFurnitureStatus((!disabling) as int)
EndFunction
Function SetBedFlag(int flag = 0)
	SetFurnitureStatus(flag + 1)	; New Status is [0, 2] instead of [-1, 1]
EndFunction
Function SetBedding(int flag = 0)
	SetBedFlag(flag)
EndFunction

; ------------------------------------------------------- ;
; --- Thread PLAYING                                  --- ;
; ------------------------------------------------------- ;
;/
	The state manages actors and the animation itself from start to finish
	By this time, most Scene information is read only
/;

float _StageTimer			; Additional past default time, to delay the completion of a stage
float[] _CustomTimers	; Custom set of timers to use for this animation
float[] Property Timers hidden
	{In use timer set of the active scene}
	float[] Function Get()
		If (_CustomTimers.Length)
			return _CustomTimers
		ElseIf (LeadIn)
			return Config.StageTimerLeadIn
		ElseIf (IsAggressive)
			return Config.StageTimerAggr
		EndIf
		return Config.StageTimer
	EndFunction
	Function Set(float[] value)
		_CustomTimers = value
	EndFunction
EndProperty

State Animating
	Event OnBeginState()
		SetFurnitureIgnored(true)
		StartedAt = SexLabUtil.GetCurrentGameRealTimeEx()
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int[] sex_ = SexLabRegistry.GetPositionSexA(_ActiveScene)
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].ReadyActor(strips_[i], sex_[i])
			i += 1
		EndWhile
		SendModEvent("SSL_READY_Thread" + tid)
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, "")
		_StageHistory = new String[1]
		_StageHistory[0] = _ActiveStage
		ReStartTimer()
		SendThreadEvent("AnimationStart")
		If(LeadIn)
			SendThreadEvent("LeadInStart")
		EndIf
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
	EndEvent

	bool Function ResetScene(String asNewScene)
		If (!SexLabRegistry.SortByScene(Positions, asNewScene, true))
			Log("Cannot reset scene. New Scene is not compatible with given positions")
			return false
		EndIf
		RecordSkills()
		SetBonuses()
		UnregisterForUpdate()
		SortAliasesToPositions()
		_ActiveScene = asNewScene
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int[] sex_ = SexLabRegistry.GetPositionSexA(_ActiveScene)
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].TryLock()
			ActorAlias[i].ResetPosition(strips_[i], sex_[i])
			i += 1
		EndWhile
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, "")
		_StageHistory = new String[1]
		_StageHistory[0] = _ActiveStage
		ReStartTimer()
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
		return true
	EndFunction

	Function PlayNext(int aiNextBranch)
		UnregisterForUpdate()
		SendThreadEvent("StageEnd")
		RunHook(Config.HOOKID_STAGEEND)
		String newStage = SexLabRegistry.BranchTo(_ActiveScene, _ActiveStage, aiNextBranch)
		If (!newStage)
			Log("Invalid branch or previous stage is sink, ending scene")
			If(LeadIn)
				EndLeadIn()
			Else
				EndAnimation()
			EndIf
			If(!LeadIn && !DisableOrgasms)
				; COMEBACK: Check the Orgasm behavior in use
				SendThreadEvent("OrgasmEnd")
			EndIF
			return
		ElseIf(!Leadin && !DisableOrgasms && SexLabRegistry.GetNodeType(_ActiveScene, newStage) == 2)
			; End of animation orgasm

			; COMEBACK: Check the Orgasm behavior in use
			SendThreadEvent("OrgasmStart")
			TriggerOrgasm()
		EndIf
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].TryLock()
			ActorAlias[i].UpdateNext(strips_[i])
			i += 1
		EndWhile
		PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, _ActiveStage)
		_StageHistory = PapyrusUtil.PushString(_StageHistory, _ActiveStage)
		ReStartTimer()
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
	EndFunction
	Function ResetStage()
		GoToStage(_StageHistory.Length)
	EndFunction

	; NOTE: This here counts from 1 instead of 0
	Function GoToStage(int ToStage)
		If (ToStage <= 1)
			ResetScene(_ActiveScene)
		ElseIf(ToStage > _StageHistory.Length)
			PlayNext(0)
		Else
			; Dont need to bother about stripping here as were playing an already played stage
			int i = 0
			While (i < Positions.Length)
				ActorAlias[i].TryLock()
				i += 1
			EndWhile
			_ActiveStage = _StageHistory[ToStage - 1]
			PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, _ActiveStage)
			ReStartTimer()
			SendThreadEvent("StageStart")
			RunHook(Config.HOOKID_STAGESTART)
		EndIf
	EndFunction

	Function ReStartTimer()
		If (!AutoAdvance)
			return
		EndIf
		_StageTimer = 0
		RegisterForSingleUpdate(GetTimer())
	EndFunction

	Function UpdateTimer(float AddSeconds = 0.0)
		If (AddSeconds < 0)
			_StageTimer = 0
			return
		EndIf
		_StageTimer += AddSeconds
	EndFunction

	Function SetTimers(float[] SetTimers)
		If (!SetTimers.Length)
			Log("SetTimers() - Empty timers given.", "ERROR")
			return
		EndIf
		Timers = SetTimers
	EndFunction

	float Function GetTimer()
		float timer = SexLabRegistry.GetFixedLength(_ActiveScene, _ActiveStage)
		If (!timer)
			return GetStageTimer(0)
		EndIf
		return timer
	EndFunction

	float Function GetStageTimer(int maxstage)
		int stageIdx = _StageHistory.Find(_ActiveStage)
		int lastTimerIdx = Timers.Length - 1
		If (stageIdx <= lastTimerIdx)
			return Timers[stageIdx]
		EndIf
		return Timers[lastTimerIdx]
	Endfunction
	
	Event OnUpdate()
		If (_StageTimer > 0)
			RegisterForSingleUpdate(_StageTimer)
			_StageTimer = 0
			return
		EndIf
		GoToStage(_StageHistory.Length + 1)
	EndEvent

	Function TriggerOrgasm()
		SendModEvent("SSL_ORGASM_Thread" + tid)
	EndFunction

	Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
		If (!CenterOn)
			return
		ElseIf(CenterOn != CenterRef)
			ObjectReference oldCenter = CenterRef
			SetFurnitureIgnored(false)
			CenterAlias.ForceRefTo(CenterOn)
			If (!SexLabRegistry.IsCompatibleCenter(_ActiveScene, CenterOn))
				String[] out = new String[16]
				CenterRef = FindCenter(Scenes, _StartScene, out, _furniStatus)
				int where = out.Find("")
				If (where == 0)	; New center has no available scenes closeby, pick new ones
					If (Config.HasThreadControl(Self) && InvalidCenterMsg.Show() == 1)
						Log("Cannot relocate center, end scene by player choice", "CenterOnObject")
						EndAnimation()
					Else
						Log("Cannot relocate center, cancel relocation", "CenterOnObject")
						CenterAlias.ForceRefTo(oldCenter)
					EndIf
					return
				Else
					If (where == -1)
						where = out.Length - 1
					EndIf
					_ActiveScene = out[Utility.RandomInt(0, where)]
				EndIf
			EndIf
			SetFurnitureIgnored(true)
		EndIf
		If(resync)
			RealignActors()
			SendThreadEvent("ActorsRelocated")
		EndIf
	EndFunction

	Function RealignActors()
		PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, _ActiveStage)
	EndFunction

	Function ChangeActorsEx(Actor[] akNewPositions, Actor[] akSubmissives)
		akNewPositions = PapyrusUtil.RemoveActor(akNewPositions, none)
		If(akNewPositions.Length == Positions.Length)	; Equality
			int i = 0
			While(i < akNewPositions.Length)
				If(Positions.Find(akNewPositions[i]) == -1)
					i = akNewPositions.Length
				EndIf
				i += 1
			EndWhile
			If(i == akNewPositions.Length)
				return
			EndIf
		ElseIf(!akNewPositions.Length || akNewPositions.Length > POSITION_COUNT_MAX)
			return
		EndIf
		UnregisterforUpdate()
		SendThreadEvent("ActorChangeStart")
		int i = 0
		While(i < Positions.Length)	; Remove actors that are no longer used
			int w = akNewPositions.Find(Positions[i])
			If(w == -1)
				ActorAlias[i].Initialize()
			EndIf
			i += 1
		EndWhile
		int n = 0
		While(n < akNewPositions.Length)
			int w = Positions.Find(akNewPositions[n])
			If(w == -1)
				sslActorAlias slot = PickAlias(akNewPositions[n])
				If(slot.SetActor(akNewPositions[n]))	; Add actor and move to playing state
					slot.OnDoPrepare("", "", 0.0, none)	; TODO: Validate args here to not do pathing stuffz
				EndIf
			EndIf
			n += 1
		EndWhile
		Submissives = akSubmissives
		; Validate Animations or get new
		If (!SexLabRegistry.ValidateSceneA(_ActiveScene, Positions, "", Submissives))
			ClearForcedScenes()
			_PrimaryScenes = SexLabRegistry.LookupScenesA(Positions, "", Submissives, _furniStatus, CenterRef)
			If (!_PrimaryScenes.Length)
				Log("Changing scene actors but no animation for new positions")
				EndAnimation()
				return
			ElseIf (LeadIn)
				_LeadInScenes = SexLabRegistry.LookupScenesA(Positions, "LeadIn", Submissives, _furniStatus, CenterRef)
				If (!_LeadInScenes.Length)
					EndLeadIn()
					return
				EndIf
			EndIf
			ResetScene(Scenes[Utility.RandomInt(0, Scenes.Length - 1)])
		Else
			ResetScene(_ActiveScene)
		EndIf
		SendThreadEvent("ActorChangeEnd")
	EndFunction
	Function PrepareDone()
		; Avoid the log since we expect this to be invoked when ChangeActorEx() is called
	EndFunction

	function EndLeadIn()
		If (!LeadIn)
			return
		EndIf
		LeadIn = false
		UnregisterForUpdate()
		SendThreadEvent("LeadInEnd")
		SkillXP[0] = SkillXP[0] + (TotalTime / 10.0)
		If (!ResetScene(Scenes[Utility.RandomInt(0, Scenes.Length - 1)]))
			EndAnimation()
		EndIf
	endFunction

	Function Initialize()
		EndAnimation()
	EndFunction
	Function EndAnimation(bool Quickly = false)
		GoToState(STATE_END)
	EndFunction

	int Function GetStatus()
		return STATUS_INSCENE
	EndFunction

	Event OnEndState()
		UnregisterForUpdate()
		SetFurnitureIgnored(false)
	EndEvent
EndState

Function RealignActors()
	Log("Cannot align actors outside the playing state", "RealignActors()")
EndFunction
Function ChangeActorsEx(Actor[] akNewPositions, Actor[] akSubmissives)
	Log("Cannot change positions outside the playing state", "ChangeActorsEx()")
EndFunction
bool Function ResetScene(String asNewScene)
	Log("Cannot reset outside the playing state", "ResetScene()")
	return false
EndFunction
Function ResetStage()
	Log("Cannot reset outside the playing state", "ResetStage()")
EndFunction
Function EndLeadIn()
	Log("Cannot end leadin outside the playing state", "EndLeadIn()")
EndFunction
Function PlayNext(int aiNextBranch)
	Log("Cannot play next branch outside the playing state", "EndLeadIn()")
EndFunction
Function GoToStage(int ToStage)
	Log("Cannot change playing branch outside the playing state", "GoToStage()")
EndFunction
Function TriggerOrgasm()
	Log("Cannot trigger orgasms outside the playing state", "TriggerOrgasm()")
EndFunction
Function ReStartTimer()
	Log("Cannot re/start timers outside of playing state", "ReStartTimer()")
EndFunction
Function UpdateTimer(float AddSeconds = 0.0)
	Log("Cannot upate timers outside of playing state", "UpdateTimer()")
EndFunction
Function SetTimers(float[] SetTimers)
	Log("Cannot set timers outside of playing state", "SetTimers()")
EndFunction
float Function GetTimer()
	Log("timers are not defined outside of playing state", "GetTimer()")
	return 0.0
EndFunction
float Function GetStageTimer(int maxstage)
	Log("timers are not defined outside of playing state", "GetStageTimer()")
	return 0.0
Endfunction

Function ChangeActors(Actor[] NewPositions)
	Actor[] argSub = PapyrusUtil.ActorArray(NewPositions.Length)
	int i = 0
	int ii = 0
	While (i < Submissives.Length)
		If (NewPositions.Find(Submissives[i]) > -1)
			argSub[ii] = Submissives[i]
			ii += 1
		EndIf
		i += 1
	EndWhile
	ChangeActorsEx(NewPositions, PapyrusUtil.RemoveActor(argSub, none))
EndFunction
Function PlayStageAnimations()
	RealignActors()
EndFunction

; Set location for all positions on CenterAlias, incl offset, and play their respected animation. Positions are assumed to be sorted by scene
String Function PlaceAndPlay(Actor[] akPositions, float[] afCoordinates, String asSceneID, String asStageID) native

; ------------------------------------------------------- ;
; --- Thread END                                      --- ;
; ------------------------------------------------------- ;
;/
	The end state has 2 purposes:
	1) Reset all actors in the animation to their pre-animation status
	2) Reset the thread after a short buffer duration back to the idle state
/;

State Ending
	Event OnBeginState()
		RegisterForSingleUpdateGameTime(0.1)	; 18s with TimeScale = 20
		DisableHotkeys()
		; Config.DisableThreadControl(self as sslThreadController)	; TODO: this should be moved to sslThreadController
		If(IsObjectiveDisplayed(0))
			SetObjectiveDisplayed(0, False)
		EndIf
		RecordSkills()
		int i = 0
		While(i < Positions.Length)
			ActorAlias[i].DoStatistics()
			ActorAlias[i].Clear()
			i += 1
		EndWhile
		SendThreadEvent("AnimationEnding")
		SendThreadEvent("AnimationEnd")
		RunHook(Config.HOOKID_END)
	EndEvent

	Event OnUpdateGameTime()
		Initialize()
	EndEvent
	Event OnEndState()
		UnregisterForUpdateGameTime()
		Log("Returning to thread pool...")
	EndEvent

	int Function GetStatus()
		return STATUS_ENDING
	EndFunction
EndState

; ------------------------------------------------------- ;
; --- State Independent                               --- ;
; ------------------------------------------------------- ;
;/
	Functions whichs behavior is not dependent on the currently playing state
/;

Function AddScene(String asSceneID)
	If (!asSceneID || !SexLabRegistry.SceneExists(asSceneID))
		return
	EndIf
	If(_CustomScenes.Length > 0)
		_CustomScenes = PapyrusUtil.PushString(_CustomScenes, _StartScene)
	ElseIf(LeadIn)
		_LeadInScenes = PapyrusUtil.PushString(_LeadInScenes, _StartScene)
	Else
		_PrimaryScenes = PapyrusUtil.PushString(_PrimaryScenes, _StartScene)
	EndIf
EndFunction

sslActorAlias Function PickAlias(Actor ActorRef)
	int i
	while i < 5
		if ActorAlias[i].ForceRefIfEmpty(ActorRef)
			return ActorAlias[i]
		endIf
		i += 1
	endWhile
	return none
EndFunction

Function SetFurnitureIgnored(bool disabling = true)
	If (CenterRef as Actor)
		return
	EndIf
	CenterRef.SetDestroyed(disabling)
	CenterRef.BlockActivation(disabling)
	CenterRef.SetNoFavorAllowed(disabling)
EndFunction

; ------------------------------------------------------- ;
; --- Function Declarations                           --- ;
; ------------------------------------------------------- ;
;/
	Most functions used to manage animations have a unique behavior depending on the currently active state
	The below block defines such functions. All of these functions will be overwritten for every state where there
	is reason to implement them
/;

Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
	Log("Invalid State", "CenterOnObject()")
EndFunction
Function EndAnimation(bool Quickly = false)
	Log("Invalid state", "EndAnimation()")
EndFunction
Function PrepareDone()
	Log("Invalid state", "PrepareDone()")
EndFunction

; The following functions are implemented by sslThreadController.psc
Function DisableHotkeys()
	Log("Invalid function call", "DisableHotkeys()")
EndFunction

; ------------------------------------------------------- ;
; --- Actor Alias                                     --- ;
; ------------------------------------------------------- ;
;/
	QoL accessors for the specified Actor
/;

int Function FindSlot(Actor ActorRef)
	return Positions.Find(ActorRef)
EndFunction

sslActorAlias Function ActorAlias(Actor ActorRef)
	return PositionAlias(FindSlot(ActorRef))
EndFunction

sslActorAlias Function PositionAlias(int Position)
	If(Position < 0 || Position >= Positions.Length)
		return none
	EndIf
	return ActorAlias[Position]
EndFunction

Function SortAliasesToPositions()
	sslActorAlias[] newAliases = new sslActorAlias[5]
	int i = 0
	While (i < ActorAlias.Length)
		Actor it = ActorAlias[i].GetActorReference()
		If (it)
			int where = Positions.Find(it)
			newAliases[where] = ActorAlias[i]
		EndIf
		i += 1
	EndWhile
	ActorAlias = newAliases
EndFunction

; ------------------------------------------------------- ;
; --- Thread Hooks & Events                           --- ;
; ------------------------------------------------------- ;
;/
	Interface to send blocking and non blocking hooks
/;

Function RunHook(int aiHookID)
	RunHook(aiHookID)
EndFunction

Function SendThreadEvent(string HookEvent)
	Log(HookEvent, "Event Hook")
	SetupThreadEvent(HookEvent)
	int i = _Hooks.Length
	while i
		i -= 1
		SetupThreadEvent(HookEvent + "_" + _Hooks[i])
	endWhile
EndFunction
Function SetupThreadEvent(string HookEvent)
	int eid = ModEvent.Create("Hook"+HookEvent)
	if eid
		ModEvent.PushInt(eid, thread_id)
		ModEvent.PushBool(eid, HasPlayer)
		ModEvent.Send(eid)
	endIf
	SendModEvent(HookEvent, thread_id)
EndFunction

; ------------------------------------------------------- ;
; --- Initialization                                  --- ;
; ------------------------------------------------------- ;
;/
	Functions for re/initialization
/;

; This is only called once when the Framework is first initialized
Function SetTID(int id)
	thread_id = id
	Log(self, "Setup")
	int i = 0
	While(i < ActorAlias.Length)
		ActorAlias[i].Setup()
		i += 1
	EndWhile
	Config = Game.GetFormFromFile(0xD62, "SexLab.esm") as sslSystemConfig
	DoNothingPackage = Game.GetFormFromFile(0xE50E, "SexLab.esm") as Package
	InvalidCenterMsg = Game.GetFormFromFile(0xAA6A6, "SexLab.esm") as Message
	Initialize()
EndFunction

; Reset this thread to base status
Function Initialize()
	UnregisterForUpdate()
	DisableHotkeys()
	Config.DisableThreadControl(self as sslThreadController)
	int i = 0
	While(i < ActorAlias.Length)
		ActorAlias[i].Initialize()
		i += 1
	EndWhile
	CenterAlias.TryToClear()
	; TODO: reset public variables here
	; Enter thread selection pool
	GoToState("Unlocked")
EndFunction

; ------------------------------------------------------- ;
; --- Logging                                         --- ;
; ------------------------------------------------------- ;
;/
	Generic logging utility
/;

Function Log(string msg, string src = "")
	msg = "Thread[" + thread_id + "] " + src + " - " + msg
	Debug.Trace("SEXLAB - " + msg)
	If(Config.DebugMode)
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	EndIf
EndFunction

Function LogConsole(String asReport)
	String msg = "Thread[" + thread_id + "] - " + asReport
	SexLabUtil.PrintConsole(msg)
	Debug.Trace("SEXLAB - " + msg)
EndFunction

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.")
EndFunction

Function Fatal(string msg, string src = "", bool halt = true)
	msg = "Thread["+thread_id+"] - FATAL - " + src + " - " + msg
	Debug.TraceStack("SEXLAB - " + msg)
	SexLabUtil.PrintConsole(msg)
	If(Config.DebugMode)
		Debug.TraceUser("SexLabDebug", msg)
	EndIf
	If (halt)
		Initialize()
	EndIf
EndFunction


; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;								██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗							;
;								██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝							;
;								██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 							;
;								██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  							;
;								███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   							;
;								╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   							;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

sslThreadLibrary Property ThreadLib
	sslThreadLibrary Function Get()
		return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslThreadLibrary
	EndFunction
	Function Set(sslThreadLibrary aSet)
	EndFunction
EndProperty
sslAnimationSlots Property AnimSlots
	sslAnimationSlots Function Get()
		return Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationSlots
	EndFunction
	Function Set(sslAnimationSlots aSet)
	EndFunction
EndProperty
sslCreatureAnimationSlots Property CreatureSlots
	sslCreatureAnimationSlots Function Get()
		return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationSlots
	EndFunction
	Function Set(sslCreatureAnimationSlots aSet)
	EndFunction
EndProperty
sslActorLibrary property ActorLib
  sslActorLibrary Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorLibrary
  EndFunction
  Function Set(sslActorLibrary aSet)
  EndFunction
EndProperty

int Property ActorCount
	int Function Get()
		return Positions.Length
	EndFunction
EndProperty
Actor[] property Victims
	Actor[] Function Get()
		GetAllVictims()
	EndFunction
EndProperty

int[] Property Genders
	int[] Function Get()
		int[] g = ActorLib.GetGendersAll(Positions)
		int[] ret = new int[4]
		ret[0] = PapyrusUtil.CountInt(g, 0)
		ret[1] = PapyrusUtil.CountInt(g, 1)
		ret[2] = PapyrusUtil.CountInt(g, 2)
		ret[3] = PapyrusUtil.CountInt(g, 3)
		return ret
	endFunction
	Function Set(int[] aSet)
	EndFunction
EndProperty
int Property Males hidden
	int Function get()
		return Genders[0]
	EndFunction
EndProperty
int Property Females hidden
	int Function get()
		return Genders[1]
	EndFunction
EndProperty

bool Property HasCreature hidden
	bool Function get()
		return Creatures > 0
	EndFunction
EndProperty
int Property Creatures hidden
	int Function get()
		return Genders[2] + Genders[3]
	EndFunction
EndProperty
int Property MaleCreatures hidden
	int Function get()
		return Genders[2]
	EndFunction
EndProperty
int Property FemaleCreatures hidden
	int Function get()
		return Genders[3]
	EndFunction
EndProperty

int Property Stage
	int Function Get()
		return _StageHistory.Length
	EndFunction
	Function Set(int aSet)
		return GoToStage(aSet)
	EndFunction
EndProperty

string[] Property AnimEvents
	String[] Function Get()
		return SexLabRegistry.GetAnimationEventA(_ActiveScene, _ActiveStage)
	EndFunction
EndProperty

string Property AdjustKey
	String Function Get()
		return "Global"
	EndFunction
EndProperty

bool[] Property IsType	; [0] IsAggressive, [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty, [6] HadVaginal, [7] HadAnal, [8] HadOral
	bool[] Function Get()
		bool[] ret = new bool [9]
		ret[0] = IsAggressive
		ret[1] = IsVaginal
		ret[2] = IsAnal
		ret[3] = IsOral
		ret[4] = IsLoving
		ret[5] = IsDirty
		int i = 0
		While (i < _StageHistory.Length - 1)
			ret[6] = ret[6] || SexlabRegistry.IsStageTag(_ActiveScene, _StageHistory[i], "Vaginal")
			ret[7] = ret[7] || SexlabRegistry.IsStageTag(_ActiveScene, _StageHistory[i], "Anal")
			ret[8] = ret[8] || SexlabRegistry.IsStageTag(_ActiveScene, _StageHistory[i], "Oral")
			i += 1
		EndWhile
		return ret
	EndFUnction
	Function Set(bool[] aSet)
	EndFunction
EndProperty
bool Property IsVaginal hidden
	bool Function get()
		return SexlabRegistry.IsSceneTag(_ActiveScene, "Vaginal")
	endfunction
	Function set(bool value)
	EndFunction
EndProperty
bool Property IsAnal hidden
	bool Function get()
		return SexlabRegistry.IsSceneTag(_ActiveScene, "Anal")
	endfunction
	Function set(bool value)
	EndFunction
EndProperty
bool Property IsOral hidden
	bool Function get()
		return SexlabRegistry.IsSceneTag(_ActiveScene, "Oral")
	endfunction
	Function set(bool value)
	EndFunction
EndProperty
bool Property IsLoving hidden
	bool Function get()
		return SexlabRegistry.IsSceneTag(_ActiveScene, "Loving")
	endfunction
	Function set(bool value)
	EndFunction
EndProperty
bool Property IsDirty hidden
	bool Function get()
		return SexlabRegistry.IsSceneTag(_ActiveScene, "Dirty") || SexlabRegistry.IsSceneTag(_ActiveScene, "Forced")
	endfunction
	Function set(bool value)
	EndFunction
EndProperty

int[] Property BedStatus
	int[] Function Get()
		int[] ret = new int[2]
		ret[0] = _furniStatus - 1
		ret[1] = BedTypeID
	EndFunction
	Function Set(int[] aSet)
	EndFunction
EndProperty
ObjectReference Property BedRef
	ObjectReference Function Get()
		If (sslThreadLibrary.IsBed(CenterRef))
			return CenterRef
		EndIf
		return none
	EndFunction
	Function Set(ObjectReference aSet)
	EndFunction
EndProperty
int Property BedTypeID hidden
	int Function get()
		return sslThreadLibrary.GetBedTypeImpl(CenterRef)
	EndFunction
EndProperty
bool Property UsingBed hidden
	bool Function get()
		return BedRef != none
	EndFunction
EndProperty
bool Property UsingBedRoll hidden
	bool Function get()
		return BedTypeID == 1
	EndFunction
EndProperty
bool Property UsingSingleBed hidden
	bool Function get()
		return BedTypeID == 2
	EndFunction
EndProperty
bool Property UsingDoubleBed hidden
	bool Function get()
		return BedTypeID == 3
	EndFunction
EndProperty
bool Property UseNPCBed hidden
	bool Function get()
		int NPCBed = Config.NPCBed
		return NPCBed == 2 || (NPCBed == 1 && (Utility.RandomInt(0, 1) as bool))
	EndFunction
EndProperty

Actor property VictimRef hidden
	Actor Function Get()
		Actor[] vics = GetAllVictims()
		If(vics.Length)
			return vics[0]
		EndIf
		return none
	EndFunction
	Function Set(Actor ActorRef)
		sslActorAlias vic = ActorAlias(ActorRef)
		If(!vic)
			return
		EndIf
		vic.SetVictim(true)
	EndFunction
EndProperty

float[] Property CenterLocation
	float[] Function Get()
		float[] ret = new float[6]
		ret[0] = CenterRef.GetPositionX()
		ret[1] = CenterRef.GetPositionY()
		ret[2] = CenterRef.GetPositionZ()
		ret[3] = CenterRef.GetAngleX()
		ret[4] = CenterRef.GetAngleY()
		ret[5] = CenterRef.GetAngleZ()
		return ret
	EndFunction
	Function Set(float[] aSet)
	EndFunction
EndProperty

sslBaseAnimation Property Animation
	sslBaseAnimation Function Get()
		return sslBaseAnimation.GetOrSetBaseAnimation(_ActiveScene, none, true) as sslBaseAnimation
	EndFunction
	Function Set(sslBaseAnimation aSet)
		SetAnimationImpl(aSet)
	EndFunction
EndProperty
sslBaseAnimation Property StartingAnimation
	sslBaseAnimation Function Get()
		return sslBaseAnimation.GetOrSetBaseAnimation(_StartScene, none, true) as sslBaseAnimation
	EndFunction
	Function Set(sslBaseAnimation aSet)
		SetStartingAnimation(aSet)
	EndFunction
EndProperty
sslBaseAnimation[] Property Animations hidden
	sslBaseAnimation[] Function get()
		return sslBaseAnimation.AsBaseAnimations(Scenes)
	EndFunction
EndProperty

Function AddAnimation(sslBaseAnimation AddAnimation, bool ForceTo = false)
	If(!AddAnimation)
		return
	EndIf
	AddScene(AddAnimation.PROXY_ID)
EndFunction
Function SetAnimation(int aid = -1)
	if aid < 0 || aid >= Animations.Length
		aid = Utility.RandomInt(0, (Animations.Length - 1))
	endIf
	SetAnimationImpl(Animations[aid])
EndFunction
Function SetAnimationImpl(sslBaseAnimation akAnimation)
	ResetScene(akAnimation.PROXY_ID)
EndFunction

bool function AddTag(string Tag)
	return false
endFunction
bool function RemoveTag(string Tag)
	return false
endFunction
bool function ToggleTag(string Tag)
	return false
endFunction
bool function AddTagConditional(string Tag, bool AddTag)
	return false
endFunction
String[] Function AddString(string[] ArrayValues, string ToAdd, bool RemoveDupes = true)
	if ToAdd != ""
		string[] Output = ArrayValues
		if !RemoveDupes || Output.length < 1
			return PapyrusUtil.PushString(Output, ToAdd)
		elseIf Output.Find(ToAdd) == -1
			int i = Output.Find("")
			if i != -1
				Output[i] = ToAdd
			else
				Output = PapyrusUtil.PushString(Output, ToAdd)
			endIf
		endIf
		return Output
	endIf
	return ArrayValues
EndFunction

Sound Property SoundFX
	Sound Function Get()
		return none
	EndFunction
	Function Set(Sound aSet)
	EndFunction
EndProperty

function SyncEvent(int id, float WaitTime)
endFunction
function SyncEventDone(int id)
endFunction
Function SyncDone()
EndFunction
Function RefreshDone()
EndFunction
Function ResetDone()
EndFunction
Function StripDone()
EndFunction
Function OrgasmDone()
EndFunction
Function StartupDone()
EndFunction

sslBaseAnimation[] Function GetForcedAnimations()
	return sslBaseAnimation.AsBaseAnimations(_CustomScenes)
EndFunction
sslBaseAnimation[] Function GetAnimations()
	return sslBaseAnimation.AsBaseAnimations(_PrimaryScenes)
EndFunction
sslBaseAnimation[] Function GetLeadAnimations()
	return sslBaseAnimation.AsBaseAnimations(_LeadInScenes)
EndFunction

int Function GetHighestPresentRelationshipRank(Actor ActorRef)
	if Positions.Length <= 1
		If(ActorRef == Positions[0])
			return 0
		Else
			return ActorRef.GetRelationshipRank(Positions[0])
		EndIf
	endIf
	int out = -4 ; lowest possible
	int i = Positions.Length
	while i > 0 && out < 4
		i -= 1
		if Positions[i] != ActorRef
			int rank = ActorRef.GetRelationshipRank(Positions[i])
			if rank > out
				out = rank
			endIf
		endIf
	endWhile
	return out
EndFunction

int Function GetLowestPresentRelationshipRank(Actor ActorRef)
	if Positions.Length <= 1
		If(ActorRef == Positions[0])
			return 0
		Else
			return ActorRef.GetRelationshipRank(Positions[0])
		EndIf
	endIf
	int out = 4 ; highest possible
	int i = Positions.Length
	while i > 0 && out > -4
		i -= 1
		if Positions[i] != ActorRef
			int rank = ActorRef.GetRelationshipRank(Positions[i])
			if rank < out
				out = rank
			endIf
		endIf
	endWhile
	return out
EndFunction

string Function GetHook()
	return _Hooks[0]
EndFunction

Function Action(string FireState)
endfunction
Function FireAction()
EndFunction
Function EndAction()
EndFunction

Function InitShares()
EndFunction

int Function FilterAnimations()
	LogRedundant("FilterAnimations")
	return 0
EndFunction

Function HookAnimationStarting()
EndFunction
Function HookStageStart()
EndFunction
Function HookStageEnd()
EndFunction
Function HookAnimationEnd()
EndFunction

Function SendTrackedEvent(Actor ActorRef, string Hook = "")
	sslThreadLibrary.SendTrackingEvents(ActorRef, Hook, thread_id)
EndFunction
Function SetupActorEvent(Actor ActorRef, string Callback)
	sslThreadLibrary.MakeTrackingEvent(ActorRef, Callback, thread_id)
EndFunction

Function UpdateAdjustKey()
EndFunction

String Function Key(string Callback)
	return ""	; "SSL_" + thread_id + "_" + Callback
EndFunction
Function QuickEvent(string Callback)
	; ModEvent.Send(ModEvent.Create(Key(Callback)))
endfunction

Race Property CreatureRef
	Race Function Get()
		Keyword npc = Keyword.GetKeyword("ActorTypeNPC")
		int i = 0
		While(i < Positions.Length)
			If(!Positions[i].HasKeyword(npc))
				return Positions[i].GetRace()
			EndIf
			i += 1
		EndWhile
		return none
	EndFunction
	Function Set(Race aSet)
	EndFunction
EndProperty

float[] Property RealTime
	float[] Function Get()
		float[] ret = new float[1]
		ret[0] = SexLabUtil.GetCurrentGameRealTimeEx()
		return ret
	EndFunction
	Function Set(float[] aSet)
	EndFunction
EndProperty

bool Property FastEnd auto hidden

Actor Function GetPlayer()
	return PlayerRef
EndFunction
Actor Function GetVictim()
	return VictimRef
EndFunction
float Function GetTime()
	return StartedAt
endfunction

Function RemoveFade()
	if HasPlayer
		Config.RemoveFade()
	endIf
EndFunction
Function ApplyFade()
	if HasPlayer
		Config.ApplyFade()
	endIf
EndFunction

bool Function IsPlayerActor(Actor ActorRef)
	return ActorRef == PlayerRef
EndFunction
bool Function IsPlayerPosition(int Position)
	return Position == Positions.Find(PlayerRef)
EndFunction
int Function GetPosition(Actor ActorRef)
	return Positions.Find(ActorRef)
EndFunction
int Function GetPlayerPosition()
	return Positions.Find(PlayerRef)
EndFunction

Function DisableRagdollEnd(Actor ActorRef = none, bool disabling = true)
EndFunction

Function SetStartAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState", float PlayTime = 0.1)
EndFunction
Function SetEndAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState")
EndFunction

bool Function CenterOnBed(bool AskPlayer = true, float Radius = 750.0)
	bool InStart = GetStatus() == STATUS_SETUP
	If (_furniStatus == FURNI_DISALLOW)
		return false
	ElseIf (InStart && !HasPlayer && Config.NPCBed == 0 || HasPlayer && Config.AskBed == 0)
		return false
	EndIf
	int i = 0
	While (i < Positions.Length)
		ObjectReference furni = Positions[i].GetFurnitureReference()
		If (furni)
			int BedType = sslThreadLibrary.GetBedTypeImpl(furni)
			If (BedType > 0 && (Positions.Length < 4 || BedType != 2))
				CenterOnObject(furni)
				return true
			EndIf
		EndIf
		i += 1
	EndWhile
 	ObjectReference FoundBed
	Radius *= _furniStatus	; Double radius is preferring a furniture
	If (HasPlayer)
		If (!InStart || Config.AskBed == 1 || (Config.AskBed == 2 && (!IsVictim(PlayerRef) || UseNPCBed)))
			FoundBed = ThreadLib.GetNearestUnusedBed(PlayerRef, Radius)
			AskPlayer = AskPlayer && (!InStart || !(Config.AskBed == 2 && IsVictim(PlayerRef)))
		EndIf
	ElseIf (UseNPCBed)
		FoundBed = ThreadLib.GetNearestUnusedBed(Positions[0], Radius)
	EndIf
	; Found a bed AND EITHER forced use OR don't care about players choice OR or player approved
	if FoundBed && (_furniStatus == FURNI_PREFER || (!AskPlayer || (AskPlayer && (Config.UseBed.Show() as bool))))
		CenterOnObject(FoundBed)
		return true
	endIf
	return false
EndFunction

Function CenterOnCoords(float LocX = 0.0, float LocY = 0.0, float LocZ = 0.0, float RotX = 0.0, float RotY = 0.0, float RotZ = 0.0, bool resync = true)
	Form xMarker = Game.GetForm(0x3B)
	ObjectReference new_center = CenterRef.PlaceAtMe(xMarker)
	new_center.SetAngle(RotX, RotY, RotZ)
	new_center.SetPosition(LocX, LocY, LocZ)
	CenterOnObject(new_center, resync)
EndFunction

; COMEBACK: This is used in the MoveScene function (child script). Idk if theres any point or nah
int Function AreUsingFurniture(Actor[] ActorList)	
	int i = 0
	While(i < ActorList.Length)
		ObjectReference ref = ActorList[i].GetFurnitureReference()
		If(ref)
			return sslThreadLibrary.GetBedTypeImpl(ref)
		EndIf
		i += 1
	EndWhile
	return -1
EndFunction

; Function used to find and set the currently active Timer array
; Timers property now does this explicetly on each access
Function ResolveTimers()
EndFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

; ------------------------------------------------------- ;
; --- Actor Setup                                     --- ;
; ------------------------------------------------------- ;

bool Function UseLimitedStrip()
	bool limitedstrip = HasTag("LimitedStrip")
	bool LeadInNoBody = !(Config.StripLeadInMale[2] || Config.StripLeadInFemale[2])
	return LeadIn && (!LeadInNoBody || limitedstrip) || \
	Config.LimitedStrip && (limitedstrip || (!LeadInNoBody && AnimSlots.CountTag(Animations, "Kissing,Foreplay,LeadIn,LimitedStrip") == Animations.Length))
EndFunction

; Actor Overrides
Function SetStrip(Actor ActorRef, bool[] StripSlots)
	if StripSlots && StripSlots.Length == 33
		ActorAlias(ActorRef).OverrideStrip(StripSlots)
	else
		Log("Malformed StripSlots bool[] passed, must be 33 length bool array, "+StripSlots.Length+" given", "ERROR")
	endIf
EndFunction

Function SetNoStripping(Actor ActorRef)
	if ActorRef
		bool[] StripSlots = new bool[33]
		sslActorAlias Slot = ActorAlias(ActorRef)
		if Slot
			Slot.OverrideStrip(StripSlots)
			Slot.DoUndress = false
		endIf
	endIf
EndFunction

Function DisableUndressAnimation(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoUndress = !disabling
	else
		ActorAlias[0].DoUndress = !disabling
		ActorAlias[1].DoUndress = !disabling
		ActorAlias[2].DoUndress = !disabling
		ActorAlias[3].DoUndress = !disabling
		ActorAlias[4].DoUndress = !disabling
	endIf
EndFunction

Function DisableRedress(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoRedress = !disabling
	else
		ActorAlias[0].DoRedress = !disabling
		ActorAlias[1].DoRedress = !disabling
		ActorAlias[2].DoRedress = !disabling
		ActorAlias[3].DoRedress = !disabling
		ActorAlias[4].DoRedress = !disabling
	endIf
EndFunction

Function DisablePathToCenter(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DisablePathToCenter(disabling)
	else
		ActorAlias[0].DisablePathToCenter(disabling)
		ActorAlias[1].DisablePathToCenter(disabling)
		ActorAlias[2].DisablePathToCenter(disabling)
		ActorAlias[3].DisablePathToCenter(disabling)
		ActorAlias[4].DisablePathToCenter(disabling)
	endIf
EndFunction

Function ForcePathToCenter(Actor ActorRef = none, bool forced = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).ForcePathToCenter(forced)
	else
		ActorAlias[0].ForcePathToCenter(forced)
		ActorAlias[1].ForcePathToCenter(forced)
		ActorAlias[2].ForcePathToCenter(forced)
		ActorAlias[3].ForcePathToCenter(forced)
		ActorAlias[4].ForcePathToCenter(forced)
	endIf
EndFunction

; Orgasms
Function DisableAllOrgasms(bool OrgasmsDisabled = true)
	DisableOrgasms = OrgasmsDisabled
EndFunction

Function DisableOrgasm(Actor ActorRef, bool OrgasmDisabled = true)
	if ActorRef
		ActorAlias(ActorRef).DisableOrgasm(OrgasmDisabled)
	endIf
EndFunction

bool Function IsOrgasmAllowed(Actor ActorRef)
	return ActorAlias(ActorRef).IsOrgasmAllowed()
EndFunction

bool Function NeedsOrgasm(Actor ActorRef)
	return ActorAlias(ActorRef).NeedsOrgasm()
EndFunction

Function ForceOrgasm(Actor ActorRef)
	if ActorRef
		ActorAlias(ActorRef).DoOrgasm(true)
	endIf
EndFunction

; Voice
Function SetVoice(Actor ActorRef, sslBaseVoice Voice, bool ForceSilent = false)
	ActorAlias(ActorRef).SetVoice(Voice, ForceSilent)
EndFunction

sslBaseVoice Function GetVoice(Actor ActorRef)
	return ActorAlias(ActorRef).GetVoice()
EndFunction

; Actor Strapons
bool Function IsUsingStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).IsUsingStrapon()
EndFunction

Function EquipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).EquipStrapon()
EndFunction

Function UnequipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).UnequipStrapon()
EndFunction

Function SetStrapon(Actor ActorRef, Form ToStrapon)
	ActorAlias(ActorRef).SetStrapon(ToStrapon)
endfunction

Form Function GetStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).GetStrapon()
endfunction

; Expressions
Function SetExpression(Actor ActorRef, sslBaseExpression Expression)
	ActorAlias(ActorRef).SetExpression(Expression)
EndFunction
sslBaseExpression Function GetExpression(Actor ActorRef)
	return ActorAlias(ActorRef).GetExpression()
EndFunction

; Enjoyment/Pain
int Function GetEnjoyment(Actor ActorRef)
	return ActorAlias(ActorRef).GetEnjoyment()
EndFunction
int Function GetPain(Actor ActorRef)
	return ActorAlias(ActorRef).GetPain()
EndFunction

; Actor Information
bool Function PregnancyRisk(Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
	return ActorRef && HasActor(ActorRef) && ActorCount > 1 && ActorAlias(ActorRef).PregnancyRisk() \
		&& (Males > 0 || (AllowFemaleCum && Females > 1 && Config.AllowFFCum) || (AllowCreatureCum && MaleCreatures > 0))
EndFunction

; ------------------------------------------------------- ;
; --- Skill System			                              --- ;
; ------------------------------------------------------- ;

float[] Property SkillBonus auto hidden ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd
float[] Property SkillXP auto hidden    ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd
float SkillTime

Function RecordSkills()
	float TimeNow = SexLabUtil.GetCurrentGameRealTimeEx()
	float xp = ((TimeNow - SkillTime) / 8.0)
	if xp >= 0.5
		if IsType[1]
			SkillXP[1] = SkillXP[1] + xp
		endIf
		if IsType[2]
			SkillXP[2] = SkillXP[2] + xp
		endIf
		if IsType[3]
			SkillXP[3] = SkillXP[3] + xp
		endIf
		if IsType[4]
			SkillXP[4] = SkillXP[4] + xp
		endIf
		if IsType[5]
			SkillXP[5] = SkillXP[5] + xp
		endIf
	endIf
	SkillTime = TimeNow
endfunction

Function SetBonuses()
	SkillBonus[0] = SkillXP[0]
	if IsType[1]
		SkillBonus[1] = SkillXP[1]
	endIf
	if IsType[2]
		SkillBonus[2] = SkillXP[2]
	endIf
	if IsType[3]
		SkillBonus[3] = SkillXP[3]
	endIf
	if IsType[4]
		SkillBonus[4] = SkillXP[4]
	endIf
	if IsType[5]
		SkillBonus[5] = SkillXP[5]
	endIf
EndFunction
