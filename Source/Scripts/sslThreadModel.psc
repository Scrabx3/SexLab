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

Function StopAnimation()
	EndAnimation()
EndFunction

float Function GetTime()
	return StartedAt
endfunction
float Function GetTimeTotal()
	return TotalTime
EndFunction

String[] Function GetStageHistory()
	return PapyrusUtil.RemoveString(_StageHistory, "%")
EndFunction
int Function GetStageHistoryLength()
	return _StageHistory.Length
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

Actor[] Function GetPositions()
	return PapyrusUtil.RemoveActor(Positions, none)
EndFunction

int Function GetNthPositionSex(int n)
	If (n < 0 || n >= Positions.Length)
		return 0
	EndIf
	return ActorAlias[n].GetSex()
EndFunction

int[] Function GetPositionSexes()
	int[] ret = Utility.CreateIntArray(Positions.Length)
	int i = 0
	While (i < ret.Length)
		ret[i] = ActorAlias[i].GetSex()
		i += 1
	EndWhile
	return ret
EndFunction

Function SetCustomStrip(Actor akActor, int aiSlots, bool abWeapon, bool abApplyNow)
	sslActorAlias it = ActorAlias(akActor)
	If (!it)
		return
	EndIf
	it.SetStripping(aiSlots, abWeapon, abApplyNow)
EndFunction

bool Function IsUndressAnimationAllowed(Actor akActor)
	sslActorAlias it = ActorAlias(akActor)
	return it && it.DoUndress
EndFunction
Function SetIsUndressAnimationAllowed(Actor akActor, bool abAllowed)
	sslActorAlias it = ActorAlias(akActor)
	If (!it)
		return
	EndIf
	it.DisableStripAnimation(!abAllowed)
EndFunction

bool Function IsRedressAllowed(Actor akActor)
	sslActorAlias it = ActorAlias(akActor)
	return it && it.DoRedress
EndFunction
Function SetIsRedressAllowed(Actor akActor, bool abAllowed)
	sslActorAlias it = ActorAlias(akActor)
	If (!it)
		return
	EndIf
	it.SetAllowRedress(abAllowed)
EndFunction

Function SetPathingFlag(Actor akActor, int aiPathingFlag)
	sslActorAlias it = ActorAlias(akActor)
	If (!it)
		return
	EndIf
	it.SetPathing(aiPathingFlag)
EndFunction

; Voice
Function SetVoice(Actor ActorRef, sslBaseVoice Voice, bool ForceSilent = false)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return
	EndIf
	ref.SetVoice(Voice, ForceSilent)
EndFunction

