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
	Error("Cannot mark as victim outside of setup state", "SetVictim()")
EndFunction

int Function GetSex()
	return _sex
EndFunction

; ------------------------------------------------------- ;
; --- Orgasms                                         --- ;
; ------------------------------------------------------- ;

function DisableOrgasm(bool bNoOrgasm)
	_canOrgasm = !bNoOrgasm
endFunction

bool function IsOrgasmAllowed()
	return _canOrgasm && !_Thread.DisableOrgasms
endFunction

bool function PregnancyRisk()
	If(_sex != 1)
		return false
	EndIf
	String activeScene = _Thread.GetActiveScene()
	String[] orgasmStages = SexLabRegistry.GetClimaxStages(activeScene)
	int i = 0
	While (i < orgasmStages.Length)
		If (SexLabRegistry.IsStageTag(activeScene, orgasmStages[i], "Vaginal"))
			return true
		EndIf
		i += 1
	EndWhile
	return false
endFunction

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
	Error("Cannot set voice outside of setup state", "SetVoice()")
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
sslActorStats Stats

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
String Property TRACK_END		 	= "Start" AutoReadOnly

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

int _AnimVarIsNPC
int _AnimVarFootIKDisable

; Center
ObjectReference _myMarker

; Orgasms
int _orgasmCount
bool _canOrgasm

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
		_sex = SexLabRegistry.GetSex(ProspectRef, true)
		_AnimVarIsNPC = ProspectRef.GetAnimationVariableInt("IsNPC")
		_AnimVarFootIKDisable = ProspectRef.GetAnimationVariableInt("FootIKDisable")
		Log(ProspectRef + " is sex: " + _sex + " npc: " + _AniMVarIsNPC + " ikdisable: " + _AnimVarFootIKDisable)

		TrackedEvent(TRACK_ADDED)
		GoToState(STATE_SETUP)
		return true
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
	
	Function SetVictim(bool Victimize)
		_victim = Victimize
	EndFunction

	Function SetVoice(sslBaseVoice ToVoice = none, bool ForceSilence = false)
		_IsForcedSilent = ForceSilence
		if ToVoice && (_sex > 2) == ToVoice.Creature
			_Voice = ToVoice
		endIf
	EndFunction

	Function SetStrapon(Form ToStrapon)
		_Strapon = ToStrapon
	EndFunction

	Event OnDoPrepare(string asEventName, string asStringArg, float abUseFade, form akPathTo)
		If(ActorRef == _PlayerRef)
			ActorRef.SheatheWeapon()
			Game.SetPlayerAIDriven()
		Else
			_Config.CheckBardAudience(ActorRef, true)
		EndIf
		Stats.SeedActor(ActorRef)
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
			LogInfo += "_Strapon[" + _Strapon + "] "
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
		GetBaseEnjoyment()
		LogInfo += "BaseEnjoyment["+BaseEnjoyment+"]"
		Log(LogInfo)
		; Position
		If(ActorRef.GetActorValue("Paralysis") > 0)
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

State Paused
	; Should only be called once the first time the main thread enters animating state
	Function ReadyActor(int aiStripData, int aiPositionGenders)
		_stripData = aiStripData
		_useStrapon = _sex == 1 && Math.LogicalAnd(aiPositionGenders, 0x2) == 0
		RegisterForModEvent("SSL_READY_Thread" + _Thread.tid, "OnStartPlaying")
	EndFunction
	Event OnStartPlaying(string asEventName, string asStringArg, float afNumArg, form akSender)
		UnregisterForModEvent("SSL_READY_Thread" + _Thread.tid)
		LockActor()
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
		EndIf
		; Only called once on the first enter to Animating State
		_StartedAt = SexLabUtil.GetCurrentGameRealTimeEx()
		_LastOrgasm = _StartedAt
		_Thread.AnimationStart()
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
			_ActorRef.SetVehicle(_myMarker)
		EndIf
		_ActorRef.SheatheWeapon()
		If (ActorRef.IsSneaking())
			ActorRef.StartSneaking()
		EndIf
		_ActorRef.SetAnimationVariableInt("IsNPC", 0)
		_ActorRef.SetAnimationVariableInt("FootIKDisable", 1)
		If (ActorRef == _PlayerRef)
			If(_Config.AutoTFC)
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
		GoToState(STATE_IDLE)
		Clear()
	EndFunction
	Function Initialize()
		TrackedEvent(TRACK_END)
		GoToState("")	; temporary state to avoid recursive loop here
		Initialize()
	EndFunction
