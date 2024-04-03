ScriptName SexLabThread extends Quest
{
  API Script to directly interact with individual SexLab Threads
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

; Return a list of all played stages (including the currently playing one)
; This list may include duplicates if the scene looped (e.g. A -> B -> C -> A) and resets when the scene changes
; This creates a copy of the internal history, dont call this repeatedly when you can cache the result
String[] Function GetStageHistory()
EndFunction
; Same as above, but only returns the length of the history
int Function GetStageHistoryLength()
EndFunction

; Stop this threads animation. Will fail if the thread is idling/ending
Function StopAnimation()
EndFunction

; ------------------------------------------------------- ;
; --- Tags		                                        --- ;
; ------------------------------------------------------- ;
;/
	Tags are used to further describe a scene, they have different scopes:
		- ThreadTags combine tags shared by every scene the thread has been initiaited with, Example: if we have 2 scenes: 
				["doggy", "loving", "behind"] and ["doggy", "loving", "hugging", "kissing"], then the thread tags will be ["doggy", "loving"]
		- SceneTags describe the playing scene loosely, for each tag there is at least one stage that uses it
		- StageTags only describe the currently playing stage
/;

; If this thread is tagged with the given argument
bool Function HasTag(String asTag)
EndFunction
; If the active scene is tagged with the given argument
bool Function HasSceneTag(String asTag)
EndFunction
; If the active stage is tagged with the given argument
bool Function HasStageTag(String asTag)
EndFunction

bool Function IsSceneVaginal()
	return HasSceneTag("Vaginal")
EndFunction
bool Function IsSceneAnal()
	return HasSceneTag("Anal")
EndFunction
bool Function IsSceneOral()
	return HasSceneTag("Oral")
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
; --- Interaction		                                  --- ;
; ------------------------------------------------------- ;
;/
	Lookup interaction data
	This data is based on the actors 3D, its reliably thus heavily depends on 
	how well aligned the animation is
/;

int Property PTYPE_ANY			= -1 AutoReadOnly
int Property PTYPE_VAGINALP = 0  AutoReadOnly	; being penetrated
int Property PTYPE_ANALP 		= 1  AutoReadOnly
int Property PTYPE_VAGINALA = 2  AutoReadOnly	; penetrating someone else
int Property PTYPE_ANALA 		= 3  AutoReadOnly
int Property PTYPE_Oral 		= 4  AutoReadOnly	; receiving oral
int Property PTYPE_Foot 		= 5  AutoReadOnly	; receiving footjob
int Property PTYPE_Hand 		= 6  AutoReadOnly	; receiving handjob
int Property PTYPE_GRINDING = 7  AutoReadOnly	; grinding against someone else

; If physics related data is currently available or not
bool Function IsPhysicsEnabled()
EndFunction

; Get a list of all types the two actors interact with another
; If akPartner is none, returns all interactions with any partner
; This function is NOT commutative
int[] Function GetInteractionTypes(Actor akPosition, Actor akPartner)
EndFunction

; If akPosition interacts with akPartner under a given type
; If akPartner is none, checks against any available partner
; If akPosition is none, iterates over all possible positions
; If both are none, returns if the given type is present among any positions
bool Function HasInteractionType(int aiType, Actor akPosition, Actor akPartner)
EndFunction

; Return the first actor that interacts with akPosition by the given type
; (Returned value will be a subset of all positions in the scene)
Actor Function GetPartnerByType(Actor akPosition, int aiType)
EndFUnction
Actor[] Function GetPartnersByType(Actor akPosition, int aiType)
EndFUnction

; Return the velocity of the specified interaction type
; Velocity may be positive or negative, depending on the direction of movement
float Function GetVelocity(Actor akPosition, Actor akPartner, int aiType)
EndFunction

; ------------------------------------------------------- ;
; --- Time Data			                                  --- ;
; ------------------------------------------------------- ;
;/
	Time related data
/;

; The timestamp at which the thread has started
; Time is returned as real time seconds since the save has been created
float Function GetTime()
EndFunction
; Returns the threads current total runtime
float Function GetTimeTotal()
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

; Retrive the sex of this position as used by the thread
int Function GetNthPositionSex(int n)
EndFunction
int[] Function GetPositionSexes()
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

; Return the current enjoyment/arousal level for this actor
int Function GetEnjoyment(Actor akActor)
EndFunction

; If the given actor has a chance of impregnation at some point during this scene. That is, the function will check
; if at any point during this scene this actor had vaginal contact with an orgasming male actor, either direct or indirect
; This function only considers stages that have already been played
; --- Arguments
; abAllowFutaImpregnation	- if akActor is a futa, can they still be impregnated?
; abFutaCanPregnate				- if the orgasming actor is a futa, can they impregnate?
; abCreatureCanPregnate		- if the orgasming actor is a creature, can they impregnate?
; --- Return
; All actors that had vaginal intercourse with the given actor
Actor[] Function CanBeImpregnated(Actor akActor, bool abAllowFutaImpregnation, bool abFutaCanPregnate, bool abCreatureCanPregnate)
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
