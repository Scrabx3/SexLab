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
	return _dead
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

; ------------------------------------------------------- ;
; --- Enjoyment & Pain                                --- ;
; ------------------------------------------------------- ;

;pain based on context and pentration, dynamic, often reducing over time
int Function GetPain()
	return EffectivePain as int
EndFunction

;enjoyment without considering pain and other psychological factors
int function CalcReaction()
	; This function is intended to represent the excitement of an actor
	; It controls how "loud" an actor moans, how strong the expression is and
	; when they orgasm (using default SL separate orgasm logic, CalcReaction() > 100 => Orgasm)
	return EffectiveArousal as int
endFunction

;static enjoyment based on context and psychological factors (other than pain)
int Function GetBaseEnjoyment()
	return BaseEnjoyment
EndFunction

;enjoyment that takes psychological factors, physical stimuli, and pain into account
int Function GetEnjoyment()
	return FullEnjoyment
EndFunction

;same as GetEnjoyment(), for partial compatibility with SLSO based mods
int Function GetFullEnjoyment()
	return FullEnjoyment
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

sslBaseExpression function GetExpression()
	return _Expression
endFunction

Function SetExpression(sslBaseExpression ToExpression)
	_Expression = ToExpression
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
bool _dead
bool _victim

int _AnimVarIsNPC
bool _AnimVarbHumanoidFootIKDisable

; Center
ObjectReference _myMarker

; Orgasms
int _OrgasmCount
bool _CanOrgasm
bool _hasOrgasm
bool _holdBack
float _lastHoldBack

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

; Enjoyment
float _EnjoymentDelay

bool property IsSilent hidden
	bool function get()
		return !_Voice || _IsForcedSilent || OpenMouth
	endFunction
endProperty

