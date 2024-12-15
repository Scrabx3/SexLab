ScriptName sslThreadModel extends SexLabThread Hidden
{
	Internal class for primary scene management. 
	Implements SexLabThread, builds and controls scene-flow and keeps track of scene actors

	To start a scene, please check the functions provided in the main API (SexLabFramework.psc)
	To access, read and write scene related data see sslThreadController.psc
}

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

bool Function HasPlayer()
	return HasPlayer
EndFunction
bool Function HasActor(Actor ActorRef)
	return Positions.Find(ActorRef) != -1
EndFunction

Actor[] Function GetPositions()
	return PapyrusUtil.RemoveActor(Positions, none)
EndFunction

int Function GetPositionIdx(Actor akActor)
	return Positions.Find(akActor)
EndFunction

int Function GetActorSex(Actor akActor)
	return GetNthPositionSex(GetPositionIdx(akActor))
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
Function ResetCustomStrip(Actor akActor)
	sslActorAlias it = ActorAlias(akActor)
	If (!it)
		return
	EndIf
	it.DeleteCustomStripping()
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
Function SetActorVoice(Actor akActor, String asVoice, bool abForceSilent)
	sslActorAlias ref = ActorAlias(akActor)
	If (!ref)
		return
	EndIf
	ref.SetActorVoice(asVoice, abForceSilent)
EndFunction
String Function GetActorVoice(Actor akActor)
	sslActorAlias ref = ActorAlias(akActor)
	If (!ref)
		return none
	EndIf
	return ref.GetActorVoice()
EndFunction

; Expressions
String Function GetActorExpression(Actor akActor)
	sslActorAlias ref = ActorAlias(akActor)
	If (!ref)
		return none
	EndIf
	return ref.GetActorExpression()
EndFunction

Function SetActorExpression(Actor akActor, String asExpression)
	sslActorAlias ref = ActorAlias(akActor)
	If (!ref)
		return
	EndIf
	ref.SetActorExpression(asExpression)
EndFunction

