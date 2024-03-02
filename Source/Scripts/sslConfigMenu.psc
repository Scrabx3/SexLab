scriptname sslConfigMenu extends SKI_ConfigBase
{
	Skyrim SexLab Mod Configuration Menu
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

import PapyrusUtil
import SexLabUtil

; Framework
Actor property PlayerRef auto
SexLabFramework property SexLab auto
sslSystemConfig property Config auto
sslSystemAlias property SystemAlias auto

; Function libraries
sslActorLibrary Property ActorLib Auto
sslThreadLibrary Property ThreadLib Auto
sslActorStats Property Stats Auto

; Object registries
sslThreadSlots Property ThreadSlots Auto
sslAnimationSlots Property AnimSlots Auto
sslCreatureAnimationSlots Property CreatureSlots Auto
sslVoiceSlots Property VoiceSlots Auto
sslExpressionSlots Property ExpressionSlots Auto

; Common Data
Actor TargetRef
int TargetFlag
string TargetName
string PlayerName

; ------------------------------------------------------- ;
; --- Configuration Events                            --- ;
; ------------------------------------------------------- ;

int Function GetVersion()
	return SexLabUtil.GetVersion()
EndFunction
String function GetStringVer()
	return SexLabUtil.GetStringVer()
EndFunction

Event OnVersionUpdate(int version)
EndEvent

Event OnGameReload()
	RegisterForModEvent("SKICP_pageSelected", "OnPageSelected")
	parent.OnGameReload()
EndEvent

Event OnConfigInit()
	Pages = new string[11]
	Pages[0] = "$SSL_SexDiary"
	Pages[1] = "$SSL_AnimationSettings"
	Pages[2] = "$SSL_SoundSettings"
	Pages[3] = "$SSL_PlayerHotkeys"
	Pages[4] = "$SSL_TimersStripping"
	Pages[5] = "$SSL_ToggleAnimations"
	Pages[6] = "$SSL_MatchMaker"
	Pages[7] = "$SSL_AnimationEditor"
	Pages[8] = "$SSL_ExpressionEditor"
	Pages[9] = "$SSL_StripEditor"
	Pages[10] = "$SSL_RebuildClean"

	; Animation Settings
	Chances = new string[3]
	Chances[0] = "$SSL_Never"
	Chances[1] = "$SSL_Sometimes"
	Chances[2] = "$SSL_Always"

	BedOpt = new string[3]
	BedOpt[0] = "$SSL_Never"
	BedOpt[1] = "$SSL_Always"
	BedOpt[2] = "$SSL_NotVictim"

	_FadeOpt = new string[3]
	_FadeOpt[0] = "$SSL_Never"
	_FadeOpt[1] = "$SSL_UseBlack"
	_FadeOpt[2] = "$SSL_UseBlur"

	_ClimaxTypes = new String[3]
	_ClimaxTypes[0] = "$SSL_Climax_0"	; Default
	_ClimaxTypes[1] = "$SSL_Climax_1"	; Legacy
	_ClimaxTypes[2] = "$SSL_Climax_2"	; Extern

	_Sexes = new String[3]
	_Sexes[0] = "$SSL_Male"
	_Sexes[1] = "$SSL_Female"
	_Sexes[2] = "$SSL_Futa"

	; Expression Editor
	Phases = new string[5]
	Phases[0] = "Phase 1"
	Phases[1] = "Phase 2"
	Phases[2] = "Phase 3"
	Phases[3] = "Phase 4"
	Phases[4] = "Phase 5"

	Moods = new string[17]
	Moods[0]  = "Dialogue Anger"
	Moods[1]  = "Dialogue Fear"
	Moods[2]  = "Dialogue Happy"
	Moods[3]  = "Dialogue Sad"
	Moods[4]  = "Dialogue Surprise"
	Moods[5]  = "Dialogue Puzzled"
	Moods[6]  = "Dialogue Disgusted"
	Moods[7]  = "Mood Neutral"
	Moods[8]  = "Mood Anger"
	Moods[9]  = "Mood Fear"
	Moods[10] = "Mood Happy"
	Moods[11] = "Mood Sad"
	Moods[12] = "Mood Surprise"
	Moods[13] = "Mood Puzzled"
	Moods[14] = "Mood Disgusted"
	Moods[15] = "Combat Anger"
	Moods[16] = "Combat Shout"

	Phonemes = new string[16]
	Phonemes[0]  = "0: Aah"
	Phonemes[1]  = "1: BigAah"
	Phonemes[2]  = "2: BMP"
	Phonemes[3]  = "3: ChjSh"
	Phonemes[4]  = "4: DST"
	Phonemes[5]  = "5: Eee"
	Phonemes[6]  = "6: Eh"
	Phonemes[7]  = "7: FV"
	Phonemes[8]  = "8: i"
	Phonemes[9]  = "9: k"
	Phonemes[10] = "10: N"
	Phonemes[11] = "11: Oh"
	Phonemes[12] = "12: OohQ"
	Phonemes[13] = "13: R"
	Phonemes[14] = "14: Th"
	Phonemes[15] = "15: W"

	Modifiers = new string[14]
	Modifiers[0]  = "0: BlinkL"
	Modifiers[1]  = "1: BlinkR"
	Modifiers[2]  = "2: BrowDownL"
	Modifiers[3]  = "3: BrownDownR"
	Modifiers[4]  = "4: BrowInL"
	Modifiers[5]  = "5: BrowInR"
	Modifiers[6]  = "6: BrowUpL"
	Modifiers[7]  = "7: BrowUpR"
	Modifiers[8]  = "8: LookDown"
	Modifiers[9]  = "9: LookLeft"
	Modifiers[10] = "10: LookRight"
	Modifiers[11] = "11: LookUp"
	Modifiers[12] = "12: SquintL"
	Modifiers[13] = "13: SquintR"

	SoundTreatment = new string[3]
	SoundTreatment[0] = "$SSL_WaitToEnd"
	SoundTreatment[1] = "$SSL_KeepPlaying"
	SoundTreatment[2] = "$SSL_CutOnTime"

	; Timers & Stripping
	TSModes = new string[3]
	TSModes[0] = "$SSL_NormalTimersStripping"
	TSModes[1] = "$SSL_ForeplayTimersStripping"
	TSModes[2] = "$SSL_AggressiveTimersStripping"
EndEvent

; ------------------------------------------------------- ;
; --- Create MCM Pages                                --- ;
; ------------------------------------------------------- ;

Event OnPageReset(string page)
	if !SystemAlias.IsInstalled
		UnloadCustomContent()
		InstallMenu()
	elseIf ShowAnimationEditor
		AnimationEditor()
	elseif page != ""
		UnloadCustomContent()
		if page == "$SSL_AnimationSettings"
			AnimationSettings()
		elseIf page == "$SSL_SoundSettings"
			SoundSettings()
		elseIf page == "$SSL_PlayerHotkeys"
			PlayerHotkeys()
		elseIf page == "$SSL_TimersStripping"
			TimersStripping()
		elseIf page == "$SSL_StripEditor"
			StripEditor()
		elseIf page == "$SSL_ToggleAnimations"
			ToggleAnimations()
		elseIf page == "$SSL_MatchMaker"
			MatchMaker()
		elseIf page == "$SSL_AnimationEditor"
			AnimationEditor()
		elseIf page == "$SSL_ExpressionEditor"
			ExpressionEditor()
		elseIf page == "$SSL_SexDiary" || page == "$SSL_SexJournal"
			SexDiary()
		elseIf page == "$SSL_RebuildClean"
			RebuildClean()
		endIf
	else
		if (Config.GetThreadControlled() || ThreadSlots.FindActorController(PlayerRef) != -1)
			AnimationEditor()
			PreventOverwrite = true
		else
			LoadCustomContent("SexLab/logo.dds", 184, 31)
		endIf
	endIf
endEvent

bool ShowAnimationEditor = false
event OnPageSelected(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)
	if ShowAnimationEditor && (a_numArg as int) != Pages.Find("$SSL_ToggleAnimations")
		ShowAnimationEditor = false
	elseIf EditOpenMouth && (a_numArg as int) != Pages.Find("$SSL_ExpressionEditor")
		EditOpenMouth = false
	endIf
endEvent

; ------------------------------------------------------- ;
; --- Config Setup                                    --- ;
; ------------------------------------------------------- ;

event OnConfigOpen()
	If(PlayerRef.GetLeveledActorBase().GetSex() == 0)
		Pages[0] = "$SSL_SexJournal"
	Else
		Pages[0] = "$SSL_SexDiary"
	EndIf

	; Player & Target info
	PlayerName = PlayerRef.GetLeveledActorBase().GetName()
	TargetRef = Config.TargetRef
	EmptyStatToggle = false
	If(TargetRef)
		If(TargetRef.Is3DLoaded())
			TargetName = TargetRef.GetLeveledActorBase().GetName()
			TargetFlag = OPTION_FLAG_NONE
		EndIf
		StatRef = TargetRef
	Else
		TargetName = "$SSL_NoTarget"
		TargetFlag = OPTION_FLAG_DISABLED
		StatRef = PlayerRef
	EndIf
	; Reset animation editor auto selector
	PreventOverwrite = false
	; All paged menus need this
	PerPage = 125
	; AnimationEditor
	AnimEditPage = 1
	; ToggleAnimations
	TogglePage = 1
	ta = 0
	EditTags = false
	TagFilter = ""
	TagMode = ""
	; Stripping/Timers toggles
	ts = 0
	; Strip Editor
	FullInventoryPlayer = false
	FullInventoryTarget = false
EndEvent

Event OnConfigClose()
	ModEvent.Send(ModEvent.Create("SexLabConfigClose"))
	; Realign actors if an adjustment in editor was just made
	If(AutoRealign)
		AutoRealign = false
		If(ThreadControlled)
			ThreadControlled.RealignActors()
		EndIf
	EndIf
endEvent

; ------------------------------------------------------- ;
; --- Object Pagination                               --- ;
; ------------------------------------------------------- ;

; All paged menus need
int PerPage
int LastPage

string[] function PaginationMenu(string BeforePages = "", string AfterPages = "", int CurrentPage)
	string[] Output
	if BeforePages != ""
		Output = PapyrusUtil.PushString(Output, BeforePages)
	endIf
	if CurrentPage < LastPage
		Output = PapyrusUtil.PushString(Output, "$SSL_NextPage")
	endIf
	if CurrentPage > 1
		Output = PapyrusUtil.PushString(Output, "$SSL_PrevPage")
	endIf
	if AfterPages != ""
		Output = PapyrusUtil.PushString(Output, AfterPages)
	endIf
	return Output
endfunction

; ------------------------------------------------------- ;
; --- Mapped State Option Events                      --- ;
; ------------------------------------------------------- ;

string[] function MapOptions()
	return StringSplit(GetState(), "_")
endFunction

Event OnHighlightST()
	String[] Options = PapyrusUtil.StringSplit(GetState(), "_")
	If (Options[0] == "ClimaxType")					; Animation Settings
		SetInfoText("$SSL_ClimaxInfo")
	ElseIf (Options[0] == "SexSelect")
		SetInfoText("$SSL_InfoPlayerGender")
	ElseIf (Options[0] == "UseFade")
		SetInfoText("$SSL_UseFadeInfo")

	; Animation Toggle
	Elseif Options[0] == "Animation"
		sslBaseAnimation Slot = AnimToggles[(Options[1] as int)]
		if Config.MirrorPress(Config.AdjustStage)
			SetInfoText("$SSL_AnimationEditor") ; TODO: ?
		else
			SetInfoText(Slot.Name+" Tags:\n"+StringJoin(Slot.GetTags(), ", "))
		endIf

	; Voice Toggle
	elseIf Options[0] == "Voice"
		sslBaseVoice Slot = VoiceSlots.GetBySlot(Options[1] as int)
		SetInfoText(Slot.Name+" Tags:\n"+StringJoin(Slot.GetTags(), ", "))

	; Timers & Stripping - Stripping
	ElseIf(Options[0] == "Stripping")
		int i = Options[2] as int
		string InfoText = PlayerRef.GetLeveledActorBase().GetName()+" Slot "+((Options[2] as int) + 30)+": "
		InfoText += GetItemName(PlayerRef.GetWornForm(Armor.GetMaskForSlot((Options[2] as int) + 30)), "?")
		if TargetRef
			InfoText += "\n"+TargetRef.GetLeveledActorBase().GetName()+" Slot "+((Options[2] as int) + 30)+": "
			InfoText += GetItemName(TargetRef.GetWornForm(Armor.GetMaskForSlot((Options[2] as int) + 30)), "?")
		endIf
		SetInfoText(InfoText)

	; Strip Editor
	ElseIf(Options[0] == "StripEditorPlayer" || Options[0] == "StripEditorTarget")
		Form item
		If(Options[0] == "StripEditorPlayer")
			item = ItemsPlayer[Options[1] as int]
		Else
			item = ItemsTarget[Options[1] as int]
		EndIf
		String InfoText = GetItemName(item, "?")
		Armor ArmorRef = item as Armor
		If(ArmorRef)
			InfoText += "\nArmor Slots: " + GetAllMaskSlots(ArmorRef.GetSlotMask())
		Else
			InfoText += "\nWeapon"
		EndIf
		SetInfoText(InfoText)

	; Advanced OpenMouth Expression
	elseIf Options[0] == "AdvancedOpenMouth"
		SetInfoText("$SSL_InfoAdvancedOpenMouth")

	; Alt OpenMouth Expression
	elseIf Options[0] == "OpenMouthExpression"
		SetInfoText("$SSL_InfoOpenMouthExpression")

	elseIf Options[0] == "LipsPhoneme"
		SetInfoText("$SSL_InfoLipsPhoneme")

	elseIf Options[0] == "LipsFixedValue"
		SetInfoText("$SSL_InfoLipsFixedValue")

	elseIf Options[0] == "LipsMinValue"
		SetInfoText("$SSL_InfoLipsMinValue")

	elseIf Options[0] == "LipsMaxValue"
		SetInfoText("$SSL_InfoLipsMaxValue")

	elseIf Options[0] == "LipsMoveTime"
		SetInfoText("$SSL_InfoLipsMoveTime")

	elseIf Options[0] == "LipsSoundTime"
		SetInfoText("$SSL_InfoLipsSoundTime")

	; Error & Warning
	elseIf Options[0] == "InstallError"
		SetInfoText("CRITICAL ERROR: File Integrity Framework quest / files overwritten...\nUnable to resolve needed variables. Install unable continue as result.\nUsually caused by incompatible SexLab addons. Disable other SexLab addons (NOT SexLab.esm) one by one and trying again until this message goes away. Alternatively, with TES5Edit after the background loader finishes check for any mods overriding SexLab.esm's Quest records. ScocLB.esm & SexlabScocLB.esp are the most common cause of this problem.\nIf using Mod Organizer, check that no mods are overwriting any of SexLab Frameworks files. There should be no red - symbol under flags for your SexLab Framework install in Mod Organizer.")

	elseIf Options[0] == "FNISWarning"
		SetInfoText("Important FNIS Check:\nIf you're getting a '?' on any checks try scrolling in and out of 3rd person mode then checking again while still in 3rd. These '?' are just soft warnings and can usually be ignored safely.\nIf scrolling in and out doesn't work and characters stand frozen in place during animation than these are the most likely causes. Fix your FNIS install.")
	endIf
endEvent

event OnSliderOpenST()
	string[] Options = MapOptions()

	; Animation Editor
	if Options[0] == "Adjust"
		; Stage, Slot
		if Options[2] == "3" ; SOS
			SetSliderDialogStartValue(Animation.GetSchlong(AdjustKey, Position, Options[1] as int))
			SetSliderDialogRange(-9, 9)
			SetSliderDialogInterval(1)
			SetSliderDialogDefaultValue(Animation.GetSchlong("Global", Position, Options[1] as int))
		else ; Alignments
			SetSliderDialogStartValue(Animation.GetAdjustment(AdjustKey, Position, Options[1] as int, Options[2] as int))
			SetSliderDialogRange(-100.0, 100.0)
			SetSliderDialogInterval(0.50)
			SetSliderDialogDefaultValue(Animation.GetAdjustment("Global", Position, Options[1] as int, Options[2] as int))
		endIf
	; Animation Editor (Animation Offsets)
	elseIf Options[0] == "AnimationOffset"
		AnimOffsets = Animation.GetBedOffsets()
		SetSliderDialogStartValue(AnimOffsets[Options[2] as int])
		if Options[2] == "3" ; Rotation
			SetSliderDialogRange(0, 360)
			SetSliderDialogInterval(15)
		else
			SetSliderDialogRange(-100.0, 100.0)
			SetSliderDialogInterval(0.50)
		endIf
		SetSliderDialogDefaultValue(0.0)

	; Expression OpenMouth Editor
	elseIf Options[0] == "OpenMouth"
		; Gender, ID
		SetSliderDialogStartValue(Config.GetOpenMouthPhonemes(Options[1] == "1")[Options[2] as int] * 100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
		if Options[2] == "1"
			if Options[1] == "1"
				SetSliderDialogDefaultValue(100)
			else
				SetSliderDialogDefaultValue(80)
			endIf
		else
			SetSliderDialogDefaultValue(0)
		endIf

	elseIf Options[0] == "LipsMinValue"
		SetSliderDialogStartValue(Config.LipsMinValue)
		SetSliderDialogRange(0, 90)
		SetSliderDialogInterval(5)
		SetSliderDialogDefaultValue(20)

	elseIf Options[0] == "LipsMaxValue"
		SetSliderDialogStartValue(Config.LipsMaxValue)
		SetSliderDialogRange(10, 100)
		SetSliderDialogInterval(5)
		SetSliderDialogDefaultValue(50)

	elseIf Options[0] == "LipsMoveTime"
		SetSliderDialogStartValue(Config.LipsMoveTime)
		SetSliderDialogRange(0.2, 4.0)
		SetSliderDialogInterval(0.2)
		SetSliderDialogDefaultValue(0.2)

	; Expression Editor
	elseIf Options[0] == "Expression"
		; Gender, Type, ID
		SetSliderDialogStartValue( Expression.GetIndex(Phase, Options[1] as int, Options[2] as int, Options[3] as int) )
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
		SetSliderDialogDefaultValue(0)

	; Timers & Stripping - Timers
	ElseIf(Options[0] == "Timers")
		int i = Options[1] as int
		SetSliderDialogStartValue(sslSystemConfig.GetSettingFltA("fTimers", ts * 5 + i))
		SetSliderDialogRange(3, 180)
		SetSliderDialogInterval(1)
		SetSliderDialogDefaultValue(GetDefaultTime(ts * 5 + i))
	EndIf
endEvent

event OnSliderAcceptST(float value)
	string[] Options = MapOptions()

	; Animation Editor
	if Options[0] == "Adjust"
		; Stage, Slot
		if Config.MirrorPress(Config.AdjustStage) && ShowMessage("$SSL_WarnApplyAllStages", true, "$Yes", "$No")
			int Stage = 1
			while Stage <= Animation.StageCount
				Animation.SetAdjustment(AdjustKey, Position, Stage, Options[2] as int, value)
				Stage += 1
			endWhile
			Config.ExportProfile(Config.AnimProfile)
			ForcePageReset()
		else
			Animation.SetAdjustment(AdjustKey, Position, Options[1] as int, Options[2] as int, value)
			Config.ExportProfile(Config.AnimProfile)
			if Options[2] == "3" ; SOS
				SetSliderOptionValueST(value, "{0}")
			else
				SetSliderOptionValueST(value, "{2}")
			endIf
		endIf
		AutoRealign = PlayerRef.IsInFaction(Config.AnimatingFaction) && (Config.GetThreadControlled() != none || ThreadSlots.FindActorController(PlayerRef) != -1)

	; Animation Editor (Animation Offsets)
	elseIf Options[0] == "AnimationOffset"
		AnimOffsets[Options[2] as int] = value
		Animation.SetBedOffsets(AnimOffsets[0], AnimOffsets[1], AnimOffsets[2], AnimOffsets[3])
		Animation.ExportOffsets("BedOffset")
		if Options[2] == "3" ; Rotation
			SetSliderOptionValueST(value, "{0}")
		else
			SetSliderOptionValueST(value, "{2}")
		endIf
		AutoRealign = PlayerRef.IsInFaction(Config.AnimatingFaction) && (Config.GetThreadControlled() != none || ThreadSlots.FindActorController(PlayerRef) != -1)

	; Expression OpenMouth Editor
	elseIf Options[0] == "OpenMouth"
		; Gender, ID, Value
		Config.SetOpenMouthPhoneme(Options[1] == "1", Options[2] as int, value / 100.0)
		SetSliderOptionValueST(value as int)

	elseIf Options[0] == "LipsMinValue"
		Config.LipsMinValue = value as int
		SetSliderOptionValueST(Config.LipsMinValue, "{0}")

	elseIf Options[0] == "LipsMaxValue"
		Config.LipsMaxValue = value as int
		SetSliderOptionValueST(Config.LipsMaxValue, "{0}")

	elseIf Options[0] == "LipsMoveTime"
		Config.LipsMoveTime = value
		SetSliderOptionValueST(Config.LipsMoveTime, "$SSL_Seconds")

	; Expression Editor
	elseIf Options[0] == "Expression"
		; Gender, Type, ID
		Expression.SetIndex(Phase, Options[1] as int, Options[2] as int, Options[3] as int, value as int)
		; Expression.SavePhase(Phase, Options[1] as int)
		SetSliderOptionValueST(value as int)

	; Timers & Stripping - Timers
	ElseIf(Options[0] == "Timers")
		int i = Options[1] as int
		sslSystemConfig.SetSettingFltA("fTimers", value, ts * 5 + i)
		SetSliderOptionValueST(value, "$SSL_Seconds")
	EndIf
EndEvent

Event OnMenuOpenST()
	String[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "ClimaxType")				; General Animation Settings
		SetMenuDialogStartIndex(sslSystemConfig.GetSettingInt("iClimaxType"))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_ClimaxTypes)
	ElseIf (s[0] == "SexSelect")
		int sex
		If (s[1] == "0")
			sex = SexLabRegistry.GetSex(PlayerRef, true)
		Else
			sex = SexLabRegistry.GetSex(Config.TargetRef, true)
		EndIf
		String[] options
		If (sex <= 2)	; Human
			options = _Sexes
		Else					; Creature
			options = new String[2]
			options[0] = "$SSL_Male"
			options[1] = "$SSL_Female"
		EndIf
		SetMenuDialogStartIndex(sex % 3)
		SetMenuDialogDefaultIndex(sex % 3)
		SetMenuDialogOptions(options)
	ElseIf (s[0] == "UseFade")
		SetMenuDialogStartIndex(sslSystemConfig.GetSettingInt("iUseFade"))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_FadeOpt)

	ElseIf (s[0] == "LipsPhoneme")	; Expression OpenMouth & LipSync Editor
		string[] LipsPhonemes = new String[1]
		LipsPhonemes[0] = "$SSL_Automatic"
		LipsPhonemes = MergeStringArray(LipsPhonemes, Phonemes)
		SetMenuDialogStartIndex(sslSystemConfig.GetSettingInt("iLipsPhoneme") + 1)
		SetMenuDialogDefaultIndex(2) ; BigAah
		SetMenuDialogOptions(LipsPhonemes)
	EndIf
