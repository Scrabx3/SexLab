scriptname sslBaseVoice extends sslBaseObject
{
	Access Script for Voice related logic
	Voices aren't considered part of the public API, if you want to create a custom voice,
	create a Voice.yml file instead and listing all of your values there
}

bool Function GetEnabled(String asID) native global
Function SetEnabled(String asID, bool abEnabled) native global

String[] Function GetVoiceTags(String asID) native global
int Function GetCompatibleSex(String asID) native global
String[] Function GetCompatibleRaces(String asID) native global

Sound Function GetSoundObject(String asID, int aiStrength, String[] asContext, String asScene, String asStage, int aiPositionIdx) native global
Sound Function GetOrgasmSound(String asID, String[] asContext, String asScene, String asStage, int aiPositionIdx) native global
Function PlaySound(Actor akActor, Sound akSound, float afStrength, bool abSyncLips) global
	If (abSyncLips)
		MoveLips(akActor, akSound, afStrength / 100.0)
	Else
		akSound.PlayAndWait(akActor)
	EndIf
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

bool Function InitializeVoiceObject(String asID) native global
Function FinalizeVoiceObject(String asID) native global

int Property SOUNDIDX_HOT    = 0 AutoReadOnly Hidden
int Property SOUNDIDX_MILD   = 1 AutoReadOnly Hidden
int Property SOUNDIDX_MEDIUM = 2 AutoReadOnly Hidden
Sound Function GetSoundObjectLeg(String asID, int aiIdx) native global
Function SetSoundObjectLeg(String asID, int aiIdx, Sound aSet) native global

Function SetVoiceTags(String asID, String[] asNewTags) native global
Function SetCompatibleSex(String asID, int aSet) native global
Function SetCompatibleRaces(String asID, String[] aSet) native global

String Function _GetName()
	return Registry
EndFunction
bool Function _GetEnabled()
	return Registry && GetEnabled(Registry)
EndFunction
Function _SetEnabled(bool abEnabled)
	If (Registry != "")
		SetEnabled(Registry, abEnabled)
	EndIf
EndFunction
String[] Function _GetTags()
	If (Registry != "")
		return GetVoiceTags(Registry)
	EndIf
	return Utility.CreateStringArray(0)
EndFunction
Function _SetTags(String[] asSet)
	If (Registry != "")
		SetVoiceTags(Registry, asSet)
	EndIf
EndFunction

Function MoveLips(Actor ActorRef, Sound SoundRef = none, float Strength = 1.0) global
	sslSystemConfig c = SexLabUtil.GetConfig()
	MoveLipsEx(ActorRef, SoundRef, Strength, c.LipsSoundTime, c.LipsMoveTime, c.LipsPhoneme, c.LipsMinValue, c.LipsMaxValue, c.LipsFixedValue)
endFunction
function MoveLipsEx(Actor ActorRef, Sound SoundRef = none, float Strength = 1.0, int SoundCut = 0, float MoveTime = 0.2, int Phoneme = 1, int MinValue = 20, int MaxValue = 50, bool IsFixedValue = false, bool UseMFG = false) global	
	float SavedP
	int p = Phoneme
	if p < 0 || p > 15
		p = 0
		float[] Phonemes = new float[32]
		int i
		; Get Phonemes
		while i <= 15
			Phonemes[i] = sslBaseExpression.GetPhoneme(ActorRef, i) ; 0.0 - 1.0
			if Phonemes[i] >= Phonemes[p] ; seems to be required to prevet issues
				p = i
			endIf
			i += 1
		endWhile
		SavedP = Phonemes[p]
	else
		SavedP = sslBaseExpression.GetPhoneme(ActorRef, p)
	endIf
	int MinP = MinValue
	int MaxP = MaxValue
	if !IsFixedValue
		float ReferenceP = SavedP
		if ReferenceP > (1.0 - (0.2 * Strength))
			ReferenceP = (1.0 - (0.2 * Strength))
		endIf
		MinP = ((ReferenceP * 100) - (MinP * Strength)) as int
		MaxP = ((ReferenceP * 100) + (MaxP * Strength)) as int
	endIf
	if MinP < 0
		MinP = 0
	elseIf MinP > 90
		MinP = 90
	endIf
	if (MaxP - MinP) < 10
		MaxP = MinP + 10
	endIf
	ActorRef.SetExpressionPhoneme(p, (MinP as float)*0.01)
	Utility.Wait(0.1)
	int Instance = -1
	if SoundCut != -1 && SoundRef != none
		Instance = SoundRef.Play(ActorRef)
	endIf
	sslExpressionUtil.SmoothSetPhoneme(ActorRef, p, MaxP)
	if SoundCut == -1 && SoundRef != none
		SoundRef.PlayAndWait(ActorRef)
	else
		Utility.Wait(MoveTime)
	endIf
	sslExpressionUtil.SmoothSetPhoneme(ActorRef, 0, p, (SavedP*100) as int)
	if SoundCut == 1 && Instance != -1
		Sound.StopInstance(Instance)
	endIf
	Utility.Wait(0.2)
