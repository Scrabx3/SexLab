scriptname sslBaseAnimation extends sslBaseObject
{
	Script for storing and reading Animation data
	Once an animation is registered, it is assumed read only

	DO NOT link to a script instance directly, use the main API instead

	NOTE:
	This script has been made redundant and is merely used as a proxy to call to the
	actual registry inside the native code base. Its usage is discouraged and should be avoided
	See SexlabRegistry.psc for concrete animation access
}

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

String PROXY_ID
Function SetProxy(String asProxyID)
	PROXY_ID = asProxyID
EndFunction
bool Function HasProxy()
	return PROXY_ID && SexLabRegistry.SceneExists(PROXY_ID)
EndFunction

int Function GetMaxDepth()
	return SexLabRegistry.GetPathMax(PROXY_ID, "").Length
EndFunction

; Get the stage represented by some depth, or the max depth stage if aiDepth is greater than max depth
String Function GetStageBounded(int aiDepth)
	String[] maxpath = SexLabRegistry.GetPathMax(PROXY_ID, "")
	If (maxpath.Length >= aiDepth)
		return maxpath[maxpath.Length - 1]
	EndIf
	return maxpath[aiDepth]
EndFunction

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

bool property GenderedCreatures
	bool Function Get()
		If (!PROXY_ID)
			return false
		EndIf
		return GetGendersA()[3] > 0
	EndFUnction
	Function Set(bool aSet)
	EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Array Indexers                                  --- ;
; ------------------------------------------------------- ;

int function DataIndex(int Slots, int Position, int Stage, int Slot = 0)
	return -1
endFunction

int function StageIndex(int Position, int Stage)
	return -1
endFunction

int function AdjIndex(int Stage, int Slot = 0, int Slots = 4)
	return -1
endfunction

int function OffsetIndex(int Stage, int Slot)
	return -1
endfunction

int function FlagIndex(int Stage, int Slot)
	return -1
endfunction

; ------------------------------------------------------- ;
; --- Animation Events                                --- ;
; ------------------------------------------------------- ;

string[] function FetchPosition(int Position)
	if Position >= ActorCount() || Position < 0
		Log("Unknown Position, '"+Position+"' given", "FetchPosition")
		return none
	endIf
	int depth = GetMaxDepth()
	String node = ""
	string[] ret = Utility.CreateStringArray(depth)
	int i = 0
	While(i < ret.Length)
		ret[i] = SexLabRegistry.GetAnimationEvent(PROXY_ID, node, Position)
		node = SexLabRegistry.BranchTo(PROXY_ID, node, 0)
		i += 1
	EndWhile
	return ret
endFunction

string[] function FetchStage(int Stage)
	int depth = GetMaxDepth()
	if Stage > depth || Stage < 0
		Log("Unknown Stage, '"+Stage+"' given", "FetchStage")
		return none
	endif
	return SexlabRegistry.GetAnimationEventA(PROXY_ID, Stage)
endFunction

function GetAnimEvents(string[] AnimEvents, int Stage)
	int depth = GetMaxDepth()
	if AnimEvents.Length != 5 || Stage > depth || Stage < 0
		Log("Invalid Call(" + AnimEvents + ", " + Stage + "/" + depth + ")", "GetAnimEvents")
		return
	endif
	String[] anims = SexlabRegistry.GetAnimationEventA(PROXY_ID, Stage)
	int i = 0
	while i < anims.Length
		AnimEvents[i] = anims[i]
		i += 1
	endWhile
endFunction

string function FetchPositionStage(int Position, int Stage)
	String GetStageBounded = GetStageBounded(Stage)
	return SexLabRegistry.GetAnimationEvent(PROXY_ID, Stage, Position)
endFunction

function SetPositionStage(int Position, int Stage, string AnimationEvent)
endFunction

; ------------------------------------------------------- ;
; --- Stage Timer                                     --- ;
; ------------------------------------------------------- ;

bool function HasTimer(int Stage)
	return GetTimer(Stage) > 0
endFunction

