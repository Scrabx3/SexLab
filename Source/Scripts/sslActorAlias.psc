ScriptName sslActorAlias extends ReferenceAlias
{
	Alias Script for Actors which are animated by a SexLab Thread
	See SexLabThread.psc for documentation and functions to correctly access this class
}

; TODO: Expressions, esp "OpenMouth" ones should be calculated in real time in the dll, 
; the dll respecting the "forced" flag but the script otherwise only requests this information from the dll, not controlling it

String Function GetActorName()
	return ActorRef.GetLeveledActorBase().GetName()
EndFunction

bool function IsVictim()
	return _victim
endFunction

bool Function IsAggressor()
	return _Thread.IsAggressive && !IsVictim()
EndFunction

Function SetVictim(bool Victimize)
	_victim = Victimize
EndFunction

int Function GetSex()
	return _sex
EndFunction

bool Function GetIsDead()
	return _livestatus == LIVESTATUS_DEAD
EndFunction

; ------------------------------------------------------- ;
; --- Orgasms                                         --- ;
; ------------------------------------------------------- ;

function DisableOrgasm(bool bNoOrgasm)
	_CanOrgasm = !bNoOrgasm
endFunction

bool function IsOrgasmAllowed()
	return _CanOrgasm
endFunction

int function GetOrgasmCount()
	return _OrgasmCount
EndFunction

; ------------------------------------------------------- ;
; --- Enjoyment & Pain                                --- ;
; ------------------------------------------------------- ;

; Pain based on context and interaction, dynamic, often reducing over time
int Function GetPain()
	return _PainEffective as int
EndFunction

; Enjoyment that takes psychological factors, physics/interactions, and pain into account
int Function GetEnjoyment()
	return _FullEnjoyment
EndFunction

; Same as GetEnjoyment(), for partial compatibility with SLSO based mods
int Function GetFullEnjoyment()
	return _FullEnjoyment
EndFunction

; Multiplication factor influencing the rate at which non-interaction enjoyment increases over time
; Dependent upon arousal, sexuality, best relation, and context (boosted a bit on stage advance too)
float Function GetEnjFactor()
	return _EnjFactor
EndFunction

Function AdjustPain(float AdjustBy)
	_AdjustPain = AdjustBy
EndFunction
Function AdjustEnjoyment(int AdjustBy)
	_AdjustEnjoyment = AdjustBy
EndFunction
Function AdjustEnjFactor(float AdjustBy)
	_AdjustEnjFactor = AdjustBy
EndFunction

; ------------------------------------------------------- ;
; --- Stripping									                      --- ;
; ------------------------------------------------------- ;

Function SetStripping(int aiSlots, bool abStripWeapons, bool abApplyNow)
	_stripCstm = new int[2]
	_stripCstm[0] = aiSlots
	_stripCstm[1] = abStripWeapons as int
	If (abApplyNow && GetState() == STATE_PLAYING)
		int[] set
		_equipment = StripByDataEx(0x80, set, _stripCstm, _equipment)
		ActorRef.QueueNiNodeUpdate()
	EndIf
EndFunction

Function DisableStripAnimation(bool abDisable)
	_DoUndress = !abDisable
EndFunction

Function SetAllowRedress(bool abAllowRedress)
	_AllowRedress = abAllowRedress
EndFunction

; ------------------------------------------------------- ;
; --- Strapon									                        --- ;
; ------------------------------------------------------- ;

Form function GetStrapon()
	return _Strapon
endFunction

bool function IsUsingStrapon()
	return _useStrapon && _Strapon && ActorRef.IsEquipped(_Strapon)
endFunction

Function SetStrapon(Form ToStrapon)
	Error("Called from invalid state", "SetStrapon()")
EndFunction

; ------------------------------------------------------- ;
; --- Voice                                           --- ;
; ------------------------------------------------------- ;

sslBaseVoice function GetVoice()
	return _Voice
endFunction

Function SetVoice(sslBaseVoice ToVoice = none, bool ForceSilence = false)
	_IsForcedSilent = ForceSilence
	if ToVoice && (_sex > 2) == ToVoice.Creature
		_Voice = ToVoice
	endIf
EndFunction

bool Function IsSilent()
	return IsSilent
EndFunction

; ------------------------------------------------------- ;
; --- Expression                                      --- ;
; ------------------------------------------------------- ;

String Function GetActorExpression()
	return _Expression
EndFunction

Function SetActorExpression(String asExpression)
	_Expression = asExpression
	TryRefreshExpression()
EndFunction

Function SetMouthForcedOpen(bool abForceOpen)
	OpenMouth = abForceOpen
EndFunction

; ------------------------------------------------------- ;
; --- Pathing                                         --- ;
; ------------------------------------------------------- ;

int Property PATHING_DISABLE = -1 AutoReadOnly
int Property PATHING_ENABLE = 0 AutoReadOnly
int Property PATHING_FORCE = 1 AutoReadOnly

Function SetPathing(int aiPathingFlag)
	_PathingFlag = PapyrusUtil.ClampInt(_PathingFlag, PATHING_DISABLE, PATHING_FORCE)
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

sslThreadModel _Thread
sslSystemConfig _Config

Faction _AnimatingFaction
Actor _PlayerRef
Form _xMarker

; Constants
String Property STATE_IDLE 		= "Empty" AutoReadOnly
String Property STATE_SETUP		= "Ready" AutoReadOnly
String Property STATE_PAUSED	= "Paused" AutoReadOnly
String Property STATE_PLAYING = "Animating" AutoReadOnly

String Property TRACK_ADDED 	= "Added" AutoReadOnly
String Property TRACK_START 	= "Start" AutoReadOnly
String Property TRACK_END		 	= "End" AutoReadOnly

int Property LIVESTATUS_ALIVE 			= 0 AutoReadOnly
int Property LIVESTATUS_DEAD 				= 1 AutoReadOnly
int Property LIVESTATUS_UNCONSCIOUS = 2 AutoReadOnly

; ------------------------------------------------------- ;
; --- Alias Data                                      --- ;
; ------------------------------------------------------- ;

; Actor
Actor _ActorRef
Actor Property ActorRef
	Actor Function Get()
		return _ActorRef
	EndFunction
EndProperty

int _sex
bool _victim

int _livestatus
Actor _killer

int _AnimVarIsNPC
bool _AnimVarbHumanoidFootIKDisable

; Center
ObjectReference _myMarker

; Orgasms
int _OrgasmCount
bool _CanOrgasm
int _countLast
bool _hasOrgasm
float _lastHoldBack

; Enjoyment
float _EnjoymentDelay
float _ContextCheckDelay
float _EnjRaise

; Stripping
int _stripData		; Strip data as provided by the animation
int[] _stripCstm	; Strip data as provided by the author -> [ArmorFlag, bStripWeapon]	
Form[] _equipment	; [HighHeelSpell, WeaponRight, WeaponLeft, Armor...]

bool _AllowRedress
bool property DoRedress
	bool function get()
		return _AllowRedress && (!IsVictim() || _Config.RedressVictim)
	endFunction
	function set(bool value)
		_AllowRedress = value
	endFunction
endProperty

bool _DoUndress
bool property DoUndress
	bool function get()
		return _Config.UndressAnimation && _DoUndress && GetState() != STATE_PLAYING
	endFunction
	function set(bool value)
		_DoUndress = value
	endFunction
endProperty

; Strapon
bool _useStrapon
Form _Strapon			; Strapon used by the animation
Form _HadStrapon	; Strapon worn prior to animation start

; Voice
sslBaseVoice _Voice
bool _IsForcedSilent
float _BaseDelay
float _VoiceDelay
float _ExpressionDelay

bool property IsSilent hidden
	bool function get()
		return !_Voice || _IsForcedSilent || OpenMouth
	endFunction
endProperty

; Expressions
String _Expression

bool Property ForceOpenMouth Auto Hidden
bool Property OpenMouth
	bool Function Get()
		return ForceOpenMouth || _Thread.Animation.UseOpenMouth(Position, _Thread.Stage)
	EndFunction
	Function Set(bool abSet)
		ForceOpenMouth = abSet
	EndFunction