EndState

Function ReadyActor(int aiStripData, int aiPositionGenders)
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

float _LoopDelay
float _LoopExpressionDelay
float _RefreshExpressionDelay

State Animating
	Event OnBeginState()
		RegisterForModEvent("SSL_ORGASM_Thread" + _Thread.tid, "OnOrgasmALL")
	EndEvent

	Function UpdateNext(int aiStripData)
		If (_stripData != aiStripData)
			_stripData = aiStripData
			_equipment = StripByDataEx(_stripData, GetStripSettings(), _stripCstm, _equipment)
		EndIf
		_VoiceDelay -= Utility.RandomFloat(0.1, 0.3)
		if _VoiceDelay < 0.8
			_VoiceDelay = 0.8 ; Can't have delay shorter than animation update loop
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
		; Trigger orgasm
		If(_canOrgasm && _Config.SeparateOrgasms && Strength >= 100 && _Thread.Stage < _Thread.Animation.StageCount)
			int cmp
			If(_sex == 0)
				cmp = 20
			ElseIf(_sex == 3)
				cmp = 30
			EndIf
			If(SexLabUtil.GetCurrentGameRealTimeEx() - _LastOrgasm > cmp)
				OrgasmEffect()
			EndIf
		EndIf
		; Loop
		_LoopDelay += (_VoiceDelay * 0.35)
		_LoopExpressionDelay += (_VoiceDelay * 0.35)
		_RefreshExpressionDelay += (_VoiceDelay * 0.35)
		RegisterForSingleUpdate(_VoiceDelay * 0.35)
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

	Function DoOrgasm(bool Forced = false)
		; TODO: Review this block below
		int Enjoyment = GetEnjoyment()
		if !Forced && (!_canOrgasm || _Thread.DisableOrgasms)
			; Orgasm Disabled for actor or whole thread
			return 
		elseIf !Forced && Enjoyment < 1
			; Actor have the orgasm few seconds ago or is in pain and can't orgasm
			return
		elseIf Math.Abs(SexLabUtil.GetCurrentGameRealTimeEx() - _LastOrgasm) < 5.0
			Log("Excessive OrgasmEffect Triggered")
			return
		endIf

		; Check if the animation allow Orgasm. By default all the animations with a CumID>0 are type SEX and allow orgasm 
		; But the Lesbian Animations usually don't have CumId assigned and still the orgasm should be allowed at least for Females.
		bool CanOrgasm = Forced || (_sex == 1 && (_Thread.Animation.HasTag("Lesbian") || _Thread.Animation.Females == _Thread.Animation.PositionCount))
		int i = _Thread.ActorCount
		while !CanOrgasm && i > 0
			i -= 1
			CanOrgasm = _Thread.Animation.GetCumID(i, _Thread.Stage) > 0 || _Thread.Animation.GetCum(i) > 0
		endWhile
		if !CanOrgasm
			; Orgasm Disabled for the animation
			return
		endIf

		; Check Separate Orgasm conditions 
		if !Forced && _Config.SeparateOrgasms
			if Enjoyment < 100 && (_Thread.Stage < _Thread.Animation.StageCount || _orgasmCount > 0)
				; Prevent the orgasm with low enjoyment at least the last stage be reached without orgasms
				return
			endIf
			bool IsCumSource = False
			i = _Thread.ActorCount
			while !IsCumSource && i > 0
				i -= 1
				IsCumSource = _Thread.Animation.GetCumSource(i, _Thread.Stage) == Position
			endWhile
			if !IsCumSource
				if _sex == 2 && !(_Thread.Animation.HasTag("Anal") || _Thread.Animation.HasTag("Vaginal") || _Thread.Animation.HasTag("Pussy") || _Thread.Animation.HasTag("Cunnilingus") || _Thread.Animation.HasTag("Fisting") || _Thread.Animation.HasTag("Handjob") || _Thread.Animation.HasTag("Blowjob") || _Thread.Animation.HasTag("Boobjob") || _Thread.Animation.HasTag("Footjob") || _Thread.Animation.HasTag("Penis"))
					return
				elseIf _sex == 0 && !(_Thread.Animation.HasTag("Anal") || _Thread.Animation.HasTag("Vaginal") || _Thread.Animation.HasTag("Handjob") || _Thread.Animation.HasTag("Blowjob") || _Thread.Animation.HasTag("Boobjob") || _Thread.Animation.HasTag("Footjob") || _Thread.Animation.HasTag("Penis"))
					return
				elseIf _sex == 1 && !(_Thread.Animation.HasTag("Anal") || _Thread.Animation.HasTag("Vaginal") || _Thread.Animation.HasTag("Pussy") || _Thread.Animation.HasTag("Cunnilingus") || _Thread.Animation.HasTag("Fisting") || _Thread.Animation.HasTag("Breast"))
					return
				endIf
			endIf
		endIf
		UnregisterForUpdate()
		_LastOrgasm = SexLabUtil.GetCurrentGameRealTimeEx()
		_orgasmCount += 1
		; Send an orgasm event hook with actor and orgasm count
		int eid = ModEvent.Create("SexLabOrgasm")
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, FullEnjoyment)
		ModEvent.PushInt(eid, _orgasmCount)
		ModEvent.Send(eid)
		TrackedEvent("Orgasm")
		Log(GetActorName() + ": Orgasms["+_orgasmCount+"] FullEnjoyment ["+FullEnjoyment+"] BaseEnjoyment["+BaseEnjoyment+"] Enjoyment["+Enjoyment+"]")
		If(_Config.OrgasmEffects)
			; Shake camera for player
			If(ActorRef == _PlayerRef && _Config.ShakeStrength > 0 && Game.GetCameraState() >= 8 )
				Game.ShakeCamera(none, _Config.ShakeStrength, _Config.ShakeStrength + 1.0)
			EndIf
			; Play SFX/Voice
			If(!IsSilent)
				PlayLouder(_Voice.GetSound(100, false), ActorRef, _Config.VoiceVolume)
			EndIf
			PlayLouder(_Config.OrgasmFX, ActorRef, _Config.SFXVolume)
		EndIf
		; Apply cum to female positions from male position orgasm
		if _Thread.ActorCount > 1 && _Config.UseCum && _sex != 1 && _sex != 4
			if _Thread.ActorCount == 2
				_Thread.PositionAlias(1 - Position).ApplyCum()
			else
				while i > 0
					i -= 1
					if Position != i && Position < _Thread.Animation.PositionCount && _Thread.Animation.IsCumSource(Position, i, _Thread.Stage)
						_Thread.PositionAlias(i).ApplyCum()
					endIf
				endWhile
			endIf
		endIf
		Utility.WaitMenuMode(0.2)
		; Reset enjoyment build up, if using multiple orgasms
		QuitEnjoyment += Enjoyment
		if _sex <= 2 || sslActorStats.IsSkilled(ActorRef)
			if IsVictim()
				BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(5, 10)
			else
				if IsAggressor()
					BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(5, 10)
				endIf
			endIf
		else
			if IsVictim()
				BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(5, 10)
			else
				if IsAggressor()
					BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(5, 10)
				endIf
			endIf
		endIf
		RegisterForSingleUpdate(0.8)
	EndFunction

	Function TryUnlock()
		UnlockActor()
	EndFunction
	Function UnlockActor()
		_ActorRef.SetVehicle(none)
		_ActorRef.SetAnimationVariableInt("IsNPC", _AnimVarIsNPC)
		_ActorRef.SetAnimationVariableInt("FootIKDisable", _AnimVarFootIKDisable)
		If (ActorRef == _PlayerRef)
			MiscUtil.SetFreeCameraState(false)
		Else
			ActorUtil.RemovePackageOverride(ActorRef, _Thread.DoNothingPackage)
			ActorRef.EvaluatePackage()
		EndIf
		UnlockActorImpl()
		GoToState(STATE_PAUSED)
	EndFunction
	
	Function ResetPosition(int aiStripData, int aiPositionGenders)
		_stripData = aiStripData
		_equipment = StripByDataEx(_stripData, GetStripSettings(), _stripCstm, _equipment)
		_useStrapon = _sex == 1 && Math.LogicalAnd(aiPositionGenders, 0x2) == 0
		ResolveStrapon()
	EndFunction

	Function Clear()
		UnlockActor() ; will go to idle state
		Clear()
	EndFunction
	Function Initialize()
		UnlockActor()
		Initialize()
	EndFunction

	Event OnEndState()
		UnregisterForModEvent("SSL_ORGASM_Thread" + _Thread.tid)
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
Function ResetPosition(int aiStripData, int aiPositionGenders)
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
	return _Config.GetStripSettings(_sex == 1 || _sex == 2, _Thread.UseLimitedStrip(), !_Thread.IsConsent(), IsVictim())
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