float function GetTimer(int Stage)
	String stage_ = GetStageBounded(Stage)
	return SexLabRegistry.GetFixedLength(PROXY_ID, stage_)
endFunction

function SetStageTimer(int Stage, float Timer)
endFunction

float function GetTimersRunTime(float[] StageTimers)
	if StageTimers.Length < 2
		return -1.0
	endIf
	float seconds = 0.0
	String stage = SexLabRegistry.GetStartAnimation(PROXY_ID)
	int depth = GetMaxDepth()
	int i = 0
	While(i < depth)
		float time = SexLabRegistry.GetFixedLength(PROXY_ID, stage)
		If (time)
			seconds += time
		ElseIf (i > StageTimers.Length - 1)
			seconds += StageTimers[StageTimers.Length - 1]
		Else
			seconds += StageTimers[i]
		EndIf
		i += 1
	EndWhile
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
; --- SoundFX                                         --- ;
; ------------------------------------------------------- ;

;/ NOTE:
	Sound FX are runtime evaluated and no longer statically available
	Leaving this here for reference until the new system is done
/;

; Form[] StageSoundFX
Sound property SoundFX hidden
	Sound function get()
		; if StageSoundFX[0]
		; 	return StageSoundFX[0] as Sound
		; endIf
		return none
	endFunction
	function set(Sound var)
		; if var
		; 	StageSoundFX[0] = var as Form
		; else
		; 	StageSoundFX[0] = none
		; endIf
	endFunction
endProperty

Sound function GetSoundFX(int Stage)
	; if Stage < 1 || Stage > StageSoundFX.Length
	; 	return StageSoundFX[0] as Sound
	; endIf
	; return StageSoundFX[(Stage - 1)] as Sound
	return none
endFunction

function SetStageSoundFX(int stage, Sound StageFX)
	; ; Validate stage
	; if stage > Stages || stage < 1
	; 	Log("Unknown animation stage, '"+stage+"' given.", "SetStageSound")
	; 	return
	; endIf
	; ; Initialize fx array if needed
	; if StageSoundFX.Length != Stages
	; 	StageSoundFX = PapyrusUtil.ResizeFormArray(StageSoundFX, Stages, SoundFX)
	; endIf
	; ; Set Stage fx
	; StageSoundFX[(stage - 1)] = StageFX
endFunction

; ------------------------------------------------------- ;
; --- Offsets                                         --- ;
; ------------------------------------------------------- ;

float[] function GetPositionOffsets(string AdjustKey, int Position, int Stage)
	float[] Output = new float[4]
	return PositionOffsets(Output, AdjustKey, Position, Stage)
endFunction

float[] function GetRawOffsets(int Position, int Stage)
	float[] Output = new float[4]
	return RawOffsets(Output, Position, Stage)
endFunction

; COMEBACK: Rewire
float[] function _GetStageAdjustments(string Registrar, string AdjustKey, int Stage) global native
float[] function GetPositionAdjustments(string AdjustKey, int Position, int Stage)
	return _GetStageAdjustments(Registry, InitAdjustments(AdjustKey, Position), Stage)
endFunction

; COMEBACK: Rewire or discard
float[] function _GetAllAdjustments(string Registrar, string AdjustKey) global native
float[] function GetAllAdjustments(string AdjustKey)
	return _GetAllAdjustments(Registry, Adjustkey)
endFunction

; COMEBACK: Rewire or discard
bool function _HasAdjustments(string Registrar, string AdjustKey, int Stage) global native
bool function HasAdjustments(string AdjustKey, int Stage)
	return _HasAdjustments(Registry, AdjustKey, Stage)
endFunction

; COMEBACK: BedType ID? Applicable or nah?
function _PositionOffsets(string Registrar, string AdjustKey, string LastKey, int Stage, float[] RawOffsets) global native
float[] function PositionOffsets(float[] Output, string AdjustKey, int Position, int Stage, int BedTypeID = 0)
	String stage_ = GetStageBounded(Stage)
	float[] offsets = SexLabRegistry.GetOffset(PROXY_ID, stage_, Position)
	If (Output.Length == 4)
		Output[0] = offsets[0]
		Output[1] = offsets[1]
		Output[2] = offsets[2]
		Output[3] = offsets[3]
	EndIf
	return offsets
