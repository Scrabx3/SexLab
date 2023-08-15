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

; // TODO: Add a 3rd person mod detection when determining FNIS sensitive variables.
; // Disable it when no longer relevant.

; ------------------------------------------------------- ;
; --- System Resources                                --- ;
; ------------------------------------------------------- ;

SexLabFramework property SexLab auto

int function GetVersion()
  return SexLabUtil.GetVersion()
endFunction

string function GetStringVer()
  return SexLabUtil.GetStringVer()
endFunction

bool property Enabled hidden
  bool function get()
    return SexLab.Enabled
  endFunction
endProperty

; bool property InDebugMode auto hidden
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
      if PlayerRef && PlayerRef != none
        PlayerRef.AddSpell((Game.GetFormFromFile(0x073CC, "SexLab.esm") as Spell))
        PlayerRef.AddSpell((Game.GetFormFromFile(0x5FE9B, "SexLab.esm") as Spell))
      endIf        
    else
      if Debug.TraceUser("SexLabDebug", "SexLab Debug/Development Mode Deactivated")
        Debug.CloseUserLog("SexLabDebug")
      endIf
      MiscUtil.PrintConsole("SexLab Debug/Development Mode Deactivated")
      if PlayerRef && PlayerRef != none
        PlayerRef.RemoveSpell((Game.GetFormFromFile(0x073CC, "SexLab.esm") as Spell))
        PlayerRef.RemoveSpell((Game.GetFormFromFile(0x5FE9B, "SexLab.esm") as Spell))
      endIf        
    endIf
    int eid = ModEvent.Create("SexLabDebugMode")
    ModEvent.PushBool(eid, value)
    ModEvent.Send(eid)
  endFunction
endProperty


Faction property AnimatingFaction auto
Faction property GenderFaction auto
Faction property ForbiddenFaction auto
Weapon property DummyWeapon auto
Armor property NudeSuit auto
Armor property CalypsStrapon auto

Spell property SelectedSpell auto

Spell property CumVaginalOralAnalSpell auto
Spell property CumOralAnalSpell auto
Spell property CumVaginalOralSpell auto
Spell property CumVaginalAnalSpell auto
Spell property CumVaginalSpell auto
Spell property CumOralSpell auto
Spell property CumAnalSpell auto

Spell property Vaginal1Oral1Anal1 auto
Spell property Vaginal2Oral1Anal1 auto
Spell property Vaginal2Oral2Anal1 auto
Spell property Vaginal2Oral1Anal2 auto
Spell property Vaginal1Oral2Anal1 auto
Spell property Vaginal1Oral2Anal2 auto
Spell property Vaginal1Oral1Anal2 auto
Spell property Vaginal2Oral2Anal2 auto
Spell property Oral1Anal1 auto
Spell property Oral2Anal1 auto
Spell property Oral1Anal2 auto
Spell property Oral2Anal2 auto
Spell property Vaginal1Oral1 auto
Spell property Vaginal2Oral1 auto
Spell property Vaginal1Oral2 auto
Spell property Vaginal2Oral2 auto
Spell property Vaginal1Anal1 auto
Spell property Vaginal2Anal1 auto
Spell property Vaginal1Anal2 auto
Spell property Vaginal2Anal2 auto
Spell property Vaginal1 auto
Spell property Vaginal2 auto
Spell property Oral1 auto
Spell property Oral2 auto
Spell property Anal1 auto
Spell property Anal2 auto

Keyword property CumOralKeyword auto
Keyword property CumAnalKeyword auto
Keyword property CumVaginalKeyword auto
Keyword property CumOralStackedKeyword auto
Keyword property CumAnalStackedKeyword auto
Keyword property CumVaginalStackedKeyword auto

Keyword property ActorTypeNPC auto
Keyword property SexLabActive auto
Keyword property FurnitureBedRoll auto

Furniture property BaseMarker auto
Package property DoNothing auto