; Enjoyment
int Function GetPain(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return 0
	EndIf
	return ref.GetPain()
EndFunction

int Function GetEnjoyment(Actor ActorRef)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return 0
	EndIf
	return ref.GetEnjoyment()
EndFunction

Function AdjustPain(Actor ActorRef, int AdjustBy)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return
	EndIf
	return ref.AdjustPain(AdjustBy)
EndFunction

Function AdjustEnjoyment(Actor ActorRef, int AdjustBy)
	sslActorAlias ref = ActorAlias(ActorRef)
	If (!ref)
		return
	EndIf
	return ref.AdjustEnjoyment(AdjustBy)
EndFunction

; Orgasms
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
	return GetSubmissive(ActorRef)
EndFunction

bool Function IsAggressor(Actor ActorRef)
	sslActorAlias agr = ActorAlias(ActorRef)
	return GetSubmissives().Length && agr && agr.IsAggressor()
EndFunction

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;

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
	return _ContextTags.Length && _ContextTags.Find(asTag) > -1
EndFunction

Function AddContext(String asContext)
	If (HasContext(asContext))
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
; --- Physics					                                --- ;
; ------------------------------------------------------- ;

bool Function IsInteractionRegistered()
	return IsCollisionRegistered()
EndFunction

int[] Function GetInteractionTypes(Actor akPosition, Actor akPartner)
	return GetCollisionActions(akPosition, akPartner)
EndFunction

bool Function HasInteractionType(int aiType, Actor akPosition, Actor akPartner)
	return HasCollisionAction(aiType, akPosition, akPartner)
EndFunction

Actor Function GetPartnerByType(Actor akPosition, int aiType)
	return GetPartnerByAction(akPosition, aiType)
EndFUnction
Actor[] Function GetPartnersByType(Actor akPosition, int aiType)
	return GetPartnersByAction(akPosition, aiType)
EndFUnction
Actor Function GetPartnerByTypeRev(Actor akPartner, int aiType)
	return GetPartnerByActionRev(akPartner, aiType)
EndFunction
Actor[] Function GetPartnersByTypeRev(Actor akPartner, int aiType)
	return GetPartnersByActionRev(akPartner, aiType)
EndFunction

float Function GetVelocity(Actor akPosition, Actor akPartner, int aiType)
	return GetActionVelocity(akPosition, akPartner, aiType)
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

; Additions by ClimaxEXT
Int Property CONSENT_CONNONSUB 		= 0 AutoReadOnly Hidden
Int Property CONSENT_NONCONNONSUB = 1 AutoReadOnly Hidden
Int Property CONSENT_CONSUB 			= 2 AutoReadOnly Hidden
Int Property CONSENT_NONCONSUB 		= 3 AutoReadOnly Hidden

Int Property ACTORINT_NONPART 	= 0 AutoReadOnly Hidden
Int Property ACTORINT_PASSIVE 	= 1 AutoReadOnly Hidden
Int Property ACTORINT_ACTIVE 		= 2 AutoReadOnly Hidden

int Property ASLTYPE_NONE	= -1 AutoReadOnly		; none
int Property ASLTYPE_GR 	= 0  AutoReadOnly 	; grinding
int Property ASLTYPE_HJ		= 1  AutoReadOnly 	; handjob
int Property ASLTYPE_FJ		= 2  AutoReadOnly 	; footjob
int Property ASLTYPE_OR 	= 3  AutoReadOnly 	; oral
int Property ASLTYPE_VG 	= 4  AutoReadOnly		; vaginal
int Property ASLTYPE_AN		= 5  AutoReadOnly		; anal
int Property ASLTYPE_SRVG	= 6  AutoReadOnly		; spitroast (oral+vaginal)
int Property ASLTYPE_SRAN = 7  AutoReadOnly		; spitroast (oral+anal)
int Property ASLTYPE_DP 	= 8  AutoReadOnly		; double penetration
int Property ASLTYPE_TP 	= 9  AutoReadOnly		; triple penetration

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
		return SexLabUtil.GetCurrentGameRealTime() - StartedAt
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
		Positions = PapyrusUtil.RemoveActor(Positions, none)
		If(Positions.Length < 1 || Positions.Length >= POSITION_COUNT_MAX)
			Fatal("Failed to start Thread -- No valid actors available for animation")
			return none
		EndIf
		Actor[] submissives = GetSubmissives()
		_CustomScenes = ValidateScenes(_CustomScenes, submissives)
		If(_CustomScenes.Length)
			If(LeadIn)
				Log("LeadIn detected on custom Animations. Disabling LeadIn")
				LeadIn = false
			EndIf
		Else
      _PrimaryScenes = ValidateScenes(_PrimaryScenes, submissives)
			If(!_PrimaryScenes.Length)
        _PrimaryScenes = SexLabRegistry.LookupScenesA(Positions, "", submissives, _furniStatus, CenterRef)
				If (!_PrimaryScenes.Length)
        	_PrimaryScenes = SexLabRegistry.LookupScenes(Positions, "", none, _furniStatus, CenterRef)
					If (!_PrimaryScenes.Length)
						Fatal("Failed to start Thread -- No valid animations for given actors")
						return none
					EndIf
				EndIf
			EndIf
			If(LeadIn)
				_LeadInScenes = ValidateScenes(_LeadInScenes, submissives)
				LeadIn = _LeadInScenes.Length
			EndIf
		EndIf
		ShuffleScenes(Scenes, _StartScene)
		String[] out = new String[16]
		ObjectReference new_center = FindCenter(Scenes, out, _BaseCoordinates, _furniStatus)
		If (!new_center || out[0] == "")
			Fatal("Failed to start Thread -- Unable to locate a center compatible with given scenes")
			return none
		EndIf
		CenterRef = new_center
		_ActiveScene = out[GetActiveIdx(out)]
		If (!SexLabRegistry.SortBySceneA(Positions, submissives, _ActiveScene, -1))
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
		CenterRef.SendModEvent("SSL_PREPARE_Thread" + tid)
		SendThreadEvent("AnimationStarting")
		RunHook(Config.HOOKID_STARTING)
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
			If (sslSystemConfig.GetSettingInt("iUseFade") > 0)
				Config.ApplyFade()
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

String[] Function ValidateScenes(String[] asScenes, Actor[] akSubmissives)
	If(!asScenes.Length)
		return asScenes
	EndIf
	String[] s = SexLabRegistry.ValidateScenesA(asScenes, Positions, "", akSubmissives, -1)
	If (!s.Length)
		return SexLabRegistry.ValidateScenes(asScenes, Positions, "", none, -1)
	EndIf
	return s
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
bool _ForceAdvance		; Force fully auto advance (set by timed stages)
float _StageTimer			; timer for the current stage
float _SFXTimer				; so long until new SFX effect
float[] _CustomTimers	; Custom set of timers to use for this animation
float[] Property Timers hidden
	{In use timer set of the active scene}
	float[] Function Get()
		If (_CustomTimers.Length)
			return _CustomTimers
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
		StartedAt = SexLabUtil.GetCurrentGameRealTime()
		AnimationStart()
		RegisterCollision(Positions, _ActiveScene)
	EndEvent
	Function AnimationStart()
		If (_animationSyncCount < Positions.Length)
			_animationSyncCount += 1
			Log("AnimationStart called " + _animationSyncCount + "/" + (Positions.Length + 1) + " times")
			return
		EndIf
		Log("AnimationStart fully setup, begin animating")
		SexLabUtil.PrintConsole("[SexLab] Playing Animation " + SexLabRegistry.GetSceneName(_ActiveScene)) ; NOTE: Temporary until UI
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, "")
		_StageHistory = new String[1]
		_StageHistory[0] = _ActiveStage
		SendThreadEvent("AnimationStart")
		If(LeadIn)
			SendThreadEvent("LeadInStart")
		EndIf
		StartStage()
		StartTranslations()
	EndFunction

	bool Function ResetScene(String asNewScene)
		UnregisterForUpdate()
		AddExperience(Positions, _ActiveScene, _StageHistory)
		If (asNewScene != _ActiveScene)
			If (!SexLabRegistry.SortBySceneA(Positions, GetSubmissives(), asNewScene, -1))
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
			RegisterCollision(Positions, asNewScene)
			SortAliasesToPositions()
			_ActiveScene = asNewScene
		EndIf
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int[] sex_ = SexLabRegistry.GetPositionSexA(_ActiveScene)
		int[] schlongs_ = SexLabRegistry.GetSchlongAngleA(_ActiveScene, _ActiveStage)
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].TryLock()
			ActorAlias[i].ResetPosition(strips_[i], sex_[i], schlongs_[i])
			i += 1
		EndWhile
		StopTranslations()
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, "")
		_StageHistory = new String[1]
		_StageHistory[0] = _ActiveStage
		StartStage()
		StartTranslations()
		return true
	EndFunction

	Function PlayNext(int aiNextBranch)
		UnregisterForUpdate()
		SendThreadEvent("StageEnd")
		RunHook(Config.HOOKID_STAGEEND)
		String newStage = SexLabRegistry.BranchTo(_ActiveScene, _ActiveStage, aiNextBranch)
		PlayNextImpl(newStage)
	EndFunction
	Function PlayNextImpl(String asNewStage)
		If (!asNewStage)
			Log("Invalid branch or previous stage is sink, ending scene")
			If(LeadIn)
				EndLeadIn()
			Else
				EndAnimation()
			EndIf
			return
		ElseIf(!Leadin)
			If (SexLabRegistry.GetNodeType(_ActiveScene, asNewStage) == 2)
				SendThreadEvent("OrgasmStart")
				_SceneEndClimax = true
				TriggerOrgasm()
			EndIf
			int ctype = sslSystemConfig.GetSettingInt("iClimaxType")
			If (ctype == Config.CLIMAXTYPE_SCENE)
				int[] cactors = SexLabRegistry.GetClimaxingActors(_ActiveScene, asNewStage)
				int i = 0
				While (i < cactors.Length)
					ActorAlias[cactors[i]].DoOrgasm()
					i += 1
				EndWhile
			EndIf
		EndIf
		int[] strips_ = SexLabRegistry.GetStripDataA(_ActiveScene, "")
		int i = 0
		While (i < Positions.Length)
			ActorAlias[i].TryLock()
			ActorAlias[i].UpdateNext(strips_[i])
			i += 1
		EndWhile
		StopTranslations()
		_ActiveStage = PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, asNewStage)
		_StageHistory = PapyrusUtil.PushString(_StageHistory, _ActiveStage)
		StartStage()
		StartTranslations()
	EndFunction
	Function TriggerOrgasm()
		SendModEvent("SSL_ORGASM_Thread" + tid)
	EndFunction

	Function ResetStage()
		GoToStage(Stage)
	EndFunction

	Function StartStage()
		SendThreadEvent("StageStart")
		RunHook(Config.HOOKID_STAGESTART)
		ReStartTimer()
		sslSceneMenu.SetStage(Self, _ActiveScene, _ActiveStage)
	EndFunction

	; NOTE: This here counts from 1 instead of 0
	Function GoToStage(int ToStage)
		If (ToStage <= 1)
			ResetScene(_ActiveScene)
		ElseIf (ToStage > Stage)
			int idx = SelectNextStage(_ActiveScene, _ActiveStage, _ThreadTags)
			PlayNext(idx)
		ElseIf (ToStage == Stage)
			ReStartTimer()
		Else
			; Skip stripping for already played stages
			int i = 0
			While (i < Positions.Length)
				ActorAlias[i].TryLock()
				i += 1
			EndWhile
			_StageHistory = Utility.ResizeStringArray(_StageHistory, ToStage)
			_ActiveStage = _StageHistory[ToStage - 1]
			RealignActors()
			StartStage()
		EndIf
	EndFunction
	Function BranchTo(int aiNextBranch)
		PlayNext(aiNextBranch)
	EndFunction
	Function SkipTo(String asNextStage)
		PlayNextImpl(asNextStage)
	EndFunction

	Function ReStartTimer()
		_ForceAdvance = false
		_StageTimer = GetTimer()
		If (!_ForceAdvance && !AutoAdvance)
			sslSceneMenu.SetTimer(Self, 0.0)
		Else
			sslSceneMenu.SetTimer(Self, _StageTimer)
		EndIf
		RegisterForSingleUpdate(ANIMATING_UPDATE_INTERVAL)
	EndFunction

	Function UpdateTimer(float AddSeconds = 0.0)
		_StageTimer += AddSeconds
		_ForceAdvance = true
		sslSceneMenu.SetTimer(Self, _StageTimer)
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
		Log("GetTimer() - Fixed timer: " + timer)
		_ForceAdvance = true
		return timer
	EndFunction

	float Function GetStageTimer(int maxstage)
		int[] c = SexLabRegistry.GetClimaxingActors(_ActiveScene, _ActiveStage)
		bool isClimaxStage = c.Length > 0
		If (isClimaxStage)
			return Timers[Timers.Length - 1]
		EndIf
		int lastTimerIdx = Timers.Length - 2
		If (_StageHistory.Length < lastTimerIdx)
			return Timers[_StageHistory.Length]
		EndIf
		return Timers[lastTimerIdx]
	Endfunction
	
	Event OnUpdate()
		If (AutoAdvance || _ForceAdvance)
			_StageTimer -= ANIMATING_UPDATE_INTERVAL
			If (_StageTimer <= 0)
				GoToStage(_StageHistory.Length + 1)
				; TODO: avoid last stage if GetOrgasmCount() for dom is 0 and enj < 80
				; perpetutate 2nd last stage or use ChangeAnimation() instead, and skip to 2nd/3rd stage
				return
			EndIf
		EndIf
		If (_SFXTimer > 0)
			_SFXTimer -= ANIMATING_UPDATE_INTERVAL
		Else
			bool penetration = HasCollisionAction(CTYPE_Vaginal, none, none) || HasCollisionAction(CTYPE_Anal, none, none)
			bool oral = HasCollisionAction(CTYPE_Oral, none, none)
			Log("SFX Testing; penetration = " + penetration + " / oral = " + oral)
			If (oral && penetration)
				Config.SexMixedFX.Play(CenterRef)
			ElseIf (oral)
				Config.SuckingFX.Play(CenterRef)
			Else
				Config.SquishingFX.Play(CenterRef)
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
				SexLabRegistry.SortBySceneA(Positions, GetSubmissives(), _ActiveScene, -1)
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
		StopTranslations()
		PlaceAndPlay(Positions, _InUseCoordinates, _ActiveScene, _ActiveStage)
		StartTranslations()
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
					slot.OnDoPrepare("", "skip", 0.0, none)
				EndIf
			EndIf
			n += 1
		EndWhile
		; Validate Animations or get new
		Positions = akNewPositions
		Actor[] sub = GetSubmissives()
		If (!SexLabRegistry.ValidateSceneA(_ActiveScene, Positions, "", sub, -1))
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
		sslSceneMenu.SetPositions(Self, Positions)
		SendThreadEvent("ActorChangeEnd")
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
			SendThreadEvent("OrgasmEnd")
		EndIF
		GoToState(STATE_END)
	EndFunction

	int Function GetStatus()
		return STATUS_INSCENE
	EndFunction

	Event OnEndState()
		UnregisterCollision()
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
Function StartStage()
	Log("Cannot reset outside the playing state", "StartStage()")