EndProperty

; Pathing
int _PathingFlag
bool property DoPathToCenter
	bool function get()
		return _PathingFlag == PATHING_FORCE || (_PathingFlag == PATHING_ENABLE && _Config.DisableTeleport)
	endFunction
endProperty

; Time
float _StartedAt
float _LastOrgasm

; ------------------------------------------------------- ;
; --- Alias IDLE                                      --- ;
; ------------------------------------------------------- ;
;/
	An Idle state waiting for the owning thread to be initialized
	In this state, the reference is null and all related data is invalid

	This state will fill the alias and alias related data, then move to the "Ready" state
/;

Auto State Empty
	bool Function SetActor(Actor ProspectRef)
		ForceRefTo(ProspectRef)
		_ActorRef = ProspectRef
		If (_ActorRef.IsDead())
			_livestatus = LIVESTATUS_DEAD
			_killer = _ActorRef.GetKiller()
		ElseIf (_ActorRef.IsUnconscious())
			_livestatus = LIVESTATUS_UNCONSCIOUS
		Else
			_livestatus = LIVESTATUS_ALIVE
		EndIf
		_sex = SexLabRegistry.GetSex(ProspectRef, true)

		TrackedEvent(TRACK_ADDED)
		GoToState(STATE_SETUP)
		return true
	EndFunction

	Function Clear()
		; Use direct access here as to not update an outdated actor instance
		Actor underlying = GetReference() as Actor
		If (GetIsDead())
			If (underlying.IsEssential())
				underlying.GetActorBase().SetEssential(false)
			EndIf
			underlying.KillSilent(_killer)
		Else
			_Thread.RequestStatisticUpdate(underlying, _StartedAt)
		EndIf
		Parent.Clear()
	EndFunction

	String Function GetActorName()
		return "EMPTY"
	EndFunction

	Event OnEndState()
		RegisterForModEvent("SSL_CLEAR_Thread" + _Thread.tid, "OnRequestClear")
	EndEvent
EndState

bool Function SetActor(Actor ProspectRef)
	Error("Not in idle phase", "SetActor")
	return false
EndFunction

; ------------------------------------------------------- ;
; --- Alias SETUP                                     --- ;
; ------------------------------------------------------- ;
;/
	Pre animation start. The alias is waiting for the underlying thread to begin the animation
/;

State Ready
	Event OnBeginState()
		RegisterForModEvent("SSL_PREPARE_Thread" + _Thread.tid, "OnDoPrepare")
	EndEvent

	Function SetStrapon(Form ToStrapon)
		_Strapon = ToStrapon
	EndFunction

	Event OnDoPrepare(string asEventName, string asStringArg, float abUseFade, form akPathTo)
		If(_ActorRef == _PlayerRef)
			_ActorRef.SheatheWeapon()
			Game.SetPlayerAIDriven()
		Else
			_Config.CheckBardAudience(ActorRef, true)
		EndIf
		_AnimVarIsNPC = _ActorRef.GetAnimationVariableInt("IsNPC")
		_AnimVarbHumanoidFootIKDisable = _ActorRef.GetAnimationVariableBool("bHumanoidFootIKDisable")
		; TODO: Code below to ---- isnt optimizedy yet !IMPORTANT
		; Delays
		If(_sex > 2)
			_BaseDelay = 3.0
		ElseIf(_sex != 0)
			_BaseDelay = _Config.FemaleVoiceDelay
		Else
			_BaseDelay = _Config.MaleVoiceDelay
		EndIf
		_VoiceDelay = _BaseDelay
		_ExpressionDelay = _BaseDelay * 2
		; TODO: find fitting interval for enjoyment updates
		_EnjoymentDelay = 1.5 ;SLSO's widget too 'jumpy' with 3.0
		_ContextCheckDelay = 8.0
		_hasOrgasm = false
		_lastHoldBack = 0.0
		; Voice
		if !_Voice && !_IsForcedSilent
			if _sex > 2
				_Voice = _Config.VoiceSlots.PickByRaceKey(SexLabRegistry.GetRaceKey(ActorRef))
			else
				_Voice = _Config.VoiceSlots.PickVoice(ActorRef)
			endIf
		endIf
		; ----
		; Strapon & Expression (for NPC only)
		If (_sex <= 2)
			If (_Config.UseStrapons && _sex == 1)
				_HadStrapon = _Config.WornStrapon(ActorRef)
				If (!_HadStrapon)
					_Strapon = _Config.GetStrapon()
				ElseIf (!_Strapon)
					_Strapon = _HadStrapon
				EndIf
			EndIf
			If (_Expression == "" && _Config.UseExpressions)
				String[] expr
				If (IsVictim())
					expr = sslExpressionSlots.GetExpressionsByStatus(_ActorRef, 1)
				ElseIf (IsAggressor())
					expr = sslExpressionSlots.GetExpressionsByStatus(_ActorRef, 2)
				Else
					expr = sslExpressionSlots.GetExpressionsByStatus(_ActorRef, 0)
				EndIf
				_Expression = expr[Utility.RandomInt(0, expr.Length - 1)]
			EndIf
		EndIf
		; Position
		ActorRef.SetActorValue("Paralysis", 0.0)
		If(akPathTo && !abUseFade && DoPathToCenter)
			ObjectReference pathto = akPathTo as ObjectReference
			float distance = ActorRef.GetDistance(pathto)
			If(distance > 256.0 && distance <= 6144.0)
				float t = SexLabUtil.GetCurrentGameRealTime() + 15.0
				ActorRef.SetFactionRank(_AnimatingFaction, 2)
				ActorRef.EvaluatePackage()
				While (ActorRef.GetDistance(pathto) > 256.0 && SexLabUtil.GetCurrentGameRealTime() < t)
					Utility.Wait(0.045)
				EndWhile
			EndIf
		EndIf
		ActorRef.SetFactionRank(_AnimatingFaction, 1)
		ActorRef.EvaluatePackage()
		GoToState(STATE_PAUSED)
		If (asStringArg != "skip")
			_Thread.PrepareDone()
		EndIf
		; Delayed Initialization
		UpdateBaseEnjoymentCalculations()
		If (!_Config.DebugMode)
			return
		EndIf
		String LogInfo = ""
		If(_Voice)
			LogInfo += "Voice[" + _Voice.Name + "] "
		Else
			LogInfo += "Voice[NONE] "
		EndIf
		LogInfo += "Strapon[" + _Strapon + "] "
		LogInfo += "Expression[" + _Expression + "] "
		Log(LogInfo)
	EndEvent

	Function Clear()
		GoToState(STATE_IDLE)
		Clear()
	EndFunction

	Event OnEndState()
		UnregisterForModEvent("SSL_PREPARE_Thread" + _Thread.tid)
	EndEvent
EndState

Event OnDoPrepare(string asEventName, string asStringArg, float abUseFade, form akPathTo)
	Error("Preparation request outside a valid state", "OnDoPrepare()")
EndEvent

; --- Legacy

Event PrepareActor()
EndEvent
Function PathToCenter()
EndFunction

; ------------------------------------------------------- ;
; --- Alias PAUSED                                    --- ;
; ------------------------------------------------------- ;
;/
	Second idle state for a filled alias during or immediately before the actual animation start
	An actor in this state may walk around freely

	When this state is called initially, it is assumed that all relevant data has been set and the actor is waiting
	for strip information and the actual animation call
/;

int _schlonganglestart