endFunction

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

Sound property Hot
	Sound Function Get()
		If (Registry != "")
			return GetSoundObjectLeg(Registry, SOUNDIDX_HOT)
		EndIf
		return none
	EndFunction
	Function Set(Sound aSet)
		If (Registry != "")
			SetSoundObjectLeg(Registry, SOUNDIDX_HOT, aSet)
		EndIf
	EndFunction
EndProperty
Sound property Mild
	Sound Function Get()
		If (Registry != "")
			return GetSoundObjectLeg(Registry, SOUNDIDX_MILD)
		EndIf
		return none
	EndFunction
	Function Set(Sound aSet)
		If (Registry != "")
			SetSoundObjectLeg(Registry, SOUNDIDX_MILD, aSet)
		EndIf
	EndFunction
EndProperty
Sound property Medium
	Sound Function Get()
		If (Registry != "")
			return GetSoundObjectLeg(Registry, SOUNDIDX_MEDIUM)
		EndIf
		return none
	EndFunction
	Function Set(Sound aSet)
		If (Registry != "")
			SetSoundObjectLeg(Registry, SOUNDIDX_MEDIUM, aSet)
		EndIf
	EndFunction
EndProperty

Topic property LipSync hidden
	Topic Function Get()
		return Config.LipSync
	EndFunction
EndProperty

string[] property RaceKeys hidden
	String[] Function Get()
		return PapyrusUtil.RemoveString(GetCompatibleRaces(Registry), "Humans")
	EndFunction
	Function Set(String[] aSet)
		SetCompatibleRaces(Registry, aSet)
	EndFunction
EndProperty

int property Gender hidden
	int Function Get()
		int i = GetCompatibleSex(Registry)
		If (RaceKeys.Length)
			If (i == -1)
				i = 0
			EndIf
			return i + 2
		EndIf
		return i
	EndFunction
	Function Set(int aSet)
		SetCompatibleSex(Registry, aSet)
	EndFunction
EndProperty
bool property Male hidden
	bool function get()
		return !RaceKeys.Length && (Gender == 0 || Gender == -1)
	endFunction
endProperty
bool property Female hidden
	bool function get()
		return !RaceKeys.Length && (Gender == 1 || Gender == -1)
	endFunction
endProperty
bool property Creature hidden
	bool function get()
		return RaceKeys.Length > 0
	endFunction
endProperty

function PlayMoan(Actor ActorRef, int Strength = 30, bool IsVictim = false, bool UseLipSync = false)
	PlayMoanEx(ActorRef, Strength, IsVictim, UseLipSync, Config.LipsSoundTime, Config.LipsMoveTime, Config.LipsPhoneme, Config.LipsMinValue, Config.LipsMaxValue, Config.LipsFixedValue)
endFunction
function PlayMoanEx(Actor ActorRef, int Strength = 30, bool IsVictim = false, bool UseLipSync = false, int SoundCut = 0, float MoveTime = 0.2, int Phoneme = 1, int MinValue = 20, int MaxValue = 50, bool IsFixedValue = false, bool UseMFG = false)
	if !ActorRef
		return
	endIf
	
	Sound SoundRef = GetSound(Strength, IsVictim)
	if !UseLipSync
		if SoundRef
			SoundRef.Play(ActorRef)
			Utility.WaitMenuMode(0.4)
		endIf
	else
		MoveLipsEx(ActorRef, SoundRef, (Strength as float / 100.0), SoundCut, MoveTime, Phoneme, MinValue, MaxValue, IsFixedValue)
	endIf
endFunction

function Moan(Actor ActorRef, int Strength = 30, bool IsVictim = false) ;DEPRECATED
	if !ActorRef
		return
	endIf
	
	ActorBase BaseRef = ActorRef.GetLeveledActorBase()
	bool UseLipSync = Config.UseLipSync && BaseRef && !sslCreatureAnimationSlots.HasRaceType(BaseRef.GetRace())
	; Use the values of the version 1.62 for compatibility reasons
	PlayMoanEx(ActorRef, Strength, IsVictim, UseLipSync, 0, 0.2, 1, 20, 50, false, Config.HasMFGFix)
