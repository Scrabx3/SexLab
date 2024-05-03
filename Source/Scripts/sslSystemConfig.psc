ScriptName sslSystemConfig extends sslSystemLibrary
{
	Internal utility
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

; ------------------------------------------------------- ;
; --- System Resources                                --- ;
; ------------------------------------------------------- ;

bool property DebugMode hidden
  bool function get()
    return InDebugMode
  endFunction
  function set(bool value)
    InDebugMode = value
    if InDebugMode
      Debug.OpenUserLog("SexLabDebug")
      Debug.TraceUser("SexLabDebug", "SexLab Debug/Development Mode Deactivated")
      MiscUtil.PrintConsole("SexLab Debug/Development Mode Activated")        
    else
      if Debug.TraceUser("SexLabDebug", "SexLab Debug/Development Mode Deactivated")
        Debug.CloseUserLog("SexLabDebug")
      endIf
      MiscUtil.PrintConsole("SexLab Debug/Development Mode Deactivated")     
    endIf
    int eid = ModEvent.Create("SexLabDebugMode")
    ModEvent.PushBool(eid, value)
    ModEvent.Send(eid)
  endFunction
endProperty

Spell[] Property MatchMakerSpells Auto
{4 Spells: Solo | Target | OrgySolo | OrgyTarget}
bool Property MatchMaker Hidden
  bool Function Get()
	  return PlayerRef.HasSpell(MatchMakerSpells[0])
  EndFunction
  Function set(bool abValue)
    int i = 0
    While (i < MatchMakerSpells.Length)
      If (abValue)
        PlayerRef.AddSpell(MatchMakerSpells[i], true)
      Else
        PlayerRef.RemoveSpell(MatchMakerSpells[i])
      EndIf
      i += 1
    EndWhile
  EndFunction
EndProperty

Sound[] property HotkeyUp auto
Sound[] property HotkeyDown auto

Message property CleanSystemFinish auto
Message property CheckSKSE auto
Message property CheckSkyrim auto
Message property CheckPapyrusUtil auto
Message property CheckSkyUI auto
Message property TakeThreadControl auto

SoundCategory property AudioSFX auto
SoundCategory property AudioVoice auto

; ------------------------------------------------------- ;
; --- Config Properties                               --- ;
; ------------------------------------------------------- ;

int Function GetAnimationCount() native global
float[] Function GetEnjoymentFactors() native global
int Function GetEnjoymentSettingInt(String asSetting) native global
float Function GetEnjoymentSettingFlt(String asSetting) native global
Form[] Function GetStrippableItems(Actor akActor, bool abWornOnly) native global

bool Function GetSettingBool(String asSetting) native global
int Function GetSettingInt(String asSetting) native global
float Function GetSettingFlt(String asSetting) native global
String Function GetSettingStr(String asSetting) native global
int Function GetSettingIntA(String asSetting, int n) native global
float Function GetSettingFltA(String asSetting, int n) native global

Function SetSettingBool(String asSetting, bool abValue) native global
Function SetSettingInt(String asSetting, int aiValue) native global
Function SetSettingFlt(String asSetting, float aiValue) native global
Function SetSettingStr(String asSetting, String asValue) native global
Function SetSettingIntA(String asSetting, int aiValue, int n) native global
Function SetSettingFltA(String asSetting, float aiValue, int n) native global

String Function ParseMMTagString() global
	String req = sslSystemConfig.GetSettingStr("sRequiredTags")
	String opt = sslSystemConfig.GetSettingStr("sOptionalTags")
	String neg = sslSystemConfig.GetSettingStr("sExcludedTags")
	String[] optA = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(opt, ","))
	String[] negA = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(neg, ","))
	int i = 0
	While (i < optA.Length)
		req += ", ~" + optA[i]
		i += 1
	EndWhile
	int n = 0
	While (n < negA.Length)
		req += ", -" + negA[n]
		n += 1
	EndWhile
	return req
EndFunction

int Property CLIMAXTYPE_SCENE  = 0 AutoReadOnly
int Property CLIMAXTYPE_LEGACY = 1 AutoReadOnly
int Property CLIMAXTYPE_EXTERN = 2 AutoReadOnly

; Booleans
bool property AllowCreatures hidden
  bool Function Get()
    return GetSettingBool("bAllowCreatures")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bAllowCreatures", aSet)
  EndFunction
EndProperty
bool property UseCreatureGender hidden
  bool Function Get()
    return GetSettingBool("bCreatureGender")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bCreatureGender", aSet)
  EndFunction
EndProperty

bool property UseStrapons hidden
  bool Function Get()
    return GetSettingBool("bUseStrapons")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bUseStrapons", aSet)
  EndFunction
EndProperty
bool property RedressVictim hidden
  bool Function Get()
    return GetSettingBool("bRedressVictim")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bRedressVictim", aSet)
  EndFunction
EndProperty
bool property UseLipSync hidden
  bool Function Get()
    return GetSettingBool("bUseLipSync")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bUseLipSync", aSet)
  EndFunction
EndProperty
bool property UseExpressions hidden
  bool Function Get()
    return GetSettingBool("bUseExpressions")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bUseExpressions", aSet)
  EndFunction
EndProperty
bool property UseCum hidden
  bool Function Get()
    return GetSettingBool("bUseCum")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bUseCum", aSet)
  EndFunction
EndProperty
bool property DisablePlayer hidden
  bool Function Get()
    return GetSettingBool("bDisablePlayer")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bDisablePlayer", aSet)
  EndFunction
EndProperty
bool property AutoTFC hidden
  bool Function Get()
    return GetSettingBool("bAutoTFC")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bAutoTFC", aSet)
  EndFunction
EndProperty
bool property AutoAdvance hidden
  bool Function Get()
    return GetSettingBool("bAutoAdvance")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bAutoAdvance", aSet)
  EndFunction
EndProperty
bool property OrgasmEffects hidden
  bool Function Get()
    return GetSettingBool("bOrgasmEffects")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bOrgasmEffects", aSet)
  EndFunction
EndProperty
bool property RestrictSameSex hidden
  bool Function Get()
    return GetSettingBool("bRestrictSameSex")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bRestrictSameSex", aSet)
  EndFunction
EndProperty
bool property ShowInMap hidden
  bool Function Get()
    return GetSettingBool("bShowInMap")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bShowInMap", aSet)
  EndFunction
EndProperty
bool property DisableTeleport hidden
  bool Function Get()
    return GetSettingBool("bDisableTeleport")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bDisableTeleport", aSet)
  EndFunction
EndProperty
bool property DisableScale hidden
  bool Function Get()
    return GetSettingBool("bDisableScale")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bDisableScale", aSet)
  EndFunction
EndProperty
bool property UndressAnimation hidden
  bool Function Get()
    return GetSettingBool("bUndressAnimation")
  EndFunction
  Function Set(bool aSet)
    SetSettingBool("bUndressAnimation", aSet)
  EndFunction
EndProperty
bool property SubmissivePlayer hidden
  bool Function Get()
	return GetSettingBool("bSubmissivePlayer")
  EndFunction
  Function Set(bool aSet)
	SetSettingBool("bSubmissivePlayer", aSet)
  EndFunction
EndProperty
bool property SubmissiveTarget hidden
	bool Function Get()
	  return GetSettingBool("bSubmissiveTarget")
	EndFunction
	Function Set(bool aSet)
	  SetSettingBool("bSubmissiveTarget", aSet)
	EndFunction
  EndProperty

; Integers
int property AskBed hidden
  int Function Get()
    return GetSettingInt("iAskBed")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAskBed", aiSet)
  EndFunction
EndProperty
int property NPCBed hidden
  int Function Get()
    return GetSettingInt("iNPCBed")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iNPCBed", aiSet)
  EndFunction