State Paused
	; Should only be called once the first time the main thread enters animating state
	Function ReadyActor(int aiStripData, int aiPositionGenders, int aiSchlongAngle)
		_stripData = aiStripData
		_useStrapon = _sex == 1 && Math.LogicalAnd(aiPositionGenders, 0x2) == 0
		_schlonganglestart = aiSchlongAngle
		RegisterForModEvent("SSL_READY_Thread" + _Thread.tid, "OnStartPlaying")
	EndFunction
	Event OnStartPlaying(string asEventName, string asStringArg, float afNumArg, form akSender)
		; Only called once on the first enter to Animating State
		UnregisterForModEvent("SSL_READY_Thread" + _Thread.tid)
		If (_sex <= 2)
			If (DoUndress)
				DoUndress = false
				If (_sex == 0)
					Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G1")
				Else
					Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G1")
				EndIf
				Utility.Wait(0.6)
			EndIf
			_equipment = StripByData(_stripData, GetStripSettings(), _stripCstm)
			ResolveStrapon()
			ActorRef.QueueNiNodeUpdate()
		EndIf
		_StartedAt = SexLabUtil.GetCurrentGameRealTime()
		_LastOrgasm = _StartedAt
		; wait to ensure schlong mesh and AI package are updated
		Utility.Wait(0.6)
		LockActor()
		_Thread.AnimationStart()
		Utility.Wait(0.2)
		Debug.SendAnimationEvent(ActorRef, "SOSBend" + _schlonganglestart)
		TrackedEvent(TRACK_START)
	EndEvent

	Function SetStrapon(Form ToStrapon)
		SetStraponAnimationImpl(ToStrapon)
	EndFunction
	Function ResolveStrapon(bool force = false)
		ResolveStraponImpl()
	EndFunction

	Function TryLock()
		LockActor()
	EndFunction
	Function LockActor()
		LockActorImpl()
		If (!sslActorLibrary.HasVehicle(_ActorRef))
			If (!_myMarker)
				_myMarker = _ActorRef.PlaceAtMe(_xMarker)
			EndIf
			; Utility.Wait(0.5)
			_ActorRef.SetVehicle(_myMarker)
		EndIf
		_ActorRef.SheatheWeapon()
		If (ActorRef.IsSneaking())
			ActorRef.StartSneaking()
		EndIf
		_ActorRef.SetAnimationVariableInt("IsNPC", 0)
		_ActorRef.SetAnimationVariableBool("bHumanoidFootIKDisable", 1)
		If (ActorRef == _PlayerRef)
			If(_Config.AutoTFC)
				Game.ForceThirdPerson()
				MiscUtil.SetFreeCameraState(true)
				MiscUtil.SetFreeCameraSpeed(_Config.AutoSUCSM)
			EndIf
		Else
			ActorUtil.AddPackageOverride(ActorRef, _Thread.DoNothingPackage, 100, 1)
			_ActorRef.EvaluatePackage()
		EndIf
		SendDefaultAnimEvent()
		GoToState(STATE_PLAYING)
	EndFunction
	
	Function RemoveStrapon()
		If(_Strapon && !_HadStrapon)
			ActorRef.RemoveItem(_Strapon, 1, true)
		EndIf
	EndFunction

	Function Clear()
		If (_sex <= 2)
			Redress()
			RemoveStrapon()
		EndIf
		; If we are here, the animation is officially "started"
		; Clearing should only remove the actor from the alias but not re iniitlaize the whole script
		TrackedEvent(TRACK_END)
		GoToState(STATE_IDLE)
		Clear()
	EndFunction
	Function Initialize()
		TrackedEvent(TRACK_END)
		GoToState("")	; temporary state to avoid recursive loop here
		Initialize()
	EndFunction
EndState

Function ReadyActor(int aiStripData, int aiPositionGenders, int aiSchlongAngle)
	Error("Cannot ready outside of idle state", "ReadyActor()")
EndFunction
Function LockActor()
	Error("Cannot lock actor outside of idle state", "LockActor()")
EndFunction
Event OnStartPlaying(string asEventName, string asStringArg, float afNumArg, form akSender)
	Error("Playing request outside of idle state", "OnStartPlaying()")
EndEvent
Function RemoveStrapon()
	Error("Removing strapon from invalid state", "RemoveStrapon()")
EndFunction

;	Lock actor iff in idling state, otherwise do nothing
Function TryLock()
EndFunction

; Take this actor out of combat and clear all actor states, return true if the actor was the player
Function LockActorImpl() native
Form[] Function StripByData(int aiStripData, int[] aiDefaults, int[] aiOverwrites) native

; ------------------------------------------------------- ;
; --- Alias PLAYING                                   --- ;
; ------------------------------------------------------- ;
;/
	Main logic loop for in-animation actors
	This state will handle requipment status, orgasms, sounds, etc

	This section is divided into 2 parts:
	First the "paused" part which stores actors as they can move around freely and have no further actions applied to them,
	this is the state they originaly go into from the Setup state and will wait for further intrusctions (stripping, lock position, ...)
	And the "Playing" state, in this state actors are assumed in the animation and have voice logic and all applied to them
/;

float Property UpdateInterval = 0.25 AutoReadOnly
Int Property HoldBackKeyCode = 0x100 AutoReadOnly Hidden ; LMB

float _LoopDelay
float _LoopExpressionDelay
float _RefreshExpressionDelay
float _LoopEnjoymentDelay
float _LoopContextCheckDelay