sslBaseVoice Function GetVoice(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return none
	EndIf
	return ref.GetVoice()
EndFunction

; Expressions
Function SetExpression(Actor ActorRef, sslBaseExpression Expression)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return
	EndIf
	ref.SetExpression(Expression)
EndFunction

sslBaseExpression Function GetExpression(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return none
	EndIf
	return ref.GetExpression()
EndFunction

; Orgasms
int Function GetEnjoyment(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return 0
	EndIf
	return ref.GetEnjoyment()
EndFunction

Function DisableOrgasm(Actor ActorRef, bool OrgasmDisabled = true)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return
	EndIf
	return ref.DisableOrgasm(OrgasmDisabled)
EndFunction

bool Function IsOrgasmAllowed(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return false
	EndIf
	return ref.IsOrgasmAllowed()
EndFunction

Function ForceOrgasm(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return none
	EndIf
	return ref.DoOrgasm(true)
EndFunction

Actor[] Function CanBeImpregnated(Actor akActor,  bool abAllowFutaImpregnation, bool abFutaCanPregnate, bool abCreatureCanPregnate)
	Actor[] ret
	sslActorAlias ref = ActorAlias(akActor)
	If (!ref)
		return ret
	EndIf
	int refsex = ref.GetSex()
	If !(refsex == 1 || abAllowFutaImpregnation && refsex == 2)
		return ret
	EndIf
	ret = new Actor[5]
	String[] orgasmStages = SexLabRegistry.GetClimaxStages(_ActiveScene)
	int i = 0
	While (i < orgasmStages.Length)
		If (_StageHistory.Find(orgasmStages[i]) > -1 && SexLabRegistry.IsStageTag(_ActiveScene, orgasmStages[i], "~Grinding, ~Vaginal, Penetration"))
			int[] orgP = SexLabRegistry.GetClimaxingActors(_ActiveScene, orgasmStages[i])
			int n = 0
			While (n < orgP.Length)
				If (Positions[n] != akActor && ActorAlias[n].IsOrgasmAllowed())
					int orgSex = ActorAlias[n].GetSex()
					If (orgSex == 0 || (abFutaCanPregnate && orgSex == 2) || (abCreatureCanPregnate && orgSex == 3))
						ret[n] = Positions[n]
					EndIf
				EndIf
				n += 1
			EndWhile
		EndIf
		i += 1
	EndWhile
	return PapyrusUtil.RemoveActor(ret, none)
EndFunction

; Actor Strapons

bool Function IsUsingStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).IsUsingStrapon()
EndFunction

Function SetStrapon(Actor ActorRef, Form ToStrapon)
	ActorAlias(ActorRef).SetStrapon(ToStrapon)
endfunction

Form Function GetStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).GetStrapon()
endfunction

; ------------------------------------------------------- ;
; --- Submission                                      --- ;
; ------------------------------------------------------- ;
;/
	Functions for consent interpretation and to view and manipulate the submissive flag for individual actors
/;

bool Function IsConsent()
	return !HasContext("Aggressive")
EndFunction

Function SetConsent(bool abIsConsent)
	If (abIsConsent)
		RemoveContext("Aggressive")
	Else
		AddContext("Aggressive")
	EndIf
EndFunction

Actor[] Function GetSubmissives()
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

Function SetIsSubmissive(Actor akActor, bool abIsSubmissive)
	sslActorAlias it = ActorAlias(akActor)
	If (!it)
		return
	EndIf
	it.SetVictim(abIsSubmissive)
EndFunction

bool Function GetSubmissive(Actor akActor)
	sslActorAlias it = ActorAlias(akActor)
	return it && it.IsVictim()
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
	return _ThreadTags.Length && _ThreadTags.Find(Tag) > -1
EndFunction

bool Function HasSceneTag(String Tag)
	return SexLabRegistry.IsSceneTag(_ActiveScene, Tag)
EndFunction
bool Function IsVaginal()
	return HasSceneTag("Vaginal")
EndFunction
bool Function IsAnal()
	return HasSceneTag("Anal")
EndFunction
bool Function IsOral()
	return HasSceneTag("Oral")
EndFunction

bool Function HasStageTag(String Tag)
	return SexLabRegistry.IsStageTag(_ActiveScene, _ActiveStage, Tag)
EndFunction

String[] Function GetTags()
	return PapyrusUtil.ClearEmpty(_ThreadTags)
EndFunction

bool Function HasContext(String asTag)
	return _ContextTags.Length && _ContextTags.Find(asTag)
EndFunction

Function AddContext(String asContext)
	If (_ContextTags.Length && _ContextTags.Find(asContext) > -1)
		return
	EndIf
	_ContextTags = PapyrusUtil.PushString(_ContextTags, asContext)
EndFunction
Function RemoveContext(String asContext)
	_ContextTags = PapyrusUtil.RemoveString(_ContextTags, asContext)
EndFunction

String[] Function AddContextExImpl(String[] asOldContext, String asContext) native
Function AddContextEx(String asContext)
	_ContextTags = AddContextExImpl(_ContextTags, asContext)
EndFunction

bool Function IsLeadIn()
	return LeadIn
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

int Property Stage Hidden
	int Function Get()
		return _StageHistory.Length
	EndFunction
	Function Set(int aSet)
		return GoToStage(aSet)
	EndFunction
EndProperty

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

bool Property AutoAdvance auto hidden
bool Property LeadIn auto hidden

String[] _ThreadTags
String[] _ContextTags
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
	bool Function AddActorsA(Actor[] ActorList, Actor[] akVictims)
		int i = 0
		While(i < ActorList.Length)
			If(AddActor(ActorList[i], akVictims.Find(ActorList[i]) > -1) == -1)
				return false
			EndIf
			i += 1
		EndWhile
    Log("Added " + ActorList + " to thread", "AddActorsA()")
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
		If (CenterOn)
			CenterAlias.ForceRefTo(CenterOn)
		Else
			CenterAlias.Clear()
		EndIf
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
		Actor[] submissives = GetSubmissives()
		_CustomScenes = SexLabRegistry.ValidateScenesA(_CustomScenes, Positions, "", submissives)
		If(_CustomScenes.Length)
			If(LeadIn)
				Log("LeadIn detected on custom Animations. Disabling LeadIn")
				LeadIn = false
			EndIf
		Else  ; only validate if these arent overwritten by custom scenes
      _PrimaryScenes = SexLabRegistry.ValidateScenesA(_PrimaryScenes, Positions, "", submissives)
			If(!_PrimaryScenes.Length)
        _PrimaryScenes = SexLabRegistry.LookupScenesA(Positions, "", submissives, _furniStatus, CenterRef)
				If (!_PrimaryScenes.Length)
					Fatal("Failed to start Thread -- No valid animations for given actors")
					return none
				EndIf
			EndIf
			If(LeadIn)
				_LeadInScenes = SexLabRegistry.ValidateScenesA(_LeadInScenes, Positions, "", submissives)
				LeadIn = _LeadInScenes.Length
			EndIf
		EndIf
		; Start Animation
		ShuffleScenes(Scenes, _StartScene)
		String[] out = new String[16]
		ObjectReference new_center = FindCenter(Scenes, out, _BaseCoordinates, _furniStatus)
		If (!new_center || out[0] == "")
			Fatal("Failed to start Thread -- Unable to locate a center compatible with given scenes")
			return none
		EndIf
		CenterRef = new_center
		_ActiveScene = out[GetActiveIdx(out)]
		If (!SexLabRegistry.SortBySceneA(Positions, submissives, _ActiveScene, true))
			Fatal("Failed to start Thread -- Cannot sort actors to active scene")
			return none
		EndIf
		GoToState(STATE_SETUP_M)
		Log("Starting thread with active scene: " + _ActiveScene)
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
		; Event to all active aliases, resync via PrepareDone() to continue startup
		_prepareAsyncCount = 0
		bool useFading = HasPlayer && sslSystemConfig.GetSettingInt("iUseFade") > 0
		CenterRef.SendModEvent("SSL_PREPARE_Thread" + tid, "", useFading as float)
		SendThreadEvent("AnimationStarting")
		RunHook(Config.HOOKID_STARTING)
		If (useFading)
			; Utility.Wait(0.5)
			Config.ApplyFade()
		EndIf
		; Base coordinates are first set in FindCenter() above
		ApplySceneOffset(_ActiveScene, _BaseCoordinates)
		_InUseCoordinates[0] = _BaseCoordinates[0]
		_InUseCoordinates[1] = _BaseCoordinates[1]
		_InUseCoordinates[2] = _BaseCoordinates[2]
		_InUseCoordinates[3] = _BaseCoordinates[3]
		SortAliasesToPositions()
		PrepareDone()
		If (_CustomScenes.Length)
			_ThreadTags = SexLabRegistry.GetCommonTags(_CustomScenes)
		Else
			_ThreadTags = SexLabRegistry.GetCommonTags(_PrimaryScenes)
		EndIf
	EndEvent

	; Invoked n times by Aliases and once by StartThread, then continue to next state
	Function PrepareDone()
		If (_prepareAsyncCount < Positions.Length)
			_prepareAsyncCount += 1
			Log("Prepare done called " + _prepareAsyncCount + "/" + (Positions.Length + 1) + " times")
			return
		ElseIf (HasPlayer)
			If(IsVictim(PlayerRef) && Config.DisablePlayer)
				AutoAdvance = true
			Else
				AutoAdvance = Config.AutoAdvance
				; Inheritance is kinda backwards
				Config.GetThreadControl(self as sslThreadController)
			EndIf
		Else
			AutoAdvance = true
			If (Config.ShowInMap && PlayerRef.GetDistance(CenterRef) > 750)
				SetObjectiveDisplayed(0, True)
			EndIf
		EndIf
		Log("Prepare completed, entering playing state")
		GoToState(STATE_PLAYING)
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
int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
	Log("Cannot add an actor to a locked thread", "AddActor()")
	return -1
EndFunction
bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
	Log("Cannot add a list of actors to a locked thread", "AddActors()")
	return false
EndFunction
bool Function AddActorsA(Actor[] akActors, Actor[] akVictims)
	Log("Cannot add a list of actors to a locked thread", "AddActorsA()")
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

; Validate center alias OR find a valid center in close proximity to some actor in the thread
; asOutScene will contain all with the center valid scenes, afOutCoordinates the base coordinates to play the scene at
; return a valid center reference or null if no center could be found
ObjectReference Function FindCenter(String[] asScenes, String[] asOutScenes, float[] afOutCoordinates, int aiFurnitureStatus) native
; Check if the given center has a valid offset for the given scene and update afOutScenes with the new coordinates
bool Function UpdateBaseCoordinates(String asScene, float[] afBaseOut) native
Function ApplySceneOffset(String asScene, float[] afBaseOut) native
Function ShuffleScenes(String[] asScenes, String asStart) native

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

float Property ANIMATING_UPDATE_INTERVAL = 0.5 AutoReadOnly
int _animationSyncCount

bool _SceneEndClimax	; If a (legacy) climax has been triggered
float _StageTimer			; timer for the current stage
float _SFXTimer				; so long until new SFX effect
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
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int[] sex_ = SexLabRegistry.GetPositionSexA(_ActiveScene)
		int[] schlongs_ = SexLabRegistry.GetSchlongAngleA(_ActiveScene, _ActiveStage)
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].ReadyActor(strips_[i], sex_[i], schlongs_[i])
			i += 1
		EndWhile
		_SFXTimer = Config.SFXDelay
		_animationSyncCount = 0;
		SendModEvent("SSL_READY_Thread" + tid)
		StartedAt = SexLabUtil.GetCurrentGameRealTimeEx()
		AnimationStart()
		RegisterSFX(Positions)
	EndEvent
	Function AnimationStart()
		If (_animationSyncCount < Positions.Length)
			_animationSyncCount += 1
			Log("AnimationStart called " + _animationSyncCount + "/" + (Positions.Length + 1) + " times")
			return
		EndIf
		Log("AnimationStart fully setup, begin animating")
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, "")
		_StageHistory = new String[1]
		_StageHistory[0] = _ActiveStage
		SendThreadEvent("AnimationStart")
		If(LeadIn)
			SendThreadEvent("LeadInStart")
		EndIf
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
		ReStartTimer()
	EndFunction

	bool Function ResetScene(String asNewScene)
		If (asNewScene != _ActiveScene)
			If (!SexLabRegistry.SortBySceneA(Positions, GetSubmissives(), asNewScene, true))
				Log("Cannot reset scene. New Scene is not compatible with given positions")
				return false
			ElseIf (!UpdateBaseCoordinates(asNewScene, _BaseCoordinates))
				Log("Cannot reset scene. Unable to find valid coordinates")
				int i = 0
				While (i < Positions.Length)
					Positions[i] = ActorAlias[i].GetReference() as Actor
					i += 1
				EndWhile
				return false
			EndIf
			_InUseCoordinates[0] = _BaseCoordinates[0]
			_InUseCoordinates[1] = _BaseCoordinates[1]
			_InUseCoordinates[2] = _BaseCoordinates[2]
			_InUseCoordinates[3] = _BaseCoordinates[3]
			AddExperience(Positions, _ActiveScene, _StageHistory)
		EndIf
		UnregisterForUpdate()
		SortAliasesToPositions()
		_ActiveScene = asNewScene
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int[] sex_ = SexLabRegistry.GetPositionSexA(_ActiveScene)
		int[] schlongs_ = SexLabRegistry.GetSchlongAngleA(_ActiveScene, _ActiveStage)
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].TryLock()
			ActorAlias[i].ResetPosition(strips_[i], sex_[i], schlongs_[i])
			i += 1
		EndWhile
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, "")
		_StageHistory = new String[1]
		_StageHistory[0] = _ActiveStage
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
		ReStartTimer()
		return true
	EndFunction

	bool Function PlayNext(int aiNextBranch)
		UnregisterForUpdate()
		SendThreadEvent("StageEnd")
		RunHook(Config.HOOKID_STAGEEND)
		String newStage = SexLabRegistry.BranchTo(_ActiveScene, _ActiveStage, aiNextBranch)
		return PlayNextImpl(newStage)
	EndFunction
	Function PlayNextImpl(String asNewStage)
		If (!asNewStage)
			Log("Invalid branch or previous stage is sink, ending scene")
			If(LeadIn)
				EndLeadIn()
			Else
				EndAnimation()
			EndIf
		ElseIf(!Leadin)
			int ctype = sslSystemConfig.GetSettingInt("iClimaxType")
			If (ctype == Config.CLIMAXTYPE_LEGACY && SexLabRegistry.GetNodeType(_ActiveScene, asNewStage) == 2)
				; End of animation climax
				SendThreadEvent("OrgasmStart")
				_SceneEndClimax = true
				TriggerOrgasm()
			ElseIf (ctype == Config.CLIMAXTYPE_SCENE)
				; Scene embedded climax
				int[] cactors = SexLabRegistry.GetClimaxingActors(_ActiveScene, asNewStage)
				int i = 0
				While (i < cactors.Length)
					ActorAlias[cactors[i]].DoOrgasm()
					i += 1
				EndWhile
			; Else
				; External climax
			EndIf
		EndIf
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].TryLock()
			ActorAlias[i].UpdateNext(strips_[i])
			i += 1
		EndWhile
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, asNewStage)
		_StageHistory = PapyrusUtil.PushString(_StageHistory, _ActiveStage)
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
		ReStartTimer()
	EndFunction
	Function TriggerOrgasm()
		SendModEvent("SSL_ORGASM_Thread" + tid)
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
			SendThreadEvent("StageStart")
			RunHook(Config.HOOKID_STAGESTART)
			ReStartTimer()
		EndIf
	EndFunction
	Function BranchTo(int aiNextBranch)
		PlayNext(aiNextBranch)
	EndFunction
	Function SkipTo(String asNextStage)
		PlayNextImpl(asNextStage)
	EndFunction

	Function ReStartTimer()
		_StageTimer = GetTimer()
		RegisterForSingleUpdate(ANIMATING_UPDATE_INTERVAL)
	EndFunction

	Function UpdateTimer(float AddSeconds = 0.0)
		_StageTimer += AddSeconds
		AutoAdvance = true
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
		If (AutoAdvance)
			_StageTimer -= ANIMATING_UPDATE_INTERVAL
			If (_StageTimer <= 0)
				; IDEA: Randomize branching..?
				GoToStage(_StageHistory.Length + 1)
				return
			EndIf
		EndIf
		If (_SFXTimer > 0)
			_SFXTimer -= ANIMATING_UPDATE_INTERVAL
		Else
			int sfxtype = GetSFXType()
			Sound sfx = Config.GetSFXSound(sfxtype)
			; MiscUtil.PrintConsole("[SLP+] Getting SFX Sound " + type + " -> Obj = " + sfx)
			If (sfx)
				sfx.Play(CenterRef)
			EndIf
			_SFXTimer = Utility.RandomFloat(0.9, 1.3) * Config.SFXDelay
			If (_SFXTimer < 0.8)
				_SFXTimer = 0.8
			EndIf
		EndIf
		RegisterForSingleUpdate(ANIMATING_UPDATE_INTERVAL)
	EndEvent

	Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
		If (!CenterOn)
			return
		EndIf
		ObjectReference oldCenter = CenterRef
		SetFurnitureIgnored(false)
		CenterAlias.ForceRefTo(CenterOn)
		If (!UpdateBaseCoordinates(_ActiveScene, _BaseCoordinates))
			String[] out = new String[64]
			ObjectReference newCenter = FindCenter(Scenes, out, _BaseCoordinates, _furniStatus)
			If (!newCenter || out[0] == "")	; New center has no available scenes closeby, pick new ones
				If (Config.HasThreadControl(Self) && InvalidCenterMsg.Show() == 1)
					Log("Cannot relocate center, end scene by player choice", "CenterOnObject")
					EndAnimation()
				Else
					Log("Cannot relocate center, cancel relocation", "CenterOnObject")
					CenterAlias.ForceRefTo(oldCenter)
					SetFurnitureIgnored(true)
				EndIf
				return
			EndIf
			CenterAlias.ForceRefTo(newCenter)
			If (_ActiveScene != out[0])
				_ActiveScene = out[0]
				SexLabRegistry.SortBySceneA(Positions, GetSubmissives(), _ActiveScene, true)
			EndIf
			ApplySceneOffset(_ActiveScene, _BaseCoordinates)
		EndIf
		_InUseCoordinates[0] = _BaseCoordinates[0]
		_InUseCoordinates[1] = _BaseCoordinates[1]
		_InUseCoordinates[2] = _BaseCoordinates[2]
		_InUseCoordinates[3] = _BaseCoordinates[3]
		SetFurnitureIgnored(true)
		RealignActors()
		SendThreadEvent("ActorsRelocated")
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
				UpdateEncounters(Positions[i])
				Positions[i] = none
			EndIf
			i += 1
		EndWhile
		int n = 0
		While(n < akNewPositions.Length)
			int w = Positions.Find(akNewPositions[n])
			If(w == -1)
				sslActorAlias slot = PickAlias(akNewPositions[n])
				If(slot.SetActor(akNewPositions[n]))	; Add actor and move to playing state
					slot.SetVictim(akSubmissives.Find(akNewPositions[n]) > -1)
					slot.OnDoPrepare("", "", 0.0, none)
				EndIf
			EndIf
			n += 1
		EndWhile
		; Validate Animations or get new
		Positions = akNewPositions
		Actor[] sub = GetSubmissives()
		If (!SexLabRegistry.ValidateSceneA(_ActiveScene, Positions, "", sub))
			ClearForcedScenes()
			_PrimaryScenes = SexLabRegistry.LookupScenesA(Positions, "", sub, _furniStatus, CenterRef)
			If (!_PrimaryScenes.Length)
				Log("Changing scene actors but no animation for new positions")
				EndAnimation()
				return
			ElseIf (LeadIn)
				_LeadInScenes = SexLabRegistry.LookupScenesA(Positions, "LeadIn", sub, _furniStatus, CenterRef)
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
		If (!ResetScene(Scenes[Utility.RandomInt(0, Scenes.Length - 1)]))
			EndAnimation()
		EndIf
	endFunction

	Function Initialize()
		EndAnimation()
	EndFunction
	Function EndAnimation(bool Quickly = false)
		If(_SceneEndClimax)
			; Legacy Climax triggers wen the final stage begins, thus the next stage switch will
			; end the animation, invoking this function and ending the climax stage
			SendThreadEvent("OrgasmEnd")
		EndIF
		GoToState(STATE_END)
	EndFunction

	int Function GetStatus()
		return STATUS_INSCENE
	EndFunction

	Event OnEndState()
		UnregisterSFX()
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
bool Function PlayNext(int aiNextBranch)
	Log("Cannot play next branch outside the playing state", "PlayNext()")
	return false