EndFunction
Function EndLeadIn()
	Log("Cannot end leadin outside the playing state", "EndLeadIn()")
EndFunction
Function PlayNext(int aiNextBranch)
	Log("Cannot play next branch outside the playing state", "PlayNext()")
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
int Function SelectNextStage(String asScene, String asActiveStage, String[] asThreadTags) native
String Function PlaceAndPlay(Actor[] akPositions, float[] afCoordinates, String asSceneID, String asStageID) native
Function RePlace(Actor akActor, float[] afBaseCoordinates, String asSceneID, String asStageID, int n) native
Function UpdatePlacement(int n, sslActorAlias akAlias)
	RePlace(akAlias.GetReference() as Actor, _InUseCoordinates, _ActiveScene, _ActiveStage, n)
EndFunction
; Physics/SFX Related
bool Function IsCollisionRegistered() native
Function RegisterCollision(Actor[] akPosition, String asActiveScene) native
Function UnregisterCollision() native
int[] Function GetCollisionActions(Actor akPosition, Actor akPartner) native
bool Function HasCollisionAction(int aiType, Actor akPosition, Actor akPartner) native
Actor Function GetPartnerByAction(Actor akPosition, int aiType) native
Actor[] Function GetPartnersByAction(Actor akPosition, int aiType) native
Actor Function GetPartnerByActionRev(Actor akPartner, int aiType) native
Actor[] Function GetPartnersByActionRev(Actor akPartner, int aiType) native
float Function GetActionVelocity(Actor akPosition, Actor akPartner, int aiType) native

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
		SendModEvent("SSL_CLEAR_Thread" + tid, "", 1.0)
		If(IsObjectiveDisplayed(0))
			SetObjectiveDisplayed(0, False)
		EndIf
		UpdateAllEncounters()
		int i = 0
		While (i < ActorAlias.Length)
			Utility.Wait(0.05)
			If (!ActorAlias[i].GetReference())
				i += 1
			EndIf
		EndWhile
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