endFunction

float[] function RawOffsets(float[] Output, int Position, int Stage)
	String stage_ = GetStageBounded(Stage)
	float[] offsets = SexLabRegistry.GetOffsetRaw(PROXY_ID, stage_, Position)
	If (Output.Length == 4)
		Output[0] = offsets[0]
		Output[1] = offsets[1]
		Output[2] = offsets[2]
		Output[3] = offsets[3]
	EndIf
	return offsets
endFunction

function SetBedOffsets(float forward, float sideward, float upward, float rotate)
endFunction

float[] function GetBedOffsets()
	return Utility.CreateFloatArray(4)
endFunction

; ------------------------------------------------------- ;
; --- Adjustments                                     --- ;
; ------------------------------------------------------- ;

; COMEBACK: Rewire or discard
function _SetAdjustment(string Registrar, string AdjustKey, int Stage, int Slot, float Adjustment) global native
function SetAdjustment(string AdjustKey, int Position, int Stage, int Slot, float Adjustment)
	; if Position < Actors
	; 	LastKeys[Position] = InitAdjustments(AdjustKey, Position)
	; 	sslBaseAnimation._SetAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot, Adjustment)
	; endIf
endFunction

; COMEBACK: Rewire or discard
float function _GetAdjustment(string Registrar, string AdjustKey, int Stage, int nth) global native
float function GetAdjustment(string AdjustKey, int Position, int Stage, int Slot)
	return sslBaseAnimation._GetAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot)
endFunction

; COMEBACK: Rewire or discard
float function _UpdateAdjustment(string Registrar, string AdjustKey, int Stage, int nth, float by) global native
function UpdateAdjustment(string AdjustKey, int Position, int Stage, int Slot, float AdjustBy)
	; if Position < Actors
	; 	LastKeys[Position] = InitAdjustments(AdjustKey, Position)
	; 	sslBaseAnimation._UpdateAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot, AdjustBy)
	; endIf
endFunction
function UpdateAdjustmentAll(string AdjustKey, int Position, int Slot, float AdjustBy)
	; if Position < Actors
	; 	LastKeys[Position] = InitAdjustments(AdjustKey, Position)
	; 	int Stage = Stages
	; 	while Stage
	; 		sslBaseAnimation._UpdateAdjustment(Registry, AdjustKey+"."+Position, Stage, Slot, AdjustBy)
	; 		Stage -= 1
	; 	endWhile
	; endIf
endFunction

; COMEBACK: Rewire or discard
function AdjustForward(string AdjustKey, int Position, int Stage, float AdjustBy, bool AdjustStage = false)
	; if AdjustStage
	; 	UpdateAdjustment(AdjustKey, Position, Stage, 0, AdjustBy)
	; else
	; 	UpdateAdjustmentAll(AdjustKey, Position, 0, AdjustBy)
	; endIf
endFunction

; COMEBACK: Rewire or discard
function AdjustSideways(string AdjustKey, int Position, int Stage, float AdjustBy, bool AdjustStage = false)
	if AdjustStage
		UpdateAdjustment(AdjustKey, Position, Stage, 1, AdjustBy)
	else
		UpdateAdjustmentAll(AdjustKey, Position, 1, AdjustBy)
	endIf
endFunction

; COMEBACK: Rewire or discard
function AdjustUpward(string AdjustKey, int Position, int Stage, float AdjustBy, bool AdjustStage = false)
	if AdjustStage
		UpdateAdjustment(AdjustKey, Position, Stage, 2, AdjustBy)
	else
		UpdateAdjustmentAll(AdjustKey, Position, 2, AdjustBy)
	endIf
endFunction

function AdjustSchlong(string AdjustKey, int Position, int Stage, int AdjustBy)
endFunction