; Expressions
sslBaseExpression _Expression
sslBaseExpression[] _Expressions

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
		_dead = ProspectRef.IsDead()
		_sex = SexLabRegistry.GetSex(ProspectRef, true)

		TrackedEvent(TRACK_ADDED)
		GoToState(STATE_SETUP)
		return true
	EndFunction

	Function Clear()
			; Use direct access here as to not update an outdated actor instance
			Actor underlying = GetReference() as Actor
			If (_dead)
				If (underlying.IsEssential())
					underlying.GetActorBase().SetEssential(false)
				EndIf
				underlying.KillSilent()
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
		; TODO: Code below to pathing isnt optimizedy yet !IMPORTANT
		; Delays
		If(_sex > 2)
			_BaseDelay = 3.0
		ElseIf(_sex != 1)
			_BaseDelay = _Config.FemaleVoiceDelay
		Else
			_BaseDelay = _Config.MaleVoiceDelay
		EndIf
		_VoiceDelay = _BaseDelay
		_ExpressionDelay = _BaseDelay * 2
		; TODO: find fitting interval for enjoyment updates
		_EnjoymentDelay = 3.0
		_hasOrgasm = false
		_holdBack = false
		String LogInfo = ""
		; Voice
		if !_Voice && !_IsForcedSilent
			if _sex > 2
				_Voice = _Config.VoiceSlots.PickByRaceKey(SexLabRegistry.GetRaceKey(ActorRef))
			else
				_Voice = _Config.VoiceSlots.PickVoice(ActorRef)
			endIf
		endIf
		If(_Voice)
			LogInfo += "Voice[" + _Voice.Name + "] "
		Else
			LogInfo += "Voice[NONE] "
		EndIf
		; Strapon & Expression (for NPC only)
		If(_sex <= 2)
			If(_Config.UseStrapons && _sex == 1)
				_HadStrapon = _Config.WornStrapon(ActorRef)
				If(!_HadStrapon)
					_Strapon = _Config.GetStrapon()
				ElseIf(!_Strapon)	; Mightve been already set by SetStrapon prior to calling this
					_Strapon = _HadStrapon
				EndIf
			EndIf
			LogInfo += "Strapon[" + _Strapon + "] "
			if !_Expression && _Config.UseExpressions
				_Expressions = _Config.ExpressionSlots.GetByStatus(ActorRef, IsVictim(), _Thread.IsType[0] && !IsVictim())
				if _Expressions && _Expressions.Length > 0
					_Expression = _Expressions[Utility.RandomInt(0, (_Expressions.Length - 1))]
				endIf
			endIf
			If(_Expression)
				LogInfo += "_Expression[" + _Expression.Name + "] "
			EndIf
		EndIf
		; Position
		If(!_dead && ActorRef.GetActorValue("Paralysis") > 0)
			ActorRef.SetActorValue("Paralysis", 0.0)
			SendDefaultAnimEvent()
		EndIf
		If(akPathTo && !abUseFade && DoPathToCenter)
			ObjectReference pathto = akPathTo as ObjectReference
			float distance = ActorRef.GetDistance(pathto)
			If(distance > 256.0 && distance <= 6144.0)
				float t = SexLabUtil.GetCurrentGameRealTimeEx() + 15.0
				ActorRef.SetFactionRank(_AnimatingFaction, 2)
				ActorRef.EvaluatePackage()
				While (ActorRef.GetDistance(pathto) > 256.0 && SexLabUtil.GetCurrentGameRealTimeEx() < t)
					Utility.Wait(0.045)
				EndWhile
			EndIf
		EndIf
		ActorRef.SetFactionRank(_AnimatingFaction, 1)
		ActorRef.EvaluatePackage()
		GoToState(STATE_PAUSED)
		_Thread.PrepareDone()
		; Delayed Initialization
		UpdateBaseEnjoymentCalculations()
		LogInfo += "BaseEnjoyment["+BaseEnjoyment+"]"
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
		_StartedAt = SexLabUtil.GetCurrentGameRealTimeEx()
		_LastOrgasm = _StartedAt
		; wait to ensure schlong mesh and AI package are updated
		Utility.Wait(0.5)
		LockActor()
		If (_dead)
			SendDefaultAnimEvent()
		EndIf
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
		; RegisterForSingleUpdate(UpdateInterval)
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
		if _Expressions.Length && _LoopExpressionDelay >= _ExpressionDelay
			int newIdx = Utility.RandomInt(0, (_Expressions.Length - 1))
			If (_Expression != _Expressions[newIdx])
				_Expression = _Expressions[newIdx]
				RefreshExpression()
			EndIf
			Log("_Expression["+_Expression.Name+"] BaseVoiceDelay["+_BaseDelay+"] _ExpressionDelay["+_ExpressionDelay+"] _LoopExpressionDelay["+_LoopExpressionDelay+"] ")
			_LoopExpressionDelay = 0.0
		endIf
		if _RefreshExpressionDelay > 8.0
			RefreshExpression()
		endIf
		If (_holdBack && SexLabUtil.GetCurrentGameRealTimeEx() - _lastHoldBack >= 2.0)
			_holdBack = false
		EndIf
		; TODO: Update Enjoyment/Trigger Orgasms
		If _LoopEnjoymentDelay >= _EnjoymentDelay ; && IsSeparateOrgasm()
			_LoopEnjoymentDelay = 0
			UpdateEffectiveEnjoymentCalculations() ;call this before CalcReaction()
		EndIf
		; Loop
		_LoopDelay += UpdateInterval
		_LoopExpressionDelay += UpdateInterval
		_LoopEnjoymentDelay += UpdateInterval
		_RefreshExpressionDelay += UpdateInterval
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
		If (_Expression && !ActorRef.IsDead() && !ActorRef.IsUnconscious())
			; TODO: remove vsex variable once Expressions can handle futa gender
			int vsex = _sex
			If (_sex >= 2)
				vsex = _sex - 1
			EndIf
			int Strength = CalcReaction()
			_Expression.Apply(ActorRef, Strength, vsex)
			Log("_Expression.Applied("+_Expression.Name+") Strength:"+Strength+"; OpenMouth:"+OpenMouth)
		EndIf
	EndFunction

	Function PlayLouder(Sound SFX, ObjectReference FromRef, float Volume)
		Sound.SetInstanceVolume(SFX.Play(FromRef), Volume)
	EndFunction

	Event OnOrgasm()
		DoOrgasm()
	EndEvent
	Function DoOrgasm(bool Forced = false)
		; TODO: actor specific orgasm conditions (+ edging / overstim)
		If (_hasOrgasm || !Forced && (!_CanOrgasm || FullEnjoyment < 90))
			Log("Tried to orgasm, but orgasms are disabled for this position")
			return
		EndIf
		_hasOrgasm = true

		; check conditions
		If (_EnjRaise < 0.03 && FullEnjoyment > 90 && FullEnjoyment < 100)
			; TODO: edging
		ElseIf (FullEnjoyment > 100 && _EnjRaise < 0.03)
			; TODO: ruined orgasm
		EndIf

		If (_holdBack && FullEnjoyment < 120)
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
			; _Tread.ApplyCumFX(Source = ActorRef)
		EndIf
		; orgasm events
		int eid = ModEvent.Create("SexLabOrgasm")
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, FullEnjoyment)
		ModEvent.PushInt(eid, _OrgasmCount)
		ModEvent.Send(eid)

		TrackedEvent("Orgasm")

		Int handle = ModEvent.Create("SexlabOrgasmSeparate")
		If (handle)
			ModEvent.PushForm(handle, ActorRef)
			ModEvent.PushInt(handle, _Thread.tid)
		EndIf

		If (IsSeparateOrgasm())
			; TODO: Separate Orgasm Logic
		EndIf

		; ---
		RegisterForSingleUpdate(UpdateInterval)
		_LastOrgasm = SexLabUtil.GetCurrentGameRealTimeEx()
		; Update Enjoyment
		ArousalStat *= 0.02 ; drop arousal to 2%
		UpdateEffectiveEnjoymentCalculations()
		_OrgasmCount += 1
		_hasOrgasm = false
		Log(GetActorName() + ": Orgasms[" + _OrgasmCount + "] FullEnjoyment [" + FullEnjoyment + "] BaseEnjoyment[" + BaseEnjoyment + "] Enjoyment[" + FullEnjoyment + "]")
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
		If (KeyCode != HoldBackKeyCode && SexLabUtil.GetCurrentGameRealTimeEx() - _lastHoldBack < 1.8)
			return
		EndIf

		_holdBack = true
		_lastHoldBack = SexLabUtil.GetCurrentGameRealTimeEx()
	EndEvent

	Event OnEndState()
		UnregisterForModEvent("SSL_ORGASM_Thread" + _Thread.tid)
		UnregisterForKey(HoldBackKeyCode)
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
Event OnOrgasm()
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
	return _Config.GetStripSettings((_sex == 1 || _sex == 2), _Thread.UseLimitedStrip(), !_Thread.IsConsent(), IsVictim())
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
	_ActorRef       = none
	_HadStrapon     = none
	_Strapon        = none
	; Voice
	_Voice          = none
	_IsForcedSilent = false
	; _Expression
	_Expression     = none
	_Expressions    = sslUtility.ExpressionArray(0)
	; Flags
	_AllowRedress   = true
	_CanOrgasm      = true
	_hasOrgasm      = false
	ForceOpenMouth  = false
	; Integers
	_sex            = -1
	_PathingFlag    = 0
	_OrgasmCount    = 0
	BaseEnjoyment   = 0
	FullEnjoyment   = 0
	; Floats
	_LastOrgasm     = 0.0
	_StartedAt      = 0.0
	; Booleans
	_victim         = false
	_dead           = false
	; Enjoyment
	ResetEnjoymentVariables()

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
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.\n\nPlease report this to Scrab with a Papyrus Log attached")
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

