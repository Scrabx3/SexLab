scriptname sslBaseAnimation extends sslBaseObject
{
	Script for storing and reading Animation data
	Once an animation is registered, it is assumed read only

	DO NOT link to a script instance directly, use the main API instead
}

; NOTE: No plans to implement this, rather have branched animations fully functional and consider linear ones legacy - Scrab
; T-O-D-O: ADD CUSTOM ORGASM STAGE SETTINGS
; [4:36 PM] Ashal: I could add custom orgasm stage settings in the next update
; [4:36 PM] Ashal: it's not a bad idea
; [4:36 PM] Seijin: That'd be awesome
; [4:36 PM] Seijin: Maybe a tag system that says when the O should actually happen?
; [4:37 PM] Seijin: for instance: "EarlyO1" meaning one stage before the end, "EarlyO2" for 2, etc.
; [4:37 PM] Seijin: (Just spitballing)
; [4:37 PM] Ashal: Something like Anim.AddOrgasmStage(3) when settings up an animation. Would allow for multiple stages to be set for it as well
; [4:37 PM] Ashal: and if animation setup never calls that function, just default to using the last stage for orgasm like normal
; [4:41 PM] Ashal: I could add an option for it in the animation editor
; [4:41 PM] Ashal: the page where you can edit alignment settings
; [4:41 PM] Seijin: I'm comfortable with any option you would provide, just having flashbacks of a couple years ago when I knew fuck-all about scripting and couldn't understand how to make anything work.
; [4:41 PM] Seijin: That would work perfectly!
; [4:41 PM] Ashal: just a toggle box for whether the stage being edited is orgasm or not


; Total number of actors in this Animation
int Actors
int Function ActorCount()
	return Actors
EndFunction

; Total number of individual Stages
int Stages
int function StageCount()
	return Stages
endFunction

; DataKeys describing animation positions. Sorted and non-empty
int[] _DataKeys
int[] Function DataKeys()
	return PapyrusUtil.RemoveInt(_DataKeys, 0)
EndFunction

; Check if the given Set of keys matches the one required by this animation, the given set MUST be sorted
bool Function MatchKeys(int[] aiActorKeys)
	If(aiActorKeys.Length != Actors)
		return false
	EndIf
	return sslActorData.MatchArray(aiActorKeys, _DataKeys)
EndFunction

; ------------------------------------------------------- ;
; --- Tags					                                  --- ;
; ------------------------------------------------------- ;

; Supports prefixes (- disabled / ~ optional)
bool Function MatchTags(String[] asTags)
	return Parent.MatchTags(asTags)
EndFunction

bool Function HasTag(string Tag)
	return Parent.HasTag(Tag)
EndFunction

bool property IsSexual hidden
	bool function get()
		return HasTag("Sex") || HasTag("Vaginal") || HasTag("Anal") || HasTag("Oral")
	endFunction
endProperty

bool property IsVaginal hidden
	bool function get()
		return HasTag("Vaginal")
	endFunction
endProperty
bool property IsAnal hidden
	bool function get()
		return HasTag("Anal")
	endFunction
endProperty
bool property IsOral hidden
	bool function get()
		return HasTag("Oral")
	endFunction
endProperty
bool property IsDirty hidden
	bool function get()
		return HasTag("Dirty")
	endFunction
endProperty
bool property IsLoving hidden
	bool function get()
		return HasTag("Loving")
	endFunction
endProperty

bool property IsBedOnly hidden
	bool function get()
		return HasTag("BedOnly")
	endFunction
endProperty

; ------------------------------------------------------- ;
; --- Genders				                                  --- ;
; ------------------------------------------------------- ;

; Gender of the given actor:
; 0 - Male, 1 - Female, 2 - Futa, 3 - M. Crt, 4 - F. Crt
int Function GetGenderEx(int aiPosition)
	return sslActorData.GetGender(_DataKeys[aiPosition])
EndFunction

; Legacy gender count:
; 0 - Male, 1 - Female + Futa, 2 - M. Crt, 3 - F. Crt
int[] Property Genders Auto Hidden

; If the animation requires a creature to be gendered,
; meaning if an animation requires male or female traits of a creature to make sense
bool Property GenderedCreatures Auto Hidden

; ------------------------------------------------------- ;
; --- Creatures			                                  --- ;
; ------------------------------------------------------- ;

String[] RaceTypes

bool Function HasCreatures()
	return Genders[2] + Genders[3]
EndFunction

; If the animation includes actors of different race groups
bool function IsInterspecies()
	int k = sslActorData.GetRaceID(_DataKeys[0])
	int i = 1
	While(i < _DataKeys.Length)
		int nk = sslActorData.GetRaceID(_DataKeys[i])
		If(nk != k)
			return true
		EndIf
		k = nk
		i += 1
	EndWhile
	return false
endFunction

; All RaceKeys used by this animation
string[] function GetRaceKeys()
	return PapyrusUtil.ClearEmpty(RaceTypes)
endFunction

bool function HasActorRace(Actor ActorRef)
	return HasRaceID(MiscUtil.GetActorRaceEditorID(ActorRef))
endFunction
bool function HasRace(Race RaceRef)
	return HasRaceID(MiscUtil.GetRaceEditorID(RaceRef))
endFunction
bool function HasRaceKey(String RaceKey)
	return RaceType != "" && RaceKey != "" && sslCreatureAnimationSlots.HasRaceID(RaceType, RaceKey)
endFunction

; Does the specifieds position use the given racekey
bool function IsPositionRace(int Position, string RaceKey)
	return RaceTypes && RaceTypes[Position] == RaceKey
endFunction

; Given a set of RaceKeys, check if all RaceKeys are used in this animation, independent of order
bool Function HasAllRaceKeys(String[] asRaceKeys)
	If(asRaceKeys.Length != RaceTypes.Length)
		return false
	EndIf
	String[] cmp = PapyrusUtil.SortStringArray(asRaceKeys)
	String[] og = Papyrusutil.SortStringArray(RaceTypes)
	int i = 0
	While(i < cmp.Length)
		If(cmp[i] != og[i])
			return false
		EndIf
		i += 1
	EndWhile
	return true
EndFunction