EndEvent

Event OnMenuAcceptST(int aiIndex)
	String[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "ClimaxType")				; Animation Settings
		If (aiIndex < 0)
			return
		EndIf
		sslSystemConfig.SetSettingInt("iClimaxType", aiIndex)
		SetMenuOptionValueST(_ClimaxTypes[aiIndex])
	ElseIf (s[0] == "SexSelect")
		If (s[1] == "0")
			ActorLib.TreatAsSex(PlayerRef, aiIndex)
		Else
			ActorLib.TreatAsSex(Config.TargetRef, aiIndex)
		EndIf
		SetMenuOptionValueST(_Sexes[aiIndex])
	ElseIf (s[0] == "UseFade")
		If (aiIndex < 0)
			return
		EndIf
		sslSystemConfig.SetSettingInt("iUseFade", aiIndex)
		SetMenuOptionValueST(_FadeOpt[aiIndex])


	ElseIf (s[0] == "LipsPhoneme")	; Expression OpenMouth & LipSync Editor
		If (aiIndex == 0)
			sslSystemConfig.SetSettingInt("iClimaxType", -1)
			SetMenuOptionValueST("$SSL_Automatic")
		ElseIf (aiIndex > 0)
			sslSystemConfig.SetSettingInt("iClimaxType", aiIndex - 1)
			SetMenuOptionValueST(Phonemes[aiIndex - 1])
		EndIf
	EndIf
EndEvent

Event OnInputOpenST()
	string[] Options = MapOptions()

	; Set TimeSpent Actor Stat
	if Options[0] == "SetStatTimeSpent"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "TimeSpent") as string)

	; Set Vaginal Actor Stat
	elseIf Options[0] == "SetStatVaginal"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Vaginal") as string)
	
	; Set Anal Actor Stat
	elseIf Options[0] == "SetStatAnal"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Anal") as string)
	
	; Set Oral Actor Stat
	elseIf Options[0] == "SetStatOral"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Oral") as string)
	
	; Set Foreplay Actor Stat
	elseIf Options[0] == "SetStatForeplay"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Foreplay") as string)
	
	; Set Pure Actor Stat
	elseIf Options[0] == "SetStatPure"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Pure") as string)
	
	; Set Lewd Actor Stat
	elseIf Options[0] == "SetStatLewd"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Lewd") as string)
	
	; Set Males Actor Stat
	elseIf Options[0] == "SetStatMales"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Males") as string)
	
	; Set Females Actor Stat
	elseIf Options[0] == "SetStatFemales"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Females") as string)
	
	; Set Creatures Actor Stat
	elseIf Options[0] == "SetStatCreatures"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Creatures") as string)
	
	; Set Masturbation Actor Stat
	elseIf Options[0] == "SetStatMasturbation"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Masturbation") as string)
	
	; Set Aggressor Actor Stat
	elseIf Options[0] == "SetStatAggressor"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Aggressor") as string)
	
	; Set Victim Actor Stat
	elseIf Options[0] == "SetStatVictim"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "Victim") as string)
	
	; Set VaginalCount Actor Stat
	elseIf Options[0] == "SetStatVaginalCount"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "VaginalCount") as string)
	
	; Set AnalCount Actor Stat
	elseIf Options[0] == "SetStatAnalCount"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "AnalCount") as string)
	
	; Set OralCount Actor Stat
	elseIf Options[0] == "SetStatOralCount"
		SetInputDialogStartText(Stats.GetSkill(StatRef, "OralCount") as string)

		; --- Matchmaker Tags
	ElseIf Options[0] == "InputRequiredTags"
		SetInputDialogStartText(Config.RequiredTags)
	ElseIf Options[0] == "InputExcludedTags"
		SetInputDialogStartText(Config.ExcludedTags)
	ElseIf Options[0] == "InputOptionalTags"
		SetInputDialogStartText(Config.OptionalTags)

	else
		SetInputDialogStartText("Error Fatal: Opcion Desconocida")
	endIf
EndEvent

Event OnInputAcceptST(String inputString)
	string[] Options = MapOptions()

	; Set TimeSpent Actor Stat
	if Options[0] == "SetStatTimeSpent"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "TimeSpent", inputString as int)
			SetInputOptionValueST(Stats.ParseTime(Stats.GetSkill(StatRef, "TimeSpent")))
		endIf

	; Set Vaginal Actor Stat
	elseIf Options[0] == "SetStatVaginal"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Vaginal", inputString as int)
			SetInputOptionValueST(Stats.GetSkillTitle(StatRef, "Vaginal"))
		endIf
	
	; Set Anal Actor Stat
	elseIf Options[0] == "SetStatAnal"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Anal", inputString as int)
			SetInputOptionValueST(Stats.GetSkillTitle(StatRef, "Anal"))
		endIf
	
	; Set Oral Actor Stat
	elseIf Options[0] == "SetStatOral"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Oral", inputString as int)
			SetInputOptionValueST(Stats.GetSkillTitle(StatRef, "Oral"))
		endIf
	
	; Set Foreplay Actor Stat
	elseIf Options[0] == "SetStatForeplay"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Foreplay", inputString as int)
			SetInputOptionValueST(Stats.GetSkillTitle(StatRef, "Foreplay"))
		endIf
	
	; Set Pure Actor Stat
	elseIf Options[0] == "SetStatPure"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Pure", inputString as int)
			SetInputOptionValueST(Stats.GetPureTitle(StatRef))
		endIf
	
	; Set Lewd Actor Stat
	elseIf Options[0] == "SetStatLewd"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Lewd", inputString as int)
			SetInputOptionValueST(Stats.GetLewdTitle(StatRef))
		endIf
	
	; Set Males Actor Stat
	elseIf Options[0] == "SetStatMales"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Males", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "Males"))
		endIf
	
	; Set Females Actor Stat
	elseIf Options[0] == "SetStatFemales"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Females", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "Females"))
		endIf
	
	; Set Creatures Actor Stat
	elseIf Options[0] == "SetStatCreatures"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Creatures", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "Creatures"))
		endIf
	
	; Set Masturbation Actor Stat
	elseIf Options[0] == "SetStatMasturbation"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Masturbation", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "Masturbation"))
		endIf
	
	; Set Aggressor Actor Stat
	elseIf Options[0] == "SetStatAggressor"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Aggressor", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "Aggressor"))
		endIf
	
	; Set Victim Actor Stat
	elseIf Options[0] == "SetStatVictim"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "Victim", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "Victim"))
		endIf
	
	; Set VaginalCount Actor Stat
	elseIf Options[0] == "SetStatVaginalCount"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "VaginalCount", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "VaginalCount"))
		endIf
	
	; Set AnalCount Actor Stat
	elseIf Options[0] == "SetStatAnalCount"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "AnalCount", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "AnalCount"))
		endIf
	
	; Set OralCount Actor Stat
	elseIf Options[0] == "SetStatOralCount"
		if inputString as int > 0
			Stats.SetSkill(StatRef, "OralCount", inputString as int)
			SetInputOptionValueST(Stats.GetSkill(StatRef, "OralCount"))
		endIf

		; --- Matchmaker Tags
	elseIf Options[0] == "InputRequiredTags"
		Config.RequiredTags = inputString
		SetInputOptionValueST(Config.RequiredTags)
	elseIf Options[0] == "InputExcludedTags"
		Config.ExcludedTags = inputString
		SetInputOptionValueST(Config.ExcludedTags)
	elseIf Options[0] == "InputOptionalTags"
		Config.OptionalTags = inputString
		SetInputOptionValueST(Config.OptionalTags)
	endIf
EndEvent

event OnSelectST()
	string[] Options = MapOptions()
	; Sound Settings - Voice Toggle
	if Options[0] == "Voice"
		sslBaseVoice Slot = VoiceSlots.GetBySlot(Options[1] as int)
		Slot.Enabled = !Slot.Enabled
		SetToggleOptionValueST(Slot.Enabled)

	; Timers & Stripping - Stripping
	ElseIf(Options[0] == "StrippingW")
		int i = Options[1] as int
		int value = 1 - sslSystemConfig.GetSettingIntA("iStripForms", i)
		sslSystemConfig.SetSettingIntA("iStripForms", value, i)
		SetToggleOptionValueST(value)
	ElseIf(Options[0] == "Stripping")
		int i = Options[1] as int
		int n = Options[2] as int
		int bit = Math.LeftShift(1, n)
		int value = Math.LogicalXor(sslSystemConfig.GetSettingIntA("iStripForms", i), bit)
		sslSystemConfig.SetSettingIntA("iStripForms", value, i)
    SetToggleOptionValueST(Math.LogicalAnd(value, bit))
		
	; Strip Editor
	ElseIf(Options[0] == "StripEditorPlayer" || Options[0] == "StripEditorTarget")
		Form item
		If(Options[0] == "StripEditorPlayer")
			item = ItemsPlayer[Options[1] as int]
		Else
			item = ItemsTarget[Options[1] as int]
		EndIf
		int i = sslActorLibrary.CheckStrip(item)
		If(i == -1)			; Never 			-> Always
			sslActorLibrary.WriteStrip(item, false)
		ElseIf(i == 0)	; Unspecified	-> Never
			sslActorLibrary.WriteStrip(item, true)
		ElseIf(i == 1)	; Always			-> Unspecified
			sslActorLibrary.EraseStrip(item)
		EndIf
		SetTextOptionValueST(GetStripState(item))
		
	; Animation Toggle
	elseIf Options[0] == "Animation"
		; Get animation to toggle
		sslBaseAnimation Slot
		Slot = AnimToggles[(Options[1] as int)]
		
		if Config.MirrorPress(Config.AdjustStage)
			Position = 0
			Animation = Slot
			AdjustKey = "Global"
			PreventOverwrite = true
			ShowAnimationEditor = true
			ForcePageReset()
		;	AnimationEditor()
		else
			; if ta == 3
			; 	; Slot = CreatureSlots.GetBySlot(Options[1] as int)
			; 	Slot = AnimToggles[i]
			; else
			; 	; Slot = AnimSlots.GetBySlot(Options[1] as int)
			; endIf
			; Toggle action
			if ta == 1
				Slot.ToggleTag("LeadIn")
				; Invalite all cache so it can now include this one
				; LeadIn, Aggressive and Bed animations are not goods for the InvalidateByTags() funtion
				AnimationSlots.ClearAnimCache()
			elseIf ta == 2
				Slot.ToggleTag("Aggressive")
				; Invalite all cache so it can now include this one
				; LeadIn, Aggressive and Bed animations are not goods for the InvalidateByTags() funtion
				AnimationSlots.ClearAnimCache()
			elseIf EditTags
				Slot.ToggleTag(TagFilter)
				; Invalite all cache so it can now include this one
				AnimationSlots.InvalidateByTags(TagFilter)
			else
				Slot.Enabled = !Slot.Enabled
				if Slot.Enabled
					; Invalite cache by tags so it can now include this one
					AnimationSlots.InvalidateByTags(PapyrusUtil.StringJoin(Slot.GetRawTags()))
				else
					; Invalidate cache containing animation
					AnimationSlots.InvalidateByAnimation(Slot)
				endIf
			endIf

			SetToggleOptionValueST(GetToggle(Slot))
		endIf

	; Toggle Expressions
	elseIf Options[0] == "Expression"
		sslBaseExpression Slot = ExpressionSlots.GetBySlot(Options[2] as int)
		Slot.ToggleTag(Options[1])
		SetToggleOptionValueST(Slot.HasTag(Options[1]))

	; Advanced OpenMouth Expressions
	elseIf Options[0] == "AdvancedOpenMouth"
		EditOpenMouth = !EditOpenMouth
		ForcePageReset()

	; Alt OpenMouth Expression
	elseIf Options[0] == "OpenMouthExpression"
		if Config.GetOpenMouthExpression(Options[1] == "1") == 16
			Config.SetOpenMouthExpression(Options[1] == "1", 15)
		else
			Config.SetOpenMouthExpression(Options[1] == "1", 16)
		endIf
		SetToggleOptionValueST(Config.GetOpenMouthExpression(Options[1] == "1") == 15)

	; Expression OpenMouth & LipSync Editor
	elseIf Options[0] == "LipsFixedValue"
		Config.LipsFixedValue = !Config.LipsFixedValue
		SetToggleOptionValueST(Config.LipsFixedValue)

	elseIf Options[0] == "LipsSoundTime"
		Config.LipsSoundTime = sslUtility.IndexTravel(Config.LipsSoundTime + 1, 3) - 1
		SetTextOptionValueST(SoundTreatment[Config.LipsSoundTime + 1])

	; Toggle Strapons
	elseIf Options[0] == "Strapon"
		int i = Options[1] as int
		Form[] Output
		Form[] Strapons = Config.Strapons
		int n = Strapons.Length
		while n
			n -= 1
			if n != i
				Output = PushForm(Output, Strapons[n])
			endIf
		endWhile
		Config.Strapons = Output
		ForcePageReset()

	; Install System
	elseIf Options[0] == "InstallSystem"
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("Working...")
		SystemAlias.InstallSystem()
		ForcePageReset()

	; Reset Debug Tags
	elseIf Options[0] == "TextTags"
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("Resetting tags...")
		; TODO: Reset tags here
		ForcePageReset()

		; --- Matchmaker Tags
	ElseIf (Options[0] == "InputTags")
		ShowMessage(sslSystemConfig.ParseMMTagString(), false, "$Done")
	ElseIf (Options[0] == "TextResetTags")
		If (!ShowMessage("$SSL_TagResetAreYouSure"))
			return
		EndIf
		sslSystemConfig.SetSettingStr("sRequiredTags", "")
		sslSystemConfig.SetSettingStr("sOptionalTags", "")
		sslSystemConfig.SetSettingStr("sExcludedTags", "")
		ForcePageReset()
	ElseIf (Options[0] == "ToggleSubmissivePlayer")
		Config.SubmissivePlayer = !Config.SubmissivePlayer
		SetToggleOptionValueST(Config.SubmissivePlayer)
	ElseIf (Options[0] == "ToggleSubmissiveTarget")
		Config.SubmissiveTarget = !Config.SubmissiveTarget
		SetToggleOptionValueST(Config.SubmissiveTarget)
	endIf
endEvent

event OnDefaultST()
	string[] Options = MapOptions()

	; Comment
	if Options[0] == ""
	
	; Expression OpenMouth & LipSync Editor
	elseIf Options[0] == "LipsPhoneme"
		Config.LipsPhoneme = 1
		SetMenuOptionValueST(SexLabUtil.StringIfElse(Config.LipsPhoneme >= 0, Phonemes[ClampInt(Config.LipsPhoneme, 0, 15)], "$SSL_Automatic"))
	
	elseIf Options[0] == "LipsFixedValue"
		Config.LipsFixedValue = true
		SetToggleOptionValueST(Config.LipsFixedValue)
	
	endIf
endEvent

; ------------------------------------------------------- ;
; --- Install Menu                                    --- ;
; ------------------------------------------------------- ;

function InstallMenu()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("SexLab v" + GetStringVer())
	SystemCheckOptions()
	SetCursorPosition(1)
	AddHeaderOption("$SSL_Installation")
	; Install/Update button
	bool inInstall = SystemAlias.GetState() == "Installing"
	AddToggleOptionST("AllowCreatures", "$SLL_InstallEnableCreatures", Config.AllowCreatures, DoDisable(inInstall))
	AddEmptyOption()
	AddTextOptionST("InstallSystem", "$SSL_InstallUpdateSexLab{"+GetStringVer()+"}", "$SSL_ClickHere", DoDisable(inInstall))
	If inInstall
		AddTextOption("$SSL_CurrentlyInstalling", "!")
	endIf
endFunction