function OffsetCoords(float[] Output, float[] CenterCoords, float[] OffsetBy) global native
bool function IsInPosition(Actor CheckActor, ObjectReference CheckMarker, float maxdistance = 30.0) global native
int function CalcEnjoyment(float[] XP, float[] SkillsAmounts, bool IsLeadin, bool IsFemaleActor, float Timer, int OnStage, int MaxStage) global native

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
	return GetEnjoyment() >= 100 && FullEnjoyment >= 100
endFunction
function AdjustEnjoyment(int AdjustBy)
	BaseEnjoyment += AdjustBy
endfunction


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
; --- Enjoyment                                       --- ;
; ------------------------------------------------------- ;

; NOTE: There is also "NeedsOrgasm()" and "AdjustEnjoyment()" which is no longer used but depends on the values here

int BaseEnjoyment
int FullEnjoyment
;define base variables
float BasePain
float BaseEnj
float _EnjRaise
float _EnjIncr
float ArousalStat
float BestRelation
float VaginalXP
float AnalXP
int _sexuality
int SexualityStat
bool SameSexThread
bool CrtMaleHugePP
;define effective variables
float EffectivePain
float EffectiveArousal
float EffectiveEnj
float PenArousal
float NonPenArousal
float ThreadRuntime
float PenVelocity
float PenTime
int ActorPenInfo
int PenType
int _PenType

