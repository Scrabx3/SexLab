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

; Framework
Actor property PlayerRef auto
SexLabFramework property SexLab auto
sslSystemConfig property Config auto
sslSystemAlias property SystemAlias auto

; Function libraries
sslActorLibrary Property ActorLib Auto
sslThreadLibrary Property ThreadLib Auto

; Object registries
sslThreadSlots Property ThreadSlots Auto
sslAnimationSlots Property AnimSlots Auto
sslCreatureAnimationSlots Property CreatureSlots Auto

; Common Data
Actor TargetRef
int TargetFlag
string TargetName
string PlayerName

; ------------------------------------------------------- ;
; --- Conmfig Init				                            --- ;
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
	Pages[2] = "$SSL_MatchMaker"
	Pages[3] = "$SSL_SoundSettings"
	Pages[4] = "$SSL_TimersStripping"
	Pages[5] = "$SSL_StripEditor"
	Pages[6] = "$SSL_ToggleAnimations"
	Pages[7] = "$SSL_AnimationEditor"
	Pages[8] = "$SSL_ExpressionEditor"
	Pages[9] = "$SSL_PlayerHotkeys"
	Pages[10] = "$SSL_RebuildClean"

	; Animation Settings
	_PlFurnOpt = new String[4]
	_PlFurnOpt[0] = "$SSL_Never"
	_PlFurnOpt[1] = "$SSL_Always"
	_PlFurnOpt[2] = "$SSL_AskAlways"
	_PlFurnOpt[3] = "$SSL_AskNotSub"

	_NPCFurnOpt = new String[2]
	_NPCFurnOpt[0] = "$SSL_Never"
	_NPCFurnOpt[1] = "$SSL_Always"

	_FadeOpt = new string[3]
	_FadeOpt[0] = "$SSL_Never"
	_FadeOpt[1] = "$SSL_UseBlack"
	_FadeOpt[2] = "$SSL_UseBlur"

	_FilterOpt = new String[3]
	_FilterOpt[0] = "$SSL_Filter_0"		; Loose
	_FilterOpt[1] = "$SSL_Filter_1"		; Standard
	_FilterOpt[2] = "$SSL_Filter_2"		; Strict

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
	_stripView = new string[2]
	_stripView[0] = "$SSL_DefaultStripping"
	_stripView[1] = "$SSL_DominantStripping"

	If (SKSE.GetVersionMinor() < 2)
		Config.DisableScale = true
		Debug.MessageBox("[SexLab]\nYou are using an outdated version of Skyrim and scaling has thus been disabled to prevent crashes.")
	EndIf
EndEvent

Event OnConfigOpen()
	If(PlayerRef.GetLeveledActorBase().GetSex() == 0)
		Pages[0] = "$SSL_SexJournal"
	Else
		Pages[0] = "$SSL_SexDiary"
	EndIf
	_trackedIndex = 0
	_trackedActors = SexLabStatistics.GetAllTrackedUniqueActorsSorted()
	_trackedNames = Utility.CreateStringArray(_trackedActors.Length)
	int i = 0
	While (i < _trackedNames.Length)
		_trackedNames[i] = _trackedActors[i].GetActorBase().GetName()
		i += 1
	EndWhile
	_voiceCacheIndex = 0
	_voices = sslVoiceSlots.GetAllVoices()
	_voiceCachedActors = sslVoiceSlots.GetAllCachedUniqueActorsSorted(Config.TargetRef)
	_voiceCachedNames = Utility.CreateStringArray(_voiceCachedActors.Length)
	int i = 0
	While (i < _voiceCachedNames.Length)
		_voiceCachedNames[i] = _voiceCachedActors[i].GetActorBase().GetName()
		i += 1
	EndWhile
	_stripViewIdx = 0
	_playerDisplayAll = false
	_targetDisplayAll = false

	; TODO: Review below

	; Player & Target info
	PlayerName = PlayerRef.GetLeveledActorBase().GetName()
	TargetRef = Config.TargetRef
	If(TargetRef)
		If(TargetRef.Is3DLoaded())
			TargetName = TargetRef.GetLeveledActorBase().GetName()
			TargetFlag = OPTION_FLAG_NONE
		EndIf
	Else
		TargetName = "$SSL_NoTarget"
		TargetFlag = OPTION_FLAG_DISABLED
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
EndEvent

Event OnConfigClose()
	ModEvent.Send(ModEvent.Create("SexLabConfigClose"))
	; Realign actors if an adjustment in editor was just made
	If (AutoRealign)
		AutoRealign = false
		If (ThreadControlled)
			ThreadControlled.RealignActors()
		EndIf
	EndIf
endEvent

; ------------------------------------------------------- ;
; --- Config Pages						                        --- ;
; ------------------------------------------------------- ;

Event OnPageReset(string page)
	If (!SystemAlias.IsInstalled)
		InstallMenu()
	; ElseIf (ShowAnimationEditor)	; COMEBACK: This variable necessary?
	; 	AnimationEditor()
	ElseIf (Page == "")
		If (Config.GetThreadControlled() || ThreadSlots.FindActorController(PlayerRef) != -1)
			AnimationEditor()
			PreventOverwrite = true
		Else
			LoadCustomContent("SexLab/logo.dds", 184, 31)
		EndIf
	Else
		UnloadCustomContent()
		If page == "$SSL_SexDiary" || page == "$SSL_SexJournal"
			SexDiary()
		ElseIf page == "$SSL_AnimationSettings"
			AnimationSettings()
		ElseIf page == "$SSL_MatchMaker"
			MatchMaker()
		ElseIf page == "$SSL_SoundSettings"
			SoundSettings()
		ElseIf page == "$SSL_TimersStripping"
			TimersStripping()
		ElseIf page == "$SSL_StripEditor"
			StripEditor()
		ElseIf page == "$SSL_ToggleAnimations"
			ToggleAnimations()
		ElseIf page == "$SSL_AnimationEditor"
			AnimationEditor()
		ElseIf page == "$SSL_ExpressionEditor"
			ExpressionEditor()
		ElseIf page == "$SSL_PlayerHotkeys"
			PlayerHotkeys()
		ElseIf page == "$SSL_RebuildClean"
			RebuildClean()
		EndIf
	EndIf