EndProperty
int property OpenMouthSize hidden
  int Function Get()
    return GetSettingInt("iOpenMouthSize")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iOpenMouthSize", aiSet)
  EndFunction
EndProperty
int property UseFade hidden
  int Function Get()
    return GetSettingInt("iUseFade")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iUseFade", aiSet)
  EndFunction
EndProperty
int property Backwards hidden
  int Function Get()
    return GetSettingInt("iBackwards")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iBackwards", aiSet)
  EndFunction
EndProperty

; Strings

string property RequiredTags hidden
	string Function Get()
		return GetSettingStr("sRequiredTags")
	EndFunction
	Function Set(string asSet)
		SetSettingStr("sRequiredTags", asSet)
	EndFunction
EndProperty
string property ExcludedTags hidden
	string Function Get()
		return GetSettingStr("sExcludedTags")
	EndFunction
	Function Set(string asSet)
		SetSettingStr("sExcludedTags", asSet)
	EndFunction
EndProperty
string property OptionalTags hidden
	string Function Get()
		return GetSettingStr("sOptionalTags")
	EndFunction
	Function Set(string asSet)
		SetSettingStr("sOptionalTags", asSet)
	EndFunction
EndProperty

; Expressions

int property LipsPhoneme hidden
  int Function Get()
    return GetSettingInt("iLipsPhoneme")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iLipsPhoneme", aiSet)
  EndFunction
EndProperty
bool property LipsFixedValue hidden
  bool Function Get()
    return GetSettingBool("bLipsFixedValue")
  EndFunction
  Function Set(bool aiSet)
    SetSettingBool("bLipsFixedValue", aiSet)
  EndFunction
EndProperty
int property LipsMinValue hidden
  int Function Get()
    return GetSettingInt("iLipsSoundTime")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iLipsSoundTime", aiSet)
  EndFunction
EndProperty
int property LipsMaxValue hidden
  int Function Get()
    return GetSettingInt("iLipsMaxValue")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iLipsMaxValue", aiSet)
  EndFunction
EndProperty
int property LipsSoundTime hidden
  int Function Get()
    return GetSettingInt("iLipsSoundTime")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iLipsSoundTime", aiSet)
  EndFunction
EndProperty
float property LipsMoveTime hidden
  float Function Get()
    return GetSettingFlt("fLipsMoveTime")
  EndFunction
  Function Set(float aiSet)
    SetSettingFlt("fLipsMoveTime", aiSet)
  EndFunction
EndProperty

; Scene Control Keys
bool property AdjustTargetStage  Hidden
  bool Function Get()
    return GetSettingBool("bAdjustTargetStage")
  EndFunction
  Function Set(bool abSet)
    SetSettingBool("bAdjustTargetStage", abSet)
  EndFunction
EndProperty
int property AdjustStage hidden
  int Function Get()
    return GetSettingInt("iAdjustStage")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdjustStage", aiSet)
  EndFunction
EndProperty
int property AdvanceAnimation hidden
  int Function Get()
    return GetSettingInt("iAdvanceAnimation")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdvanceAnimation", aiSet)
  EndFunction
EndProperty
int property ChangeAnimation hidden
  int Function Get()
    return GetSettingInt("iChangeAnimation")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iChangeAnimation", aiSet)
  EndFunction
EndProperty
int property ChangePositions hidden
  int Function Get()
    return GetSettingInt("iChangePositions")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iChangePositions", aiSet)
  EndFunction
EndProperty
int property AdjustChange hidden
  int Function Get()
    return GetSettingInt("iAdjustChange")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdjustChange", aiSet)
  EndFunction
EndProperty
int property AdjustForward hidden
  int Function Get()
    return GetSettingInt("iAdjustForward")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdjustForward", aiSet)
  EndFunction
EndProperty
int property AdjustSideways hidden
  int Function Get()
    return GetSettingInt("iAdjustSideways")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdjustSideways", aiSet)
  EndFunction
EndProperty
int property AdjustUpward hidden
  int Function Get()
    return GetSettingInt("iAdjustUpward")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdjustUpward", aiSet)
  EndFunction
EndProperty
int property RealignActors hidden
  int Function Get()
    return GetSettingInt("iRealignActors")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iRealignActors", aiSet)
  EndFunction
EndProperty
int property MoveScene hidden
  int Function Get()
    return GetSettingInt("iMoveScene")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iMoveScene", aiSet)
  EndFunction
EndProperty
int property RestoreOffsets hidden
  int Function Get()
    return GetSettingInt("iRestoreOffsets")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iRestoreOffsets", aiSet)
  EndFunction
EndProperty
int property RotateScene hidden
  int Function Get()
    return GetSettingInt("iRotateScene")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iRotateScene", aiSet)
  EndFunction
EndProperty
int property EndAnimation hidden
  int Function Get()
    return GetSettingInt("iEndAnimation")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iEndAnimation", aiSet)
  EndFunction
EndProperty
int property AdjustSchlong hidden
  int Function Get()
    return GetSettingInt("iAdjustSchlong")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iAdjustSchlong", aiSet)
  EndFunction
EndProperty

; Misc Keys
int property ToggleFreeCamera hidden
  int Function Get()
    return GetSettingInt("iToggleFreeCamera")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iToggleFreeCamera", aiSet)
  EndFunction
EndProperty
int property TargetActor hidden
  int Function Get()
    return GetSettingInt("iTargetActor")
  EndFunction
  Function Set(int aiSet)
    SetSettingInt("iTargetActor", aiSet)
  EndFunction
EndProperty

; Floats
float property CumTimer hidden
  float Function Get()
    return GetSettingFlt("fCumTimer")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fCumTimer", afSet)
  EndFunction
EndProperty
float property ShakeStrength hidden
  float Function Get()
    return GetSettingFlt("fShakeStrength")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fShakeStrength", afSet)
  EndFunction
EndProperty
float property AutoSUCSM hidden
  float Function Get()
    return GetSettingFlt("fAutoSUCSM")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fAutoSUCSM", afSet)
  EndFunction
EndProperty
float property MaleVoiceDelay hidden
  float Function Get()
    return GetSettingFlt("fMaleVoiceDelay")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fMaleVoiceDelay", afSet)
  EndFunction
EndProperty
float property FemaleVoiceDelay hidden
  float Function Get()
    return GetSettingFlt("fFemaleVoiceDelay")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fFemaleVoiceDelay", afSet)
  EndFunction
EndProperty
float property ExpressionDelay hidden
  float Function Get()
    return GetSettingFlt("fExpressionDelay")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fExpressionDelay", afSet)
  EndFunction
EndProperty
float property VoiceVolume hidden
  float Function Get()
    return GetSettingFlt("fVoiceVolume")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fVoiceVolume", afSet)
  EndFunction
EndProperty
float property SFXDelay hidden
  float Function Get()
    return GetSettingFlt("fSFXDelay")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fSFXDelay", afSet)
  EndFunction
EndProperty
float property SFXVolume hidden
  float Function Get()
    return GetSettingFlt("fSFXVolume")
  EndFunction
  Function Set(float afSet)
    SetSettingFlt("fSFXVolume", afSet)
  EndFunction
EndProperty

; Float Array
; fTimers is a 5x3 Matrix / [Stage] x [Type]
float[] property StageTimer hidden
  float[] Function Get()
    return _GetfTimers(0)
  EndFunction
  Function Set(float[] aSet)
    _SetfTimers(0, aSet)
  EndFunction
EndProperty
float[] property StageTimerLeadIn hidden
  float[] Function Get()
    return _GetfTimers(5)
  EndFunction
  Function Set(float[] aSet)
    _SetfTimers(5, aSet)
  EndFunction