Sound property OrgasmFX auto
Sound property SquishingFX auto
Sound property SuckingFX auto
Sound property SexMixedFX auto

Sound[] property HotkeyUp auto
Sound[] property HotkeyDown auto

Static property LocationMarker auto
FormList property BedsList auto
FormList property BedRollsList auto
FormList property DoubleBedsList auto
Message property UseBed auto
Message property CleanSystemFinish auto
Message property CheckSKSE auto
Message property CheckFNIS auto
Message property CheckSkyrim auto
Message property CheckSexLabUtil auto
Message property CheckPapyrusUtil auto
Message property CheckSkyUI auto
Message property TakeThreadControl auto

Topic property LipSync auto
VoiceType property SexLabVoiceM auto
VoiceType property SexLabVoiceF auto
FormList property SexLabVoices auto
SoundCategory property AudioSFX auto
SoundCategory property AudioVoice auto

Idle property IdleReset auto

; ------------------------------------------------------- ;
; --- Config Properties                               --- ;
; ------------------------------------------------------- ;

bool Function GetSettingBool(String asSetting) native global
int Function GetSettingInt(String asSetting) native global
int[] Function GetSettingIntA(String asSetting) native global

Function SetSettingBool(String asSetting, bool abValue) native global
Function SetSettingInt(String asSetting, int aiValue) native global
Function SetSettingIntA(String asSetting, int[] aiValue) native global

; Booleans
bool property AllowCreatures auto hidden
bool property UseStrapons auto hidden
bool property RedressVictim auto hidden
bool property UseLipSync auto hidden
bool property UseExpressions auto hidden
bool property UseCum auto hidden
bool property DisablePlayer auto hidden
bool property AutoTFC auto hidden
bool property AutoAdvance auto hidden
bool property OrgasmEffects auto hidden
bool property UseCreatureGender auto hidden
bool property LimitedStrip auto hidden
bool property RestrictSameSex auto hidden
bool property AdjustTargetStage auto hidden
bool property ShowInMap auto hidden
bool property DisableTeleport auto hidden
bool property DisableScale auto hidden
bool property UndressAnimation auto hidden

; Integers
int property AskBed auto hidden
int property NPCBed auto hidden
int property OpenMouthSize auto hidden
int property UseFade auto hidden
int property Backwards auto hidden
int property AdjustStage auto hidden
int property AdvanceAnimation auto hidden
int property ChangeAnimation auto hidden
int property ChangePositions auto hidden
int property AdjustChange auto hidden
int property AdjustForward auto hidden
int property AdjustSideways auto hidden
int property AdjustUpward auto hidden
int property RealignActors auto hidden
int property MoveScene auto hidden
int property RestoreOffsets auto hidden
int property RotateScene auto hidden
int property EndAnimation auto hidden
int property ToggleFreeCamera auto hidden
int property TargetActor auto hidden
int property AdjustSchlong auto hidden

; Floats
float property CumTimer auto hidden
float property ShakeStrength auto hidden
float property AutoSUCSM auto hidden
float property MaleVoiceDelay auto hidden
float property FemaleVoiceDelay auto hidden
float property ExpressionDelay auto hidden
float property VoiceVolume auto hidden
float property SFXDelay auto hidden
float property SFXVolume auto hidden

; Int Arrays
int[] Property iStripForms Auto Hidden  ;  0b[Weapon][Gender][Leadin || Submissive][Aggressive]

; Float Array
float[] Property fTimers Auto Hidden    ; 5x3 Matrix / [Stage] x [Type]
float[] property OpenMouthMale auto hidden
float[] property OpenMouthFemale auto hidden
float[] property BedOffset auto hidden

; Compatibility checks
bool property HasSchlongs auto hidden
bool property HasMFGFix auto hidden

; Data
int property LipsPhoneme auto hidden
bool property LipsFixedValue auto hidden
int property LipsMinValue auto hidden
int property LipsMaxValue auto hidden
int property LipsSoundTime auto hidden
float property LipsMoveTime auto hidden

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