State Animating
	Event OnBeginState()
		RegisterForModEvent("SSL_ORGASM_Thread" + _Thread.tid, "OnOrgasm")
		RegisterForSingleUpdate(UpdateInterval)
		If (_ActorRef == _PlayerRef)
			RegisterForKey(HoldBackKeyCode)
		EndIf
	EndEvent

	Function UpdateNext(int aiStripData)
		If (_stripData != aiStripData)
			_stripData = aiStripData
			_equipment = StripByDataEx(_stripData, GetStripSettings(), _stripCstm, _equipment)
			ActorRef.QueueNiNodeUpdate()
		EndIf
		_VoiceDelay -= Utility.RandomFloat(0.1, 0.3)
		if _VoiceDelay < 0.8
			_VoiceDelay = 0.8 ; Can't have delay shorter than animation update loop (COMEBACK: why?)
		endIf
	EndFunction

	Function SetStrapon(Form ToStrapon)
		SetStraponAnimationImpl(ToStrapon)
	EndFunction
	Function ResolveStrapon(bool force = false)
		ResolveStraponImpl()
	EndFunction

	Event OnUpdate()
		If(_Thread.GetStatus() != _Thread.STATUS_INSCENE)
			return
		EndIf
		; TODO: Review this block below
		; Probalby also want to give these variables more readable names
		; The function plays sound, updates and refreshes expression and enjoyment
		; Probably should changes this to reduce and compare timers to 0?
		If _LoopContextCheckDelay >= _ContextCheckDelay
			_LoopContextCheckDelay = 0
			RecheckConSubStatus()
		EndIf
		If _LoopEnjoymentDelay >= _EnjoymentDelay ; && IsSeparateOrgasm()
			_LoopEnjoymentDelay = 0
			UpdateEffectiveEnjoymentCalculations() ;call this before CalcReaction()
		EndIf
		int Strength = CalcReaction()
		if _LoopDelay >= _VoiceDelay && (_Config.LipsFixedValue || Strength > 10)
			_LoopDelay = 0.0
			bool UseLipSync = _Config.UseLipSync && _sex <= 2
			if OpenMouth && UseLipSync && !_Config.LipsFixedValue
				sslBaseVoice.MoveLips(ActorRef, none, 0.3)
				Log("PlayMoan:False; UseLipSync:"+UseLipSync+"; OpenMouth:"+OpenMouth)
			elseIf !IsSilent
				_Voice.PlayMoan(ActorRef, Strength, IsVictim(), UseLipSync)
				Log("PlayMoan:True; UseLipSync:"+UseLipSync+"; OpenMouth:"+OpenMouth)
			endIf
		endIf
		If (_RefreshExpressionDelay > 8.0)
			RefreshExpression()
		EndIf
		If (IsSeparateOrgasm() && _CanOrgasm && _FullEnjoyment >= 100)
			int cmp
			If(_sex == 0)
				cmp = 20
			ElseIf(_sex == 3)
				cmp = 30
			Else
				cmp = 10
			EndIf
			If(SexLabUtil.GetCurrentGameRealTime() - _LastOrgasm > cmp)
				DoOrgasm()
			EndIf
		EndIf
		; Loop
		_LoopDelay += UpdateInterval
		_LoopExpressionDelay += UpdateInterval
		_RefreshExpressionDelay += UpdateInterval
		_LoopEnjoymentDelay += UpdateInterval
		_LoopContextCheckDelay += UpdateInterval
		RegisterForSingleUpdate(UpdateInterval)
	EndEvent

	Function TryRefreshExpression()
		RefreshExpression()
	EndFunction
	Function RefreshExpression()
		_RefreshExpressionDelay = 0.0
		If (_sex > 2 || !ActorRef.Is3DLoaded() || ActorRef.IsDisabled())
			return
		ElseIf (OpenMouth)
			sslBaseExpression.OpenMouth(ActorRef)
			Utility.Wait(1.0)
		ElseIf (sslBaseExpression.IsMouthOpen(ActorRef))
			sslBaseExpression.CloseMouth(ActorRef)
		EndIf
		If (_Expression && _livestatus == LIVESTATUS_ALIVE)
			int strength = CalcReaction()
			sslBaseExpression.ApplyExpression(_Expression, _ActorRef, strength)
			Log("sslBaseExpression.ApplyExpression(" + _Expression + ") Strength:" + strength + "; OpenMouth:" + OpenMouth)
		EndIf
	EndFunction

	Function PlayLouder(Sound SFX, ObjectReference FromRef, float Volume)
		Sound.SetInstanceVolume(SFX.Play(FromRef), Volume)
	EndFunction

	Event OnOrgasm(string eventName, string strArg, float numArg, Form sender)
		DoOrgasm()
	EndEvent
	Function DoOrgasm(bool Forced = false)
		If (_hasOrgasm || !Forced && (!_CanOrgasm || (IsSeparateOrgasm() && _FullEnjoyment < 90)))
			Log("Tried to orgasm, but orgasms are disabled for this position: hasOrgasm = " + _hasOrgasm + " Forced=" + Forced + " _CanOrgasm=" + _CanOrgasm + " FullEnjoyment=" + _FullEnjoyment)
			return
		EndIf
		_hasOrgasm = true
		; TODO: actor specific orgasm conditions (+ edging / overstim)
		If (_EnjRaise < 0.03 && _FullEnjoyment > 90 && _FullEnjoyment < 100)
			; TODO: edging - let enjoyment raise faster and faster
			; rely on increasing _EnjFactor
		ElseIf (_FullEnjoyment > 100 && _EnjRaise < 0.03)
			; TODO: ruined orgasm
			; rely on reducing _FullEnjoyment
		EndIf
		If (SexLabUtil.GetCurrentGameRealTime() - _lastHoldBack >= 2.0)
			_lastHoldBack = 0.0
		EndIf
		If (_lastHoldBack > 0.0 && _FullEnjoyment < 120)
			Log("Orgasm manually got held back")
			_hasOrgasm = false
			return
		EndIf
		; SFX
		If(_Config.OrgasmEffects)
			If (ActorRef == _PlayerRef && _Config.ShakeStrength > 0 && Game.GetCameraState() >= 8)
				Game.ShakeCamera(none, _Config.ShakeStrength, _Config.ShakeStrength + 1.0)
			EndIf
			If(!IsSilent)
				PlayLouder(_Voice.GetSound(100, false), ActorRef, _Config.VoiceVolume)
			EndIf
			PlayLouder(_Config.OrgasmFX, ActorRef, _Config.SFXVolume)
		EndIf
		If (_sex != 1 && _sex != 4)	
			; TODO: Trigger Cum FX
			; Ideally this should invoke some function on the Thread to avoid this script accessing other sslActorAlias instances
			; this should only apply the actual FX with this Positions underlying Ref being the source. If there is no schlong, consider failing silenently
			; _Thread.ApplyCumFX(Source = ActorRef)
			_Thread.ApplyCumFX(_ActorRef)
		EndIf
		; Events
		int eid = ModEvent.Create("SexLabOrgasm")
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, _FullEnjoyment)
		ModEvent.PushInt(eid, _OrgasmCount)
		ModEvent.Send(eid)
		TrackedEvent("Orgasm")
		If IsSeparateOrgasm()
			Int handle = ModEvent.Create("SexlabOrgasmSeparate")
			If (handle)
				ModEvent.PushForm(handle, ActorRef)
				ModEvent.PushInt(handle, _Thread.tid)
				ModEvent.Send(handle)
			EndIf
		EndIf
		; enjoyment reduction handled by AdjustEnjTimeVariables()
		RegisterForSingleUpdate(UpdateInterval)
		_LastOrgasm = SexLabUtil.GetCurrentGameRealTime()
		_countLast = _OrgasmCount
		_OrgasmCount += 1
		_hasOrgasm = false
		Log(GetActorName() + ": Orgasms[" + _OrgasmCount + "] FullEnjoyment [" + _FullEnjoyment + "]")
	EndFunction

	Function TryUnlock()
		UnlockActor()
	EndFunction
	Function UnlockActor()
		_ActorRef.SetVehicle(none)
		_ActorRef.SetAnimationVariableInt("IsNPC", _AnimVarIsNPC)
		_ActorRef.SetAnimationVariableBool("bHumanoidFootIKDisable", _AnimVarbHumanoidFootIKDisable)
		If (ActorRef == _PlayerRef)
			MiscUtil.SetFreeCameraState(false)
		Else
			ActorUtil.RemovePackageOverride(ActorRef, _Thread.DoNothingPackage)
			ActorRef.EvaluatePackage()
		EndIf
		UnlockActorImpl()
		GoToState(STATE_PAUSED)
	EndFunction
	
	Function ResetPosition(int aiStripData, int aiPositionGenders, int aiSchlongAngle)
		_stripData = aiStripData
		_equipment = StripByDataEx(_stripData, GetStripSettings(), _stripCstm, _equipment)
		_useStrapon = _sex == 1 && Math.LogicalAnd(aiPositionGenders, 0x2) == 0
		ResolveStrapon()
		ActorRef.QueueNiNodeUpdate()
		Debug.SendAnimationEvent(ActorRef, "SOSBend" + aiSchlongAngle)
	EndFunction

	Function Clear()
		UnlockActor() ; will go to idle state
		Clear()
	EndFunction
	Function Initialize()
		UnlockActor()
		Initialize()
	EndFunction

	Event OnKeyDown(Int KeyCode)
		; give some time to overlap
		If (KeyCode != HoldBackKeyCode && SexLabUtil.GetCurrentGameRealTime() - _lastHoldBack < 1.8)
			return
		EndIf
		_lastHoldBack = SexLabUtil.GetCurrentGameRealTime()
	EndEvent

	Event OnEndState()
		UnregisterForModEvent("SSL_ORGASM_Thread" + _Thread.tid)
		UnregisterForKey(HoldBackKeyCode)
		If _ThreadRuntime > 40
			_SceneArousal = PapyrusUtil.ClampFloat(_FullEnjoyment as float, 0, 100)
			SexlabStatistics.SetStatistic(_ActorRef, 17, _SceneArousal)
		EndIf
		If(_Expression || sslBaseExpression.IsMouthOpen(ActorRef))
			sslBaseExpression.CloseMouth(ActorRef)
		EndIf
		ActorRef.ClearExpressionOverride()
		ActorRef.ResetExpressionOverrides()
		sslBaseExpression.ClearMFG(ActorRef)
		SendDefaultAnimEvent()
	EndEvent
EndState

Function UnlockActor()
	Error("Cannot unlock actor outside of playing state", "UnlockActor()")
EndFunction
Function UpdateNext(int aiStripData)
	Error("Cannot update to next stage outside of playing state", "UpdateNext()")
EndFunction
Function ResetPosition(int aiStripData, int aiPositionGenders, int aiSchlongAngle)
	Error("Cannot reset position outside of playing state", "ResetPosition()")
EndFunction
function RefreshExpression()
	Error("Cannot refresh expression outside of playing state", "RefreshExpression()")