endFunction

function MoanNoWait(Actor ActorRef, int Strength = 30, bool IsVictim = false, float Volume = 1.0) ;DEPRECATED
	if !ActorRef
		return
	endIf
	
	if Volume > 0.0
		Sound SoundRef = GetSound(Strength, IsVictim)
		if SoundRef
			LipSync(ActorRef, Strength)
			Sound.SetInstanceVolume(SoundRef.Play(ActorRef), Volume)
		endIf
	endIf
endFunction

Sound function GetSound(int Strength, bool IsVictim = false)
	if Strength > 75 && Hot
		return Hot
	elseIf IsVictim && Medium
		return Medium
	endIf
	return Mild
endFunction

function LipSync(Actor ActorRef, int Strength, bool ForceUse = false)
	if !ActorRef
		return
	endIf
	
	if (ForceUse || Config.UseLipSync) && Game.GetCameraState() != 3
		ActorRef.Say(LipSync)
	endIf
endFunction

function TransitUp(Actor ActorRef, int from, int to) global
	if !ActorRef
		return
	endIf

	int value = from
	bool HasMFG = SexLabUtil.GetConfig().HasMFGFix
	if HasMFG
		sslExpressionUtil.SmoothSetPhoneme(ActorRef, 1, from) ; OLDRIM
		Utility.Wait(0.5)
		sslExpressionUtil.SmoothSetPhoneme(ActorRef, 1, to) ; OLDRIM
	else
		ActorRef.SetExpressionPhoneme(1, (from as float / 100.0))
		Utility.Wait(0.1)
		while value < (to + 4)
			value += 4
			ActorRef.SetExpressionPhoneme(1, (value as float / 100.0))
			Utility.Wait(0.02)
		endWhile
		ActorRef.SetExpressionPhoneme(1, (to as float / 100.0))
	endIf
endFunction

function TransitDown(Actor ActorRef, int from, int to) global
	if !ActorRef
		return
	endIf

	int value = from
	bool HasMFG = SexLabUtil.GetConfig().HasMFGFix
	if HasMFG
		sslExpressionUtil.SmoothSetPhoneme(ActorRef, 1, from) ; OLDRIM
		Utility.Wait(0.5)
		sslExpressionUtil.SmoothSetPhoneme(ActorRef, 1, to) ; OLDRIM
	else
		ActorRef.SetExpressionPhoneme(1, (from as float / 100.0)) ; SKYRIM SE
		Utility.Wait(0.1)
		while value > (to - 4)
			value -= 4
			ActorRef.SetExpressionPhoneme(1, (value as float / 100.0)) ; SKYRIM SE
			Utility.Wait(0.02)
		endWhile
		ActorRef.SetExpressionPhoneme(1, (to as float / 100.0)) ; SKYRIM SE
	endIf	
endFunction

bool function CheckGender(int CheckGender)
	return Gender == CheckGender || (Gender == -1 && (CheckGender == 1 || CheckGender == 0)) || (CheckGender >= 2 && Gender >= 2)
endFunction

function SetRaceKeys(string RaceList)
	string[] KeyList = PapyrusUtil.StringSplit(RaceList)
	int i = KeyList.Length
	while i
		i -= 1
		if KeyList[i]
			AddRaceKey(KeyList[i])
		endIf
	endWhile
endFunction
function AddRaceKey(string RaceKey)
	if !RaceKey
		; Do nothing
	elseIf !RaceKeys || !RaceKeys.Length
		String[] arg = new string[1]
		arg[0] = RaceKey
		RaceKeys = arg
	elseIf RaceKeys.Find(RaceKey) == -1
		RaceKeys = PapyrusUtil.PushString(RaceKeys, RaceKey)
	endIf
endFunction
bool function HasRaceKey(string RaceKey)
	return RaceKey && RaceKeys && RaceKeys.Find(RaceKey) != -1
endFunction
bool function HasRaceKeyMatch(string[] RaceList)
	if RaceList && RaceKeys
		int i = RaceList.Length
		while i
			i -= 1
			if RaceKeys.Find(RaceList[i]) != -1
				return true
			endIf
		endWhile
	endIf
	return false
endFunction

function Save(int id = -1)
	FinalizeVoiceObject(Registry)
endFunction

function Initialize()
	parent.Initialize()
endFunction
