scriptname sslBaseExpression extends sslBaseObject
{
	Access Script for Expression related logic
	Expression logic is not considered part of the public API, if you want to create a custom expression 
	profile, consider creating an Expression.yml file instead and listing all of your values there
}

String[] Function GetExpressionTags(String asID) native global
Function SetExpressionTags(String asID, String[] asNewTags) native global
bool Function GetEnabled(String asID) native global
Function SetEnabled(String asID, bool abEnabled) native global
Function RenameExpression(String asID, String asNewID) native global
int[] Function GetLevelCounts(String asID) native global
float[] Function GetValues(String asID, bool abFemale, int aiLevel) native global
Function SetValues(String asID, bool abFemale, int aiLevel, float[] afValues) native global

float function GetModifier(Actor ActorRef, int id) global native
float function GetPhoneme(Actor ActorRef, int id) global native
float function GetExpression(Actor ActorRef, bool getId) global native

; Apply Expression on Actor at given strength
; Actor must be NPC (Human RaceID)
; afStrength must be in [0; 100]
Function ApplyExpression(String asExpression, Actor akActor, float afStrength) global
	int sex = SexLabRegistry.GetSex(akActor, false)
	float lvMax = GetLevelCounts(asExpression)[(sex == 1) as int]
	int lvl = ((afStrength * lvMax) / 100.0) as int
	float[] values = GetValues(asExpression, sex != 0, lvl)
	ApplyPresetFloats(akActor, values)
EndFunction

function ClearPhoneme(Actor ActorRef) global
	sslExpressionUtil.resetPhonemesSmooth(ActorRef)
endFunction
function ClearModifier(Actor ActorRef) global
	sslExpressionUtil.resetModifiersSmooth(ActorRef)
endFunction
function ClearMFG(Actor ActorRef) global
	sslExpressionUtil.resetMFGSmooth(ActorRef)
endFunction

function OpenMouth(Actor ActorRef) global
	bool isRealFemale = ActorRef.GetLeveledActorBase().GetSex() == 1
	int OpenMouthExpression = SexLabUtil.GetConfig().GetOpenMouthExpression(isRealFemale)
	int OpenMouthSize = SexLabUtil.GetConfig().OpenMouthSize
	float[] Phonemes = SexLabUtil.GetConfig().GetOpenMouthPhonemes(isRealFemale)											 
	Int i = 0
	Int s = 0
	while i < Phonemes.length
		if (GetPhoneme(ActorRef, i) != Phonemes[i])
			sslExpressionUtil.SmoothSetModifier(ActorRef, 0, PapyrusUtil.ClampInt((OpenMouthSize * Phonemes[i]) as int, 0, 100))
		endIf
		if Phonemes[i] >= Phonemes[s] ; seems to be required to prevet issues
			s = i
		endIf
		i += 1
	endWhile
	sslExpressionUtil.SmoothSetPhoneme(ActorRef, s, (Phonemes[s] * 100.0) as int)
	if (GetExpression(ActorRef, true) as int == OpenMouthExpression || GetExpression(ActorRef, false) != OpenMouthSize as float / 100.0)
		sslExpressionUtil.SmoothSetExpression(ActorRef, OpenMouthExpression, OpenMouthSize)
	endIf
endFunction

function CloseMouth(Actor ActorRef) global
	ClearPhoneme(ActorRef)
	sslExpressionUtil.SmoothSetExpression(ActorRef,7,70)
endFunction

bool function IsMouthOpen(Actor ActorRef) global
	bool isRealFemale = ActorRef.GetLeveledActorBase().GetSex() == 1
	int OpenMouthExpression = SexLabUtil.GetConfig().GetOpenMouthExpression(isRealFemale)
	float MinMouthSize = (SexLabUtil.GetConfig().OpenMouthSize * 0.01) - 0.1
	if GetExpression(ActorRef, true) as Int == OpenMouthExpression && GetExpression(ActorRef, false) >= MinMouthSize
		return true
	endIf
	float[] Phonemes = SexLabUtil.GetConfig().GetOpenMouthPhonemes(isRealFemale)											 
	Int i = 0
	while i < Phonemes.length
		if (GetPhoneme(ActorRef, i) < (MinMouthSize * Phonemes[i]))
			return false
		endIf
		i += 1
	endWhile
	return true
endFunction