function SystemCheckOptions()
	String[] okOrFail = new String[3]
	okOrFail[0] = "<font color='#FF0000'>X</font>"
	okOrFail[1] = "<font color='#00FF00'>ok</font>"
	okOrFail[2] = "<font color='#0000FF'>?</font>"

	AddTextOption("Skyrim Script Extender", okOrFail[Config.CheckSystemPart("SKSE") as int], OPTION_FLAG_DISABLED)
	AddTextOption("SexLab.dll", okOrFail[Config.CheckSystemPart("SexLabP+") as int], OPTION_FLAG_DISABLED)
	AddTextOption("SexLabUtil.dll", okOrFail[Config.CheckSystemPart("SexLabUtil") as int], OPTION_FLAG_DISABLED)
	AddTextOption("PapyrusUtil.dll", okOrFail[Config.CheckSystemPart("PapyrusUtil") as int], OPTION_FLAG_DISABLED)
	AddTextOption("NiOverride", okOrFail[Config.CheckSystemPart("NiOverride") as int], OPTION_FLAG_DISABLED)
	AddTextOption("Mfg Fix", okOrFail[Config.CheckSystemPart("MfgFix") as int], OPTION_FLAG_DISABLED)
	AddTextOption("FNIS - Fores New Idles in Skyrim (7.0+)", okOrFail[Config.CheckSystemPart("FNIS") as int], OPTION_FLAG_DISABLED)
	AddTextOption("FNIS For Users Behaviors Generated", okOrFail[(Config.CheckSystemPart("FNISGenerated") as int) * 2], OPTION_FLAG_DISABLED)
	AddTextOption("FNIS Creature Pack (7.0+)", okOrFail[(Config.CheckSystemPart("FNISCreaturePack") as int) * 2], OPTION_FLAG_DISABLED)
	; Show soft error warning if relevant
	if !Config.CheckSystemPart("FNISGenerated") || !Config.CheckSystemPart("FNISCreaturePack")
		AddTextOptionST("FNISWarning", "INFO: On '?' Warning", "README")
		SetInfoText("Important FNIS Check:\nIf you're getting a '?' on any checks try scrolling in and out of 3rd person mode then checking again while still in 3rd. These '?' are just soft warnings and can usually be ignored safely.\nIf scrolling in and out doesn't work and characters stand frozen in place during animation than these are the most likely causes. Fix your FNIS install.")
	endIf
endFunction

; ------------------------------------------------------- ;
; --- Animation Settings                              --- ;
; ------------------------------------------------------- ;

string[] Chances
string[] BedOpt
string[] _FadeOpt
String[] _ClimaxTypes
String[] _Sexes

function AnimationSettings()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$SSL_PlayerSettings")
	AddToggleOptionST("AutoAdvance","$SSL_AutoAdvanceStages", Config.AutoAdvance)
	AddToggleOptionST("DisableVictim","$SSL_DisableVictimControls", Config.DisablePlayer)
	AddToggleOptionST("AutomaticTFC","$SSL_AutomaticTFC", Config.AutoTFC)
	AddSliderOptionST("AutomaticSUCSM","$SSL_AutomaticSUCSM", Config.AutoSUCSM, "{0}")
	AddMenuOptionST("SexSelect_0", "$SSL_PlayerGender", _Sexes[SexLabRegistry.GetSex(PlayerRef, false) % 3])
	If (Config.TargetRef)
		String name = Config.TargetRef.GetLeveledActorBase().GetName()
		AddMenuOptionST("SexSelect_1", "$SSL_{" + name + "}sGender", _Sexes[SexLabRegistry.GetSex(Config.TargetRef, false) % 3])
	Else
		AddTextOption("$SSL_NoTarget", "$SSL_Male", OPTION_FLAG_DISABLED)
	EndIf
	AddHeaderOption("$SSL_ExtraEffects")
	AddMenuOptionST("ClimaxType", "$SSL_ClimaxType", _ClimaxTypes[sslSystemConfig.GetSettingInt("iClimaxType")])
	AddToggleOptionST("OrgasmEffects","$SSL_OrgasmEffects", Config.OrgasmEffects)
	AddSliderOptionST("ShakeStrength","$SSL_ShakeStrength", (Config.ShakeStrength * 100), "{0}%")
	AddToggleOptionST("UseCum","$SSL_ApplyCumEffects", Config.UseCum)
	AddSliderOptionST("CumEffectTimer","$SSL_CumEffectTimer", Config.CumTimer, "$SSL_Seconds")
	AddToggleOptionST("UseExpressions","$SSL_UseExpressions", Config.UseExpressions)
	; AddToggleOptionST("RefreshExpressions","$SSL_RefreshExpressions", Config.RefreshExpressions)
	; AddSliderOptionST("ExpressionDelay","$SSL_ExpressionDelay", Config.ExpressionDelay, "{1}x")
	AddToggleOptionST("UseLipSync", "$SSL_UseLipSync", Config.UseLipSync)
	; AddToggleOptionST("SeparateOrgasms","$SSL_SeparateOrgasms", Config.SeparateOrgasms)
	; AddToggleOptionST("AllowFemaleFemaleCum","$SSL_AllowFemaleFemaleCum", Config.AllowFFCum, SexLabUtil.IntIfElse((!Config.UseCum), OPTION_FLAG_DISABLED, OPTION_FLAG_NONE))

	SetCursorPosition(1)
	; AddMenuOptionST("AnimationProfile", "$SSL_AnimationProfile", "Profile #"+Config.AnimProfile)
	AddHeaderOption("$SSL_Creatures")
	AddToggleOptionST("AllowCreatures","$SSL_AllowCreatures", Config.AllowCreatures)
	AddToggleOptionST("UseCreatureGender","$SSL_UseCreatureGender", Config.UseCreatureGender)
	AddHeaderOption("$SSL_AnimationHandling")
	; AddToggleOptionST("RaceAdjustments","$SSL_RaceAdjustments", Config.RaceAdjustments)
	AddMenuOptionST("UseFade","$SSL_UseFade", _FadeOpt[sslSystemConfig.GetSettingInt("iUseFade")])
	AddToggleOptionST("DisableScale","$SSL_DisableScale", Config.DisableScale)
	; AddToggleOptionST("SeedNPCStats","$SSL_SeedNPCStats", Config.SeedNPCStats)
	; AddToggleOptionST("ScaleActors","$SSL_EvenActorsHeight", Config.ScaleActors, SexLabUtil.IntIfElse(Config.DisableScale, OPTION_FLAG_DISABLED, OPTION_FLAG_NONE))
	; AddToggleOptionST("ForeplayStage","$SSL_PreSexForeplay", Config.ForeplayStage)
	; AddSliderOptionST("LeadInCoolDown","$SSL_LeadInCoolDown", Config.LeadInCoolDown, "$SSL_Seconds", SexLabUtil.IntIfElse(Config.ForeplayStage, OPTION_FLAG_NONE, OPTION_FLAG_DISABLED))
	AddToggleOptionST("RestrictSameSex","$SSL_RestrictSameSex", Config.RestrictSameSex)
	AddToggleOptionST("StraponsFemale","$SSL_FemalesUseStrapons", Config.UseStrapons)
	AddToggleOptionST("UndressAnimation","$SSL_UndressAnimation", Config.UndressAnimation)
	AddToggleOptionST("RedressVictim","$SSL_VictimsRedress", Config.RedressVictim)
	AddToggleOptionST("LimitedStrip","$SSL_LimitedStrip", Config.LimitedStrip)
	AddToggleOptionST("DisableTeleport","$SSL_DisableTeleport", Config.DisableTeleport)
	AddToggleOptionST("ShowInMap","$SSL_ShowInMap", Config.ShowInMap)
	AddTextOptionST("NPCBed","$SSL_NPCsUseBeds", Chances[ClampInt(Config.NPCBed, 0, 2)])
	AddTextOptionST("AskBed","$SSL_AskBed", BedOpt[ClampInt(Config.AskBed, 0, 2)])
	; AddToggleOptionST("RemoveHeelEffect","$SSL_RemoveHeelEffect", Config.RemoveHeelEffect)
	; AddToggleOptionST("BedRemoveStanding","$SSL_BedRemoveStanding", Config.BedRemoveStanding)
endFunction

state AnimationProfile
	event OnMenuOpenST()
		string[] Profiles = new string[5]
		Profiles[0] = "AnimationProfile_1.json"
		Profiles[1] = "AnimationProfile_2.json"
		Profiles[2] = "AnimationProfile_3.json"
		Profiles[3] = "AnimationProfile_4.json"
		Profiles[4] = "AnimationProfile_5.json"
		SetMenuDialogStartIndex((Config.AnimProfile - 1))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(Profiles)
	endEvent
	event OnMenuAcceptST(int i)
		i += 1
		; Export/Set/Import profiles
		Config.SwapToProfile(ClampInt(i, 1, 5))
		SetMenuOptionValueST("Profile #"+Config.AnimProfile)
	endEvent
	event OnDefaultST()
		OnMenuAcceptST(1)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAnimationProfile")
	endEvent
endState

state RaceAdjustments
	event OnSelectST()
		Config.RaceAdjustments = !Config.RaceAdjustments
		SetToggleOptionValueST(Config.RaceAdjustments)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRaceAdjustments")
	endEvent
endState

state DisableTeleport
	event OnSelectST()
		Config.DisableTeleport = !Config.DisableTeleport
		SetToggleOptionValueST(Config.DisableTeleport)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoDisableTeleport")
	endEvent
endState

state SeedNPCStats
	event OnSelectST()
		Config.SeedNPCStats = !Config.SeedNPCStats
		SetToggleOptionValueST(Config.SeedNPCStats)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoSeedNPCStats")
	endEvent
endState

; ------------------------------------------------------- ;
; --- Player Hotkeys                                  --- ;
; ------------------------------------------------------- ;

function PlayerHotkeys()
	SetCursorFillMode(TOP_TO_BOTTOM)

	AddHeaderOption("$SSL_GlobalHotkeys")
	AddKeyMapOptionST("TargetActor", "$SSL_TargetActor", Config.TargetActor)
	AddKeyMapOptionST("ToggleFreeCamera", "$SSL_ToggleFreeCamera", Config.ToggleFreeCamera)

	AddHeaderOption("$SSL_SceneManipulation")
	AddKeyMapOptionST("RealignActors","$SSL_RealignActors", Config.RealignActors)
	AddKeyMapOptionST("EndAnimation", "$SSL_EndAnimation", Config.EndAnimation)
	AddKeyMapOptionST("AdvanceAnimation", "$SSL_AdvanceAnimationStage", Config.AdvanceAnimation)
	AddKeyMapOptionST("ChangeAnimation", "$SSL_ChangeAnimationSet", Config.ChangeAnimation)
	AddKeyMapOptionST("ChangePositions", "$SSL_SwapActorPositions", Config.ChangePositions)
	AddKeyMapOptionST("MoveSceneLocation", "$SSL_MoveSceneLocation", Config.MoveScene)

	SetCursorPosition(1)
	AddHeaderOption("$SSL_AlignmentAdjustments")
	AddTextOptionST("AdjustTargetStage", "$SSL_AdjustTargetStage", StringIfElse(Config.AdjustTargetStage, "$SSL_CurrentStage", "$SSL_AllStages"))
	AddKeyMapOptionST("AdjustStage", StringIfElse(Config.AdjustTargetStage, "$SSL_AdjustAllStages", "$SSL_AdjustStage"), Config.AdjustStage)
	AddKeyMapOptionST("BackwardsModifier", "$SSL_ReverseDirectionModifier", Config.Backwards)
	AddKeyMapOptionST("AdjustChange","$SSL_ChangeActorBeingMoved", Config.AdjustChange)
	AddKeyMapOptionST("AdjustForward","$SSL_MoveActorForwardBackward", Config.AdjustForward)
	AddKeyMapOptionST("AdjustUpward","$SSL_AdjustPositionUpwardDownward", Config.AdjustUpward)
	AddKeyMapOptionST("AdjustSideways","$SSL_MoveActorLeftRight", Config.AdjustSideways)
	AddKeyMapOptionST("AdjustSchlong","$SSL_AdjustSchlong", Config.AdjustSchlong)
	AddKeyMapOptionST("RotateScene", "$SSL_RotateScene", Config.RotateScene)
	AddKeyMapOptionST("RestoreOffsets","$SSL_DeleteSavedAdjustments", Config.RestoreOffsets)
endFunction

bool function KeyConflict(int newKeyCode, string conflictControl, string conflictName)
	bool continue = true
	if (conflictControl != "")
		string msg
		if (conflictName != "")
			msg = "This key is already mapped to: \n'" + conflictControl + "'\n(" + conflictName + ")\n\nAre you sure you want to continue?"
		else
			msg = "This key is already mapped to: \n'" + conflictControl + "'\n\nAre you sure you want to continue?"
		endIf
		continue = ShowMessage(msg, true, "$Yes", "$No")
	endIf
	return !continue
endFunction

state AdjustStage
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdjustStage = newKeyCode
			SetKeyMapOptionValueST(Config.AdjustStage)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdjustStage = 157
		SetKeyMapOptionValueST(Config.AdjustStage)
	endEvent
	event OnHighlightST()
		SetInfoText(StringIfElse(Config.AdjustTargetStage, "$SSL_InfoAdjustAllStages", "$SSL_InfoAdjustStage"))
	endEvent
endState
state AdjustChange
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdjustChange = newKeyCode
			SetKeyMapOptionValueST(Config.AdjustChange)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdjustChange = 37
		SetKeyMapOptionValueST(Config.AdjustChange)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdjustChange")
	endEvent
endState
state AdjustForward
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdjustForward = newKeyCode
			SetKeyMapOptionValueST(Config.AdjustForward)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdjustForward = 38
		SetKeyMapOptionValueST(Config.AdjustForward)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdjustForward")
	endEvent
endState
state AdjustUpward
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdjustUpward = newKeyCode
			SetKeyMapOptionValueST(Config.AdjustUpward)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdjustUpward = 39
		SetKeyMapOptionValueST(Config.AdjustUpward)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdjustUpward")
	endEvent
endState
state AdjustSideways
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdjustSideways = newKeyCode
			SetKeyMapOptionValueST(Config.AdjustSideways)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdjustSideways = 40
		SetKeyMapOptionValueST(Config.AdjustSideways)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdjustSideways")
	endEvent
endState
state AdjustSchlong
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdjustSchlong = newKeyCode
			SetKeyMapOptionValueST(Config.AdjustSchlong)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdjustSchlong = 46
		SetKeyMapOptionValueST(Config.AdjustSchlong)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdjustSchlong")
	endEvent
endState
state RotateScene
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.RotateScene = newKeyCode
			SetKeyMapOptionValueST(Config.RotateScene)
		endIf
	endEvent
	event OnDefaultST()
		Config.RotateScene = 22
		SetKeyMapOptionValueST(Config.RotateScene)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRotateScene")
	endEvent
endState
state RestoreOffsets
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.RestoreOffsets = newKeyCode
			SetKeyMapOptionValueST(Config.RestoreOffsets)
		endIf
	endEvent
	event OnDefaultST()
		Config.RestoreOffsets = 12
		SetKeyMapOptionValueST(Config.RestoreOffsets)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRestoreOffsets")
	endEvent
endState

state RealignActors
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.RealignActors = newKeyCode
			SetKeyMapOptionValueST(Config.RealignActors)
		endIf
	endEvent
	event OnDefaultST()
		Config.RealignActors = 26
		SetKeyMapOptionValueST(Config.RealignActors)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRealignActors")
	endEvent
endState
state AdvanceAnimation
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.AdvanceAnimation = newKeyCode
			SetKeyMapOptionValueST(Config.AdvanceAnimation)
		endIf
	endEvent
	event OnDefaultST()
		Config.AdvanceAnimation = 57
		SetKeyMapOptionValueST(Config.AdvanceAnimation)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdvanceAnimation")
	endEvent
endState
state ChangeAnimation
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.ChangeAnimation = newKeyCode
			SetKeyMapOptionValueST(Config.ChangeAnimation)
		endIf
	endEvent
	event OnDefaultST()
		Config.ChangeAnimation = 24
		SetKeyMapOptionValueST(Config.ChangeAnimation)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoChangeAnimation")
	endEvent
endState
state ChangePositions
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.ChangePositions = newKeyCode
			SetKeyMapOptionValueST(Config.ChangePositions)
		endIf
	endEvent
	event OnDefaultST()
		Config.ChangePositions = 13
		SetKeyMapOptionValueST(Config.ChangePositions)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoChangePositions")
	endEvent
endState
state MoveSceneLocation
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.MoveScene = newKeyCode
			SetKeyMapOptionValueST(Config.MoveScene)
		endIf
	endEvent
	event OnDefaultST()
		Config.MoveScene = 27
		SetKeyMapOptionValueST(Config.MoveScene)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoMoveScene")
	endEvent
endState
state BackwardsModifier
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.Backwards = newKeyCode
			SetKeyMapOptionValueST(Config.Backwards)
		endIf
	endEvent
	event OnDefaultST()
		Config.Backwards = 54
		SetKeyMapOptionValueST(Config.Backwards)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoBackwards")
	endEvent
endState
state EndAnimation
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.EndAnimation = newKeyCode
			SetKeyMapOptionValueST(Config.EndAnimation)
		endIf
	endEvent
	event OnDefaultST()
		Config.EndAnimation = 207
		SetKeyMapOptionValueST(Config.EndAnimation)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoEndAnimation")
	endEvent
endState
state TargetActor
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.UnregisterForKey(Config.TargetActor)
			Config.TargetActor = newKeyCode
			Config.RegisterForKey(Config.TargetActor)
			SetKeyMapOptionValueST(Config.TargetActor)
		endIf
	endEvent
	event OnDefaultST()
		Config.UnregisterForKey(Config.TargetActor)
		Config.TargetActor = 49
		Config.RegisterForKey(Config.TargetActor)
		SetKeyMapOptionValueST(Config.TargetActor)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoTargetActor")
	endEvent
endState
state ToggleFreeCamera
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		if newKeyCode == 1 || !KeyConflict(newKeyCode, conflictControl, conflictName)
			if newKeyCode == 1
				newKeyCode = -1
			endIf
			Config.UnregisterForKey(Config.ToggleFreeCamera)
			Config.ToggleFreeCamera = newKeyCode
			Config.RegisterForKey(Config.ToggleFreeCamera)
			SetKeyMapOptionValueST(Config.ToggleFreeCamera)
		endIf
	endEvent
	event OnDefaultST()
		Config.UnregisterForKey(Config.ToggleFreeCamera)
		Config.ToggleFreeCamera = 81
		Config.RegisterForKey(Config.ToggleFreeCamera)
		SetKeyMapOptionValueST(Config.ToggleFreeCamera)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoToggleFreeCamera")
	endEvent
endState
state AdjustTargetStage
	event OnSelectST()
		Config.AdjustTargetStage = !Config.AdjustTargetStage
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.AdjustTargetStage = false
		SetTextOptionValueST("$SSL_AllStages")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAdjustTargetStage")
	endEvent
endState

; ------------------------------------------------------- ;
; --- Troubleshoot                                    --- ;
; ------------------------------------------------------- ;

function Troubleshoot()
	AddTextOptionST("AnimationTrouble", "Animations Don't Play", "$SSL_ClickHere")
	AddTextOptionST("VoiceTrouble", "Characters don't play any moans during animation", "$SSL_ClickHere")
	AddTextOptionST("LipSyncTrouble", "Characters don't lipsync their moans", "$SSL_ClickHere")
endFunction

state AnimationTrouble
	event OnSelectST()
		if ShowMessage("To perform this test, you will need to find a safe location to wait while the tests are performed. Are you in a safe location?", true, "$Yes", "$No")
			ShowMessage("Close all menus to continue...", false)
			Utility.Wait(0.1)
			(Quest.GetQuest("SexLabTroubleshoot") as sslTroubleshoot).PerformTests("FNIS,ThreadSlots,AnimSlots")
		endIf
	endEvent
endState

state VoiceTrouble
	event OnSelectST()
		if ShowMessage("To perform this test, you will need to find a safe location to wait while the tests are performed. Are you in a safe location?", true, "$Yes", "$No")
			ShowMessage("Close all menus to continue...", false)
			Utility.Wait(0.1)
			(Quest.GetQuest("SexLabTroubleshoot") as sslTroubleshoot).PerformTests("VoiceSlots,PlayVoice")
		endIf
	endEvent