EndEvent

; bool ShowAnimationEditor = false
event OnPageSelected(String a_eventName, String a_strArg, Float a_numArg, Form a_sender)
	; if ShowAnimationEditor && (a_numArg as int) != Pages.Find("$SSL_ToggleAnimations")
	; 	ShowAnimationEditor = false
	; else
		If EditOpenMouth && (a_numArg as int) != Pages.Find("$SSL_ExpressionEditor")
		EditOpenMouth = false
	endIf
endEvent

; ------------------------------------------------------- ;
; --- Sex Diary/Journal Editor                        --- ;
; ------------------------------------------------------- ;

Actor[] _trackedActors
String[] _trackedNames
int _trackedIndex

String Function GetSexualityTitle(Actor ActorRef) global
	int sexuality = SexLabStatistics.GetSexuality(ActorRef)
	If (sexuality == 0)
		return "$SSL_Heterosexual"
	ElseIf (sexuality == 1)
		If (SexLabRegistry.GetSex(ActorRef, true) == 0)
			return "$SSL_Gay"
		Else
			return "$SSL_Lesbian"
		EndIf
	Else
		return "$SSL_Bisexual"
	EndIf
EndFunction

String[] Function StatTitles() global
	String[] StatTitles = new String[7]
	StatTitles[0] = "$SSL_Unskilled"
	StatTitles[1] = "$SSL_Novice"
	StatTitles[2] = "$SSL_Apprentice"
	StatTitles[3] = "$SSL_Journeyman"
	StatTitles[4] = "$SSL_Expert"
	StatTitles[5] = "$SSL_Master"
	StatTitles[6] = "$SSL_GrandMaster"
	return StatTitles
EndFunction

Function SexDiary()
	SetCursorFillMode(LEFT_TO_RIGHT)
	If (_trackedIndex >= _trackedActors.Length)
		_trackedIndex = 0
	EndIf
	Actor it = _trackedActors[_trackedIndex]
	AddMenuOptionST("StatSelectingMenu", "$SSL_StatSelectingMenu", _trackedNames[_trackedIndex])
	AddTextOptionST("ResetTargetStats", "$SSL_Reset{" + _trackedNames[_trackedIndex] + "}Stats", "$SSL_ClickHere")
	AddHeaderOption("$SSL_Statistics")
	AddEmptyOption()

	SetCursorFillMode(TOP_TO_BOTTOM)
	AddTextOption("$SSL_LastTimeInScene", Utility.GameTimeToString(SexLabStatistics.GetStatistic(it, 0)))
	AddTextOption("$SSL_TimeInScenes", sslActorStats.ParseTime(SexLabStatistics.GetStatistic(it, 1) as int))
	String[] xp_titles = StatTitles()
	int i = 2
	While (i < 5)		; XP Statistics
		float value = SexLabStatistics.GetStatistic(it, i)
		int lv = PapyrusUtil.ClampInt(sslActorStats.CalcLevel(value), 0, xp_titles.Length - 1)
		AddTextOption("$SSL_Statistic_" + i, xp_titles[lv])
		i += 1
	EndWhile
	While (i < 9)		; Partner Statistics
		AddTextOption("$SSL_Statistic_" + i, SexLabStatistics.GetStatistic(it, i) as int)
		i += 1
	EndWhile
	SetCursorPosition(5)
	AddTextOptionST("StatChangeSexuality", "$SSL_Sexuality", GetSexualityTitle(it))
	While (i < 16)	; "Times" Statistics
		AddTextOption("$SSL_Statistic_" + i, SexLabStatistics.GetStatistic(it, i) as int)
		i += 1
	EndWhile
EndFunction

State StatSelectingMenu
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(_trackedIndex)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_trackedNames)
	EndEvent
	Event OnMenuAcceptST(Int aiIndex)
		_trackedIndex = aiIndex
		SetMenuOptionValueST(_trackedNames[_trackedIndex])
		ForcePageReset()
	EndEvent
	Event OnDefaultST()
		_trackedIndex = 0
		SetMenuOptionValueST(_trackedNames[_trackedIndex])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SSL_StatSelectingMenuHighlight")
	EndEvent
EndState

State ResetTargetStats
	Event OnSelectST()
		If (!ShowMessage("$SSL_WarnReset{" + _trackedNames[_trackedIndex] + "}Stats"))
			return
		EndIf
		SexLabStatistics.ResetStatistics(_trackedActors[_trackedIndex])
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SSL_ResetStatHighlight")
	EndEvent
EndState

State StatChangeSexuality
	Event OnSelectST()
		Actor it = _trackedActors[_trackedIndex]
		int sex = SexLabStatistics.GetSexuality(it)
		If (sex == 0)	; Hetero -> Homo
			sslActorStats.SetLegacyStatistic(it, Stats.kSexuality, 25)
		ElseIf (sex == 1)	; Homo -> Bi
			sslActorStats.SetLegacyStatistic(it, Stats.kSexuality, 50)
		Else	; Bi -> Hetero
			sslActorStats.SetLegacyStatistic(it, Stats.kSexuality, 75)
		EndIf
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SSL_SexualityHighlight")
	EndEvent
EndState

; ------------------------------------------------------- ;
; --- Animation Settings                              --- ;
; ------------------------------------------------------- ;