; ------------------------------------------------------- ;
; --- Animations		                                  --- ;
; ------------------------------------------------------- ;

String[] _ANIMATIONS	; M x S matrix 	| M = ActorCount, S = StageCount

; Get all animations for the given position, beginning by stage 1
String[] function FetchPosition(int Position)
	If(Position >= Actors || Position < 0)
		Log("Invalid Position, '" + Position + "' given", "FetchPosition")
		return none
	EndIf
	String[] ret = Utility.CreateStringArray(Stages)
	int i = 0
	While(i < ret.Length)
		ret[i] = AccessAnimation(Position, i)
		i += 1
	EndWhile
	return ret
endFunction

; Get all animations for the given stage, beginning by position 1
String[] Function FetchStage(int Stage)
	if Stage > Stages
		Log("Unknown Stage, '"+Stage+"' given", "FetchStage")
		return none
	endIf
	String[] ret = Utility.CreateStringArray(Actors)
	int i = 0
	While(i < ret.Length)
		ret[i] = AccessAnimation(i, Stage - 1)
		i += 1
	EndWhile
	return ret
EndFunction

; Get the animation for the given position, at the given stage
String Function FetchPositionStage(int Position, int Stage)
	return AccessAnimation(Position, Stage - 1)
EndFunction

String Function AccessAnimation(int aiPosition, int aiStage)
	return _ANIMATIONS[aiPosition * Stages + aiStage]
EndFunction

Function WriteAnimation(int aiPosition, int aiStage, String asValue)
	int w = aiPosition * Stages + aiStage
	_ANIMATIONS[w] = asValue
EndFunction

; ------------------------------------------------------- ;
; --- Offsets				                                  --- ;
; ------------------------------------------------------- ;

float[] _OFFSETS	;	M	x S x 4	matrix 	| M = ActorCount, S = StageCount
float[] BedOffset	; 1D array					| BedOffset.Length == kOffsetEnd

int Property kForward  	= 0 AutoReadOnly
int Property kSideways 	= 1 AutoReadOnly
int Property kUpward   	= 2 AutoReadOnly
int Property kRotate   	= 3 AutoReadOnly
int Property kOffsetEnd = 4 AutoReadOnly

float Function AccessOffset(int aiPosition, int aiStage, int aiIndex)
	return _OFFSETS[(aiPosition * Stages * kOffsetEnd) + (aiStage * kOffsetEnd) + aiIndex]
EndFunction

Function EditOffset(int aiPosition, int aiStage, int aiIndex, float afValue)
	int w = (aiPosition * Stages * kOffsetEnd) + (aiStage * kOffsetEnd) + aiIndex
	_OFFSETS[w] = _OFFSETS[w] + afValue
EndFunction

Function WriteOffset(int aiPosition, int aiStage, int aiIndex, float afValue)
	int w = (aiPosition * Stages * kOffsetEnd) + (aiStage * kOffsetEnd) + aiIndex
	_OFFSETS[w] = afValue
EndFunction

float[] function GetPositionOffsets(string AdjustKey, int Position, int Stage)
	float[] Output = new float[4]
	return PositionOffsets(Output, AdjustKey, Position, Stage)
endFunction

float[] function GetRawOffsets(int Position, int Stage)
	float[] Output = new float[4]
	return RawOffsets(Output, Position, Stage)
endFunction

float[] function _GetStageAdjustments(string Registrar, string AdjustKey, int Stage) global native
float[] function GetPositionAdjustments(string AdjustKey, int Position, int Stage)
	return _GetStageAdjustments(Registry, InitAdjustments(AdjustKey, Position), Stage)
endFunction

float[] function _GetAllAdjustments(string Registrar, string AdjustKey) global native
float[] function GetAllAdjustments(string AdjustKey)
	return _GetAllAdjustments(Registry, Adjustkey)
endFunction

bool function _HasAdjustments(string Registrar, string AdjustKey, int Stage) global native
bool function HasAdjustments(string AdjustKey, int Stage)
	return _HasAdjustments(Registry, AdjustKey, Stage)
endFunction

; Get the Position offsets for one specific actor for one specific stage
function _PositionOffsets(string Registrar, string AdjustKey, string LastKey, int Stage, float[] RawOffsets) global native
float[] function PositionOffsets(float[] Output, string AdjustKey, int Position, int Stage, int BedTypeID = 0)
	Output = RawOffsets(Output, Position, Stage)
	_PositionOffsets(Registry, AdjustKey+"."+Position, LastKeys[Position], Stage, Output)
	If(BedTypeID && BedOffset.Length == 4)
		float Forward = Output[0]
		float Side = Output[1]
		Output[0] = ((Forward * Math.cos(BedOffset[3])) - (Side * Math.sin(BedOffset[3])))
		Output[1] = ((Forward * Math.sin(BedOffset[3])) + (Side * Math.cos(BedOffset[3])))

		Output[0] = Output[0] + BedOffset[0]
		Output[1] = Output[1] + BedOffset[1]
		Output[2] = Output[2] + BedOffset[2]
		Output[3] = Output[3] + BedOffset[3]
	EndIf
	If(Output[3] >= 360.0)
		Output[3] = Output[3] - 360.0
	ElseIf(Output[3] < 0.0)
		Output[3] = Output[3] + 360.0
	EndIf
	Log("PositionOffsets()[Forward:"+Output[0]+",Sideward:"+Output[1]+",Upward:"+Output[2]+",Rotation:"+Output[3]+"]")
	return Output
endFunction

; get a M x 4 matrix containing all offsets for every actor of the given stage
float[] Function PositionOffsetsEx(String asAdjustKey, int aiStage, int aiBedType)
	float[] ret = Utility.CreateFloatArray(Actors * kOffsetEnd)
	int i = 0
	While(i < Actors)
		float[] offsets 
		offsets = PositionOffsets(offsets, asAdjustKey, i, aiStage, aiBedType)
		int n = 0
		While(n < offsets.Length)
			ret[i * kOffsetEnd + n] = offsets[n]
			n += 1
		EndWhile
		i += 1
	EndWhile
	return ret
EndFunction