Function StopTranslations()
	int i = 0
	While (i < Positions.Length)
		Positions[i].StopTranslation()
		i += 1
	EndWhile
EndFunction

Function StartTranslations()
	int i = 0
	While (i < Positions.Length)
		; Some creatures (such as horses or spiders) may tilt unnaturaly during scenes, 
		; forcing them in translation ensures they are angled correctly
		; translating only Y axis, as it does not have any visual effect on the actor
		If (ActorAlias[i].GetSex() > 2)
			float x = Positions[i].X
			float y = Positions[i].Y
			float z = Positions[i].Z
			float ax = Positions[i].GetAngleX()
			float ay = Positions[i].GetAngleY() + 0.001
			float az = Positions[i].GetAngleZ()
			Positions[i].TranslateTo(x, y, z, ax, ay, az, 1.0, 0.0001)
		EndIf
		i += 1
	EndWhile
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

Sound Function GetAliasSound(sslActorAlias akThis, String asVoice, int aiStrength)
	return sslBaseVoice.GetSoundObject(asVoice, aiStrength, _ContextTags, _ActiveScene, _ActiveStage, ActorAlias.Find(akThis))
EndFunction
Sound Function GetAliasOrgasmSound(sslActorAlias akThis, String asVoice)
	return sslBaseVoice.GetOrgasmSound(asVoice, _ContextTags, _ActiveScene, _ActiveStage, ActorAlias.Find(akThis))
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
	float timeregistered = SexLabUtil.GetCurrentGameRealTime() - afRegisteredAt
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
; --- ENJOYMENT: Interaction Factor                   --- ;
; ------------------------------------------------------- ;