EndFunction
Function PlayNextImpl(String asNewStage)
	Log("Cannot play next branch outside the playing state", "PlayNextImpl()")
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
Function BranchTo(int aiNextBranch)
	Log("Cannot branch to another stage while scene is not playing", "BranchTo()")
EndFunction
Function SkipTo(String asNextStage)
	Log("Cannot skip to another stage while scene is not playing", "SkipTo()")
EndFunction

Function ChangeActors(Actor[] NewPositions)
	Actor[] submissives = GetSubmissives()
	Actor[] argSub = PapyrusUtil.ActorArray(NewPositions.Length)
	int i = 0
	int ii = 0
	While (i < submissives.Length)
		If (NewPositions.Find(submissives[i]) > -1)
			argSub[ii] = submissives[i]
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
Function RePlace(Actor akActor, float[] afBaseCoordinates, String asSceneID, String asStageID, int n) native
Function UpdatePlacement(int n, sslActorAlias akAlias)
	RePlace(akAlias.GetActorReference(), _InUseCoordinates, _ActiveScene, _ActiveStage, n)
EndFunction
bool Function RegisterSFX(Actor[] akPositions) native
Function UnregisterSFX() native
int Function GetSFXType() native

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
		Config.DisableThreadControl(self as sslThreadController)
		If(IsObjectiveDisplayed(0))
			SetObjectiveDisplayed(0, False)
		EndIf
		UpdateAllEncounters()
		SendModEvent("SSL_CLEAR_Thread" + tid, "", 1.0)
		SendThreadEvent("AnimationEnding")
		SendThreadEvent("AnimationEnd")
		RunHook(Config.HOOKID_END)
		; Cant use default OnUpdate() event as the previous state could leak a registration into this one here
		; any attempt to prevent this leak without artificially slowing down the code have failed
		; 0.1 gametime = 6ig minutes = 360 ig seconds = 360 / 20 rt seconds = 18 rt seconds with default timescale
		RegisterForSingleUpdateGameTime(0.1)
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
		_CustomScenes = PapyrusUtil.PushString(_CustomScenes, asSceneID)
	ElseIf(LeadIn)
		_LeadInScenes = PapyrusUtil.PushString(_LeadInScenes, asSceneID)
	Else
		_PrimaryScenes = PapyrusUtil.PushString(_PrimaryScenes, asSceneID)
	EndIf