float[] function RawOffsets(float[] Output, int Position, int Stage)
	Output = new float[4]
	int i = 0
	While(i < kOffsetEnd)
		Output[i] = AccessOffset(Position, Stage - 1, i)
		i += 1
	EndWhile
	return Output
endFunction

function SetBedOffsets(float forward, float sideward, float upward, float rotate)
	BedOffset = new float[4]
	BedOffset[0] = forward
	BedOffset[1] = sideward
	BedOffset[2] = upward
	BedOffset[3] = rotate
endFunction

float[] function GetBedOffsets()
	if BedOffset.Length
		return BedOffset
	endIf
	return Utility.CreateFloatArray(4)
endFunction

; ------------------------------------------------------- ;
; --- FLags					                                  --- ;
; ------------------------------------------------------- ;

int[] _FLAGS ; M x S x 6 matrix 	| M = ActorCount, S = StageCount

int Property kSilent    = 0 AutoReadOnly
int Property kOpenMouth = 1 AutoReadOnly
int Property kStrapon   = 2 AutoReadOnly
int Property kSchlong   = 3 AutoReadOnly
int Property kCumID     = 4 AutoReadOnly
int Property kCumSrc    = 5 AutoReadOnly
int Property kFlagEnd		= 6 AUtoReadOnly

int[] Function GetFlags()
	return _FLAGS
EndFunction

int Function AccessFlag(int aiPosition, int aiStage, int aiIndex)
	return _FLAGS[(aiPosition * Stages * kFlagEnd) + (aiStage * kFlagEnd) + aiIndex]
EndFunction

Function EditFlag(int aiPosition, int aiStage, int aiIndex, int aiValue)
	int w = (aiPosition * Stages * kFlagEnd) + (aiStage * kFlagEnd) + aiIndex
	_FLAGS[w] = _FLAGS[w] + aiValue
EndFunction

Function WriteFlag(int aiPosition, int aiStage, int aiIndex, int aiValue)
	int w = (aiPosition * Stages * kFlagEnd) + (aiStage * kFlagEnd) + aiIndex
	_FLAGS[w] = aiValue
EndFunction

bool function IsSilent(int Position, int Stage)
	return AccessFlag(Position, Stage - 1, kSilent)
endFunction

bool function UseOpenMouth(int Position, int Stage)
	return AccessFlag(Position, Stage - 1, kOpenMouth)
endFunction

bool function UseStrapon(int Position, int Stage)
	return AccessFlag(Position, Stage - 1, kStrapon)
endFunction

int function _GetSchlong(string Registrar, string AdjustKey, string LastKey, int Stage) global native
int function GetSchlong(string AdjustKey, int Position, int Stage)
	int ret = sslBaseAnimation._GetSchlong(Registry, AdjustKey+"."+Position, LastKeys[Position], Stage)
	if ret == -99
		return AccessFlag(Position, Stage - 1, kSchlong)
	endIf
	return ret
endFunction

int function GetCumID(int Position, int Stage = 1)
	return AccessFlag(Position, Stage - 1, kCumID)
endFunction

int function GetCumSource(int Position, int Stage = 1)
	return AccessFlag(Position, Stage - 1, kCumSrc)
endFunction

bool function IsCumSource(int SourcePosition, int TargetPosition, int Stage = 1)
	int CumSrc = GetCumSource(TargetPosition, Stage)
	return CumSrc == -1 || CumSrc == SourcePosition
endFunction

function SetStageCumID(int Position, int Stage, int CumID, int CumSource = -1)
	If(Position > Actors || Stage > Stages)
		return
	EndIf
	WriteFlag(Position, Stage - 1, kCumID, CumID)
	WriteFlag(Position, Stage - 1, kCumSrc, CumSource)
endFunction

int function GetCum(int Position)
	return GetCumID(Position, Stages)
endFunction

; ------------------------------------------------------- ;
; --- SoundFX                                         --- ;
; ------------------------------------------------------- ;

Form[] StageSoundFX
Sound property SoundFX hidden
	Sound function get()
		return StageSoundFX[0] as Sound
	endFunction
	function set(Sound var)
		StageSoundFX[0] = var
	endFunction
endProperty

Sound function GetSoundFX(int Stage)
	if Stage < 1 || Stage > StageSoundFX.Length
		return StageSoundFX[0] as Sound
	endIf
	return StageSoundFX[Stage - 1] as Sound
endFunction

function SetStageSoundFX(int stage, Sound StageFX)
	if stage > Stages || stage < 1
		Log("Unknown animation stage, '"+stage+"' given.", "SetStageSound")
		return
	endIf
	if StageSoundFX.Length != Stages
		StageSoundFX = PapyrusUtil.ResizeFormArray(StageSoundFX, Stages, SoundFX)
	endIf
	StageSoundFX[stage - 1] = StageFX
endFunction

; ------------------------------------------------------- ;
; --- Stage Timer                                     --- ;
; ------------------------------------------------------- ;

float[] Timers

bool function HasTimer(int Stage)
	return Stage > 0 && Stage <= Timers.Length && Timers[Stage - 1] != 0.0
endFunction

float function GetTimer(int Stage)
	if !HasTimer(Stage)
		return 0.0 ; Stage has no timer
	endIf
	return Timers[Stage - 1]
endFunction

Function SetStageTimer(int Stage, float Timer)
	If(!Stage || Stage > Stages)
		Log("Unknown animation stage, '"+Stage+"' given.", "SetStageTimer")
		return
	ElseIf(Timers.Length != Stages)
		Timers = Utility.CreateFloatArray(Stages)
	EndIf
	Timers[Stage - 1] = Timer
EndFunction

float function GetTimersRunTime(float[] StageTimers)
	if StageTimers.Length <= 1
		return -1.0
	endIf
	float seconds = 0.0
	int LastTimer = StageTimers.Length - 1
	int LastStage = Stages - 1
	int Stage = Stages
	while Stage > 0
 		Stage -= 1
 		if HasTimer(Stage)
 			seconds += GetTimer(Stage)
 		elseIf Stage < LastStage
 			seconds += StageTimers[PapyrusUtil.ClampInt(Stage, 0, (LastTimer - 1))]
 		elseIf Stage >= LastStage
 			seconds += StageTimers[LastTimer]
 		endIf
	endWhile
	return seconds
