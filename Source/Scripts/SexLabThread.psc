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

int Property STATUS_UNDEF 	= 0 AutoReadOnly  ; Undefined
int Property STATUS_IDLE	 	= 1 AutoReadOnly  ; Idling (Inactive)
int Property STATUS_SETUP 	= 2 AutoReadOnly  ; Preparing an animation. Available data may be incomplete
int Property STATUS_INSCENE = 3 AutoReadOnly  ; Playing an animation
int Property STATUS_ENDING	= 4 AutoReadOnly  ; Ending. Data is still available but most functionality is disabled

; Return the current status of the thread. This status divides the threads functionality in sub sections
; Some functionality may depend on current thread status
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

; Force the argument scene to be played instead of the currently active one
; On success, will delete stage history and sort actors to the new scene
bool Function ResetScene(String asScene)
EndFunction

; Branch or skip from the currently playing stage. Will fail if called outside of playing state
; If the given branch/stage does not exist will end the scene
Function BranchTo(int aiNextBranch)
EndFunction
Function SkipTo(String asNextStage)
EndFunction

; Stop this threads animation. Will fail if the thread is idling/ending
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

; --- Submission

; Return if the given actor is a submissive or not
bool Function GetSubmissive(Actor akActor)
EndFunction
Function SetIsSubmissive(Actor akActor, bool abIsSubmissive)
EndFunction
; Get all submissives for the current animation
Actor[] Function GetSubmissives()
EndFunction

; --- Stripping

; Set custom strip settings for this actor
; aiSlots represents a slot mask of all slots that should be unequipped (if possible)
Function SetCustomStrip(Actor akActor, int aiSlots, bool abWeapon, bool abApplyNow)
EndFunction
; If the actor will play a short animation on scene start when undressing. Only used before entering playing state
bool Function IsUndressAnimationAllowed(Actor akActor)
EndFunction
Function SetIsUndressAnimationAllowed(Actor akActor, bool abAllowed)
EndFunction
; if the actor will re-equip their gear after the animation (and they are not a submissive)
bool Function IsRedressAllowed(Actor akActor)
EndFunction
Function SetIsRedressAllowed(Actor akActor, bool abAllowed)
EndFunction

; --- Voice

; Update the given actors voice
Function SetVoice(Actor ActorRef, sslBaseVoice Voice, bool ForceSilent = false)
EndFunction
sslBaseVoice Function GetVoice(Actor ActorRef)
EndFunction

; --- Expressions

; Update the given actors expression
Function SetExpression(Actor ActorRef, sslBaseExpression Expression)
EndFunction
sslBaseExpression Function GetExpression(Actor ActorRef)
EndFunction

; --- Orgasms

; Disable or enable orgasm events for the stated actor
Function DisableOrgasm(Actor ActorRef, bool OrgasmDisabled = true)
EndFunction
bool Function IsOrgasmAllowed(Actor ActorRef)
EndFunction
; Create an orgasm event for the given actor
Function ForceOrgasm(Actor ActorRef)
EndFunction

; --- Strapons

; Set the strapon this actor should use. Will fail if the actor isnt a valid target for strapon usage
Function SetStrapon(Actor ActorRef, Form ToStrapon)
endfunction
Form Function GetStrapon(Actor ActorRef)
endfunction
; if the given actor is currently using a strapon
bool Function IsUsingStrapon(Actor ActorRef)
EndFunction

; --- Pathing

int Property PATHING_DISABLE = -1 AutoReadOnly	; Always be teleported
int Property PATHING_ENABLE = 0 AutoReadOnly		; Let the user config decide (default)
int Property PATHING_FORCE = 1 AutoReadOnly			; Always try to walk unless the distance is too great

; Set the pathing flag of the position, determing if this actor can walk to the center or should be teleported to it
; This can only be set before playing state
Function SetPathingFlag(Actor akActor, int aiPathingFlag)
EndFunction