endState

state LipSyncTrouble
	event OnSelectST()
		if ShowMessage("To perform this test, you will need to find a safe location to wait while the tests are performed. Are you in a safe location?", true, "$Yes", "$No")
			ShowMessage("Close all menus to continue...", false)
			Utility.Wait(0.1)
			(Quest.GetQuest("SexLabTroubleshoot") as sslTroubleshoot).PerformTests("PlayVoice,LipSync")
		endIf
	endEvent
endState

; ------------------------------------------------------- ;
; --- Sound Settings                                  --- ;
; ------------------------------------------------------- ;

function SoundSettings()
	SetCursorFillMode(LEFT_TO_RIGHT)

	; Voices & SFX
	AddMenuOptionST("PlayerVoice","$SSL_PCVoice", VoiceSlots.GetSavedName(PlayerRef))
	AddEmptyOption()
	; AddToggleOptionST("NPCSaveVoice","$SSL_NPCSaveVoice", Config.NPCSaveVoice)
	AddMenuOptionST("TargetVoice","$SSL_Target{"+TargetName+"}Voice", VoiceSlots.GetSavedName(TargetRef), TargetFlag)
	AddSliderOptionST("VoiceVolume","$SSL_VoiceVolume", (Config.VoiceVolume * 100), "{0}%")
	AddSliderOptionST("SFXVolume","$SSL_SFXVolume", (Config.SFXVolume * 100), "{0}%")
	AddSliderOptionST("MaleVoiceDelay","$SSL_MaleVoiceDelay", Config.MaleVoiceDelay, "$SSL_Seconds")
	AddSliderOptionST("SFXDelay","$SSL_SFXDelay", Config.SFXDelay, "$SSL_Seconds")
	AddSliderOptionST("FemaleVoiceDelay","$SSL_FemaleVoiceDelay", Config.FemaleVoiceDelay, "$SSL_Seconds")

	; Toggle Voices
	AddHeaderOption("$SSL_ToggleVoices")
	AddHeaderOption("")
	int i
	while i < VoiceSlots.Slotted
		sslBaseVoice Voice = VoiceSlots.GetBySlot(i)
		if Voice
			AddToggleOptionST("Voice_"+i, Voice.Name, Voice.Enabled)
		endIf
		i += 1
	endWhile
endFunction

; ------------------------------------------------------- ;
; --- Animation Editor                                --- ;
; ------------------------------------------------------- ;

; Current edit target
sslThreadController ThreadControlled
sslBaseAnimation Animation
sslBaseAnimation ControlledAnimation
sslAnimationSlots AnimationSlots
bool PreventOverwrite
bool IsCreatureEditor
bool AutoRealign
string AdjustKey
int Position
int AnimEditPage
float[] AnimOffsets ; = forward, side, up, rotate

function AnimationEditor()
	SetCursorFillMode(LEFT_TO_RIGHT)

	; Auto select players animation if they are animating right now
	if !PreventOverwrite 
		ThreadControlled = Config.GetThreadControlled()
		if !(ThreadControlled && (ThreadControlled.GetState() == "Animating" || ThreadControlled.GetState() == "Advancing"))
			if TargetRef && TargetRef != none && TargetRef.IsInFaction(Config.AnimatingFaction)
				ThreadControlled = ThreadSlots.GetActorController(TargetRef)
			endIf
			if !(ThreadControlled && (ThreadControlled.GetState() == "Animating" || ThreadControlled.GetState() == "Advancing"))
				if PlayerRef.IsInFaction(Config.AnimatingFaction)
					ThreadControlled = ThreadSlots.GetActorController(PlayerRef)
				endIf
			endIf
		endIf
		if ThreadControlled && ThreadControlled.Animation
			PreventOverwrite = true
			Position  = ThreadControlled.GetAdjustPos()
			Animation = ThreadControlled.Animation
			ControlledAnimation = ThreadControlled.Animation
			AdjustKey = ThreadControlled.AdjustKey
		endIf
	endIf

	; Pick a default animation
	if !Animation
		Position  = 0
		Animation = AnimSlots.GetBySlot(0)
		AdjustKey = "Global"
		IsCreatureEditor = false
	endIf

	; Check if editing a creature animation
	AnimationSlots   = AnimSlots
	IsCreatureEditor = Animation.IsCreature
	if IsCreatureEditor
		AnimationSlots = CreatureSlots
	endIf

	; Set current pagination settings
	PerPage      = 125
	LastPage     = AnimationSlots.PageCount(PerPage)
	AnimEditPage = AnimationSlots.FindPage(Animation.Registry, PerPage)

	; Adjustkeys for current animation
	AdjustKeys    = new string[1]
	AdjustKeys[0] = "Animation"
	AdjustKeys = MergeStringArray(AdjustKeys, Animation.GetAdjustKeys())

	; Show editor options
	SetTitleText(Animation.Name)
	AddMenuOptionST("AnimationSelect", "$SSL_Animation", Animation.Name)
	AddToggleOptionST("AnimationEnabled", "$SSL_Enabled", Animation.Enabled)

	AddMenuOptionST("AnimationAdjustKey", "$SSL_AdjustmentProfile", AdjustKey)
	if AdjustKey == "Animation"
		string Type = "Bed"
		Type = "Bed"
		AnimOffsets = Animation.GetBedOffsets()
		if (Animation.PositionCount == 1 && (!IsCreatureEditor || (Animation.HasActorRace(PlayerRef) || (TargetRef && Animation.HasActorRace(PlayerRef))))) || (Animation.PositionCount >= 2 && TargetRef && (!IsCreatureEditor || (Animation.HasActorRace(PlayerRef) || Animation.HasActorRace(TargetRef))))
			AddTextOptionST("AnimationTest", "$SSL_PlayAnimation", "$SSL_ClickHere")
		else
			AddTextOptionST("AnimationTest", "$SSL_PlayAnimation", "$SSL_ClickHere", OPTION_FLAG_DISABLED)
		endIf
		
		AddHeaderOption(Type + " Adjustments")
		AddHeaderOption("")

		AddSliderOptionST("AnimationOffset_"+Type+"_0", "$SSL_AdjustForwards", AnimOffsets[0], "{2}")
		AddSliderOptionST("AnimationOffset_"+Type+"_1", "$SSL_AdjustSideways", AnimOffsets[1], "{2}")
		AddSliderOptionST("AnimationOffset_"+Type+"_2", "$SSL_AdjustUpwards",  AnimOffsets[2], "{2}")
		AddSliderOptionST("AnimationOffset_"+Type+"_3", "$SSL_AdjustRotation",  AnimOffsets[3], "{0}")
	else
		AddMenuOptionST("AnimationPosition", "$SSL_Position", "$SSL_{"+GenderLabel(Animation.GetGender(Position))+"}Gender{"+(Position + 1)+"}Position")

		AddMenuOptionST("AnimationAdjustCopy", "$SSL_CopyFromProfile", "$SSL_Select")

		if (Animation.PositionCount == 1 && (!IsCreatureEditor || (Animation.HasActorRace(PlayerRef) || (TargetRef && Animation.HasActorRace(PlayerRef))))) || (Animation.PositionCount >= 2 && TargetRef && (!IsCreatureEditor || (Animation.HasActorRace(PlayerRef) || Animation.HasActorRace(TargetRef))))
			AddTextOptionST("AnimationTest", "$SSL_PlayAnimation", "$SSL_ClickHere")
		else
			AddTextOptionST("AnimationTest", "$SSL_PlayAnimation", "$SSL_ClickHere", OPTION_FLAG_DISABLED)
		endIf

		string Profile
		if AdjustKey && AdjustKey != "Global"
			string[] RaceIDs = StringSplit(AdjustKey, ".")
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
			if RaceRef
				id = RaceRef.GetName()
			elseIf id != "human"
				id = RaceIDs[Position]
			endIf
			Profile = "$SSL_{"+id+"}-{"+GenderLabel(Gender)+"}"
		else
			Profile = "$SSL_{Global}-{"+GenderLabel(Animation.GetGender(Position))+"}"
		endIf

		int Stage = 1
		while Stage <= Animation.StageCount

			float[] Adjustments = Animation.GetPositionAdjustments(AdjustKey, Position, Stage)
			; Log(Adjustments, "AnimationEditor("+AdjustKey+", "+Position+", "+Stage+")")

			AddHeaderOption("$SSL_Stage{"+Stage+"}Adjustments")
			AddHeaderOption(Profile)

			AddSliderOptionST("Adjust_"+Stage+"_0", "$SSL_AdjustForwards", Adjustments[0], "{2}")
			AddSliderOptionST("Adjust_"+Stage+"_1", "$SSL_AdjustSideways", Adjustments[1], "{2}")
			AddSliderOptionST("Adjust_"+Stage+"_2", "$SSL_AdjustUpwards",  Adjustments[2], "{2}")
			AddSliderOptionST("Adjust_"+Stage+"_3", "$SSL_SchlongUpDown",  Adjustments[3], "{0}")

			Stage += 1
		endWhile
	endIf
endFunction

string function GenderLabel(string id)
	if id == "0" || id == "M"
		return "$SSL_Male"
	elseIf id == "1" || id == "F"
		return "$SSL_Female"
	elseIf id >= "2" || id == "C"
		return "$SSL_Creature"
	endIf
	return "$SSL_Unknown"
endFunction

string[] PageOptions
string[] MenuOptions
string[] AdjustKeys

state AnimationEnabled
	event OnSelectST()
		Animation.Enabled = !Animation.Enabled
		SetToggleOptionValueST(Animation.Enabled)
		if Animation.Enabled
			if Animation.IsCreature
				CreatureSlots.InvalidateByTags(PapyrusUtil.StringJoin(Animation.GetRawTags()))
			else
				AnimationSlots.InvalidateByTags(PapyrusUtil.StringJoin(Animation.GetRawTags()))
			endIf
		else
			if Animation.IsCreature
				CreatureSlots.InvalidateByAnimation(Animation)
			else
				AnimationSlots.InvalidateByAnimation(Animation)
			endIf
		endIf
	endEvent
	event OnDefaultST()
		Animation.Enabled = true
		SetToggleOptionValueST(Animation.Enabled)
		if Animation.IsCreature
			CreatureSlots.InvalidateByTags(PapyrusUtil.StringJoin(Animation.GetRawTags()))
		else
			AnimationSlots.InvalidateByTags(PapyrusUtil.StringJoin(Animation.GetRawTags()))
		endIf
	endEvent
endState

state AnimationSelect

	event OnMenuOpenST()
		if Config.AllowCreatures
			PageOptions = PaginationMenu(StringIfElse(IsCreatureEditor, "$SSL_SwitchNormalAnimationEditor", "$SSL_SwitchCreatureAnimationEditor"), "", AnimEditPage)
		else
			PageOptions = PaginationMenu("", "", AnimEditPage)
		endIf
		MenuOptions = MergeStringArray(PageOptions, AnimationSlots.GetSlotNames(AnimEditPage, PerPage))
		SetMenuDialogOptions(MenuOptions)
		int MenuIndex = MenuOptions.Find(Animation.Name)
		if !MenuIndex
			MenuIndex = PageOptions.Length - 1
		endIf
		SetMenuDialogStartIndex(MenuIndex)
		SetMenuDialogDefaultIndex(MenuIndex)
	endEvent

	event OnMenuAcceptST(int i)
		if i >= 0
			AdjustKey = "Global"
			Position  = 0
			if MenuOptions[i] == "$SSL_SwitchNormalAnimationEditor" || MenuOptions[i] == "$SSL_SwitchCreatureAnimationEditor"
				if IsCreatureEditor
					IsCreatureEditor = false
					Animation = AnimSlots.GetBySlot(0)
				else
					IsCreatureEditor = true
					Animation = CreatureSlots.GetBySlot(0)
				endIf
			elseIf MenuOptions[i] == "$SSL_PrevPage"
				Animation = AnimationSlots.GetBySlot(((AnimEditPage - 2) * PerPage))
			elseIf MenuOptions[i] == "$SSL_NextPage"
				Animation = AnimationSlots.GetBySlot((AnimEditPage * PerPage))
			else
				i -= PageOptions.Length
				i += ((AnimEditPage - 1) * PerPage)
				Animation = AnimationSlots.GetBySlot(i)
			endIf		
			SetMenuOptionValueST(Animation.Name)
			ForcePageReset()
		endIf
	endEvent
	
	event OnDefaultST()
		if IsCreatureEditor
			Animation = CreatureSlots.GetBySlot(0)
		else
			Animation = AnimSlots.GetBySlot(0)
		endIf
		AdjustKey = "Global"
		Position  = 0
		SetMenuOptionValueST(Animation.Name)
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText(Animation.Name+" Tags:\n"+StringJoin(Animation.GetTags(), ", "))
	endEvent
endState

state AnimationPosition
	event OnMenuOpenST()
		string[] Positions = Utility.CreateStringArray(Animation.PositionCount)
		int i = Positions.Length
		while i
			i -= 1
			Positions[i] = "$SSL_{"+GenderLabel(Animation.GetGender(i))+"}Gender{"+(i + 1)+"}Position"
		endWhile
		SetMenuDialogStartIndex(Position)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(Positions)
	endEvent
	event OnMenuAcceptST(int i)
		if i >= 0
			Position = i
			SetMenuOptionValueST("$SSL_{"+GenderLabel(Animation.GetGender(i))+"}Gender{"+(i + 1)+"}Position")
			PreventOverwrite = true
			ForcePageReset()
		endIf
	endEvent
	event OnDefaultST()
		if Position != 0
			Position = 0
			SetMenuOptionValueST(Position)
			PreventOverwrite = true
			ForcePageReset()
		endIf
	endEvent
	event OnHighlightST()
		if PreventOverwrite && Animation == ControlledAnimation && ThreadControlled != none
			Actor ActorRef = ThreadControlled.Positions[Position]
			if ActorRef && ActorRef != none
				SetInfoText(ActorRef.GetLeveledActorBase().GetName())
			endIf
		endIf
	endEvent
endState

state AnimationAdjustKey
	event OnMenuOpenST()
		SetMenuDialogStartIndex(AdjustKeys.Find(AdjustKey))
		SetMenuDialogDefaultIndex(AdjustKeys.Find("Global"))
		SetMenuDialogOptions(AdjustKeys)
	endEvent
	event OnMenuAcceptST(int i)
		AdjustKey = "Global"
		if i >= 0 && i < AdjustKeys.Length
			AdjustKey = AdjustKeys[i]
		endIf
		if Config.MirrorPress(Config.AdjustStage) && AdjustKey != "Global" && AdjustKey != "Animation" && ShowMessage("$SSL_WarnProfileRemove{"+AdjustKey+"}", true, "$Yes", "$No")
			Animation.RestoreOffsets(AdjustKey)
			AdjustKey = "Global"
		endIf
		SetMenuOptionValueST(AdjustKey)
		PreventOverwrite = true
		ForcePageReset()
	endEvent
	event OnDefaultST()
		if AdjustKey != "Global"
			AdjustKey = "Global"
			SetMenuOptionValueST(AdjustKey)
			PreventOverwrite = true
			ForcePageReset()
		endIf
	endEvent
endState

string[] TempAdjustKeys
state AnimationAdjustCopy
	event OnMenuOpenST()
		TempAdjustKeys = RemoveString(AdjustKeys,"Animation")
		SetMenuDialogStartIndex(TempAdjustKeys.Find(AdjustKey))
		SetMenuDialogDefaultIndex(TempAdjustKeys.Find("Global"))
		SetMenuDialogOptions(TempAdjustKeys)
	endEvent
	event OnMenuAcceptST(int i)
		string CopyKey = "Global"
		if i >= 0
			CopyKey = TempAdjustKeys[i]
		endIf
		if CopyKey != AdjustKey && ShowMessage("$SSL_ProfileOverwrite{"+AdjustKey+"}With{"+CopyKey+"}", true, "$Yes", "$No")
			Animation.RestoreOffsets(AdjustKey)
			int n = Animation.PositionCount
			while n
				n -= 1
				Animation.CopyAdjustmentsFrom(AdjustKey, CopyKey, n)
			endWhile
			ForcePageReset()
		endIf
		; SetMenuOptionValueST(TempAdjustKeys[i])
	endEvent
	event OnDefaultST()
		AdjustKey = "Global"
		SetMenuOptionValueST(AdjustKey)
		ForcePageReset()
	endEvent
endState

state AnimationTest
	event OnSelectST()
		if ShowMessage("About to player test animation "+Animation.Name+" for preview purposes.\n\nDo you wish to continue?", true, "$Yes", "$No")

			sslThreadModel Thread = SexLab.NewThread()
			if Thread
				sslBaseAnimation[] Anims = new sslBaseAnimation[1]
				Anims[0] = Animation
				Thread.SetForcedAnimations(Anims)
				Thread.DisableBedUse(true)
				Thread.DisableLeadIn(true)
				; select a solo actor
				if Animation.PositionCount == 1
					string RaceKey = ""
					int FindGender = Animation.GetGender(0)
					if FindGender > 1
						RaceKey = Animation.RaceType
					elseif FindGender > 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Pussy") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Futa"))
						FindGender = -1
					elseif FindGender == 0 && Config.UseStrapons && Animation.UseStrapon(0, 1)
						FindGender = -1
					endIf

					bool ValidPlayer = ThreadLib.CheckActor(PlayerRef, FindGender) && (RaceKey == "" || sslCreatureAnimationSlots.GetAllRaceKeys(PlayerRef.GetLeveledActorBase().GetRace()).Find(RaceKey) != -1)
					bool ValidTarget = ThreadLib.CheckActor(TargetRef, FindGender) && (RaceKey == "" || sslCreatureAnimationSlots.GetAllRaceKeys(TargetRef.GetLeveledActorBase().GetRace()).Find(RaceKey) != -1)
					if ValidPlayer && ValidTarget
						if ShowMessage("Which actor would you like to play the solo animation "+Animation.Name+" with?", true, TargetName, PlayerName)
							Thread.AddActor(TargetRef)
						else
							Thread.AddActor(PlayerRef)
						endIf
					elseIf ValidTarget
						Thread.AddActor(TargetRef)
					elseIf ValidPlayer
						Thread.AddActor(PlayerRef)
					else
						ShowMessage("Failed to start test animation.\n  None valid actor selected", false)
					endIf
				; Add actors
				elseIf Animation.PositionCount >= 2
					Thread.AddActors(ThreadLib.FindAnimationPartners(Animation, PlayerRef, 1500, PlayerRef, TargetRef))
				endIf
				if Animation.PositionCount != Thread.ActorCount
					ShowMessage("Failed to start test animation.\n  Animation.PositionCount["+Animation.PositionCount+"] and ActorCount["+Thread.ActorCount+"] don't match", false)
				else
					ShowMessage("Starting animation "+Animation.Name+".\n\nClose all menus and return to the game to continue...", false)
					Utility.Wait(0.5)
					if !Thread.StartThread()
						ShowMessage("Failed to start test animation.", false)
					endIf
				endIf
			else
				ShowMessage("Failed to start test animation.", false)
			endIf
		endIf
	endEvent
endState

; ------------------------------------------------------- ;
; --- Toggle Animations                               --- ;
; ------------------------------------------------------- ;

sslBaseAnimation[] AnimToggles
string[] TAModes
string[] TFAction
string[] TagCache
string TagFilter
string TagMode
bool EditTags
int TogglePage
int ta
int TFA

function AddAnimationsTag(string Tag)
	if Tag == "" || AnimToggles.Length < 1
		return
	endIf
	
	int i
	while i < AnimToggles.Length
		if AnimToggles[i] && AnimToggles[i].Registered && (!TagFilter || EditTags || AnimToggles[i].HasTag(TagFilter))
			AnimToggles[i].AddTag(Tag)
		endIf
		i += 1
	endWhile