endFunction

float function GetRunTime()
	return GetTimersRunTime(Config.StageTimer)
endFunction

float function GetRunTimeLeadIn()
	return GetTimersRunTime(Config.StageTimerLeadIn)
endFunction

float function GetRunTimeAggressive()
	return GetTimersRunTime(Config.StageTimerAggr)
endFunction

; ------------------------------------------------------- ;
; --- Animation Setup                                 --- ;
; ------------------------------------------------------- ;

int position_stage

; initialize a position and build the associated actor key
int Function CreatePosition(int aiGender, bool[] abFlags, int aiCum = -1, String asRaceKey = "")
	If(Actors >= 5)
		Log("Cannot add more positions to animation")
		return -1
	EndIf
	int idx = Actors
	Actors += 1
	; Only allocate more space if this is position > 0, as position == 0 has no stages fixed
	; allocation for pos1 happens in AddPositionStage()
	If(idx > 0)
		_ANIMATIONS = Utility.ResizeStringArray(_ANIMATIONS, Actors * Stages)
		_OFFSETS = Utility.ResizeFloatArray(_OFFSETS, Actors * Stages * kOffsetEnd)
		_FLAGS = Utility.ResizeIntArray(_FLAGS, Actors * Stages * kFlagEnd)
	Else
		_ANIMATIONS = new String[1]
		_OFFSETS = new float[4]
		_FLAGS = new int[6]
	EndIf
	; Legacy support
	If(asRaceKey == "Wolves" || asRaceKey == "Dogs")
		asRaceKey = "Canines"
	EndIf
	; Invalid RaceKey returns 0/human
	int raceid = sslActorData.GetRaceIDByRaceKey(asRaceKey)
	_DataKeys[idx] = sslActorData.BuildCustomKey(aiGender, raceid, abFlags)

	position_stage = 0
	WriteFlag(idx, 0, kCumID, aiCum)
	return idx
EndFunction

; Add a new Stage to a given Position. This has to be called directly after CreatePosition() 
; and requires to be called in succession for every single Stage before creating a second position
Function AddPositionStage(int Position, string AnimationEvent, float forward = 0.0, float side = 0.0, float up = 0.0, float rotate = 0.0, bool silent = false, bool openmouth = false, bool strapon = true, int sos = 0)
	If(Position == -1 || Position >= 5 || AnimationEvent == "")
		Log("FATAL: Invalid arguments!", "AddPositionStage("+Position+", "+AnimationEvent+")")
		return
	ElseIf(Position == 0)
		; The first position dictates number of stages
		Stages += 1
		If(Stages > 1)
			_ANIMATIONS = Utility.ResizeStringArray(_ANIMATIONS, Actors * Stages)
			_OFFSETS = Utility.ResizeFloatArray(_OFFSETS, Actors * Stages * kOffsetEnd)
			_FLAGS = Utility.ResizeIntArray(_FLAGS, Actors * Stages * kFlagEnd)
		EndIf
	EndIf

	WriteAnimation(Position, position_stage, AnimationEvent)

	WriteOffset(Position, position_stage, kForward, forward)
	WriteOffset(Position, position_stage, kSideways, side)
	WriteOffset(Position, position_stage, kUpward, up)
	WriteOffset(Position, position_stage, kRotate, rotate)

	WriteFlag(Position, position_stage, kSilent, silent as int)
	WriteFlag(Position, position_stage, kOpenMouth, openmouth as int)
	WriteFlag(Position, position_stage, kStrapon, strapon as int)
	WriteFlag(Position, position_stage, kSchlong, sos as int)
	WriteFlag(Position, position_stage, kCumID, AccessFlag(Position, 0, kCumID))
	WriteFlag(Position, position_stage, kCumSrc, -1)

	position_stage += 1
EndFunction