; Only called once when the framework is first initialized
Function Setup()
	Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
	_Config = SexLabQuestFramework as sslSystemConfig
	Stats = SexLabQuestFramework as sslActorStats

	_Thread = GetOwningQuest() as sslThreadModel
	_AnimatingFaction = _Config.AnimatingFaction
	_PlayerRef = Game.GetPlayer()
	_xMarker = Game.GetFormFromFile(0x045A93, "SexLab.esm") ; 0x3B)

	Initialize()
EndFunction

; Initialize will clear the alias and reset all of the data accordingly
Function Initialize()
	; Forms
	_ActorRef 			= none
	_HadStrapon 		= none
	_Strapon 				= none
	; Voice
	_Voice 					= none
	_IsForcedSilent = false
	; _Expression
	_Expression     = none
	_Expressions    = sslUtility.ExpressionArray(0)
	; Flags
	_AllowRedress		= false
	_canOrgasm     	= true
	ForceOpenMouth 	= false
	; Integers
	_PathingFlag    = 0
	_orgasmCount 		= 0
	BestRelation  	= 0
	BaseEnjoyment 	= 0
	QuitEnjoyment 	= 0
	FullEnjoyment 	= 0
	; Floats
	_LastOrgasm     = 0.0

	TryToClear()
	UnregisterForAllModEvents()