endFunction

function RemoveAnimationsTag(string Tag)
	if Tag == "" || AnimToggles.Length < 1
		return
	endIf
	
	int i
	while i < AnimToggles.Length
		if AnimToggles[i] && AnimToggles[i].Registered && (!TagFilter || EditTags || AnimToggles[i].HasTag(TagFilter))
			AnimToggles[i].RemoveTag(Tag)
		endIf
		i += 1
	endWhile
endFunction

function ToggleAnimationsTag(string Tag)
	if Tag == "" || AnimToggles.Length < 1
		return
	endIf
	
	int i
	while i < AnimToggles.Length
		if AnimToggles[i] && AnimToggles[i].Registered && (!TagFilter || EditTags || AnimToggles[i].HasTag(TagFilter))
			AnimToggles[i].ToggleTag(Tag)
		endIf
		i += 1
	endWhile
endFunction

function ToggleAnimations()
	SetCursorFillMode(LEFT_TO_RIGHT)

	; Allow tag toggling only on main animation toggle and creature
	bool AllowTagToggle = (ta == 0 || ta == 3)

	;if !AllowTagToggle
	;	TagFilter = ""
	;	EditTags = false
	;endIf

	; Get relevant slot registry
	AnimationSlots = AnimSlots
	if ta == 3
		AnimationSlots = CreatureSlots		
	endIf

	; Setup pagination
	PerPage  = 122
	LastPage = AnimationSlots.PageCount(PerPage)
	if TogglePage > LastPage || TogglePage < 1
		TogglePage = 1
	endIf

	; Get animations to be toggled
	AnimToggles = AnimationSlots.GetSlots(TogglePage, PerPage)
	int Slotted = AnimationSlots.Slotted

	; Mode select
	if Config.AllowCreatures
		TAModes = new string[4]
		TAModes[0] = "$SSL_ToggleAnimations"
		TAModes[1] = "$SSL_ForeplayAnimations"
		TAModes[2] = "$SSL_AggressiveAnimations"
		TAModes[3] = "$SSL_CreatureAnimations"
	else
		TAModes = new string[3]
		TAModes[0] = "$SSL_ToggleAnimations"
		TAModes[1] = "$SSL_ForeplayAnimations"
		TAModes[2] = "$SSL_AggressiveAnimations"
	endIf

	TFA = 0
	If TagFilter
		if EditTags
			TFAction = new string[5]
			TFAction[0] = "$SSL_ToggleTag{"+TagFilter+"}"
			TFAction[1] = "$SSL_ToggleFilter"
			TFAction[2] = "$SSL_InvertTagFromAll{"+TagFilter+"}"
			TFAction[3] = "$SSL_AddTagToAll{"+TagFilter+"}"
			TFAction[4] = "$SSL_RemoveTagFromAll{"+TagFilter+"}"
		else
			TFAction = new string[2]
			TFAction[0] = "$SSL_ToggleAnimations"
			TFAction[1] = "$SSL_ToggleFilter"
		endIf
	elseIf ta == 1 || ta == 2
		TFAction = new string[4]
		if ta == 1
			TagMode = "LeadIn"
		else
			TagMode = "Aggressive"
		endIf
		TFAction[0] = "$SSL_ToggleTag{"+TagMode+"}"
		TFAction[1] = "$SSL_InvertTagFromAll{"+TagMode+"}"
		TFAction[2] = "$SSL_AddTagToAll{"+TagMode+"}"
		TFAction[3] = "$SSL_RemoveTagFromAll{"+TagMode+"}"
	else
		TFAction = new string[1]
		TFAction[0] = "$SSL_ToggleAnimations"
	endIf
	
	SetTitleText(TAModes[ta])
	AddMenuOptionST("TAModeSelect", "$SSL_View", TAModes[ta])

	; Page select
	AddTextOptionST("AnimationTogglePage", "Page #", TogglePage+" / "+LastPage, DoDisable(Slotted <= PerPage))


	;if AllowTagToggle
		AddMenuOptionST("FilterByTag", "Filter By Tag:", StringIfElse(!TagFilter, "---", TagFilter), DoDisable(!AllowTagToggle))
		AddMenuOptionST("FilterAction", "Action:", TFAction[TFA], DoDisable(TFAction.Length < 2))
	;	AddTextOptionST("ToggleAction", "Toggle Action:", StringIfElse(EditTags && TagFilter, "Has: \""+TagFilter+"\"", "$SSL_DoDisable"), DoDisable(!TagFilter))
	;endIf

	AddHeaderOption("")
	AddHeaderOption("")

	int i
	while i < AnimToggles.Length
		if AnimToggles[i] && AnimToggles[i].Registered && (!TagFilter || EditTags || AnimToggles[i].HasTag(TagFilter))
			AddToggleOptionST("Animation_"+i, AnimToggles[i].Name, GetToggle(AnimToggles[i]))
		endIf
		i += 1
	endWhile
endFunction

bool function GetToggle(sslBaseAnimation Anim)
	if ta == 1
		return Anim.HasTag("LeadIn")
	elseIf ta == 2
		return Anim.HasTag("Aggressive")
	elseIf EditTags
		return Anim.HasTag(TagFilter)
	else
		return Anim.Enabled
	endIf
endFunction

state TAModeSelect
	event OnMenuOpenST()
		SetMenuDialogStartIndex(ta)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(TAModes)
	endEvent
	event OnMenuAcceptST(int i)
		if i != ta
			TagFilter = ""
			EditTags = false
		endIf
		ta = i
		TogglePage = 1
		SetMenuOptionValueST(TAModes[ta])
		ForcePageReset()
	endEvent
	event OnDefaultST()
		ta = 0
		TogglePage = 1
		SetMenuOptionValueST(TAModes[ta])
		ForcePageReset()
	endEvent
endState

state AnimationTogglePage
	event OnSelectST()
		TogglePage += 1
		if TogglePage > LastPage
			TogglePage = 1
		endIf
		SetTextOptionValueST(TogglePage)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		TogglePage = 1
		SetTextOptionValueST(TogglePage)
	endEvent
	event OnHighlightST()
		SetInfoText("")
	endEvent
endState

state FilterByTag
	event OnMenuOpenST()
		TagCache    = new string[1]
		TagCache[0] = "( NONE )"
		if ta == 3
			TagCache = MergeStringArray(TagCache, AnimationSlots.GetTagCache())
		else
			TagCache = MergeStringArray(TagCache, RemoveString(RemoveString(AnimationSlots.GetTagCache(),"LeadIn"),"Aggressive"))
		endIf
		SortStringArray(TagCache)
		if TagFilter && TagCache.Find(TagFilter) != -1
			SetMenuDialogStartIndex(TagCache.Find(TagFilter))
		else
			SetMenuDialogStartIndex(0)
		endIf
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(TagCache)
	endEvent
	event OnMenuAcceptST(int i)
		TagFilter = StringIfElse(i < 1, "", TagCache[i])
		TagCache = Utility.CreateStringArray(0)
		TogglePage = 1
		SetMenuOptionValueST(TagFilter)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		TagFilter = ""
		TogglePage = 1
		SetMenuOptionValueST(TAModes[ta])
		ForcePageReset()
	endEvent
endState

state FilterAction
	event OnMenuOpenST()
		SetMenuDialogStartIndex(TFA)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(TFAction)
	endEvent
	event OnMenuAcceptST(int i)
		if i >= 0
			TFA = i
		endIf
		SetMenuOptionValueST(TFAction[TFA])
		if TagFilter
			if TFA == 1
				EditTags = !EditTags
			elseIf TFA == 2
				if ShowMessage("$SSL_WarnInvertTagFromAll{"+TagFilter+"}", true, "$Yes", "$No")
					ToggleAnimationsTag(TagFilter)
				endIf
			elseIf TFA == 3
				if ShowMessage("$SSL_WarnAddTagToAll{"+TagFilter+"}", true, "$Yes", "$No")
					AddAnimationsTag(TagFilter)
				endIf
			elseIf TFA == 4
				if ShowMessage("$SSL_WarnRemoveTagFromAll{"+TagFilter+"}", true, "$Yes", "$No")
					RemoveAnimationsTag(TagFilter)
				endIf
			endIf
			ForcePageReset()
		elseIf ta == 1 || ta == 2
			TFAction = new string[4]
			if TFA == 1
				if ShowMessage("$SSL_WarnInvertTagFromAll{"+TagMode+"}", true, "$Yes", "$No")
					ToggleAnimationsTag(TagMode)
				endIf
			elseIf TFA == 2
				if ShowMessage("$SSL_WarnAddTagToAll{"+TagMode+"}", true, "$Yes", "$No")
					AddAnimationsTag(TagMode)
				endIf
			elseIf TFA == 3
				if ShowMessage("$SSL_WarnRemoveTagFromAll{"+TagMode+"}", true, "$Yes", "$No")
					RemoveAnimationsTag(TagMode)
				endIf
			endIf
			if TFA != 0
				ForcePageReset()
			endIf
		endIf
	endEvent
	event OnDefaultST()
		TFA = 0
		SetMenuOptionValueST(TFAction[TFA])
	endEvent
endState

state ToggleAction
	event OnSelectST()
		EditTags = !EditTags
		ForcePageReset()
	endEvent
	event OnDefaultST()
		EditTags = false
		SetTextOptionValueST("Enable/Disable")
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("")
	endEvent
endState



; ------------------------------------------------------- ;
; --- Toggle Expressions                              --- ;
; ------------------------------------------------------- ;

function ToggleExpressions()
	SetCursorFillMode(LEFT_TO_RIGHT)

	int flag = 0x00
	if !Config.UseExpressions
		AddHeaderOption("$SSL_ExpressionsDisabled")
		AddToggleOptionST("UseExpressions","$SSL_UseExpressions", Config.UseExpressions)
		flag = OPTION_FLAG_DISABLED
	endIf

	AddHeaderOption("$SSL_ExpressionsNormal")
	AddHeaderOption("")
	int i
	while i < ExpressionSlots.Slotted
		sslBaseExpression Exp = ExpressionSlots.Expressions[i]
		if Exp.Registered && Exp.Enabled
			AddToggleOptionST("Expression_Normal_"+i, Exp.Name, Exp.HasTag("Normal") && flag == 0x00, flag)
		endIf
		i += 1
	endWhile

	if ExpressionSlots.Slotted % 2 != 0
		AddEmptyOption()
	endIf

	AddHeaderOption("$SSL_ExpressionsVictim")
	AddHeaderOption("")
	i = 0
	while i < ExpressionSlots.Slotted
		sslBaseExpression Exp = ExpressionSlots.Expressions[i]
		if Exp.Registered && Exp.Enabled
			AddToggleOptionST("Expression_Victim_"+i, Exp.Name, Exp.HasTag("Victim") && flag == 0x00, flag)
		endIf
		i += 1
	endWhile

	if ExpressionSlots.Slotted % 2 != 0
		AddEmptyOption()
	endIf

	AddHeaderOption("$SSL_ExpressionsAggressor")
	AddHeaderOption("")

	i = 0
	while i < ExpressionSlots.Slotted
		sslBaseExpression Exp = ExpressionSlots.Expressions[i]
		if Exp.Registered && Exp.Enabled
			AddToggleOptionST("Expression_Aggressor_"+i, Exp.Name, Exp.HasTag("Aggressor") && flag == 0x00, flag)
		endIf
		i += 1
	endWhile
endFunction

; ------------------------------------------------------- ;
; --- Matchmaker	                                  --- ;
; ------------------------------------------------------- ;

Function MatchMaker()
	SetCursorFillMode(TOP_TO_BOTTOM)
	int flag = DoDisable(!Config.MatchMaker)
	AddToggleOptionST("ToggleMatchMaker", "$SSL_ToggleMatchMaker", Config.MatchMaker)
	AddHeaderOption("$SSL_MatchMakerTagsSettings", flag)
	AddTextOptionST("InputTags", "$SSL_InputTags", sslSystemConfig.ParseMMTagString(), flag)
	AddInputOptionST("InputRequiredTags", "$SSL_InputRequiredTags", Config.RequiredTags, flag)
	AddInputOptionST("InputExcludedTags", "$SSL_InputExcludedTags", Config.ExcludedTags, flag)
	AddInputOptionST("InputOptionalTags", "$SSL_InputOptionalTags", Config.OptionalTags, flag)
	AddTextOptionST("TextResetTags", "$SSL_TextResetTags", "$SSL_ResetTagsHere", flag)
	SetCursorPosition(1)
	AddHeaderOption("$SSL_MatchMakerActorSettings", flag)
	AddToggleOptionST("ToggleSubmissivePlayer", "$SSL_ToggleSubmissivePlayer", Config.SubmissivePlayer, flag)
	AddToggleOptionST("ToggleSubmissiveTarget", "$SSL_ToggleSubmissiveTarget", Config.SubmissiveTarget, flag)
EndFunction

State ToggleMatchMaker
	; IDEA: Have this be saved natively and read it on game init/reload, add remove Spells based on it
	Event OnSelectST()
		Config.MatchMaker = !Config.MatchMaker
		SetToggleOptionValueST(Config.MatchMaker)
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		Config.MatchMaker = false
		SetToggleOptionValueST(Config.MatchMaker)
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SSL_InfoMatchMaker")
	EndEvent
EndState

; ------------------------------------------------------- ;
; --- Expression Editor                               --- ;
; ------------------------------------------------------- ;

; Current edit target
sslBaseExpression Expression
bool EditOpenMouth
int Phase
; Type flags
int property Male = 0 autoreadonly
int property Female = 1 autoreadonly
int property Phoneme = 0 autoreadonly
int property Modifier = 16 autoreadonly
int property Mood = 30 autoreadonly
; Labels
string[] Phases
string[] Moods
string[] Phonemes
string[] Modifiers
string[] SoundTreatment

function ExpressionEditor()
	SetCursorFillMode(LEFT_TO_RIGHT)

	if !Expression
		Expression = ExpressionSlots.GetBySlot(0)
		Phase = 1
	endIf

	int FlagF = OPTION_FLAG_NONE
	int FlagM = OPTION_FLAG_NONE
	if Phase > Expression.PhasesFemale
		FlagF = OPTION_FLAG_DISABLED
	endIf
	if Phase > Expression.PhasesMale
		FlagM = OPTION_FLAG_DISABLED
	endIf

	; Left
	; 0. OpenMouth Config
	; 1. Name
	; 2. Normal Tag
	; 3. Victim Tag
	; 4. Aggressor Tag
	; 5. Phase Select

	; Right
	; 0. OpenMouth Config
	; 1. <empty>
	; 2. Export Expression
	; 3. Import Expression
	; 4. Player Test
	; 5. Target Test

	; 0
	if EditOpenMouth
		SetTitleText("$SSL_OpenMouthSyncLipsConfig")

		AddHeaderOption("$SSL_OpenMouthConfig")
		AddHeaderOption("")

		AddSliderOptionST("OpenMouthSize","$SSL_OpenMouthSize", Config.OpenMouthSize, "{0}%")

		AddTextOptionST("AdvancedOpenMouth", "$SSL_EditExpression", "$SSL_ClickHere")

		AddToggleOptionST("OpenMouthExpression_1", "Use Alt Female Expression", Config.GetOpenMouthExpression(True) == 15)
		AddToggleOptionST("OpenMouthExpression_0", "Use Alt Male Expression", Config.GetOpenMouthExpression(False) == 15)

		AddTextOptionST("ExpressionTestPlayer", "$SSL_TestOnPlayer", "$SSL_Apply")
		AddTextOptionST("ExpressionTestTarget", "$SSL_TestOn{"+TargetName+"}", "$SSL_Apply", SexLabUtil.IntIfElse((!TargetRef), OPTION_FLAG_DISABLED, OPTION_FLAG_NONE))

		; OpenMouth Phoneme settings
		AddHeaderOption("$SSL_{$SSL_Female}-{$SSL_Phoneme}")
		AddHeaderOption("$SSL_{$SSL_Male}-{$SSL_Phoneme}")

		int i = 0
		while i <= 15
			AddSliderOptionST("OpenMouth_1_"+i, Phonemes[i], sslSystemConfig.GetSettingFltA("fOpenMouthFemale", i) * 100, "{0}")
			AddSliderOptionST("OpenMouth_0_"+i, Phonemes[i], sslSystemConfig.GetSettingFltA("fOpenMouthMale", i) * 100, "{0}")
			i += 1
		endWhile

		AddHeaderOption("$SSL_SyncLipsConfig")
		AddHeaderOption("")


		AddMenuOptionST("LipsPhoneme", "$SSL_LipsPhoneme", SexLabUtil.StringIfElse(Config.LipsPhoneme >= 0, Phonemes[ClampInt(Config.LipsPhoneme, 0, 15)], "$SSL_Automatic"))
		AddToggleOptionST("LipsFixedValue", "$SSL_LipsFixedValue", Config.LipsFixedValue)

		AddSliderOptionST("LipsMinValue", "$SSL_LipsMinValue", Config.LipsMinValue, "{0}")
		AddSliderOptionST("LipsMaxValue", "$SSL_LipsMaxValue", Config.LipsMaxValue, "{0}")

		AddTextOptionST("LipsSoundTime", "$SSL_LipsSoundTime", SoundTreatment[ClampInt(Config.LipsSoundTime + 1, 0, 2)])
		AddSliderOptionST("LipsMoveTime", "$SSL_LipsMoveTime", Config.LipsMoveTime, "$SSL_Seconds")

		return ; to hide the rest of the options

	else
		SetTitleText(Expression.Name)

		AddHeaderOption("$SSL_OpenMouthConfig")
		AddHeaderOption("")

		AddSliderOptionST("OpenMouthSize","$SSL_OpenMouthSize", Config.OpenMouthSize, "{0}%")
		AddTextOptionST("AdvancedOpenMouth", "$SSL_EditOpenMouth", "$SSL_ClickHere")

	endIf

	; 1
	AddHeaderOption("$SSL_ExpressionEditor")
	AddHeaderOption("")

	AddMenuOptionST("ExpressionSelect", "$SSL_ModifyingExpression", Expression.Name)
	AddToggleOptionST("ExpressionEnabled", "$SSL_Enabled", Expression.Enabled)

	; 2
	AddToggleOptionST("ExpressionNormal", "$SSL_ExpressionsNormal", Expression.HasTag("Normal"))
	AddTextOptionST("ExportExpression", "$SSL_ExportExpression", "$SSL_ClickHere")

	; 3
	AddToggleOptionST("ExpressionVictim", "$SSL_ExpressionsVictim", Expression.HasTag("Victim"))
	AddTextOptionST("ImportExpression", "$SSL_ImportExpression", "$SSL_ClickHere")

	; 4
	AddToggleOptionST("ExpressionAggressor", "$SSL_ExpressionsAggressor", Expression.HasTag("Aggressor"))
	AddTextOptionST("ExpressionTestPlayer", "$SSL_TestOnPlayer", "$SSL_Apply")

	; AddTextOptionST("ExpressionCopyFromPlayer", "$SSL_ExpressionCopyFrom", "$SSL_ClickHere")
	; AddTextOptionST("ExpressionCopyFromTarget", "$SSL_ExpressionCopyFrom", "$SSL_ClickHere", Math.LogicalAnd(OPTION_FLAG_NONE, (TargetRef == none) as int))

	; 5
	AddMenuOptionST("ExpressionPhase", "$SSL_Modifying{"+Expression.Name+"}Phase", Phase)
	AddTextOptionST("ExpressionTestTarget", "$SSL_TestOn{"+TargetName+"}", "$SSL_Apply", SexLabUtil.IntIfElse(!TargetRef, OPTION_FLAG_DISABLED, OPTION_FLAG_NONE))

	; Show expression customization options
	float[] FemaleModifiers = Expression.GetModifiers(Phase, Female)
	float[] FemalePhonemes  = Expression.GetPhonemes(Phase, Female)

	float[] MaleModifiers   = Expression.GetModifiers(Phase, Male)
	float[] MalePhonemes    = Expression.GetPhonemes(Phase, Male)

	; Add/Remove Female Phase
	if Phase == (Expression.PhasesFemale + 1)
		AddTextOptionST("ExpressionAddPhaseFemale", "$SSL_AddFemalePhase", "$SSL_ClickHere")
	elseIf Phase > Expression.PhasesFemale
		AddTextOptionST("ExpressionAddPhaseFemale", "$SSL_AddFemalePhase", "$SSL_ClickHere", OPTION_FLAG_DISABLED)
	elseIf Phase == Expression.PhasesFemale
		AddTextOptionST("ExpressionRemovePhaseFemale", "$SSL_RemoveFemalePhase", "$SSL_ClickHere")
	elseIf Phase < Expression.PhasesFemale
		AddTextOptionST("ExpressionRemovePhaseFemale", "$SSL_RemoveFemalePhase", "$SSL_ClickHere", OPTION_FLAG_DISABLED)
	else
		AddEmptyOption()
	endIf

	; Add/Remove Male Phase
	if Phase == (Expression.PhasesMale + 1)
		AddTextOptionST("ExpressionAddPhaseMale", "$SSL_AddMalePhase", "$SSL_ClickHere")
	elseIf Phase > Expression.PhasesMale
		AddTextOptionST("ExpressionAddPhaseMale", "$SSL_AddMalePhase", "$SSL_ClickHere", OPTION_FLAG_DISABLED)
	elseIf Phase == Expression.PhasesMale
		AddTextOptionST("ExpressionRemovePhaseMale", "$SSL_RemoveMalePhase", "$SSL_ClickHere")
	elseIf Phase < Expression.PhasesMale
		AddTextOptionST("ExpressionRemovePhaseMale", "$SSL_RemoveMalePhase", "$SSL_ClickHere", OPTION_FLAG_DISABLED)
	else
		AddEmptyOption()
	endIf

	; Expression/Mood settings
	AddHeaderOption("$SSL_{$SSL_Female}-{$SSL_Mood}", FlagF)
	AddHeaderOption("$SSL_{$SSL_Male}-{$SSL_Mood}", FlagM)

	AddMenuOptionST("MoodTypeFemale", "$SSL_MoodType", Moods[Expression.GetMoodType(Phase, Female)], FlagF)
	AddMenuOptionST("MoodTypeMale", "$SSL_MoodType", Moods[Expression.GetMoodType(Phase, Male)], FlagM)

	AddSliderOptionST("MoodAmountFemale", "$SSL_MoodStrength", Expression.GetMoodAmount(Phase, Female), "{0}", FlagF)
	AddSliderOptionST("MoodAmountMale", "$SSL_MoodStrength", Expression.GetMoodAmount(Phase, Male), "{0}", FlagM)

	; Modifier settings
	AddHeaderOption("$SSL_{$SSL_Female}-{$SSL_Modifier}", FlagF)
	AddHeaderOption("$SSL_{$SSL_Male}-{$SSL_Modifier}", FlagM)

	int i = 0
	while i <= 13
		AddSliderOptionST("Expression_1_"+Modifier+"_"+i, Modifiers[i], FemaleModifiers[i] * 100, "{0}", FlagF)
		AddSliderOptionST("Expression_0_"+Modifier+"_"+i, Modifiers[i], MaleModifiers[i] * 100, "{0}", FlagM)
		i += 1
	endWhile

	; Phoneme settings
	AddHeaderOption("$SSL_{$SSL_Female}-{$SSL_Phoneme}", FlagF)
	AddHeaderOption("$SSL_{$SSL_Male}-{$SSL_Phoneme}", FlagM)
	i = 0
	while i <= 15
		AddSliderOptionST("Expression_1_"+Phoneme+"_"+i, Phonemes[i], FemalePhonemes[i] * 100, "{0}", FlagF)
		AddSliderOptionST("Expression_0_"+Phoneme+"_"+i, Phonemes[i], MalePhonemes[i] * 100, "{0}", FlagM)
		i += 1
	endWhile
