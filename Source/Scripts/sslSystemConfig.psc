scriptname sslSystemConfig extends sslSystemLibrary
{
	User Config Storage
}

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

bool _DebugMode
bool Property DebugMode hidden
	bool Function Get()
		return _DebugMode
	EndFunction
	Function Set(bool abValue)
		_DebugMode = abValue
		If(_DebugMode)
			Debug.OpenUserLog("SexLabDebug")
			Debug.TraceUser("SexLabDebug", "SexLab Debug/Development Mode Deactivated")
			MiscUtil.PrintConsole("SexLab Debug/Development Mode Activated")
			PlayerRef.AddSpell((Game.GetFormFromFile(0x073CC, "SexLab.esm") as Spell))
			PlayerRef.AddSpell((Game.GetFormFromFile(0x5FE9B, "SexLab.esm") as Spell))
		Else
			If(Debug.TraceUser("SexLabDebug", "SexLab Debug/Development Mode Deactivated"))
				Debug.CloseUserLog("SexLabDebug")
			EndIf
			MiscUtil.PrintConsole("SexLab Debug/Development Mode Deactivated")
			PlayerRef.RemoveSpell((Game.GetFormFromFile(0x073CC, "SexLab.esm") as Spell))
			PlayerRef.RemoveSpell((Game.GetFormFromFile(0x5FE9B, "SexLab.esm") as Spell))
		EndIf
	EndFunction
EndProperty


Faction property AnimatingFaction auto
Faction property GenderFaction auto
Armor property CalypsStrapon auto
Form[] property Strapons auto hidden

Spell property SelectedSpell auto

Keyword property ActorTypeNPC auto

Sound property OrgasmFX auto
Sound property SquishingFX auto
Sound property SuckingFX auto
Sound property SexMixedFX auto

Sound[] property HotkeyUp auto
Sound[] property HotkeyDown auto

FormList property BedsList auto
FormList property BedRollsList auto
FormList property DoubleBedsList auto
Message property CleanSystemFinish auto
Message property CheckSKSE auto
Message property CheckFNIS auto
Message property CheckSkyrim auto
Message property CheckSexLabUtil auto
Message property CheckPapyrusUtil auto
Message property CheckSkyUI auto
Message property TakeThreadControl auto

Topic property LipSync auto		; only Accessed in sslBaseVoice, probably want to remove this from here
SoundCategory property AudioSFX auto
SoundCategory property AudioVoice auto

; ------------------------------------------------------- ;
; --- Config Properties                               --- ;
; ------------------------------------------------------- ;

; Installation
bool Property bInstallDefaults Auto Hidden
bool Property bInstallDefaultsCrt Auto Hidden

; Booleans
bool property RestrictAggressive auto hidden
bool property AllowCreatures auto hidden
bool property UseCreatureGender auto hidden
bool property NPCSaveVoice auto hidden
bool property UseStrapons auto hidden
bool property RedressVictim auto hidden
bool property UndressAnimation auto hidden
bool property UseLipSync auto hidden
bool property UseExpressions auto hidden
bool property RefreshExpressions auto hidden
bool property ScaleActors auto hidden
bool property UseCum auto hidden
bool property AllowFFCum auto hidden
bool property DisablePlayer auto hidden
bool property AutoTFC auto hidden
bool property AutoAdvance auto hidden
bool property ForeplayStage auto hidden
bool property OrgasmEffects auto hidden
bool property RaceAdjustments auto hidden
bool property BedRemoveStanding auto hidden
bool property LimitedStrip auto hidden
bool property RestrictSameSex auto hidden
bool property SeparateOrgasms auto hidden
bool property RemoveHeelEffect auto hidden
bool property AdjustTargetStage auto hidden
bool property ShowInMap auto hidden
bool property DisableTeleport auto hidden
bool property SeedNPCStats auto hidden
bool property DisableScale auto hidden