EndFunction

Event OnRequestClear(string asEventName, string asStringArg, float afDoStatistics, form akSender)
	If (afDoStatistics)
		DoStatistics()
	EndIf
	Clear()
EndEvent

; ------------------------------------------------------- ;
; --- Escape Events                                   --- ;
; ------------------------------------------------------- ;
;/
	Events which if triggered should stop the underlying animation
/;

Event OnCellDetach()
	Log("An Alias is out of range and cannot be animated anymore. Stopping _Thread...")
	_Thread.EndAnimation()
EndEvent
Event OnUnload()
	Log("An Alias is out of range and cannot be animated anymore. Stopping _Thread...")
	_Thread.EndAnimation()
EndEvent
Event OnDying(Actor akKiller)
	Log("An Alias is dying and cannot be animated anymore. Stopping _Thread...")
	_Thread.EndAnimation()
EndEvent

; ------------------------------------------------------- ;
; --- Logging                                         --- ;
; ------------------------------------------------------- ;
;/
	Generic logging utility
/;

function Log(string msg, string src = "")
	msg = "Thread[" + _Thread.tid + "] ActorAlias[" + GetActorName() + "] " + src + " - " + msg
	Debug.Trace("SEXLAB - " + msg)
	if _Config.DebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
endFunction

Function Error(String msg, string src = "")
	msg = "Thread[" + _Thread.tid + "] ActorAlias[" + GetActorName() + "] - ERROR - " + src + " - " + msg
	Debug.TraceStack("SEXLAB - " + msg)
	SexLabUtil.PrintConsole(msg)
	if _Config.DebugMode
		Debug.TraceUser("SexLabDebug", msg)
	endIf