float[] function GetCurrentMFG(Actor ActorRef) global
	float[] Preset = new float[32]
	int i
	int p
	while p <= 15
		Preset[i] = GetPhoneme(ActorRef, p) ; 0.0 - 1.0
		i += 1
		p += 1
	endWhile
	int m
	while m <= 13
		Preset[i] = GetModifier(ActorRef, m) ; 0.0 - 1.0
		i += 1
		m += 1
	endWhile
	Preset[30] = GetExpression(ActorRef, true)  ; 0 - 16
	Preset[31] = GetExpression(ActorRef, false) ; 0.0 - 1.0
	return Preset
endFunction

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

int[] property PhaseCounts hidden
	int[] function get()
		return GetLevelCounts(Registry)
	endFunction
endProperty
int property PhasesMale hidden
	int function get()
		return PhaseCounts[Male]
	endFunction
endProperty
int property PhasesFemale hidden
	int function get()
		return PhaseCounts[Female]
	endFunction
endProperty

Function _SetRegistryID(String asSet)
	If (asSet != "")
		RenameExpression(Registry, asSet)
	EndIf
	Parent._SetRegistryID(asSet)
EndFunction
String Function _GetName()
	return Registry
EndFunction
bool Function _GetEnabled()
	return GetEnabled(Registry)
EndFunction
Function _SetEnabled(bool abEnabled)
	If (Registry != "")
		SetEnabled(Registry, abEnabled)
	EndIf
EndFunction
String[] Function _GetTags()
	return GetExpressionTags(Registry)
EndFunction
Function _SetTags(String[] asSet)
	If (Registry != "")
		SetExpressionTags(Registry, asSet)
	EndIf
EndFunction

function ApplyPresetFloats(Actor ActorRef, float[] Preset) global
	bool bMouthOpen = IsMouthOpen(ActorRef)
	float currExpr = GetExpression(ActorRef, true)
	float currValue = GetExpression(ActorRef, false)
	If (!bMouthOpen && currExpr != Preset[30])
		sslExpressionUtil.SmoothSetExpression(ActorRef, currExpr as int, 0, currValue)
	endIf
	sslExpressionUtil.ApplyExpressionPreset(ActorRef, Preset, bMouthOpen)
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

; Gender Types
int property Male       = 0 autoreadonly
int property Female     = 1 autoreadonly
int property MaleFemale = -1 autoreadonly
; MFG Types
int property Phoneme  = 0 autoreadonly
int property Modifier = 16 autoreadonly
int property Mood     = 30 autoreadonly
; ID loop ranges
int property PhonemeIDs  = 15 autoreadonly
int property ModifierIDs = 13 autoreadonly

; ------------------------------------------------------- ;
; --- Application Functions                           --- ;
; ------------------------------------------------------- ;

function Apply(Actor ActorRef, int Strength, int Gender)
	ApplyPhase(ActorRef, PickPhase(Strength, Gender), Gender)
endFunction

function ApplyPhase(Actor ActorRef, int Phase, int Gender)
	if Phase <= PhaseCounts[Gender]
		;	TransitPresetFloats(ActorRef, GetCurrentMFG(ActorRef), GetValues(Registry, Phase, Gender)) 
		ApplyPresetFloats(ActorRef, GetValues(Registry, Phase, Gender))
	endIf
endFunction

int function PickPhase(int Strength, int Gender)
	int phase = (PapyrusUtil.ClampInt(Strength, 1, 100) * PhaseCounts[Gender]) / 100
	return PapyrusUtil.ClampInt(phase, 1, PhaseCounts[Gender])
endFunction

float[] function SelectPhase(int Strength, int Gender)
	return GenderPhase(PickPhase(Strength, Gender), Gender)
endFunction 

; ------------------------------------------------------- ;
; --- Global Utilities                                --- ;
; ------------------------------------------------------- ;