EndProperty
float[] property StageTimerAggr hidden
  float[] Function Get()
    return _GetfTimers(10)
  EndFunction
  Function Set(float[] aSet)
    _SetfTimers(10, aSet)
  EndFunction
EndProperty
float[] Function _GetfTimers(int aiIdx0)
    float[] ret = new float[5]
    ret[aiIdx0 + 0] = GetSettingFltA("fTimers", aiIdx0 + 0)
    ret[aiIdx0 + 1] = GetSettingFltA("fTimers", aiIdx0 + 1)
    ret[aiIdx0 + 2] = GetSettingFltA("fTimers", aiIdx0 + 2)
    ret[aiIdx0 + 3] = GetSettingFltA("fTimers", aiIdx0 + 3)
    ret[aiIdx0 + 4] = GetSettingFltA("fTimers", aiIdx0 + 4)
    return ret
EndFunction
Function _SetfTimers(int aiIdx0, float[] afSet)
    SetSettingFltA("fTimers", afSet[0], aiIdx0 + 0)
    SetSettingFltA("fTimers", afSet[1], aiIdx0 + 1)
    SetSettingFltA("fTimers", afSet[2], aiIdx0 + 2)
    SetSettingFltA("fTimers", afSet[3], aiIdx0 + 3)
    SetSettingFltA("fTimers", afSet[4], aiIdx0 + 4)
EndFunction


float[] property OpenMouthMale hidden
  float[] Function Get()
    float[] ret = new float[17]
    int i = 0
    While (i < ret.Length)
      ret[i] = GetSettingFltA("fOpenMouthMale", i)
      i += 1
    EndWhile
    return ret
  EndFunction
  Function Set(float[] aSet)
    If (aSet.Length != 17)
      return
    EndIf
    int i = 0
    While (i < aSet.Length)
      SetSettingFltA("fOpenMouthMale", aSet[i], i)
      i += 1
    EndWhile
  EndFunction
EndProperty
float[] property OpenMouthFemale hidden
  float[] Function Get()
    float[] ret = new float[17]
    int i = 0
    While (i < ret.Length)
      ret[i] = GetSettingFltA("fOpenMouthFemale", i)
      i += 1
    EndWhile
    return ret
  EndFunction
  Function Set(float[] aSet)
    If (aSet.Length != 17)
      return
    EndIf
    int i = 0
    While (i < aSet.Length)
      SetSettingFltA("fOpenMouthFemale", aSet[i], i)
      i += 1
    EndWhile
  EndFunction
EndProperty

; Compatibility checks
bool property HasNiOverride hidden
  bool Function Get()
    return SKSE.GetPluginVersion("SKEE64") >= 7 || NiOverride.GetScriptVersion() >= 7
  EndFUnction
  Function Set(bool aSet)
  EndFunction
EndProperty
bool property HasMFGFix hidden
  bool Function Get()
    return SKSE.GetPluginVersion("mfgfix") > -1
  EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Config Accessors                                --- ;
; ------------------------------------------------------- ;

float function GetVoiceDelay(bool IsFemale = false, int Stage = 1, bool IsSilent = false)
  if IsSilent
    return 3.0 ; Return basic delay for loop
  endIf
  float VoiceDelay = MaleVoiceDelay
  if IsFemale
    VoiceDelay = FemaleVoiceDelay
  endIf
  if Stage > 1
    VoiceDelay -= (Stage * 0.8) + Utility.RandomFloat(-0.2, 0.4)
    if VoiceDelay < 0.8
      return Utility.RandomFloat(0.8, 1.3) ; Can't have delay shorter than animation update loop
    endIf
  endIf
  return VoiceDelay
endFunction

; iStripForms: 0b[Weapon][Female | Submissive][Aggressive]
int[] Function GetStripForms(bool abFemaleOrSubmissive, bool abAggressive) global
  int idx = 2 * abFemaleOrSubmissive as int + 4 * abAggressive as int
  int[] ret = new int[2]
  ret[0] = GetSettingIntA("iStripForms", idx)
  ret[1] = GetSettingIntA("iStripForms", idx + 1)
  return ret
EndFunction

float[] function GetOpenMouthPhonemes(bool isFemale)
  If (isFemale)
    return Utility.ResizeFloatArray(OpenMouthFemale, 16)
  Else
    return Utility.ResizeFloatArray(OpenMouthMale, 16)
  EndIf
endFunction

bool function SetOpenMouthPhonemes(bool isFemale, float[] Phonemes)
  if Phonemes.Length < 16
    return false
  endIf
  String setting = "fOpenMouthMale"
  If (isFemale)
    setting = "fOpenMouthFemale"
  EndIf
  int i = 16
  while i > 0
    i -= 1
    float value = PapyrusUtil.ClampFloat(Phonemes[i], 0.0, 1.0)
    SetSettingFltA(setting, value, i)
  endWhile
  return true
endFunction

bool function SetOpenMouthPhoneme(bool isFemale, int id, float value)
  if id < 0 || id > 15 
    return false
  endIf
  String setting = "fOpenMouthMale"
  If (isFemale)
    setting = "fOpenMouthFemale"
  EndIf
  float clamped = PapyrusUtil.ClampFloat(value, 0.0, 1.0)
  SetSettingFltA(setting, clamped, id)
  return true
endFunction

int function GetOpenMouthExpression(bool isFemale)
  String setting = "fOpenMouthMale"
  If (isFemale)
    setting = "fOpenMouthFemale"
  EndIf
  int ret = GetSettingFltA(setting, 16) as int
  If (ret <= 16 && ret >= 0)
    return ret
  EndIf
  return 16
endFunction

bool function SetOpenMouthExpression(bool isFemale, int value)
  String setting = "fOpenMouthMale"
  If (isFemale)
    setting = "fOpenMouthFemale"
  EndIf
  int clamped = PapyrusUtil.ClampInt(value, 0, 16)
  SetSettingFltA(setting, clamped, 16)
  return true
endFunction

; TODO: Nativy
bool function SetCustomBedOffset(Form BaseBed, float Forward = 0.0, float Sideward = 0.0, float Upward = 37.0, float Rotation = 0.0)
  if !BaseBed || !BedsList.HasForm(BaseBed)
    Log("Invalid form or bed does not exist currently in bed list.", "SetBedOffset("+BaseBed+")")
    return false
  endIf
  float[] off = new float[4]
  off[0] = Forward
  off[1] = Sideward
  off[2] = Upward
  off[3] = PapyrusUtil.ClampFloat(Rotation, -360.0, 360.0)
  StorageUtil.FloatListCopy(BaseBed, "SexLab.BedOffset", off)
  return true
endFunction

bool function ClearCustomBedOffset(Form BaseBed)
  return StorageUtil.FloatListClear(BaseBed, "SexLab.BedOffset") > 0
endFunction

float[] function GetBedOffsets(Form BaseBed)
  float[] Offsets = new float[4]
  if StorageUtil.FloatListCount(BaseBed, "SexLab.BedOffset") == 4
    StorageUtil.FloatListSlice(BaseBed, "SexLab.BedOffset", Offsets)
    return Offsets
  endIf
  int i = BedOffset.Length
  while i > 0
    i -= 1
    Offsets[i] = BedOffset[i]
  endWhile
  return Offsets
endFunction

; ------------------------------------------------------- ;
; --- SFX                                             --- ;
; ------------------------------------------------------- ;

; IDEA: Config system to replace SFX Sounds
; IDEA: Use Velocity value to dynamically adjust volume
; IDEA: SFX Types as bitflags
; TODO: Remaining SFX Sound Types