float Function GetInteractionFactor(Actor ActorRef, int typeASL, int infoActor)
	float ret = 0.0
	If (Positions.Length > 1 && IsCollisionRegistered())
		ret = CalcPhysicFactor(ActorRef)
	Endif
	If (ret == 0)
		ret = CalcInteractionFactorASL(typeASL, infoActor)
	Endif
	return ret
EndFunction

float Function CalcPhysicFactor(Actor ActorRef)
	float factorPhysic = 0.0
	float velocityMax = 0.03
	bool actor_pOral = false
	bool actor_pFoot = false
	bool actor_pHand = false

	int[] typesPhysic = GetCollisionActions(ActorRef, none)
	float[] factors = sslSystemConfig.GetEnjoymentFactors()
	int i = 0
  While (i < typesPhysic.Length)
		int typePhysic = typesPhysic[i]
		float mult = 1 + Math.Abs(GetActionVelocity(ActorRef, none, typePhysic)) / velocityMax
		If (typePhysic == CTYPE_Vaginal)
			factorPhysic += factors[ASLTYPE_VG] * mult
		ElseIf (typePhysic == CTYPE_Anal)
			factorPhysic += factors[ASLTYPE_AN] * mult
		ElseIf (typePhysic == CTYPE_Oral)
			factorPhysic += factors[ASLTYPE_OR] * mult
			actor_pOral = true
		ElseIf (typePhysic == CTYPE_FootJob)
			factorPhysic += factors[ASLTYPE_FJ]
			actor_pFoot = true
		ElseIf (typePhysic == CTYPE_HandJob)
			factorPhysic += factors[ASLTYPE_HJ]
			actor_pHand = true
		ElseIf (typePhysic == CTYPE_Grinding)
			factorPhysic += factors[ASLTYPE_GR]
		EndIf
		i += 1
  EndWhile
	If (HasCollisionAction(CTYPE_Vaginal, none, ActorRef))
		float mult = 1 + Math.Abs(GetActionVelocity(none, ActorRef, CTYPE_Vaginal)) / velocityMax
		factorPhysic += factors[ASLTYPE_VG + 1] * mult
	Endif
	If (HasCollisionAction(CTYPE_Anal, none, ActorRef))
		float mult = 1 + Math.Abs(GetActionVelocity(none, ActorRef, CTYPE_Anal)) / velocityMax
		factorPhysic += factors[ASLTYPE_AN + 1] * mult
	Endif
	If (!actor_pOral && HasCollisionAction(CTYPE_Oral, none, ActorRef))
		factorPhysic += factors[ASLTYPE_OR]
	Endif
	If (!actor_pFoot && HasCollisionAction(CTYPE_FootJob, none, ActorRef))
		factorPhysic += factors[ASLTYPE_FJ + 1]
	Endif
	If (!actor_pHand && HasCollisionAction(CTYPE_HandJob, none, ActorRef))
		factorPhysic += factors[ASLTYPE_HJ + 1]
	Endif
	return factorPhysic
EndFunction

; ------------------------------------------------------- ;
; --- ENJOYMENT: Interaction Info (based on tags)     --- ;
; ------------------------------------------------------- ;