String[] _PlFurnOpt
String[] _NPCFurnOpt
string[] _FadeOpt
String[] _FilterOpt
String[] _ClimaxTypes
String[] _Sexes

Function AnimationSettings()
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
	AddToggleOptionST("UseLipSync", "$SSL_UseLipSync", Config.UseLipSync)

	SetCursorPosition(1)
	AddHeaderOption("$SSL_Creatures")
	AddToggleOptionST("AllowCreatures","$SSL_AllowCreatures", Config.AllowCreatures)
	AddToggleOptionST("UseCreatureGender","$SSL_UseCreatureGender", Config.UseCreatureGender)
	AddHeaderOption("$SSL_AnimationHandling")
	AddToggleOptionST("DisableScale","$SSL_DisableScale", Config.DisableScale)
	AddMenuOptionST("FilterStrictness", "$SSL_FilterStrictness", _FilterOpt[sslSystemConfig.GetSettingInt("iFilterStrictness")])
	AddMenuOptionST("UseFade","$SSL_UseFade", _FadeOpt[sslSystemConfig.GetSettingInt("iUseFade")])
	AddToggleOptionST("UndressAnimation","$SSL_UndressAnimation", Config.UndressAnimation)
	AddToggleOptionST("RedressVictim","$SSL_VictimsRedress", Config.RedressVictim)
	AddToggleOptionST("DisableTeleport","$SSL_DisableTeleport", Config.DisableTeleport)
	AddToggleOptionST("ShowInMap","$SSL_ShowInMap", Config.ShowInMap)
	; TODO: Reimplement these once the new UI stands
	; AddTextOptionST("NPCBed","$SSL_NPCsUseBeds", Chances[ClampInt(Config.NPCBed, 0, 2)])
	; AddTextOptionST("AskBed","$SSL_AskBed", BedOpt[ClampInt(Config.AskBed, 0, 2)])
EndFunction

state DisableScale
	; COMEBACK: Might want to delete this for good since scaling is essential and works relaibly for latest
	event OnSelectST()
		Config.DisableScale = !Config.DisableScale
		SetToggleOptionValueST(Config.DisableScale)
		ForcePageReset()
	endEvent
	event OnDefaultST()
		Config.DisableScale = false
		SetToggleOptionValueST(Config.DisableScale)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoDisableScale")
	endEvent
endState

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
	AddEmptyOption()
	AddHeaderOption("$SSL_MatchMakerActorSettings", flag)
	AddToggleOptionST("ToggleSubmissivePlayer", "$SSL_ToggleSubmissivePlayer", Config.SubmissivePlayer, flag)
	AddToggleOptionST("ToggleSubmissiveTarget", "$SSL_ToggleSubmissiveTarget", Config.SubmissiveTarget, flag)
EndFunction

State ToggleMatchMaker
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
; --- Sound Settings                                  --- ;
; ------------------------------------------------------- ;

String[] _voices
Actor[] _voiceCachedActors
String[] _voiceCachedNames
int _voiceCacheIndex

String Function GetSavedVoice(Actor akActor) global
	String ret = sslVoiceSlots.GetSavedVoice(akActor)
	If (!ret)
		return "$SSL_Random"
	EndIf
	return ret
EndFunction

Function SoundSettings()
	SetCursorFillMode(LEFT_TO_RIGHT)
	If (_voiceCacheIndex >= _voiceCachedNames.Length)
		_voiceCacheIndex = 0
	EndIf
	; Voices & SFX
	AddSliderOptionST("VoiceVolume","$SSL_VoiceVolume", Config.VoiceVolume * 100, "{0}%")
	AddSliderOptionST("SFXVolume","$SSL_SFXVolume", Config.SFXVolume * 100, "{0}%")
	AddSliderOptionST("MaleVoiceDelay","$SSL_MaleVoiceDelay", Config.MaleVoiceDelay, "$SSL_Seconds")
	AddSliderOptionST("SFXDelay","$SSL_SFXDelay", Config.SFXDelay, "$SSL_Seconds")
	AddSliderOptionST("FemaleVoiceDelay","$SSL_FemaleVoiceDelay", Config.FemaleVoiceDelay, "$SSL_Seconds")
	AddEmptyOption()
	; Cached Voices
	AddHeaderOption("$SSL_CachedVoices")
	AddEmptyOption()
	AddMenuOptionST("SelectVoiceCache", "$SSL_SelectVoiceCache", _voiceCachedNames[_voiceCacheIndex])
	AddMenuOptionST("SelectVoiceCacheV", "$SSL_SelectVoiceCacheV", GetSavedVoice(_voiceCachedActors[_voiceCacheIndex]))
	; Toggle Voices
	AddHeaderOption("$SSL_ToggleVoices")
	AddEmptyOption()
	int i = 0
	While (i < _voices.Length)
		AddToggleOptionST("Voice_" + i, _voices[i], sslBaseVoice.GetEnabled(_voices[i]))
		i += 1
	EndWhile
EndFunction

State SelectVoiceCache
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(_voiceCacheIndex)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_voiceCachedNames)
	EndEvent
	Event OnMenuAcceptST(Int aiIndex)
		_voiceCacheIndex = aiIndex
		ForcePageReset()
		; SetMenuOptionValueST(_voiceCachedNames[aiIndex])
	EndEvent
	Event OnDefaultST()
		_voiceCacheIndex = 0
		ForcePageReset()
		; SetMenuOptionValueST(_voiceCachedNames[_voiceCacheIndex])
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SSL_SelectVoieCacheInfo")
	EndEvent
EndState