EndFunction

int Function GetActiveIdx(String[] asOutResult)
	If (_StartScene)
		int where = asOutResult.Find(_StartScene)
		If (where != -1)
			return where
		EndIf
	EndIf
	int emptyidx = asOutResult.Find("")
	If (emptyidx == -1) ; All scenes filled
		return Utility.RandomInt(0, asOutResult.Length - 1)
	EndIf
	return Utility.RandomInt(0, emptyidx - 1)
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

bool Function UseLimitedStrip()
	If (LeadIn)
		return true
	EndIf
	bool excplicit = HasTag("Penetration") || HasTag("DoublePenetration") || HasTag("TripplePenetration") || HasTag("Fingering") || HasTag("Fisting")
	excplicit = excplicit || HasTag("Tribadism") || HasTag("Grinding") || HasTag("Boobjob") || HasTag("Buttjob")
	return Config.LimitedStrip && !excplicit
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
Function AnimationStart()
	Log("Invalid state", "AnimationStart()")
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
	int i = 0
	While (i < ActorAlias.Length)
		Actor position = ActorAlias[i].GetReference() as Actor
		If (position)
			int inActorArray = Positions.Find(position)
			sslActorAlias tmp = ActorAlias[inActorArray]
			ActorAlias[inActorArray] = ActorAlias[i]
			ActorAlias[i] = tmp
		EndIf
		i += 1
	EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Statistics	                                    --- ;