function TransitPresetFloats(Actor ActorRef, float[] FromPreset, float[] ToPreset, float Speed = 1.0, float Time = 1.0) global 
	if !ActorRef || FromPreset.Length < 32 || ToPreset.Length < 32
		return
	endIf
	if Speed < 0.1
		ApplyPresetFloats(ActorRef, ToPreset)
		return
	endIf
	int n = (10 * Speed) as int
	int p
	while p < n
		float[] Preset = new float[32]
		int i = Preset.Length
		while i > 0
			i -= 1
			if i > 29
				Preset[i] = ToPreset[i]
			else
				Preset[i] = ((ToPreset[i] - FromPreset[i]) / n) * p + FromPreset[i]
			endIf
		endWhile
		ApplyPresetFloats(ActorRef, Preset)
		Utility.Wait((Time / 10) / Speed)
		p += 1
	endWhile
	ApplyPresetFloats(ActorRef, ToPreset)
endFunction

function ApplyPresetFloatsLegacy(Actor ActorRef, float[] Preset, bool IsMouthOpen) global 
	int i
	int p
	int m
	; Set expression
	float currExpr = GetExpression(ActorRef, true)
	float currExprStr = GetExpression(ActorRef, false)
	if (GetExpression(ActorRef, true) == Preset[30] || GetExpression(ActorRef, false) != Preset[31]) && !IsMouthOpen
		ActorRef.SetExpressionOverride(Preset[30] as int, (Preset[31] * 100.0) as int)
	endIf
	; Set Phoneme
	if IsMouthOpen
		i = 16 ; escape the Phoneme to prevent override the MouthOpen
	else
		int s
		while p <= 15
			if GetPhoneme(ActorRef, p) != Preset[i]
				ActorRef.SetExpressionPhoneme(p, Preset[i]) ; is supouse to be / 100.0 already thanks SetIndex function
			endIf
			if Preset[p] >= Preset[s] ; seems to be required to prevet issues
				s = p
			endIf
			i += 1
			p += 1
		endWhile
		ActorRef.SetExpressionPhoneme(s, Preset[s]) ; is supouse to be / 100.0 already thanks SetIndex function
	endIf
	; Set Modifers
	while m <= 13
		if GetModifier(ActorRef, m) != Preset[i]
			ActorRef.SetExpressionModifier(m, Preset[i]) ; is supouse to be / 100.0 already thanks SetIndex function
		endif
		i += 1
		m += 1
	endWhile
endFunction

; ------------------------------------------------------- ;
; --- Editing Functions                               --- ;
; ------------------------------------------------------- ;

function SetIndex(int Phase, int Gender, int Mode, int id, int value)
	float[] Preset = GetValues(Registry, Phase, Gender)
	int i = Mode+id
	if value > 100
		value = 100
	elseIf value < 0
		value = 0
	endIf
	Preset[i] = value as float
	if i != 30
		Preset[i] = Preset[i] / 100.0
	endIf
	SetPhase(Phase, GEnder, Preset)
endFunction

function SetPreset(int Phase, int Gender, int Mode, int id, int value)
	if Mode == Mood
		SetMood(Phase, Gender, id, value)
	elseif Mode == Modifier
		SetModifier(Phase, Gender, id, value)
	elseif Mode == Phoneme
		SetPhoneme(Phase, Gender, id, value)
	endIf
endFunction

function SetMood(int Phase, int Gender, int id, int value)
	if Gender == Female || Gender == MaleFemale
		SetIndex(Phase, Female, Mood, 0, id)
		SetIndex(Phase, Female, Mood, 1, value)
	endIf
	if Gender == Male || Gender == MaleFemale
		SetIndex(Phase, Male, Mood, 0, id)
		SetIndex(Phase, Male, Mood, 1, value)
	endIf
endFunction

function SetModifier(int Phase, int Gender, int id, int value)
	if Gender == Female || Gender == MaleFemale
		SetIndex(Phase, Female, Modifier, id, value)
	endIf
	if Gender == Male || Gender == MaleFemale
		SetIndex(Phase, Male, Modifier, id, value)
	endIf
endFunction

function SetPhoneme(int Phase, int Gender, int id, int value)
	if Gender == Female || Gender == MaleFemale
		SetIndex(Phase, Female, Phoneme, id, value)
	endIf
	if Gender == Male || Gender == MaleFemale
		SetIndex(Phase, Male, Phoneme, id, value)
	endIf
endFunction

function EmptyPhase(int Phase, int Gender)
	float[] Preset = new float[32]
	SetPhase(Phase, Gender, Preset)
endFunction

function AddPhase(int Phase, int Gender)
	float[] Preset = GetValues(Registry, Phase, Gender)
	if Preset[31] == 0.0 || Preset[30] < 0.0 || Preset[30] > 16.0
		Preset[30] = 7.0
		Preset[31] = 0.5
	endIf
	SetPhase(Phase, Gender, Preset)