State SelectVoiceCacheV
	Event OnMenuOpenST()
		int idx = _voices.Find(GetSavedVoice(_voiceCachedActors[_voiceCacheIndex]))
		If (idx < 0)
			idx = 0
		Endif
		SetMenuDialogStartIndex(idx)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_voices)
	EndEvent
	Event OnMenuAcceptST(Int aiIndex)
		sslVoiceSlots.StoreVoice(_voiceCachedActors[_voiceCacheIndex], _voices[aiIndex])
		SetMenuOptionValueST(_voices[aiIndex])
	EndEvent
	Event OnHighlightST()
		SetInfoText("$SSL_SelectVoiceCacheVInfo")
	EndEvent
EndState

; ------------------------------------------------------- ;
; --- Timers & Stripping                              --- ;
; ------------------------------------------------------- ;

String[] _stripView
int _stripViewIdx

Function TimersStripping()
	SetCursorFillMode(LEFT_TO_RIGHT)
	; Timers
	AddHeaderOption("$SSL_Timers")
	AddEmptyOption()
	int t = 0
	While (t < 4)
		AddSliderOptionST("StageTimers_" + t, "$SSL_StageTimer_" + t, sslSystemConfig.GetSettingFltA("fTimers", t), "$SSL_Seconds")
		t += 1
	EndWhile
	; Stripping
	AddHeaderOption("$SSL_Stripping")
	AddMenuOptionST("TSModeSelect", "$SSL_View", _stripView[_stripViewIdx])
	AddTextOption("", "$SSL_StrippingFst_" + _stripViewIdx, OPTION_FLAG_DISABLED)
	AddTextOption("", "$SSL_StrippingSnd_" + _stripViewIdx, OPTION_FLAG_DISABLED)
	; iStripForms: 0b[Weapon][Female | Submissive][Aggressive]
	int r1 = _stripViewIdx * 4	; 0 / 4
	int r2 = r1 + 2	; 2 / 6
	AddToggleOptionST("StrippingW_" + (r1 + 1), "$SSL_Weapons", sslSystemConfig.GetSettingIntA("iStripForms", r1 + 1))
	AddToggleOptionST("StrippingW_" + (r2 + 1), "$SSL_Weapons", sslSystemConfig.GetSettingIntA("iStripForms", r2 + 1))
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
EndFunction

; ------------------------------------------------------- ;
; --- Strip Editor                                    --- ;
; ------------------------------------------------------- ;

Form[] _playerItems
Form[] _targetItems
bool _playerDisplayAll
bool _targetDisplayAll

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

String Function GetItemName(Form ItemRef, string AltName = "$SSL_Unknown")
	If (!ItemRef)
		return "None"
	EndIf
	String name = ItemRef.GetName()
	If (sslUtility.Trim(name) != "")
		return name
	EndIf
	return AltName
EndFunction

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

Function StripEditor()
	SetCursorFillMode(TOP_TO_BOTTOM)
	int n = 0
	While (n < 2)
		Form[] list
		If (n == 0)
			AddHeaderOption("$SSL_Equipment{" + PlayerREf.GetActorBase().GetName() + "}")
			AddToggleOptionST("FullInventory_" + n, "$SSL_FullInventory", _playerDisplayAll)
			_playerItems = sslSystemConfig.GetStrippableItems(PlayerRef, !_playerDisplayAll)
			list = _playerItems
		Else
			If (!Config.TargetRef)
				AddTextOption("$SSL_NoTarget", "")
				return
			EndIf
			AddHeaderOption("$SSL_Equipment{" + Config.TargetRef.GetLeveledActorBase().GetName() + "}")
			AddToggleOptionST("FullInventory_" + n, "$SSL_FullInventory", _targetDisplayAll)
			_targetItems = sslSystemConfig.GetStrippableItems(TargetRef, !_targetDisplayAll)
			list = _targetItems
		EndIf
		int MAX_ENTRIES = 62
		int i = 0
		While (i < list.Length && i < MAX_ENTRIES)
			AddTextOptionST("StripFlag_" + n + "_" + i, GetItemName(list[i]), GetStripState(list[i]))
			i += 1
		EndWhile
		n += 1
	EndWhile
EndFunction

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

