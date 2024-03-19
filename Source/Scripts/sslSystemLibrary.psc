scriptname sslSystemLibrary extends Quest hidden
{
	Base Script for library type script
	With SLp+ 2.0 majority of SLs library functionanility is global, making most of this script unused
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

; Settings access
sslSystemConfig property Config auto

; Object registeries
sslThreadSlots property ThreadSlots auto
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
	ThreadSlots = SexLabQuestFramework as sslThreadSlots

	Form SexLabQuestRegistry = Game.GetFormFromFile(0x664FB, "SexLab.esm")
	ExpressionSlots = SexLabQuestRegistry as sslExpressionSlots
	VoiceSlots = SexLabQuestRegistry as sslVoiceSlots

	PlayerRef = Game.GetPlayer()
endFunction

function Setup()
	LoadLibs()
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

sslActorLibrary Property ActorLib hidden
	sslActorLibrary Function Get()
			return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorLibrary
	EndFunction
EndProperty
sslThreadLibrary property ThreadLib hidden
	sslThreadLibrary Function Get()
		return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslThreadLibrary
	EndFunction
EndProperty
sslAnimationSlots property AnimSlots hidden
	sslAnimationSlots Function Get()
		return Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationSlots
	EndFunction
EndProperty
sslCreatureAnimationSlots property CreatureSlots hidden
	sslCreatureAnimationSlots Function Get()
		return Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationSlots
	EndFunction
EndProperty
sslActorStats property Stats Hidden
	sslActorStats Function Get()
		return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorStats
	EndFunction
EndProperty

bool property InDebugMode auto hidden
event SetDebugMode(bool ToMode)
	InDebugMode = ToMode
endEvent

event OnInit()
	; LoadLibs(false)
	; Debug.Trace("SEXLAB -- Init "+self)
endEvent