EndFunction

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.\n\nPlease report this to Scrab with a Papyrus Log attached")
	Debug.TraceStack("Invoking Legacy Content Function " + asFunction)
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
event OnOrgasm()
	DoOrgasm()
endEvent
event OrgasmStage()
	DoOrgasm()
endEvent
bool function NeedsOrgasm()
	return GetEnjoyment() >= 100 && FullEnjoyment >= 100
endFunction

function RegisterEvents()
endFunction
function ClearEvents()
endFunction

function EquipStrapon()
	if _Strapon && !ActorRef.IsEquipped(_Strapon)
		ActorRef.EquipItem(_Strapon, true, true)
	endIf
endFunction
function UnequipStrapon()
	if _Strapon && ActorRef.IsEquipped(_Strapon)
		ActorRef.UnequipItem(_Strapon, true, true)
	endIf
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

float[] Skills
float[] OwnSkills

int BestRelation
int BaseEnjoyment
int QuitEnjoyment
int FullEnjoyment

Function GetBaseEnjoyment()
	; COMEBACK: Everything below still needs reviewing or redoing
	if _sex <= 2 || sslActorStats.IsSkilled(ActorRef)
		; Always use players stats for NPCS if present, so players stats mean something more
		Actor SkilledActor = ActorRef
		If(_Thread.HasPlayer && ActorRef != _PlayerRef)
			SkilledActor = _PlayerRef
		; If a non-creature couple, base skills off partner
		ElseIf(_Thread.ActorCount > 1 && !_Thread.HasCreature)
			SkilledActor = _Thread.Positions[sslUtility.IndexTravel(Position, _Thread.ActorCount)]
		EndIf
		; Get sex skills of partner/player
		Skills       = Stats.GetSkillLevels(SkilledActor)
		OwnSkills    = Stats.GetSkillLevels(ActorRef)
		; Try to prevent orgasms on fist stage resting enjoyment
		float FirsStageTime
		if _Thread.LeadIn
			FirsStageTime = _Config.StageTimerLeadIn[0]
		elseIf _Thread.IsType[0]
			FirsStageTime = _Config.StageTimerAggr[0]
		else
			FirsStageTime = _Config.StageTimer[0]
		endIf
		BaseEnjoyment -= Math.Abs(CalcEnjoyment(_Thread.SkillBonus, Skills, _Thread.LeadIn, _sex == 1, FirsStageTime, 1, _Thread.Animation.StageCount)) as int
		if BaseEnjoyment < -5
			BaseEnjoyment += 10
		endIf
		; Add Bonus Enjoyment
		if IsVictim()
			BestRelation = _Thread.GetLowestPresentRelationshipRank(ActorRef)
			BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(1, 10)
		else
			BestRelation = _Thread.GetHighestPresentRelationshipRank(ActorRef)
			if IsAggressor()
				BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(1, 10)
			else
				BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(1, 10)
			endIf
		endIf
	else
		if IsVictim()
			BestRelation = _Thread.GetLowestPresentRelationshipRank(ActorRef)
			BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(1, 10)
		else
			BestRelation = _Thread.GetHighestPresentRelationshipRank(ActorRef)
			if IsAggressor()
				BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(1, 10)
			else
				BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(1, 10)
			endIf
		endIf
	endIf