int[] Function GetStripSettings(bool IsFemale, bool IsLeadIn = false, bool IsAggressive = false, bool IsVictim = false)
  int idx
  If(IsAggressive)
    idx = (Math.LeftShift(IsVictim as int, 1) + 4) * 2
  Else
    idx = ((IsFemale as int) + Math.LeftShift(IsLeadIn as int, 1)) * 2
  EndIf
  int[] ret = new int[2]
  ret[0] = iStripForms[idx]
  ret[1] = iStripForms[idx + 1]
  return ret
EndFunction

float[] function GetOpenMouthPhonemes(bool isFemale)
  float[] Phonemes = new float[16]
  int i = 16
  while i > 0
    i -= 1
    if isFemale
      Phonemes[i] = OpenMouthFemale[i]
    else
      Phonemes[i] = OpenMouthMale[i]
    endIf
  endWhile
  return Phonemes
endFunction

bool function SetOpenMouthPhonemes(bool isFemale, float[] Phonemes)
  if Phonemes.Length < 16
    return false
  endIf
  if OpenMouthFemale.Length < 16
    OpenMouthFemale = new float[17]
  endIf
  if OpenMouthMale.Length < 16
    OpenMouthMale = new float[17]
  endIf
  int i = 16
  while i > 0
    i -= 1
    if isFemale
      OpenMouthFemale[i] = PapyrusUtil.ClampFloat(Phonemes[i], 0.0, 1.0)
    else
      OpenMouthMale[i] = PapyrusUtil.ClampFloat(Phonemes[i], 0.0, 1.0)
    endIf
  endWhile
  return true
endFunction

bool function SetOpenMouthPhoneme(bool isFemale, int id, float value)
  if id < 0 || id > 15 
    return false
  endIf
  if isFemale
    if OpenMouthFemale.Length < 16
      OpenMouthFemale = new float[17]
    endIf
    OpenMouthFemale[id] = PapyrusUtil.ClampFloat(value, 0.0, 1.0)
  else
    if OpenMouthMale.Length < 16
      OpenMouthMale = new float[17]
    endIf
    OpenMouthMale[id] = PapyrusUtil.ClampFloat(value, 0.0, 1.0)
  endIf
  return true
endFunction

int function GetOpenMouthExpression(bool isFemale)
  if isFemale
    if OpenMouthFemale.Length >= 17 && OpenMouthFemale[16] >= 0.0 && OpenMouthFemale[16] <= 16.0
      return OpenMouthFemale[16] as int
    endIf
  else
    if OpenMouthMale.Length >= 17 && OpenMouthMale[16] >= 0.0 && OpenMouthMale[16] <= 16.0
      return OpenMouthMale[16] as int
    endIf
  endIf
  return 16
endFunction

bool function SetOpenMouthExpression(bool isFemale, int value)
  if isFemale
    if OpenMouthFemale.Length < 17
      OpenMouthFemale = new float[17]
    endIf
    OpenMouthFemale[16] = PapyrusUtil.ClampInt(value, 0, 16) as Float
    return true
  else
    if OpenMouthMale.Length < 17
      OpenMouthMale = new float[17]
    endIf
    OpenMouthMale[16] = PapyrusUtil.ClampInt(value, 0, 16) as Float
    return true
  endIf
  return false
endFunction

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
; --- Hotkeys & TargetRef                             --- ;
; ------------------------------------------------------- ;

Actor _CrosshairRef
Actor Property TargetRef Auto Hidden

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
  ElseIf (keyCode == EndAnimation && BackwardsPressed())
    ThreadSlots.StopAll()
  EndIf
EndEvent

Function SetTargetActor()
  If (!_CrosshairRef)
    return
  EndIf
  TargetRef = _CrosshairRef
  SelectedSpell.Cast(TargetRef, TargetRef)
  Debug.Notification("SexLab Target Selected: " + TargetRef.GetLeveledActorBase().GetName())
  ; Give them stats if they need it
  Stats.SeedActor(TargetRef)
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

