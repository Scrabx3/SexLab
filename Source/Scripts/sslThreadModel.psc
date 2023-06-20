ScriptName sslThreadModel extends Quest Hidden
{
	Internal class for primary scene management. Builds and controls scene-flow and keeps track of scene actors

	To start a scene, please check the functions provided in the main API (SexLabFramework.psc)
	To access, read and write scene related data see sslThreadController.psc
}

Actor[] Function GetVictims()
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

; Constants
int Property POSITION_COUNT_MAX = 5 AutoReadOnly

String Property STATE_IDLE 		= "Unlocked" AutoReadOnly
String Property STATE_SETUP 	= "Making" AutoReadOnly
String Property STATE_PLAYING = "Animation" AutoReadOnly
String Property STATE_END 		= "Ending" AutoReadOnly

; ------------------------------------------------------- ;
; --- Thread Status                                   --- ;
; ------------------------------------------------------- ;

int Property Status_UNDEF 	= 0 AutoReadOnly
int Property Status_IDLE	 	= 1 AutoReadOnly
int Property Status_SETUP 	= 2 AutoReadOnly
int Property Status_INSCENE = 3 AutoReadOnly
int Property Status_ENDING	= 4 AutoReadOnly

bool Property IsLocked hidden
	bool Function get()
		return GetStatus() != Status_IDLE
	EndFunction
EndProperty

; Every valid state will oerwrite this
; Should this ever be called, then the Thread was in an unspecified state and will be reset
int Function GetStatus()
	Fatal("Undefined Status. Resetting thread...")
	return Status_UNDEF
EndFunction

; ------------------------------------------------------- ;
; --- Thread Data                                     --- ;
; ------------------------------------------------------- ;

sslActorAlias[] Property ActorAlias Auto
Actor[] Property Positions Auto Hidden

String _ActiveScene	              ; The currently playing Animation
String _StartScene	              ; The first animation this thread player
String[] CustomScenes						  ; animation overrides (will always be used if not empty)
String[] PrimaryScenes			      ; set of valid animations
String[] LeadInScenes						  ; set of valid lead-in (intro) animations
String[] Property Scenes Hidden	  ; currently active set of animation
	String[] Function get()
		If(CustomScenes.Length > 0)
			return CustomScenes
		ElseIf(LeadIn)
			return LeadInScenes
		Else
			return PrimaryScenes
		EndIf
	EndFunction
EndProperty

int Property FURNI_DISALLOW = 0 AutoReadOnly
int Property FURNI_ALLOW 		= 1 AutoReadOnly
int Property FURNI_PREFER 	= 2 AutoReadOnly
int _furniStatus

ObjectReference _center										; the actual center object the animation is using
ReferenceAlias Property CenterAlias Auto	; the alias referencing _center
ObjectReference Property CenterRef Hidden	; shorthand for CenterAlias
	ObjectReference Function Get()
		return _center
	EndFunction
	Function Set(ObjectReference akNewCenter)
		CenterOnObjectImpl(akNewCenter)
	EndFunction
EndProperty

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
		return Status_IDLE
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
		ElseIf(ActorCount >= POSITION_COUNT_MAX)
			Fatal("Failed to add actor -- Thread has reached actor limit", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		ElseIf(Positions.Find(ActorRef) != -1)
			Fatal("Failed to add actor -- They have been already added to this thread", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		int ERRC = ActorLib.ValidateActor(ActorRef)
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
		PrimaryScenes = SexLabRegistry.SceneExistA(asScenes)
	EndFunction
  Function SetForcedScenes(String[] asScenes)
    CustomScenes = SexLabRegistry.SceneExistA(asScenes)
  EndFunction
  Function SetLeadScenes(String[] asScenes)
    LeadInScenes = SexLabRegistry.SceneExistA(asScenes)
    LeadIn = LeadInScenes.Length > 0
  EndFunction
  Function SetStartingScene(String asFirstScene)
    If (SexLabRegistry.SceneExists(asFirstScene))
      _StartScene = asFirstScene
    EndIf
  EndFunction
	Function AddScene(String asSceneID)
		If (!asSceneID || !SexLabRegistry.SceneExists(asSceneID))
			return
		EndIf
		If(CustomScenes.Length > 0)
			CustomScenes = PapyrusUtil.PushString(CustomScenes, _StartScene)
		ElseIf(LeadIn)
			LeadInScenes = PapyrusUtil.PushString(LeadInScenes, _StartScene)
		Else
			PrimaryScenes = PapyrusUtil.PushString(PrimaryScenes, _StartScene)
		EndIf
	EndFunction

	Function DisableLeadIn(bool disabling = true)
		LeadIn = !disabling
	EndFunction
	Function SetFurniStatus(int aiStatus)
		_furniStatus = PapyrusUtil.ClampInt(aiStatus, FURNI_DISALLOW, FURNI_PREFER)
	EndFunction

	Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
		CenterOnObjectImpl(CenterOn)
	EndFunction
	Function CenterOnObjectImpl(ObjectReference akNewCenter)
		CenterAlias.ForceRefTo(akNewCenter)
		_center = akNewCenter
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
		Actor[] victims_ = GetAllVictims()
		CustomScenes = SexLabRegistry.ValidateScenesA(CustomScenes, Positions, "", victims_)
		If(CustomScenes.Length)
			If(LeadIn)
				Log("LeadIn detected on custom Animations. Disabling LeadIn")
				LeadIn = false
			EndIf
		Else  ; only validate if these arent overwritten by custom scenes
      PrimaryScenes = SexLabRegistry.ValidateScenesA(PrimaryScenes, Positions, "", victims_)
			If(!PrimaryScenes.Length)
        PrimaryScenes = SexLabRegistry.LookupScenesA(Positions, "", victims_, _furniStatus, _center)
				If (!PrimaryScenes.Length)
					Fatal("Failed to start Thread -- No valid animations for given actors")
					return none
				EndIf
			EndIf
			If(LeadIn)
				LeadInScenes = SexLabRegistry.ValidateScenesA(LeadInScenes, Positions, "", victims_)
				If(!LeadInScenes.Length)
					LeadInScenes = SexLabRegistry.LookupScenesA(Positions, "LeadIn", victims_, _furniStatus, _center)
					LeadIn = LeadInScenes.Length
				EndIf
			EndIf
		EndIf
		; Start Animation
		return StartThreadUnchecked()
	EndFunction

  sslThreadController Function StartThreadUnchecked()
		UnregisterForUpdate()
		SendThreadEvent("AnimationStarting")
		ThreadHooks = Config.GetThreadHooks()
		HookAnimationStarting()
		If(_StartScene && Scenes.Find(_StartScene) == -1)
			AddScene(_StartScene)
		EndIf
		_ActiveScene = GetSetCenterObject(Scenes, _StartScene)
		If (!_ActiveScene)
			Fatal("Failed to start Thread -- No valid animation applicable to current environment")
			return none
		EndIf
		_prepareAsyncCount = 0
		; TODO: HasPlayer && Config.FadeoutMode -------------------v
		CenterRef.SendModEvent("SSL_PREPARE_Thread" + tid, "", HasPlayer as float)
		; TODO: Additional fade out settings
		PrepareDone()
    return self as sslThreadController
  EndFunction
	
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
				EnableHotkeys()
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

	int Function GetStatus()
		return Status_SETUP
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
Function SetForcedScenes(String[] asScenes)
	Log("Forced animations can only be set during setup", "SetForcedScenes()")
EndFunction
Function SetLeadScenes(String[] asScenes)
	Log("LeadIn animations can only be set during setup", "SetLeadScenes()")
EndFunction
Function SetStartingScene(String asFirstAnimation)
	Log("Start animations can only be set during setup", "SetStartingScene()")
EndFunction
Function AddScene(String asSceneID)
	Log("Manipulating available default scenes can only be done during setup", "AddScene()")
EndFunction
Function DisableLeadIn(bool disabling = true)
	Log("Lead in status can only be set during setup", "DisableLeadIn()")
EndFunction
Function SetFurniStatus(int aiStatus)
	Log("Furniture status can only be set during setup", "SetFurniStatus()")
EndFunction

; Given an array of Scenes, select some valid Scene within the array, using the currently selected center as comparable
; If no scene is allowed with the current center, will set a new center
; Return the Scene to be played
String Function GetSetCenterObject(String[] asSceneIDs, String asScenePrefered) native

; --- Legacy

Function SetAnimations(sslBaseAnimation[] AnimationList)
	If(AnimationList.Length && AnimationList.Find(none) == -1)
		SetScenes(sslBaseAnimation.AsSceneIDs(AnimationList))
	EndIf
EndFunction
Function SetForcedAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList.Length && AnimationList.Find(none) == -1
		SetForcedScenes(sslBaseAnimation.AsSceneIDs(AnimationList))
	endIf
EndFunction
Function SetLeadAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList.Length && AnimationList.Find(none) == -1
		SetLeadScenes(sslBaseAnimation.AsSceneIDs(AnimationList))
	endIf
EndFunction
Function SetStartingAnimation(sslBaseAnimation FirstAnimation)
	SetStartingScene(FirstAnimation.PROXY_ID)
EndFunction
Function DisableBedUse(bool disabling = true)
	SetFurniStatus((!disabling) as int)
EndFunction
Function SetBedFlag(int flag = 0)
	SetFurniStatus(flag + 1)	; New Status is [0, 2] instead of [-1, 1]
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



; ------------------------------------------------------- ;
; --- Thread END                                      --- ;
; ------------------------------------------------------- ;
;/
	The end state has 2 purposes:
	1) Reset all actors in the animation to their pre-animation status
	2) Reset the thread after a short buffer duration back to the idle state