; gets called by Initialize()
Function ResetEnjoymentVariables()
	;base variables
	_sexuality      = 0
	BasePain = 0.0
	BaseEnj = 0.0
	_EnjRaise = 0.0
	_EnjIncr = 0.0
	ArousalStat = 0.0
	BestRelation = 0.0
	VaginalXP = 0.0
	AnalXP = 0.0
	SexualityStat = -1
	SameSexThread = False
	CrtMaleHugePP = False
	;effective variables
	EffectivePain = 0.0
	EffectiveArousal = 0.0
	EffectiveEnj = 0.0
	PenArousal = 0.0
	NonPenArousal = 0.0
	ThreadRuntime = 0.0
	PenVelocity = 0.0
	PenTime = 0.0
	ActorPenInfo = -1
	PenType = -1
	_PenType = -1
EndFunction

; gets called by OnDoPrepare()
Function UpdateBaseEnjoymentCalculations()
	ArousalStat = SexlabStatistics.GetStatistic(_ActorRef, 18)
	_sexuality = SexlabStatistics.GetSexuality(_ActorRef)
	SexualityStat = SexlabStatistics.MapSexuality(_sexuality)
	SameSexThread = _Thread.SameSexThread()
	CrtMaleHugePP = _Thread.CrtMaleHugePP()
	BestRelation  = _Thread.GetBestRelationForScene(_ActorRef) as float
	VaginalXP = SexlabStatistics.GetStatistic(_ActorRef, 3)
	AnalXP = SexlabStatistics.GetStatistic(_ActorRef, 2)
	BasePain = CalcBasePain()
	BaseEnj = CalcBaseEnjoyment(ArousalStat, BasePain)
	BaseEnjoyment = BaseEnj as int
	DebugBaseCalcVariables()
EndFunction

; gets called by OnUpdate() and OnOrgasm()
Function UpdateEffectiveEnjoymentCalculations()
	_PenType = _Thread.GetPenetrationType()
	;--------------- GetPenetrationTime() ---------------;
	If _PenType > 0 && PenType <= 0
		PenTime = _EnjoymentDelay
	ElseIf _PenType > 0 && PenType > 0 && (_PenType != PenType)
		PenTime = _EnjoymentDelay
	ElseIf _PenType > 0 && PenType > 0 && (_PenType == PenType)
		PenTime += _EnjoymentDelay
	ElseIf _PenType <= 0 && PenType > 0
		PenTime = 0
	EndIf
	;----------------------------------------------------;
	PenType = _PenType
	If PenType >= 0
		ActorPenInfo = _Thread.GetActorPenInfo(_ActorRef, PenType)
		PenVelocity = _Thread.GetPenetrationVelocity()
	EndIf
	ThreadRuntime = SexLabUtil.GetCurrentGameRealTimeEx() - _StartedAt
	EffectivePain = CalcEffectivePain(BasePain)
	EffectiveArousal = CalcEffectiveArousal(ArousalStat)
	float _oldIncr = _EnjIncr
	_EnjIncr = EffectiveEnj
	EffectiveEnj = CalcEffectiveEnjoyment(EffectivePain, EffectiveArousal, BaseEnj)
	_EnjIncr -= EffectiveEnj
	_EnjRaise = (_oldIncr + _EnjIncr) / 2

	FullEnjoyment = EffectiveEnj as int
	DebugEffectiveCalcVariables()
EndFunction

float Function CalcBasePain()
	BasePain = 0
	If !_Thread.IsConsent() && _victim
		If _Thread.HasSceneTag("Spanking")
			BasePain += 2.5
		EndIf
		If _Thread.HasSceneTag("Dominant")
			BasePain += 7.5
		EndIf
		If _Thread.HasSceneTag("Asphyxiation")
			BasePain += 10
		EndIf
		If _Thread.HasSceneTag("Humiliation")
			BasePain = 15
		ElseIf _Thread.HasSceneTag("Forced") && !(_Thread.HasSceneTag("Rape"))
			BasePain = 17.5
		ElseIf _Thread.HasSceneTag("Forced") && _Thread.HasSceneTag("Rape")
			BasePain = 25
		ElseIf _Thread.HasSceneTag("Ryona")
			BasePain = 30
		ElseIf _Thread.HasSceneTag("Gore")
			BasePain = 35
		EndIf
	EndIf

	return BasePain
EndFunction