; Complete the setup & finalize data
function Save(int id = -1)
	; Sort positions
	_DataKeys = Utility.ResizeIntArray(_DataKeys, Actors)
	int[] ogidx = Utility.CreateIntArray(Actors)
	int k = 0
	While(k < ogidx.Length)
		ogidx[k] = k
		k += 1
	EndWhile
	; Log("Keys before sorting: " + _DataKeys + " / " + ogidx)
	int i = 1
	While(i < _DataKeys.Length)
		int x = ogidx[i]
		int it = _DataKeys[i]
		int n = i - 1
		While(n >= 0 && sslActorData.IsLess(it, _DataKeys[n]))
			_DataKeys[n + 1] = _DataKeys[n]
			ogidx[n + 1] = ogidx[n]
			n -= 1
		EndWhile
		_DataKeys[n + 1] = it
		ogidx[n + 1] = x
		i += 1
	EndWhile
	; Log("Keys after sorting: " + _DataKeys + " / " + ogidx)
	; Log("Animations before sorting: " + _ANIMATIONS)
	String[] og_str = _ANIMATIONS
	float[] og_flt = _OFFSETS
	int[] og_int = _FLAGS

	_ANIMATIONS = Utility.CreateStringArray(og_str.Length)
	_OFFSETS = Utility.CreateFloatArray(og_flt.Length)
	_FLAGS = Utility.CreateIntArray(og_int.Length)

	int n = 0
	While(n < Actors)
		; animation >> aiPosition * Stages + aiStage
		; offsets		>> (aiPosition * Stages * kOffsetEnd) + (aiStage * kOffsetEnd) + aiIndex
		; flags			>> (aiPosition * Stages * kFlagEnd) + (aiStage * kFlagEnd) + aiIndex
		int idx = ogidx[n]
		int j = 0
		While(j < Stages)
			; with idx = 2, s = 4, j <= 4
			; animation >> idx * s + j
			WriteAnimation(n, j, og_str[idx * Stages + j])

			WriteFlag(n, j, kSilent, og_int[(idx * Stages * kFlagEnd) + (j * kFlagEnd) + kSilent])
			WriteFlag(n, j, kOpenMouth, og_int[(idx * Stages * kFlagEnd) + (j * kFlagEnd) + kOpenMouth])
			WriteFlag(n, j, kStrapon, og_int[(idx * Stages * kFlagEnd) + (j * kFlagEnd) + kStrapon])
			WriteFlag(n, j, kSchlong, og_int[(idx * Stages * kFlagEnd) + (j * kFlagEnd) + kSchlong])
			WriteFlag(n, j, kCumID, og_int[(idx * Stages * kFlagEnd) + (j * kFlagEnd) + kCumID])
			WriteFlag(n, j, kCumSrc, og_int[(idx * Stages * kFlagEnd) + (j * kFlagEnd) + kCumSrc])
			
			WriteOffset(n, j, kForward, og_flt[(idx * Stages * kOffsetEnd) + (j * kOffsetEnd) + kForward])
			WriteOffset(n, j, kSideways, og_flt[(idx * Stages * kOffsetEnd) + (j * kOffsetEnd) + kSideways])
			WriteOffset(n, j, kUpward, og_flt[(idx * Stages * kOffsetEnd) + (j * kOffsetEnd) + kUpward])
			WriteOffset(n, j, kRotate, og_flt[(idx * Stages * kOffsetEnd) + (j * kOffsetEnd) + kRotate])
			j += 1
		EndWhile
		n += 1
	EndWhile
	; Log("Animations after sorting: " + _ANIMATIONS)

	; Add legacy gender tags/data
	String[] gendertag = Utility.CreateStringArray(Actors)
	int j = 0
	While(j < Actors)
		If(sslActorData.IsMale(_DataKeys[j]))
			gendertag[j] = "M"
			genders[0] = genders[0] + 1
		ElseIf(sslActorData.IsFemale(_DataKeys[j]))
			gendertag[j] = "F"
			genders[1] = genders[1] + 1
		ElseIf(sslActorData.IsCreature(_DataKeys[j]))
			gendertag[j] = "C"
			If(sslActorData.IsMaleCreature(_DataKeys[j]))
				genders[2] = genders[2] + 1
			Else
				genders[3] = genders[3] + 1
			EndIf
		EndIf
		j += 1
	EndWhile
	PapyrusUtil.SortStringArray(gendertag, false)
	AddTag(PapyrusUtil.StringJoin(gendertag, ""))
	PapyrusUtil.SortStringArray(gendertag, true)
	AddTag(PapyrusUtil.StringJoin(gendertag, ""))
	; Import Offsets
	ImportOffsetsDefault("BedOffset")
	ImportOffsets("BedOffset")
	; Reset saved keys if they no longer match
	if LastKeyReg != Registry
		LastKeys = new string[5]
	endIf
	LastKeyReg = Registry
	; Log the new animation
	if IsCreature
		; RaceTypes = PapyrusUtil.ResizeStringArray(RaceTypes, Actors)
		if IsInterspecies()
			AddTag("Interspecies")
		else
			RemoveTag("Interspecies")
		endIf
	endIf
	Log("Done registering animation " + Name)
	parent.Save(id)
endFunction

; ------------------------------------------------------- ;
; --- Initialize                                      --- ;
; ------------------------------------------------------- ;

function Initialize()
	Actors = 0
	Stages = 0
	GenderedCreatures = false

	_DataKeys = new int[5]
	Genders = new int[4]
	StageSoundFX = new Form[1]

	; Only init if needed to keep between registry resets.
	if LastKeys.Length != 5
		LastKeys  = new string[5]
	endIf

	RaceTypes  = Utility.CreateStringArray(0)
	BedOffset  = Utility.CreateFloatArray(0)
	Timers     = Utility.CreateFloatArray(0)

	parent.Initialize()
EndFunction

; ------------------------------------------------------- ;
; --- Adjustments                                     --- ;
; ------------------------------------------------------- ;

string[] LastKeys
string LastKeyReg

function _SetAdjustment(string Registrar, string AdjustKey, int Stage, int Slot, float Adjustment) global native
function SetAdjustment(string AdjustKey, int Position, int Stage, int Slot, float Adjustment)
	if Position < Actors
		LastKeys[Position] = InitAdjustments(AdjustKey, Position)
		sslBaseAnimation._SetAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot, Adjustment)
	endIf
endFunction

float function _GetAdjustment(string Registrar, string AdjustKey, int Stage, int nth) global native
float function GetAdjustment(string AdjustKey, int Position, int Stage, int Slot)
	return sslBaseAnimation._GetAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot)
endFunction

float function _UpdateAdjustment(string Registrar, string AdjustKey, int Stage, int nth, float by) global native
function UpdateAdjustment(string AdjustKey, int Position, int Stage, int Slot, float AdjustBy)
	if Position < Actors
		LastKeys[Position] = InitAdjustments(AdjustKey, Position)
		sslBaseAnimation._UpdateAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot, AdjustBy)
	endIf
endFunction
function UpdateAdjustmentAll(string AdjustKey, int Position, int Slot, float AdjustBy)
	if Position < Actors
		LastKeys[Position] = InitAdjustments(AdjustKey, Position)
		int Stage = Stages
		while Stage
			sslBaseAnimation._UpdateAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot, AdjustBy)
			Stage -= 1
		endWhile
	endIf
endFunction

function AdjustForward(string AdjustKey, int Position, int Stage, float AdjustBy, bool AdjustStage = false)
	if AdjustStage
		UpdateAdjustment(AdjustKey, Position, Stage, 0, AdjustBy)
	else
		UpdateAdjustmentAll(AdjustKey, Position, 0, AdjustBy)
	endIf
endFunction

function AdjustSideways(string AdjustKey, int Position, int Stage, float AdjustBy, bool AdjustStage = false)
	if AdjustStage
		UpdateAdjustment(AdjustKey, Position, Stage, 1, AdjustBy)
	else
		UpdateAdjustmentAll(AdjustKey, Position, 1, AdjustBy)
	endIf
endFunction

function AdjustUpward(string AdjustKey, int Position, int Stage, float AdjustBy, bool AdjustStage = false)
	if AdjustStage
		UpdateAdjustment(AdjustKey, Position, Stage, 2, AdjustBy)
	else
		UpdateAdjustmentAll(AdjustKey, Position, 2, AdjustBy)
	endIf
endFunction