int Property TYPE_NULL      = 0 AutoReadOnly
int Property TYPE_FOOT      = 1 AutoReadOnly
int Property TYPE_HAND      = 2 AutoReadOnly
int Property TYPE_TRIBADISM = 4 AutoReadOnly
int Property TYPE_GRINDING  = 8 AutoReadOnly
int Property TYPE_ORAL      = 16 AutoReadOnly
int Property TYPE_ANAL      = 32 AutoReadOnly
int Property TYPE_VAGINAL   = 64 AutoReadOnly

Sound property OrgasmFX auto
Sound property SquishingFX auto
Sound property SuckingFX auto
Sound property SexMixedFX auto

Sound Function GetSFXSound(int aiSFXType)
  If (aiSFXType == TYPE_NULL)
    return none
  EndIf
  int all = TYPE_ANAL + TYPE_VAGINAL + TYPE_ORAL
  If (Math.LogicalAnd(aiSFXType, TYPE_ANAL + TYPE_VAGINAL + TYPE_ORAL) > 0)
    If (Math.LogicalAnd(aiSFXType, TYPE_ORAL) == 0)
      return SquishingFX
    Else
      return SexMixedFX
    EndIf
  ElseIf (Math.LogicalAnd(aiSFXType, TYPE_ORAL) > 0)
    return SuckingFX
  EndIf
  return none
EndFUnction

; ------------------------------------------------------- ;
; --- Hotkeys & TargetRef                             --- ;
; ------------------------------------------------------- ;

Spell Property SelectedSpell Auto
Actor Property TargetRef Auto Hidden
Actor _CrosshairRef

Event OnCrosshairRefChange(ObjectReference ActorRef)
  _CrosshairRef = ActorRef as Actor
EndEvent

Event OnKeyDown(int keyCode)
  If (Utility.IsInMenuMode())
    return
  ElseIf (keyCode == ToggleFreeCamera)
    ToggleFreeCamera()
  ElseIf (keyCode == TargetActor)
    If (_ActiveControl)
      DisableThreadControl(_ActiveControl)
    Else
      SetTargetActor()
    EndIf
  EndIf
EndEvent

Function SetTargetActor()
  If (!_CrosshairRef)
    return
  EndIf
  TargetRef = _CrosshairRef
  SelectedSpell.Cast(TargetRef, TargetRef)
  Debug.Notification("SexLab Target Selected: " + TargetRef.GetLeveledActorBase().GetName())
  ; Attempt to grab control of their animation?
  sslThreadController TargetThread = ThreadSlots.GetActorController(TargetRef)
  If (TargetThread && !TargetThread.HasPlayer && TargetThread.GetStatus() == TargetThread.STATUS_INSCENE && \
        !ThreadSlots.GetActorController(PlayerRef) && TakeThreadControl.Show())
    GetThreadControl(TargetThread) 
  EndIf
EndFunction

Function ToggleFreeCamera()
  If (Game.GetCameraState() != 3)
    MiscUtil.SetFreeCameraSpeed(AutoSUCSM)
  EndIf
  MiscUtil.ToggleFreeCamera()
EndFunction

bool function BackwardsPressed()
  return Input.GetNumKeysPressed() > 1 && MirrorPress(Backwards)
endFunction

bool function AdjustStagePressed()
  return (!AdjustTargetStage && Input.GetNumKeysPressed() > 1 && MirrorPress(AdjustStage)) \
    || (AdjustTargetStage && !(Input.GetNumKeysPressed() > 1 && MirrorPress(AdjustStage)))
endFunction

bool function IsAdjustStagePressed()
  return Input.GetNumKeysPressed() > 1 && MirrorPress(AdjustStage)
endFunction

bool function MirrorPress(int mirrorkey)
  if mirrorkey == 42 || mirrorkey == 54  ; Shift
    return Input.IsKeyPressed(42) || Input.IsKeyPressed(54)
  elseif mirrorkey == 29 || mirrorkey == 157 ; Ctrl
    return Input.IsKeyPressed(29) || Input.IsKeyPressed(157)
  elseif mirrorkey == 56 || mirrorkey == 184 ; Alt
    return Input.IsKeyPressed(56) || Input.IsKeyPressed(184)
  else
    return Input.IsKeyPressed(mirrorkey)
  endIf
endFunction

; ------------------------------------------------------- ;
; --- Thread Control                                  --- ;
; ------------------------------------------------------- ;

sslThreadController _ActiveControl
sslThreadController Function GetThreadControlled()
  return _ActiveControl
EndFunction
bool Function HasThreadControl(SexLabThread akThread)
  return _ActiveControl == akThread
EndFunction

Function GetThreadControl(sslThreadController TargetThread)
  If (!TargetThread || _ActiveControl || TargetThread.GetStatus() != TargetThread.STATUS_INSCENE && TargetThread.GetStatus() != TargetThread.STATUS_SETUP)
    Log("Cannot get Control of " + TargetThread + ", another thread is already being controlled or given thread is not animating/none")
    return
  EndIf
  Log("Taking control over thread: " + TargetThread)
  _ActiveControl = TargetThread
  ; Lock players movement iff they arent owned by the thread
  If (!_ActiveControl.HasPlayer)
    _ActiveControl.AutoAdvance = false
    PlayerRef.StopCombatAlarm()
    if PlayerRef.IsWeaponDrawn()
      PlayerRef.SheatheWeapon()
    endIf
    Game.SetPlayerAIDriven()
  EndIf
  ; Give player control
  _ActiveControl.EnableHotkeys(true)
EndFunction

Function DisableThreadControl(sslThreadController TargetThread)
  If (!_ActiveControl || _ActiveControl != TargetThread)
    return
  EndIf
  ; Release players thread control
  _ActiveControl.DisableHotkeys()
  _ActiveControl.AutoAdvance = true
  ; Unlock players movement iff they arent owned by the thread
  If (!_ActiveControl.HasPlayer)
    Game.SetPlayerAIDriven(false)
  EndIf
  _ActiveControl = none
Endfunction

; ------------------------------------------------------- ;
; --- Thread Hooks                                    --- ;
; ------------------------------------------------------- ;

SexLabThreadHook[] _Hooks
int Property HOOKID_STARTING    = 0 AutoReadOnly
int Property HOOKID_STAGESTART  = 1 AutoReadOnly
int Property HOOKID_STAGEEND    = 2 AutoReadOnly
int Property HOOKID_END         = 3 AutoReadOnly

bool Function AddHook(SexLabThreadHook akHook)
  If (!akHook || _Hooks.Find(akHook) > -1)
    return false
  ElseIf (!_Hooks.Length)
    _Hooks = new SexLabThreadHook[16]
  EndIf
  int idx = _Hooks.Find(none)
  If (idx == -1)
    Error("Unable to bind new Thread Hook, limit of " + _Hooks.Length + " hooks reached")
    Debug.MessageBox("Unable to bind new Thread Hook, limit of possible hooks reached\nPlease report this to Scrab")
    return false
  EndIf
  _Hooks[idx] = akHook
  return true
EndFunction

bool Function RemoveHook(SexLabThreadHook akHook)
  int idx = _Hooks.Find(akHook)
  If (idx == -1)
    Error("Hook " + akHook + " is not registered and cannot be removed")
    return false
  EndIf
  _Hooks[idx] = none
  return true
EndFunction

bool Function IsHooked(SexLabThreadHook akHook)
  return akHook && _Hooks.Find(akHook) > -1
EndFUnction

Function RunHook(int aiHookID, SexLabThread akThread)
  Log("Running Hook " + aiHookID + " from thread " + akThread)
  int i = 0
  While (i < _Hooks.Length)
    If (!_Hooks[i])
      ; Skip
    ElseIf (HOOKID_STAGESTART)
      _Hooks[i].OnStageStart(akThread)
    ElseIf (HOOKID_STAGEEND)
      _Hooks[i].OnStageEnd(akThread)
    ElseIf (HOOKID_STARTING)
      _Hooks[i].OnAnimationStarting(akThread)
    ElseIf (HOOKID_END)
      _Hooks[i].OnAnimationEnd(akThread)
    EndIf
    i += 1
  EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Animation Profiles                              --- ;