EndFunction

int function GetEnjoyment()
	if _sex > 2 && !sslActorStats.IsSkilled(ActorRef)
		FullEnjoyment = BaseEnjoyment + (PapyrusUtil.ClampFloat(((SexLabUtil.GetCurrentGameRealTimeEx() - _StartedAt) + 1.0) / 5.0, 0.0, 40.0) + ((_Thread.Stage as float / _Thread.Animation.StageCount as float) * 60.0)) as int
	else
		FullEnjoyment = BaseEnjoyment + CalcEnjoyment(_Thread.SkillBonus, Skills, _Thread.LeadIn, _sex == 1, (SexLabUtil.GetCurrentGameRealTimeEx() - _StartedAt), _Thread.Stage, _Thread.Animation.StageCount)
		; Log("FullEnjoyment["+FullEnjoyment+"] / BaseEnjoyment["+BaseEnjoyment+"] / Enjoyment["+(FullEnjoyment - BaseEnjoyment)+"]")
	endIf

	int Enjoyment = FullEnjoyment - QuitEnjoyment
	if Enjoyment > 0
		return Enjoyment
	endIf
	return 0
endFunction

int function GetPain()
	GetEnjoyment()
	if FullEnjoyment < 0
		return Math.Abs(FullEnjoyment) as int
	endIf
	return 0	
endFunction

int function CalcReaction()
	int Strength = GetEnjoyment()
	; Check if the actor is in pain or too excited to care about pain
	if FullEnjoyment < 0 && Strength < Math.Abs(FullEnjoyment)
		Strength = FullEnjoyment
	endIf
	return PapyrusUtil.ClampInt(Math.Abs(Strength) as int, 0, 100)
endFunction

function AdjustEnjoyment(int AdjustBy)
	BaseEnjoyment += AdjustBy
endfunction

; ------------------------------------------------------- ;
; --- Data Accessors                                  --- ;
; ------------------------------------------------------- ;

function ApplyCum()
	if !ActorRef || !ActorRef.Is3DLoaded()
		return
	endif
	Cell ParentCell = ActorRef.GetParentCell()
	int CumID = _Thread.Animation.GetCumID(Position, _Thread.Stage)
	if CumID > 0 && ParentCell && ParentCell.IsAttached() ; Error treatment for Spells out of Cell
		_Thread.ActorLib.ApplyCum(ActorRef, CumID)
	endIf
endFunction

; ------------------------------------------------------- ;
; ---	Statistics				                            --- ;
; ------------------------------------------------------- ;

; TODO: Completely overhaul this
Function DoStatistics()
	Actor VictimRef = _Thread.VictimRef
	if IsVictim()
		VictimRef = ActorRef
	endIf
	int sex_ = _sex
	If (sex_ >= 2)
		; translate to legacy sex
		sex_ -= 1
	EndIf
	float rt = SexLabUtil.GetCurrentGameRealTimeEx()
	sslActorStats.RecordThread(ActorRef, sex_, BestRelation, _StartedAt, rt, Utility.GetCurrentGameTime(), _Thread.HasPlayer, VictimRef, _Thread.Genders, _Thread.SkillXP)
	Stats.AddPartners(ActorRef, _Thread.Positions, _Thread.Victims)
	if _Thread.IsVaginal
		Stats.AdjustSkill(ActorRef, "VaginalCount", 1)
	endIf
	if _Thread.IsAnal
		Stats.AdjustSkill(ActorRef, "AnalCount", 1)
	endIf
	if _Thread.IsOral
		Stats.AdjustSkill(ActorRef, "OlCount", 1)
	endIf
EndFunction

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