endFunction
function DoOrgasm(bool Forced = false)
	Error("Cannot create an orgasm outside of playing state", "DoOrgasm()")
endFunction
Function PlayLouder(Sound SFX, ObjectReference FromRef, float Volume)
	Error("Cannot play sound outside of playing state", "PlayLouder()")
EndFunction
Event OnOrgasm(string eventName, string strArg, float numArg, Form sender)
	Error("Cannot create orgasm effects outside of playing state", "OnOrgasm()")
EndEvent

Function TryUnlock()
EndFunction
Function TryRefreshExpression()
EndFunction

; Undo "LockActor()" persistent changes
Function UnlockActorImpl() native
Form[] Function StripByDataEx(int aiStripData, int[] aiDefaults, int[] aiOverwrites, Form[] akMergeWith) native

; ------------------------------------------------------- ;
; --- State Independent                               --- ;
; ------------------------------------------------------- ;
;/
	Main logic loop for in-animation actors
	This state will handle requipment status, orgasms, sounds, etc
/;

Function SendDefaultAnimEvent(bool Exit = False)
	Debug.SendAnimationEvent(ActorRef, "AnimObjectUnequip")
	If(_sex <= 2)	; Human
		Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
		return
	EndIf
	Debug.SendAnimationEvent(ActorRef, "ReturnDefaultState") 	; chicken, hare and slaughterfish before the "ReturnToDefault"
	Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") 		; rest creature-animal
	Debug.SendAnimationEvent(ActorRef, "FNISDefault") 				; dwarvenspider and chaurus
	Debug.SendAnimationEvent(ActorRef, "IdleReturnToDefault") ; Werewolves and VampirwLords
	Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") 			; Trolls afther the "ReturnToDefault" and draugr, daedras and all dwarven exept spiders
	Debug.SendAnimationEvent(ActorRef, "Reset") 							; Hagravens afther the "ReturnToDefault" and Dragons
EndFunction

function TrackedEvent(string EventName)
	sslThreadLibrary.SendTrackingEvents(ActorRef, EventName, _Thread.tid)
endFunction

bool Function IsSeparateOrgasm()
	return sslSystemConfig.GetSettingInt("iClimaxType") == _Config.CLIMAXTYPE_EXTERN
EndFunction

Function ResolveStrapon(bool force = false)
	Error("Called from invalid state", "ResolveStrapon()")
EndFunction
Function SetStraponAnimationImpl(Form akNewStrapon)
	If (_Strapon == akNewStrapon)
		return
	ElseIf (_Strapon && !_HadStrapon)
		ActorRef.RemoveItem(_Strapon, 1, true)
	EndIf
	_Strapon = akNewStrapon
	ResolveStrapon()
EndFunction
Function ResolveStraponImpl()
	If (!_Strapon)
		return
	EndIf
	bool equipped = ActorRef.IsEquipped(_Strapon)
	If(!equipped && _useStrapon)
		ActorRef.EquipItem(_Strapon, true, true)
	ElseIf(equipped && !_useStrapon)
		ActorRef.UnequipItem(_Strapon, true, true)
	EndIf
EndFunction

int[] Function GetStripSettings()
	If (_Thread.IsConsent())
		return sslSystemConfig.GetStripForms(_sex == 1 || _sex == 2, false)
	Else
		return sslSystemConfig.GetStripForms(IsVictim(), true)
	EndIf
EndFunction

Function Redress()
	If (!DoRedress)
		return
	EndIf
	; _equipment := [HighHeelSpell, WeaponRight, WeaponLeft, Armor...]
	If(_equipment[1])
		ActorRef.EquipItemEx(_equipment[1], ActorRef.EquipSlot_RightHand, equipSound = false)
	EndIf
	If(_equipment[2])
		ActorRef.EquipItemEx(_equipment[2], ActorRef.EquipSlot_LeftHand, equipSound = false)
	EndIf
	int i = 3
	While (i < _equipment.Length)
		ActorRef.EquipItemEx(_equipment[i], ActorRef.EquipSlot_Default, equipSound = false)
		i += 1
	EndWhile
	Spell HDTHeelSpell = _equipment[0] as Spell
	If(HDTHeelSpell && ActorRef.GetWornForm(0x00000080) && !ActorRef.HasSpell(HDTHeelSpell))
		ActorRef.AddSpell(HDTHeelSpell, false)
	EndIf
EndFunction

; ------------------------------------------------------- ;
; --- Initialization                                  --- ;
; ------------------------------------------------------- ;
;/
	Functions for re/initialization
/;

; Only called on re/initialization of the owning Thread
Function Setup()
	Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
	_Config = SexLabQuestFramework as sslSystemConfig

	_Thread = GetOwningQuest() as sslThreadModel
	_AnimatingFaction = _Config.AnimatingFaction
	_PlayerRef = Game.GetPlayer()
	_xMarker = Game.GetFormFromFile(0x045A93, "SexLab.esm") ; 0x3B)

	Initialize()
EndFunction

; Initialize will clear the alias and reset all of the data accordingly
Function Initialize()
	; Forms
	_ActorRef 	= none
	_HadStrapon = none
	_Strapon 		= none
	; Voice
	_Voice 					= none
	_IsForcedSilent = false
	; _LegacyExpression
	_Expression = ""
	; Flags
	_AllowRedress		= true
	_CanOrgasm    	= true
	_hasOrgasm      = false
	ForceOpenMouth	= false
	; Integers
	_sex = -1
	_livestatus = 0
	_PathingFlag = 0
	_OrgasmCount = 0
	_FullEnjoyment	= 0
	; Floats
	_LastOrgasm = 0.0
	_StartedAt	= 0.0
	; Booleans
	_victim = false

	TryToClear()
	UnregisterForAllModEvents()
EndFunction

Event OnRequestClear(string asEventName, string asStringArg, float afDoStatistics, form akSender)
	Clear()
EndEvent

; ------------------------------------------------------- ;
; --- Escape Events                                   --- ;
; ------------------------------------------------------- ;
;/
	Events which if triggered should stop the underlying animation
/;

Event OnCellDetach()
	Log("An Alias is out of range and cannot be animated anymore. Stopping Thread...")
	_Thread.EndAnimation()
EndEvent
Event OnUnload()
	Log("An Alias is out of range and cannot be animated anymore. Stopping Thread...")
	_Thread.EndAnimation()
EndEvent
Event OnDying(Actor akKiller)
	Log("An Alias is dying and cannot be animated anymore. Stopping Thread...")
	_Thread.EndAnimation()
EndEvent

; ------------------------------------------------------- ;
; --- Logging                                         --- ;
; ------------------------------------------------------- ;
;/
	Generic logging utility
/;

function Log(string msg, string src = "")
	msg = "Thread[" + _Thread.tid + "] ActorAlias[" + GetActorName() + "] State" + GetState() + "] " + src + " - " + msg
	Debug.Trace("SEXLAB - " + msg)
	if _Config.DebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
endFunction

Function Error(String msg, string src = "")
	msg = "Thread[" + _Thread.tid + "] ActorAlias[" + GetActorName() + "] State" + GetState() + "] - ERROR - " + src + " - " + msg
	Debug.TraceStack("SEXLAB - " + msg)
	SexLabUtil.PrintConsole(msg)
	if _Config.DebugMode
		Debug.TraceUser("SexLabDebug", msg)
	endIf
EndFunction

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is a strictiyl redundant function that should not be called under any circumstance. See Papyrus Logs for more information.")
	Debug.TraceStack("Invoking Legacy Function " + asFunction)
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

function OffsetCoords(float[] Output, float[] CenterCoords, float[] OffsetBy) global
	Debug.MessageBox("[SEXLAB]\n'OffsetCoords' is a strictiyl redundant function that should not be called under any circumstance. See Papyrus Logs for more information.")
	Debug.TraceStack("Invoking Legacy Function OffsetCoords")
EndFunction
bool function IsInPosition(Actor CheckActor, ObjectReference CheckMarker, float maxdistance = 30.0) global
	Debug.MessageBox("[SEXLAB]\n'IsInPosition' is a strictiyl redundant function that should not be called under any circumstance. See Papyrus Logs for more information.")
	Debug.TraceStack("Invoking Legacy Function IsInPosition")
