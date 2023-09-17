ScriptName SexLabThread extends Quest
{
  API Script to directly interact with SexLab Threads
}

; The thread ID of the current thread
; These are unique and can be used to reference this specific thread throughout other parts of the framework
int Function GetThreadID()
EndFunction

; ------------------------------------------------------- ;
; --- Thread Status                                   --- ;
; ------------------------------------------------------- ;
;/
	View and manipulate runtime data
/;

int Property STATUS_UNDEF 	= 0 AutoReadOnly  ; Undefined (oh noes)
int Property STATUS_IDLE	 	= 1 AutoReadOnly  ; Idling (inactive)
int Property STATUS_SETUP 	= 2 AutoReadOnly  ; Preparing an animation. Available data may be incomplete
int Property STATUS_INSCENE = 3 AutoReadOnly  ; Playing an animation
int Property STATUS_ENDING	= 4 AutoReadOnly  ; Ending. Data is still available but most functionality is disabled

; Return the current status of the thread. This status divides the threads functionality in sub sections
; Some functionality is only available while a thread is in a specific status
int Function GetStatus()
EndFunction

; Get the currently running scene
String Function GetActiveScene()
EndFunction
; Get the currently running stage
String Function GetActiveStage()
EndFunction

; Get all scenes available to the current animation
String[] Function GetPlayingScenes()
EndFunction

; Stop this threads animation. Will error if the thread is idling/ending
Function StopAnimation()
EndFunction

; ------------------------------------------------------- ;
; --- Context                                         --- ;
; ------------------------------------------------------- ;
;/
	Context data are thread owned, custom tags used to specify the scenes context
    Custom contexts can be used to indirectly communicate with other mods
/;

; If the thread owns some context
bool Function HasContext(String asTag)
EndFunction

; Add or remove some context to/from the scene
Function AddContext(String asContext)
EndFunction
Function RemoveContext(String asContext)
EndFunction

; If the current animation is assumed to be consent
bool Function IsConsent()
EndFunction
Function SetConsent(bool abIsConsent)
EndFunction

; If the thread is currently in a lead in phase
bool Function IsLeadIn()
EndFunction

; ------------------------------------------------------- ;
; --- Position Info                                   --- ;
; ------------------------------------------------------- ;
;/
	Functions to view and manipulate position related data
/;

; If this actor is pariticpating in the scene
bool Function HasActor(Actor akActor)
EndFunction

; Retrieve all positions in the current scene. Order of actors is unspecified
Actor[] Function GetPositions()
EndFunction

; Return if the given actor is a submissive or not
bool Function GetSubmissive(Actor akActor)
EndFunction
Function SetIsSubmissive(Actor akActor, bool abIsSubmissive)
EndFunction

; Get all submissives for the current animation
Actor[] Function GetSubmissives()
EndFunction