function _ClearAdjustments(string Registrar, string AdjustKey) global native
function RestoreOffsets(string AdjustKey)
endFunction

bool function _CopyAdjustments(string Registrar, string AdjustKey, float[] Array) global native
function CopyAdjustmentsFrom(string AdjustKey, string CopyKey, int Position)
endFunction

string function GetLastKey(int Position)
	return ""
endFunction

string function InitAdjustments(string AdjustKey, int Position)
	return ""
endFunction

float[] function GetEmptyAdjustments(int Position)
	return Utility.CreateFloatArray(GetMaxDepth() * 4)
endFunction

string[] function _GetAdjustKeys(string Registrar) global native
string[] function GetAdjustKeys()
	return Utility.CreateStringArray(0)
endFunction

; ------------------------------------------------------- ;
; --- Flags                                           --- ;
; ------------------------------------------------------- ;

int[] function GetPositionFlags(string AdjustKey, int Position, int Stage)
	int[] Output = new int[5]
	return PositionFlags(Output, AdjustKey, Position, Stage)
endFunction

int[] function PositionFlags(int[] Output, string AdjustKey, int Position, int Stage)
	if Output.Length < 5
		Output = new int[5]
	endIf
	Output[0] = 0
	Output[1] = 0
	Output[2] = 0
	Output[3] = 0
	Output[4] = GetGender(Position)
	return Output
endFunction

; ------------------------------------------------------- ;
; --- Animation Info                                  --- ;
; ------------------------------------------------------- ;

; Runtime evaluated
bool function IsSilent(int Position, int Stage)
	return false
endFunction

; Runtime evaluated
bool function UseOpenMouth(int Position, int Stage)
	return false
endFunction

; Redundant due to multivariable genders
bool function UseStrapon(int Position, int Stage)
	return false
endFunction

; Runtime evaluated
int function _GetSchlong(string Registrar, string AdjustKey, string LastKey, int Stage) global native
int function GetSchlong(string AdjustKey, int Position, int Stage)
	return 0
endFunction

; Runtime evaluated
int function GetCumID(int Position, int Stage = 1)
	return 0
endFunction

; Runtime evaluated
int function GetCumSource(int Position, int Stage = 1)
	return 0
endFunction

; Runtime evaluated
bool function IsCumSource(int SourcePosition, int TargetPosition, int Stage = 1)
	return false
endFunction

function SetStageCumID(int Position, int Stage, int CumID, int CumSource = -1)
endFunction

; Runtime evaluated
int function GetCum(int Position)
	return 0
endFunction

int function ActorCount()
	return SexLabRegistry.GetActorCount(PROXY_ID, false)
endFunction

int function StageCount()
	return GetMaxDepth()
endFunction

int[] Function GetGendersA()
	int[] ret = new int[4]
	int count = ActorCount()
	int i = 0
	While(i < count)
		int g = GetGender(i)
		ret[g] = ret[g] + 1
		i += 1
	EndWhile
	return ret
EndFunction

int function GetGender(int Position)
	If(CreaturePosition(Position))
		If(SexLabRegistry.GetIsFemaleCreaturePositon(PROXY_ID, Position))
			return 3
		Else
			return 2
		EndIf
	ElseIf(FemalePosition(Position) || SexLabRegistry.GetIsFutaPositon(PROXY_ID, Position))
		return 1
	EndIf
	return 0
endFunction

bool function MalePosition(int Position)
	return SexLabRegistry.GetIsMalePosition(PROXY_ID, Position)
endFunction

bool function FemalePosition(int Position)
	return SexLabRegistry.GetIsFemalePosition(PROXY_ID, Position)
endFunction

bool function CreaturePosition(int Position)
	return SexLabRegistry.GetRaceIDPosition(PROXY_ID, Position) > 0
endFunction

bool function MatchGender(int Gender, int Position)
	return Gender == GetGender(Position) || (!GenderedCreatures && Gender > 1)
endFunction

int function FemaleCount()
	return Genders[1]
endFunction

int function MaleCount()
	return Genders[0]