function AdjustSchlong(string AdjustKey, int Position, int Stage, int AdjustBy)
	UpdateAdjustment(AdjustKey, Position, Stage, 3, AdjustBy as float)
endFunction

function _ClearAdjustments(string Registrar, string AdjustKey) global native
function RestoreOffsets(string AdjustKey)
	_ClearAdjustments(Registry, AdjustKey+".0")
	_ClearAdjustments(Registry, AdjustKey+".1")
	_ClearAdjustments(Registry, AdjustKey+".2")
	_ClearAdjustments(Registry, AdjustKey+".3")
	_ClearAdjustments(Registry, AdjustKey+".4")
endFunction

bool function _CopyAdjustments(string Registrar, string AdjustKey, float[] Array) global native
function CopyAdjustmentsFrom(string AdjustKey, string CopyKey, int Position)
	CopyKey   = CopyKey+"."+Position
	AdjustKey = AdjustKey+"."+Position
	float[] List
	if _HasAdjustments(Registry, CopyKey, Stages)
		List = _GetAllAdjustments(Registry, CopyKey)
	else
		List = GetEmptyAdjustments(Position)
	endIf
	_ClearAdjustments(Registry, AdjustKey)
	_CopyAdjustments(Registry, AdjustKey, List)
endFunction

string function GetLastKey(int Position)
	string LastKey = LastKeys[Position]
	if LastKey != "" && LastKey != "Global."+Position && _HasAdjustments(Registry, LastKey, Stages)
		return LastKey
	endIf
	return "Global."+Position
endFunction

string function InitAdjustments(string AdjustKey, int Position)
	if !AdjustKey || Position >= Actors || Position < 0
		Log("Unknown Position, '"+Position+"' given", "InitAdjustments")
		return LastKeys[Position]
	endIf

	AdjustKey += "."+Position
	if !_HasAdjustments(Registry, AdjustKey, Stages)
		; Pick key to copy from
		string CopyKey = LastKeys[Position]
		if AdjustKey == "Global."+Position || CopyKey == "" || CopyKey == "Global."+Position || !_HasAdjustments(Registry, CopyKey, Stages)
			CopyKey = "Global."+Position
		endIf
		if CopyKey != "Global."+Position
			string[] RaceIDs = PapyrusUtil.StringSplit(AdjustKey, ".")
			string[] LastRaceIDs = PapyrusUtil.StringSplit(LastKeys[Position], ".")
			if RaceIDs && RaceIDs.length > Position && (!LastRaceIDs || LastRaceIDs.length < Actors || RaceIDs[Position] != LastRaceIDs[Position])
				string id = RaceIDs[Position]
				Race RaceRef = Race.GetRace(id)
				string Gender = ""
				if !(RaceRef || id == "human" || sslCreatureAnimationSlots.HasRaceKey(id))
					int i = 0
					while i < 6
						i += 1
						id = StringUtil.Substring(RaceIDs[Position], 0, (StringUtil.GetLength(RaceIDs[Position]) - i))
						RaceRef = Race.GetRace(id)
						if RaceRef || id == "human" || sslCreatureAnimationSlots.HasRaceKey(id)
							Gender = StringUtil.GetNthChar(RaceIDs[Position], (StringUtil.GetLength(RaceIDs[Position]) - i))
							i = 6
						endIf
					endWhile
				endIf
				if Gender && (Gender != "M") && (Gender != "F") && (Gender != "C")
					Gender = ""
				endIf
				if id+Gender == RaceIDs[Position] || id+Gender+"M" == RaceIDs[Position] || id+Gender+"F" == RaceIDs[Position]
					CopyKey = "Global."+Position
				endIf
			endIf
		endIf
		if AdjustKey != "Global."+Position && CopyKey == "Global."+Position && !_HasAdjustments(Registry, CopyKey, Stages)
			; Initialize Global profile
			_CopyAdjustments(Registry, "Global."+Position, GetEmptyAdjustments(Position))
		endIf
		; Get adjustments from lastkey or default global
		float[] List = _GetAllAdjustments(Registry, CopyKey)
		if List.Length != (Stages * 4)
			List = GetEmptyAdjustments(Position)
			Log(List, "InitAdjustments("+AdjustKey+")")
		else
			Log(List, "CopyAdjustments("+CopyKey+", "+AdjustKey+")")
		endIf
		; Copy list to profile
		_CopyAdjustments(Registry, AdjustKey, List)
	endIf
	return AdjustKey
endFunction

; Get the schlong adjustement value for this actor, beginning at Stage 1
float[] function GetEmptyAdjustments(int Position)
	float[] ret = Utility.CreateFloatArray(Stages * 4)
	int i = 0
	While(i < Stages)
		ret[i] = AccessFlag(Position, i, kSchlong)
		i += 1
	EndWhile
	return ret
endFunction

string[] function _GetAdjustKeys(string Registrar) global native
string[] function GetAdjustKeys()
	return _GetAdjustKeys(Registry)
endFunction

; ------------------------------------------------------- ;
; --- Export/Import                                   --- ;
; ------------------------------------------------------- ;

;Animation Offsets
function ExportOffsets(string Type = "BedOffset")
	float[] Values
	if Type == "BedOffset"
		Values = GetBedOffsets()
	else
		return
	endIf
	string File = "../SexLab/SexLabOffsets.json"

	; Set label of export
	JsonUtil.SetStringValue(File, "ExportLabel", "User Defined Offsets " + Utility.GetCurrentRealTime())

	JsonUtil.FloatListClear(File, Registry+"."+Type)
	if PapyrusUtil.CountFloat(Values, 0.0) != Values.Length
		JsonUtil.FloatListCopy(File, Registry+"."+Type, Values)
	endIf

	; Save to JSON file
	JsonUtil.Save(File, true)
endFunction

function ImportOffsets(string Type = "BedOffset")
	If(Type != "BedOffset")
		return
	EndIf
	float[] Values = GetBedOffsets()
	string File = "../SexLab/SexLabOffsets.json"
	int len = 4
	if JsonUtil.FloatListCount(File, Registry+"."+Type) == len || JsonUtil.IntListCount(File, Registry+"."+Type) == len
		if Values.Length != len
			Values = Utility.CreateFloatArray(len)
		endIf
		int i = 0
		while i < len
			Values[i] = JsonUtil.FloatListGet(File, Registry+"."+Type, i)
			i += 1
		endWhile
		BedOffset = Values
	endIf