/;



; ------------------------------------------------------- ;
; --- Function Declarations                           --- ;
; ------------------------------------------------------- ;
;/
	Most functions used to manage animations have a unique behavior depending on the currently active state
	The below block defines such functions. All of these functions will be overwritten for every state where there
	is reason to implement them
/;


Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
	CenterOnObjectImpl(CenterOn)
	If(resync)	;	&& GetState() == "Animating") RealignActors() is empty if not in Animating State
		RealignActors()
		SendThreadEvent("ActorsRelocated")
	EndIf
EndFunction

Function CenterOnObjectImpl(ObjectReference akNewCenter)
	If(!akNewCenter)
		return
	EndIf
	_Center = akNewCenter.PlaceAtMe(xMarker)
	CenterAlias.ForceRefTo(akNewCenter)
	CenterLocation[0] = akNewCenter.GetPositionX()
	CenterLocation[1] = akNewCenter.GetPositionY()
	CenterLocation[2] = akNewCenter.GetPositionZ()
	CenterLocation[3] = akNewCenter.GetAngleX()
	CenterLocation[4] = akNewCenter.GetAngleY()
	CenterLocation[5] = akNewCenter.GetAngleZ()
	If(sslpp.IsBed(akNewCenter))
		BedStatus[1] = ThreadLib.GetBedType(akNewCenter)
		BedRef = akNewCenter
		SetFurnitureIgnored(true)
		float offsetX
		float offsetY
		float offsetZ
		float offsAnZ
		If(BedStatus[1] == 1)
			offsetZ = 7.5 ; Average Z offset for bedrolls
			offsAnZ = 180 ; bedrolls are usually rotated 180° on Z
		Else
			int offset = -31 ; + ((_Positions_var.find(playerref) > -1) as int) * 36
			offsetX = Math.Cos(sslUtility.TrigAngleZ(CenterLocation[5])) * offset
			offsetY = Math.Sin(sslUtility.TrigAngleZ(CenterLocation[5])) * offset
			offsetZ = 45 ; Z offset for beds
		EndIf
		float scale = akNewCenter.GetScale()
		If(scale != 1.0)
			offsetX *= scale
			offsetY *= scale
			If(CenterLocation[2] < 0)
				offsetZ *= (2 - scale) ; Assming Scale will always be in [0; 2)
			Else
				offsetZ *= scale
			EndIf
		EndIf
		CenterLocation[0] = CenterLocation[0] + offsetX
		CenterLocation[1] = CenterLocation[1] + offsetY
		CenterLocation[2] = CenterLocation[2] + offsetZ
		CenterLocation[5] = CenterLocation[5] - offsAnZ
		_Center.SetPosition(CenterLocation[0], CenterLocation[1], CenterLocation[2])
		_Center.SetAngle(CenterLocation[3], CenterLocation[4], CenterLocation[5])
	Else
		BedStatus[1] = 0
		BedRef = none
	EndIf
	Log("Creating new Center Ref from = " + akNewCenter + " at Coordinates = " + CenterLocation + "(New Center is Bed Type: " + BedStatus[1] + ")")
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




; Properties
sslSystemConfig Property Config Auto
sslActorStats Property Stats Auto
sslActorLibrary Property ActorLib Auto
sslThreadLibrary Property ThreadLib Auto
sslAnimationSlots Property AnimSlots Auto
sslCreatureAnimationSlots Property CreatureSlots Auto

Message Property UseBed Auto
Static Property xMarker Auto
Package Property DoNothingPackage Auto	; used in the alias scripts
; Furniture Property BaseMarker Auto		; trying xMarker cause of complains about alignments


; Actor Info
; assert(ActorAlias[i].GetRef() == Positions[i])


; Thread status
int Property Stage Auto Hidden
bool Property AutoAdvance auto hidden
bool Property LeadIn auto hidden

string Property AdjustKey
	String Function Get()
		return "Global"
		; TODO: reimplement this
		; if !Config.RaceAdjustments && Config.ScaleActors
		; 	AdjustKey = "Global"
		; else
		; 	int i
		; 	string NewKey
		; 	while i < ActorCount
		; 		NewKey += PositionAlias(i).GetActorKey()
		; 		i += 1
		; 		if i < ActorCount
		; 			NewKey += "."
		; 		endIf
		; 	endWhile
		; 	AdjustKey = NewKey
		; endIf
	EndFunction
EndProperty

; Animation Info
Sound Property SoundFX auto hidden
string[] Property AnimEvents auto hidden

; Stat Tracking Info
float[] Property SkillBonus auto hidden ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd
float[] Property SkillXP auto hidden    ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd

bool[] Property IsType auto hidden 			; [0] IsAggressive, [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty
bool Property IsAggressive hidden
	bool Function get()
		return IsType[0] || GetAllVictims().Length || Tags.Find("Aggressive") > -1
	endfunction
	Function set(bool value)
		IsType[0] = value
	EndFunction
EndProperty
bool Property IsVaginal hidden
	bool Function get()
		return IsType[1]
	endfunction
	Function set(bool value)
		IsType[1] = value
	EndFunction
EndProperty
bool Property IsAnal hidden
	bool Function get()
		return IsType[2]
	endfunction
	Function set(bool value)
		IsType[2] = value
	EndFunction
EndProperty
bool Property IsOral hidden
	bool Function get()
		return IsType[3]
	endfunction
	Function set(bool value)
		IsType[3] = value
	EndFunction
EndProperty
bool Property IsLoving hidden
	bool Function get()
		return IsType[4]
	endfunction
	Function set(bool value)
		IsType[4] = value
	EndFunction
EndProperty
bool Property IsDirty hidden
	bool Function get()
		return IsType[5]
	endfunction
	Function set(bool value)
		IsType[5] = value
	EndFunction
EndProperty

; Timer Info
bool UseCustomTimers
float[] CustomTimers
float[] ConfigTimers
float[] Property Timers hidden
	float[] Function get()
		if UseCustomTimers
			return CustomTimers
		endIf
		return ConfigTimers
	EndFunction
	Function set(float[] value)
	if !value.Length
		Log("Set() - Empty timers given for Property Timers.", "ERROR")
	else
		CustomTimers    = value
		UseCustomTimers = true
	endIf
	EndFunction
EndProperty

; Thread info
float[] Property CenterLocation Auto Hidden

float Property StartedAt auto hidden
float Property TotalTime hidden
	float Function get()
		return SexLabUtil.GetCurrentGameRealTimeEx() - StartedAt
	EndFunction
EndProperty

bool property DisableOrgasms auto hidden

; Beds
; BedStatus[0] = -1 forbid, 0 allow, 1 force
; BedStatus[1] = 0 none, 1 bedroll, 2 single, 3 double
int[] Property BedStatus auto hidden

ObjectReference Property BedRef auto hidden
int Property BedTypeID hidden
	int Function get()
		return BedStatus[1]
	EndFunction
EndProperty
bool Property UsingBed hidden
	bool Function get()
		return BedStatus[1] > 0
	EndFunction
EndProperty
bool Property UsingBedRoll hidden
	bool Function get()
		return BedStatus[1] == 1
	EndFunction
EndProperty
bool Property UsingSingleBed hidden
	bool Function get()
		return BedStatus[1] == 2
	EndFunction
EndProperty
bool Property UsingDoubleBed hidden
	bool Function get()
		return BedStatus[1] == 3
	EndFunction
EndProperty
bool Property UseNPCBed hidden
	bool Function get()
		int NPCBed = Config.NPCBed
		return NPCBed == 2 || (NPCBed == 1 && (Utility.RandomInt(0, 1) as bool))
	EndFunction
EndProperty

; Genders
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

; Local readonly
string[] Hooks
string[] Tags
string ActorKeys

; Animating
float SkillTime

; ------------------------------------------------------- ;
; --- Thread Making API                               --- ;
; ------------------------------------------------------- ;

; ------------------------------------------------------- ;
; --- Animation Loop		                              --- ;
; ------------------------------------------------------- ;

; SFX
float SFXDelay
float SFXTimer

; Processing
bool TimedStage
float StageTimer

State Animating
	Event OnBeginState()
		SendThreadEvent("AnimationStart")
		If(LeadIn)
			SendThreadEvent("LeadInStart")
		EndIf
		StartedAt = Utility.GetCurrentRealTime()
		SkillTime = SkillTime
		SFXDelay = Config.SFXDelay
		PlayStageAnimations()
		ResolveTimers()
		StageTimer = StartedAt + GetTimer()
		RegisterForSingleUpdate(0.5)
		SendThreadEvent("StageStart")
		HookStageStart()
	EndEvent

	Function GoToStage(int ToStage)
		UnregisterForUpdate()
		SendThreadEvent("StageEnd")
		HookStageEnd()
		Log("Going to Stage: " + ToStage)
		Stage = ToStage
		If(Stage > Animation.StageCount)
			Log("Stage > Animation.StageCount")
			If(LeadIn)
				EndLeadInImpl()
			Else
				EndAnimation()
			EndIf
			return
		EndIf
		PlayStageAnimations()
		If(!LeadIn && Stage >= Animation.StageCount && !DisableOrgasms)
			SendThreadEvent("OrgasmStart")
			TriggerOrgasm()
		EndIf
		SFXDelay = PapyrusUtil.ClampFloat(Config.SFXDelay - (Stage * 0.3), 0.5, 30.0)
		ResolveTimers()
		StageTimer = SexLabUtil.GetCurrentGameRealTimeEx() + GetTimer()
		RegisterForSingleUpdate(0.5)
		SendThreadEvent("StageStart")
		HookStageStart()
	EndFunction
	
	Event OnUpdate()
		float rt = SexLabUtil.GetCurrentGameRealTimeEx()
		If((AutoAdvance || TimedStage || Animation.HasTimer(Stage)) && StageTimer < rt)
			GoToStage(Stage + 1)
			return
		EndIf
		; Play SFX	
		; IDEA: Decouple from main loop and use actor specific ones instead
		If(SoundFX && SFXTimer < rt)
			SoundFX.Play(_Center)
			SFXTimer = rt + SFXDelay
		EndIf
		RegisterForSingleUpdate(0.5)
	EndEvent
	
	Event OnKeyDown(int KeyCode)
		MiscUtil.PrintConsole("OnKeyDown > " + KeyCode)
		If(Utility.IsInMenuMode())
			Log("Input while locked. Skipping ...")
			return
		EndIf
		int hotkey = Hotkeys.Find(KeyCode)
		If(hotkey == kAdvanceAnimation)
			AdvanceStage(Config.BackwardsPressed())
		ElseIf(hotkey == kChangeAnimation)
			ChangeAnimation(Config.BackwardsPressed())
		ElseIf(hotkey == kAdjustForward)
			AdjustForward(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf(hotkey == kAdjustUpward)
			AdjustUpward(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf(hotkey == kAdjustSideways)
			AdjustSideways(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf(hotkey == kRotateScene)
			RotateScene(Config.BackwardsPressed())
		ElseIf(hotkey == kAdjustSchlong)
			AdjustSchlong(Config.BackwardsPressed())
		ElseIf(hotkey == kAdjustChange)			; Change Adjusting Position
			AdjustChange(Config.BackwardsPressed())
		ElseIf(hotkey == kRealignActors)
			RealignActors()
		ElseIf(hotkey == kChangePositions)	; Change Positions
			ChangePositions()
		ElseIf(hotkey == kRestoreOffsets)		; Reset animation offsets
			RestoreOffsets()
		ElseIf(hotkey == kMoveScene)
			MoveScene()
		ElseIf(hotkey == kEndAnimation)
			If(Config.BackwardsPressed())
				Config.ThreadSlots.StopAll()
			Else
				EndAnimation()
			EndIf
			return
		EndIf
	EndEvent

	; TODO: This should realign actors on native level
	Function RealignActors()
		; float[] offsets = Animation.PositionOffsets(AdjustKey, Stage)
		; sslpp.SetPositionsEx(Positions, _Center, offsets)
	EndFunction

; ------------------------------------------------------- ;
; --- TODO: REVIEW EVERYTHING BELOW                   --- ;
; ------------------------------------------------------- ;

	Function TriggerOrgasm()
		UnregisterForUpdate()
		if SoundFX
			SoundFX.Play(_Center)
		endIf
		QuickEvent("Orgasm")
		RegisterForSingleUpdate(0.5)
	EndFunction

	Function ChangeActors(Actor[] NewPositions)
		NewPositions = PapyrusUtil.RemoveActor(NewPositions, none)
		If(NewPositions.Length == Positions.Length)
			int i = 0
			While(i < NewPositions.Length)
				If(Positions.Find(NewPositions[i]) == -1)
					i = NewPositions.Length
				EndIf
				i += 1
			EndWhile
			If(i == NewPositions.Length)
				return
			EndIf
		ElseIf(!NewPositions.Length || NewPositions.Length > POSITION_COUNT_MAX)
			return
		EndIf
		UnregisterforUpdate()
		SendThreadEvent("ActorChangeStart")
		int i = 0
		While(i < Positions.Length)
			int w = NewPositions.Find(Positions[i])
			If(w == -1)
				ActorAlias[i].Initialize()
			EndIf
			i += 1
		EndWhile
		int n = 0
		While(n < NewPositions.Length)
			int w = Positions.Find(NewPositions[n])
			If(w == -1)
				sslActorAlias slot = PickAlias(NewPositions[n])
				If(slot.SetActor(NewPositions[n]))
					slot.SetData()
					If(NewPositions[n].GetActorValue("Paralysis") > 0)
						NewPositions[n].SetActorValue("Paralysis", 0.0)
						slot.SendDefaultAnimEvent()
						slot.PlaceActor(_Center)
					EndIf
				EndIf
			EndIf
			n += 1
		EndWhile
		ArrangePositions()
		RealignActors()

		int[] keys = GetPositionDataConfig()
		If(!Animation.MatchKeys(keys))
			If(Genders[2] || Genders[3])
				PrimaryAnimations = CreatureSlots._GetAnimations(keys, Tags)
			Else
				PrimaryAnimations = AnimSlots._GetAnimations(keys, Tags)
			EndIf
			If(!PrimaryAnimations.Length)
				If(Genders[2] || Genders[3])
					PrimaryAnimations = CreatureSlots._GetAnimations(keys, none)
				Else
					PrimaryAnimations = AnimSlots._GetAnimations(keys, none)
				EndIf
			EndIf
			If(PrimaryAnimations.Length)
				int r = Utility.RandomInt(0, PrimaryAnimations.Length - 1)
				Animation = PrimaryAnimations[r]
				If(LeadIn)
					EndLeadInImpl()
				Else
					GoToStage(Stage)
				EndIf
			Else
				Log("ERROR - Changing Actors but no animations available to animate new Set. Ending animation...")
				EndAnimation()
			EndIf
		Else
			GoToStage(Stage)
		EndIf
		SendThreadEvent("ActorChangeEnd")
	EndFunction

	Event OnEndState()
		UnregisterForUpdate()
		If(!LeadIn && Stage >= Animation.StageCount && !DisableOrgasms)
			SendThreadEvent("OrgasmEnd")
		EndIF
	EndEvent
EndState

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

Function SetStartAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState", float PlayTime = 0.1)
	ActorAlias(ActorRef).SetStartAnimationEvent(EventName, PlayTime)
EndFunction

Function SetEndAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState")
	ActorAlias(ActorRef).SetEndAnimationEvent(EventName)
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
int Function GetPlayerPosition()
	return Positions.Find(PlayerRef)
EndFunction

int Function GetPosition(Actor ActorRef)
	return Positions.Find(ActorRef)
EndFunction

bool Function PregnancyRisk(Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
	return ActorRef && HasActor(ActorRef) && ActorCount > 1 && ActorAlias(ActorRef).PregnancyRisk() \
		&& (Males > 0 || (AllowFemaleCum && Females > 1 && Config.AllowFFCum) || (AllowCreatureCum && MaleCreatures > 0))
EndFunction

; ------------------------------------------------------- ;
; --- Victim Data 				                            --- ;
; ------------------------------------------------------- ;

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
	If(!vic)
		return
	EndIf
	vic.SetVictim(Victimize)
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
; --- Animation Setup                                 --- ;
; ------------------------------------------------------- ;

sslBaseAnimation[] Function GetForcedAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(CustomAnimations.Length)
	int i = CustomAnimations.Length
	while i > 0
		i -= 1
		Output[i] = CustomAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearForcedAnimations()
	CustomAnimations = sslUtility.AnimationArray(0)
EndFunction

sslBaseAnimation[] Function GetAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(PrimaryAnimations.Length)
	int i = PrimaryAnimations.Length
	while i > 0
		i -= 1
		Output[i] = PrimaryAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearAnimations()
	PrimaryAnimations = sslUtility.AnimationArray(0)
EndFunction

sslBaseAnimation[] Function GetLeadAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(LeadAnimations.Length)
	int i = LeadAnimations.Length
	while i > 0
		i -= 1
		Output[i] = LeadAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearLeadAnimations()
	LeadAnimations = sslUtility.AnimationArray(0)
EndFunction

; ------------------------------------------------------- ;
; --- Thread Settings                                 --- ;
; ------------------------------------------------------- ;

; If any of the given Actors is using a Furniture
; return: -1 if not, 1+ for bed, 0 for any other furniture
int Function AreUsingFurniture(Actor[] ActorList)	
	int i = 0
	While(i < ActorList.Length)
		ObjectReference ref = ActorList[i].GetFurnitureReference()
		If(ref)
			return ThreadLib.GetBedType(ref)
		EndIf
		i += 1
	EndWhile
	return -1
EndFunction

; ------------------------------------------------------- ;
; --- Event Hooks                                     --- ;
; ------------------------------------------------------- ;

Function SetHook(string AddHooks)
	string[] newHooks = PapyrusUtil.StringSplit(AddHooks)
	Hooks = sslpp.MergeStringArrayEx(Hooks, newHooks, true)
EndFunction

string[] Function GetHooks()
	return PapyrusUtil.ClearEmpty(Hooks)
EndFunction

Function RemoveHook(string DelHooks)
	string[] remove = PapyrusUtil.StringSplit(DelHooks)
	int i = 0
	While(i < remove.Length)
		int where = Hooks.Find(remove[i])
		If(where > -1)
			Hooks[where] = ""
		EndIf
		i += 1
	EndWhile
	Hooks = PapyrusUtil.ClearEmpty(Hooks)
EndFunction

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;

string[] Function GetTags()
	return PapyrusUtil.ClearEmpty(Tags)
EndFunction

bool Function HasTag(string Tag)
	return Tags.Find(Tag) != -1
EndFunction

bool Function AddTag(string Tag)
	if Tag != "" && Tags.Find(Tag) == -1
		Tags = PapyrusUtil.PushString(Tags, Tag)
		return true
	endIf
	return false
EndFunction

bool Function AddTags(String[] asTags)
	Tags = sslpp.MergeStringArrayEx(Tags, asTags, true)
	return true
EndFunction

bool Function RemoveTag(string Tag)
	if Tag != "" && Tags.Find(Tag) != -1
		Tags = PapyrusUtil.RemoveString(Tags, Tag)
		return true
	endIf
	return false
EndFunction

; ------------------------------------------------------- ;
; --- Actor Alias                                     --- ;
; ------------------------------------------------------- ;

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

; ------------------------------------------------------- ;
; ---	Animation	Start                                 --- ;
; ------------------------------------------------------- ;

int[] Function ShiftKeys(int[] aiKeys)
	; IDEA: Shift Futas first to female, then to male
	int k = aiKeys.Length
	While(k > 0)
		k -= 1
		If(sslActorData.IsFuta(aiKeys[k]))
			If(Config.iFutaBehavior == 0)
				If(!sslActorData.IsMaleOverwrite(aiKeys[k]))
					ActorAlias[k].OverwriteMyGender(false)
					ArrangePositions()
					return GetPositionDataConfig()
				EndIf
			ElseIf(Config.iFutaBehavior == 1)
				If(!sslActorData.IsFemaleOverwrite(aiKeys[k]))
					ActorAlias[k].OverwriteMyGender(true)
					ArrangePositions()
					return GetPositionDataConfig()
				EndIf
			EndIf
		EndIf
	EndWhile
	int i = aiKeys.Length
	While(i > 0)
		i -= 1
		If(sslActorData.IsFemale(aiKeys[i]) && !sslActorData.IsMaleOverwrite(aiKeys[i]))
			ActorAlias[i].OverwriteMyGender(false)
			ArrangePositions()
			return GetPositionDataConfig()
		EndIf
	EndWhile
	return Utility.CreateIntArray(0)
EndFunction

; Assume all Actors have all necessary data set
; Final preperations before starting the animation. Stripping, Position, ...
Function PlaceActors()
	float w = 0.0
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].PlaceActor(_Center)
		If(!sslActorData.IsCreature(ActorAlias[i].GetActorData()))
			ActorAlias[i].Strip()
			float ww = ActorAlias[i].HandleStartAnimation()
			If(ww > w)
				w = ww
			EndIf
		EndIf
		i += 1
	EndWhile
	; If placing includes an animation, wait for longest to finish
	If(w > 0)
		Utility.Wait(w)
	EndIf
	RealignActors()
EndFunction

; ------------------------------------------------------- ;
; ---	Animation				                                --- ;
; ------------------------------------------------------- ;

; TODO: THis here should set the _ActiveScene variable

; Set the Active Animation & update the stage
; This should only be called from State "Animating"
Function SetAnimation(int aid = -1)
	if aid < 0 || aid >= Animations.Length
		aid = Utility.RandomInt(0, (Animations.Length - 1))
	endIf
	RecordSkills()
	SetAnimationImpl(Animations[aid])
	; This is only called when changing animation from an active one
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].SendDefaultAnimEvent()
		i += 1
	EndWhile
	Utility.Wait(0.2)
	GoToStage(1)
EndFunction

; Set active animation data only
Function SetAnimationImpl(sslBaseAnimation akAnimation)
	LogConsole("Setting Animation to " + akAnimation.Name)
	Animation = akAnimation
	; IsType = [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty, [6] HadVaginal, [7] HadAnal, [8] HadOral
	String[] animtags = Animation.GetTags()
	IsType[1] = animtags.Find("Vaginal") != -1
	IsType[2] = animtags.Find("Anal") != -1
	IsType[3] = animtags.Find("Oral") != -1
	IsType[4] = animtags.Find("Loving") != -1
	IsType[5] = animtags.Find("Dirty") != -1
	SetBonuses()
	SoundFX = Animation.GetSoundFX(Stage)
EndFunction

Function PlayStageAnimations()
	; split into 2 loops to minimize possible delays for anim event calls
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].SyncThread()
		i += 1
	EndWhile
	Animation.GetAnimEvents(AnimEvents, Stage)
	Log("Playing Stage Animations for animation " + Animation.Name + " with Events = " + AnimEvents)
	int n = 0
	While(n < Positions.Length)
		ActorAlias[n].PlayAnimation(AnimEvents[n])
		n += 1
	EndWhile
	RealignActors()
EndFunction

; End leadin -> Start default animation
Function EndLeadInImpl()
	Stage  = 1
	LeadIn = false
	SetAnimation()
	; Add runtime to foreplay skill xp
	SkillXP[0] = SkillXP[0] + (TotalTime / 10.0)
	; Restrip with new strip options
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].Strip()
		i += 1
	EndWhile
	StorageUtil.SetFloatValue(Config, "SexLab.LastLeadInEnd", SexLabUtil.GetCurrentGameRealTimeEx())
	SendThreadEvent("LeadInEnd")
	GoToStage(1)
EndFunction

; ------------------------------------------------------- ;
; ---	Timers  				                                --- ;
; ------------------------------------------------------- ;

; COMEBACK: Check if this works as intended
Function ResolveTimers()
	TimedStage = Animation.HasTimer(Stage)
	If(TimedStage)
		Log("Stage has timer: "+Animation.GetTimer(Stage))
	EndIf
	If(!UseCustomTimers)
		if LeadIn
			ConfigTimers = Config.StageTimerLeadIn
		elseIf IsAggressive
			ConfigTimers = Config.StageTimerAggr
		else
			ConfigTimers = Config.StageTimer
		endIf
	EndIf
EndFunction

Function UpdateTimer(float AddSeconds = 0.0)
	TimedStage = true
	StageTimer += AddSeconds
EndFunction

Function SetTimers(float[] SetTimers)
	if !SetTimers || SetTimers.Length < 1
		Log("SetTimers() - Empty timers given.", "ERROR")
	else
		CustomTimers    = SetTimers
		UseCustomTimers = true
	endIf
EndFunction

float Function GetTimer()
	TimedStage = Animation.HasTimer(Stage)
	if TimedStage
		return Animation.GetTimer(Stage)
	endIf
	return GetStageTimer(Animation.StageCount)
EndFunction

float Function GetStageTimer(int maxstage)
	int last = Timers.Length - 1
	if Stage < last
		return Timers[(Stage - 1)]
	elseIf Stage >= maxstage
		return Timers[last]
	endIf
	return Timers[(last - 1)]
endfunction

; ------------------------------------------------------- ;
; ---	Animation	End		                                --- ;
; ------------------------------------------------------- ;

Function EndAnimation(bool Quickly = false)
	; UnregisterForUpdate()
	; Apparently the OnUpdate() cycle can carry over into a new state despite being unregistered
	; Removing this wait causes the OnUpdate() Event to sometimes be called before the OnBeginState() can finish
	; Utility.Wait(0.6)
	GoToState("Ending")
EndFunction

State Ending
	Event OnBeginState()
		RegisterForSingleUpdateGameTime(0.05)	; 9 seconds with timescale 20
		SendThreadEvent("AnimationEnding")
		HookAnimationEnding()
		DisableHotkeys()
		Config.DisableThreadControl(self as sslThreadController)
		If(IsObjectiveDisplayed(0))
			SetObjectiveDisplayed(0, False)
		EndIf
		RecordSkills()
		UnplaceActors()
		If(UsingBed)
			SetFurnitureIgnored(false)
		EndIf
		int i = 0
		While(i < Positions.Length)
			ActorAlias[i].DoStatistics()
			ActorAlias[i].Clear()
			i += 1
		EndWhile
		SendThreadEvent("AnimationEnd")
		HookAnimationEnd()
	EndEvent

	Event OnUpdateGameTime()
		Log("Animation End Timeout over, initializing...")
		Initialize()
	EndEvent
	Event OnEndState()
		Log("Returning to thread pool...")
	EndEvent

	Function EndAnimation(bool Quickly = false)
	EndFunction
EndState

; Only call on placed actors, will unplace all actors, allowing them to move freely again
; Will take them out of the animation if currently animating
Function UnplaceActors()
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].UnplaceActor()
		If(!sslActorData.IsCreature(ActorAlias[i].GetActorData()))
			ActorAlias[i].Unstrip()
			ActorAlias[i].RemoveStrapon()
		EndIf
		i += 1
	EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Tagging                                         --- ;
; ------------------------------------------------------- ;

Function AddCommonTags(String[] asScenes) ; TODO: move out of here and rewrite
	; String[] commons = akAnimations[0].GetTags()
	; int i = 1
	; While(i < akAnimations.Length)
	; 	String[] animtags = akAnimations[i].GetTags()
	; 	int k = commons.Length
	; 	While(k > 0)
	; 		k -= 1
	; 		If(animtags.Find(commons[k]) == -1)
	; 			commons = sslpp.RemoveStringEx(commons, commons[k])
	; 			If(!commons.Length)
	; 				return
	; 			EndIf
	; 		EndIf
	; 	EndWhile
	; 	i += 1
	; EndWhile
	; AddTags(commons)
EndFunction

; ------------------------------------------------------- ;
; --- Center                                          --- ;
; ------------------------------------------------------- ;

Function CenterOnCoords(float LocX = 0.0, float LocY = 0.0, float LocZ = 0.0, float RotX = 0.0, float RotY = 0.0, float RotZ = 0.0, bool resync = true)
	_Center.SetPosition(LocX, LocY, LocZ)
	_Center.SetAngle(CenterLocation[3], CenterLocation[4], RotZ)
	CenterLocation[0] = LocX
	CenterLocation[1] = LocY
	CenterLocation[2] = LocZ
	CenterLocation[5] = RotZ
	If(resync)
		RealignActors()
		SendThreadEvent("ActorsRelocated")
	EndIf
EndFunction

bool Function CenterOnBed(bool AskPlayer = true, float Radius = 750.0)
	CenterOnBedEx(AskPlayer, Radius, true)
EndFunction

bool Function CenterOnBedEx(bool abAskPlayer = true, float afRadius = 750.0, bool abResync)
	If(BedStatus[0] == -1)
		return false
	ElseIf(GetState() == "Making" && (!HasPlayer && Config.NPCBed == 0 || HasPlayer && Config.AskBed == 0))
		return false
	EndIf
 	ObjectReference FoundBed
	int i = 0
	While (i < Positions.Length)
		FoundBed = Positions[i].GetFurnitureReference()
		int BedType = ThreadLib.GetBedType(FoundBed)	; 0 if no bed
		If(BedType > 0 && (Positions.Length <= 2 || BedType != 2))
			CenterOnObject(FoundBed, abResync)
			return true
		Else
			i += 1
		EndIf
	EndWhile
	afRadius *= 1 + BedStatus[0]
	If(HasPlayer)
		; Config.AskBed: 0 - Never, 1 - Alwys, 2 - If not victim
		If(;/ !InStart || /; Config.AskBed == 1 || Config.AskBed == 2 && (!IsVictim(PlayerRef) || UseNPCBed))
			FoundBed = sslpp.GetNearestUnusedBed(PlayerRef, afRadius)
			abAskPlayer = abAskPlayer && (;/ !InStart || /; Config.AskBed < 1 || !IsVictim(PlayerRef))
		EndIf
	Else
		abAskPlayer = false
		If(!FoundBed && UseNPCBed)
			FoundBed = sslpp.GetNearestUnusedBed(PlayerRef, afRadius)
		EndIf
	EndIf
	If(FoundBed && (BedStatus[0] == 1 || !abAskPlayer || UseBed.Show() as bool))
		CenterOnObject(FoundBed, abResync)
		return true
	endIf
	return false
EndFunction

; ------------------------------------------------------- ;
; --- Skill System			                              --- ;
; ------------------------------------------------------- ;

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

; ------------------------------------------------------- ;
; --- Misc Utility					                          --- ;
; ------------------------------------------------------- ;

Function SetFurnitureIgnored(bool disabling = true)
	If(!BedRef)
		return
	EndIf
	BedRef.SetDestroyed(disabling)
	BedRef.BlockActivation(disabling)
	BedRef.SetNoFavorAllowed(disabling)
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

; ------------------------------------------------------- ;
; --- Hotkey functions                                --- ;
; ------------------------------------------------------- ;

sslActorAlias AdjustAlias		; The actor currently selected for position adjustments

int[] Hotkeys
int kAdvanceAnimation = 0
int kChangeAnimation  = 1
int kChangePositions  = 2
int kAdjustChange     = 3
int kAdjustForward    = 4
int kAdjustSideways   = 5
int kAdjustUpward     = 6
int kRealignActors    = 7
int kRestoreOffsets   = 8
int kMoveScene        = 9
int kRotateScene      = 10
int kEndAnimation     = 11
int kAdjustSchlong    = 12

Function EnableHotkeys(bool forced = false)
	If(!HasPlayer && !forced)
		return
	EndIf
	Hotkeys = new int[13]
	Hotkeys[kAdvanceAnimation] = Config.AdvanceAnimation
	Hotkeys[kChangeAnimation] = Config.ChangeAnimation
	Hotkeys[kChangePositions] = Config.ChangePositions
	Hotkeys[kAdjustSideways] = Config.AdjustSideways
	Hotkeys[kRestoreOffsets] = Config.RestoreOffsets
	Hotkeys[kAdjustForward] = Config.AdjustForward
	Hotkeys[kRealignActors] = Config.RealignActors
	Hotkeys[kAdjustSchlong] = Config.AdjustSchlong
	Hotkeys[kAdjustUpward] = Config.AdjustUpward
	Hotkeys[kAdjustChange] = Config.AdjustChange
	Hotkeys[kEndAnimation] = Config.EndAnimation
	Hotkeys[kRotateScene] = Config.RotateScene
	Hotkeys[kMoveScene] = Config.MoveScene
	int i = 0
	While(i < Hotkeys.Length)
		RegisterForKey(Hotkeys[i])
		i += 1
	Endwhile
EndFunction

Function DisableHotkeys()
	UnregisterForAllKeys()
EndFunction

int Function GetAdjustPos()
	int AdjustPos = -1
	if AdjustAlias && AdjustAlias.ActorRef
		AdjustPos = Positions.Find(AdjustAlias.ActorRef)
	endIf
	if AdjustPos == -1 && Config.TargetRef
		AdjustPos = Positions.Find(Config.TargetRef)
	endIf
	if AdjustPos == -1
		AdjustPos = (ActorCount > 1) as int
	endIf
	if Positions[AdjustPos] != PlayerRef
		Config.TargetRef = Positions[AdjustPos]
	endIf
	AdjustAlias = PositionAlias(AdjustPos)
	return AdjustPos
EndFunction

Function AdvanceStage(bool backwards = false)
	If(!backwards)
		GoToStage(Stage + 1)
	Elseif(Config.IsAdjustStagePressed())
		GoToStage(1)
	ElseIf(Stage > 1)
		GoToStage(Stage - 1)
	EndIf
EndFunction

Function ChangeAnimation(bool backwards = false)
	If(Animations.Length <= 1)
		return
	EndIf
	UnregisterForUpdate()
	Log("Changing Animation")
	If(!Config.AdjustStagePressed())	; Forward/Backward
		SetAnimation(sslUtility.IndexTravel(Animations.Find(Animation), Animations.Length, backwards))
	Else	; Random
		int current = Animations.Find(Animation)
		int r = Utility.RandomInt(0, Animations.Length - 1)
		While(r == current)
			r = Utility.RandomInt(0, Animations.Length - 1)
		EndWhile
		SetAnimation(r)
	endIf
	SendThreadEvent("AnimationChange")
	RegisterForSingleUpdate(0.2)
EndFunction

Function AdjustForward(bool backwards = false, bool AdjustStage = false)
	UnregisterforUpdate()
	float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
	int AdjustPos = GetAdjustPos()
	While(true)
		PlayHotkeyFX(0, backwards)
		Animation.AdjustForward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
		AdjustAlias.RefreshLoc()
		Utility.Wait(0.1)
		If(!Input.IsKeyPressed(Hotkeys[kAdjustForward]))
			RegisterForSingleUpdate(0.2)
			return
		EndIf
		Utility.Wait(0.4)
	EndWhile
EndFunction

Function AdjustSideways(bool backwards = false, bool AdjustStage = false)
	UnregisterforUpdate()
	int AdjustPos = GetAdjustPos()
	float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
	While(true)
		PlayHotkeyFX(0, backwards)
		Animation.AdjustSideways(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
		RealignActors()
		Utility.Wait(0.1)
		If(!Input.IsKeyPressed(Hotkeys[kAdjustSideways]))
			RegisterForSingleUpdate(0.2)
			return
		EndIf
		Utility.Wait(0.4)
	EndWhile
EndFunction

Function AdjustUpward(bool backwards = false, bool AdjustStage = false)
	UnregisterforUpdate()
	int AdjustPos = GetAdjustPos()
	float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
	While(true) 
		PlayHotkeyFX(2, backwards)
		Animation.AdjustUpward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
		RealignActors()
		Utility.Wait(0.1)
		If(!Input.IsKeyPressed(Hotkeys[kAdjustUpward]))
			RegisterForSingleUpdate(0.2)
			return
		EndIf
		Utility.Wait(0.4)
	EndWhile
EndFunction

Function RotateScene(bool backwards = false)
	UnregisterForUpdate()
	float Amount = 15.0
	If(Config.IsAdjustStagePressed())
		Amount = 180.0
	EndIf
	Amount = PapyrusUtil.SignFloat(backwards, Amount)
	While(true)	; Pseudo do-while loop
		PlayHotkeyFX(1, !backwards)
		CenterLocation[5] = CenterLocation[5] + Amount
		If(CenterLocation[5] >= 360.0)
			CenterLocation[5] = CenterLocation[5] - 360.0
		ElseIf(CenterLocation[5] < 0.0)
			CenterLocation[5] = CenterLocation[5] + 360.0
		EndIf
		CenterOnCoords(CenterLocation[0], CenterLocation[1], CenterLocation[2], 0, 0, CenterLocation[5], true)
		Utility.Wait(0.1)
		If(!Input.IsKeyPressed(Hotkeys[kRotateScene]))
			RegisterForSingleUpdate(0.2)
			return
		EndIf
		Utility.Wait(0.4)
	EndWhile
EndFunction

Function AdjustSchlong(bool backwards = false)
	int Amount  = PapyrusUtil.SignInt(backwards, 1)
	int AdjustPos = GetAdjustPos()
	int Schlong = Animation.GetSchlong(AdjustKey, AdjustPos, Stage) + Amount
	If(Math.Abs(Schlong) <= 9)
		Animation.AdjustSchlong(AdjustKey, AdjustPos, Stage, Amount)
		Debug.SendAnimationEvent(Positions[AdjustPos], "SOSBend"+Schlong)
		PlayHotkeyFX(2, !backwards)
	EndIf
EndFunction

Function AdjustChange(bool backwards = false)
	If(Positions.Length <= 1)
		return
	EndIf
	int i = GetAdjustPos()
	i = sslUtility.IndexTravel(i, ActorCount, backwards)
	If(Positions[i] != PlayerRef)
		Config.TargetRef = Positions[i]
	EndIf
	AdjustAlias = ActorAlias[i]
	Config.SelectedSpell.Cast(Positions[i])	; SFX for visual feedback
	PlayHotkeyFX(0, !backwards)
	String msg = "Adjusting Position For: " + AdjustAlias.GetActorName()
	Debug.Notification(msg)
	SexLabUtil.PrintConsole(msg)
EndFunction

Function RestoreOffsets()
	Animation.RestoreOffsets(AdjustKey)
	RealignActors()
EndFunction

Function MoveScene()
	UnregisterForUpdate()
	; Processing Furnitures
	If(BedStatus[1])
		SetFurnitureIgnored(false)
	EndIf
	; Make sure the player cannot activate anything, change worldspaces or start combat on their own
	Game.DisablePlayerControls(false, true, false, false, true)
	sslActorAlias PlayerSlot = ActorAlias(PlayerRef)
	int n = 0
	While(n < Positions.Length)
		Debug.Trace("Resetting Actor: " + n)
		If(ActorAlias[n] == PlayerSlot)
			ActorAlias[n].UnplaceActor()
		Else
			ActorAlias[n].SendDefaultAnimEvent(true)
		EndIf
		n += 1
	EndWhile
	Utility.Wait(1)
	; TODO: Make some message objects to display here
	Debug.Messagebox("You have 30 secs to position yourself to a new center location.\nHold down the 'Move Scene' hotkey to relocate the center instantly to your current position")
	int i = 0
	While(i < 60 && !Input.IsKeyPressed(Hotkeys[kMoveScene]))
		Utility.Wait(0.5)
		i += 1
	EndWhile
	Game.DisablePlayerControls()	; make sure player isnt moving before resync
	float x = PlayerRef.X
	float y = PlayerRef.Y
	float z = PlayerRef.Z
	Utility.Wait(0.5)							; wait for momentum to stop
	While(x != PlayerRef.X || y != PlayerRef.Y || z != PlayerRef.Z)
		x = PlayerRef.X
		y = PlayerRef.Y
		z = PlayerRef.Z
		Utility.Wait(0.5)
	EndWhile
	If(PlayerSlot)
		PlayerSlot.PlaceActor(_Center)
	EndIf
	If(BedStatus[1] >= 2)					; Bed or DoubleBled
		CenterOnBedEx(false, 300.0, true)
	Else
		CenterOnObject(PlayerRef, true)
	EndIf
	Game.EnablePlayerControls()		; placing doesnt interact with player controls
	GoToStage(1)									; Will re-register the update loop
EndFunction

Function ChangePositions(bool backwards = false)
	If(Positions.Length < 2)
		return
	EndIf
	int[] keys = Animation.DataKeys()
	int pos = GetAdjustPos()
	int i = pos + 1
	While(i < Positions.Length + pos)
		If(i >= Positions.Length)
			i -= Positions.Length
		EndIf
		If(sslActorData.Match(keys[pos], keys[i]) && sslActorData.Match(keys[i], keys[pos]))
			Actor tmp = Positions[pos]
			sslActorAlias tmp2 = ActorAlias[pos]
			Positions[pos] = Positions[i]
			Positions[i] = tmp
			ActorAlias[pos] = ActorAlias[i]
			ActorAlias[i] = tmp2
			RealignActors()
			GoToStage(1)
			SendThreadEvent("PositionChange")
			return
		EndIf
		i += 1
	EndWhile
	Debug.Notification("Selected actor cannot switch positions")
EndFunction


Function PlayHotkeyFX(int i, bool backwards)
	if backwards
		Config.HotkeyDown[i].Play(PlayerRef)
	else
		Config.HotkeyUp[i].Play(PlayerRef)
	endIf
EndFunction

; ------------------------------------------------------- ;
; --- Thread Hooks & Events                           --- ;
; ------------------------------------------------------- ;

sslThreadHook[] ThreadHooks
Function HookAnimationStarting()
	int i = 0
	While (i < ThreadHooks.Length)
		If ThreadHooks[i].CanRunHook(Positions, Tags)
			If (ThreadHooks[i].AnimationStarting(self))
				Log("Blocking Hook AnimationStarting("+self+") - "+ThreadHooks[i])
			EndIf
			If (ThreadHooks[i].AnimationPrepare(self as sslThreadController))
				Log("Blocking Hook AnimationPrepare("+self+") - "+ThreadHooks[i])
			EndIf
		EndIf
		i += 1
	endWhile
EndFunction

Function HookStageStart()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].StageStart(self as sslThreadController)
			Log("Global Hook StageStart("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookStageStart() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookStageEnd()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].StageEnd(self as sslThreadController)
			Log("Global Hook StageEnd("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookStageEnd() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationEnding()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationEnding(self as sslThreadController)
			Log("Global Hook AnimationEnding("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationEnding() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationEnd()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationEnd(self as sslThreadController)
			Log("Global Hook AnimationEnd("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationEnd() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function SendThreadEvent(string HookEvent)
	Log(HookEvent, "Event Hook")
	SetupThreadEvent(HookEvent)
	int i = Hooks.Length
	while i
		i -= 1
		SetupThreadEvent(HookEvent+"_"+Hooks[i])
	endWhile
	; Legacy support for < v1.50 - To be removed eventually
	if HasPlayer
		SendModEvent("Player"+HookEvent, thread_id)
	endIf
EndFunction

Function SetupThreadEvent(string HookEvent)
	int eid = ModEvent.Create("Hook"+HookEvent)
	if eid
		ModEvent.PushInt(eid, thread_id)
		ModEvent.PushBool(eid, HasPlayer)
		ModEvent.Send(eid)
		; Log("Thread Hook Sent: "+HookEvent)
	endIf
	SendModEvent(HookEvent, thread_id)
EndFunction

; ------------------------------------------------------- ;
; --- Alias Events									                  --- ;
; ------------------------------------------------------- ;

int preparesDone = 0	; Sync Event complete counter
bool SyncLock = false	; pseudo mutex

String Function Key(string Callback)
	return "SSL_" + thread_id + "_" + Callback
EndFunction

Function QuickEvent(string Callback)
	ModEvent.Send(ModEvent.Create(Key(Callback)))
endfunction

function SyncEvent(int id, float WaitTime)
endFunction
function SyncEventDone(int id)
endFunction

; ------------------------------------------------------- ;
; --- Thread Setup    								                --- ;
; ------------------------------------------------------- ;

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

; This is only called once when the Framework is first initialized
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
	DisableHotkeys()
	Config.DisableThreadControl(self as sslThreadController)
	int i = 0
	While(i < ActorAlias.Length)
		ActorAlias[i].Initialize()
		i += 1
	EndWhile
	CenterAlias.TryToClear()
	; Forms
	Animation = none
	CenterRef = none
	SoundFX = none
	BedRef = none
	StartingAnimation = none
	; Boolean
	UseCustomTimers = false
	DisableOrgasms = false
	AutoAdvance = true
	LeadIn = false
	; Floats
	StartedAt = 0.0
	SkillTime = 0.0
	; Integers
	Stage = 1
	; Storage Data
	AnimEvents = new string[5]
	IsType = new bool[9]
	BedStatus = new int[2]
	SkillXP = new float[6]
	SkillBonus = new float[6]
	CenterLocation = new float[6]
	Genders = new int[4]
	Positions = PapyrusUtil.ActorArray(0)
	CustomAnimations = sslUtility.AnimationArray(0)
	PrimaryAnimations = sslUtility.AnimationArray(0)
	LeadAnimations = sslUtility.AnimationArray(0)
	Hooks = Utility.CreateStringArray(0)
	Tags = Utility.CreateStringArray(0)
	CustomTimers = Utility.CreateFloatArray(0)
	; Enter thread selection pool
	GoToState("Unlocked")
EndFunction

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; State varied
Function FireAction()
EndFunction
Function EndAction()
EndFunction
Function SyncDone()
EndFunction
Function RefreshDone()
EndFunction
Function PrepareDone()
EndFunction
Function ResetDone()
EndFunction
Function StripDone()
EndFunction
Function OrgasmDone()
EndFunction
Function StartupDone()
EndFunction
; Animating
Function TriggerOrgasm()
EndFunction
Function GoToStage(int ToStage)
EndFunction
Function ChangeActors(Actor[] NewPositions)
EndFunction
Function RealignActors()
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

bool Function HasPlayer()
	return HasPlayer
EndFunction
Actor Function GetPlayer()
	return PlayerRef
EndFunction
Actor Function GetVictim()
	return VictimRef
EndFunction
float Function GetTime()
	return StartedAt
endfunction

bool Property FastEnd auto hidden

Actor[] property Victims
	Actor[] Function Get()
		GetAllVictims()
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

; Unnecessary, just use OnBeginState()/OnEndState()
Function Action(string FireState)
	UnregisterForUpdate()
	EndAction()
	GoToState(FireState)
	FireAction()
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

bool Function HasActor(Actor ActorRef)
	return Positions.Find(ActorRef) != -1
EndFunction

int Property ActorCount
	int Function Get()
		return Positions.Length
	EndFunction
EndProperty

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
EndProperty

float[] Property RealTime
	float[] Function Get()
		float[] ret = new float[1]
		ret[0] = SexLabUtil.GetCurrentGameRealTimeEx()
		return ret
	EndFunction
EndProperty

Function UpdateAdjustKey()
EndFunction

Function DisableRagdollEnd(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoRagdoll = !disabling
	else
		ActorAlias[0].DoRagdoll = !disabling
		ActorAlias[1].DoRagdoll = !disabling
		ActorAlias[2].DoRagdoll = !disabling
		ActorAlias[3].DoRagdoll = !disabling
		ActorAlias[4].DoRagdoll = !disabling
	endIf
EndFunction

bool Function CheckTags(string[] CheckTags, bool RequireAll = true, bool Suppress = false)
	int i = CheckTags.Length
	while i
		i -= 1
		if CheckTags[i] != ""
			bool Check = Tags.Find(CheckTags[i]) != -1
			if (Suppress && Check) || (!Suppress && RequireAll && !Check)
				return false ; Stop if we need all and don't have it, or are supressing the found tag
			elseIf !Suppress && !RequireAll && Check
				return true ; Stop if we don't need all and have one
			endIf
		endIf
	endWhile
	return true
EndFunction

int Function FilterAnimations()
	LogRedundant("FilterAnimations")
	return 0
EndFunction

bool Function ToggleTag(string Tag)
	return (RemoveTag(Tag) || AddTag(Tag)) && HasTag(Tag)
EndFunction

bool Function AddTagConditional(string Tag, bool AddTag)
	if AddTag
		return AddTag(Tag)
	else
		return RemoveTag(Tag)
	endIf
EndFunction

Function InitShares()
EndFunction

Function SendTrackedEvent(Actor ActorRef, string Hook = "")
	ThreadLib.SendTrackedEvent(ActorRef, Hook, thread_id)
EndFunction

Function SetupActorEvent(Actor ActorRef, string Callback)
	ThreadLib.SetupActorEvent(ActorRef, Callback, thread_id)
EndFunction

; Because PapyrusUtil don't Remove Dupes from the Array
string[] Function AddString(string[] ArrayValues, string ToAdd, bool RemoveDupes = true)
	String[] add = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(ToAdd, ","))
	return sslpp.MergeStringArrayEx(ArrayValues, add, true)
EndFunction

string Function GetHook()
	return Hooks[0]
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
