scriptname sslSystemLibrary extends Quest hidden
{
	Base Script for library type script
	With SLp+ 2.0 majority of SLs library functionanility is global, making most of this script unused
}

; TODO: Lay out which parts here exactly are unused
; While I assume majority of no longer being necessary, until all scripts inheriting this one have been
; refractured I can only guess how much of this script is truly unused

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

; Settings access
sslSystemConfig property Config auto

; Function libraries
sslActorLibrary property ActorLib auto
sslThreadLibrary property ThreadLib auto
sslActorStats property Stats auto

; Object registeries
sslThreadSlots property ThreadSlots auto
sslAnimationSlots property AnimSlots auto
sslCreatureAnimationSlots property CreatureSlots auto
sslVoiceSlots property VoiceSlots auto
sslExpressionSlots property ExpressionSlots auto

; Data
Actor property PlayerRef auto

; ------------------------------------------------------- ;
; --- Setup                                           --- ;
; ------------------------------------------------------- ;
;/
	Functions to re/initialize this script
/;

function LoadLibs(bool Forced = false)
	Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
	Config = SexLabQuestFramework as sslSystemConfig
	ThreadLib = SexLabQuestFramework as sslThreadLibrary
	ThreadSlots = SexLabQuestFramework as sslThreadSlots
	ActorLib = SexLabQuestFramework as sslActorLibrary
	Stats = SexLabQuestFramework as sslActorStats

	Form SexLabQuestAnimations = Game.GetFormFromFile(0x639DF, "SexLab.esm")
	AnimSlots = SexLabQuestAnimations as sslAnimationSlots

	Form SexLabQuestRegistry = Game.GetFormFromFile(0x664FB, "SexLab.esm")
	CreatureSlots = SexLabQuestRegistry as sslCreatureAnimationSlots
	ExpressionSlots = SexLabQuestRegistry as sslExpressionSlots
	VoiceSlots = SexLabQuestRegistry as sslVoiceSlots

	PlayerRef = Game.GetPlayer()
endFunction

function Setup()
	LoadLibs(true)
endFunction

; ------------------------------------------------------- ;
; --- Logging                                         --- ;
; ------------------------------------------------------- ;
;/
	Generic logging utility
/;

function Log(string msg, string Type = "NOTICE")
	msg = Type+" - "+msg
	if InDebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
	if Type == "FATAL"
		Debug.TraceStack("SEXLAB - "+msg)
	else
		Debug.Trace("SEXLAB - "+msg)
	endIf
endFunction

Function Error(String asMsg)
	asMsg = "ERROR - " + asMsg
	Debug.TraceStack("SEXLAB - " + asMsg)
	SexLabUtil.PrintConsole(asMsg)
	if Config.DebugMode
		Debug.TraceUser("SexLabDebug", asMsg)
	endIf
EndFunction

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

bool property InDebugMode hidden
	bool Function Get()
		return Config.DebugMode
	EndFunction
EndProperty
event SetDebugMode(bool ToMode)
	; InDebugMode = ToMode
endEvent

event OnInit()
	; LoadLibs(false)
	; Debug.Trace("SEXLAB -- Init "+self)
endEvent