endFunction

; ------------------------------------------------------- ;
; --- Phase Accessors                                 --- ;
; ------------------------------------------------------- ;

bool function HasPhase(int Phase, Actor ActorRef)
	if !ActorRef || Phase < 1
		return false
	endIf
	int Gender = ActorRef.GetLeveledActorBase().GetSex()
	return (Gender == Female && Phase <= PhasesFemale) || (Gender == Male && Phase <= PhasesMale)
endFunction

float[] function GetPhonemes(int Phase, int Gender)
	float[] Output = new float[16]
	float[] Preset = GetValues(Registry, Phase, Gender)
	int i
	while i <= PhonemeIDs
		Output[i] = Preset[Phoneme + i]
		i += 1
	endWhile
	return Output
endFunction

float[] function GetModifiers(int Phase, int Gender)
	float[] Output = new float[14]
	float[] Preset = GetValues(Registry, Phase, Gender)
	int i
	while i <= ModifierIDs
		Output[i] = Preset[Modifier + i]
		i += 1
	endWhile
	return Output
endFunction

int function GetMoodType(int Phase, int Gender)
	return GetValues(Registry, Phase, Gender)[30] as int
endFunction

int function GetMoodAmount(int Phase, int Gender)
	return (GetValues(Registry, Phase, Gender)[31] * 100.0) as int
endFunction

int function GetIndex(int Phase, int Gender, int Mode, int id)
	return (GetValues(Registry, Phase, Gender)[Mode + id] * 100.0) as int
endFunction

int property MoodIDs = 16 autoreadonly

function CountPhases()
endFunction

float[] function GenderPhase(int Phase, int Gender)
	return GetValues(Registry, Gender == Female, Phase)
endFunction

function SetPhase(int Phase, int Gender, float[] Preset)
	If (Gender == -1)
		SetValues(Registry, true, Phase, Preset)
		SetValues(Registry, false, Phase, Preset)
	Else
		SetValues(Registry, Gender == Female, Phase, Preset)
	EndIf
endFunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

int function ValidatePreset(float[] Preset)
	if Preset.Length == 32 ; Must be appropiate size
		int i = 30
		while i
			i -= 1
			if Preset[i] > 0.0
				return 1 ; Must have alteast one phoneme or modifier value
			endIf
		endWhile
	endIf
	return 0
endFunction

string property File hidden
	string function get()
		return "../SexLab/Expression_"+Registry+".json"
	endFunction
endProperty

bool function ImportJson()
	return true
endFunction
bool function ExportJson()
	return true
endFunction

; ------------------------------------------------------- ;
; --- DEPRECATED                                      --- ;
; ------------------------------------------------------- ;

function ApplyTo(Actor ActorRef, int Strength = 50, bool IsFemale = true, bool OpenMouth = false)
	Apply(ActorRef, Strength, IsFemale as int)
	if OpenMouth
		OpenMouth(ActorRef)
	endIf
endFunction

int[] function GetPhase(int Phase, int Gender)
	return ToIntArray(GenderPhase(Phase, Gender))
endFunction

int[] function PickPreset(int Strength, bool IsFemale)
	return GetPhase(CalcPhase(Strength, IsFemale), (IsFemale as int))
endFunction

int function CalcPhase(int Strength, bool IsFemale)
	return PickPhase(Strength, (IsFemale as int))
endFunction

function ApplyPreset(Actor ActorRef, int[] Preset) global
	ApplyPresetFloats(ActorRef, ToFloatArray(Preset))
endFunction

int[] function ToIntArray(float[] FloatArray) global
	int[] Output = new int[32]
	int i = FloatArray.Length
	while i
		i -= 1
		if i == 30
			Output[i] = FloatArray[i] as int
		else
			Output[i] = (FloatArray[i] * 100.0) as int
		endIf
	endWhile
	return Output
endFunction

float[] function ToFloatArray(int[] IntArray) global
	float[] Output = new float[32]
	int i = IntArray.Length
	while i
		i -= 1
		if i == 30
			Output[i] = IntArray[i] as float
		else
			Output[i] = (IntArray[i] as float) / 100.0
		endIf
	endWhile
	return Output
endFunction
