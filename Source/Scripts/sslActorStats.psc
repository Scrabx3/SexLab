scriptname sslActorStats extends sslSystemLibrary
{
	Internal script to document statistics
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

import StorageUtil
import PapyrusUtil
import Utility
import Math

; NOTE: Leaving these as functions here as i might want to eventually 
; remove them, so to not force a clean save only to clean these vars up
String[] Function	StatTitles()
	String[] ret = new String[7]
	ret[0] = "$SSL_Unskilled"
	ret[1] = "$SSL_Novice"
	ret[2] = "$SSL_Apprentice"
	ret[3] = "$SSL_Journeyman"
	ret[4] = "$SSL_Expert"
	ret[5] = "$SSL_Master"
	ret[6] = "$SSL_GrandMaster"
	return ret
EndFunction

String[] Function	PureTitlesMale()
	String[] ret = new String[7]
	ret[0] = "$SSL_Neutral"
	ret[1] = "$SSL_Unsullied"
	ret[2] = "$SSL_CleanCut"
	ret[3] = "$SSL_Virtuous"
	ret[4] = "$SSL_EverFaithful"
	ret[5] = "$SSL_Lordly"
	ret[6] = "$SSL_Saintly"
	return ret
EndFunction

String[] Function	LewdTitlesMale()
	String[] ret = new String[7]
	ret[0] = "$SSL_Neutral"
	ret[1] = "$SSL_Experimenting"
	ret[2] = "$SSL_UnusuallyHorny"
	ret[3] = "$SSL_Promiscuous"
	ret[4] = "$SSL_SexualDeviant"
	ret[5] = "$SSL_Depraved"
	ret[6] = "$SSL_Hypersexual"
	return ret
EndFunction

String[] Function	PureTitlesFemale()
	String[] ret = new String[7]
	ret[0] = "$SSL_Neutral"
	ret[1] = "$SSL_Unsullied"
	ret[2] = "$SSL_PrimProper"
	ret[3] = "$SSL_Virtuous"
	ret[4] = "$SSL_EverFaithful"
	ret[5] = "$SSL_Ladylike"
	ret[6] = "$SSL_Saintly"
	return ret
EndFunction

String[] Function	LewdTitlesFemale()
	String[] ret = new String[7]
	ret[0] = "$SSL_Neutral"
	ret[1] = "$SSL_Experimenting"
	ret[2] = "$SSL_UnusuallyHorny"
	ret[3] = "$SSL_Promiscuous"
	ret[4] = "$SSL_SexualDeviant"
	ret[5] = "$SSL_Debaucherous"
	ret[6] = "$SSL_Nymphomaniac"
	return ret
EndFunction

String[] Function	SkillNames()
	String[] ret = new String[21]
	ret[0] = "Foreplay"
	ret[1] = "Vaginal"
	ret[2] = "Anal"
	ret[3] = "Oral"
	ret[4] = "Pure"
	ret[5] = "Lewd"
	ret[6] = "Males"
	ret[7] = "Females"
	ret[8] = "Creatures"
	ret[9] = "Masturbation"
	ret[10] = "Aggressor"
	ret[11] = "Victim"
	ret[12] = "SexCount"
	ret[13] = "PlayerSex"
	ret[14] = "Sexuality"
	ret[15] = "TimeSpent"
	ret[16] = "LastSex.RealTime"
	ret[17] = "LastSex.GameTime"
	ret[18] = "VaginalCount"
	ret[19] = "AnalCount"
	ret[20] = "OralCount"
	return ret
EndFunction

	
; ------------------------------------------------------- ;
; --- Manipulate Custom Stats                         --- ;
; ------------------------------------------------------- ;

int function FindStat(string Stat)
	return StringListFind(self, "Custom", Stat)
endFunction

int function RegisterStat(string Stat, string Value, string Prepend = "", string Append = "")
	if FindStat(Stat) == -1
		StringListAdd(self, "Custom", Stat, false)
		SetStringValue(self, "Custom.Default."+Stat, Value)
		SetStringValue(self, "Custom.Prepend."+Stat, Prepend)
		SetStringValue(self, "Custom.Append."+Stat, Append)
		SetStat(PlayerRef, Stat, Value)
	endIf
	return FindStat(Stat)
endFunction

int function GetNumStats()
	return StringListCount(self, "Custom")
endFunction

string function GetNthStat(int i)
	return StringListGet(self, "Custom", i)
endFunction

function Alter(string Name, string NewName = "", string Value = "", string Prepend = "", string Append = "")
	int i = FindStat(Name)
	if i != -1
		if NewName != ""
			StringListSet(self, "Custom", i, NewName)
			SetStringValue(self, "Custom.Default."+NewName, GetStringValue(self, "Custom.Default."+Name))
			SetStringValue(self, "Custom.Prepend."+NewName, GetStringValue(self, "Custom.Prepend."+Name))
			SetStringValue(self, "Custom.Append."+NewName, GetStringValue(self, "Custom.Append."+Name))
			UnsetStringValue(self, "Custom.Default."+Name)
			UnsetStringValue(self, "Custom.Prepend."+Name)
			UnsetStringValue(self, "Custom.Append."+Name)
			Name = NewName
		endIf
		if Value != ""
			SetStringValue(self, "Custom.Default."+Name, Value)
		endIf
		if Prepend != ""
			SetStringValue(self, "Custom.Prepend."+Name, Prepend)
		endIf
		if Append != ""
			SetStringValue(self, "Custom.Append."+Name, Append)
		endIf
	endIf
endFunction

bool function ClearStat(Actor ActorRef, string Stat)
	if HasStat(ActorRef, Stat)
		UnsetStringValue(ActorRef, "sslActorStats.Custom."+Stat)
		return true
	endIf
	return false
endFunction

function SetStat(Actor ActorRef, string Stat, string Value)
	if FindStat(Stat) != -1
		SetStringValue(ActorRef, "sslActorStats.Custom."+Stat, Value)
	endIf
endFunction

int function AdjustBy(Actor ActorRef, string Stat, int Adjust)
	if FindStat(Stat) == -1
		return 0
	endIf
	int Value = GetStatInt(ActorRef, Stat)
	Value += Adjust
	SetStat(ActorRef, Stat, (Value as string))
	return Value
endFunction

bool function HasStat(Actor ActorRef, string Stat)
	return HasStringValue(ActorRef, "sslActorStats.Custom."+Stat)
endFunction

string function GetStat(Actor ActorRef, string Stat)
	if !HasStat(ActorRef, Stat)
		return GetStatDefault(Stat)
	endIf
	return GetStringValue(ActorRef, "sslActorStats.Custom."+Stat)
endFunction

string function GetStatString(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat)
endFunction

float function GetStatFloat(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat) as float
endFunction

int function GetStatInt(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat) as int
endFunction

int function GetStatLevel(Actor ActorRef, string Stat, float Curve = 0.85)
	return CalcLevel(GetStatInt(ActorRef, Stat), Curve)
endFunction

string function GetStatTitle(Actor ActorRef, string Stat, float Curve = 0.85)
	return StatTitles()[ClampInt(CalcLevel(GetStatFloat(ActorRef, Stat), Curve), 0, 6)]
endFunction

string function GetStatDefault(string Stat)
	return GetStringValue(self, "Custom.Default."+Stat, "0")
endFunction

string function GetStatPrepend(string Stat)
	return GetStringValue(self, "Custom.Prepend."+Stat, "")
endFunction

string function GetStatAppend(string Stat)
	return GetStringValue(self, "Custom.Append."+Stat, "")
endFunction

string function GetStatFull(Actor ActorRef, string Stat)
	return GetStatPrepend(Stat) + GetStat(ActorRef, Stat) + GetStatAppend(Stat)
endFunction

; ------------------------------------------------------- ;
; --- Calculators & Parsers                           --- ;
; ------------------------------------------------------- ;

int function CalcSexuality(bool IsFemale, int Males, int Females)
	; Calculate "sexuality ratio" 0 = full homosexual, 100 = full heterosexual
	if IsFemale
		return (((Males + 1.0) / ((Males + Females + 1) as float)) * 100.0) as int
	else
		return (((Females + 1.0) / ((Males + Females + 1) as float)) * 100.0) as int
	endIf
endFunction

float function CalcLevelFloat(float Total, float Curve = 0.85)
	if Total > 0.0
		return Math.Sqrt((Math.Abs(Total) / 2.0) * Curve)
	endIf
	return 0.0
endFunction

int function CalcLevel(float Total, float Curve = 0.85)
	return CalcLevelFloat(Total, Curve) as int
endFunction

string function ZeroFill(string num)
	if StringUtil.GetLength(num) == 1
		return "0"+num
	endIf
	return num
endFunction

string function ParseTime(int time)
	if time > 0
		return ZeroFill(((time / 3600) as int))+":"+ZeroFill((((time / 60) % 60) as int))+":"+ZeroFill((time % 60 as int))
	endIf
	return "--:--:--"
endFunction

; ------------------------------------------------------- ;
; --- Sex Skills                                      --- ;
; ------------------------------------------------------- ;

bool function IsSkilled(Actor ActorRef) global native

function _SeedActor(Actor ActorRef, float RealTime, float GameTime) global native
function SeedActor(Actor ActorRef)
	if ActorRef && ActorRef != PlayerRef && !IsSkilled(ActorRef)
		if Config.SeedNPCStats && ActorRef.HasKeywordString("ActorTypeNPC")
			_SeedActor(ActorRef, SexLabUtil.GetCurrentGameRealTimeEx(), Utility.GetCurrentGameTime())
			Log(ActorRef.GetLeveledActorBase().GetName()+" Seeded Stats: "+GetSkills(ActorRef))
		else
			EmptyStats(ActorRef)
			Log(ActorRef.GetLeveledActorBase().GetName()+" Init Empty Stats")
		endIf
		sslSystemConfig.StoreActor(ActorRef)
	endIf
endFunction

float function _GetSkill(Actor ActorRef, int Stat) global native
int function GetSkill(Actor ActorRef, string Skill)
	SeedActor(ActorRef)
	return _GetSkill(ActorRef, SkillNames().Find(Skill)) as int
endFunction
float function GetSkillFloat(Actor ActorRef, string Skill)
	SeedActor(ActorRef)
	return _GetSkill(ActorRef, SkillNames().Find(Skill))
endFunction

function _SetSkill(Actor ActorRef, int Stat, float Value) global native
function SetSkill(Actor ActorRef, string Skill, int Amount)
	SeedActor(ActorRef)
	_SetSkill(ActorRef, SkillNames().Find(Skill), Amount as float)
endFunction
function SetSkillFloat(Actor ActorRef, string Skill, float Amount)
	SeedActor(ActorRef)
	_SetSkill(ActorRef, SkillNames().Find(Skill), Amount)
endFunction

float function _AdjustSkill(Actor ActorRef, int Stat, float By) global native
function AdjustSkill(Actor ActorRef, string Skill, int Amount)
	SeedActor(ActorRef)
	_AdjustSkill(ActorRef, SkillNames().Find(Skill), Amount as float)
endfunction
function AdjustSkillFloat(Actor ActorRef, string Skill, float Amount)
	SeedActor(ActorRef)
	_AdjustSkill(ActorRef, SkillNames().Find(Skill), Amount)
endFunction

int function GetSkillLevel(Actor ActorRef, string Skill, float Curve = 0.85)
	return CalcLevel(GetSkill(ActorRef, Skill), Curve)
endFunction

string function GetSkillTitle(Actor ActorRef, string Skill, float Curve = 0.85)
	return StatTitles()[ClampInt(GetSkillLevel(ActorRef, Skill, Curve), 0, 6)]
endFunction

string function GetTitle(int Level)
	return StatTitles()[ClampInt(Level, 0, 6)]
endFunction

float[] function GetSkills(Actor ActorRef) global native
;/ float[] function GetSkills(Actor ActorRef) global
	float[] Output = new float[18]
	_GetSkills(ActorRef, Output)
	return Output
endFunction /;

float[] function GetSkillLevels(Actor ActorRef)
	float[] Output = new float[6]
	float[] Skills = GetSkills(ActorRef)
	if Skills && Skills.Length >= 6
		Output[0] = CalcLevelFloat(Skills[0], 0.85)
		Output[1] = CalcLevelFloat(Skills[1], 0.85)
		Output[2] = CalcLevelFloat(Skills[2], 0.85)
		Output[3] = CalcLevelFloat(Skills[3], 0.85)
		Output[4] = CalcLevelFloat(Skills[4], 0.30)
		Output[5] = CalcLevelFloat(Skills[5], 0.30)
	endIf
	return Output
endFunction

function AddSkillXP(Actor ActorRef, float Foreplay = 0.0, float Vaginal = 0.0, float Anal = 0.0, float Oral = 0.0)
	_AdjustSkill(ActorRef, kForeplay, Foreplay)
	_AdjustSkill(ActorRef, kVaginal, Vaginal)
	_AdjustSkill(ActorRef, kAnal, Anal)
	_AdjustSkill(ActorRef, kOral, Oral)
endFunction

; ------------------------------------------------------- ;
; --- Purity/Impurty Stat                             --- ;
; ------------------------------------------------------- ;

int function GetPure(Actor ActorRef)
	return _GetSkill(ActorRef, kPure) as int
endFunction

int function GetPureLevel(Actor ActorRef)
	return CalcLevel(GetPure(ActorRef), 0.3)
endFunction

string function GetPureTitle(Actor ActorRef)
	if ActorRef.GetLeveledActorBase().GetSex() == 1
		return PureTitlesFemale()[ClampInt(GetPureLevel(ActorRef), 0, 6)]
	else
		return PureTitlesMale()[ClampInt(GetPureLevel(ActorRef), 0, 6)]
	endIf
endFunction

int function GetLewd(Actor ActorRef)
	return _GetSkill(ActorRef, kLewd) as int
endFunction

int function GetLewdLevel(Actor ActorRef)
	return CalcLevel(GetLewd(ActorRef), 0.3)
endFunction

string function GetLewdTitle(Actor ActorRef)
	if ActorRef.GetLeveledActorBase().GetSex() == 1
		return LewdTitlesFemale()[ClampInt(GetLewdLevel(ActorRef), 0, 6)]
	else
		return LewdTitlesMale()[ClampInt(GetLewdLevel(ActorRef), 0, 6)]
	endIf
endFunction

bool function IsPure(Actor ActorRef)
	return GetPurity(ActorRef) >= 0.0;GetPure(ActorRef) >= GetLewd(ActorRef)
endFunction

bool function IsLewd(Actor ActorRef)
	return GetPurity(ActorRef) < 0.0 ;GetPure(ActorRef) < GetLewd(ActorRef)
endFunction

float function GetPurity(Actor ActorRef)
	return ((GetPure(ActorRef) - GetLewd(ActorRef)) as float) * 1.5
endFunction

float function AdjustPurity(Actor ActorRef, float Adjust)
	string type = "Pure"
	if Adjust < 0.0
		type = "Lewd"
	endIf
	AdjustSkillFloat(ActorRef, type, Math.Abs(Adjust))
	return GetSkillFloat(ActorRef, type)
endFunction

string function GetPurityTitle(Actor ActorRef)
	if IsLewd(ActorRef)
		return GetLewdTitle(ActorRef)
	else
		return GetPureTitle(ActorRef)
	endIf
endFunction

int function GetPurityLevel(Actor ActorRef)
	return CalcLevel(Math.Abs(GetPurity(ActorRef)), 0.3)
endFunction

function AddPurityXP(Actor ActorRef, float Pure, float Lewd, bool IsAggressive, bool IsVictim, bool WithCreature, int ActorCount, int HadRelation)
	; Aggressive modifier for victim/aggressor
	if IsAggressive && IsVictim
		_AdjustSkill(ActorRef, kVictim, 1)
		Pure -= 1.0
		Lewd += 1.0
	elseIf IsAggressive
		_AdjustSkill(ActorRef, kAggressor, 1)
		Pure -= 2.0
		Lewd += 2.0
	endIf
	; Creature modifier
	if WithCreature
		Pure -= 1.0
		Lewd += 2.0
	endIf
	; Actor count modifier
	if ActorCount == 1
		Lewd += 1.0
	elseIf ActorCount > 2
		Pure -= (ActorCount - 1) * 2.0
		Lewd += (ActorCount - 1) * 2.0
	endIf
	; Relationship modifier
	int HighestRelation = ActorRef.GetHighestRelationshipRank()
	if HighestRelation == 4 && HadRelation == 4
		Pure += 4.0
	elseIf HighestRelation == 4 && !IsVictim
		Pure -= 2.0
		Lewd += 2.0
	endIf
	; Save adjustments
	_AdjustSkill(ActorRef, kPure, Pure)
	_AdjustSkill(ActorRef, kLewd, Lewd)
endFunction

; ------------------------------------------------------- ;
; --- Sex Counters                                    --- ;
; ------------------------------------------------------- ;

function AddSex(Actor ActorRef, float TimeSpent = 0.0, bool WithPlayer = false, bool IsAggressive = false, int Males = 0, int Females = 0, int Creatures = 0)
	_AdjustSkill(ActorRef, kTimeSpent, TimeSpent)
	_SetSkill(ActorRef, kLastGameTime, Utility.GetCurrentGameTime())
	_SetSkill(ActorRef, kLastRealTime, SexLabUtil.GetCurrentGameRealTimeEx())

	int ActorCount = (Males + Females + Creatures)
	if ActorCount > 1
		int Gender = GetGender(ActorRef)
		Males -= (Gender == 0) as int
		Females -= (Gender == 1) as int
		_AdjustSkill(ActorRef, kMales, Males)
		_AdjustSkill(ActorRef, kFemales, Females)
		_AdjustSkill(ActorRef, kCreatures, Creatures)
		_AdjustSkill(ActorRef, kSexCount, 1)
		if ActorRef != PlayerRef
			if !IsAggressive
				AdjustSexuality(ActorRef, Males * 2, Females * 2)
			else
				AdjustSexuality(ActorRef, Males, Females)
			endIf
		endIf
	else
		_AdjustSkill(ActorRef, kMasturbation, 1)
	endIf
	if WithPlayer && ActorRef != PlayerRef
		_AdjustSkill(ActorRef, kPlayerSex, 1)
		FormListAdd(PlayerRef, "SexPartners", ActorRef, false)
	endIf
endFunction

int function SexCount(Actor ActorRef)
	return _GetSkill(ActorRef, kSexCount) as int
endFunction

bool function HadSex(Actor ActorRef)
	return _GetSkill(ActorRef, kSexCount) >= 1.0
endFunction

int function PlayerSexCount(Actor ActorRef)
	return _GetSkill(ActorRef, kPlayerSex) as int
endFunction

bool function HadPlayerSex(Actor ActorRef)
	return _GetSkill(ActorRef, kPlayerSex) >= 1.0
endFunction

Actor function LastSexPartner(Actor ActorRef)
	return LastActorInList(ActorRef, "SexPartners")
endFunction
bool function HasHadSexTogether(Actor ActorRef1, Actor ActorRef2)
	return ActorRef1 && ActorRef2 && (FormListHas(ActorRef1, "SexPartners", ActorRef2) || FormListHas(ActorRef2, "SexPartners", ActorRef1))
endfunction

Actor function LastAggressor(Actor ActorRef)
	return LastActorInList(ActorRef, "WasVictimOf")
endFunction
bool function WasVictimOf(Actor VictimRef, Actor AggressorRef)
	return VictimRef && AggressorRef && (FormListHas(VictimRef, "WasVictimOf", AggressorRef) || FormListHas(AggressorRef, "WasAggressorTo", VictimRef))
endFunction

Actor function LastVictim(Actor ActorRef)
	return LastActorInList(ActorRef, "WasAggressorTo")
endFunction
bool function WasAggressorTo(Actor AggressorRef, Actor VictimRef)
	return AggressorRef && VictimRef && (FormListHas(AggressorRef, "WasAggressorTo", VictimRef) || FormListHas(VictimRef, "WasVictimOf", AggressorRef))
endFunction

Form[] function CleanActorList(Actor ActorRef, string List)
	FormListRemove(ActorRef, List, none, true)
	Form[] ActorList = FormListToArray(ActorRef, List)
	if ActorList && ActorList.Length > 0
		bool cleaned = false
		int[] Types  = new int[3]
		Types[0] = 43 ; kNPC
		Types[1] = 44 ; kLeveledCharacter
		Types[2] = 62 ; kCharacter
		int i = ActorList.Length
		while i > 0
			i -= 1
			if !ActorList[i] || Types.Find(ActorList[i].GetType()) == -1
				FormListRemoveAt(ActorRef, List, i)
				cleaned = true
			endIf
		endWhile
		if cleaned
			return FormListToArray(ActorRef, List)
		endIf
	endIf
	return ActorList
endfunction

Actor function LastActorInList(Actor ActorRef, string List)
	if ActorRef
		Form[] ActorList = CleanActorList(ActorRef, List)
		if ActorList
			return ActorList[(ActorList.Length - 1)] as Actor
		endIf
	endIf
	return none
endFunction

Actor function MostUsedPlayerSexPartner()
	Form[] SexPartners = CleanActorList(PlayerRef, "SexPartners")
	Actor PartnerRef
	int PartnerNum
	int i = SexPartners.Length
	while i > 0
		i -= 1
		int Num = PlayerSexCount(SexPartners[i] as Actor)
		if Num > PartnerNum
			PartnerRef = SexPartners[i] as Actor
			PartnerNum = Num
		endIf
	endWhile
	return PartnerRef
endFunction

Actor function MostUsedPlayerSexPartner2()
	Form[] SexPartners = CleanActorList(PlayerRef, "SexPartners")
	Actor PartnerRef
	int PartnerNum
	int i = SexPartners.Length
	while i > 0
		i -= 1
		int Num = PlayerSexCount(SexPartners[i] as Actor)
		if Num > PartnerNum
			PartnerRef = SexPartners[i] as Actor
			PartnerNum = Num
		endIf
	endWhile
	return PartnerRef
endFunction

Actor[] function MostUsedPlayerSexPartners(int MaxActors = 5) ; Based on Stats.MostUsedPlayerSexPartner()
	Form[] SexPartners = Stats.CleanActorList(PlayerRef, "SexPartners")
	Actor[] PartnerRef = PapyrusUtil.ActorArray(MaxActors)
	int[] PartnerNum = PapyrusUtil.IntArray(MaxActors)
	int i = SexPartners.Length
	int r
	int[] Num = new int[2]
	Actor[] Ref = new Actor[2]

	while i > 0
		i -= 1
		r = 0
		Ref[0] = SexPartners[i] as Actor
		Num[0] = Stats.PlayerSexCount(Ref[0])
		while r < MaxActors && Num[0] > 0
			if Num[0] >= PartnerNum[r]
				Ref[1] = PartnerRef[r]
				Num[1] = PartnerNum[r]
				PartnerRef[r] = Ref[0]
				PartnerNum[r] = Num[0]
				Ref[0] = Ref[1]
				Num[0] = Num[1]
			endIf
			r += 1
		endWhile
	endWhile
	return PartnerRef
endFunction

; ------------------------------------------------------- ;
; --- Sexuality Stats                                 --- ;
; ------------------------------------------------------- ;

function AdjustSexuality(Actor ActorRef, int Males, int Females)
	bool IsFemale = GetGender(ActorRef) == 1
	float Ratio = _GetSkill(ActorRef, kSexuality)
	if Ratio == 0.0
		Ratio = 80.0
	endIf
	if IsFemale
		Ratio += (Males - Females)
	else
		Ratio += (Females - Males)
	endIf
	_SetSkill(ActorRef, kSexuality, ClampFloat(Ratio, 1.0, 100.0) as float)
endFunction

int function GetSexuality(Actor ActorRef)
	float Ratio = _GetSkill(ActorRef, kSexuality)
	if Ratio > 0.0
		return Ratio as int
	else
		return 100
	endIf
endFunction

string function GetSexualityTitle(Actor ActorRef)
	float ratio = _GetSkill(ActorRef, kSexuality)
	; Return sexuality title
	if ratio >= 65.0 || ratio == 0.0
		return "$SSL_Heterosexual"
	elseif ratio < 65.0 && ratio > 35.0
		return "$SSL_Bisexual"
	elseif GetGender(ActorRef) == 1
		return "$SSL_Lesbian"
	else
		return "$SSL_Gay"
	endIf
endFunction

bool function IsStraight(Actor ActorRef)
	return _GetSkill(ActorRef, kSexuality) >= 65.0
endFunction

bool function IsBisexual(Actor ActorRef)
	float ratio = _GetSkill(ActorRef, kSexuality)
	return ratio < 65.0 && ratio > 35.0
endFunction

bool function IsGay(Actor ActorRef)
	return _GetSkill(ActorRef, kSexuality) <= 35.0
endFunction

; ------------------------------------------------------- ;
; --- Time Based Stats                                --- ;
; ------------------------------------------------------- ;

; Last sex - Game time1 - float days
float function LastSexGameTime(Actor ActorRef)
	return _GetSkill(ActorRef, kLastGameTime)
endFunction

float function DaysSinceLastSex(Actor ActorRef)
	return Utility.GetCurrentGameTime() - LastSexGameTime(ActorRef)
endFunction

float function HoursSinceLastSex(Actor ActorRef)
	return DaysSinceLastSex(ActorRef) * 24.0
endFunction

float function MinutesSinceLastSex(Actor ActorRef)
	return DaysSinceLastSex(ActorRef) * 1440.0
endFunction

float function SecondsSinceLastSex(Actor ActorRef)
	return DaysSinceLastSex(ActorRef) * 86400.0
endFunction

string function LastSexTimerString(Actor ActorRef)
	return ParseTime(SecondsSinceLastSex(ActorRef) as int)
endFunction

; Last sex - Real Time - float seconds
float function LastSexRealTime(Actor ActorRef)
	return _GetSkill(ActorRef, kLastRealTime)
endFunction

float function SecondsSinceLastSexRealTime(Actor ActorRef)
	float LastSex = LastSexRealTime(ActorRef)
	if LastSex > 0.0
		return SexLabUtil.GetCurrentGameRealTimeEx() - LastSex
	endIf
	return 0.0
endFunction

float function MinutesSinceLastSexRealTime(Actor ActorRef)
	return SecondsSinceLastSexRealTime(ActorRef) / 60.0
endFunction

float function HoursSinceLastSexRealTime(Actor ActorRef)
	return SecondsSinceLastSexRealTime(ActorRef) / 3600.0
endFunction

float function DaysSinceLastSexRealTime(Actor ActorRef)
	return SecondsSinceLastSexRealTime(ActorRef) / 86400.0
endFunction

string function LastSexTimerStringRealTime(Actor ActorRef)
	return ParseTime(SecondsSinceLastSexRealTime(ActorRef) as int)
endFunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;


function RecordThread(Actor ActorRef, int Gender, int HadRelation, float StartedAt, float RealTime, float GameTime, bool WithPlayer, Actor VictimRef, int[] Genders, float[] SkillXP) global native
function AddPartners(Actor ActorRef, Actor[] AllPositions, Actor[] Victims)
	if !ActorRef || !AllPositions || AllPositions.Length < 2 || AllPositions.Find(none) != -1
		return ; No Positions
	endIf
	bool IsVictim    = false
	bool IsAggressor = false
	if Victims && Victims.Length > 0
		IsVictim     = Victims.Find(ActorRef) != -1
		IsAggressor  = Victims.Find(ActorRef) == -1
	endIf
	Actor[] Positions = RemoveActor(AllPositions, ActorRef)
	int PartnerCount  = Positions.Length

	FormListRemove(ActorRef, "SexPartners", none, true)
	FormListRemove(ActorRef, "WasVictimOf", none, true)
	FormListRemove(ActorRef, "WasAggressorTo", none, true)
	sslSystemConfig.StoreActor(ActorRef)
	int i = PartnerCount
	while i
		i -= 1
		FormListRemove(ActorRef, "SexPartners", Positions[i], true)
		FormListAdd(ActorRef, "SexPartners", Positions[i], false)
	endWhile
	if ActorRef != PlayerRef
		TrimList(ActorRef, "SexPartners", 8)
	endIf
	if IsVictim
		i = PartnerCount
		while i
			i -= 1
			if Victims.Find(Positions[i]) == -1
				FormListRemove(ActorRef, "WasVictimOf", Positions[i], true)
				FormListAdd(ActorRef, "WasVictimOf", Positions[i], false)
			endIf
		endWhile
		if ActorRef != PlayerRef
			TrimList(ActorRef, "WasVictimOf", 8)
		endIf
	elseIf IsAggressor
		i = PartnerCount
		while i
			i -= 1
			if Victims.Find(Positions[i]) != -1
				FormListRemove(ActorRef, "WasAggressorTo", Positions[i], true)
				FormListAdd(ActorRef, "WasAggressorTo", Positions[i], false)
			endIf
		endWhile
		if ActorRef != PlayerRef
			TrimList(ActorRef, "WasAggressorTo", 8)
		endIf
	endIf
endFunction
function TrimList(Actor ActorRef, string List, int count)
	count = FormListCount(ActorRef, List) - count
	while count > 0
		count -= 1
		FormListRemoveAt(ActorRef, List, 0)
	endwhile
endFunction


function _ResetStats(Actor ActorRef) global native
function ResetStats(Actor ActorRef)
	; Current primary storage
	_ResetStats(ActorRef)
	ClearCustomStats(ActorRef)
	FormListClear(ActorRef, "SexPartners")
	FormListClear(ActorRef, "WasVictimOf")
	FormListClear(ActorRef, "WasAggressorTo")
endFunction

function EmptyStats(Actor ActorRef)
	if ActorRef
		ResetStats(ActorRef)
		_SetSkill(ActorRef, kSexuality, 65)
	endIf
endFunction

Actor[] function GetAllSkilledActors() global native
function ClearNPCSexSkills()
	Actor[] List = GetAllSkilledActors()
	Log("ClearNPCSexSkills("+List.Length+") "+List)
	int max = List.Length
	int i = List.Length
	while i > 0
		i -= 1
		if List[i] && List[i] != PlayerRef
			Log("ClearNPCSexSkills("+(i + 1)+"/"+max+") "+List[i].GetLeveledActorBase().GetName())
			ResetStats(List[i])
		endIf
	endWhile
	Log("ClearNPCSexSkills - DONE")
endFunction

function ClearCustomStats(Form FormRef)
	int i = StringListCount(self, "Custom")
	while i
		i -= 1
		UnsetStringValue(FormRef, "sslActorStats.Custom."+StringListGet(self, "Custom", i))
	endWhile
endFunction

int function GetGender(Actor ActorRef)
	int ret = ActorLib.GetGender(ActorRef)
	If(ret > 2)
		ret = 2
	EndIf
	return ret
endFunction


; ------------------------------------------------------- ;
; --- Skill Type IDs
; ------------------------------------------------------- ;

int function StatID(string Name)
	return SkillNames().Find(Name)
endFunction
int Property kForeplay = 0 AutoReadOnly Hidden
int Property kVaginal = 1 AutoReadOnly Hidden
int Property kAnal = 2 AutoReadOnly Hidden
int Property kOral = 3 AutoReadOnly Hidden
int Property kPure = 4 AutoReadOnly Hidden
int Property kLewd = 5 AutoReadOnly Hidden
int Property kMales = 6 AutoReadOnly Hidden
int Property kFemales = 7 AutoReadOnly Hidden
int Property kCreatures = 8 AutoReadOnly Hidden
int Property kMasturbation = 9 AutoReadOnly Hidden
int Property kAggressor = 10 AutoReadOnly Hidden
int Property kVictim = 11 AutoReadOnly Hidden
int Property kSexCount = 12 AutoReadOnly Hidden
int Property kPlayerSex = 13 AutoReadOnly Hidden
int Property kSexuality = 14 AutoReadOnly Hidden
int Property kTimeSpent = 15 AutoReadOnly Hidden
int Property kLastRealTime = 16 AutoReadOnly Hidden
int Property kLastGameTime = 17 AutoReadOnly Hidden
int Property kVaginalCount = 18 AutoReadOnly Hidden
int Property kAnalCount = 19 AutoReadOnly Hidden
int Property kOralCount = 20 AutoReadOnly Hidden
int property kStatCount = 21 AutoReadOnly hidden


string function PrintSkills(Actor ActorRef)
	float[] Skills = GetSkills(ActorRef)
	string Output
	Output += " -- "+ActorRef.GetLeveledActorBase().GetName()+" -- \n"
	Output += "\tForeplay: "+Skills[kForeplay] + "\n"
	Output += "\tVaginal: "+Skills[kVaginal] + "\n"
	Output += "\tVaginalCount: "+Skills[kVaginalCount] + "\n"
	Output += "\tAnal: "+Skills[kAnal] + "\n"
	Output += "\tAnalCount: "+Skills[kAnalCount] + "\n"
	Output += "\tOral: "+Skills[kOral] + "\n"
	Output += "\tOralCount: "+Skills[kOralCount] + "\n"
	Output += "\tPure: "+Skills[kPure] + "\n"
	Output += "\tLewd: "+Skills[kLewd] + "\n"
	Output += "\tMales: "+Skills[kMales] + "\n"
	Output += "\tFemales: "+Skills[kFemales] + "\n"
	Output += "\tCreatures: "+Skills[kCreatures] + "\n"
	Output += "\tMasturbation: "+Skills[kMasturbation] + "\n"
	Output += "\tAggressor: "+Skills[kAggressor] + "\n"
	Output += "\tVictim: "+Skills[kVictim] + "\n"
	Output += "\tSexCount: "+Skills[kSexCount] + "\n"
	Output += "\tPlayerSex: "+Skills[kPlayerSex] + "\n"
	Output += "\tSexuality: "+Skills[kSexuality] + "\n"
	Output += "\tTimeSpent: "+Skills[kTimeSpent] + "\n"
	Output += "\tLastRealTime: "+Skills[kLastRealTime] + "\n"
	Output += "\tLastGameTime: "+Skills[kLastGameTime] + "\n"
	Output += " --- "
	return Output
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	;
;																																											;
;									██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗									;
;									██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝									;
;									██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 									;
;									██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  									;
;									███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   									;
;									╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   									;
;																																											;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*	;

; v1.59b NOTICE:
; SexLab native skills storage has changed to use lists for storage
; instead of values. This allows for faster access internally and
; significantly shrinks the amount of data StorageUtil has to store.

; These functions will now reroute to their appropiate new/updated functions if
; they are used to attempt to access the native skills. If accessing if they
; are not used for native skills they will resort to old functionality

bool function HasInt(Actor ActorRef, string Stat)
	return HasIntValue(ActorRef, "sslActorStats."+Stat) || (IsSkilled(ActorRef) && _GetSkill(ActorRef, SkillNames().Find(Stat)) != 0.0)
endFunction
bool function HasFloat(Actor ActorRef, string Stat)
	return HasFloatValue(ActorRef, "sslActorStats."+Stat) || (IsSkilled(ActorRef) && _GetSkill(ActorRef, SkillNames().Find(Stat)) != 0.0)
endFunction
bool function HasStr(Actor ActorRef, string Stat)
	return HasStringValue(ActorRef, "sslActorStats."+Stat)
endFunction

int function GetInt(Actor ActorRef, string Stat)
	if SkillNames().Find(Stat) == -1
		return GetIntValue(ActorRef, "sslActorStats."+Stat)
	endIf
	return GetSkill(ActorRef, Stat)
endFunction
float function GetFloat(Actor ActorRef, string Stat)
	if SkillNames().Find(Stat) == -1
		return GetFloatValue(ActorRef, "sslActorStats."+Stat)
	endIf
	return GetSkillFloat(ActorRef, Stat)
endFunction
string function GetStr(Actor ActorRef, string Stat)
	return GetStringValue(ActorRef, "sslActorStats."+Stat)
endFunction

function SetInt(Actor ActorRef, string Stat, int Value)
	if SkillNames().Find(Stat) != -1
		_SetSkill(ActorRef, SkillNames().Find(Stat), value as int)
	else
		SetIntValue(ActorRef, "sslActorStats."+Stat, Value)
	endIf
endFunction
function SetFloat(Actor ActorRef, string Stat, float Value)
	if SkillNames().Find(Stat) != -1
		_SetSkill(ActorRef, SkillNames().Find(Stat), 0.0)
	else
		SetFloatValue(ActorRef, "sslActorStats."+Stat, Value)
	endIf
endFunction
function SetStr(Actor ActorRef, string Stat, string Value)
	SetStringValue(ActorRef, "sslActorStats."+Stat, Value)
endFunction

function ClearInt(Actor ActorRef, string Stat)
	_SetSkill(ActorRef, SkillNames().Find(Stat), 0.0)
	UnsetIntValue(ActorRef, "sslActorStats."+Stat)
endFunction
function ClearFloat(Actor ActorRef, string Stat)
	_SetSkill(ActorRef, SkillNames().Find(Stat), 0.0)
	UnsetFloatValue(ActorRef, "sslActorStats."+Stat)
endFunction
function ClearStr(Actor ActorRef, string Stat)
	UnsetStringValue(ActorRef, "sslActorStats."+Stat)
endFunction

function AdjustInt(Actor ActorRef, string Stat, int Amount)
	if Amount != 0 && ActorRef && Stat != ""
		if SkillNames().Find(stat) != -1
			AdjustSkill(ActorRef, Stat, Amount)
		else
			AdjustIntValue(ActorRef, "sslActorStats."+Stat, Amount)
		endIf
	endIf
endfunction
function AdjustFloat(Actor ActorRef, string Stat, float Amount)
	if Amount != 0.0 && ActorRef && Stat != ""
		if SkillNames().Find(stat) != -1
			AdjustSkillFloat(ActorRef, Stat, Amount)
		else
			AdjustFloatValue(ActorRef, "sslActorStats."+Stat, Amount)
		endIf
	endIf
endfunction

function ClearLegacyStats(Form FormRef)
endFunction
function UpgradeLegacyStats(Form FormRef, bool IsImportant)
endFunction

bool locked = false
state Testing
	event OnUpdate()
		Tester()
	endEvent
	function Tester()
		while locked
			utility.wait(0.5)
			Log("ActorStats Locked...")
		endWhile
		locked = true

		int i = 500
		while i
			i -= 1
			Debug.Trace("ACTORSTATS Lock Spin: "+i)
			Utility.WaitMenuMode(0.5)
		endWhile

		locked = false
	endFunction
endState
function Tester()
endFunction

int function GetHighestRelationshipRankInList(Actor ActorRef, Actor[] ActorList) global
	int i = ActorList.Length
	if i == 1
		if ActorRef == ActorList[0]
			return 0
		else
			return ActorRef.GetRelationshipRank(ActorList[0])
		endIf
	endIf
	int out = -4 ; lowest possible
	while i > 0
		i -= 1
		if ActorList[i] != ActorRef && out < 4
			int rank = ActorRef.GetRelationshipRank(ActorList[i])
			if rank > out
				out = rank
			endIf
		endIf
	endWhile
	return out
endFunction