Event OnSelectST()
	string[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "AutoAdvance")
		Config.AutoAdvance = !Config.AutoAdvance
		SetToggleOptionValueST(Config.AutoAdvance)
	ElseIf (s[0] == "DisableVictim")
		Config.DisablePlayer = !Config.DisablePlayer
		SetToggleOptionValueST(Config.DisablePlayer)
	ElseIf (s[0] == "AutomaticTFC")
		Config.AutoTFC = !Config.AutoTFC
		SetToggleOptionValueST(Config.AutoTFC)
	ElseIf (s[0] == "OrgasmEffects")
		Config.OrgasmEffects = !Config.OrgasmEffects
		SetToggleOptionValueST(Config.OrgasmEffects)
	ElseIf (s[0] == "UseCum")
		Config.UseCum = !Config.UseCum
		SetToggleOptionValueST(Config.UseCum)
	ElseIf (s[0] == "UseExpressions")
		Config.UseExpressions = !Config.UseExpressions
		SetToggleOptionValueST(Config.UseExpressions)
	ElseIf (s[0] == "UseLipSync")
		Config.UseLipSync = !Config.UseLipSync
		SetToggleOptionValueST(Config.UseLipSync)
	ElseIf (s[0] == "AllowCreatures")
		Config.AllowCreatures = !Config.AllowCreatures
		SetToggleOptionValueST(Config.AllowCreatures)
	ElseIf (s[0] == "UseCreatureGender")
		Config.UseCreatureGender = !Config.UseCreatureGender
		SetToggleOptionValueST(Config.UseCreatureGender)
	ElseIf (s[0] == "UndressAnimation")
		Config.UndressAnimation = !Config.UndressAnimation
		SetToggleOptionValueST(Config.UndressAnimation)
	ElseIf (s[0] == "RedressVictim")
		Config.RedressVictim = !Config.RedressVictim
		SetToggleOptionValueST(Config.RedressVictim)
	ElseIf (s[0] == "DisableTeleport")
		Config.DisableTeleport = !Config.DisableTeleport
		SetToggleOptionValueST(Config.DisableTeleport)
	ElseIf (s[0] == "ShowInMap")
		Config.ShowInMap = !Config.ShowInMap
		SetToggleOptionValueST(Config.ShowInMap)

	ElseIf (s[0] == "Voice")
		int idx = s[1] as int
		bool e = sslBaseVoice.GetEnabled(_voices[idx])
		sslBaseVoice.SetEnabled(_voices[idx], !e)
		SetToggleOptionValueST(!e)

	ElseIf(s[0] == "StrippingW")
		int i = s[1] as int
		int value = 1 - sslSystemConfig.GetSettingIntA("iStripForms", i)
		sslSystemConfig.SetSettingIntA("iStripForms", value, i)
		SetToggleOptionValueST(value)
	ElseIf(s[0] == "Stripping")
		int i = s[1] as int
		int n = s[2] as int
		int bit = Math.LeftShift(1, n)
		int value = Math.LogicalXor(sslSystemConfig.GetSettingIntA("iStripForms", i), bit)
		sslSystemConfig.SetSettingIntA("iStripForms", value, i)
    SetToggleOptionValueST(Math.LogicalAnd(value, bit))

	ElseIf (s[0] == "FullInventory")
		If (s[1] as int == 0)
			_playerDisplayAll = !_playerDisplayAll
		Else
			_targetDisplayAll = !_targetDisplayAll
		EndIf
		ForcePageReset()
	ElseIf(s[0] == "StripFlag")
		int n = s[1] as int
		int i = s[2] as int
		Form item
		If (n == 0)
			item = _playerItems[i]
		Else
			item = _targetItems[i]
		EndIf
		int j = sslActorLibrary.CheckStrip(item)
		If(j == -1)			; Never 			-> Always
			sslActorLibrary.WriteStrip(item, false)
		ElseIf(j == 1)	; Always			-> Unspecified
			sslActorLibrary.EraseStrip(item)
		ElseIf(j == 0)	; Unspecified	-> Never
			sslActorLibrary.WriteStrip(item, true)
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
			; ShowAnimationEditor = true
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

	ElseIf (s[0] == "Strapon")	; Toggle Strapons
		int i = s[1] as int
		Form[] Output
		Form[] Strapons = Config.Strapons
		int n = Strapons.Length
		while n
			n -= 1
			if n != i
				Output = PapyrusUtil.PushForm(Output, Strapons[n])
			endIf
		endWhile
		Config.Strapons = Output
		ForcePageReset()

	ElseIf (s[0] == "InputTags")	; Matchmaker Tags
		ShowMessage(sslSystemConfig.ParseMMTagString(), false, "$Done")
	ElseIf (s[0] == "TextResetTags")
		If (!ShowMessage("$SSL_TagResetAreYouSure"))
			return
		EndIf
		sslSystemConfig.SetSettingStr("sRequiredTags", "")
		sslSystemConfig.SetSettingStr("sOptionalTags", "")
		sslSystemConfig.SetSettingStr("sExcludedTags", "")
		ForcePageReset()
	ElseIf (s[0] == "ToggleSubmissivePlayer")
		Config.SubmissivePlayer = !Config.SubmissivePlayer
		SetToggleOptionValueST(Config.SubmissivePlayer)
	ElseIf (s[0] == "ToggleSubmissiveTarget")
		Config.SubmissiveTarget = !Config.SubmissiveTarget
		SetToggleOptionValueST(Config.SubmissiveTarget)
	endIf
endEvent

event OnSliderOpenST()
	string[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "AutomaticSUCSM")
		SetSliderDialogStartValue(Config.AutoSUCSM)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	ElseIf (s[0] == "ShakeStrength")
		SetSliderDialogStartValue(Config.ShakeStrength * 100)
		SetSliderDialogDefaultValue(70)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(5)
	ElseIf (s[0] == "CumEffectTimer")
		SetSliderDialogStartValue(Config.CumTimer)
		SetSliderDialogDefaultValue(120)
		SetSliderDialogRange(0, 43200)
		SetSliderDialogInterval(10)

	ElseIf (s[0] == "VoiceVolume")
		SetSliderDialogStartValue(Config.VoiceVolume * 100)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	ElseIf (s[0] == "SFXVolume")
		SetSliderDialogStartValue(Config.SFXVolume * 100)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	ElseIf (s[0] == "MaleVoiceDelay")
		SetSliderDialogStartValue(Config.MaleVoiceDelay)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(1, 45)
		SetSliderDialogInterval(1)
	ElseIf (s[0] == "FemaleVoiceDelay")
		SetSliderDialogStartValue(Config.FemaleVoiceDelay)
		SetSliderDialogDefaultValue(4)
		SetSliderDialogRange(1, 45)
		SetSliderDialogInterval(1)
	ElseIf (s[0] == "SFXDelay")
		SetSliderDialogStartValue(Config.SFXDelay)
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)

	ElseIf(s[0] == "StageTimers")
		int i = s[1] as int
		SetSliderDialogStartValue(sslSystemConfig.GetSettingFltA("fTimers", i))
		SetSliderDialogRange(3, 180)
		SetSliderDialogInterval(1)
		SetSliderDialogDefaultValue(15)

	; Animation Editor
elseif Options[0] == "Adjust"
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
	EndIf
endEvent