int Function GetInteractionTypeASL()
	;not conditioned by ASL
	bool stageHJ = (HasStageTag("Masturbation") || HasStageTag("HandJob") || HasStageTag("Fingering"))
	bool stageFJ = (HasStageTag("FootJob") || HasStageTag("Feet"))
	bool stageGR = HasStageTag("Grinding")
	;often conditioned by ASL
	bool stageOR = HasStageTag("Oral") && HasSceneTag("ASLTagged")
	bool stageVG = HasStageTag("Vaginal") && HasSceneTag("ASLTagged")
	bool stageAN = HasStageTag("Anal") && HasSceneTag("ASLTagged")

	if (stageOR && stageVG && stageAN)
		return ASLTYPE_TP
	elseif (stageVG && stageAN)
		return ASLTYPE_DP
	elseif (stageOR && (stageVG || stageAN))
		if stageAN && !stageVG
			return ASLTYPE_SRAN
		else
			return ASLTYPE_SRVG
		endif
	elseif stageAN
		return ASLTYPE_AN
	elseif stageVG
		return ASLTYPE_VG
	elseif stageOR
		return ASLTYPE_OR
	elseif stageFJ
		return ASLTYPE_FJ
	elseif stageHJ
		return ASLTYPE_HJ
	elseif stageGR
		return ASLTYPE_GR
	else
		return ASLTYPE_NONE
	endif
EndFunction

int Function GuessActorInterInfo(Actor ActorRef, int ActorSex, bool IsActorSub, int ConSubStatus, bool SameSexThread)
	;IMP: roles will be reversed for oral (ACTORINT_PASSIVE is the OralGiving and ACTORINT_ACTIVE is OralReceiving)
	;Not adjusting values here cuz that will have unintended effects for Spirtoast, DP, and TP scenes 
	int ActorInterInfo = ACTORINT_NONPART
	if ConSubStatus > CONSENT_NONCONNONSUB
		bool FemDom = HasSceneTag("FemDom")
		if !SameSexThread
			if (IsActorSub && !FemDom) || (!IsActorSub && FemDom)
				ActorInterInfo = ACTORINT_PASSIVE
			elseif (!IsActorSub && !FemDom) || (IsActorSub && FemDom)
				ActorInterInfo = ACTORINT_ACTIVE
			endif
		else
			if IsActorSub
				ActorInterInfo = ACTORINT_PASSIVE
			elseif !IsActorSub
				ActorInterInfo = ACTORINT_ACTIVE
			endif
		endif
	else
		if !SameSexThread
			if ActorSex == 1 || ActorSex == 4
				ActorInterInfo = ACTORINT_PASSIVE
			else ; ignoring complexities with futas
				ActorInterInfo = ACTORINT_ACTIVE
			endif
		else
			if GetPosition(ActorRef) == 0
				ActorInterInfo = ACTORINT_PASSIVE
			else
				ActorInterInfo = ACTORINT_ACTIVE
			endif
		endif
	endif
	return ActorInterInfo
EndFunction

float Function CalcInteractionFactorASL(int typeASL, int infoActor)
	If (infoActor == ACTORINT_NONPART || typeASL == ASLTYPE_NONE)
		return 0
	EndIf
	float[] factors = sslSystemConfig.GetEnjoymentFactors()
	If (typeASL == ASLTYPE_GR)
		return factors[ASLTYPE_GR]
	EndIf
	float div = 2.0
	float ret
	int idxAct = infoActor - 1
	int idxRev = 1 - idxAct
	If (typeASL == ASLTYPE_SRVG)
		ret = factors[ASLTYPE_OR + idxRev] + factors[ASLTYPE_VG + idxAct]
	ElseIf (typeASL == ASLTYPE_SRAN)
		ret = factors[ASLTYPE_OR + idxRev] + factors[ASLTYPE_AN + idxAct]
	ElseIf (typeASL == ASLTYPE_DP)
		ret = factors[ASLTYPE_VG + idxAct] + factors[ASLTYPE_AN + idxAct]
	ElseIf (typeASL == ASLTYPE_TP)
		ret = factors[ASLTYPE_OR + idxAct] + factors[ASLTYPE_VG + idxAct] + factors[ASLTYPE_AN + idxAct]
		div = 3.0
	Else
		return factors[typeASL + idxAct]
	EndIf
	If (infoActor == ACTORINT_ACTIVE)
	 	ret /= div
	EndIf
	return ret
EndFunction

; ------------------------------------------------------- ;
; --- ENJOYMENT: Best Relation                        --- ;
; ------------------------------------------------------- ;

; TODO: fill out new properties in CK
AssociationType Property SpouseAssocation Auto
Faction Property PlayerMarriedFaction Auto

;/mapping: Stranger=-2~2 | PersonOfInterest=3~7 | Lover=8~12 | Spouse=13~17 | LoverSpouse=18~22
w_agg=-2 | w_vic=-1 | <<stranger=0>> | w_dom=1 | w_sub=2
W_agg=3 | w_vic=4 | <<poi=5>> | w_dom=6 | w_sub=7
W_agg=8 | w_vic=9 | <<lover=10>> | w_dom=11 | w_sub=12
W_agg=13 | w_vic=14 | <<spouse=15>> | w_dom=16 | w_sub=17
W_agg=18 | w_vic=19 | <<spouse+lover=20>> | w_dom=21 | w_sub=22/;

