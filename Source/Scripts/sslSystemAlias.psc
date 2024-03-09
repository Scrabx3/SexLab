scriptname sslSystemAlias extends ReferenceAlias
{
	Internal Script to manage script re/initialization
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
import SexLabUtil

; Framework
SexLabFramework property SexLab auto
sslSystemConfig property Config auto

; Function libraries
sslActorLibrary property ActorLib auto
sslThreadLibrary property ThreadLib auto
sslActorStats property Stats auto

; Object registry
sslThreadSlots property ThreadSlots auto
sslVoiceSlots property VoiceSlots auto
sslExpressionSlots property ExpressionSlots auto

int Property STATUS_IDLE = 0 AutoReadOnly
int Property STATUS_INSTALLING = 1 AutoReadOnly
int Property STATUS_READY = 2 AutoReadOnly
int _InstallStatus

bool property IsInstalled hidden
	bool function get()
		return _InstallStatus == STATUS_READY
	endFunction
endProperty

; Version the mod has been initialized with
int Version

; COMEBACK: May eventually want to make these properties redundant as well
; Currently being held back by the Stats system/actor cleanup being papyurs based
bool ForcedOnce = false
bool property PreloadDone auto hidden

; ------------------------------------------------------- ;
; --- System Startup                                  --- ;
; ------------------------------------------------------- ;


event OnInit()
	; TODO: When fully automating installation, have this initialize the mod

	; GoToState("")
	; LoadLibs(false)
	; ForcedOnce = false
endEvent

event OnPlayerLoadGame()
	; Config.DebugMode = true
	Log("Version " + Version + " / " + SexLabUtil.GetVersion(), "LOADED")
	If (!Config.CheckSystem())
		; Function above will notify the player in case of error, can fail silently here
		return
	ElseIf IsInstalled
		If (Version < SexLabUtil.GetVersion())
			; --- update code here?
			; NOTE: If I never use this then this Version variable is unnecessary and should be removed
			Version = SexLabUtil.GetVersion()
		EndIf
		Config.Reload()
		ThreadSlots.StopAll()
		ModEvent.Send(ModEvent.Create("SexLabGameLoaded"))
	elseIf !ForcedOnce
		Utility.Wait(0.1)
		RegisterForSingleUpdate(30.0)
	endIf
endEvent

; Check if we should force install system, because user hasn't done it manually yet for some reason. Or it failed somehow.
event OnUpdate()
	if !IsInstalled && !ForcedOnce && _InstallStatus == STATUS_IDLE
		Quest UnboundQ = Quest.GetQuest("MQ101")
		if !UnboundQ.GetStageDone(250) && UnboundQ.GetStage() > 0
			; Wait until the end of the opening quest(cart scene) to prevent issues related with the First Person Camera
			RegisterForSingleUpdate(120.0)
		else
			ForcedOnce = true
			LogAll("Automatically Installing SexLab v" + SexLabUtil.GetStringVer())
			InstallSystem()
		endIf
	endIf
endEvent

; ------------------------------------------------------- ;
; --- System Install/Update                           --- ;
; ------------------------------------------------------- ;

bool function SetupSystem()
	_InstallStatus = STATUS_INSTALLING
	LoadLibs()
	SexLab.GoToState("Disabled")
	Version = SexLabUtil.GetVersion()

	; Framework
	SexLab.Setup()
	Config.Setup()

	; Function libraries
	ThreadLib.Setup()
	ActorLib.Setup()
	Stats.Setup()

	; Object registry
	VoiceSlots.Setup()
	ExpressionSlots.Setup()
	ThreadSlots.Setup()

	; Finish setup
	SexLab.GoToState("Enabled")
	_InstallStatus = STATUS_READY
	LogAll("SexLab v" + SexLabUtil.GetStringVer() + " - Ready!")
	; Clean storage lists	(Async)
	CleanActorStorage()
	return true
endFunction

event InstallSystem()
	ForcedOnce = true
	; Begin installatio
	LogAll("SexLab v" + SexLabUtil.GetStringVer() + " - Installing...")
	; Init system
	SetupSystem()
	int eid = ModEvent.Create("SexLabInstalled")
	ModEvent.PushInt(eid, Version)
	ModEvent.Send(eid)
endEvent

; ------------------------------------------------------- ;
; --- System Cleanup                                  --- ;
; ------------------------------------------------------- ;

function CleanActorStorage()
	if !PreloadDone
		GoToState("PreloadStorage")
		return
	endIf
	Log("Starting actor storage cleanup" ,"CleanActorStorage")
	FormListRemove(none, "SexLab.ActorStorage", none, true)
	Form[] ActorStorage = FormListToArray(none, "SexLab.ActorStorage")
	int i = ActorStorage.Length
	while i > 0
		i -= 1
		Actor ref = ActorStorage[i] as Actor
		if !ref || !IsImportant(ref, false)
			ClearFromActorStorage(ActorStorage[i])
		endIf
	endWhile
	; Log change in storage
	int Count = FormListCount(none, "SexLab.ActorStorage")
	Log("Completed actor storage cleanup: " + ActorStorage.Length + " -> " + Count, "CleanActorStorage")
	if Config.DebugMode
		debug_Cleanup()
	endIf
endFunction

function ClearFromActorStorage(Form FormRef)
	UnsetStringValue(FormRef, "SexLab.SavedVoice")
	UnsetStringValue(FormRef, "SexLab.CustomVoiceAlias")
	UnsetFormValue(FormRef, "SexLab.CustomVoiceQuest")
	FormListRemove(none, "SexLab.ActorStorage", FormRef, true)
endFunction

bool function IsImportant(Actor ActorRef, bool Strict = false) global
	if ActorRef == Game.GetPlayer()
		return true
	elseIf !ActorRef || ActorRef.IsDead() || ActorRef.IsDeleted() || ActorRef.IsChild()
		return false
	elseIf !Strict
		return true
	endIf
	ActorBase BaseRef = ActorRef.GetLeveledActorBase()
	return BaseRef.IsUnique() || BaseRef.IsEssential() || BaseRef.IsInvulnerable() || BaseRef.IsProtected() || ActorRef.IsPlayerTeammate() || ActorRef.Is3DLoaded()
endFunction

state PreloadStorage
	event OnBeginState()
		RegisterForSingleUpdate(0.1)
	endEvent
	event OnUpdate()
		GoToState("")
		if PreloadDone
			return
		endIf
		PreloadDone = true
		Log("Preloading actor storage")
		; Start actor preloading
		int PreCount = FormListCount(none, "SexLab.ActorStorage")
		FormListRemove(none, "SexLab.ActorStorage", none, true)
		; Check string values for SexLab.SavedVoice
		Form[] Forms = debug_AllStringObjs()
		int i = Forms.Length
		while i > 0
			i -= 1
			if Forms[i] && !FormListHas(none, "SexLab.ActorStorage", Forms[i]) && HasStringValue(Forms[i], "SexLab.SavedVoice")
				sslSystemConfig.StoreActor(Forms[i])
			endIf
		endWhile
		; Log change in storage
		int Count = FormListCount(none, "SexLab.ActorStorage")
		Log("Completed preload: " + PreCount + " -> " + Count, "PreloadSavedStorage")
		; Preload finished, now clean it.
		CleanActorStorage()
	endEvent
endState

; ------------------------------------------------------- ;
; --- System Utils                                    --- ;
; ------------------------------------------------------- ;

function Log(string Log, string Type = "NOTICE")
	Log = "SEXLAB - "+Type+": "+Log
	SexLabUtil.PrintConsole(Log)
	Debug.Trace(Log)
endFunction

function LogAll(string Log)
	Log = "SexLab  - "+Log
	Debug.Notification(Log)
	Debug.Trace(Log)
	MiscUtil.PrintConsole(Log)
endFunction

function LoadLibs(bool Forced = false)
	; Sync function Libraries - SexLabQuestFramework
	Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
	SexLab      = SexLabQuestFramework as SexLabFramework
	Config      = SexLabQuestFramework as sslSystemConfig
	ThreadLib   = SexLabQuestFramework as sslThreadLibrary
	ThreadSlots = SexLabQuestFramework as sslThreadSlots
	ActorLib    = SexLabQuestFramework as sslActorLibrary
	Stats       = SexLabQuestFramework as sslActorStats
	; Sync secondary object registry - SexLabQuestRegistry
	Form SexLabQuestRegistry = Game.GetFormFromFile(0x664FB, "SexLab.esm")
	ExpressionSlots = SexLabQuestRegistry as sslExpressionSlots
	VoiceSlots      = SexLabQuestRegistry as sslVoiceSlots
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

sslAnimationSlots property AnimSlots Hidden
	sslAnimationSlots Function Get()
		return Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationSlots
	EndFunction
EndProperty
sslCreatureAnimationSlots property CreatureSlots Hidden
	sslCreatureAnimationSlots Function Get()
		return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationSlots
	EndFunction
EndProperty
sslObjectFactory property Factory Hidden
	sslObjectFactory Function Get()
		return Game.GetFormFromFile(0x78818, "SexLab.esm") as sslObjectFactory
	EndFunction
EndProperty

bool property UpdatePending hidden
	bool function get()
		return Version < SexLabUtil.GetVersion()
	endFunction
endProperty

int property CurrentVersion hidden
	int function get()
		return Version
	endFunction
endProperty

function CleanTrackedActors()
	FormListRemove(Config, "TrackedActors", none, true)
	Form[] TrackedActors = FormListToArray(Config, "TrackedActors")
	int i = TrackedActors.Length
	while i > 0
		i -= 1
		if !IsActor(TrackedActors[i])
			FormListRemoveAt(Config, "TrackedActors", i)
			StringListClear(TrackedActors[i], "SexLabEvents")
		endIf
	endWhile
endFunction

function CleanTrackedFactions()
	FormListRemove(Config, "TrackedFactions", none, true)
	Form[] TrackedFactions = FormListToArray(Config, "TrackedFactions")
	int i = TrackedFactions.Length
	while i
		i -= 1
		if !TrackedFactions[i] || TrackedFactions[i].GetType() != 11 ; kFaction
			FormListRemoveAt(Config, "TrackedFactions", i)
			StringListClear(TrackedFactions[i], "SexLabEvents")
		endIf
	endWhile
endFunction

event UpdateSystem(int OldVersion, int NewVersion)
endEvent

function SendVersionEvent(string VersionEvent)
	int eid = ModEvent.Create(VersionEvent)
	ModEvent.PushInt(eid, SexLabUtil.GetVersion())
	ModEvent.Send(eid)
endFunction

bool function IsActor(Form FormRef) global
	if FormRef
		int Type = FormRef.GetType()
		return Type == 43 || Type == 44 || Type == 62 ; kNPC = 43 kLeveledCharacter = 44 kCharacter = 62
	endIf
	return false
endFunction

function MenuWait()
	Utility.Wait(0.1)
endFunction