event OnSliderAcceptST(float value)
	string[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "AutomaticSUCSM")
		Config.AutoSUCSM = value
		SetSliderOptionValueST(Config.AutoSUCSM, "{0}")
	ElseIf (s[0] == "ShakeStrength")
		Config.ShakeStrength = (value / 100.0)
		SetSliderOptionValueST(value, "{0}%")
	ElseIf (s[0] == "CumEffectTimer")
		Config.CumTimer = value
		SetSliderOptionValueST(Config.CumTimer, "$SSL_Seconds")
		
	ElseIf (s[0] == "VoiceVolume")
		Config.VoiceVolume = (value / 100.0)
		Config.AudioVoice.SetVolume(Config.VoiceVolume)
		SetSliderOptionValueST(value, "{0}%")
	ElseIf (s[0] == "SFXVolume")
		Config.SFXVolume = (value / 100.0)
		Config.AudioSFX.SetVolume(Config.SFXVolume)
		SetSliderOptionValueST(value, "{0}%")
	ElseIf (s[0] == "MaleVoiceDelay")
		Config.MaleVoiceDelay = value
		SetSliderOptionValueST(Config.MaleVoiceDelay, "$SSL_Seconds")
	ElseIf (s[0] == "FemaleVoiceDelay")
		Config.FemaleVoiceDelay = value
		SetSliderOptionValueST(Config.FemaleVoiceDelay, "$SSL_Seconds")
	ElseIf (s[0] == "SFXDelay")
		Config.SFXDelay = value
		SetSliderOptionValueST(Config.SFXDelay, "$SSL_Seconds")

	ElseIf(s[0] == "StageTimers")
		int i = s[1] as int
		sslSystemConfig.SetSettingFltA("fTimers", value, i)
		SetSliderOptionValueST(value, "$SSL_Seconds")

	; Animation Editor
elseif Options[0] == "Adjust"
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
	EndIf
EndEvent

Event OnMenuOpenST()
	String[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "ClimaxType")
		SetMenuDialogStartIndex(sslSystemConfig.GetSettingInt("iClimaxType"))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_ClimaxTypes)
	ElseIf (s[0] == "FilterStrictness")
		SetMenuDialogStartIndex(sslSystemConfig.GetSettingInt("iFilterStrictness"))
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(_FilterOpt)
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

	ElseIf (s[0] == "TSModeSelect")
		SetMenuDialogStartIndex(_stripViewIdx)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_stripView)

	ElseIf (s[0] == "LipsPhoneme")	; Expression OpenMouth & LipSync Editor
		string[] LipsPhonemes = new String[1]
		LipsPhonemes[0] = "$SSL_Automatic"
		LipsPhonemes = PapyrusUtil.MergeStringArray(LipsPhonemes, Phonemes)
		SetMenuDialogStartIndex(sslSystemConfig.GetSettingInt("iLipsPhoneme") + 1)
		SetMenuDialogDefaultIndex(2) ; BigAah
		SetMenuDialogOptions(LipsPhonemes)
	EndIf
EndEvent