; ------------------------------------------------------- ;

function ExportProfile(int Profile = 1)
  SaveAdjustmentProfile()
endFunction

function ImportProfile(int Profile = 1)
  SetAdjustmentProfile("../SexLab/AnimationProfile_"+Profile+".json")
endfunction

function SwapToProfile(int Profile)
  AnimProfile = Profile
  SetAdjustmentProfile("../SexLab/AnimationProfile_"+Profile+".json")
endFunction

bool function SetAdjustmentProfile(string ProfileName) global
  String msg = "Adjustment Profiles are no longer supported"
  Debug.MessageBox(msg)
  Debug.TraceStack(msg)
EndFunction
bool function SaveAdjustmentProfile() global
  String msg = "Adjustment Profiles are no longer supported"
  Debug.MessageBox(msg)
  Debug.TraceStack(msg)
EndFunction

; ------------------------------------------------------- ;
; --- 3rd party compatibility                         --- ;
; ------------------------------------------------------- ;

Faction property BardExcludeFaction auto
ReferenceAlias property BardBystander1 auto
ReferenceAlias property BardBystander2 auto
ReferenceAlias property BardBystander3 auto
ReferenceAlias property BardBystander4 auto
ReferenceAlias property BardBystander5 auto

bool function CheckBardAudience(Actor ActorRef, bool RemoveFromAudience = true)
  If (!ActorRef)
    return false
	ElseIf (RemoveFromAudience)
    return BystanderClear(ActorRef, BardBystander1) || BystanderClear(ActorRef, BardBystander2) || BystanderClear(ActorRef, BardBystander3) \
      || BystanderClear(ActorRef, BardBystander4) || BystanderClear(ActorRef, BardBystander5)
 	Else
    return ActorRef == BardBystander1.GetReference() || ActorRef == BardBystander2.GetReference() || ActorRef == BardBystander3.GetReference() \
      || ActorRef == BardBystander4.GetReference() || ActorRef == BardBystander5.GetReference()
	EndIf
endFunction

bool function BystanderClear(Actor ActorRef, ReferenceAlias BardBystander)
  If (ActorRef == BardBystander.GetReference())
    BardBystander.Clear()
    ActorRef.EvaluatePackage()
    Log("Cleared from bard audience", "CheckBardAudience("+ActorRef+")")
    return true
	EndIf
  return false
endFunction

; ------------------------------------------------------- ;
; --- Strapon Functions                               --- ;
; ------------------------------------------------------- ;

Armor Property CalypsStrapon Auto
Form[] Property Strapons Auto Hidden

Form Function GetStrapon()
  If (Strapons.Length > 0)
    return Strapons[Utility.RandomInt(0, (Strapons.Length - 1))]
  EndIf
  return none
EndFunction

Form Function WornStrapon(Actor ActorRef)
  int i = Strapons.Length
  While i
    i -= 1
    If (ActorRef.IsEquipped(Strapons[i]))
      return Strapons[i]
    EndIf
  EndWhile
  return none
endFunction
bool Function HasStrapon(Actor ActorRef)
  return WornStrapon(ActorRef) != none
EndFunction

Form Function PickStrapon(Actor ActorRef)
  Form strapon = WornStrapon(ActorRef)
  If (strapon)
    return strapon
  EndIf
  return GetStrapon()
EndFunction

Function LoadStrapons()
  Strapons = new form[1]
  Strapons[0] = CalypsStrapon

  If (Game.GetModByName("StrapOnbyaeonv1.1.esp") != 255)
    LoadStrapon("StrapOnbyaeonv1.1.esp", 0x0D65)
	EndIf
  If (Game.GetModByName("TG.esp") != 255)
    LoadStrapon("TG.esp", 0x0182B)
	EndIf
  If (Game.GetModByName("Futa equippable.esp") != 255)
    LoadStrapon("Futa equippable.esp", 0x0D66)
    LoadStrapon("Futa equippable.esp", 0x0D67)
    LoadStrapon("Futa equippable.esp", 0x01D96)
    LoadStrapon("Futa equippable.esp", 0x022FB)
    LoadStrapon("Futa equippable.esp", 0x022FC)
    LoadStrapon("Futa equippable.esp", 0x022FD)
	EndIf
  If (Game.GetModByName("Skyrim_Strap_Ons.esp") != 255)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x00D65)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x02859)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285A)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285B)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285C)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285D)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285E)
    LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285F)
	EndIf
  If (Game.GetModByName("SOS Equipable Schlong.esp") != 255)
    LoadStrapon("SOS Equipable Schlong.esp", 0x0D62)
	EndIf
  ModEvent.Send(ModEvent.Create("SexLabLoadStrapons"))
EndFunction

Armor Function LoadStrapon(string esp, int id)
  Armor Strapon = Game.GetFormFromFile(id, esp) as Armor
  LoadStraponEx(Strapon)
  return Strapon
EndFunction
Function LoadStraponEx(Armor akStraponForm)
  If (akStraponForm)
    Strapons = PapyrusUtil.PushForm(Strapons, akStraponForm)
  Endif
EndFunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

bool function CheckSystemPart(string CheckSystem)
  if CheckSystem == "Skyrim"
    return (StringUtil.SubString(Debug.GetVersionNumber(), 0, 3) as float) >= 1.5
  elseIf CheckSystem == "SKSE"
    return SKSE.GetScriptVersionRelease() >= 64
  elseIf CheckSystem == "SkyUI"
    return Quest.GetQuest("SKI_ConfigManagerInstance") != none
  elseIf CheckSystem == "SexLabP+"
    return SKSE.GetPluginVersion("SexLab") > -1
  elseIf CheckSystem == "PapyrusUtil"
    return PapyrusUtil.GetVersion() >= 39
  elseIf CheckSystem == "NiOverride"
		return HasNiOverride
  elseIf CheckSystem == "MfgFix"
		return HasMFGFix
  elseIf CheckSystem == "FNIS"
    return FNIS.VersionCompare(7, 0, 0) >= 0
  endIf
  return false
endFunction

bool function CheckSystem()
  if !CheckSystemPart("Skyrim")
    CheckSkyrim.Show(1.6)
    return false
  elseIf !CheckSystemPart("SKSE")
    CheckSKSE.Show(2.22)
    return false
  elseIf !CheckSystemPart("SkyUI")
    CheckSkyUI.Show(5.2)
    return false
  elseIf !CheckSystemPart("PapyrusUtil")
    CheckPapyrusUtil.Show(4.4)
    return false
  endIf
  return true
endFunction

function Reload()
  if DebugMode
    Debug.OpenUserLog("SexLabDebug")
    Debug.TraceUser("SexLabDebug", "Config Reloading...")
  endIf
  parent.Setup()

  ; Configure SFX & Voice volumes
  AudioVoice.SetVolume(VoiceVolume)
  AudioSFX.SetVolume(SFXVolume)

  ; Remove any targeted actors
  RegisterForCrosshairRef()
  _CrosshairRef = none
  TargetRef = none

  ; TFC Toggle key
  UnregisterForAllKeys()
  RegisterForKey(ToggleFreeCamera)
  RegisterForKey(TargetActor)
  RegisterForKey(EndAnimation)

  ; Remove any NPC thread control player has
  DisableThreadControl(_ActiveControl)
endFunction

function Setup()
  parent.Setup()
  SetDefaults()
endFunction