endFunction

state ExpressionSelect
	event OnMenuOpenST()
		SetMenuDialogStartIndex(ExpressionSlots.Expressions.Find(Expression))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(ExpressionSlots.GetNames(ExpressionSlots.Expressions))
	endEvent
	event OnMenuAcceptST(int i)
		if i >= 0
			Phase = 1
			Expression = ExpressionSlots.GetBySlot(i)
			SetMenuOptionValueST(Expression.Name)
			ForcePageReset()
		endIf
	endEvent
	event OnDefaultST()
		Expression = ExpressionSlots.GetBySlot(0)
		SetMenuOptionValueST(Expression.Name)
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText(Expression.Name+" Tags:\n"+StringJoin(Expression.GetTags(), ", "))
	endEvent
endState

state ExpressionPhase
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Phase - 1)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(Phases)
	endEvent
	event OnMenuAcceptST(int i)
		if i >= 0
			Phase = i + 1
			SetMenuOptionValueST(Phase)
			ForcePageReset()
		endIf
	endEvent
	event OnDefaultST()
		Phase = 1
		SetMenuOptionValueST(Phase)
		ForcePageReset()
	endEvent
endState

state ExportExpression
	event OnSelectST()
		if ShowMessage("$SSL_WarnExportExpression{"+Expression.Name+"}", true, "$Yes", "$No")
			if Expression.ExportJson()
				ShowMessage("$SSL_SuccessExportExpression")
			else
				ShowMessage("$SSL_ErrorExportExpression")
			endIf
		endIf
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoExportExpression{"+Expression.Registry+"}")
	endEvent
endState

state ImportExpression
	event OnSelectST()
		if ShowMessage("$SSL_WarnImportExpression{"+Expression.Name+"}", true, "$Yes", "$No")
			if Expression.ImportJson()
				ShowMessage("$SSL_SuccessImportExpression")
				Phase = 1
				ForcePageReset()
			else
				ShowMessage("$SSL_ErrorImportExpression")
			endIf
		endIf
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoImportExpression{"+Expression.Registry+"}")
	endEvent
endState

state ExpressionCopyFromPlayer
	event OnSelectST()
		Actor ActorRef = PlayerRef
		if TargetRef && ShowMessage("$SSL_ExpressionCopyFromTarget", true, TargetName, PlayerName)
			ActorRef == TargetRef
		endIf
		float[] Preset = sslBaseExpression.GetCurrentMFG(ActorRef)
		if PapyrusUtil.AddFloatValues(Preset) > (Preset[30] + Preset[31])
			Expression.SetPhase(Phase, ActorRef.GetLeveledActorBase().GetSex(), Preset)
		else
			ShowMessage("$SSL_ExpressionCopy{"+ActorRef.GetLeveledActorBase().GetName()+"}Empty")
		endIf
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_ExpressionCopyFromInfo")
	endEvent
endState

state ExpressionTestPlayer
	event OnSelectST()
		TestApply(PlayerRef)
	endEvent
endState

state ExpressionTestTarget
	event OnSelectST()
		TestApply(TargetRef)
	endEvent
endState

function TestApply(Actor ActorRef)
	if !ActorRef || !ActorRef.Is3DLoaded()
		return
	endIf
	string ActorName = ActorRef.GetLeveledActorBase().GetName()
	if EditOpenMouth
		if ShowMessage("$SSL_WarnTestExpression{"+ActorName+"}", true, "$Yes", "$No")
			ShowMessage("$SSL_StartTestOpenMouth", false)
			Utility.Wait(0.1)
			if ActorRef == PlayerRef
				Game.ForceThirdPerson()
			endIf
			sslBaseExpression.OpenMouth(ActorRef)
			Utility.Wait(0.1)
			Debug.Notification("$SSL_AppliedTestExpression")
			Utility.WaitMenuMode(15.0)
			sslBaseExpression.CloseMouth(ActorRef)
			ActorRef.ClearExpressionOverride()
			Debug.Notification("$SSL_RestoredTestExpression")
		endIf
	elseIf Expression && ShowMessage("$SSL_WarnTestExpression{"+ActorName+"}", true, "$Yes", "$No")
		bool testOpenMouth = false
		if ShowMessage("$SSL_WarnTestExpressionWithOpenMouth", true, "$Yes", "$No")
			testOpenMouth = true
		endIf
		ShowMessage("$SSL_StartTestExpression{"+Expression.Name+"}_{"+phase+"}", false)
		Utility.Wait(0.1)
		if ActorRef == PlayerRef
			Game.ForceThirdPerson()
		endIf
		if testOpenMouth
			sslBaseExpression.OpenMouth(ActorRef)
			Utility.Wait(1.0)
		endIf
		Expression.ApplyPhase(ActorRef, Phase, ActorRef.GetLeveledActorBase().GetSex())
		Log("Expression.Applied("+Expression.Name+") Strength:"+100+"; OpenMouth:"+testOpenMouth)
		Utility.Wait(0.1)
		Debug.Notification("$SSL_AppliedTestExpression")
		Utility.WaitMenuMode(15.0)
		sslBaseExpression.ClearMFG(ActorRef)
		ActorRef.ResetExpressionOverrides()
		ActorRef.ClearExpressionOverride()
		Debug.Notification("$SSL_RestoredTestExpression")
	endIf
endFunction

state ExpressionEnabled
	event OnSelectST()
		Expression.Enabled = !Expression.Enabled
		SetToggleOptionValueST(Expression.Enabled)
	endEvent
	event OnDefaultST()
		Expression.Enabled = Expression.HasTag("Normal") && Expression.HasTag("Victim") && Expression.HasTag("Aggressor")
		SetToggleOptionValueST(Expression.Enabled)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoExpressionEnabled")
	endEvent
endState
state ExpressionNormal
	event OnSelectST()
		Expression.ToggleTag("Normal")
		SetToggleOptionValueST(Expression.HasTag("Normal"))
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_ToggleExpressionNormal")
	endEvent
endState
state ExpressionVictim
	event OnSelectST()
		Expression.ToggleTag("Victim")
		SetToggleOptionValueST(Expression.HasTag("Victim"))
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_ToggleExpressionVictim")
	endEvent
endState
state ExpressionAggressor
	event OnSelectST()
		Expression.ToggleTag("Aggressor")
		SetToggleOptionValueST(Expression.HasTag("Aggressor"))
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_ToggleExpressionAggressor")
	endEvent
endState

state ExpressionAddPhaseFemale
	event OnSelectST()
		Expression.AddPhase(Phase, Female)
		if Phase > 1 && ShowMessage("$SSL_WarnCopyPreviousPhase", true, "$Yes", "$No")
			float[] PeviousPhase = Expression.GenderPhase((Phase - 1), Female)
			float[] NewValues = new float[32]
			int i = PeviousPhase.Length
			while i
				i -= 1
				NewValues[i] = PeviousPhase[i]
			endWhile
			Expression.SetPhase(Phase, Female, NewValues)
		endIf
		ForcePageReset()
	endEvent
endState
state ExpressionAddPhaseMale
	event OnSelectST()
		Expression.AddPhase(Phase, Male)
		if Phase > 1 && ShowMessage("$SSL_WarnCopyPreviousPhase", true, "$Yes", "$No")
			float[] PeviousPhase = Expression.GenderPhase((Phase - 1), Male)
			float[] NewValues = new float[32]
			int i = PeviousPhase.Length
			while i
				i -= 1
				NewValues[i] = PeviousPhase[i]
			endWhile
			Expression.SetPhase(Phase, Male, NewValues)
		endIf
		ForcePageReset()
	endEvent
endState

state ExpressionRemovePhaseFemale
	event OnSelectST()
		Expression.EmptyPhase(Phase, Female)
		ForcePageReset()
	endEvent
endState
state ExpressionRemovePhaseMale
	event OnSelectST()
		Expression.EmptyPhase(Phase, Male)
		ForcePageReset()
	endEvent
endState

state MoodTypeFemale
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Expression.GetMoodType(Phase, Female))
		SetMenuDialogDefaultIndex(7)
		SetMenuDialogOptions(Moods)
	endEvent
	event OnMenuAcceptST(int i)
		if i > 14
			ShowMessage("$SSL_WarnMoodForbidden{"+Moods[i]+"}")
			Expression.SetIndex(Phase, Female, Mood, 0, 0)
			SetMenuOptionValueST(Moods[0])
		elseIf i >= 0
			Expression.SetIndex(Phase, Female, Mood, 0, i)
			SetMenuOptionValueST(Moods[i])
		endIf
	endEvent
	event OnDefaultST()
		Expression.SetIndex(Phase, Female, Mood, 0, 7)
		SetMenuOptionValueST(Moods[7])
	endEvent
endState
state MoodAmountFemale
	event OnSliderOpenST()
		SetSliderDialogStartValue(Expression.GetMoodAmount(Phase, Female))
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Expression.SetIndex(Phase, Female, Mood, 1, value as int)
		SetSliderOptionValueST(value as int)
	endEvent
	event OnDefaultST()
		Expression.SetIndex(Phase, Female, Mood, 1, 50)
		SetSliderOptionValueST(50)
	endEvent
endState

state MoodTypeMale
	event OnMenuOpenST()
		SetMenuDialogStartIndex(Expression.GetMoodType(Phase, Male))
		SetMenuDialogDefaultIndex(7)
		SetMenuDialogOptions(Moods)
	endEvent
	event OnMenuAcceptST(int i)
		if i > 14
			ShowMessage("$SSL_WarnMoodForbidden{"+Moods[i]+"}")
			Expression.SetIndex(Phase, Male, Mood, 0, 0)
			SetMenuOptionValueST(Moods[0])
		elseIf i >= 0
			Expression.SetIndex(Phase, Male, Mood, 0, i)
			SetMenuOptionValueST(Moods[i])
		endIf
	endEvent
	event OnDefaultST()
		Expression.SetIndex(Phase, Male, Mood, 0, 7)
		SetMenuOptionValueST(Moods[7])
	endEvent
endState
state MoodAmountMale
	event OnSliderOpenST()
		SetSliderDialogStartValue(Expression.GetMoodAmount(Phase, Male))
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Expression.SetIndex(Phase, Male, Mood, 1, value as int)
		SetSliderOptionValueST(value as int)
	endEvent
	event OnDefaultST()
		Expression.SetIndex(Phase, Male, Mood, 1, 50)
		SetSliderOptionValueST(50)
	endEvent
endState

; ------------------------------------------------------- ;
; --- Sex Diary/Journal Editor                        --- ;
; ------------------------------------------------------- ;

Actor StatRef

function SexDiary()
	SetCursorFillMode(TOP_TO_BOTTOM)

	if TargetRef != StatRef
		AddTextOptionST("SetStatTarget", "$SSL_Viewing{"+StatRef.GetLeveledActorBase().GetName()+"}", "$SSL_View{"+TargetName+"}", TargetFlag)
	else
		AddTextOptionST("SetStatTarget", "$SSL_Viewing{"+TargetName+"}", "$SSL_View{"+PlayerName+"}")
	endIf

	AddHeaderOption("$SSL_SexualExperience")

	if Config.DebugMode 
		AddInputOptionST("SetStatTimeSpent", "$SSL_TimeSpentHavingSex", Stats.ParseTime(Stats.GetSkill(StatRef, "TimeSpent") as int))
		AddInputOptionST("SetStatVaginal", "$SSL_VaginalProficiency", Stats.GetSkillTitle(StatRef, "Vaginal"))
		AddInputOptionST("SetStatAnal", "$SSL_AnalProficiency", Stats.GetSkillTitle(StatRef, "Anal"))
		AddInputOptionST("SetStatOral", "$SSL_OralProficiency", Stats.GetSkillTitle(StatRef, "Oral"))
		AddInputOptionST("SetStatForeplay", "$SSL_ForeplayProficiency", Stats.GetSkillTitle(StatRef, "Foreplay"))
		AddInputOptionST("SetStatPure", "$SSL_SexualPurity", Stats.GetPureTitle(StatRef))
		AddInputOptionST("SetStatLewd", "$SSL_SexualPerversion", Stats.GetLewdTitle(StatRef))
	else
		AddTextOption("$SSL_TimeSpentHavingSex", Stats.ParseTime(Stats.GetSkill(StatRef, "TimeSpent") as int))
		AddTextOption("$SSL_VaginalProficiency", Stats.GetSkillTitle(StatRef, "Vaginal"))
		AddTextOption("$SSL_AnalProficiency", Stats.GetSkillTitle(StatRef, "Anal"))
		AddTextOption("$SSL_OralProficiency", Stats.GetSkillTitle(StatRef, "Oral"))
		AddTextOption("$SSL_ForeplayProficiency", Stats.GetSkillTitle(StatRef, "Foreplay"))
		AddTextOption("$SSL_SexualPurity", Stats.GetPureTitle(StatRef))
		AddTextOption("$SSL_SexualPerversion", Stats.GetLewdTitle(StatRef))
	endIf
	; AddEmptyOption()

	Actor ActorRef
	if StatRef == PlayerRef
		Actor[] PlayerPartners = Stats.MostUsedPlayerSexPartners(3)
		int i = 0
		while i < PlayerPartners.Length
			if PlayerPartners[i] != none
				AddTextOption("$SSL_MostActivePartner", PlayerPartners[i].GetLeveledActorBase().GetName()+" ("+Stats.PlayerSexCount(PlayerPartners[i])+")")
			endIf
			i += 1
		endWhile
	else
		ActorRef = Stats.LastSexPartner(StatRef)
		if ActorRef
			AddTextOption("$SSL_LastPartner", ActorRef.GetLeveledActorBase().GetName())
		endIf
	endIf

	ActorRef = Stats.LastAggressor(StatRef)
	if ActorRef
		AddTextOption("$SSL_LastAggressor", ActorRef.GetLeveledActorBase().GetName())
	endIf

	ActorRef = Stats.LastVictim(StatRef)
	if ActorRef
		AddTextOption("$SSL_LastVictim", ActorRef.GetLeveledActorBase().GetName())
	endIf


	SetCursorPosition(1)

	AddTextOptionST("ResetTargetStats", "$SSL_Reset{"+StatRef.GetLeveledActorBase().GetName()+"}Stats", "$SSL_ClickHere")

	AddHeaderOption("$SSL_SexualStats")
	AddTextOptionST("SetStatSexuality", "$SSL_Sexuality", Stats.GetSexualityTitle(StatRef))

	if Config.DebugMode 
		AddInputOptionST("SetStatMales", "$SSL_MaleSexualPartners", Stats.GetSkill(StatRef, "Males"))
		AddInputOptionST("SetStatFemales", "$SSL_FemaleSexualPartners", Stats.GetSkill(StatRef, "Females"))
		AddInputOptionST("SetStatCreatures", "$SSL_CreatureSexualPartners", Stats.GetSkill(StatRef, "Creatures"))
		AddInputOptionST("SetStatMasturbation", "$SSL_TimesMasturbated", Stats.GetSkill(StatRef, "Masturbation"))
		AddInputOptionST("SetStatAggressor", "$SSL_TimesAggressive", Stats.GetSkill(StatRef, "Aggressor"))
		AddInputOptionST("SetStatVictim", "$SSL_TimesVictim", Stats.GetSkill(StatRef, "Victim"))
		AddInputOptionST("SetStatVaginalCount", "$SSL_TimesVaginal", Stats.GetSkill(StatRef, "VaginalCount"))
		AddInputOptionST("SetStatAnalCount", "$SSL_TimesAnal", Stats.GetSkill(StatRef, "AnalCount"))
		AddInputOptionST("SetStatOralCount", "$SSL_TimesOral", Stats.GetSkill(StatRef, "OralCount"))
	else
		AddTextOption("$SSL_MaleSexualPartners", Stats.GetSkill(StatRef, "Males"))
		AddTextOption("$SSL_FemaleSexualPartners", Stats.GetSkill(StatRef, "Females"))
		AddTextOption("$SSL_CreatureSexualPartners", Stats.GetSkill(StatRef, "Creatures"))
		AddTextOption("$SSL_TimesMasturbated", Stats.GetSkill(StatRef, "Masturbation"))
		AddTextOption("$SSL_TimesAggressive", Stats.GetSkill(StatRef, "Aggressor"))
		AddTextOption("$SSL_TimesVictim", Stats.GetSkill(StatRef, "Victim"))
		AddTextOption("$SSL_TimesVaginal", Stats.GetSkill(StatRef, "VaginalCount"))
		AddTextOption("$SSL_TimesAnal", Stats.GetSkill(StatRef, "AnalCount"))
		AddTextOption("$SSL_TimesOral", Stats.GetSkill(StatRef, "OralCount"))
	endIf
	
	; Custom stats set by other mods
	if StatRef == PlayerRef
		int i = Stats.GetNumStats()
		while i
			i -= 1
			AddTextOption(Stats.GetNthStat(i), Stats.GetStatFull(StatRef, Stats.GetNthStat(i)))
		endWhile
	else
		AddTextOption("$SSL_TimesWithPlayer", Stats.PlayerSexCount(StatRef))
	endIf