EndFunction
int function CalcEnjoyment(float[] XP, float[] SkillsAmounts, bool IsLeadin, bool IsFemaleActor, float Timer, int OnStage, int MaxStage) global
	Debug.MessageBox("[SEXLAB]\n'CalcEnjoyment' is a strictiyl redundant function that should not be called under any circumstance. See Papyrus Logs for more information.")
	Debug.TraceStack("Invoking Legacy Function CalcEnjoyment")
EndFunction

int Property Position
	int Function Get()
		return _Thread.Positions.Find(ActorRef)
	EndFunction
EndProperty

bool property UseStrapon hidden
	bool function get()
		return _useStrapon
	endFunction
endProperty

bool _DoRagdoll
bool property DoRagdoll hidden
	bool function get()
		return !_DoRagdoll ; && _Config.RagdollEnd
	endFunction
	function set(bool value)
		_DoRagdoll = !value
	endFunction
endProperty

int property Schlong hidden
	int function get()
		return 0
	endFunction
endProperty

bool property MalePosition hidden
	bool function get()
		return _Thread.Animation.GetGender(Position) == 0
	endFunction
endProperty

sslBaseExpression function GetExpression()
	return _Config.ExpressionSlots.GetByRegistrar(_Expression)
endFunction
Function SetExpression(sslBaseExpression ToExpression)
	_Expression = ToExpression.Registry
	TryRefreshExpression()
EndFunction

int function GetGender()
	int ret = SexLabRegistry.GetSex(ActorRef, false)
	If (ret >= 2)
		ret -= 1
	EndIf
	return ret
endFunction

function DisablePathToCenter(bool disabling)
	If (disabling)
		_PathingFlag = PATHING_DISABLE
	ElseIf (_PathingFlag == PATHING_DISABLE)
		_PathingFlag = PATHING_ENABLE
	EndIf
endFunction

function ForcePathToCenter(bool forced)
	If (forced)
		_PathingFlag = PATHING_FORCE
	Else
		_PathingFlag = PATHING_ENABLE
	EndIf
endFunction

function AttachMarker()
endFunction
function SyncThread()
endFunction

function OverrideStrip(bool[] SetStrip)
	if SetStrip.Length != 33
		_Thread.Log("Invalid strip override bool[] - Must be length 33 - was "+SetStrip.Length, "OverrideStrip()")
		return
	endif
	_stripCstm = new int[2]
	int i = 0
	int ii = 0
	While(i < 32)
		If(SetStrip[i])
			ii += Math.LeftShift(1, i)
		EndIF
		i += 1
	EndWhile
	_stripCstm[0] = ii
	_stripCstm[1] = SetStrip[32] as int
endFunction

Function Strip()
	_equipment = StripByDataEx(0x80, GetStripSettings(), _stripCstm, _equipment)
	ActorRef.QueueNiNodeUpdate()
EndFunction
Function UnStrip()
	Redress()
EndFunction

function SetEndAnimationEvent(string EventName)
endFunction
function SetStartAnimationEvent(string EventName, float PlayTime)
endFunction

function OrgasmEffect()
	DoOrgasm()
endFunction
event OrgasmStage()
	DoOrgasm()
endEvent
bool function NeedsOrgasm()
	return _FullEnjoyment >= 100
endFunction
function SetOrgasmCount(int value)
	; Will mess with internal enjoyment, deemed redundant!
EndFunction

function RegisterEvents()
endFunction
function ClearEvents()
endFunction

function EquipStrapon()
	; if _Strapon && !ActorRef.IsEquipped(_Strapon)
	; 	ActorRef.EquipItem(_Strapon, true, true)
	; endIf
endFunction
function UnequipStrapon()
	; if _Strapon && ActorRef.IsEquipped(_Strapon)
	; 	ActorRef.UnequipItem(_Strapon, true, true)
	; endIf
endFunction

function RefreshLoc()
	_Thread.RealignActors()
endFunction
function SyncLocation(bool Force = false)
	_Thread.RealignActors()
endFunction
function Snap()
	_Thread.RealignActors()
endFunction

function SetAdjustKey(string KeyVar)
endfunction
function LoadShares()
endFunction

bool function ContinueStrip(Form ItemRef, bool DoStrip = true)
	return sslActorLibrary.ContinueStrip(ItemRef, DoStrip)
endFunction

int function IntIfElse(bool check, int isTrue, int isFalse)
	if check
		return isTrue
	endIf
	return isFalse
endfunction

function ClearAlias()
	Clear()
endFunction

bool function PregnancyRisk()
	return _Thread.PregnancyRisk(_ActorRef)
endFunction

Function DoStatistics()
	; Thread handles Position statistics based on History and Participants
EndFunction

; Below functions are all strictly redundant
; Their functionality is either unnecessary or has absorbed into some other function directly
; Most of these functions had a specific functionality to operate on the underlying actor, allowing them to be invoked illegally
; would create issues in the framework itself while having them fail silently would potentially introduce issues on 
; the code illegally calling these functions, hence they all fail with an error message
function GetPositionInfo()
	LogRedundant("GetPositionInfo")
endFunction
function SyncActor()
	LogRedundant("SyncActor")
endFunction
function SyncAll(bool Force = false)
	LogRedundant("SyncAll")
endFunction
function RefreshActor()
	LogRedundant("RefreshActor")
endFunction
function RestoreActorDefaults()
	LogRedundant("RestoreActorDefaults")
endFunction
function SendAnimation()
	LogRedundant("SendAnimation")
endFunction
function StopAnimating(bool Quick = false, string ResetAnim = "IdleForceDefaultState")
	LogRedundant("StopAnimating")
endFunction
function StartAnimating()
	LogRedundant("OnBeginState")
endFunction
event ResetActor()
	LogRedundant("ResetActor")
endEvent
function ClearEffects()
	LogRedundant("ClearEffects")
endFunction

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
; --- Data Accessors                                  --- ;
; ------------------------------------------------------- ;

function ApplyCum()
	; TODO: _Tread.ApplyCumFX(Source = ActorRef)

	Log("START", "ApplyCum")
	if _ActorRef && _ActorRef.Is3DLoaded()
		Cell ParentCell = _ActorRef.GetParentCell()

		bool vaginalPen = _Thread.IsVaginalComplex(_ActorRef, _TypeInterASL)
		bool oralPen = _Thread.IsOralComplex(_ActorRef, _TypeInterASL)
		bool analPen = _Thread.IsAnalComplex(_ActorRef, _TypeInterASL)

		if !vaginalPen && !oralPen && !analPen && !_Thread.HasStageTag("ASLTagged")
			vaginalPen = _Thread.IsVaginal()
			oralPen = _Thread.IsOral()
			analPen = _Thread.IsAnal()
		endIf

		Log("Adding v = " + vaginalPen + " o = " + oralPen + " a = " + analPen, "ApplyCum")

		if (vaginalPen || oralPen || analPen) && ParentCell && ParentCell.IsAttached() 
			; thanks a lot for removing ActorLib scrab
			(Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorLibrary).AddCum(_ActorRef, vaginalPen, oralPen, analPen)
		endIf
	endIf
endFunction
; ------------------------------------------------------- ;
; --- Misc Utility					                  --- ;
; ------------------------------------------------------- ;

; NOTE: Might be unnecessary
String function GetActorKey()
	ActorBase base = ActorRef.GetLeveledActorBase()
	String ActorKey = MiscUtil.GetRaceEditorID(base.GetRace())
	If(!_Config.RaceAdjustments)	; Based on RaceKey instead of Race
		If(sslCreatureAnimationSlots.HasRaceID("Canines", ActorKey))
			ActorKey = "Canines"
		Else
			ActorKey = SexLabRegistry.GetRaceID(ActorRef)
		EndIf
	EndIf
	If(_sex > 2)
		ActorKey += "C"
		If(_Config.useCreatureGender)
			If(_sex == 4)
				ActorKey += "F"
			Else
				ActorKey += "M"
			EndIf
		EndIf
	ElseIf(_sex == 1 || _sex == 2)
		ActorKey += "F"
	Else
		ActorKey += "M"
	EndIf
	If(!_Config.ScaleActors)
		; COMEBACK: If this here isnt being deleted, call my custom GetScale() here
		float ActorScalePlus
		ActorKey += ((ActorScalePlus * 25) + 0.5) as int
	EndIf
	return ActorKey