Function GetThreadControl(sslThreadController TargetThread)
  If (!TargetThread || _ActiveControl || TargetThread.GetStatus() != TargetThread.STATUS_INSCENE)
    Log("Cannot get Control of " + TargetThread + ", another thread is already being controlled or given thread is not animating/none")
    return
  EndIf
  Log("Taking control over thread: " + TargetThread)
  _ActiveControl = TargetThread
  ; Lock players movement iff they arent owned by the thread
  If (!_ActiveControl.HasPlayer)
    PlayerRef.StopCombat()
    if PlayerRef.IsWeaponDrawn()
      PlayerRef.SheatheWeapon()
    endIf
    Game.SetPlayerAIDriven()
  EndIf
  ; Give player control
  _ActiveControl.AutoAdvance = false
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
  If (_ActiveControl.HasPlayer)
    Game.SetPlayerAIDriven(false)
  EndIf
  _ActiveControl = none
Endfunction

; ------------------------------------------------------- ;
; --- Thread Hooks                                    --- ;
; ------------------------------------------------------- ;

SexLabThreadHook[] _Hooks
int Property HOOKID_STARTING     = 0 AutoReadOnly
int Property HOOKID_STAGESTART   = 1 AutoReadOnly
int Property HOOKID_STAGEEND     = 2 AutoReadOnly
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

bool function SetAdjustmentProfile(string ProfileName) global native
bool function SaveAdjustmentProfile() global native

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

  elseIf CheckSystem == "SexLabUtil"
    return SexLabUtil.GetPluginVersion() >= 16300

  elseIf CheckSystem == "PapyrusUtil"
    return PapyrusUtil.GetVersion() >= 39

  elseIf CheckSystem == "FNIS"
    return FNIS.VersionCompare(7, 0, 0) >= 0

  elseIf CheckSystem == "FNISGenerated"
    return FNIS.IsGenerated()

  elseIf CheckSystem == "FNISCreaturePack"
    return FNIS.VersionCompare(7, 0, 0, true) >= 0

  elseIf CheckSystem == "FNISSexLabFramework" && PlayerRef.Is3DLoaded() && Game.GetCameraState() > 3
    return PlayerRef.GetAnimationVariableInt("SexLabFramework") >= 16000

  elseIf CheckSystem == "FNISSexLabCreature" && PlayerRef.Is3DLoaded() && Game.GetCameraState() > 3
    return PlayerRef.GetAnimationVariableInt("SexLabCreature") >= 16000

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
  elseIf !CheckSystemPart("SexLabUtil")
    CheckSexLabUtil.Show()
    return false
  elseIf !CheckSystemPart("PapyrusUtil")
    CheckPapyrusUtil.Show(4.4)
    return false
  endIf
  return true
endFunction