float Function CalcEffectivePain(float _BasePain)
	float PenPain = 0.0

	If PenType > 1 && ActorPenInfo == 1
		;TODO: Scrab advised to rely on sslActorStats.CalcLevel, how?
		If AnalXP < 40 || VaginalXP < 40
			If PenType == 3 || PenType >= 5
				If AnalXP < 5
					PenPain += 22.5
				ElseIf AnalXP < 15
					PenPain += 15
				ElseIf AnalXP < 25
					PenPain += 7.5
				ElseIf AnalXP < 40
					PenPain += 5
				EndIf
			EndIf
			If PenType == 2 || PenType == 4 || PenType > 5
				If VaginalXP < 5
					PenPain += 15
				ElseIf VaginalXP < 15
					PenPain += 10
				ElseIf VaginalXP < 25
					PenPain += 5
				ElseIf VaginalXP < 40
					PenPain += 2.5
				EndIf
			EndIf
			If PenType > 5
				PenPain -= 5 ;a small reduction in overall pain for DP
			EndIf
			float PenVelModifier = PenPain * (PenVelocity * (RegulatoryFactor(PenPain)))
			float PenTimeModifier = PenPain * (PenTime * (RegulatoryFactor(PenPain)))
			If PenVelocity >= 50 ;adjust value according to logic when it is introduced (right now assumed 1-100)
				PenPain += PenVelModifier
			ElseIf PenVelocity <= 10
				PenPain -= (PenVelModifier * 0.4)
			EndIf
			PenPain -= (PenTimeModifier * 0.4)
		EndIf
		If CrtMaleHugePP && _sex <= 2 && ActorPenInfo == 1 ;should use the creatures' ref but ehhh...
			PenPain += 10
		EndIf
		If PenPain < 0
			PenPain = 0
		EndIf
	EndIf

	EffectivePain = (_BasePain + PenPain)
	float RuntimeModifier = EffectivePain * (ThreadRuntime * (RegulatoryFactor(EffectivePain)))
	EffectivePain -= (RuntimeModifier * 0.4)

	If EffectivePain < 0
		EffectivePain = 0
	EndIf
	return EffectivePain
EndFunction

float Function CalcSceneArousal()
	float SceneArousal = 0.0
	PenArousal = 0

	If ActorPenInfo > 0
		If PenType == 1
			PenArousal += 2.5
			If ActorPenInfo == 2
				PenArousal += 4
			EndIf
		ElseIf PenType == 2
			PenArousal += 15
			If ActorPenInfo == 2
				PenArousal -= 2.5
			EndIf
		ElseIf PenType == 3
			PenArousal += 10
			If ActorPenInfo == 2
				PenArousal += 1.5
			EndIf
		ElseIf PenType == 4
			PenArousal += 16.5
			If ActorPenInfo == 2
				PenArousal -= 7.5
			EndIf
		ElseIf PenType == 5
			PenArousal += 11.5
			If ActorPenInfo == 2
				PenArousal -= 4
			EndIf
		ElseIf PenType == 6
			PenArousal += 20
			If ActorPenInfo == 2
				PenArousal -= 7.5
			EndIf
		ElseIf PenType == 7
			PenArousal += 22.5
			If ActorPenInfo == 2
				PenArousal -= 10
			EndIf
		EndIf
		PenArousal += ThreadRuntime * 0.2
		float PenVelModifier = PenArousal * (PenVelocity * (RegulatoryFactor(PenArousal)))
		float PenTimeModifier = PenArousal * (((1 / PenTime) * 40) * (RegulatoryFactor(PenArousal)))
		If PenVelocity >= 40 ;adjust value according to logic when it is introduced (right now assumed 1-100)
			PenArousal += PenVelModifier
		ElseIf PenVelocity <= 10
			PenArousal -= (PenVelModifier * 0.4)
		EndIf
		If PenTime <= 40
			PenArousal += PenTimeModifier
		Else
			PenArousal -= (PenTimeModifier * 0.4)
		EndIf
	EndIf

	NonPenArousal = ThreadRuntime * 0.4
	If Math.Abs(PenArousal) > 0.0001 ; reduce floating point error
		NonPenArousal *= 0.4
	EndIf

	SceneArousal = (PenArousal + NonPenArousal)
	float RuntimeModifier = SceneArousal * (ThreadRuntime * (RegulatoryFactor(SceneArousal)))
	If ((SceneArousal > 65) && (RuntimeModifier > (SceneArousal * 0.1)))
		RuntimeModifier = SceneArousal * 0.1
	ElseIf SceneArousal > 100
			RuntimeModifier = SceneArousal * 0.04
	ElseIf SceneArousal > 150
		RuntimeModifier = SceneArousal * 0.02
	EndIf
	SceneArousal += RuntimeModifier

	return SceneArousal
EndFunction