int Function GetRelationForScene(Actor ActorRef, Actor TargetRef, int ConSubStatus)
	int BaseRelation = 0
	int ContextRelation = 0
	int retRelation = 0
	bool withSpouse = false
	bool withLover = false
	
	If ActorRef == PlayerRef
		If TargetRef.IsInFaction(PlayerMarriedFaction)
			withSpouse = true
			BaseRelation = 15
		EndIf
	Else
		If ActorRef.HasAssociation(SpouseAssocation, TargetRef)
			withSpouse = true
			BaseRelation = 15
		EndIf
	EndIf
	If !withSpouse && ActorRef.GetRelationshipRank(TargetRef) >= 4
		withLover = true
		BaseRelation = 10
	ElseIf !withLover && !withSpouse && (ActorRef.GetRelationshipRank(TargetRef) >= 1) && (SexLabStatistics.GetTimesMet(ActorRef, TargetRef) >= 3)
		BaseRelation = 5
	EndIf

	If ConSubStatus == CONSENT_CONSUB
		If IsVictim(ActorRef)
			ContextRelation = 1
		ElseIf IsVictim(TargetRef)
			ContextRelation = 2
		EndIf
	Else
		If IsVictim(ActorRef)
			ContextRelation = -2
		ElseIf IsVictim(TargetRef)
			ContextRelation = -1
		EndIf
	EndIf

	retRelation = BaseRelation + ContextRelation
	return retRelation
EndFunction

int Function GetBestRelationForScene(Actor ActorRef, int ConSubStatus)
	if Positions.Length <= 1
		return 0
	elseif Positions.Length == 2
		if(ActorRef == Positions[0])
			return GetRelationForScene(ActorRef, Positions[1], ConSubStatus)
		else
			return GetRelationForScene(ActorRef, Positions[0], ConSubStatus)
		endif
	endIf
	int ret = -2
	int i = 0
	while i < Positions.Length
		if Positions[i] != ActorRef
			int relation = GetRelationForScene(ActorRef, Positions[i], ConSubStatus)
			if relation > ret
				ret = relation
			endif
		endIf
		i += 1
	endWhile
	return ret
EndFunction

; ------------------------------------------------------- ;
; --- ENJOYMENT: Thread Info                          --- ;
; ------------------------------------------------------- ;

bool Function SameSexThread()
	bool SameSexThread = false
	int MaleCount = sslActorLibrary.CountMale(Positions)
	int FemCount = sslActorLibrary.CountFemale(Positions)
	int FutaCount = sslActorLibrary.CountFuta(Positions)
	int CrtMaleCount = sslActorLibrary.CountCrtMale(Positions)
	int CrtFemaleCount = sslActorLibrary.CountCrtFemale(Positions)
	If (Positions.Length != 1 && ((MaleCount + CrtMaleCount == Positions.Length) || (FemCount + CrtFemaleCount == Positions.Length) || (FutaCount == Positions.Length)))
		SameSexThread = true ; returns false for solo scenes
	EndIf
	return SameSexThread
EndFunction

int Function IdentifyConsentSubStatus()
	int ConSubStatus = CONSENT_CONNONSUB
	If GetSubmissives().Length == 0
		If !IsConsent()
			ConSubStatus = CONSENT_NONCONNONSUB
		EndIf
	Else
		If IsConsent()
			ConSubStatus = CONSENT_CONSUB
		Else
			ConSubStatus = CONSENT_NONCONSUB
		EndIf
	EndIf
	return ConSubStatus
EndFunction

bool Function CrtMaleHugePP()
	bool HugePP = false
	If sslActorLibrary.CountCrtMale(Positions) > 0
		int CreMalePos = -1
		int i = 0
		while i < Positions.Length
			if Positions[i] != None
				int gender = GetNthPositionSex(i)
				if gender == 3
					CreMalePos = i
				endIf
			endIf
			i += 1
		endWhile
		If CreMalePos > -1
			string CreRacekey = SexlabRegistry.GetRaceKey(Positions[CreMalePos])
			If CreRacekey ==  "bears" || CreRacekey ==  "chaurus" || CreRacekey ==  "chaurushunters" || CreRacekey ==  "chaurusreapers" || CreRacekey ==  "dragons" || CreRacekey ==  "dwarvencenturions" || CreRacekey ==  "frostatronach" || CreRacekey ==  "gargoyles" || CreRacekey ==  "giants" || CreRacekey ==  "giantspiders" || CreRacekey ==  "horses" || CreRacekey ==  "largespiders" || CreRacekey ==  "lurkers" || CreRacekey ==  "mammoths" || CreRacekey ==  "sabrecats" || CreRacekey ==  "trolls" || CreRacekey ==  "werewolves"
				HugePP = true
			EndIf
		EndIf
	EndIf
	return HugePP
EndFunction