endFunction

state SetStatTarget
	event OnSelectST()
		if StatRef == PlayerRef && TargetRef
			StatRef = TargetRef
		else
			StatRef = PlayerRef
		endIf
		ForcePageReset()
	endEvent
endState
state SetStatSexuality
	event OnSelectST()
		int Ratio = Stats.GetSexuality(StatRef)
		if Stats.IsStraight(StatRef)
			Stats.SetSkill(StatRef, "Sexuality", 50)
		elseIf Stats.IsBisexual(StatRef)
			Stats.SetSkill(StatRef, "Sexuality", 1)
		else
			Stats.SetSkill(StatRef, "Sexuality", 100)
		endIf
		SetTextOptionValueST(Stats.GetSexualityTitle(StatRef))
	endEvent
endState

bool EmptyStatToggle
state ResetTargetStats
	event OnSelectST()
		if ShowMessage("$SSL_WarnReset{"+StatRef.GetLeveledActorBase().GetName()+"}Stats")
			EmptyStatToggle = !EmptyStatToggle
			if EmptyStatToggle || StatRef == PlayerRef
				Stats.EmptyStats(StatRef)
			else
				Stats.ResetStats(StatRef)
			endIf
			ForcePageReset()
		endIf
	endEvent
endState

; ------------------------------------------------------- ;
; --- Timers & Stripping                              --- ;
; ------------------------------------------------------- ;

string[] TSModes
int ts	; 0 - Default / 1 - Lead In / 2 - Aggressive

Function TimersStripping()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddMenuOptionST("TSModeSelect", "$SSL_View", TSModes[ts])
	AddEmptyOption()
	; Timers
	AddHeaderOption("$SSL_TimerType_" + ts)
	AddHeaderOption("")
	AddSliderOptionST("Timers_0", "$SSL_Stage1Length", sslSystemConfig.GetSettingFltA("fTimers", (ts * 5 + 0)), "$SSL_Seconds")
	AddSliderOptionST("Timers_3", "$SSL_Stage4Length", sslSystemConfig.GetSettingFltA("fTimers", (ts * 5 + 3)), "$SSL_Seconds")
	AddSliderOptionST("Timers_1", "$SSL_Stage2Length", sslSystemConfig.GetSettingFltA("fTimers", (ts * 5 + 1)), "$SSL_Seconds")
	AddSliderOptionST("Timers_4", "$SSL_StageEndingLength", sslSystemConfig.GetSettingFltA("fTimers", (ts * 5 + 4)), "$SSL_Seconds")
	AddSliderOptionST("Timers_2", "$SSL_Stage3Length", sslSystemConfig.GetSettingFltA("fTimers", (ts * 5 + 2)), "$SSL_Seconds")
	AddEmptyOption()
	; Stripping
	If(ts == 2)
		AddHeaderOption("$SSL_VictimStripFrom")
		AddHeaderOption("$SSL_AggressorStripFrom")
	Else
		AddHeaderOption("$SSL_FemaleStripFrom")
		AddHeaderOption("$SSL_MaleStripFrom")
	EndIf
	int r1 = ts * 4										; 0 / 4 / 8
	int r2 = (ts * ts) + (3 * ts) + 2	; 2 / 6 / 12
	AddToggleOptionST("StrippingW_" + r1, "$SSL_Weapons", sslSystemConfig.GetSettingIntA("iStripForms", r1 + 1))
	AddToggleOptionST("StrippingW_" + r2, "$SSL_Weapons", sslSystemConfig.GetSettingIntA("iStripForms", r2 + 3))
	int i = 0
	While (i < 32)
		int bit = Math.LeftShift(1, i)
		AddToggleOptionST("Stripping_" + r1 + "_" + i, "$SSL_Strip_" + i, Math.LogicalAnd(sslSystemConfig.GetSettingIntA("iStripForms", r1), bit))
		AddToggleOptionST("Stripping_" + r2 + "_" + i, "$SSL_Strip_" + i, Math.LogicalAnd(sslSystemConfig.GetSettingIntA("iStripForms", r2), bit))
		If (i == 13)
			AddHeaderOption("$SSL_ExtraSlots")
			AddHeaderOption("$SSL_ExtraSlots")
		EndIf
		i += 1
	EndWhile
endFunction

float Function GetDefaultTime(int idx)
	float[] f = new float[15]
	; Default
	f[0] = 30.0		
	f[1] = 20.0
	f[2] = 15.0
	f[3] = 15.0
	f[4] = 9.0
	; lead In
	f[5] = 10.0		
	f[6] = 10.0
	f[7] = 10.0
	f[8] = 8.0
	f[9] = 8.0
	; Aggressive
	f[10] = 20.0	
	f[11] = 15.0
	f[12] = 10.0
	f[13] = 10.0
	f[14] = 4.0
	return f[idx]
EndFunction

state TSModeSelect
	event OnMenuOpenST()
		SetMenuDialogStartIndex(ts)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(TSModes)
	endEvent
	event OnMenuAcceptST(int i)
		if i < 0
			i = ts
		endIf
		ts = i
		SetMenuOptionValueST(TSModes[ts])
		ForcePageReset()
	endEvent
	event OnDefaultST()
		ts = 0
		SetMenuOptionValueST(TSModes[ts])
		ForcePageReset()
	endEvent
endState

; ------------------------------------------------------- ;
; --- Strip Editor                                    --- ;
; ------------------------------------------------------- ;

Form[] ItemsPlayer
Form[] ItemsTarget
bool FullInventoryPlayer
bool FullInventoryTarget

; Strip Page to customize if items should never or always be stripped
Function StripEditor()
	SetCursorFillMode(LEFT_TO_RIGHT)
	AddHeaderOption("$SSL_Equipment{" + PlayerName + "}")
	AddToggleOptionST("FullInventoryPlayer", "$SSL_FullInventory", FullInventoryPlayer)
	ItemsPlayer = sslSystemConfig.GetStrippableItems(PlayerRef, !FullInventoryPlayer)
	int i = 0
	While(i < ItemsPlayer.Length && i < 127 - 2)	; At most 128 entries per page
		AddTextOptionST("StripEditorPlayer_" + i, GetItemName(ItemsPlayer[i]), GetStripState(ItemsPlayer[i]))
		i += 1
	EndWhile
	If((i + 2) > 121 || !TargetRef)	; Want at least 6 free spaces for target NPC
		return
	EndIf
	AddHeaderOption("$SSL_Equipment{" + TargetRef.GetLeveledActorBase().GetName() + "}")
	AddToggleOptionST("FullInventoryTarget", "$SSL_FullInventory", FullInventoryTarget)
	ItemsTarget = sslSystemConfig.GetStrippableItems(TargetRef, !FullInventoryTarget)
	int n = 0
	While(n < ItemsTarget.Length && (i + n) < (127 - 4))
		AddTextOptionST("StripEditorTarget_" + i, GetItemName(ItemsTarget[i]), GetStripState(ItemsTarget[i]))
		n += 1
	EndWhile
EndFunction

String Function GetStripState(Form ItemRef)
	int strip = sslActorLibrary.CheckStrip(ItemRef)
	If(strip == 1)
		return "$SSL_AlwaysRemove"
	ElseIf(strip == -1)
		return "$SSL_NeverRemove"
	Else
		return "---"
	EndIf
EndFunction

string function GetItemName(Form ItemRef, string AltName = "$SSL_Unknown")
	if ItemRef
		string Name = ItemRef.GetName()
		if sslUtility.Trim(Name) != ""
			return Name
		else 
			return AltName
		endIf
	endIf
	return "None"
endFunction

int[] function GetAllMaskSlots(int Mask)
	int i = 30
	int Slot = 0x01
	int[] Output
	while i < 62
		if Math.LogicalAnd(Mask, Slot) == Slot
			Output = PapyrusUtil.PushInt(Output, i)
		endIf
		Slot *= 2
		i += 1
	endWhile
	return Output
endFunction

state FullInventoryPlayer
	event OnSelectST()
		FullInventoryPlayer = !FullInventoryPlayer
		ForcePageReset()
	endEvent
endState

state FullInventoryTarget
	event OnSelectST()
		FullInventoryTarget = !FullInventoryTarget
		ForcePageReset()
	endEvent
endState

; ------------------------------------------------------- ;
; --- Rebuild & Clean                                 --- ;
; ------------------------------------------------------- ;

function RebuildClean()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("SexLab v"+GetStringVer()+" by Ashal@LoversLab.com")
	if SexLab.Enabled
		AddTextOptionST("ToggleSystem","$SSL_EnabledSystem", "$SSL_DoDisable")
	else
		AddTextOptionST("ToggleSystem","$SSL_DisabledSystem", "$SSL_DoEnable")
	endIf
	AddHeaderOption("$SSL_Maintenance")
	AddToggleOptionST("DebugMode","$SSL_DebugMode", Config.DebugMode)
	AddToggleOptionST("Benchmark", "$SSL_Benchmark", Config.Benchmark)
	AddTextOptionST("StopCurrentAnimations","$SSL_StopCurrentAnimations", "$SSL_ClickHere")
	AddTextOptionST("RestoreDefaultSettings","$SSL_RestoreDefaultSettings", "$SSL_ClickHere")
	AddTextOptionST("ResetAnimationRegistry","$SSL_ResetAnimationRegistry", "$SSL_ClickHere")
	AddTextOptionST("ResetVoiceRegistry","$SSL_ResetVoiceRegistry", "$SSL_ClickHere")
	AddTextOptionST("ResetExpressionRegistry","$SSL_ResetExpressionRegistry", "$SSL_ClickHere")
	AddTextOptionST("ResetStripOverrides","$SSL_ResetStripOverrides", "$SSL_ClickHere")
	AddTextOptionST("ClearNPCSexSkills","$SSL_ClearNPCSexSkills", "$SSL_ClickHere")
	AddTextOptionST("CleanSystem","$SSL_CleanSystem", "$SSL_ClickHere")
	AddHeaderOption("$SSL_AvailableStrapons")
	AddTextOptionST("RebuildStraponList","$SSL_RebuildStraponList", "$SSL_ClickHere")
	int i = Config.Strapons.Length
	while i
		i -= 1
		string Name = Config.Strapons[i].GetName()
		if Name == "strapon"
			Name = "Aeon/Horker"
		endIf
		AddTextOptionST("Strapon_" + i, Name, "$SSL_Remove")
	endWhile

	SetCursorPosition(1)
	AddHeaderOption("Registry Info")
	AddTextOption("Animations", sslSystemConfig.GetAnimationCount(), OPTION_FLAG_DISABLED)
	AddTextOption("Voices", VoiceSlots.Slotted+" / 375", OPTION_FLAG_DISABLED)
	AddTextOption("Expressions", ExpressionSlots.Slotted+" / 375", OPTION_FLAG_DISABLED)
	AddHeaderOption("System Requirements")
	SystemCheckOptions()	
endFunction

; ------------------------------------------------------- ;
; --- Unorganized State Option Dump                   --- ;
; ------------------------------------------------------- ;

state AutoAdvance
	event OnSelectST()
		Config.AutoAdvance = !Config.AutoAdvance
		SetToggleOptionValueST(Config.AutoAdvance)
	endEvent
	event OnDefaultST()
		Config.AutoAdvance = false
		SetToggleOptionValueST(Config.AutoAdvance)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAutoAdvance")
	endEvent
endState
state DisableVictim
	event OnSelectST()
		Config.DisablePlayer = !Config.DisablePlayer
		SetToggleOptionValueST(Config.DisablePlayer)
	endEvent
	event OnDefaultST()
		Config.DisablePlayer = false
		SetToggleOptionValueST(Config.DisablePlayer)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoDisablePlayer")
	endEvent
endState
state AutomaticTFC
	event OnSelectST()
		Config.AutoTFC = !Config.AutoTFC
		SetToggleOptionValueST(Config.AutoTFC)
	endEvent
	event OnDefaultST()
		Config.AutoTFC = false
		SetToggleOptionValueST(Config.AutoTFC)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAutomaticTFC")
	endEvent
endState
state AutomaticSUCSM
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.AutoSUCSM)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.AutoSUCSM = value
		SetSliderOptionValueST(Config.AutoSUCSM, "{0}")
	endEvent
	event OnDefaultST()
		Config.AutoSUCSM = 5.0
		SetToggleOptionValueST(Config.AutoSUCSM, "{0}")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAutomaticSUCSM")
	endEvent
endState
state UseExpressions
	event OnSelectST()
		Config.UseExpressions = !Config.UseExpressions
		SetToggleOptionValueST(Config.UseExpressions)
	endEvent
	event OnDefaultST()
		Config.UseExpressions = true
		SetToggleOptionValueST(Config.UseExpressions)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoUseExpressions")
	endEvent
endState
state RefreshExpressions
	event OnSelectST()
		Config.RefreshExpressions = !Config.RefreshExpressions
		SetToggleOptionValueST(Config.RefreshExpressions)
	endEvent
	event OnDefaultST()
		Config.RefreshExpressions = true
		SetToggleOptionValueST(Config.RefreshExpressions)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRefreshExpressions")
	endEvent
endState
state UseLipSync
	event OnSelectST()
		Config.UseLipSync = !Config.UseLipSync
		SetToggleOptionValueST(Config.UseLipSync)
	endEvent
	event OnDefaultST()
		Config.UseLipSync = true
		SetToggleOptionValueST(Config.UseLipSync)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoUseLipSync")
	endEvent
endState
state ShowInMap
	event OnSelectST()
		Config.ShowInMap = !Config.ShowInMap
		SetToggleOptionValueST(Config.ShowInMap)
	endEvent
	event OnDefaultST()
		Config.ShowInMap = false
		SetToggleOptionValueST(Config.ShowInMap)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoShowInMap")
	endEvent
endState
state LimitedStrip
	event OnSelectST()
		Config.LimitedStrip = !Config.LimitedStrip
		SetToggleOptionValueST(Config.LimitedStrip)
	endEvent
	event OnDefaultST()
		Config.LimitedStrip = false
		SetToggleOptionValueST(Config.LimitedStrip)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_LimitedStripInfo")
	endEvent
endState
state RedressVictim
	event OnSelectST()
		Config.RedressVictim = !Config.RedressVictim
		SetToggleOptionValueST(Config.RedressVictim)
	endEvent
	event OnDefaultST()
		Config.RedressVictim = true
		SetToggleOptionValueST(Config.RedressVictim)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoReDressVictim")
	endEvent
endState
state UseCum
	event OnSelectST()
		Config.UseCum = !Config.UseCum
		SetToggleOptionValueST(Config.UseCum)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.UseCum = true
		SetToggleOptionValueST(Config.UseCum)
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoUseCum")
	endEvent
endState
state AllowFemaleFemaleCum
	event OnSelectST()
		Config.AllowFFCum = !Config.AllowFFCum
		SetToggleOptionValueST(Config.AllowFFCum)
	endEvent
	event OnDefaultST()
		Config.AllowFFCum = false
		SetToggleOptionValueST(Config.AllowFFCum)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAllowFFCum")
	endEvent
endState
state CumEffectTimer
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.CumTimer)
		SetSliderDialogDefaultValue(120)
		SetSliderDialogRange(0, 43200)
		SetSliderDialogInterval(10)
	endEvent
	event OnSliderAcceptST(float value)
		Config.CumTimer = value
		SetSliderOptionValueST(Config.CumTimer, "$SSL_Seconds")
	endEvent
	event OnDefaultST()
		Config.CumTimer = 120.0
		SetSliderOptionValueST(Config.CumTimer, "$SSL_Seconds")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoCumTimer")
	endEvent
endState


state OpenMouthSize
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.OpenMouthSize)
		SetSliderDialogDefaultValue(80)
		SetSliderDialogRange(20, 100)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.OpenMouthSize = value as int
		SetSliderOptionValueST(Config.OpenMouthSize, "{0}%")
	endEvent
	event OnDefaultST()
		Config.OpenMouthSize = 80
		SetSliderOptionValueST(Config.OpenMouthSize, "{0}%")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoOpenMouthSize")
	endEvent
endState

state OrgasmEffects
	event OnSelectST()
		Config.OrgasmEffects = !Config.OrgasmEffects
		SetToggleOptionValueST(Config.OrgasmEffects)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.OrgasmEffects = true
		SetToggleOptionValueST(Config.OrgasmEffects)
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoOrgasmEffects")
	endEvent
endState
state SeparateOrgasms
	event OnSelectST()
		Config.SeparateOrgasms = !Config.SeparateOrgasms
		SetToggleOptionValueST(Config.SeparateOrgasms)
	endEvent
	event OnDefaultST()
		Config.SeparateOrgasms = false
		SetToggleOptionValueST(Config.SeparateOrgasms)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoSeparateOrgasms")
	endEvent
endState
state RemoveHeelEffect
	event OnSelectST()
		Config.RemoveHeelEffect = !Config.RemoveHeelEffect
		SetToggleOptionValueST(Config.RemoveHeelEffect)
	endEvent
	event OnDefaultST()
		Config.RemoveHeelEffect = Config.HasHDTHeels
		SetToggleOptionValueST(Config.RemoveHeelEffect)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRemoveHeelEffect")
	endEvent
endState

state AllowCreatures
	event OnSelectST()
		Config.AllowCreatures = !Config.AllowCreatures
		SetToggleOptionValueST(Config.AllowCreatures)
	endEvent
	event OnDefaultST()
		Config.AllowCreatures = false
		SetToggleOptionValueST(Config.AllowCreatures)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAllowCreatures")
	endEvent
endState
state UseCreatureGender
	event OnSelectST()
		Config.UseCreatureGender = !Config.UseCreatureGender
		CreatureSlots.ClearAnimCache()
		SetToggleOptionValueST(Config.UseCreatureGender)
	endEvent
	event OnDefaultST()
		if Config.UseCreatureGender
			CreatureSlots.ClearAnimCache()
		endIf
		Config.UseCreatureGender = false
		SetToggleOptionValueST(Config.UseCreatureGender)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoUseCreatureGender")
	endEvent
endState
state AskBed
	event OnSelectST()
		Config.AskBed = sslUtility.IndexTravel(Config.AskBed, 3)
		SetTextOptionValueST(BedOpt[Config.AskBed])
	endEvent
	event OnDefaultST()
		Config.AskBed = 1
		SetTextOptionValueST(BedOpt[Config.AskBed])
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoAskBed")
	endEvent