function SetDefaults()
  ; Reload config
  Reload()
  ; Reset data
  LoadStrapons()
  ; Rest some player configurations
  VoiceSlots.ForgetVoice(PlayerRef)
endFunction

; ------------------------------------------------------- ;
; --- Export/Import to JSON                           --- ;
; ------------------------------------------------------- ;

string File
function ExportSettings()
  ; Export object registry
  ExportAnimations()
  ExportCreatures()
  ExportVoices()
endFunction

function ImportSettings()  
  ; Import object registry
  ImportAnimations()
  ImportCreatures()
  ImportVoices()

  ; Reload settings with imported values
  Reload()
endFunction

; Integers
function ExportInt(string Name, int Value)
  JsonUtil.SetIntValue(File, Name, Value)
endFunction
int function ImportInt(string Name, int Value)
  return JsonUtil.GetIntValue(File, Name, Value)
endFunction

; Booleans
function ExportBool(string Name, bool Value)
  JsonUtil.SetIntValue(File, Name, Value as int)
endFunction
bool function ImportBool(string Name, bool Value)
  return JsonUtil.GetIntValue(File, Name, Value as int) as bool
endFunction

; Floats
function ExportFloat(string Name, float Value)
  JsonUtil.SetFloatValue(File, Name, Value)
endFunction
float function ImportFloat(string Name, float Value)
  return JsonUtil.GetFloatValue(File, Name, Value)
endFunction

; Float Arrays
function ExportFloatList(string Name, float[] Values, int len)
  JsonUtil.FloatListClear(File, Name)
  JsonUtil.FloatListCopy(File, Name, Values)
endFunction
float[] function ImportFloatList(string Name, float[] Values, int len)
  if JsonUtil.FloatListCount(File, Name) == len
    if Values.Length != len
      Values = Utility.CreateFloatArray(len)
    endIf
    int i
    while i < len
      Values[i] = JsonUtil.FloatListGet(File, Name, i)
      i += 1
    endWhile
  endIf
  return Values
endFunction

; Boolean Arrays
function ExportBoolList(string Name, bool[] Values, int len)
  JsonUtil.IntListClear(File, Name)
  int i
  while i < len
    JsonUtil.IntListAdd(File, Name, Values[i] as int)
    i += 1
  endWhile
endFunction
bool[] function ImportBoolList(string Name, bool[] Values, int len)
  if JsonUtil.IntListCount(File, Name) == len
    if Values.Length != len
      Values = Utility.CreateBoolArray(len)
    endIf
    int i
    while i < len
      Values[i] = JsonUtil.IntListGet(File, Name, i) as bool
      i += 1
    endWhile
  endIf
  return Values
endFunction

; Animations
function ExportAnimations()
  JsonUtil.StringListClear(File, "Animations")
  int i = AnimSlots.Slotted
  while i
    i -= 1
    sslBaseAnimation Slot = AnimSlots.GetBySlot(i)
    JsonUtil.StringListAdd(File, "Animations", sslUtility.MakeArgs(",", Slot.Registry, Slot.Enabled as int, Slot.HasTag("LeadIn") as int, Slot.HasTag("Aggressive") as int))
  endWhile
endfunction
function ImportAnimations()
  int i = JsonUtil.StringListCount(File, "Animations")
  while i
    i -= 1
    ; Registrar, Enabled, Foreplay, Aggressive
    string[] args = PapyrusUtil.StringSplit(JsonUtil.StringListGet(File, "Animations", i))
    if args.Length == 4 && AnimSlots.FindByRegistrar(args[0]) != -1
      sslBaseAnimation Slot = AnimSlots.GetbyRegistrar(args[0])
      Slot.Enabled = (args[1] as int) as bool
      Slot.AddTagConditional("LeadIn", (args[2] as int) as bool)
      Slot.AddTagConditional("Aggressive", (args[3] as int) as bool)
    endIf
  endWhile
endFunction

; Creatures
function ExportCreatures()
  JsonUtil.StringListClear(File, "Creatures")
  int i = CreatureSlots.Slotted
  while i
    i -= 1
    sslBaseAnimation Slot = CreatureSlots.GetBySlot(i)
    JsonUtil.StringListAdd(File, "Creatures", sslUtility.MakeArgs(",", Slot.Registry, Slot.Enabled as int))
  endWhile
endFunction
function ImportCreatures()
  int i = JsonUtil.StringListCount(File, "Creatures")
  while i
    i -= 1
    ; Registrar, Enabled
    string[] args = PapyrusUtil.StringSplit(JsonUtil.StringListGet(File, "Creatures", i))
    if args.Length == 2 && CreatureSlots.FindByRegistrar(args[0]) != -1
      CreatureSlots.GetbyRegistrar(args[0]).Enabled = (args[1] as int) as bool
    endIf
  endWhile
endFunction

; Voices
function ExportVoices()
  JsonUtil.StringListClear(File, "Voices")
  int i = VoiceSlots.Slotted
  while i
    i -= 1
    sslBaseVoice Slot = VoiceSlots.GetBySlot(i)
    JsonUtil.StringListAdd(File, "Voices", sslUtility.MakeArgs(",", Slot.Registry, Slot.Enabled as int))
  endWhile
  ; Player voice
  JsonUtil.SetStringValue(File, "PlayerVoice", VoiceSlots.GetSavedName(PlayerRef))
endfunction
function ImportVoices()
  int i = JsonUtil.StringListCount(File, "Voices")
  while i
    i -= 1
    ; Registrar, Enabled
    string[] args = PapyrusUtil.StringSplit(JsonUtil.StringListGet(File, "Voices", i))
    if args.Length == 2 && VoiceSlots.FindByRegistrar(args[0]) != -1
      VoiceSlots.GetbyRegistrar(args[0]).Enabled = (args[1] as int) as bool
    endIf
  endWhile
  ; Player voice
  VoiceSlots.ForgetVoice(PlayerRef)
  VoiceSlots.SaveVoice(PlayerRef, VoiceSlots.GetByName(JsonUtil.GetStringValue(File, "PlayerVoice", "$SSL_Random")))
endFunction
; ------------------------------------------------------- ;
; --- Config Properties                               --- ;
; ------------------------------------------------------- ;

; Both shaders are [RampUp: 0.35s, Hold: 0.65s, RampDown: 0.4s]
ImageSpaceModifier Property FadeToBlackAndBackImod Auto
ImageSpaceModifier Property BlurAndBackImod Auto

function ApplyFade(bool forceTest = false)
  int imod = GetSettingInt("iUseFade")
  If (imod == 0)      ; No fade
    return
  ElseIf (imod == 1)  ; Fade Black
    FadeToBlackAndBackImod.Apply()
  ElseIf (imod == 2)  ; Blur
    BlurAndBackImod.Apply()
  EndIf
  Utility.Wait(0.37)
endFunction

function RemoveFade(bool forceTest = false)
  FadeToBlackAndBackImod.Remove()
  BlurAndBackImod.Remove()
endFunction

; ------------------------------------------------------- ;
; --- Misc                                            --- ;
; ------------------------------------------------------- ;

function StoreActor(Form FormRef) global
  if FormRef
    StorageUtil.FormListAdd(none, "SexLab.ActorStorage", FormRef, false)
  endIf
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;               ██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗              ;
;               ██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝              ;
;               ██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝               ;
;               ██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝                ;
;               ███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║                 ;
;               ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝                 ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

int function GetVersion()
  return SexLabUtil.GetVersion()
endFunction

string function GetStringVer()
  return SexLabUtil.GetStringVer()
endFunction

bool property Enabled hidden
  bool function get()
    return SexLabUtil.GetAPI().Enabled
  endFunction
endProperty

SexLabFramework Property SexLab
  SexLabFramework Function Get()
    return SexLabUtil.GetAPI()
  EndFunction