Event OnMenuAcceptST(int aiIndex)
	String[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (aiIndex < 0)
		return
	EndIf
	If (s[0] == "ClimaxType")
		sslSystemConfig.SetSettingInt("iClimaxType", aiIndex)
		SetMenuOptionValueST(_ClimaxTypes[aiIndex])
	ElseIf (s[0] == "FilterStrictness")
		sslSystemConfig.SetSettingInt("iFilterStrictness", aiIndex)
		SetMenuOptionValueST(_FilterOpt[aiIndex])
	ElseIf (s[0] == "SexSelect")
		If (s[1] == "0")
			ActorLib.TreatAsSex(PlayerRef, aiIndex)
		Else
			ActorLib.TreatAsSex(Config.TargetRef, aiIndex)
		EndIf
		SetMenuOptionValueST(_Sexes[aiIndex])
	ElseIf (s[0] == "UseFade")
		sslSystemConfig.SetSettingInt("iUseFade", aiIndex)
		SetMenuOptionValueST(_FadeOpt[aiIndex])

	ElseIf (s[0] == "TSModeSelect")
		_stripViewIdx = aiIndex
		ForcePageReset()

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
	String[] options = PapyrusUtil.StringSplit(GetState(), "_")
	; --- Matchmaker Tags
	If (options[0] == "InputRequiredTags")
		SetInputDialogStartText(Config.RequiredTags)
		ForcePageReset()
	ElseIf (options[0] == "InputExcludedTags")
		SetInputDialogStartText(Config.ExcludedTags)
		ForcePageReset()
	ElseIf (options[0] == "InputOptionalTags")
		SetInputDialogStartText(Config.OptionalTags)
		ForcePageReset()
	Else
		SetInputDialogStartText("Error: Invalid Option ID " + options)
	EndIf
EndEvent

Event OnInputAcceptST(String inputString)
	String[] options = PapyrusUtil.StringSplit(GetState(), "_")
	; --- Matchmaker Tags
	If (options[0] == "InputRequiredTags")
		Config.RequiredTags = inputString
		SetInputOptionValueST(Config.RequiredTags)
	ElseIf (options[0] == "InputExcludedTags")
		Config.ExcludedTags = inputString
		SetInputOptionValueST(Config.ExcludedTags)
	ElseIf (options[0] == "InputOptionalTags")
		Config.OptionalTags = inputString
		SetInputOptionValueST(Config.OptionalTags)
	EndIf
EndEvent

Event OnHighlightST()
	string[] s = PapyrusUtil.StringSplit(GetState(), "_")
	If (s[0] == "AutoAdvance")
		SetInfoText("$SSL_InfoAutoAdvance")
	ElseIf (s[0] == "ClimaxType") 
		SetInfoText("$SSL_ClimaxInfo")
	ElseIf (s[0] == "SexSelect")
		SetInfoText("$SSL_InfoPlayerGender")
	ElseIf (s[0] == "UseFade")
		SetInfoText("$SSL_UseFadeInfo")
	ElseIf (s[0] == "FilterStrictness")
		SetInfoText("$SSL_FilterStrictnessInfo")
	ElseIf (s[0] == "DisableVictim")
		SetInfoText("$SSL_InfoDisablePlayer")
	ElseIf (s[0] == "AutomaticTFC")
		SetInfoText("$SSL_InfoAutomaticTFC")
	ElseIf (s[0] == "AutomaticSUCSM")
		SetInfoText("$SSL_InfoAutomaticSUCSM")
	ElseIf (s[0] == "OrgasmEffects")
		SetInfoText("$SSL_InfoOrgasmEffects")
	ElseIf (s[0] == "ShakeStrength")
		SetInfoText("$SSL_InfoShakeStrength")
	ElseIf (s[0] == "UseCum")
		SetInfoText("$SSL_InfoUseCum")
	ElseIf (s[0] == "CumEffectTimer")
		SetInfoText("$SSL_InfoCumTimer")
	ElseIf (s[0] == "UseExpressions")
		SetInfoText("$SSL_InfoUseExpressions")
	ElseIf (s[0] == "UseLipSync")
		SetInfoText("$SSL_InfoUseLipSync")
	ElseIf (s[0] == "AllowCreatures")
		SetInfoText("$SSL_InfoAllowCreatures")
	ElseIf (s[0] == "UseCreatureGender")
		SetInfoText("$SSL_InfoUseCreatureGender")
	ElseIf (s[0] == "UndressAnimation")
		SetInfoText("$SSL_InfoUndressAnimation")
	ElseIf (s[0] == "RedressVictim")
		SetInfoText("$SSL_InfoReDressVictim")
	ElseIf (s[0] == "DisableTeleport")
		SetInfoText("$SSL_InfoDisableTeleport")
	ElseIf (s[0] == "ShowInMap")
		SetInfoText("$SSL_InfoShowInMap")

	ElseIf (s[0] == "VoiceVolume")
		SetInfoText("$SSL_InfoVoiceVolume")
	ElseIf (s[0] == "SFXVolume")
		SetInfoText("$SSL_InfoSFXVolume")
	ElseIf (s[0] == "MaleVoiceDelay")
		SetInfoText("$SSL_InfoMaleVoiceDelay")
	ElseIf (s[0] == "FemaleVoiceDelay")
		SetInfoText("$SSL_InfoFemaleVoiceDelay")
	ElseIf (s[0] == "SFXDelay")
		SetInfoText("$SSL_InfoSFXDelay")
	ElseIf (s[0] == "Voice")
		int idx = s[1] as int
		String[] tags = sslBaseVoice.GetVoiceTags(_voices[idx])
		SetInfoText("Tags: " + PapyrusUtil.StringJoin(tags, ", "))

	ElseIf(s[0] == "Stripping")
		int i = s[2] as int
		String info = PlayerRef.GetLeveledActorBase().GetName() + " Slot " + (i + 30) + ": "
		info += GetItemName(PlayerRef.GetWornForm(Armor.GetMaskForSlot(i + 30)), "?")
		If (Config.TargetRef)
			info += "\n" + Config.TargetRef.GetLeveledActorBase().GetName() + " Slot " + (i + 30) + ": "
			info += GetItemName(Config.TargetRef.GetWornForm(Armor.GetMaskForSlot(i + 30)), "?")
		EndIf
		SetInfoText(info)

	ElseIf(s[0] == "StripFlag")
		int n = s[1] as int
		int i = s[2] as int
		Form item
		If (n == 0)
			item = _playerItems[i]
		Else
			item = _targetItems[i]
		EndIf
		String InfoText = GetItemName(item, "?")
		Armor ArmorRef = item as Armor
		If(ArmorRef)
			InfoText += "\nArmor Slots: " + GetAllMaskSlots(ArmorRef.GetSlotMask())
		Else
			InfoText += "\nWeapon"
		EndIf
		SetInfoText(InfoText)

	; Animation Toggle
	Elseif Options[0] == "Animation"
		sslBaseAnimation Slot = AnimToggles[(Options[1] as int)]
		if Config.MirrorPress(Config.AdjustStage)
			SetInfoText("$SSL_AnimationEditor") ; TODO: ?
		else
			SetInfoText(Slot.Name+" Tags:\n"+StringJoin(Slot.GetTags(), ", "))
		endIf


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
	endIf
endEvent

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
		; AddToggleOptionST("LipsFixedValue", "$SSL_LipsFixedValue", Config.LipsFixedValue)
		AddEmptyOption()

		AddSliderOptionST("LipsMinValue", "$SSL_LipsMinValue", Config.LipsMinValue, "{0}")
		AddSliderOptionST("LipsMaxValue", "$SSL_LipsMaxValue", Config.LipsMaxValue, "{0}")

		AddTextOptionST("LipsSoundTime", "$SSL_LipsSoundTime", SoundTreatment[ClampInt(Config.LipsSoundTime + 1, 0, 2)])
		AddSliderOptionST("LipsMoveTime", "$SSL_LipsMoveTime", Config.LipsMoveTime, "$SSL_Seconds")

		return ; to hide the rest of the options

	endif
	SetTitleText(Expression.Name)

	AddHeaderOption("$SSL_OpenMouthConfig")
	AddHeaderOption("")

	AddSliderOptionST("OpenMouthSize","$SSL_OpenMouthSize", Config.OpenMouthSize, "{0}%")
	AddTextOptionST("AdvancedOpenMouth", "$SSL_EditOpenMouth", "$SSL_ClickHere")

	; 1
	AddHeaderOption("$SSL_ExpressionEditor")
	AddHeaderOption("")

	AddMenuOptionST("ExpressionSelect", "$SSL_ModifyingExpression", Expression.Name)
	AddToggleOptionST("ExpressionEnabled", "$SSL_Enabled", Expression.Enabled)

	; 2
	AddToggleOptionST("ExpressionNormal", "$SSL_ExpressionsNormal", Expression.HasTag("Normal"))
	AddEmptyOption()

	; 3
	AddToggleOptionST("ExpressionVictim", "$SSL_ExpressionsVictim", Expression.HasTag("Victim"))
	AddEmptyOption()

	; 4
	AddToggleOptionST("ExpressionAggressor", "$SSL_ExpressionsAggressor", Expression.HasTag("Aggressor"))
	AddTextOptionST("ExpressionTestPlayer", "$SSL_TestOnPlayer", "$SSL_Apply")

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
; --- Debug & installation							              --- ;
; ------------------------------------------------------- ;

Function RebuildClean()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("SexLab v" + GetStringVer() + " by Ashal@LoversLab.com")
	AddToggleOptionST("DebugMode","$SSL_DebugMode", Config.DebugMode)
	AddTextOptionST("StopCurrentAnimations","$SSL_StopCurrentAnimations", "$SSL_ClickHere")
	AddTextOptionST("ResetStripOverrides","$SSL_ResetStripOverrides", "$SSL_ClickHere")
	AddTextOptionST("CleanSystem","$SSL_CleanSystem", "$SSL_ClickHere")
	AddHeaderOption("$SSL_AvailableStrapons")
	AddTextOptionST("RebuildStraponList","$SSL_RebuildStraponList", "$SSL_ClickHere")
	int i = Config.Strapons.Length
	While i
		i -= 1
		String Name = Config.Strapons[i].GetName()
		AddTextOptionST("Strapon_" + i, Name, "$SSL_Remove")
	EndWhile

	SetCursorPosition(1)
	AddHeaderOption("Registry Info")
	; IDEA: Allow clicking on this for more info, custom swf mayhaps?
	AddTextOption("Animations", sslSystemConfig.GetAnimationCount(), OPTION_FLAG_DISABLED)
	AddTextOption("Voices", sslVoiceSlots.GetAllVoices().Length, OPTION_FLAG_DISABLED)
	AddTextOption("Expressions", sslExpressionSlots.GetAllProfileIDs().Length, OPTION_FLAG_DISABLED)
	AddHeaderOption("System Requirements")
	SystemCheckOptions()
EndFunction

Function InstallMenu()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("SexLab v" + GetStringVer())
	SystemCheckOptions()

	SetCursorPosition(1)
	AddHeaderOption("$SSL_Installation")
	AddTextOption("$SSL_CurrentlyInstalling", "!")

	While (!SystemAlias.IsInstalled)
		Utility.WaitMenuMode(0.5)
	EndWhile
	ForcePageReset()
EndFunction

Function SystemCheckOptions()
	String[] okOrFail = new String[2]
	okOrFail[0] = "<font color='#FF0000'>X</font>"
	okOrFail[1] = "<font color='#00FF00'>ok</font>"

	AddTextOption("Skyrim Script Extender", okOrFail[Config.CheckSystemPart("SKSE") as int], OPTION_FLAG_DISABLED)
	AddTextOption("SexLab.dll", okOrFail[Config.CheckSystemPart("SexLabP+") as int], OPTION_FLAG_DISABLED)
	AddTextOption("PapyrusUtil.dll", okOrFail[Config.CheckSystemPart("PapyrusUtil") as int], OPTION_FLAG_DISABLED)
	AddTextOption("RaceMenu", okOrFail[Config.CheckSystemPart("NiOverride") as int], OPTION_FLAG_DISABLED)
	AddTextOption("Mfg Fix", okOrFail[Config.CheckSystemPart("MfgFix") as int], OPTION_FLAG_DISABLED)
EndFunction

; ------------------------------------------------------- ;
; --- Unorganized State Option Dump                   --- ;
; ------------------------------------------------------- ;


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


state StopCurrentAnimations
	event OnSelectST()
		ShowMessage("$SSL_StopRunningAnimations", false)
		ThreadSlots.StopAll()
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
state DebugMode
	event OnSelectST()
		Config.DebugMode = !Config.DebugMode
		SetToggleOptionValueST(Config.DebugMode)
	endEvent
	event OnHighlightST()
		SetInfoText("$SSL_InfoDebugMode")
	endEvent
endState
state CleanSystem
	event OnSelectST()
		if ShowMessage("$SSL_WarnCleanSystem")
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

sslActorStats Property Stats Hidden
  sslActorStats Function Get()
	  return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorStats
  EndFunction
EndProperty
sslExpressionSlots Property ExpressionSlots Hidden
	sslExpressionSlots Function Get()
		return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslExpressionSlots
	EndFunction
EndProperty
sslVoiceSlots property VoiceSlots Hidden
  sslVoiceSlots Function Get()
	  return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslVoiceSlots
  EndFunction
EndProperty

string[] function MapOptions()
	return PapyrusUtil.StringSplit(GetState(), "_")
endFunction

function Troubleshoot()
endFunction

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
	if _stripViewIdx == 1
		if type == 1
			return Config.StripLeadInFemale
		else
			return Config.StripLeadInMale
		endIf
	elseIf _stripViewIdx == 2
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

float Function GetDefaultTime(int idx)
	float[] f = new float[15]
	; Default
	f[0] = 15.0		
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


float[] function GetTimers()
	if _stripViewIdx == 1
		return Config.StageTimerLeadIn
	elseIf _stripViewIdx == 2
		return Config.StageTimerAggr
	else
		return Config.StageTimer
	endIf
endFunction

; Default Timer Values
float[] function GetTimersDef()
	float[] ret = new float[5]
	if _stripViewIdx == 1
		ret[0] = 10.0
		ret[1] = 10.0
		ret[2] = 10.0
		ret[3] = 8.0
		ret[4] = 8.0
	elseIf _stripViewIdx == 2
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