endFunction

bool function IsSexual()
	return IsSexual
endFunction

function SetContent(int contentType)
	; No longer used
endFunction

; ------------------------------------------------------- ;
; --- Creature Use                                    --- ;
; ------------------------------------------------------- ;

; All Actors have a raceid 2.0+
bool function HasActorRace(Actor ActorRef)
	return true
endFunction

; All races have a raceid 2.0+
bool function HasRace(Race RaceRef)
	return true
endFunction

function AddRace(Race RaceRef)
endFunction

; legacy functions dont support human racekey so return > 0 instead of > -1
bool function HasRaceID(string RaceID)
	return SexLabRegistry.MapRaceKeyToID(RaceID) > 0
endFunction

; Are any of the racekeys part of this animation
bool function HasValidRaceKey(string[] RaceKeys)
	return CountValidRaceKey(RaceKeys) > 0
endFunction

; How many of the given racekeys are part of this animation
int function CountValidRaceKey(string[] RaceKeys)
	String[] racekeys_ = GetRaceTypes()
	int ret = 0
	int i = 0
	While(i < RaceKeys.Length)
		If (RaceKeys[i] && racekeys_.Find(RaceKeys[i]))
			ret += 1
		EndIf
		i += 1
	EndWhile
	return ret
endFunction

; Is the given position this racekey
bool function IsPositionRace(int Position, string RaceKey)
	return SexLabRegistry.GetRaceKeyPositionA(PROXY_ID, Position).Find(RaceKey) > -1
endFunction

; Does the given position have any of the given racekeys
bool function HasPostionRace(int Position, string[] RaceKeys)
	int i = 0
	While(i < RaceKeys.Length)
		If(IsPositionRace(Position, RaceKeys[i]))
			return true
		EndIf
		i += 1
	EndWhile
	return false
endFunction

; All of this scenes racetypes
string[] function GetRaceTypes()
	int count = ActorCount()
	string[] ret = Utility.CreateStringArray(count)
	int i = 0
	While(i < count)
		String racekey = SexLabRegistry.GetRaceKeyPosition(PROXY_ID, i)
		If (racekey == "humans")
			ret[i] = ""
		Else
			ret[i] = racekey
		EndIf
		i += 1
	EndWhile
	return ret
endFunction

function AddRaceID(string RaceID)
endFunction

function SetRaceKey(string RaceKey)
endFunction

function SetPositionRaceKey(int Position, string RaceKey)
endFunction

function SetRaceIDs(string[] RaceList)
endFunction

; All compatible racekeys of this animations creature
; Legacy of legacy, Intended for 1-creature-anims only
string[] function GetRaceIDs()
	String[] racekeys = GetRaceTypes()
	int i = 0
	While(i < racekeys.Length)
		If (racekeys[i] != "")
			int id = SexLabRegistry.MapRaceKeyToID(racekeys[i])
			return SexLabRegistry.MapRaceIDToRaceKeyA(id)
		EndIf
		i += 1
	EndWhile
	return Utility.CreateStringArray(0)
endFunction

; ------------------------------------------------------- ;
; --- Animation Setup                                 --- ;
; ------------------------------------------------------- ;

int function AddPosition(int Gender = 0, int AddCum = -1)
	return -1
endFunction

int function AddCreaturePosition(string RaceKey, int Gender = 2, int AddCum = -1)
	return -1
endFunction

function AddPositionStage(int Position, string AnimationEvent, float forward = 0.0, float side = 0.0, float up = 0.0, float rotate = 0.0, bool silent = false, bool openmouth = false, bool strapon = true, int sos = 0)
endFunction

function Save(int id = -1)
endFunction

; 2 creatures of different race participating?
bool function IsInterspecies()
	String[] racekeys = GetRaceTypes()
	String somerace
	int i = 0
	While(i < racekeys.Length)
		If (racekeys[i] != "")
			If (somerace && somerace != racekeys[i])
				return true
			EndIf
			somerace = racekeys[i]
		EndIf
		i += 1
	EndWhile
	return false