function Reload()
  ; DebugMode = true
  if DebugMode
    Debug.OpenUserLog("SexLabDebug")
    Debug.TraceUser("SexLabDebug", "Config Reloading...")
  endIf

  LoadLibs(false)
  SexLab = SexLabUtil.GetAPI()

  ; SetVehicle Scaling Fix
	; NOTE: Trying new placement function that doesnt rely on SetVehicle, "fix" may become redundant
  ; SexLabUtil.VehicleFixMode((DisableScale as int))

  ; Configure SFX & Voice volumes
  AudioVoice.SetVolume(VoiceVolume)
  AudioSFX.SetVolume(SFXVolume)

  ; Remove any targeted actors
  RegisterForCrosshairRef()
  _CrosshairRef = none
  TargetRef    = none

  ; TFC Toggle key
  UnregisterForAllKeys()
  RegisterForKey(ToggleFreeCamera)
  RegisterForKey(TargetActor)
  RegisterForKey(EndAnimation)

  ; Mod compatability checks
  ; - SOS/SAM Schlongs (currently unused)
  HasSchlongs = Game.GetModByName("Schlongs of Skyrim - Core.esm") != 255 || Game.GetModByName("SAM - Shape Atlas for Men.esp") != 255

  ; - MFG Fix check
	; TODO: May need to check another way, some players might get upset that their mfg is reset on load // CHECK FOR DLL INSTEAD
  HasMFGFix = MfgConsoleFunc.ResetPhonemeModifier(PlayerRef)

	; TODO: Fade settings will need an overhaul, and likely have these removed in the process
  if !FadeToBlackHoldImod || FadeToBlackHoldImod == none
    FadeToBlackHoldImod = Game.GetFormFromFile(0xF756E, "Skyrim.esm") as ImageSpaceModifier ;0xF756D **0xF756E 0x10100C** 0xF756F 0xFDC57 0xFDC58 0x 0x 0x
  endIf
  if !FadeToBlurHoldImod || FadeToBlurHoldImod == none
    FadeToBlurHoldImod = Game.GetFormFromFile(0x44F3B, "Skyrim.esm") as ImageSpaceModifier ;0x201D3 0x44F3B **0xFD809 0x1037E2 0x1037E3 0x1037E4 0x1037E5 0x1037E6** 0x
  endIf
  if !ForceBlackVFX || ForceBlackVFX == none
    ForceBlackVFX = Game.GetFormFromFile(0x8FC39, "SexLab.esm") as VisualEffect ;0x44F3A 
  endIf
  if !ForceBlurVFX || ForceBlurVFX == none
    ForceBlurVFX = Game.GetFormFromFile(0x8FC3A, "SexLab.esm") as VisualEffect ;0x101967
  endIf

	; COMEBACK: This is a cot (yes), which wont be recognized by the default funcs
	; Requires special identification
  Form CivilWarCot01L = Game.GetFormFromFile(0xE2826, "Skyrim.esm")
  if CivilWarCot01L && !BedsList.HasForm(CivilWarCot01L)
    BedsList.AddForm(CivilWarCot01L)
  endIf
	; COMEBACK: THis here also isnt recognized by default funcs but behaves as a common bed
  Form WRTempleHealingAltar01 = Game.GetFormFromFile(0xD4848, "Skyrim.esm")
  if WRTempleHealingAltar01 && !BedsList.HasForm(WRTempleHealingAltar01)
    BedsList.AddForm(WRTempleHealingAltar01)
    SetCustomBedOffset(WRTempleHealingAltar01, 0.0, 0.0, 39.0, 90.0)
  endIf

  ; Remove gender override if player's gender matches normally
  if PlayerRef.GetFactionRank(GenderFaction) == PlayerRef.GetLeveledActorBase().GetSex()
    PlayerRef.RemoveFromFaction(GenderFaction)
  endIf

  ; Remove any NPC thread control player has
  DisableThreadControl(_ActiveControl)

  ; Load json animation profile
  ImportProfile(PapyrusUtil.ClampInt(AnimProfile, 1, 5))
endFunction

function Setup()
  parent.Setup()
  SetDefaults()
endFunction