; Integers
int property AnimProfile auto hidden
int property AskBed auto hidden
int property NPCBed auto hidden
int property OpenMouthSize auto hidden
int property UseFade auto hidden

int property Backwards auto hidden
int property AdjustStage auto hidden
int property AdvanceAnimation auto hidden
int property ChangeAnimation auto hidden
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
int property ChangePositions auto hidden

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
float property LeadInCoolDown auto hidden

; Int Arrays
int[] Property iStripForms Auto Hidden	;	0b[Weapon][Gender][Leadin || Submissive][Aggressive]

; Float Array
float[] Property fTimers Auto Hidden		; 5x3 Matrix / [Stage] x [Type]
float[] property OpenMouthMale auto hidden
float[] property OpenMouthFemale auto hidden
float[] property BedOffset auto hidden

; Compatibility checks
bool property HasHDTHeels auto hidden
bool property HasNiOverride auto hidden
bool property HasFrostfall auto hidden
bool property HasSchlongs auto hidden
bool property HasMFGFix auto hidden

FormList property FrostExceptions auto hidden
MagicEffect HDTHeelEffect

; Data
Actor CrosshairRef
Actor property TargetRef auto hidden
Actor[] property TargetRefs auto hidden

int HookCount
bool HooksInit
sslThreadHook[] ThreadHooks

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

bool function HasCreatureInstall()
	return FNIS.GetMajor(true) > 0 && (Game.GetCameraState() < 8 || PlayerRef.GetAnimationVariableInt("SexLabCreature") > 0)
endFunction

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
	; For some reason with the old function if you change the value of the variable with the returned BedOffset Array the value also change on the original BedOffset
	while i > 0
		i -= 1
		Offsets[i] = BedOffset[i]
	endWhile
	return Offsets
endFunction

; ------------------------------------------------------- ;
; --- Strapon Functions                               --- ;
; ------------------------------------------------------- ;

Form function GetStrapon()
	if Strapons.Length > 0
		return Strapons[Utility.RandomInt(0, (Strapons.Length - 1))]
	endIf
	return none
endFunction

Form function WornStrapon(Actor ActorRef)
	int i = Strapons.Length
	while i
		i -= 1
		if ActorRef.GetItemCount(Strapons[i]) > 0
			return Strapons[i]
		endIf
	endWhile
	return none
endFunction

bool function HasStrapon(Actor ActorRef)
	return WornStrapon(ActorRef) != none
endFunction

Form function PickStrapon(Actor ActorRef)
	form Strapon = WornStrapon(ActorRef)
	if Strapon
		return Strapon
	endIf
	return GetStrapon()
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

function LoadStrapons()
	Strapons = new form[1]
	Strapons[0] = CalypsStrapon

	if Game.GetModByName("StrapOnbyaeonv1.1.esp") != 255
		LoadStrapon("StrapOnbyaeonv1.1.esp", 0x0D65)
	endIf
	if Game.GetModByName("TG.esp") != 255
		LoadStrapon("TG.esp", 0x0182B)
	endIf
	if Game.GetModByName("Futa equippable.esp") != 255
		LoadStrapon("Futa equippable.esp", 0x0D66)
		LoadStrapon("Futa equippable.esp", 0x0D67)
		LoadStrapon("Futa equippable.esp", 0x01D96)
		LoadStrapon("Futa equippable.esp", 0x022FB)
		LoadStrapon("Futa equippable.esp", 0x022FC)
		LoadStrapon("Futa equippable.esp", 0x022FD)
	endIf
	if Game.GetModByName("Skyrim_Strap_Ons.esp") != 255
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x00D65)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x02859)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285A)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285B)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285C)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285D)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285E)
		LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285F)
	endIf
	if Game.GetModByName("SOS Equipable Schlong.esp") != 255
		LoadStrapon("SOS Equipable Schlong.esp", 0x0D62)
	endIf
	ModEvent.Send(ModEvent.Create("SexLabLoadStrapons"))