; ------------------------------------------------------- ;
;/
	Statistics related functions
/;

; Called at the end of an active scene, shortly before its swapped or the thread ends
Function AddExperience(Actor[] akPositions, String asActiveStage, String[] asStageHistory) native
; Only call this once per actor, before positions are cleared. Only updates actors own statistics (no encounter updates)
Function UpdateStatistics(Actor akActor, Actor[] akPositions,  String asActiveScene, String[] asPlayedStages, float afTimeInThread) native
Function RequestStatisticUpdate(Actor akPosition, float afRegisteredAt)	; Called when one of the positions is cleared
	float timeregistered = SexLabUtil.GetCurrentGameRealTimeEx() - afRegisteredAt
	UpdateStatistics(akPosition, Positions, _ActiveScene, _StageHistory, timeregistered)
EndFunction

; int Property ENC_Any 			  = 0	AutoReadOnly Hidden
; int Property ENC_Victim		  = 1	AutoReadOnly Hidden
; int Property ENC_Assault	  = 2	AutoReadOnly Hidden
; int Property ENC_Submissive	= 3	AutoReadOnly Hidden
; int Property ENC_Dominant	  = 4	AutoReadOnly Hidden

Function UpdateEncounters(Actor akActor, int i = 0)
	int consent = 2 * IsConsent() as int
	bool submissive = ActorAlias(akActor).IsVictim()
	While (i < Positions.Length)
		If (Positions[i] != akActor)
			bool subB = ActorAlias[i].IsVictim()
			int type
			If (subB == submissive)
				type = 0
			ElseIf (submissive)
				type = 1 + consent
			Else
				type = 2 + consent
			EndIf
			SexLabStatistics.AddEncounter(akActor, Positions[i], type)
		EndIf
		i += 1
	EndWhile
EndFunction
Function UpdateAllEncounters()
	int i = 0
	While (i < Positions.Length)
		UpdateEncounters(Positions[i], i + 1)
		i += 1
	EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Thread Hooks & Events                           --- ;
; ------------------------------------------------------- ;
;/
	Interface to send blocking and non blocking hooks
/;

Function RunHook(int aiHookID)
	Config.RunHook(aiHookID, self)
EndFunction

Function SendThreadEvent(string HookEvent)
	Log(HookEvent, "Event Hook")
	SetupThreadEvent(HookEvent)
	int i = 0
	While (i < _Hooks.Length)
		SetupThreadEvent(HookEvent + "_" + _Hooks[i])
		i += 1
	EndWhile
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

; Only called on framework re/initialization through ThreadSlots.psc
Function SetTID(int id)
	thread_id = id
	Log(self, "Setup")
	int i = 0
	While(i < ActorAlias.Length)
		ActorAlias[i].Setup()
		i += 1
	EndWhile
	Initialize()
EndFunction

; Reset this thread to base status
Function Initialize()
	UnregisterForUpdate()
	Config.DisableThreadControl(self as sslThreadController)
	int i = 0
	While(i < ActorAlias.Length)
		ActorAlias[i].Initialize()
		i += 1
	EndWhile
	CenterAlias.TryToClear()
	Positions = PapyrusUtil.ActorArray(0)
	_ActiveScene = ""
	_StartScene = ""
	_CustomScenes = Utility.CreateStringArray(0)
	_PrimaryScenes = Utility.CreateStringArray(0)
	_LeadInScenes = Utility.CreateStringArray(0)
	_BaseCoordinates = new float[4]
	_InUseCoordinates = new float[4]
	_ActiveStage = ""
	_StageHistory = Utility.CreateStringArray(0)
	_furniStatus = FURNI_ALLOW
	StartedAt = 0.0
	AutoAdvance = true
	LeadIn = false
	_ThreadTags = Utility.CreateStringArray(0)
	_ContextTags = Utility.CreateStringArray(0)
	_Hooks = Utility.CreateStringArray(0)
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

; TODO: move functions to proper section, if needed - SLICK implementation as block for now
; ------------------------------------------------------- ;
; --- Relation & Penetration                          --- ;
; ------------------------------------------------------- ;

; TODO: fill out new properties in CK
;required for relations function
AssociationType Property SpouseAssocation Auto
Faction Property PlayerMarriedFaction Auto

string Function GetStageLabel(string _scene_, int StageNum) global
;function introduced temporarily from patched AnimStageLabel script
	If SexLabRegistry.IsSceneTag(_scene_, StageNum+"LI")
		return "LI"	;LeadIn, no penetration
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"SB")
		return "SB" ;SlowBlowjob, oral
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"FB")
		return "FB" ;FastBlowjob, oral
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"SV")
		return "SV" ;SlowVaginal
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"FV")
		return "FV" ;FastVaginal
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"SA")
		return "SA" ;SlowAnal
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"FA")
		return "FA" ;FastAnal
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"SR")
		return "SR" ;SpitRoast, oral + vag/anal
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"DP")
		return "DP" ;DoublePenetration
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"TP")
		return "TP" ;TriplePenetration
	ElseIf SexLabRegistry.IsSceneTag(_scene_, StageNum+"EN")
		return "EN" ;EndStage
	Else
		return "" ;scene not stage-labelled
	EndIf
EndFunction