EndProperty

Message property CheckFNIS Hidden
  Message Function Get()
    return Game.GetFormFromFile(0x70C38, "SexLab.esm") as Message
  EndFunction
EndProperty
Message property CheckSexLabUtil Hidden
  Message Function Get()
    return Game.GetFormFromFile(0x7D380, "SexLab.esm") as Message
  EndFunction
EndProperty


Faction property AnimatingFaction Hidden
  Faction Function Get()
    return Game.GetFormFromFile(0xE50F, "SexLab.esm") as Faction
  EndFunction
EndProperty
Faction property GenderFaction Hidden
  Faction Function Get()
    return Game.GetFormFromFile(0x43A43, "SexLab.esm") as Faction
  EndFunction
EndProperty
Faction property ForbiddenFaction Hidden
  Faction Function Get()
    return Game.GetFormFromFile(0x49068, "SexLab.esm") as Faction
  EndFunction
EndProperty
Weapon property DummyWeapon Hidden
  Weapon Function Get()
    return Game.GetFormFromFile(0x311BF, "SexLab.esm") as Weapon
  EndFunction
EndProperty
Armor property NudeSuit Hidden
  Armor Function Get()
    return Game.GetFormFromFile(0x18715, "SexLab.esm") as Armor
  EndFunction
EndProperty
Keyword property ActorTypeNPC Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("ActorTypeNPC")
  EndFunction
EndProperty
Keyword property SexLabActive Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabActive")
  EndFunction
EndProperty
Keyword property FurnitureBedRoll Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("FurnitureBedRoll")
  EndFunction
EndProperty
Furniture property BaseMarker Hidden
  Furniture Function Get()
    return Game.GetFormFromFile(0x45A93, "SexLab.esm") as Furniture
  EndFunction
EndProperty
Package property DoNothing Hidden
  Package Function Get()
    return Game.GetFormFromFile(0xE50E, "SexLab.esm") as Package
  EndFunction
EndProperty
FormList property BedsList Hidden
  FormList Function Get()
    return Game.GetFormFromFile(0x181B1, "SexLab.esm") as FormList
  EndFunction
EndProperty
FormList property BedRollsList Hidden
  FormList Function Get()
    return Game.GetFormFromFile(0x6198C, "SexLab.esm") as FormList
  EndFunction
EndProperty
FormList property DoubleBedsList Hidden
  FormList Function Get()
    return Game.GetFormFromFile(0x854B8, "SexLab.esm") as FormList
  EndFunction
EndProperty
Static property LocationMarker Hidden
  Static Function Get()
    return Game.GetFormFromFile(0x2803E, "SexLab.esm") as Static
  EndFunction
EndProperty
Message property UseBed Hidden
  Message Function Get()
    return Game.GetFormFromFile(0x65F97, "SexLab.esm") as Message
  EndFunction
EndProperty
Topic property LipSync Hidden
  Topic Function Get()
    return Game.GetFormFromFile(0x68590, "SexLab.esm") as Topic
  EndFunction
EndProperty
VoiceType property SexLabVoiceM Hidden
  VoiceType Function Get()
    return Game.GetFormFromFile(0x2CBBD, "SexLab.esm") as VoiceType
  EndFunction
EndProperty
VoiceType property SexLabVoiceF Hidden
  VoiceType Function Get()
    return Game.GetFormFromFile(0x2CBBE, "SexLab.esm") as VoiceType
  EndFunction
EndProperty
FormList property SexLabVoices Hidden
  FormList Function Get()
    return Game.GetFormFromFile(0x2CBBC, "SexLab.esm") as FormList
  EndFunction
EndProperty
Idle property IdleReset Hidden
  Idle Function Get()
    return Game.GetFormFromFile(0x87FCA, "SexLab.esm") as Idle
  EndFunction
EndProperty

Spell property CumVaginalOralAnalSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x43A3F, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property CumOralAnalSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x43A41, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property CumVaginalOralSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x43A3B, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property CumVaginalAnalSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x43A3D, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property CumVaginalSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x41478, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property CumOralSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x434D5, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property CumAnalSpell Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x434D7, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Oral1Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D651, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Oral1Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D653, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Oral2Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D655, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Oral1Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D657, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Oral2Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D659, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Oral2Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D65B, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Oral1Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D65D, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Oral2Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D65F, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Oral1Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D661, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Oral2Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D663, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Oral1Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D665, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Oral2Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D667, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Oral1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D669, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Oral1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D66B, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Oral2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D66D, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Oral2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D66F, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D671, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D673, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D675, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D677, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D679, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Vaginal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D67B, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Oral1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D67D, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Oral2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D67F, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Anal1 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D681, "SexLab.esm") as Spell
  EndFunction
EndProperty
Spell property Anal2 Hidden
  Spell Function Get()
    return Game.GetFormFromFile(0x8D683, "SexLab.esm") as Spell
  EndFunction
EndProperty
Keyword property CumOralKeyword Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabOralCum")
  EndFunction
EndProperty
Keyword property CumAnalKeyword Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabAnalCum")
  EndFunction
EndProperty
Keyword property CumVaginalKeyword Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabVaginalCum")
  EndFunction
EndProperty
Keyword property CumOralStackedKeyword Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabOralStackedCum")
  EndFunction
EndProperty
Keyword property CumAnalStackedKeyword Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabAnalStackedCum")
  EndFunction
  Function Set(Keyword aSet)
  EndFunction
EndProperty
Keyword property CumVaginalStackedKeyword Hidden
  Keyword Function Get()
    return Keyword.GetKeyword("SexLabVaginalStackedCum")
  EndFunction
EndProperty

GlobalVariable property DebugVar1 Hidden
  GlobalVariable Function Get()
    return Game.GetFormFromFile(0x7DE45, "SexLab.esm") as GlobalVariable
  EndFunction
EndProperty
GlobalVariable property DebugVar2 Hidden
  GlobalVariable Function Get()
    return Game.GetFormFromFile(0x7DE46, "SexLab.esm") as GlobalVariable
  EndFunction
EndProperty
GlobalVariable property DebugVar3 Hidden
  GlobalVariable Function Get()
    return Game.GetFormFromFile(0x7DE47, "SexLab.esm") as GlobalVariable
  EndFunction
EndProperty
GlobalVariable property DebugVar4 Hidden
  GlobalVariable Function Get()
    return Game.GetFormFromFile(0x7DE48, "SexLab.esm") as GlobalVariable
  EndFunction
EndProperty
GlobalVariable property DebugVar5 Hidden
  GlobalVariable Function Get()
    return Game.GetFormFromFile(0x7DE49, "SexLab.esm") as GlobalVariable
  EndFunction
EndProperty

Actor[] property TargetRefs auto hidden

bool property HasSchlongs Hidden
  bool Function Get()
    return Game.GetModByName("Schlongs of Skyrim - Core.esm") != 255 || Game.GetModByName("SAM - Shape Atlas for Men.esp") != 255
  EndFunction
EndProperty

bool property HasFrostfall
  bool Function Get()
    return Game.GetModByName("Frostfall.esp") != 255
  EndFunction
EndProperty

FormList property FrostExceptions
  FormList Function Get()
    If (HasFrostfall)
      return Game.GetFormFromFile(0x6E7E6, "Frostfall.esp") as FormList
    EndIf
    return none
  EndFunction
EndProperty

float[] property BedOffset hidden
  float[] Function Get()
    float[] ret = new float[4]
    ret[2] = 37.0
    return ret
  EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Export/Import to JSON                           --- ;
; ------------------------------------------------------- ;

; Expressions
function ExportExpressions()
endfunction
function ImportExpressions()
endFunction

; ------------------------------------------------------- ;
; --- MCM Settings                                    --- ;
; ------------------------------------------------------- ;