endFunction

Armor function LoadStrapon(string esp, int id)
	Form Strapon = Game.GetFormFromFile(id, esp)
	if Strapon && (Strapon as Armor)
		Strapons = PapyrusUtil.PushForm(Strapons, Strapon)
	endif
	return Strapon as Armor
endFunction

; ------------------------------------------------------- ;
; --- Hotkeys                                         --- ;
; ------------------------------------------------------- ;

sslThreadController Control
sslThreadController Function GetThreadControlled()
	return Control
EndFunction

event OnKeyDown(int keyCode)
	if !Utility.IsInMenuMode() && !UI.IsMenuOpen("Console") && !UI.IsMenuOpen("Loading Menu")
		if keyCode == ToggleFreeCamera
			ToggleFreeCamera()
		elseIf keyCode == TargetActor
			if Control
				DisableThreadControl(Control)
			else
				SetTargetActor()
			endIf
		elseIf keyCode == EndAnimation && BackwardsPressed()
			ThreadSlots.StopAll()
		endIf
	endIf
endEvent

event OnCrosshairRefChange(ObjectReference ActorRef)
	CrosshairRef = ActorRef as Actor
endEvent

function SetTargetActor()
	if CrosshairRef
		TargetRef = CrosshairRef
		SelectedSpell.Cast(TargetRef, TargetRef)
		Debug.Notification("SexLab Target Selected: "+TargetRef.GetLeveledActorBase().GetName())
		; Give them stats if they need it
		Stats.SeedActor(TargetRef)
		; Attempt to grab control of their animation?
		sslThreadController TargetThread = ThreadSlots.GetActorController(TargetRef)
		if TargetThread && !TargetThread.HasPlayer && (TargetThread.GetState() == "Animating" || TargetThread.GetState() == "Advancing")
			sslThreadController PlayerThread = ThreadSlots.GetActorController(PlayerRef)
			if (!PlayerThread || !(PlayerThread.GetState() == "Animating" || PlayerThread.GetState() == "Advancing")) && TakeThreadControl.Show()
				if PlayerThread != none
					ThreadSlots.StopThread(PlayerThread)
				endIf
				GetThreadControl(TargetThread) 
			endIf
		endIf
	endif
endFunction

function AddTargetActor(Actor ActorRef)
	if ActorRef
		if TargetRefs.Find(ActorRef) != -1
			TargetRefs[TargetRefs.Find(ActorRef)] = none
		endIf
		TargetRefs[4] = TargetRefs[3]
		TargetRefs[3] = TargetRefs[2]
		TargetRefs[2] = TargetRefs[1]
		TargetRefs[1] = TargetRefs[0]
		TargetRefs[0] = ActorRef
	endIf
endFunction

function GetThreadControl(sslThreadController TargetThread)
	if Control || !(TargetThread.GetState() == "Animating" || TargetThread.GetState() == "Advancing")
		Log("Failed to control thread "+TargetThread)
		return
	endIf
	Control = TargetThread
	if !Control || Control == none
		Log("Failed to control thread "+TargetThread)
		return
	endIf
	; Lock players movement
	PlayerRef.StopCombat()
	if PlayerRef.IsWeaponDrawn()
		PlayerRef.SheatheWeapon()
	endIf
	PlayerRef.SetFactionRank(AnimatingFaction, 1)
	Game.SetPlayerAIDriven()
	; Give player control
	Control.AutoAdvance = false
	Control.EnableHotkeys(true)
	Log("Player has taken control of thread "+Control)
endFunction

function DisableThreadControl(sslThreadController TargetThread)
	if Control && Control == TargetThread
		; Release players thread control
		MiscUtil.SetFreeCameraState(false)
		if Game.GetCameraState() == 0
			Game.ForceThirdPerson()
		endIf
		Control.DisableHotkeys()
		Control.AutoAdvance = true
		Control = none
		; Unlock players movement
		PlayerRef.RemoveFromFaction(AnimatingFaction)
		Game.SetPlayerAIDriven(false)
	endIf