int Function GetPenetrationType()
; TODO: implement by or based on SFX system
;probable mapping: 0=NoPen | 1=Oral | 2=Vaginal | 3=Anal | 4=DoubleOV | 5=DoubleOA | 6=DoubleVA | 7=Triple

	;<<<temporary implementation below>>>
	int PenType = -1
	string StageLabel = GetStageLabel(_ActiveScene, _StageHistory.Length)

	If StageLabel == ""
		return GetPenetrationTypeFallback()
	EndIf

	string PreviousStageLabel = GetStageLabel(_ActiveScene, _StageHistory.Length - 1)
	If StageLabel == "EN"
		StageLabel = PreviousStageLabel
	EndIf

	If StageLabel == "LI"
		PenType = 0
	ElseIf StageLabel == "SB" || StageLabel == "FB"
		PenType = 1
	ElseIf StageLabel == "SV" || StageLabel == "FV"
		PenType = 2
	ElseIf StageLabel == "SA" || StageLabel == "FA"
		PenType = 3
	ElseIf StageLabel == "SR"
		If IsVaginal() && !IsAnal()
			PenType = 4
		ElseIf IsAnal() && !IsVaginal()
			PenType = 5
		Else
			PenType = Utility.RandomInt(4, 5)
		EndIf
	ElseIf StageLabel == "DP"
		PenType = 6
	ElseIf StageLabel == "TP"
		PenType = 7
	EndIf

	return PenType
EndFunction

int Function GetPenetrationTypeFallback()
	;temporarily introduced; to recheck scene tags if animation has not been stage-labelled yet
	int PenType = -1
	If (HasSceneTag("LeadIn") || IsLeadIn()) || (!IsOral() && !IsVaginal() && !IsAnal())
		PenType = 0
	ElseIf IsOral() && !IsVaginal() && !IsAnal()
		PenType = 1
	ElseIf IsVaginal() && !IsOral() && !IsAnal()
		PenType = 2
	ElseIf IsAnal() && !IsOral() && !IsVaginal()
		PenType = 3
	ElseIf IsOral() && (IsVaginal() || IsAnal())
		If IsVaginal() && !IsAnal()
			PenType = 4
		ElseIf IsAnal() && !IsVaginal()
			PenType = 5
		Else
			PenType = Utility.RandomInt(4, 5)
		EndIf
	ElseIf HasSceneTag("DoublePenetration")
		PenType = 6
	ElseIf HasSceneTag("TriplePenetration")
		PenType = 7
	EndIf
	return PenType
EndFunction

float Function GetPenetrationVelocity()
; TODO: implement by or based on SFX system

	;<<<temporary implementation below>>>
	float PenVelocity = 0.0
	string StageLabel = GetStageLabel(_ActiveScene, _StageHistory.Length)
	string PreviousStageLabel = GetStageLabel(_ActiveScene, _StageHistory.Length - 1)
	bool SlowPen = False
	bool FastPen = False
	If StageLabel == "EN"
		StageLabel = PreviousStageLabel
	EndIf
	
	If StageLabel == "SB" || StageLabel == "SV" || StageLabel == "SA"
		SlowPen = True
	ElseIf StageLabel == "FB" || StageLabel == "FV" || StageLabel == "FA"
		FastPen = True
	ElseIf StageLabel == "SR" || StageLabel == "DP" || StageLabel == "TP" || (StageLabel == "" && !HasSceneTag("LeadIn") && !IsLeadIn() && (IsOral() || IsVaginal() || IsAnal()))
		If !IsConsent()
			FastPen = True
		Else
			SlowPen = True
		EndIf
	EndIf

	If SlowPen
		PenVelocity = TotalTime * 0.5
	ElseIf FastPen
		PenVelocity = TotalTime * 1
	EndIf
	If (SlowPen && PenVelocity > 60)
		PenVelocity == 60
	ElseIf (FastPen && PenVelocity > 30)
		PenVelocity == 30
	EndIf

	return PenVelocity
EndFunction

int Function GetActorPenInfo(Actor ActorRef, int PenType)
;function to-be-implemented by or based on SFX system
;primarily helpful in not relying much on positions-related code in alias script
;probable mapping: 0=NonParticipant | 1=Receiver | 2=Giver

	;<<<temporary implementation below>>>
	int ActorPenInfo = 0
	int gender = ActorAlias(ActorRef).GetSex()
	bool FemOnly = False

	If PenType > 0
		If !IsConsent()
			If !SameSexThread()
				If (IsVictim(ActorRef) && !HasSceneTag("FemDom")) || (!IsVictim(ActorRef) && HasSceneTag("FemDom"))
					ActorPenInfo = 1
				ElseIf (!IsVictim(ActorRef) && !HasSceneTag("FemDom")) || (IsVictim(ActorRef) && HasSceneTag("FemDom"))
					ActorPenInfo = 2
				EndIf
			Else
				If IsVictim(ActorRef)
					ActorPenInfo = 1
				ElseIf !IsVictim(ActorRef)
					ActorPenInfo = 2
				EndIf
			EndIf
		Else
			If !SameSexThread()
				If gender == 1 || gender == 4
					ActorPenInfo = 1
				ElseIf gender == 0 || gender == 3
					ActorPenInfo = 2
				ElseIf gender == 2
					If HasSceneTag("Anubs") && HasSceneTag("MF")
						ActorPenInfo = Utility.RandomInt(1, 2)
					Else
						ActorPenInfo = 2
					EndIf
				EndIf
			Else
				If GetPosition(ActorRef) == 0
					ActorPenInfo = 1
				Else
					ActorPenInfo = 2
				EndIf
			EndIf
		EndIf
	EndIf
	return ActorPenInfo
EndFunction

float Function GetPenetrationFactor(int PenType, int ActorPenInfo)
;a multiplcation factor for calculating strength of penetration-based effects;max return 2.7
	float PenFactor = 0.0
	float oral_giving = Utility.RandomFloat(0.35, 0.45)
	float oral_receiving = Utility.RandomFloat(0.6, 0.7)
	float vaginal_giving = Utility.RandomFloat(0.85, 1.0)
	float vaginal_receiving = Utility.RandomFloat(0.9, 1.1)
	float anal_giving = Utility.RandomFloat(0.8, 0.95)
	float anal_receiving = Utility.RandomFloat(0.95, 1.15)
	
	If ActorPenInfo > 0
		If PenType == 1
			PenFactor = oral_receiving
			If ActorPenInfo == 2
				PenFactor = oral_giving
			EndIf
		ElseIf PenType == 2
			PenFactor = vaginal_receiving
			If ActorPenInfo == 2
				PenFactor = vaginal_giving
			EndIf
		ElseIf PenType == 3
			PenFactor = anal_receiving
			If ActorPenInfo == 2
				PenFactor = anal_giving
			EndIf
		;TODO: improve conditions for ActorPenInfo == 2
		ElseIf PenType == 4
			PenFactor = oral_giving + vaginal_receiving
			If ActorPenInfo == 2
				PenFactor = Utility.RandomFloat(oral_receiving, vaginal_giving);(oral_receiving || vaginal_giving) 
			EndIf
		ElseIf PenType == 5
			PenFactor = oral_giving + anal_receiving
			If ActorPenInfo == 2
				PenFactor = Utility.RandomFloat(oral_receiving, anal_giving);(oral_receiving || anal_giving)
			EndIf
		ElseIf PenType == 6
			PenFactor = vaginal_receiving + anal_receiving
			If ActorPenInfo == 2
				PenFactor = Utility.RandomFloat(anal_giving, vaginal_giving);(vaginal_giving || anal_giving)
			EndIf
		ElseIf PenType == 7
			PenFactor = oral_giving + vaginal_receiving + anal_receiving
			If ActorPenInfo == 2
				PenFactor = Utility.RandomFloat(oral_receiving, vaginal_receiving);(oral_receiving || vaginal_giving || anal_giving)
			EndIf
		EndIf
	EndIf
	return PenFactor