endFunction

; ------------------------------------------------------- ;
; --- Enjoyment                                       --- ;
; ------------------------------------------------------- ;

;stats variables
float _ArousalStat
float _SceneArousal
float _VaginalXP
float _AnalXP
int _SexualityStat
int _ActorSexuality
;thread info
bool _SameSexThread
bool _CrtMaleHugePP
int _ConSubStatus
int _ActorInterInfo
int _numStage
float _ThreadRuntime
float _StageSkippedAt
float _StageSkipCompensation
;base variables
float _BestRelation
float _PainContext
float _EnjFactor
float _StageAdvanceFactor
;penetration variables
int _TypeInterASL
float _InterFactor
float _InterStartedAt
float _TimeInter
float _TotalInterTime
;effective variables
float _PainPen
float _PainEffective
float _EnjInter
float _InterEnjBackup
float _NonInterEnj
float _EnjEffective
int _FullEnjoyment
;adjustment variables
float _AdjustEnjFactor
float _AdjustPain
int _AdjustEnjoyment

;customizable variables
float _timeMax = 60.0 ;the timespan above which no pen_pain
float _requiredXP = 50.0 ;the xp above which no pen_pain
float _boostTime = 20.0 ;constant InterType gives enj boost till _TimeInter stays below _boostTime
float _penaltyTime = 80.0 ;constant InterType gives enj penalty if _TimeInter goes higher than _penaltyTime
int _MaxNoPainOrgasmsM = 1 ;after this many orgasms for males, enjoyment reset OnOrgasm will be less than zero (pserudo pain)
int _MaxNoPainOrgasmsF = 3 ;same as above but for female and futa actors

Function ResetEnjoymentVariables()
	;stats variables
	_ArousalStat = 0.0
	_SceneArousal = 0.0
	_VaginalXP = 0.0
	_AnalXP = 0.0
	_SexualityStat = 0
	_ActorSexuality = -1
	;thread info
	_SameSexThread = False
	_CrtMaleHugePP = False
	_ConSubStatus = _Thread.CONSENT_CONNONSUB
	_ActorInterInfo = _Thread.ACTORINT_NONPART
	_numStage = 0
	_ThreadRuntime = 0.0
	_StageSkippedAt = 0.0
	_StageSkipCompensation = 0.0
	;base variables
	_BestRelation = 0.0
	_PainContext = 0.0
	_EnjFactor = 0.0
	_StageAdvanceFactor = 0.0
	;penetration variables
	_TypeInterASL = 0
	_InterFactor = 0.0
	_InterStartedAt = 0.0
	_TimeInter = 0.0
	_TotalInterTime = 0.0
	;effective variables
	_PainPen = 0.0
	_PainEffective = 0.0
	_EnjInter = 0.0
	_InterEnjBackup = 0.0
	_NonInterEnj = 0.0
	_EnjEffective = 0.0
	_FullEnjoyment = 0
	;adjustment variables
	_AdjustEnjFactor = 0.0
	_AdjustPain = 0.0
	_AdjustEnjoyment = 0
EndFunction

Function UpdateBaseEnjoymentCalculations()
	ResetEnjoymentVariables()
	_ArousalStat = SexlabStatistics.GetStatistic(_ActorRef, 17)
	_VaginalXP = SexlabStatistics.GetStatistic(_ActorRef, 2)
	_AnalXP = SexlabStatistics.GetStatistic(_ActorRef, 3)
	_SexualityStat = SexlabStatistics.GetSexuality(_ActorRef)
	_ActorSexuality = SexlabStatistics.MapSexuality(_SexualityStat)
	_SameSexThread = _Thread.SameSexThread()
	_CrtMaleHugePP = _Thread.CrtMaleHugePP()
	_ConSubStatus = _Thread.IdentifyConsentSubStatus()
	_ActorInterInfo = _Thread.GuessActorInterInfo(_ActorRef, _sex, _victim, _ConSubStatus, _SameSexThread)
	_BestRelation  = _Thread.GetBestRelationForScene(_ActorRef, _ConSubStatus) as float
	_PainContext = CalcContextPain()
	_EnjFactor = CalcEnjoymentFactor()
	If _Config.DebugMode
		DebugBaseCalcVariables()
	EndIf
EndFunction

Function UpdateEffectiveEnjoymentCalculations()
	;update _EnjFactor
	int _numStageTemp = _Thread.GetStageHistoryLength()
	If (_numStageTemp > _numStage) && _numStage
		If !_victim
			_StageAdvanceFactor += 0.25
		Else
			_StageAdvanceFactor += 0.15
		EndIf
		_EnjFactor = (_EnjFactor + _StageAdvanceFactor)
	EndIf
	_numStage = _numStageTemp
	If _AdjustEnjFactor
		_EnjFactor = (_EnjFactor + _AdjustEnjFactor)
	EndIf
	;check interactions
	_TypeInterASL = _Thread.GetInteractionTypeASL()
	float InterFactorTemp = _Thread.GetInteractionFactor(_ActorRef, _TypeInterASL, _ActorInterInfo)
	If InterFactorTemp > 0 && _InterFactor == 0
		_TimeInter = _EnjoymentDelay
		_InterStartedAt = SexLabUtil.GetCurrentGameRealTime()
	ElseIf InterFactorTemp > 0 && _InterFactor > 0
		_TimeInter += _EnjoymentDelay
	ElseIf InterFactorTemp == 0 && _InterFactor > 0
		_TimeInter = 0
	EndIf
	_InterFactor = InterFactorTemp
	;time
	_TotalInterTime = SexLabUtil.GetCurrentGameRealTime() - _InterStartedAt
	_ThreadRuntime = SexLabUtil.GetCurrentGameRealTime() - _StartedAt
	AdjustEnjTimeVariables()
	;pain
	_PainEffective = CalcEffectivePain()
	If _AdjustPain
		_PainEffective = (_PainEffective + _AdjustPain)
	EndIf
	;enjoyment
	_EnjEffective = CalcEffectiveEnjoyment()
	_FullEnjoyment = _EnjEffective as int
	If _AdjustEnjoyment
		_FullEnjoyment = (_FullEnjoyment + _AdjustEnjoyment)
	EndIf
	;arousal (OnOrgasm)
	If _countLast != _OrgasmCount
		_SceneArousal = PapyrusUtil.ClampFloat(_FullEnjoyment as float, 0, 100)
		SexlabStatistics.SetStatistic(_ActorRef, 17, _SceneArousal)
		_countLast = _OrgasmCount
		_StageAdvanceFactor = 0.0
	EndIf
	;debug
	If _Config.DebugMode
		DebugEffectiveCalcVariables()
	EndIf
EndFunction

Function RecheckConSubStatus()
	int ConSubTemp = _Thread.IdentifyConsentSubStatus()
	If ConSubTemp != _ConSubStatus
		_ActorInterInfo = _Thread.GuessActorInterInfo(_ActorRef, _sex, _victim, _ConSubStatus, _SameSexThread)
		_BestRelation  = _Thread.GetBestRelationForScene(_ActorRef, _ConSubStatus) as float
		_PainContext = CalcContextPain()
		_EnjFactor = CalcEnjoymentFactor()
		_ConSubStatus = ConSubTemp
	EndIf
EndFunction