endfunction

function ToggleFreeCamera()
	if Game.GetCameraState() != 3
		MiscUtil.SetFreeCameraSpeed(AutoSUCSM)
	endIf
	MiscUtil.ToggleFreeCamera()
endFunction

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
	if !ActorRef
		return false
	elseIf RemoveFromAudience
		return BystanderClear(ActorRef, BardBystander1) || BystanderClear(ActorRef, BardBystander2) || BystanderClear(ActorRef, BardBystander3) \
			|| BystanderClear(ActorRef, BardBystander4) || BystanderClear(ActorRef, BardBystander5)
	else
		return ActorRef == BardBystander1.GetReference() || ActorRef == BardBystander2.GetReference() || ActorRef == BardBystander3.GetReference() \
			|| ActorRef == BardBystander4.GetReference() || ActorRef == BardBystander5.GetReference()
	endIf
endFunction

bool function BystanderClear(Actor ActorRef, ReferenceAlias BardBystander)
	if ActorRef == BardBystander.GetReference()
		BardBystander.Clear()
		ActorRef.EvaluatePackage()
		Log("Cleared from bard audience", "CheckBardAudience("+ActorRef+")")
		return true
	endIf
	return false
endFunction

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

	elseIf CheckSystem == "NiOverride"
		return SKSE.GetPluginVersion("SKEE64") >= 7 || NiOverride.GetScriptVersion() >= 7 ;SSE

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
	; Check Skyrim Version
	if !CheckSystemPart("Skyrim")
		CheckSkyrim.Show(1.6)
		return false
	; Check SKSE install
	elseIf !CheckSystemPart("SKSE")
		CheckSKSE.Show(2.22)
		return false
	; Check SkyUI install - depends on passing SKSE check passing
	elseIf !CheckSystemPart("SkyUI")
		CheckSkyUI.Show(5.2)
		return false
	; Check SexLabUtil install - this should never happen if they have properly updated
	elseIf !CheckSystemPart("SexLabUtil")
		CheckSexLabUtil.Show()
		return false
	; Check PapyrusUtil install - depends on passing SKSE check passing
	elseIf !CheckSystemPart("PapyrusUtil")
		CheckPapyrusUtil.Show(4.4)
		return false
	; Check FNIS generation - soft fail
	; elseIf CheckSystemPart("FNISSexLabFramework")
		; CheckFNIS.Show()
	endIf
	; Return result
	return true
endFunction