endFunction

float function CalcCenterAdjuster(int Stage)
	return 0.0
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

string function GetGenderTag(bool Reverse = false)
	if Reverse
		return GenderTag(Creatures, "C")+GenderTag(Males, "M")+GenderTag(Females, "F")
	endIf
	return GenderTag(Females, "F")+GenderTag(Males, "M")+GenderTag(Creatures, "C")
endFunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

function Initialize()
	parent.Initialize()
endFunction

; ------------------------------------------------------- ;
; --- Properties                                      --- ;
; ------------------------------------------------------- ;

; Creature Use
string property RaceType 
	String Function Get()
		return GetRaceIDs()[0]
	EndFunction
	Function Set(String aSet)
	EndFunction
EndProperty
Form[] property CreatureRaces hidden
	; RaceKeys are no longer bound to some EditorID; hence this function no longer applies
	form[] function get()
		return Utility.CreateFormArray(0)
	endFunction
endProperty

; Information
bool property IsSexual hidden
	bool function get()
		return HasTag("Sex") || HasTag("Vaginal") || HasTag("Anal") || HasTag("Oral")
	endFunction
endProperty
bool property IsCreature hidden
	bool function get()
		return Genders[2] > 0 || Genders[3] > 0
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

; Animation handling tags
bool property IsBedOnly hidden
	bool function get()
		; COMEBACK: Rather than checking for a tag here, check if the furniture state is set to bed
		return HasTag("BedOnly")
	endFunction
endProperty

int property StageCount hidden
	int function get()
		return StageCount()
	endFunction
endProperty
int property PositionCount hidden
	int function get()
		return ActorCount()
	endFunction
endProperty

; Position Genders
int[] property Genders
	int[] Function Get()
		return GetGendersA()
	EndFunction
	Function Set(int[] aSet)
	EndFunction
EndProperty
int property Males hidden
	int function get()
		return Genders[0]
	endFunction
endProperty
int property Females hidden
	int function get()
		return Genders[1]
	endFunction
endProperty
int property Creatures hidden
	int function get()
		return Genders[2] + Genders[3]
	endFunction
endProperty
int property MaleCreatures hidden
	int function get()
		return Genders[2]
	endFunction
endProperty
int property FemaleCreatures hidden
	int function get()
		return Genders[3]
	endFunction
endProperty

; COMEBACK: Skipped that on first read
bool function CheckByTags(int ActorCount, string[] Search, string[] Suppress, bool RequireAll)
	return Enabled && ActorCount == PositionCount && CheckTags(Search, RequireAll) && (Suppress.Length < 1 || !HasOneTag(Suppress))
endFunction

int property kSilent    = 0 autoreadonly hidden
int property kOpenMouth = 1 autoreadonly hidden
int property kStrapon   = 2 autoreadonly hidden
int property kSchlong   = 3 autoreadonly hidden
int property kCumID     = 4 autoreadonly hidden
int property kCumSrc    = 5 autoreadonly hidden
int property kFlagEnd hidden
	int function get()
		return 0	; 6
	endFunction
endProperty

int[] function FlagsArray(int Position)
	int[] ret = new int[6]
	return ret
endFunction

function FlagsSave(int Position, int[] Flags)
endFunction

int property kForward  = 0 autoreadonly hidden
int property kSideways = 1 autoreadonly hidden
int property kUpward   = 2 autoreadonly hidden
int property kRotate   = 3 autoreadonly hidden
int property kOffsetEnd hidden
	int function get()
		return 0	; 4
	endFunction
endProperty

float[] function OffsetsArray(int Position)
	float[] ret = new float[4]
	return ret
endFunction

function OffsetsSave(int Position, float[] Offsets)
endFunction

function InitArrays(int Position)
endFunction

;Animation Offsets
function ExportOffsets(string Type = "BedOffset")
endFunction

function ImportOffsets(string Type = "BedOffset")
endFunction

function ImportOffsetsDefault(string Type = "BedOffset")
endFunction

function ExportJSON()
endFunction