endFunction

function ImportOffsetsDefault(string Type = "BedOffset")
	If(Type != "BedOffset")
		return
	EndIf
	string File = "../SexLab/SexLabOffsetsDefault.json"
	float[] Values = GetBedOffsets()
	int len = 4
	if JsonUtil.FloatListCount(File, Registry+"."+Type) == len || JsonUtil.IntListCount(File, Registry+"."+Type) == len
		if Values.Length != len
			Values = Utility.CreateFloatArray(len)
		endIf
		int i = 0
		while i < len
			Values[i] = JsonUtil.FloatListGet(File, Registry+"."+Type, i)
			i += 1
		endWhile
		BedOffset = Values
	endIf
endFunction

function ExportJSON()
	string Folder = "../SexLab/Animations/"
	if IsCreature
		Folder += "Creatures/"
	endIf
	string Filename = Folder+Registry+".json"
	JsonUtil.ClearAll(Filename)

	JsonUtil.SetPathStringValue(Filename, ".name", Name)
	JsonUtil.SetPathIntValue(Filename, ".enabled", Enabled as int)
	JsonUtil.SetPathStringArray(Filename, ".tags", GetTags())
	if StageSoundFX
		JsonUtil.SetPathFormArray(Filename, ".sfx", StageSoundFX)
	endIf
	if Timers
		JsonUtil.SetPathFloatArray(Filename, ".timers", Timers)
	endIf
	JsonUtil.SetPathFloatArray(Filename, ".bedoffset", GetBedOffsets())
	int Position
	while Position < PositionCount
		string path = ".positions["+Position+"]"
		int Stage = 0
		while Stage < StageCount
			JsonUtil.SetPathStringValue(Filename, path + ".animation["+Stage+"]", AccessAnimation(Position, Stage))
			JsonUtil.SetPathFloatArray(Filename, path + ".offset["+Stage+"]", GetRawOffsets(Position, Stage))
			JsonUtil.SetPathIntValue(Filename, path + ".flag.schlong["+Stage+"]", AccessFlag(Position, Stage, kSilent))
			JsonUtil.SetPathIntValue(Filename, path + ".flag.cum["+Stage+"]", AccessFlag(Position, Stage, kOpenMouth))
			JsonUtil.SetPathIntValue(Filename, path + ".flag.cumsrc["+Stage+"]", AccessFlag(Position, Stage, kStrapon))
			JsonUtil.SetPathIntValue(Filename, path + ".flag.openmouth["+Stage+"]", AccessFlag(Position, Stage, kSchlong))
			JsonUtil.SetPathIntValue(Filename, path + ".flag.silent["+Stage+"]", AccessFlag(Position, Stage, kCumID))
			JsonUtil.SetPathIntValue(Filename, path + ".flag.strapon["+Stage+"]", AccessFlag(Position, Stage, kCumSrc))
		endWhile
		JsonUtil.SetPathIntValue(Filename, path + ".gender", GetGender(Position))
		if IsCreature && CreaturePosition(Position)
			if RaceTypes[Position] == ""
				JsonUtil.SetPathStringValue(Filename, path + ".creature", RaceType)
			else
				JsonUtil.SetPathStringValue(Filename, path + ".creature", RaceTypes[Position])
			endIf
		endIf
		Position += 1
	endWhile
	JsonUtil.Save(Filename)
	JsonUtil.Unload(Filename)
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;    				    ██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗	  				  ;
;    				    ██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝	  				  ;
;    				    ██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 	  				  ;
;    				    ██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  	  				  ;
;    				    ███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   	  				  ;
;    				    ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   	  				  ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nFunction '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.\n\nPlease report this to Scrab with a Papyrus Log attached")
	Debug.TraceStack("Invoking Legacy Content Function " + asFunction)
EndFunction

; Just compare directly
bool function MatchGender(int Gender, int Position)
	return Gender == GetGender(Position) || (!GenderedCreatures && Gender > 1)
endFunction

; Just use the property directly
int function FemaleCount()
	return Genders[1]
endFunction
int function MaleCount()
	return Genders[0]
endFunction
bool function IsSexual()
	return IsSexual
endFunction

int Function GetGender(int Position)
	return sslActorData.GetLegacyGenderByKey(_DataKeys[Position])
EndFunction

bool Function MalePosition(int Position)
	return sslActorData.IsMale(_DataKeys[Position])
EndFunction

bool Function FemalePosition(int Position)
	return sslActorData.IsFemale(_DataKeys[Position])
EndFunction

bool Function CreaturePosition(int Position)
	return sslActorData.IsCreature(_DataKeys[Position])
EndFunction

; Scene Building Legacy Functions
int function AddPosition(int Gender = 0, int AddCum = -1)
	return CreatePosition(Gender, Utility.CreateBoolArray(0), AddCum)
endFunction
bool function CheckByTags(int ActorCount, string[] Search, string[] Suppress, bool RequireAll)
	return Enabled && ActorCount == PositionCount && CheckTags(Search, RequireAll) && (Suppress.Length < 1 || !HasOneTag(Suppress))
endFunction

int[] function GetPositionFlags(string AdjustKey, int Position, int Stage)
	return PositionFlags(Utility.CreateIntArray(5), AdjustKey, Position, Stage)
endFunction

int[] function PositionFlags(int[] Output, string AdjustKey, int Position, int Stage)
	Output = new int[5]
	Output[0] = AccessFlag(Position, Stage - 1, kSilent)
	Output[1] = AccessFlag(Position, Stage - 1, kOpenMouth)
	Output[2] = AccessFlag(Position, Stage - 1, kStrapon)
	Output[3] = GetSchlong(AdjustKey, Position, Stage)
	Output[4] = GetGender(Position)
	return Output
endFunction

; Misc stuff
int property StageCount hidden
	int function get()
		return Stages
	endFunction
endProperty
int property PositionCount hidden
	int function get()
		return Actors
	endFunction
endProperty
bool property IsCreature hidden
	bool function get()
		return Creatures
	endFunction