function SetDefaults()
	; TODO: See if this is implemented in .dll
  ; BedOffset = new float[4]
  ; BedOffset[0] = 0.0
  ; BedOffset[2] = 37.0

  ; Reload config
  Reload()

  ; Reset data
  LoadStrapons()

  if !HotkeyUp || HotkeyUp.Length != 3 || HotkeyUp.Find(none) != -1
    HotkeyUp = new Sound[3]
    hotkeyUp[0] = Game.GetFormFromFile(0x8AAF0, "SexLab.esm") as Sound
    hotkeyUp[1] = Game.GetFormFromFile(0x8AAF1, "SexLab.esm") as Sound
    hotkeyUp[2] = Game.GetFormFromFile(0x8AAF2, "SexLab.esm") as Sound
  endIf
  if !HotkeyDown || HotkeyDown.Length != 3 || HotkeyDown.Find(none) != -1
    HotkeyDown = new Sound[3]
    hotkeyDown[0] = Game.GetFormFromFile(0x8AAF3, "SexLab.esm") as Sound
    hotkeyDown[1] = Game.GetFormFromFile(0x8AAF4, "SexLab.esm") as Sound
    hotkeyDown[2] = Game.GetFormFromFile(0x8AAF5, "SexLab.esm") as Sound
  endIf

  ; Rest some player configurations
  if PlayerRef
    Stats.SetSkill(PlayerRef, "Sexuality", 75)
    VoiceSlots.ForgetVoice(PlayerRef)
  endIf
endFunction

; ------------------------------------------------------- ;
; --- Export/Import to JSON                           --- ;
; ------------------------------------------------------- ;

string File
function ExportSettings()
  ; Export object registry
  ExportAnimations()
  ExportCreatures()
  ExportExpressions()
  ExportVoices()
endFunction

function ImportSettings()  
  ; Import object registry
  ImportAnimations()
  ImportCreatures()
  ImportExpressions()
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

; Expressions
function ExportExpressions()
  int i = ExpressionSlots.Slotted
  while i
    i -= 1
    ExpressionSlots.GetBySlot(i).ExportJson()
  endWhile
endfunction
function ImportExpressions()
  int i = ExpressionSlots.Slotted
  while i
    i -= 1
    ExpressionSlots.GetBySlot(i).ImportJson()
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
; --- Misc                                            --- ;
; ------------------------------------------------------- ;

; int[] property ActorTypes auto hidden
function StoreActor(Form FormRef) global
  if FormRef
    StorageUtil.FormListAdd(none, "SexLab.ActorStorage", FormRef, false)
  endIf
endFunction

ImageSpaceModifier FadeEffect
VisualEffect ForceVFX
VisualEffect ForceBlackVFX
VisualEffect ForceBlurVFX
ImageSpaceModifier FadeToBlackHoldImod
ImageSpaceModifier FadeToBlurHoldImod
function RemoveFade(bool forceTest = false)
  if !forceTest && UseFade < 1
    return
  endIf
  if FadeEffect && FadeEffect != none
    bool Black = UseFade % 2 != 0
    If UseFade < 3
      if forceTest
        Utility.WaitMenuMode(5.0)
        if ForceVFX
          ForceVFX.Stop(PlayerRef)
        endIf
        FadeEffect.Remove()
      else
        if ForceVFX
          ForceVFX.Stop(PlayerRef)
        endIf
        ImageSpaceModifier.RemoveCrossFade()
      endIf
    else
      Game.FadeOutGame(false, Black, 0.5, 1.5)
    endIf
    FadeEffect = none
  endIf
endFunction

function ApplyFade(bool forceTest = false)
  if !forceTest && UseFade < 1
    return
  endIf
  if FadeEffect && FadeEffect != none
    FadeEffect.Remove()
  endIf
  FadeEffect = none
  bool Black
  if UseFade % 2 != 0
    if FadeToBlackHoldImod && FadeToBlackHoldImod != none
      FadeEffect = FadeToBlackHoldImod
      Black = True
    endIf
  else
    if FadeToBlurHoldImod && FadeToBlurHoldImod != none
      FadeEffect = FadeToBlurHoldImod
      Black = False
    endIf
  endIf
  if FadeEffect && FadeEffect != none
    If UseFade < 3
      if forceTest
        FadeEffect.Apply()
      else
        FadeEffect.ApplyCrossFade()
      endIf
      if Black && ForceBlackVFX
        ForceVFX = ForceBlackVFX
      elseIf !Black && ForceBlurVFX
        ForceVFX = ForceBlurVFX
      endIf
      if ForceVFX
        ForceVFX.Play(PlayerRef)
      endIf
    else
      Game.FadeOutGame(true, Black, 0.5, 3.0)
    endIf
  endIf