function Reload()
	if DebugMode
		Debug.OpenUserLog("SexLabDebug")
		Debug.TraceUser("SexLabDebug", "Config Reloading...")
	endIf

	; LoadLibs(false)
	; SexLab = SexLabUtil.GetAPI()

	; SetVehicle Scaling Fix
	; SexLabUtil.VehicleFixMode((DisableScale as int))

	; Configure SFX & Voice volumes
	AudioVoice.SetVolume(VoiceVolume)
	AudioSFX.SetVolume(SFXVolume)

	; Remove any targeted actors
	RegisterForCrosshairRef()
	CrosshairRef = none
	TargetRef    = none

	; TFC Toggle key
	UnregisterForAllKeys()
	RegisterForKey(ToggleFreeCamera)
	RegisterForKey(TargetActor)
	RegisterForKey(EndAnimation)

	; Mod compatability checks
	HasNiOverride = Config.CheckSystemPart("NiOverride")
	HasHDTHeels   = Game.GetModByName("hdtHighHeel.esm") != 255
	if HasHDTHeels && !HDTHeelEffect
		HDTHeelEffect = Game.GetFormFromFile(0x800, "hdtHighHeel.esm") as MagicEffect
	endIf
	HasFrostfall = Game.GetModByName("Frostfall.esp") != 255
	if HasFrostfall && !FrostExceptions
		FrostExceptions = Game.GetFormFromFile(0x6E7E6, "Frostfall.esp") as FormList
	endIf
	HasSchlongs = Game.GetModByName("Schlongs of Skyrim - Core.esm") != 255
	HasMFGFix = SKSE.GetPluginVersion("mfgfix") > -1

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

	; TODO: confirm forms are the same in SSE
	if GetBedOffsets(Game.GetFormFromFile(0xB8371, "Skyrim.esm"))[3] != 180.0
		SetCustomBedOffset(Game.GetFormFromFile(0xB8371, "Skyrim.esm"), 0.0, 0.0, 0.0, 180.0) 	; BedRoll Ground
	endIf
	Form DA02Altar = Game.GetFormFromFile(0x5ED79, "Skyrim.esm")
	if DA02Altar && !BedsList.HasForm(DA02Altar)
		BedsList.AddForm(DA02Altar)
		BedRollsList.AddForm(DA02Altar)
	endIf
	Form CivilWarCot01L = Game.GetFormFromFile(0xE2826, "Skyrim.esm")
	if CivilWarCot01L && !BedsList.HasForm(CivilWarCot01L)
		BedsList.AddForm(CivilWarCot01L)
	endIf
	Form WRTempleHealingAltar01 = Game.GetFormFromFile(0xD4848, "Skyrim.esm")
	if WRTempleHealingAltar01 && !BedsList.HasForm(WRTempleHealingAltar01)
		BedsList.AddForm(WRTempleHealingAltar01)
		SetCustomBedOffset(WRTempleHealingAltar01, 0.0, 0.0, 39.0, 90.0)
	endIf
	Form HHFurnitureBedSingle01 = Game.GetFormFromFile(0x2FBC7, "Skyrim.esm")
	if HHFurnitureBedSingle01 && !BedsList.HasForm(HHFurnitureBedSingle01)
		BedsList.AddForm(HHFurnitureBedSingle01)
	endIf
	
	; Dawnguard additions
	if Game.GetModByName("Dawnguard.esm") != 255
		; Bedroll
		Form DLC1BedrollGroundF = Game.GetFormFromFile(0xC651, "Dawnguard.esm")
		if DLC1BedrollGroundF && !BedsList.HasForm(DLC1BedrollGroundF)
			BedsList.AddForm(DLC1BedrollGroundF)
			BedRollsList.AddForm(DLC1BedrollGroundF)
			SetCustomBedOffset(DLC1BedrollGroundF, 0.0, 0.0, 0.0, 180.0)
		endIf
	endIf

	; Remove gender override if player's gender matches normally
	if PlayerRef.GetFactionRank(GenderFaction) == PlayerRef.GetLeveledActorBase().GetSex()
		PlayerRef.RemoveFromFaction(GenderFaction)
	endIf

	; Remove any NPC thread control player has
	DisableThreadControl(Control)

	; Load json animation profile
	ImportProfile(PapyrusUtil.ClampInt(AnimProfile, 1, 5))

	; Init Thread Hooks
	if !HooksInit
		InitThreadHooks()
	endIf
endFunction

function InitThreadHooks()
	HookCount = 0
	ThreadHooks = new sslThreadHook[64]
	HooksInit = true
endFunction

int function RegisterThreadHook(sslThreadHook Hook)
	if !Hook
		Log("RegisterThreadHook("+Hook+") - INVALID HOOK")
		return -1
	elseIf !HooksInit
		InitThreadHooks()
	elseIf HookCount >= 64
		Log("RegisterThreadHook("+Hook+") - FAILED TO REGISTER, AT CAPACITY")
		return -1
	endIf

	; Find current index
	int idx = ThreadHooks.Find(Hook)

	; Add new hook
	if idx == -1
		idx = ThreadHooks.Find(none)
		ThreadHooks[idx] = Hook
	endIf

	; Update counter if higher than current saved count
	if (idx + 1) > HookCount
		HookCount = (idx + 1)
	endIf 

	Log("RegisterThreadHook("+Hook+") - Registered hook at ["+idx+"/"+HookCount+"]")

	; TODO: Should probably add better error handling incase count ever exceeds 64, but very unlikely.

	return ThreadHooks.Find(Hook)