endState
state NPCBed
	event OnSelectST()
		Config.NPCBed = sslUtility.IndexTravel(Config.NPCBed, 3)
		SetTextOptionValueST(Chances[Config.NPCBed])
	endEvent
	event OnDefaultST()
		Config.NPCBed = 0
		SetTextOptionValueST(Chances[Config.NPCBed])
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoNPCBed")
	endEvent
endState
state BedRemoveStanding
	event OnSelectST()
		Config.BedRemoveStanding = !Config.BedRemoveStanding
		SetToggleOptionValueST(Config.BedRemoveStanding)
	endEvent
	event OnDefaultST()
		Config.BedRemoveStanding = true
		SetToggleOptionValueST(Config.BedRemoveStanding)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoBedRemoveStanding")
	endEvent
endState
state ForeplayStage
	event OnSelectST()
		Config.ForeplayStage = !Config.ForeplayStage
		SetToggleOptionValueST(Config.ForeplayStage)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.ForeplayStage = true
		SetToggleOptionValueST(Config.ForeplayStage)
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoForeplayStage")
	endEvent
endState
state LeadInCoolDown
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.LeadInCoolDown)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 3600)
		SetSliderDialogInterval(30)
	endEvent
	event OnSliderAcceptST(float value)
		Config.LeadInCoolDown = value
		SetSliderOptionValueST(Config.LeadInCoolDown, "$SSL_Seconds")
	endEvent
	event OnDefaultST()
		Config.LeadInCoolDown = 0.0
		SetToggleOptionValueST(Config.LeadInCoolDown, "$SSL_Seconds")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoLeadInCoolDown")
	endEvent
endState
state ScaleActors
	event OnSelectST()
		Config.ScaleActors = !Config.ScaleActors
		SetToggleOptionValueST(Config.ScaleActors)
		if Config.ScaleActors && Config.DisableScale
			Config.DisableScale = false
			SexLabUtil.VehicleFixMode(0)
		endIf
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.ScaleActors = false
		SetToggleOptionValueST(Config.ScaleActors)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoScaleActors")
	endEvent
endState
state DisableScale
	event OnSelectST()
		Config.DisableScale = !Config.DisableScale
		SetToggleOptionValueST(Config.DisableScale)
		SexLabUtil.VehicleFixMode((Config.DisableScale as int))
		if Config.DisableScale && Config.ScaleActors
			Config.ScaleActors = false
		endIf
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.DisableScale = false
		SexLabUtil.VehicleFixMode(0)
		SetToggleOptionValueST(Config.DisableScale)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoDisableScale")
	endEvent
endState
state RestrictSameSex
	event OnSelectST()
		Config.RestrictSameSex = !Config.RestrictSameSex
		SetToggleOptionValueST(Config.RestrictSameSex)
	endEvent
	event OnDefaultST()
		Config.RestrictSameSex = false
		SetToggleOptionValueST(Config.RestrictSameSex)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoRestrictSameSex")
	endEvent
endState

state UndressAnimation
	event OnSelectST()
		Config.UndressAnimation = !Config.UndressAnimation
		SetToggleOptionValueST(Config.UndressAnimation)
	endEvent
	event OnDefaultST()
		Config.UndressAnimation = false
		SetToggleOptionValueST(Config.UndressAnimation)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoUndressAnimation")
	endEvent
endState

state StraponsFemale
	event OnSelectST()
		Config.UseStrapons = !Config.UseStrapons
		SetToggleOptionValueST(Config.UseStrapons)
	endEvent
	event OnDefaultST()
		Config.UseStrapons = true
		SetToggleOptionValueST(Config.UseStrapons)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoUseStrapons")
	endEvent
endState

string[] VoiceNames
state PlayerVoice
	event OnMenuOpenST()
		VoiceNames = VoiceSlots.GetNormalSlotNames(true)
		SetMenuDialogOptions(VoiceNames)
		SetMenuDialogStartIndex(VoiceNames.Find(VoiceSlots.GetSavedName(PlayerRef)))
		SetMenuDialogDefaultIndex(0)
	endEvent
	event OnMenuAcceptST(int i)
		if i < 1
			VoiceSlots.ForgetVoice(PlayerRef)
			SetMenuOptionValueST("$SSL_Random")
		else
			sslBaseVoice Voice = VoiceSlots.GetByName(VoiceNames[i])
			VoiceSlots.SaveVoice(PlayerRef, Voice)
			SetMenuOptionValueST(VoiceNames[i])
			sslThreadController Thread = ThreadSlots.GetActorController(PlayerRef)
			if Thread
				Thread.SetVoice(PlayerRef, Voice)
			endIf
		endIf
	endEvent
	event OnDefaultST()
		VoiceSlots.ForgetVoice(PlayerRef)
		SetMenuOptionValueST("$SSL_Random")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoPlayerVoice")
	endEvent
endState
state TargetVoice
	event OnMenuOpenST()
		VoiceNames = VoiceSlots.GetNormalSlotNames(true)
		SetMenuDialogOptions(VoiceNames)
		SetMenuDialogStartIndex(VoiceNames.Find(VoiceSlots.GetSavedName(TargetRef)))
		SetMenuDialogDefaultIndex(0)
	endEvent
	event OnMenuAcceptST(int i)
		if i < 1
			VoiceSlots.ForgetVoice(TargetRef)
			SetMenuOptionValueST("$SSL_Random")
		else
			sslBaseVoice Voice = VoiceSlots.GetByName(VoiceNames[i])
			VoiceSlots.SaveVoice(TargetRef, Voice)
			SetMenuOptionValueST(VoiceNames[i])
			sslThreadController Thread = ThreadSlots.GetActorController(TargetRef)
			if Thread
				Thread.SetVoice(TargetRef, Voice)
			endIf
		endIf
	endEvent
	event OnDefaultST()
		VoiceSlots.ForgetVoice(TargetRef)
		SetMenuOptionValueST("$SSL_Random")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoPlayerVoice")
	endEvent
endState
state NPCSaveVoice
	event OnSelectST()
		Config.NPCSaveVoice = !Config.NPCSaveVoice
		SetToggleOptionValueST(Config.NPCSaveVoice)
	endEvent
	event OnDefaultST()
		Config.NPCSaveVoice = false
		SetToggleOptionValueST(Config.NPCSaveVoice)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoNPCSaveVoice")
	endEvent
endState
state SFXVolume
	event OnSliderOpenST()
		SetSliderDialogStartValue((Config.SFXVolume * 100))
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.SFXVolume = (value / 100.0)
		Config.AudioSFX.SetVolume(Config.SFXVolume)
		SetSliderOptionValueST(value, "{0}%")
	endEvent
	event OnDefaultST()
		Config.SFXVolume = 1.0
		SetSliderOptionValueST((Config.SFXVolume * 100), "{0}%")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoSFXVolume")
	endEvent
endState
state VoiceVolume
	event OnSliderOpenST()
		SetSliderDialogStartValue((Config.VoiceVolume * 100))
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.VoiceVolume = (value / 100.0)
		Config.AudioVoice.SetVolume(Config.VoiceVolume)
		SetSliderOptionValueST(value, "{0}%")
	endEvent
	event OnDefaultST()
		Config.VoiceVolume = 1.0
		SetSliderOptionValueST((Config.VoiceVolume * 100), "{0}%")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoVoiceVolume")
	endEvent
endState
state SFXDelay
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.SFXDelay)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.SFXDelay = value
		SetSliderOptionValueST(Config.SFXDelay, "$SSL_Seconds")
	endEvent
	event OnDefaultST()
		Config.SFXDelay = 3.0
		SetSliderOptionValueST(Config.SFXDelay, "$SSL_Seconds")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoSFXDelay")
	endEvent
endState
state MaleVoiceDelay
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.MaleVoiceDelay)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 45)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.MaleVoiceDelay = value
		SetSliderOptionValueST(Config.MaleVoiceDelay, "$SSL_Seconds")
	endEvent
	event OnDefaultST()
		Config.MaleVoiceDelay = 5.0
		SetSliderOptionValueST(Config.MaleVoiceDelay, "$SSL_Seconds")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoMaleVoiceDelay")
	endEvent
endState
state FemaleVoiceDelay
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.FemaleVoiceDelay)
		SetSliderDialogDefaultValue(4)
		SetSliderDialogRange(1, 45)
		SetSliderDialogInterval(1)
	endEvent
	event OnSliderAcceptST(float value)
		Config.FemaleVoiceDelay = value
		SetSliderOptionValueST(Config.FemaleVoiceDelay, "$SSL_Seconds")
	endEvent
	event OnDefaultST()
		Config.FemaleVoiceDelay = 4.0
		SetSliderOptionValueST(Config.FemaleVoiceDelay, "$SSL_Seconds")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoFemaleVoiceDelay")
	endEvent
endState
state ExpressionDelay
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.ExpressionDelay)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(0.5, 5)
		SetSliderDialogInterval(0.5)
	endEvent
	event OnSliderAcceptST(float value)
		Config.ExpressionDelay = value
		SetSliderOptionValueST(Config.ExpressionDelay, "{1}x")
	endEvent
	event OnDefaultST()
		Config.ExpressionDelay = 2.0
		SetSliderOptionValueST(Config.ExpressionDelay, "{1}x")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoExpressionDelay")
	endEvent
endState
state ShakeStrength
	event OnSliderOpenST()
		SetSliderDialogStartValue(Config.ShakeStrength * 100)
		SetSliderDialogDefaultValue(70)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	endEvent
	event OnSliderAcceptST(float value)
		Config.ShakeStrength = (value / 100.0)
		SetSliderOptionValueST(value, "{0}%")
	endEvent
	event OnDefaultST()
		Config.ShakeStrength = 0.7
		SetSliderOptionValueST((Config.ShakeStrength * 100), "{0}%")
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoShakeStrength")
	endEvent
endState

state ToggleSystem
	event OnSelectST()
		if SexLab.Enabled && ShowMessage("$SSL_WarnDisableSexLab")
			SexLab.GoToState("Disabled")
		elseIf !SexLab.Enabled && ShowMessage("$SSL_WarnEnableSexLab")
			SexLab.GoToState("Enabled")
		endIf
		ForcePageReset()
	endEvent
endState
state RestoreDefaultSettings
	event OnSelectST()
		if ShowMessage("$SSL_WarnRestoreDefaults")
			SetOptionFlagsST(OPTION_FLAG_DISABLED)
			SetTextOptionValueST("$SSL_Resetting")			
			Config.SetDefaults()
			ShowMessage("$SSL_RunRestoreDefaults", false)
			SetTextOptionValueST("$SSL_ClickHere")
			SetOptionFlagsST(OPTION_FLAG_NONE)
			; ForcePageReset()
		endIf
	endEvent
endState
state StopCurrentAnimations
	event OnSelectST()
		ShowMessage("$SSL_StopRunningAnimations", false)
		ThreadSlots.StopAll()
	endEvent
endState
state ResetAnimationRegistry
	event OnSelectST()
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("$SSL_Resetting")		
		ThreadSlots.StopAll()
		AnimSlots.Setup()
		CreatureSlots.Setup()
		ShowMessage("$SSL_RunRebuildAnimations", false)
		Debug.Notification("$SSL_RunRebuildAnimations")
		SetTextOptionValueST("$SSL_ClickHere")
		SetOptionFlagsST(OPTION_FLAG_NONE)
		ForcePageReset()
	endEvent
endState
state ResetVoiceRegistry
	event OnSelectST()
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("$SSL_Resetting")		
		ThreadSlots.StopAll()
		VoiceSlots.Setup()
		ShowMessage("$SSL_RunRebuildVoices", false)
		Debug.Notification("$SSL_RunRebuildVoices")
		SetTextOptionValueST("$SSL_ClickHere")
		SetOptionFlagsST(OPTION_FLAG_NONE)
		ForcePageReset()
	endEvent
endState
state ResetExpressionRegistry
	event OnSelectST()
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("$SSL_Resetting")		
		ThreadSlots.StopAll()
		ExpressionSlots.Setup()
		ShowMessage("$SSL_RunRebuildExpressions", false)
		Debug.Notification("$SSL_RunRebuildExpressions")
		SetTextOptionValueST("$SSL_ClickHere")
		SetOptionFlagsST(OPTION_FLAG_NONE)
		ForcePageReset()
	endEvent
endState
state ResetStripOverrides
	event OnSelectST()
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("$SSL_Resetting")		
		ActorLib.ResetStripOverrides()
		ShowMessage("$Done", false)
		SetTextOptionValueST("$SSL_ClickHere")
		SetOptionFlagsST(OPTION_FLAG_NONE)
	endEvent
endState
state ClearNPCSexSkills
	event OnSelectST()
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetTextOptionValueST("$SSL_Resetting")

		Stats.ClearNPCSexSkills()
		
		ShowMessage("$Done", false)
		SetTextOptionValueST("$SSL_ClickHere")
		SetOptionFlagsST(OPTION_FLAG_NONE)
	endEvent
endState
state DebugMode
	event OnSelectST()
		Config.DebugMode = !Config.DebugMode
		SetToggleOptionValueST(Config.DebugMode)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoDebugMode")
	endEvent
endState
state Benchmark
	event OnSelectST()
		Config.Benchmark = !Config.Benchmark
		SetToggleOptionValueST(Config.Benchmark)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoBenchmark")
	endEvent
endState
state ResetPlayerSexStats
	event OnSelectST()
		if ShowMessage("$SSL_WarnResetStats")
			Stats.ResetStats(PlayerRef)
			Debug.Notification("$SSL_RunResetStats")
		endIf
	endEvent
endState
state CleanSystem
	event OnSelectST()
		if ShowMessage("$SSL_WarnCleanSystem")
			ThreadSlots.StopAll()
			SystemAlias.SetupSystem()

			ModEvent.Send(ModEvent.Create("SexLabReset"))
			Config.CleanSystemFinish.Show()
		endIf
	endEvent
endState
state RebuildStraponList
	event OnSelectST()
		Config.LoadStrapons()
		if Config.Strapons.Length > 0
			ShowMessage("$SSL_FoundStrapon", false)
		else
			ShowMessage("$SSL_NoStrapons", false)
		endIf
		ForcePageReset()
	endEvent
endState


; ------------------------------------------------------- ;
; --- Misc Utilities                                  --- ;
; ------------------------------------------------------- ;

function Log(string Log, string Type = "NOTICE")
	Log = Type+": "+Log
	if Config.DebugMode
		SexLabUtil.PrintConsole(Log)
	endIf
	if Type == "FATAL"
		Debug.TraceStack("SEXLAB - "+Log)
	else
		Debug.Trace("SEXLAB - "+Log)
	endIf
endFunction

function ResetAllQuests()
	bool SaveDebug = Config.DebugMode
	; Reset relevant quests
	ResetQuest(Game.GetFormFromFile(0x00D62, "SexLab.esm") as Quest)
	ResetQuest(Game.GetFormFromFile(0x639DF, "SexLab.esm") as Quest)
	ResetQuest(Game.GetFormFromFile(0x664FB, "SexLab.esm") as Quest)
	ResetQuest(Game.GetFormFromFile(0x78818, "SexLab.esm") as Quest)
	sslThreadController[] Threads = ThreadSlots.Threads
	int i = Threads.Length
	while i
		i -= 1
		ResetQuest(Threads[i])
	endwhile
	Config.DebugMode = SaveDebug
endFunction

function ResetQuest(Quest QuestRef)
	if QuestRef
		while QuestRef.IsStarting()
			Utility.WaitMenuMode(0.1)
		endWhile
		QuestRef.Stop()
		while QuestRef.IsStopping()
			Utility.WaitMenuMode(0.1)
		endWhile
		if !QuestRef.Start()
			QuestRef.Start()
			Log("Failed to start quest!", "ResetQuest("+QuestRef+")")
		endIf
	else
		Log("Invalid quest!", "ResetQuest("+QuestRef+")")
	endIf
endFunction

int function DoDisable(bool check)
	if check
		return OPTION_FLAG_DISABLED
	endIf
	return OPTION_FLAG_NONE
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

int function AddItemToggles(Form[] Items, int ID, int Max)
endFunction

Form[] function GetItems(Actor ActorRef, bool FullInventory = false)
	if FullInventory
		return GetFullInventory(ActorRef)
	else
		return GetEquippedItems(ActorRef)
	endIf
endFunction
Form[] function GetEquippedItems(Actor ActorRef)
	Form[] Output = new Form[34]
	; Weapons
	Form ItemRef
	ItemRef = ActorRef.GetEquippedWeapon(false) ; Right Hand
	if ItemRef && IsToggleable(ItemRef)
		Output[33] = ItemRef
	endIf
	ItemRef = ActorRef.GetEquippedWeapon(true) ; Left Hand
	if ItemRef && ItemRef != Output[33] && IsToggleable(ItemRef)
		Output[32] = ItemRef
	endIf

	; Armor
	int i
	int Slot = 0x01
	while i < 32
		Form WornRef = ActorRef.GetWornForm(Slot)
		if WornRef
			if WornRef as ObjectReference
				WornRef = (WornRef as ObjectReference).GetBaseObject()
			endIf
			if Output.Find(WornRef) == -1 && IsToggleable(WornRef)
				Output[i] = WornRef
			endIf
		endIf
		Slot *= 2
		i    += 1
	endWhile
	return PapyrusUtil.ClearNone(Output)
endFunction
Form[] function GetFullInventory(Actor ActorRef)
	int[] Valid = new int[3]
	Valid[0] = 26 ; kArmor
	Valid[1] = 41 ; kWeapon 
	Valid[2] = 53 ; kLeveledItem
	;/ Valid[3] = 124 ; kOutfit
	Valid[4] = 102 ; kARMA
	Valid[5] = 120 ; kEquipSlot /;

	Form[] Output = GetEquippedItems(ActorRef)
	Form[] Items  = ActorRef.GetContainerForms()
	int n = Output.Length
	int i = Items.Length
	Output = Utility.ResizeFormArray(Output, 126)
	while i && n < 126
		i -= 1
		Form ItemRef = Items[i]
		if ItemRef && Valid.Find(ItemRef.GetType()) != -1
			if ItemRef as ObjectReference
				ItemRef = (ItemRef as ObjectReference).GetBaseObject()
			endIf
			if Output.Find(ItemRef) == -1 && IsToggleable(ItemRef)
				Output[n] = ItemRef
				n += 1
			endIf
		endIf
	endWhile
	return PapyrusUtil.ClearNone(Output)
endFunction

bool function IsToggleable(Form ItemRef)
	return !SexLabUtil.HasKeywordSub(ItemRef, "NoStrip") && !SexLabUtil.HasKeywordSub(ItemRef, "AlwaysStrip")
endFunction

bool[] function GetStripping(int type)
	if ts == 1
		if type == 1
			return Config.StripLeadInFemale
		else
			return Config.StripLeadInMale
		endIf
	elseIf ts == 2
		if type == 1
			return Config.StripVictim
		else
			return Config.StripAggressor
		endIf
	else
		if type == 1
			return Config.StripFemale
		else
			return Config.StripMale
		endIf
	endIf
endFunction

float[] function GetTimers()
	if ts == 1
		return Config.StageTimerLeadIn
	elseIf ts == 2
		return Config.StageTimerAggr
	else
		return Config.StageTimer
	endIf
endFunction

; Default Timer Values
float[] function GetTimersDef()
	float[] ret = new float[5]
	if ts == 1
		ret[0] = 10.0
		ret[1] = 10.0
		ret[2] = 10.0
		ret[3] = 8.0
		ret[4] = 8.0
	elseIf ts == 2
		ret[0] = 20.0
		ret[1] = 15.0
		ret[2] = 10.0
		ret[3] = 10.0
		ret[4] = 4.0
	else
		ret[0] = 30.0
		ret[1] = 20.0
		ret[2] = 15.0
		ret[3] = 15.0
		ret[4] = 9.0
	endIf
	return ret
endFunction