endFunction

event OnInit()
  parent.OnInit()
  SetDefaults()
endEvent


; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;                ██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗              ;
;                ██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝              ;
;                ██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝               ;
;                ██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝                ;
;                ███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║                 ;
;                ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝                 ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

GlobalVariable property DebugVar1 auto
GlobalVariable property DebugVar2 auto
GlobalVariable property DebugVar3 auto
GlobalVariable property DebugVar4 auto
GlobalVariable property DebugVar5 auto

Actor[] property TargetRefs auto hidden

bool property HasFrostfall
  bool Function Get()
    return Game.GetModByName("Frostfall.esp") != 255
  EndFunction
  Function Set(bool aSet)
  EndFunction
EndProperty

FormList property FrostExceptions
  FormList Function Get()
    If (HasFrostfall)
      return Game.GetFormFromFile(0x6E7E6, "Frostfall.esp") as FormList
    EndIf
    return none
  EndFunction
  Function Set(FormList aSet)
  EndFunction
EndProperty

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

float property LeadInCoolDown = 0.0 auto hidden

; COMEBACK: Re-implement?
bool property RaceAdjustments = false auto hidden    ; this and v is used for ActorKey scale profile settings
bool property ScaleActors = false auto hidden
int property AnimProfile = 1 auto hidden

; TODO: This has special behavior to return "OrgasmBehavior == EXTERN"
bool property SeparateOrgasms = false auto hidden

; ------------------------------------------------------- ;
; --- Functions                                       --- ;
; ------------------------------------------------------- ;

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

bool property HasNiOverride
  bool Function Get()
    return SKSE.GetPluginVersion("SKEE64") >= 7 || NiOverride.GetScriptVersion() >= 7
  EndFUnction
  Function Set(bool aSet)
  EndFunction
EndProperty
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
  LogRedundant("GetRheadHooks")
  return new sslThreadHook[1]
endFunction
int function GetThreadHookCount()
  LogRedundant("GetThreadHookCount")
  return 0
endFunction

function InitThreadHooks()
endFunction

bool Function HasCreatureInstall()
  return FNIS.GetMajor(true) > 0
EndFunction

function ReloadData()
  ; ActorTypeNPC =            Game.GetForm(0x13794)
  ; AnimatingFaction =        Game.GetFormFromFile(0xE50F, "SexLab.esm")
  ; AudioSFX =                Game.GetFormFromFile(0x61428, "SexLab.esm")
  ; AudioVoice =              Game.GetFormFromFile(0x61429, "SexLab.esm")
  ; BaseMarker =              Game.GetFormFromFile(0x45A93 "SexLab.esm")
  ; BedRollsList =            Game.GetFormFromFile(0x6198C, "SexLab.esm")
  ; BedsList =                Game.GetFormFromFile(0x181B1, "SexLab.esm")
  ; CalypsStrapon =           Game.GetFormFromFile(0x1A22A, "SexLab.esm")
  ; CheckFNIS =               Game.GetFormFromFile(0x70C38, "SexLab.esm")
  ; CheckPapyrusUtil =        Game.GetFormFromFile(0x70C3B, "SexLab.esm")
  ; CheckSKSE =               Game.GetFormFromFile(0x70C39, "SexLab.esm")
  ; CheckSkyrim =             Game.GetFormFromFile(0x70C3A, "SexLab.esm")
  ; CheckSkyUI =              Game.GetFormFromFile(0x70C3C, "SexLab.esm")
  ; CleanSystemFinish =       Game.GetFormFromFile(0x6CB9E, "SexLab.esm")
  ; CumAnalKeyword =          Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumAnalSpell =            Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumOralAnalSpell =        Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumOralKeyword =          Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumOralSpell =            Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumVaginalAnalSpell =     Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumVaginalKeyword =       Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumVaginalOralAnalSpell = Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumVaginalOralSpell =     Game.GetFormFromFile(0x, "SexLab.esm")
  ; CumVaginalSpell =         Game.GetFormFromFile(0x, "SexLab.esm")
  ; DoNothing =               Game.GetFormFromFile(0x, "SexLab.esm")
  ; DummyWeapon =             Game.GetFormFromFile(0x, "SexLab.esm")
  ; ForbiddenFaction =        Game.GetFormFromFile(0x, "SexLab.esm")
  ; GenderFaction =           Game.GetFormFromFile(0x, "SexLab.esm")
  ; LipSync =                 Game.GetFormFromFile(0x, "SexLab.esm")
  ; LocationMarker =          Game.GetFormFromFile(0x, "SexLab.esm")
  ; NudeSuit =                Game.GetFormFromFile(0x, "SexLab.esm")
  ; OrgasmFX =                Game.GetFormFromFile(0x, "SexLab.esm")
  ; SexLabVoiceF =            Game.GetFormFromFile(0x, "SexLab.esm")
  ; SexLabVoiceM =            Game.GetFormFromFile(0x, "SexLab.esm")
  ; SexMixedFX =              Game.GetFormFromFile(0x, "SexLab.esm")
  ; SquishingFX =             Game.GetFormFromFile(0x, "SexLab.esm")
  ; SuckingFX =               Game.GetFormFromFile(0x, "SexLab.esm")
  ; UseBed =                  Game.GetFormFromFile(0x, "SexLab.esm")
  ; VoicesPlayer =            Game.GetFormFromFile(0x, "SexLab.esm")