endFunction

sslThreadHook[] function GetThreadHooks()
	return ThreadHooks
endFunction
int function GetThreadHookCount()
	return HookCount
endFunction

function Setup()
	parent.Setup()
	SetDefaults()
endFunction

function SetDefaults()
	DebugMode = false
	; Reload config
	Reload()
	; Reset data
	LoadStrapons()
	if HotkeyUp.Length != 3 || HotkeyUp.Find(none) != -1
		HotkeyUp = new Sound[3]
		hotkeyUp[0] = Game.GetFormFromFile(0x8AAF0, "SexLab.esm") as Sound
		hotkeyUp[1] = Game.GetFormFromFile(0x8AAF1, "SexLab.esm") as Sound
		hotkeyUp[2] = Game.GetFormFromFile(0x8AAF2, "SexLab.esm") as Sound
	endIf
	if HotkeyDown.Length != 3 || HotkeyDown.Find(none) != -1
		HotkeyDown = new Sound[3]
		hotkeyDown[0] = Game.GetFormFromFile(0x8AAF3, "SexLab.esm") as Sound
		hotkeyDown[1] = Game.GetFormFromFile(0x8AAF4, "SexLab.esm") as Sound
		hotkeyDown[2] = Game.GetFormFromFile(0x8AAF5, "SexLab.esm") as Sound
	endIf

	; Rest some player configurations
	if PlayerRef && PlayerRef != none
		Stats.SetSkill(PlayerRef, "Sexuality", 75)
		VoiceSlots.ForgetVoice(PlayerRef)
	endIf
endFunction

; ------------------------------------------------------- ;
; --- Export/Import to JSON                           --- ;
; ------------------------------------------------------- ;

string File
function ExportSettings()
	File = "../SexLab/SexlabConfig.json"
	; Set label of export
	JsonUtil.SetStringValue(File, "ExportLabel", PlayerRef.GetLeveledActorBase().GetName()+" - "+Utility.GetCurrentRealTime() as int)
	; Export object registry
	ExportAnimations()
	ExportCreatures()
	ExportExpressions()
	ExportVoices()
	; Save to JSON file
	JsonUtil.Save(File, true)
endFunction

function ImportSettings()
	File = "../SexLab/SexlabConfig.json"
	; Import object registry
	ImportAnimations()
	ImportCreatures()
	ImportExpressions()
	ImportVoices()
	; Reload settings with imported values
	Reload()
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

Event OnInit()
	SetDefaults()
EndEvent

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

bool property RestrictStrapons auto hidden
bool property RagdollEnd auto hidden
bool property UseMaleNudeSuit auto hidden
bool property UseFemaleNudeSuit auto hidden
bool property RestrictGenderTag auto hidden
bool property FixVictimPos auto hidden
bool property ForceSort auto hidden

bool function UsesNudeSuit(bool IsFemale)
	return false
	; return ((!IsFemale && UseMaleNudeSuit) || (IsFemale && UseFemaleNudeSuit))
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

bool[] function GetStrip(bool IsFemale, bool IsLeadIn = false, bool IsAggressive = false, bool IsVictim = false)
	int idx = (IsFemale as int + Math.LeftShift((IsLeadIn || !IsVictim) as int, 1) + Math.LeftShift(IsAggressive as int, 2)) * 2
	return sslUtility.BitsToBool(iStripForms[idx], iStripForms[idx + 1])
endFunction

function ReloadData()
endFunction

Spell function GetHDTSpell(Actor ActorRef)
	return sslpp.GetHDTHeelSpell(ActorRef)
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
