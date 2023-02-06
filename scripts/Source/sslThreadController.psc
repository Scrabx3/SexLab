scriptname sslThreadController extends sslThreadModel
{
	Class to access and write scene data
	Use the functions listed here to manipulate a running scene or retrieve data from it, to get a (valid) instance
	of this API use SexLabFramework.GetController(tid). The 'tid' or thread-id can be obtained through a variety of functions
	also found in the main API. It is also (and most commonly) accessed by listening to one of the various events invoked by a running thread

	Do NOT read or write a thread through any functions not listed here. There is no guarntee for backwards compatibility otherwise
	Do NOT link to an instance of this API through a direct property
}

; TODO: Add state-independent API

; ------------------------------------------------------- ;
; --- Animation End	                                  --- ;
; ------------------------------------------------------- ;

State Ending

	; TODO: Add API elements to ending scenes, eg "RestartScene(sslBaseAnimation)"

EndState

; ------------------------------------------------------- ;
; --- Animation Loop                                  --- ;
; ------------------------------------------------------- ;

State Animating

	; TODO: Add API elements to active Scenes

EndState

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

float Function GetAnimationRunTime()
	return Animation.GetTimersRunTime(Timers)
EndFunction

Function ResetPositions()
	RealignActors()
EndFunction

ObjectReference Function GetCenterFX()
	if CenterRef != none && CenterRef.Is3DLoaded()
		return CenterRef
	else
		int i = 0
		while i < ActorCount
			if Positions[i] != none && Positions[i].Is3DLoaded()
				return Positions[i]
			endIf
			i += 1
		endWhile
	endIf
EndFunction