; ------------------------------------------------------- ;
; --- ORGASM FX                                       --- ;
; ------------------------------------------------------- ;

bool Function IsVaginalComplex(Actor ActorRef, int TypeInterASL)
	bool ret = False
	If (IsCollisionRegistered() && (HasCollisionAction(CTYPE_Vaginal, ActorRef, none) || HasCollisionAction(CTYPE_Vaginal, none, ActorRef))) \
		|| (TypeInterASL >= ASLTYPE_VG && (TypeInterASL != ASLTYPE_AN && TypeInterASL != ASLTYPE_SRAN))
		ret = True
	EndIf
	return ret
EndFunction

bool Function IsAnalComplex(Actor ActorRef, int TypeInterASL)
	bool ret = False
	If (IsCollisionRegistered() && (HasCollisionAction(CTYPE_Anal, ActorRef, none) || HasCollisionAction(CTYPE_Anal, none, ActorRef))) \
		|| (TypeInterASL >= ASLTYPE_AN && (TypeInterASL != ASLTYPE_SRVG))
		ret = True
	EndIf
	return ret
EndFunction

bool Function IsOralComplex(Actor ActorRef, int TypeInterASL)
	bool ret = False
	If (IsCollisionRegistered() && HasCollisionAction(CTYPE_Oral, ActorRef, none)) \
		|| (TypeInterASL >= ASLTYPE_OR && (TypeInterASL != ASLTYPE_VG && TypeInterASL != ASLTYPE_AN))
		ret = True
	EndIf
	return ret
EndFunction

Function ApplyCumFX(Actor SourceRef)
	; TODO: If there is no schlong, consider failing silenently
	If (!Config.UseCum)
		return
	EndIf
	int i = 0
	while i < Positions.Length
		int otherSex = GetNthPositionSex(i)

		Log("Checking for cum FX: " + i + " " + otherSex)

		if (i != GetPosition(SourceRef)) && (otherSex == 1 || otherSex == 2 || otherSex == 4)
			ActorAlias[i].ApplyCum()
		endIf
		i += 1
	endWhile
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
	msg = "Thread[" + thread_id + "] " + msg
	sslLog.Log(msg)
EndFunction

Function Fatal(string msg, string src = "", bool halt = true)
	msg = "Thread["+thread_id+"] - FATAL - " + msg
	sslLog.Error(msg, true)
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

sslThreadLibrary Property ThreadLib Hidden
	sslThreadLibrary Function Get()
		return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslThreadLibrary
	EndFunction
EndProperty
sslAnimationSlots Property AnimSlots Hidden
	sslAnimationSlots Function Get()
		return Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationSlots
	EndFunction
EndProperty
sslCreatureAnimationSlots Property CreatureSlots Hidden
	sslCreatureAnimationSlots Function Get()
		return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationSlots
	EndFunction
EndProperty
sslActorLibrary property ActorLib Hidden
  sslActorLibrary Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorLibrary
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

Function LogConsole(String asReport)
	String msg = "Thread[" + thread_id + "] - " + asReport
	sslLog.Log(msg, true)
EndFunction
Function LogRedundant(String asFunction)
	Debug.MessageBox("[SexLab]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function that is no longer used.\nThis is most likely due to a file conflict. Ensure no other mod overwrites SexLab files.\nSee Papyrus Log for more information.")
	Debug.TraceStack("[SexLab] Redundant function called: " + asFunction)
EndFunction

Function AddAnimation(sslBaseAnimation AddAnimation, bool ForceTo = false)
	If(!AddAnimation)
		return
	EndIf
	AddScene(AddAnimation.Registry)
EndFunction
Function SetAnimation(int aid = -1)
	if aid < 0 || aid >= Animations.Length
		aid = Utility.RandomInt(0, (Animations.Length - 1))
	endIf
	SetAnimationImpl(Animations[aid])
EndFunction
Function SetAnimationImpl(sslBaseAnimation akAnimation)
	ResetScene(akAnimation.Registry)
EndFunction

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
		ret[0] = SexLabUtil.GetCurrentGameRealTime()
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

bool Function UseLimitedStrip()
	If (LeadIn)
		return true
	EndIf
	bool excplicit = HasTag("Penetration") || HasTag("DoublePenetration") || HasTag("TripplePenetration") || HasTag("Fingering") || HasTag("Fisting")
	excplicit = excplicit || HasTag("Tribadism") || HasTag("Grinding") || HasTag("Boobjob") || HasTag("Buttjob")
	return Config.LimitedStrip && !excplicit
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
	SetStartingScene(FirstAnimation.Registry)
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

bool property DisableOrgasms hidden
	bool Function Get()
		bool ret = false
		int i = 0
		While (i < Positions.Length && !ret)
			ret = !ActorAlias[i].IsOrgasmAllowed()
			i += 1
		EndWhile
		return ret
	EndFunction
	Function Set(bool abDisable)
		int i = 0
		While (i < Positions.Length)
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