bool property RestrictAggressive = false auto hidden
bool property RestrictStrapons = false auto hidden
bool property UseMaleNudeSuit = false auto hidden
bool property UseFemaleNudeSuit = false auto hidden
bool property NPCSaveVoice = true auto hidden
bool property RagdollEnd = false auto hidden
bool property RefreshExpressions = true auto hidden
bool property AllowFFCum = false auto hidden
bool property ForeplayStage = false auto hidden
bool property BedRemoveStanding = true auto hidden
bool property RestrictGenderTag = false auto hidden
bool property RemoveHeelEffect = true auto hidden
bool property SeedNPCStats = true auto hidden
bool property FixVictimPos = true auto hidden
bool property ForceSort = true auto hidden
bool property LimitedStrip = false auto hidden
bool property ScaleActors = false auto hidden ; Scale is encoded in animation, disable all scale with other setting
int property AnimProfile = 1 auto hidden  ; scaling is considered absolute, 1 profile to fit them all

float property LeadInCoolDown = 0.0 auto hidden

; COMEBACK: Re-implement?
bool property RaceAdjustments = false auto hidden    ; this and v is used for ActorKey scale profile settings

bool property SeparateOrgasms Hidden
  bool Function Get()
    return GetSettingInt("iClimaxType") == CLIMAXTYPE_EXTERN
  EndFunction
  Function Set(bool aSet)
    If (aSet)
      SetSettingInt("iClimaxType", CLIMAXTYPE_EXTERN)
    Else
      SetSettingInt("iClimaxType", CLIMAXTYPE_SCENE)
    EndIf
  EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Functions                                       --- ;
; ------------------------------------------------------- ;

event OnInit()
  parent.OnInit()
endEvent

bool function AddCustomBed(Form BaseBed, int BedType = 0)
  if !BaseBed
    return false
  elseIf !BedsList.HasForm(BaseBed)
    BedsList.AddForm(BaseBed)
  endIf
  if BedType == 1 && !BedRollsList.HasForm(BaseBed)
    BedRollsList.AddForm(BaseBed)
  elseIf BedType == 2 && !DoubleBedsList.HasForm(BaseBed)
    DoubleBedsList.AddForm(BaseBed)
  endIf
  return true
endFunction

Form function EquipStrapon(Actor ActorRef)
  form Strapon = PickStrapon(ActorRef)
  if Strapon
    ActorRef.AddItem(Strapon, 1, true)
    ActorRef.EquipItem(Strapon, false, true)
  endIf
  return Strapon
endFunction

function UnequipStrapon(Actor ActorRef)
  int i = Strapons.Length
  while i
    i -= 1
    if ActorRef.IsEquipped(Strapons[i])
      ActorRef.RemoveItem(Strapons[i], 1, true)
    endIf
  endWhile
endFunction

bool function UsesNudeSuit(bool IsFemale)
  return false
endFunction

bool property HasHDTHeels
  bool Function Get()
    return Game.GetModByName("hdtHighHeel.esm") != 255
  EndFunction
  Function Set(bool aSet)
  EndFunction
EndProperty

Spell function GetHDTSpell(Actor ActorRef)
  If (!ActorRef || !HasHDTHeels) ; || !ActorRef.GetWornForm(Armor.GetMaskForSlot(37))
    return none
  EndIf
  MagicEffect HDTHeelEffect = Game.GetFormFromFile(0x800, "hdtHighHeel.esm") as MagicEffect
  if !HDTHeelEffect
    return none
  endIf
  int i = ActorRef.GetSpellCount()
  while i
    i -= 1
    Spell SpellRef = ActorRef.GetNthSpell(i)
    Log(SpellRef.GetName(), "Checking("+SpellRef+") for HDT HighHeels")
    if SpellRef && StringUtil.Find(SpellRef.GetName(), "Heel") != -1
      return SpellRef
    endIf
    int n = SpellRef.GetNumEffects()
    while n
      n -= 1
      if SpellRef.GetNthEffectMagicEffect(n) == HDTHeelEffect
        return SpellRef
      endIf
    endWhile
  endWhile
  return none
endFunction

function AddTargetActor(Actor ActorRef)
endFunction

int function RegisterThreadHook(sslThreadHook Hook)
  AddHook(Hook)
endFunction
sslThreadHook[] function GetThreadHooks()
  return new sslThreadHook[1]
endFunction
int function GetThreadHookCount()
  return 0
endFunction

function InitThreadHooks()
endFunction

bool Function HasCreatureInstall()
  Log("Function HasCreatureInstall() is redundant and always returns true to avoid a FNIS Compile Dependency")
  return true
EndFunction

function ReloadData()
endFunction

; ------------------------------------------------------- ;
; --- Pre P2.0 Config Accessors                       --- ;
; ------------------------------------------------------- ;

int[] Function GetStripSettings(bool IsFemale, bool IsLeadIn = false, bool IsAggressive = false, bool IsVictim = false)
  return GetStripForms(IsFemale || IsVictim , IsAggressive)
EndFunction

bool[] function GetStrip(bool IsFemale, bool IsLeadIn = false, bool IsAggressive = false, bool IsVictim = false)
  int[] ret = GetStripSettings(IsFemale, IsLeadIn, IsAggressive, IsVictim)
  return sslUtility.BitsToBool(ret[0], ret[1])
endFunction

bool[] property StripMale Hidden
  bool[] Function Get()
    return GetStrip(false, false, false, false)
  EndFunction
EndProperty
bool[] property StripFemale Hidden
  bool[] Function Get()
    return GetStrip(true, false, false, false)
  EndFunction
EndProperty
bool[] property StripLeadInMale Hidden
  bool[] Function Get()
    return GetStrip(false, true, false, false)
  EndFunction
EndProperty
bool[] property StripLeadInFemale Hidden
  bool[] Function Get()
    return GetStrip(true, true, false, false)
  EndFunction
EndProperty
bool[] property StripVictim Hidden
  bool[] Function Get()
    return GetStrip(false, false, true, true)
  EndFunction
EndProperty
bool[] property StripAggressor Hidden
  bool[] Function Get()
    return GetStrip(false, false, true, false)
  EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Pre 1.50 Config Accessors                       --- ;
; ------------------------------------------------------- ;

bool property bRestrictAggressive hidden
  bool function get()
    return RestrictAggressive
  endFunction
endProperty
bool property bAllowCreatures hidden
  bool function get()
    return AllowCreatures
  endFunction
endProperty
bool property bUseStrapons hidden
  bool function get()
    return UseStrapons
  endFunction
endProperty
bool property bRedressVictim hidden
  bool function get()
    return RedressVictim
  endFunction
endProperty
bool property bRagdollEnd hidden
  bool function get()
    return RagdollEnd
  endFunction
endProperty
bool property bUndressAnimation hidden
  bool function get()
    return UndressAnimation
  endFunction
endProperty
bool property bScaleActors hidden
  bool function get()
    return ScaleActors
  endFunction
endProperty
bool property bUseCum hidden
  bool function get()
    return UseCum
  endFunction
endProperty
bool property bAllowFFCum hidden
  bool function get()
    return AllowFFCum
  endFunction
endProperty
bool property bDisablePlayer hidden
  bool function get()
    return DisablePlayer
  endFunction
endProperty
bool property bAutoTFC hidden
  bool function get()
    return AutoTFC
  endFunction
endProperty
bool property bAutoAdvance hidden
  bool function get()
    return AutoAdvance
  endFunction
endProperty
bool property bForeplayStage hidden
  bool function get()
    return ForeplayStage
  endFunction
endProperty
bool property bOrgasmEffects hidden
  bool function get()
    return OrgasmEffects
  endFunction
endProperty