float Function CalcContextPain()
    _PainContext = 0
    If _victim && _ConSubStatus != _Thread.CONSENT_CONNONSUB
		If _Thread.HasSceneTag("Spanking")
			_PainContext += 3
		EndIf
		If _Thread.HasSceneTag("Dominant")
			_PainContext += 8
		EndIf
		If _Thread.HasSceneTag("Asphyxiation")
			_PainContext += 10
		EndIf
		If _Thread.HasSceneTag("Humiliation")
			_PainContext = 15
		ElseIf _Thread.HasSceneTag("Forced") && !(_Thread.HasSceneTag("Rape"))
			_PainContext = 18
		ElseIf _Thread.HasSceneTag("Forced") && _Thread.HasSceneTag("Rape")
			_PainContext = 25
		ElseIf _Thread.HasSceneTag("Ryona")
			_PainContext = 30
		ElseIf _Thread.HasSceneTag("Gore")
			_PainContext = 35
		EndIf
		If _ConSubStatus == _Thread.CONSENT_CONSUB
			_PainContext -= (_BestRelation * _PainContext * 0.03)
		EndIf
    EndIf
    return _PainContext
EndFunction

float Function CalcEnjoymentFactor()
	_EnjFactor = 0
	;arousal
	If _ArousalStat <= 0
		_ArousalStat = 0
	ElseIf _ArousalStat > 100
		_ArousalStat = 100
	EndIf
	_EnjFactor = (0.5 + (_ArousalStat / 50))
	;sexuality
	If (_ActorSexuality == 0 && !_SameSexThread) || (_ActorSexuality == 1 && _SameSexThread) || (_ActorSexuality == 2)
		_EnjFactor += 0.5
	ElseIf (_ActorSexuality == 1 && !_SameSexThread) || (_ActorSexuality == 0 && _SameSexThread)
		_EnjFactor -= 0.5
	EndIf
	;context
	If _ConSubStatus == _Thread.CONSENT_NONCONSUB
		If _victim
			_EnjFactor -= 0.35
		ElseIf !_victim
			_EnjFactor += 0.30
		EndIf
	EndIf
	;relation
	_EnjFactor += (0.5 + (_BestRelation / 22))
	return _EnjFactor
EndFunction

float Function CalcEffectivePain()
	_PainEffective = 0
	_PainPen = 0.0
	If (_Thread.IsVaginalComplex(_ActorRef, _TypeInterASL) || _Thread.IsAnalComplex(_ActorRef, _TypeInterASL)) \
		&& (_VaginalXP < _requiredXP || _AnalXP < _requiredXP) && (_TotalInterTime < _timeMax) 
		If ((_Thread.HasPhysicType(_Thread.PTYPE_VAGINALP, _ActorRef, none) && (_sex == 1 || _sex == 4)) \
			|| _Thread.HasPhysicType(_Thread.PTYPE_ANALP, _ActorRef, none)) \
			|| (_ActorInterInfo == _Thread.ACTORINT_PASSIVE)
			float factorXP = (2 - ((1 / (_requiredXP * 2)) * (1 + _VaginalXP + _AnalXP)))
			float factorPP = 0.0
			If _CrtMaleHugePP && _sex <= 2
				factorPP = 0.5
			EndIf
			_PainPen = (_InterFactor + factorPP) * factorXP * 25
			float InterTimeModifier = _PainPen * ((1 / _timeMax) * _TotalInterTime)
			_PainPen -= InterTimeModifier
		EndIf
		If _PainPen < 0
			_PainPen = 0
		EndIf
	EndIf
	_PainEffective = _PainContext + _PainPen
	If _PainEffective < 0
		_PainEffective = 0
	EndIf
	return _PainEffective
EndFunction

float Function CalcEffectiveEnjoyment()
	_EnjEffective = 0.0
	_NonInterEnj = 0.0
	_EnjInter = 0.0
	;intractions-based enjoyment
	If _InterFactor > 0 && _TimeInter >= _EnjoymentDelay
		_EnjInter = _InterFactor * _TimeInter
		float InterTimeModifier = 0
		If _TimeInter < _boostTime
			InterTimeModifier = _EnjInter * (_boostTime - _TimeInter) * 0.05
		ElseIf _TimeInter > _penaltyTime
			InterTimeModifier = _EnjInter * ((_penaltyTime - _TimeInter) / 150)
		EndIf
		_EnjInter += InterTimeModifier
	EndIf
	;avoiding rapid drops in _EnjInter
	If _EnjInter > 0
		_InterEnjBackup = _EnjInter
	EndIf
	If _EnjInter == 0 && _InterEnjBackup > 0
		_InterEnjBackup -= (1 * _EnjoymentDelay)
		_EnjInter = _InterEnjBackup
	EndIf
	;runtime-based enjoyment
	_NonInterEnj = _EnjFactor * (_ThreadRuntime * 0.4)
	;calculating return value
	_EnjEffective = _NonInterEnj + _EnjInter - _PainEffective
	return _EnjEffective
EndFunction

Function AdjustEnjTimeVariables()
	;increases runtime-based enjoyment (OnStageSkip)
	If _StageSkipCompensation
		float adjustedRuntime = _StageSkippedAt + _StageSkipCompensation
		If _ThreadRuntime < adjustedRuntime
			_StageSkipCompensation -= _EnjoymentDelay
			_ThreadRuntime = _ThreadRuntime + _StageSkipCompensation
		EndIf
	EndIf
	;reduces runtime-based enjoyment (OnOrgasm)
	If _OrgasmCount > 0
		If _sex == 0 || _sex == 3
			_ThreadRuntime = ((_ThreadRuntime - 40) / (4 * _OrgasmCount))
			If _OrgasmCount > _MaxNoPainOrgasmsM
				_ThreadRuntime -= _OrgasmCount * 20
			EndIf
		Else
			_ThreadRuntime = ((_ThreadRuntime - 40) / (3 + _OrgasmCount))
			If _OrgasmCount > _MaxNoPainOrgasmsF
				_ThreadRuntime -= _OrgasmCount * 10
			EndIf
		EndIf
		;reduces intractions-based enjoyment (OnOrgasm)
		If (_countLast != _OrgasmCount)
			_TimeInter = _EnjoymentDelay
		EndIf
	EndIf
EndFunction

Function CompensateStageSkip(float AdjustBy)
	_StageSkippedAt = _ThreadRuntime
	_StageSkipCompensation = AdjustBy
EndFunction

int function CalcReaction()
	; This function is intended to represent the excitement of an actor
	; It controls how "loud" an actor moans, how strong the expression is
	int Strength = Math.Abs(_FullEnjoyment) as int
	return PapyrusUtil.ClampInt(Strength, 0, 100)
endFunction

Function DebugBaseCalcVariables()
	string BaseCalcLog = "[ClimaxEXT_Base] Actor: " + GetActorName() + ", IsVictim: " + IsVictim() + ", Sexuality: " + _ActorSexuality + ", SameSexThread: " + _SameSexThread + ", CrtMaleHugePP: " + _CrtMaleHugePP + ", ConSubStatus: " + _ConSubStatus + ", ActorInterInfo: " + _ActorInterInfo + ", BestRelation: " + _BestRelation as int + ", ArousalStat: " + _ArousalStat as int + ", AnalXP: " + _AnalXP as int + ", VaginalXP: " + _VaginalXP as int + ", ContextPain: " + _PainContext as int + ", EnjFactor: " + _EnjFactor
	Log(BaseCalcLog)
EndFunction

Function DebugEffectiveCalcVariables()
	string EffectiveCalcLog = "[ClimaxEXT_Full] Actor: " + GetActorName() + ", PhysicTypes: " + _Thread.GetPhysicTypes(_ActorRef, none) + ", ASLType: " + _TypeInterASL + ", EnjFactor: " + _EnjFactor + ", IntFactor: " + _InterFactor + ", AdjustedRuntime: " + _ThreadRuntime as int + ", IntTime: " + _TimeInter as int + ", PenPain: " + _PainPen as int + ", EffectivePain: " + _PainEffective as int + ", InterEnj: " + _EnjInter as int + ", NonInterEnj: " + _NonInterEnj as int + ", FullEnjoyment: " + _FullEnjoyment
	Log(EffectiveCalcLog)
EndFunction