EndFunction

bool Function SameSexThread()
	;still needed for determining sexuality of scene
	bool SameSexThread = False
	int MaleCount = ActorLib.CountMale(Positions)
	int FemCount = ActorLib.CountFemale(Positions)
	int FutaCount = ActorLib.CountFuta(Positions)
	int CrtMaleCount = ActorLib.CountCrtMale(Positions)
	int CrtFemaleCount = ActorLib.CountCrtFemale(Positions)
	If (Positions.Length != 1 && ((MaleCount + CrtMaleCount == Positions.Length) || (FemCount + CrtFemaleCount == Positions.Length) || (FutaCount == Positions.Length)))
		SameSexThread = True
	EndIf
	return SameSexThread
EndFunction

bool Function CrtMaleHugePP()
	bool HugePP = False
	If ActorLib.CountCrtMale(Positions) > 0
		int CreMalePos = -1
		int i = -1
		while i < Positions.Length
			if Positions[i] != None
				int gender = GetNthPositionSex(i)
				if gender == 3
					CreMalePos = i
				endIf
			endIf
		endWhile
		If CreMalePos > -1
			string CreRacekey = SexlabRegistry.GetRaceKey(Positions[CreMalePos])
			If CreRacekey ==  "Bear" || CreRacekey ==  "Chaurus" || CreRacekey ==  "ChaurusHunter" || CreRacekey ==  "ChaurusReaper" || CreRacekey ==  "Dragon" || CreRacekey ==  "DwarvenCenturion" || CreRacekey ==  "FrostAtronach" || CreRacekey ==  "Gargoyle" || CreRacekey ==  "Giant" || CreRacekey ==  "GiantSpider" || CreRacekey ==  "Horse" || CreRacekey ==  "LargeSpider" || CreRacekey ==  "Lurker" || CreRacekey ==  "Mammoth" || CreRacekey ==  "Netch" || CreRacekey ==  "Sabrecat" || CreRacekey ==  "Troll" || CreRacekey ==  "Werewolf"
				HugePP = True
			EndIf
		EndIf
	EndIf
	return HugePP
EndFunction

int Function GetConsentSubStatus()
	int ConsentSubStatus = -1
	string[] agg_tags = new string [6]
	agg_tags[0] = "Forced"
	agg_tags[1] = "Humiliation"
	agg_tags[2] = "Ryona"
	agg_tags[3] = "Amputee"
	agg_tags[4] = "Gore"
	agg_tags[5] = "Dead"
	string[] sub_tags = new string [3]
	sub_tags[0] = "Dominant"
	sub_tags[1] = "Spanking"
	sub_tags[2] = "Asphyxiation"

	If (SexlabRegistry.IsSceneTagA(_ActiveScene, sub_tags) && !SexlabRegistry.IsSceneTagA(_ActiveScene, agg_tags))
		SetConsent(True)
	EndIf

	If GetSubmissives().Length == 0
		If IsConsent()
			ConsentSubStatus = 0 ;consensual without submissive-flagged actor (usual scenes)
		Else
			ConsentSubStatus = 1 ;non-consensual without submissive-flagged actor (non-cons cons)
		EndIf
	Else
		If IsConsent()
			ConsentSubStatus = 2 ;consensual with submissive-flagged actor (cons sub-dom || cons non-cons)
		Else
			ConsentSubStatus = 3 ;non-consensual with submissive-flagged actor (non-cons vic-agg)
		EndIf
	EndIf

	return ConsentSubStatus
EndFunction

int Function GetRelationForScene(Actor ActorRef, Actor TargetRef)
	;mapping: Stranger=-2~0 | POI=1~5 | Lover=6~10 | Spouse=11~15 | LoverSpouse=16~20
	;w_agg=-2 | w_vic=-1 | <<stranger=0>>
	;W_agg=1 | w_vic=2 | <<poi=3>> | w_dom=4 | w_sub=5
	;W_agg=6 | w_vic=7 | <<lover=8>> | w_dom=9 | w_sub=10
	;W_agg=11 | w_vic=12 | <<spouse=13>> | w_dom=14 | w_sub=15
	;W_agg=16 | w_vic=17 | <<spouse+lover=18>> | w_dom=19 | w_sub=20
	int BaseRelation = 0
	int ContextRelation = 0
	int Relation = 0
	bool WithSpouse = False
	bool WithLover = False
	bool WithPOI = False ;person of interest
	int _ConsentSubStatus = GetConsentSubStatus()
	
	If ActorRef == PlayerRef
		If TargetRef.IsInFaction(PlayerMarriedFaction)
			WithSpouse = True
			BaseRelation = 13
		EndIf
	Else
		If ActorRef.HasAssociation(SpouseAssocation, TargetRef)
			WithSpouse = True
			BaseRelation = 13
		EndIf
	EndIf
	If !WithSpouse && ActorRef.GetRelationshipRank(TargetRef) >= 4
		WithLover = True
		BaseRelation = 8
	ElseIf !WithLover && !WithSpouse && (ActorRef.GetRelationshipRank(TargetRef) >= 1) && (SexLabStatistics.GetTimesMet(ActorRef, TargetRef) >= 3)
		WithPOI = True
		BaseRelation = 3
	EndIf

	If _ConsentSubStatus > 1
		If (WithSpouse || WithLover || WithPOI)
			If IsVictim(ActorRef) ;with dom
				ContextRelation = 1
			ElseIf IsVictim(TargetRef) ;with sub
				ContextRelation = 2
			EndIf
		Else
			If IsVictim(ActorRef) ;with aggressor
				ContextRelation = -2
			ElseIf IsVictim(TargetRef) ;with victim
				ContextRelation = -1
			EndIf
		EndIf
	EndIf
	Relation = BaseRelation + ContextRelation
	return Relation
EndFunction