endFunction

; ------------------------------------------------------- ;
; --- Pre P2.0 Config Accessors                       --- ;
; ------------------------------------------------------- ;

bool[] function GetStrip(bool IsFemale, bool IsLeadIn = false, bool IsAggressive = false, bool IsVictim = false)
  int idx = (IsFemale as int + Math.LeftShift((IsLeadIn || !IsVictim) as int, 1) + Math.LeftShift(IsAggressive as int, 2)) * 2
  return sslUtility.BitsToBool(iStripForms[idx], iStripForms[idx + 1])
endFunction

bool[] property StripMale
  bool[] Function Get()
    return GetStrip(false, false, false, false)
  EndFunction
EndProperty
bool[] property StripFemale
  bool[] Function Get()
    return GetStrip(true, false, false, false)
  EndFunction
EndProperty
bool[] property StripLeadInMale
  bool[] Function Get()
    return GetStrip(false, true, false, false)
  EndFunction
EndProperty
bool[] property StripLeadInFemale
  bool[] Function Get()
    return GetStrip(true, true, false, false)
  EndFunction
EndProperty
bool[] property StripVictim
  bool[] Function Get()
    return GetStrip(false, false, true, true)
  EndFunction
EndProperty
bool[] property StripAggressor
  bool[] Function Get()
    return GetStrip(false, false, true, false)
  EndFunction
EndProperty

float[] property StageTimer
  float[] Function Get()
    float[] ret = new float[5]
    ret[0] = fTimers[0]
    ret[1] = fTimers[1]
    ret[2] = fTimers[2]
    ret[3] = fTimers[3]
    ret[4] = fTimers[4]
    return ret
  EndFunction
EndProperty
float[] property StageTimerLeadIn
  float[] Function Get()
    float[] ret = new float[5]
    ret[0] = fTimers[5]
    ret[1] = fTimers[6]
    ret[2] = fTimers[7]
    ret[3] = fTimers[8]
    ret[4] = fTimers[9]
    return ret
  EndFunction
EndProperty
float[] property StageTimerAggr
  float[] Function Get()
    float[] ret = new float[5]
    ret[0] = fTimers[10]
    ret[1] = fTimers[11]
    ret[2] = fTimers[12]
    ret[3] = fTimers[13]
    ret[4] = fTimers[14]
    return ret
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