endProperty
int Property Males
	int Function get()
		return Genders[0]
	EndFunction
EndProperty
int Property Females
	int Function get()
		return Genders[1]
	EndFunction
EndProperty
int Property Creatures
	int Function get()
		return Genders[2] + Genders[3]
	EndFunction
EndProperty
int Property MaleCreatures
	int Function get()
		return Genders[2]
	EndFunction
EndProperty
int Property FemaleCreatures
	int Function get()
		return Genders[3]
	EndFunction
EndProperty

function SetContent(int contentType)
endFunction

function AddRaceID(string RaceID)
	if !HasRaceID(RaceID)
		sslCreatureAnimationSlots.AddRaceID(RaceType, RaceID)
	endIf
endFunction

string[] function GetRaceIDs()
	return sslCreatureAnimationSlots.GetAllRaceIDs(RaceType)
endFunction

function AddRace(Race RaceRef)
	AddRaceID(MiscUtil.GetRaceEditorID(RaceRef))
endFunction

; Redundant due to outdated naming conventions
bool function HasRaceID(string RaceID)
	return RaceType != "" && RaceID != "" && sslCreatureAnimationSlots.HasRaceID(RaceType, RaceID)
endFunction

; Redundant due to outdated naming conventions
string[] function GetRaceTypes()
	return PapyrusUtil.ClearEmpty(RaceTypes)
endFunction

bool function HasValidRaceKey(string[] RaceKeys)
	int i = RaceKeys.Length
	while i
		i -= 1
		if RaceKeys[i] != "" && RaceTypes.Find(RaceKeys[i]) != -1
			return true
		endIf
	endWhile
	return false
endFunction

int function CountValidRaceKey(string[] RaceKeys)
	int i = RaceKeys.Length
	int out = 0
	while i
		i -= 1
		if RaceKeys[i] != "" && RaceTypes.Find(RaceKeys[i]) != -1
			out += PapyrusUtil.CountString(RaceTypes, RaceKeys[i])
		endIf
	endWhile
	return out
endFunction

bool function HasPostionRace(int Position, string[] RaceKeys)
	return RaceTypes && RaceKeys.Find(RaceTypes[Position]) != -1
endFunction

; Note sure how this would ever be useful
Form[] property CreatureRaces hidden
	form[] function get()
		string[] Races = sslCreatureAnimationSlots.GetAllRaceIDs(RaceType)
		int i = Races.Length
		Form[] RaceRefs = Utility.CreateFormArray(i)
		while i
			i -= 1
			RaceRefs[i] = Race.GetRace(Races[i])
		endWhile
		return PapyrusUtil.ClearNone(RaceRefs)
	endFunction
endProperty

int function AddCreaturePosition(string RaceKey, int Gender = 2, int AddCum = -1)
	If Gender <= 0 || Gender > 3
		Gender = 2
	elseIf Gender == 1
		Gender = 3
	endIf
	; Shift gender by 1 as legacy gender has no futa key
	return CreatePosition(Gender + 1, Utility.CreateBoolArray(0), AddCum, RaceKey)
endFunction

string function GetGenderString(int Gender)
	if Gender == 0
		return "M"
	elseIf Gender == 1
		return "F"
	elseIf Gender >= 2
		return "C"
	endIf
	return ""
endFunction

string function GenderTag(int count, string gender)
	if count == 0
		return ""
	elseIf count == 1
		return gender
	elseIf count == 2
		return gender+gender
	elseIf count == 3
		return gender+gender+gender
	elseIf count == 4
		return gender+gender+gender+gender
	elseIf count == 5
		return gender+gender+gender+gender+gender
	endIf
	return ""
endFunction

string function GetGenderTag(bool Reverse = false)
	if Reverse
		return GenderTag(Creatures, "C")+GenderTag(Males, "M")+GenderTag(Females, "F")
	endIf
	return GenderTag(Females, "F")+GenderTag(Males, "M")+GenderTag(Creatures, "C")
endFunction

float function CalcCenterAdjuster(int Stage)
endFunction

int[] function FlagsArray(int Position)
	LogRedundant("FlagsArray")
endFunction

function FlagsSave(int Position, int[] Flags)
	LogRedundant("FlagsSave")
endFunction

float[] function OffsetsArray(int Position)
	LogRedundant("OffsetsArray")
endFunction

function OffsetsSave(int Position, float[] Offsets)
	LogRedundant("OffsetsSave")
endFunction

function InitArrays(int Position)
	LogRedundant("InitArrays")
endFunction

int function DataIndex(int Slots, int Position, int Stage, int Slot = 0)
	LogRedundant("DataIndex")
endFunction

int function StageIndex(int Position, int Stage)
	LogRedundant("StageIndex")
endFunction

int function AdjIndex(int Stage, int Slot = 0, int Slots = 4)
	LogRedundant("AdjIndex")
endfunction

int function OffsetIndex(int Stage, int Slot)
	LogRedundant("OffsetIndex")
endfunction

int function FlagIndex(int Stage, int Slot)
	LogRedundant("FlagIndex")
endfunction

; Animations now have complex creature support using data keys
string property RaceType
	String Function Get()
		int i = 0
		While(i < _DataKeys.Length)
			String rk = sslActorData.GetRaceKey(_DataKeys[i])
			If(rk != "human")
				return rk
			EndIf
			i += 1
		EndWhile
		return ""
	EndFunction
EndProperty

Function GetAnimEvents(string[] AnimEvents, int Stage)
	If(AnimEvents.Length != 5 || Stage > Stages)
		Log("Invalid Call("+AnimEvents+", "+Stage+"/"+Stages+")", "GetAnimEvents")
		return
	EndIf
	String[] copy = FetchStage(Stage)
	int i = 0
	While(i < copy.Length)
		AnimEvents[i] = copy[i]
		i += 1
	EndWhile
EndFunction

; Animations are read only after setup, dont make everything mutable just cuz you can
function SetRaceKey(string RaceKey)
endFunction

function SetPositionRaceKey(int Position, string RaceKey)
endFunction

function SetRaceIDs(string[] RaceList)
endFunction

function SetPositionStage(int Position, int Stage, string AnimationEvent)
endFunction