int Function GetBestRelationForScene(Actor ActorRef)
	if Positions.Length <= 1
		return 0
	elseif Positions.Length == 2
		if(ActorRef == Positions[0])
			return GetRelationForScene(ActorRef, Positions[1])
		else
			return GetRelationForScene(ActorRef, Positions[0])
		endif
	endIf
	int ret = -2 ; lowest possible
	int i = Positions.Length
	while i > 0 && ret < 34
		i -= 1
		if Positions[i] != ActorRef
			int relation = GetRelationForScene(ActorRef, Positions[i])
			if relation >= 0 ;ensrures that lowest value is retuned for agg/vic scenes
				ret = relation
			endIf
		endIf
	endWhile
	return ret
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

sslThreadLibrary Property ThreadLib Hidden
	sslThreadLibrary Function Get()
		return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslThreadLibrary
	EndFunction
	Function Set(sslThreadLibrary aSet)
	EndFunction
EndProperty
sslAnimationSlots Property AnimSlots Hidden
	sslAnimationSlots Function Get()
		return Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationSlots
	EndFunction
	Function Set(sslAnimationSlots aSet)
	EndFunction
EndProperty
sslCreatureAnimationSlots Property CreatureSlots Hidden
	sslCreatureAnimationSlots Function Get()
		return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationSlots
	EndFunction
	Function Set(sslCreatureAnimationSlots aSet)
	EndFunction
EndProperty
sslActorLibrary property ActorLib Hidden
  sslActorLibrary Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorLibrary
  EndFunction
  Function Set(sslActorLibrary aSet)
  EndFunction
EndProperty

int Property ActorCount Hidden
	int Function Get()
		return Positions.Length
	EndFunction
EndProperty
Actor[] property Victims Hidden
	Actor[] Function Get()
		GetAllVictims()
	EndFunction
EndProperty

int[] Property Genders Hidden
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

string[] Property AnimEvents Hidden
	String[] Function Get()
		return SexLabRegistry.GetAnimationEventA(_ActiveScene, _ActiveStage)
	EndFunction
EndProperty

string Property AdjustKey Hidden
	String Function Get()
		return "Global"
	EndFunction
EndProperty

bool[] Property IsType Hidden	; [0] IsAggressive, [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty, [6] HadVaginal, [7] HadAnal, [8] HadOral
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
bool Property IsAggressive hidden
	bool Function get()
		return !IsConsent()
	endfunction
	Function set(bool value)
		SetConsent(value)
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

int[] Property BedStatus Hidden
	int[] Function Get()
		int[] ret = new int[2]
		ret[0] = _furniStatus - 1
		ret[1] = BedTypeID
	EndFunction
	Function Set(int[] aSet)
	EndFunction
EndProperty
ObjectReference Property BedRef Hidden
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
Actor[] Function GetAllVictims()
	return GetSubmissives()
EndFunction
Function SetVictim(Actor ActorRef, bool Victimize = true)
	SetIsSubmissive(ActorRef, Victimize)
EndFunction

float[] Property CenterLocation Hidden
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

sslBaseAnimation Function GetSetAnimationLegacyCast(String asScene)
	int[] sexes = SexLabRegistry.GetPositionSexA(asScene)
	If (sexes.Find(3) > -1 || sexes.Find(4) > -1)
		return CreatureSlots.GetSetAnimation(asScene)
	Else
		return AnimSlots.GetSetAnimation(asScene)
	EndIf
EndFunction
sslBaseAnimation Property Animation Hidden
	sslBaseAnimation Function Get()
		return GetSetAnimationLegacyCast(_ActiveScene)
	EndFunction
	Function Set(sslBaseAnimation aSet)
		SetAnimationImpl(aSet)
	EndFunction
EndProperty
sslBaseAnimation Property StartingAnimation Hidden
	sslBaseAnimation Function Get()
		return GetSetAnimationLegacyCast(_StartScene)
	EndFunction
	Function Set(sslBaseAnimation aSet)
		SetStartingAnimation(aSet)
	EndFunction
EndProperty
sslBaseAnimation[] Property Animations hidden
	sslBaseAnimation[] Function get()
		return GetAnimationsLegacyCast(Scenes)
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

Sound Property SoundFX Hidden
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

sslBaseAnimation[] Function GetAnimationsLegacyCast(String[] asScenes)
	sslBaseAnimation[] ret = AnimSlots.AsBaseAnimation(asScenes)
	If (!ret.Length)
		ret = CreatureSlots.AsBaseAnimation(asScenes)
	EndIf
	return ret
EndFunction
sslBaseAnimation[] Function GetForcedAnimations()
	return GetAnimationsLegacyCast(_CustomScenes)
EndFunction
sslBaseAnimation[] Function GetAnimations()
	return GetAnimationsLegacyCast(_PrimaryScenes)
EndFunction
sslBaseAnimation[] Function GetLeadAnimations()
	return GetAnimationsLegacyCast(_LeadInScenes)
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
	If (_Hooks.Length)
		return _Hooks[0]
	EndIf
	return ""
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

Race Property CreatureRef Hidden
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

float[] Property RealTime Hidden
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

bool property DisableOrgasms hidden
	bool Function Get()
		bool ret = false
		int i = 0
		While (i < ActorAlias.Length && !ret)
			ret = !ActorAlias[i].IsOrgasmAllowed()
			i += 1
		EndWhile
		return ret
	EndFunction
	Function Set(bool abDisable)
		int i = 0
		While (i < ActorAlias.Length)
			ActorAlias[i].DisableOrgasm(abDisable)
			i += 1
		EndWhile
	EndFunction
EndProperty
Function DisableAllOrgasms(bool OrgasmsDisabled = true)
	DisableOrgasms = OrgasmsDisabled
EndFunction
bool Function NeedsOrgasm(Actor ActorRef)
	return ActorAlias(ActorRef).NeedsOrgasm()
EndFunction

; These are empty funcs on alias script. Correct equipping of strapons should be internal and function autonomous
Function EquipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).EquipStrapon()
EndFunction
Function UnequipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).UnequipStrapon()
EndFunction

bool Function PregnancyRisk(Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
	return CanBeImpregnated(ActorRef, true, AllowFemaleCum, AllowCreatureCum)
EndFunction

float[] Property SkillBonus Hidden
	{[0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd}
	float[] Function Get()
		float[] ret = new float[6]
		return ret
	EndFunction
EndProperty
float[] Property SkillXP hidden
	{[0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd}
	float[] Function Get()
		float[] ret = new float[6]
		return ret
	EndFunction
EndProperty
Function SetBonuses()
EndFunction
Function RecordSkills()
	AddExperience(Positions, _ActiveScene, _StageHistory)
endfunction

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

; Enjoyment/Pain
int Function GetPain(Actor ActorRef)
	return ActorAlias(ActorRef).GetPain()
EndFunction