float Function CalcEffectiveArousal(float _ArousalStat)
	float SceneArousal = CalcSceneArousal()
	EffectiveArousal = _ArousalStat + SceneArousal
	return EffectiveArousal
EndFunction

float Function CalcBaseEnjoyment(float _ArousalStat, float _BasePain)
	BaseEnj = 0

	If _ArousalStat < 0
		_ArousalStat = 0
	EndIf
	If _ArousalStat > 0
		BaseEnj += _ArousalStat
	EndIf

	If (SexualityStat == 1 && SameSexThread) || (SexualityStat == 1 && !SameSexThread)
		BaseEnj = -10
	EndIf

	bool RelationTurnedNC = False ;non-consensual
	If BestRelation == 1 || BestRelation == 2 || BestRelation == 9 || BestRelation == 10 || BestRelation == 19 || BestRelation == 20 || BestRelation == 27 || BestRelation == 28
		RelationTurnedNC = True
	EndIf
	If BestRelation > 0 && RelationTurnedNC
		BaseEnj += (BestRelation * 0.5)
	ElseIf BestRelation > 0 && !RelationTurnedNC
		BaseEnj += (BestRelation * 0.5) + 5
	ElseIf BestRelation == -2
		BaseEnj -= (_BasePain * 0.2)
	EndIf

	BaseEnjoyment = BaseEnj as Int
	return BaseEnj
EndFunction

float Function CalcEffectiveEnjoyment(float _EffectivePain, float _EffectiveArousal, float _BaseEnjoyment)
	EffectiveEnj = _BaseEnjoyment + _EffectiveArousal - _EffectivePain
	return EffectiveEnj
EndFunction

float Function RegulatoryExp(float base, float exponent)
	float result = 1.0
	float i = 0.0
	if exponent == 0
		return 1
	elseif exponent > 0
		while i < exponent
			result *= base
			i += 1
		endwhile
		return result
	else
		while i < -exponent
			result *= base
			i += 1
		endwhile
		return 1 / result
	endIf
EndFunction

float Function RegulatoryFactor(float value)
	float factor = 0.0
	factor = 0.10 * RegulatoryExp(2.71828, -0.005 * value)
	return factor
EndFunction

Function DebugBaseCalcVariables()
	Log("[SLICK Base] IsVictim: " + IsVictim() + ", Sexuality: " + SexualityStat + ", SameSexThread: " + SameSexThread + ", CrtMaleHugePP: " + CrtMaleHugePP + ", BestRelation: " + BestRelation as int + ", ArousalStat: " + ArousalStat as int + ", AnalXp: " + AnalXP as int + ", VaginalXP: " + VaginalXP as int + ", BasePain: " + BasePain as int + ", BaseEnjoyment: " + BaseEnj as int)

	MiscUtil.PrintConsole("[SLICK Base] Actor: " + _ActorRef.GetLeveledActorBase().GetName() + ", BestRelation: " + BestRelation as int + ", ArousalStat: " + ArousalStat as int + ", BasePain: " + BasePain as int + ", BaseEnjoyment: " + BaseEnj as int)
EndFunction

Function DebugEffectiveCalcVariables()
	Log("[SLICK Effective] PenType: " + PenType + ", ActorPenInfo: " + ActorPenInfo + ", PenVelocity: " + PenVelocity as int + ", PenTime: " + PenTime as int + ", PenArousal: " + PenArousal as int + ", NonPenArousal: " + NonPenArousal as int + ", CalcReaction: " + CalcReaction() + ", EffectivePain: " + EffectivePain as int + ", EffectiveEnj: " + EffectiveEnj as int)

	MiscUtil.PrintConsole("[SLICK Effective] Actor: " + _ActorRef.GetLeveledActorBase().GetName() + ", PenType: " + PenType + ", ActorPenInfo: " + ActorPenInfo + ", PenArousal: " + PenArousal as int + ", NonPenArousal: " + NonPenArousal as int + ", EffectivePain: " + EffectivePain as int + ", EffectiveEnj: " + EffectiveEnj as int)

	Debug.Notification("full enjoyment for " + _ActorRef.GetLeveledActorBase().GetName() + ": " + EffectiveEnj as int)
EndFunction

; ------------------------------------------------------- ;
; --- Data Accessors                                  --- ;
; ------------------------------------------------------- ;

function ApplyCum()
	; TODO: _Tread.ApplyCumFX(Source = ActorRef)
endFunction

; ------------------------------------------------------- ;
; --- Misc Utility					                          --- ;
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
