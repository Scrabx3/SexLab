scriptname SexLabFramework extends Quest

; TODO: MERGE MATCHMAKER INTO THE FRAMEWORK AS AN OPTION TO TOGGLE ON/OFF IN THE MCM.

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
;                                                                                                                                           ;
;     ███████╗███████╗██╗  ██╗██╗      █████╗ ██████╗     ███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗    ;
;     ██╔════╝██╔════╝╚██╗██╔╝██║     ██╔══██╗██╔══██╗    ██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝    ;
;     ███████╗█████╗   ╚███╔╝ ██║     ███████║██████╔╝    █████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝     ;
;     ╚════██║██╔══╝   ██╔██╗ ██║     ██╔══██║██╔══██╗    ██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗     ;
;     ███████║███████╗██╔╝ ██╗███████╗██║  ██║██████╔╝    ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗    ;
;     ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ;
;                                                                                                                                           ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
;                                  Created by Ashal@LoversLab.com [http://www.loverslab.com/user/1-ashal/]                                  ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
;                                    SexLabP+ maintained by Scrab [https://www.patreon.com/ScrabJoseline]                                   ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

; Integer ID of the current SexLab version
int function GetVersion()
  return SexLabUtil.GetVersion()
endFunction

; A user friendly string representing the current SexLab version
string function GetStringVer()
  return SexLabUtil.GetStringVer()
endFunction

; Is SexLab is currently enabled and able to start a new scene?
bool property Enabled hidden
  bool function get()
    return GetState() != "Disabled"
  endFunction
endProperty

; Is there any SexLab thread currently active and animating?
bool property IsRunning hidden
  bool function get()
    return ThreadSlots.IsRunning()
  endFunction
endProperty

; The number of active/running scenes
int property ActiveAnimations hidden
  int function get()
    return ThreadSlots.ActiveThreads()
  endFunction
endProperty

; If creatures are currently enabled
bool property AllowCreatures hidden
  bool function get()
    return Config.AllowCreatures
  endFunction
endProperty

; If creatures genders are currently enabled
bool property CreatureGenders hidden
  bool function get()
    return Config.UseCreatureGender
  endFunction
endProperty

;#------------------------------------------------------------------------------------------------------------------------------------------#;
;#                                                                                                                                          #;
;#                                                            MAIN API FUNCTIONS                                                            #;
;#                                                                                                                                          #;
;#------------------------------------------------------------------------------------------------------------------------------------------#;

; The preferred way to create a SexLab Scene
; --- Params:
; akPositions:    The actors to animate
; asTags:         Requested animation tags (may be empty). Supported prefixes: '-' to disable a tag, '~' for OR-conjunctions
;                 Example: "~A, B, ~C, -D" <=> Animation has tag B, does NOT have tag D and has EITHER tag A or C 
; akSubmissive:   Must be one of the participating actors. If specified, the given actor is considered submissive for the context of the animation
; akCenter:       If specified, SexLab will try to place all actors near or on the given reference
; aiFurniture:    Furniture preference. Must be one of the following: 0 - Disable; 1 - Allow; 2 - Prefer
; asHook:         A callback string to receive callback events. See 'Hooks' section below for details
; --- Return:
; SexLabThread:   An API instance to interact with the started scene. See sslThreadController.psc for more info
; None:           If an error occured
SexLabThread Function StartScene(Actor[] akPositions, String asTags, Actor akSubmissive = none, ObjectReference akCenter = none, int aiFurniture = 1, String asHook = "")
  String[] scenes = SexLabRegistry.LookupScenes(akPositions, asTags, akSubmissive, aiFurniture, akCenter)
  If (!scenes.Length)
    Log("StartScene() - Failed to find valid animations")
    return none
  EndIf
  return StartSceneEx(akPositions, scenes, akSubmissive, akCenter, aiFurniture, asHook)
EndFunction

; Start a scene with pre-defined animations
SexLabThread Function StartSceneEx(Actor[] akPositions, String[] asAnims, Actor akSubmissive = none, ObjectReference akCenter = none, int aiFurniture = 1, String asHook = "")
  sslThreadModel thread = NewThread()
  If (!thread)
    Log("StartScene() - Failed to claim an available thread")
    return none
  ElseIf (!thread.AddActors(akPositions, akSubmissive))
    Log("StartScene() - Failed to add some actors to thread")
    return none
  EndIf
  thread.SetScenes(asAnims)
  thread.CenterOnObject(akCenter)
  thread.SetFurnitureStatus(aiFurniture)
  thread.SetHook(asHook)
  return thread.StartThread()
EndFunction

; Wrapper function for StartScene which takes Actors one-by-one instead of an array
SexLabThread Function StartSceneQuick(Actor akActor1, Actor akActor2 = none, Actor akActor3 = none, Actor akActor4 = none, Actor akActor5 = none, \
                                        Actor akSubmissive = none, String asTags = "", String asHook = "")
  Actor[] Positions = SexLabUtil.MakeActorArray(akActor1, akActor2, akActor3, akActor4, akActor5)
  return StartScene(Positions, asTags, akSubmissive, asHook = asHook)
EndFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                            THREAD FUNCTIONS                                                             #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

; Get the thread API associated with the given thread id
SexLabThread Function GetThread(int aiThreadID)
  return ThreadSlots.GetThread(aiThreadID)
EndFunction

; Get the thread API representing the thread that most recently animated this actor
SexLabThread Function GetThreadByActor(Actor akActor)
  return ThreadSlots.GetThreadByActor(akActor)
EndFunction

;#------------------------------------------------------------------------------------------------------------------------------------------#;
;#                                                                                                                                          #;
;#                                                              HOOK FUNCTIONS                                                              #;
;#                                                                                                                                          #;
;#------------------------------------------------------------------------------------------------------------------------------------------#;
;#------------------------------------------------------------------------------------------------------------------------------------------#;
;#                                                                                                                                          #;
;#  ABOUT HOOKS IN SEXLAB                                                                                                                   #;
;# Hooks are used to react and interact with running threads in SexLab utilizing events invoked while the thread executes                   #;
;#                                                                                                                                          #;
;# SexLab differentiates two types of Hooks: Blocking and non-blocking                                                                      #;
;# Non-Blocking Hooks are the more common implementation, these are to asynchronously react to the flow of an animation, for example        #;
;#   to advance your story once the animation is over, or to react to other peoples animations starting                                     #;
;# Blocking hooks on the other hand are synchronized and will *halt* a threads execution until the Hook returns. As such, they are          #;
;#   more invasive to the players gameplay experience and should thus be used sparringly                                                    #;
;#                                                                                                                                          #;
;#                                                                                                                                          #;   
;#  HOW TO USE HOOKS                                                                                                                        #;
;# 1. Non-Blocking Hooks                                                                                                                    #;
;# Non-Blocking hooks use mod events to do their work. This is how they are async and why they are very easy to maintain                    #;
;#   There are a variety of different hooks you can use here, and all follow the same schema:                                               #;
;# - First, you want to register for a mod event, like so:                                                                                  #;
;#        RegisterForModEvent("Hook<ModEventType>", "<EventName>")                                                                          #;
;#   Change "ModEventType" to one of the types listed below (e.g. AnimationStart) and the event name to anything you want (e.g. MyEvent)    #;
;# - Next, elsewhere in your script you want to add a new event function, using the following signature:                                    #;
;#        Event <EventName>(int aiThreadID, bool abHasPlayer)                                                                               #;
;#        EndEvent                                                                                                                          #;
;#   Change <EventName> to the same name that you used above, in our example it would be "Event MyEvent(int aiThreadID, bool abHasPlayer)"  #;
;#   And thats all! Now every time an animation starts you will receive the event you have registered for                                   #;
;#                                                                                                                                          #;
;# 1.1 Local Hooks                                                                                                                          #;
;# Sometimes you do not want to react to *every* event that is being send, but only to some events for scenes you started yourself          #;
;#   This is where the "asHook" parameter comes into play that you can set when requested a scene through this API. This parameter is used  #;
;#   to create specialized thread-local hooks that are only send from thread which know about this hook                                     #;
;# These Local Hooks function basically the same as the global ones, the ID of Event that is being send undergoes a slight change however:  #;
;#   We already discussed how the ID for a global hook is `Hook<ModEventType>`, for our local hook we use a similar approach but append     #;
;#   a special suffix to the ID to signify that we only care about a specific hook: `_<MyLocalHookID>`. For example, if we want to hook     #;
;#   "AnimationStart" with a Local Hook named "MyLocalHook", our signature will be `HookAnimationStart_MyLocalHook` and to let the started  #;
;#   thread know about the hook id, we pass "MyLocalHook" into the "asHook" parameter!                                                      #;
;#                                                                                                                                          #;
;# 1.2 Types of Events                                                                                                                      #;
;#  AnimationStart    - Send when the animation starts                                                                                      #;
;#  AnimationEnd      - Send when the animation is fully terminated                                                                         #;
;#  LeadInStart       - Send when the animation starts and has a LeadIn                                                                     #;
;#  LeadInEnd         - Send when a LeadIn animation ends                                                                                   #;
;#  StageStart        - Send for every Animation Stage that starts                                                                          #;
;#  StageEnd          - Send for every Animation Stage that is completed                                                                    #;
;#  OrgasmStart       - Send when an actor reaches the final stage                                                                          #;
;#  OrgasmEnd         - Send when the final stage is completed                                                                              #;
;#  AnimationChange   - Send if the Animation that was playing is changed by the HotKey                                                     #;
;#  PositionChange    - Send if the Positions of the animation (the involved actors) are changed                                            #;
;#  ActorsRelocated   - Send if the actors gets a new alignment                                                                             #;
;#  ActorChangeStart  - Send when the function ChangeActors is called                                                                       #;
;#  ActorChangeEnd    - Send when the replacement of actors, by the function ChangeActors is completed                                      #;
;#                                                                                                                                          #;
;#                                                                                                                                          #;
;# 2. Blocking Hooks                                                                                                                        #;
;# Another, more complex type of Hook are Blocking Hooks. These should generally be avoided as they halt the threads execution but there    #;
;#   are situations were time is of essence and asynchronous hooks simply don't cut it.                                                     #;
;# To implement a blocking hook, you first want to create a new reference alias and attach a script to it. The script can have any name     #;
;#   you want, important is that it extends "SexLabThreadHook" instead of "ReferenceAlias" and fill in the properties. This is all you      #;
;#   need to do to implement a blocking hook. To read on how to actually use these Hooks, see "SexLabThreadHook.psc"                        #;
;#                                                                                                                                          #;
;#                                                                                                                                          #;
;# 3. Misc Events                                                                                                                           #;
;# There are other events that are sent by SexLab, but they are NOT related to Hooks:                                                       #;
;#    -   EVENT NAME    - | -                 CAUSE                  - | -                          ARGUMENTS                          -    #;
;#   SexLabDisabled       | When SexLab is Disabled                    | ()                                                                 #;
;#   SexLabEnabled        | When SexLab is Enabled                     | ()                                                                 #;
;#   SexLabOrgasm         | When an actor has an orgasm                | (Actor akClimaxingActor, itn aiEnjoyment, itn aiSceneOrgasmCount)  #;
;#   SexLabLoadStrapons   | Strapons are allowed to be registered      | ()                                                                 #;
;#   SexLabStoppedActive  | All threads are forcefully stopped         | ()                                                                 #;
;#                                                                                                                                          #;
;#------------------------------------------------------------------------------------------------------------------------------------------#;

; Register a new blocking hook to receive events from running threads
; Return if the hook has been successfully installed
bool Function RegisterHook(SexLabThreadHook akHook)
  return Config.AddHook(akHook)
EndFunction

; Unregister a hook to no longer receive events
; Return if the hook was unregistered successfully
bool Function UnregisterHook(SexLabThreadHook akHook)
  return Config.RemoveHook(akHook)
EndFunction

; Check if the given hook is currently registered
bool Function IsHooked(SexLabThreadHook akHook)
  return Config.IsHooked(akHook)
EndFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                             ACTOR FUNCTIONS                                                             #
;#                  These functions are used to handle and get info on the actors that will participate in the animations.                 #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

; Return this actors sex
; Mapping: Male = 0 | Female = 1 | Futa = 2 | CrtMale = 3 | CrtFemale = 4
int Function GetSex(Actor akActor)
  return SexlabRegistry.GetSex(akActor, false)
EndFunction
int[] Function GetSexAll(Actor[] akPositions)
  return sslActorLibrary.GetSexAll(akPositions)
EndFunction

; Force an actor to be considered male, female or futa by SexLab
; --- Param:
; akActor:    The actor which's sex to overwrite/force
; aiSexTag:   The actors new sex; 0 - Male, 1 - Female, 2 - Futa
Function TreatAsSex(Actor akActor, int aiSexTag)
  ActorLib.TreatAsSex(akActor, aiSexTag)
EndFunction
Function TreatAsMale(Actor ActorRef)
  TreatAsSex(ActorRef, 0)
EndFunction
Function TreatAsFemale(Actor ActorRef)
  TreatAsSex(ActorRef, 1)
EndFunction
Function TreatAsFuta(Actor ActorRef)
  TreatAsSex(ActorRef, 2)
EndFunction

; Clear a forced sex assignment previously established with "TreatAsSex"
Function ClearForcedSex(Actor akActor)
  ActorLib.ClearForcedSex(akActor)
EndFunction

; Given an array of actors, create an array of length 5 representing the number of individual sexes contained in that array,
; The returned array lists the number of males/females/... inside the array at their respective index; s.t.
;   [0] represents the number of human males
;   [1] represents the number of human females
;   [2] represents the number of human futas
;   [3] represents the number of creature males
;   [4] represents the number of creature females
int[] Function CountSexAll(Actor[] akPositions)
  return ActorLib.CountSexAll(akPositions)
EndFunction
int Function CountMale(Actor[] akPositions)
	return ActorLib.CountMale(akPositions)
EndFunction
int Function CountFemale(Actor[] akPositions)
	return ActorLib.CountFemale(akPositions)
EndFunction
int Function CountFuta(Actor[] akPositions)
	return ActorLib.CountFuta(akPositions)
EndFunction
int Function CountCreatures(Actor[] akPositions)
	return ActorLib.CountCreatures(akPositions)
EndFunction
int Function CountCrtMale(Actor[] akPositions)
	return ActorLib.CountCrtMale(akPositions)
EndFunction
int Function CountCrtFemale(Actor[] akPositions)
	return ActorLib.CountCrtFemale(akPositions)
EndFunction

;/* ValidateActor
* * Checks if the given actor is a valid target for SexLab animations.
* * 
* * @param: ActorRef, the actor to check if it is valid for SexLab Animations.
* * @return: an int that is 1 if the actor is valid or a negative value if it is not valid
* *    -1 = The Actor does not exists (it is None)
* *    -2 = The Actor is from a disabled race
* *   -10 = The Actor is already part of a SexLab animation
* *   -11 = The Actor is forbidden form SexLab animations
* *   -12 = The Actor does not have the 3D loaded
* *   -13 = The Actor is dead (He's dead Jim.)
* *   -14 = The Actor is disabled
* *   -15 = The Actor is flying (so it cannot be SexLab animated)
* *   -16 = The Actor is on mount (so it cannot be SexLab animated)
* *   -17 = The Actor is a creature but creature animations are disabled
* *   -18 = The Actor is a creature that is not supported by SexLab
*/;
int function ValidateActor(Actor ActorRef)
  return ActorLib.ValidateActor(ActorRef)
endFunction

;/* IsValidActor
* * Checks if given actor is a valid target for SexLab animation.
* * 
* * @param: ActorRef, the actor to check if it is valid for SexLab Animations.
* * @return: True if the actor is valid, and False if it is not.
*/;
bool function IsValidActor(Actor ActorRef)
  return ActorLib.IsValidActor(ActorRef)
endFunction

;/* IsActorActive
* * Checks if the given actor is active in any SexLab animation
* * 
* * @param: ActorRef, the actor to check for activity in a SexLab Animation.
* * @return: True if the actor is being animated by SexLab, and False if it is not.
*/;
bool function IsActorActive(Actor ActorRef)
  return ActorRef.IsInFaction(AnimatingFaction)
endFunction

;/* ForbidActor
* * Makes an actor to be never allowed to engage in SexLab Animations.
* * @param: ActorRef, the actor to forbid from SexLab use.
*/;
function ForbidActor(Actor ActorRef)
  ActorLib.ForbidActor(ActorRef)
endFunction

;/* AllowActor
* * Removes an actor from the forbidden list, undoing the effects of ForbidActor()
* * 
* * @param: ActorRef, the actor to remove from the forbid list.
*/;
function AllowActor(Actor ActorRef)
  ActorLib.AllowActor(ActorRef)
endFunction

;/* IsForbidden
* * Checks if an actor is currently forbidden from use in SexLab scenes.
* * 
* * @param: ActorRef, the actor to check.
* * @return: True if the actor is forbidden from use.
*/;
bool function IsForbidden(Actor ActorRef)
  return ActorLib.IsForbidden(ActorRef)
endFunction

;/* FindAvailableActor
* * Searches within a given area for a SexLab valid actor
* * 
* * @param: ObjectReference CenterRef - The object to use as the center point in the search. 
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @param: int FindGender [OPTIONAL] - The desired gender id to look for, -1 for any, 0 for male, 1 for female.
* * @param: Actor IgnoreRef1/2/3/4 [OPTIONAL] - An actor you know for certain you do not want returned by this function.
* * @return: Actor - A valid actor found, if any. None if no valid actor found.
*/;
Actor function FindAvailableActor(ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none)
  return ThreadLib.FindAvailableActor(CenterRef, Radius, FindGender, IgnoreRef1, IgnoreRef2, IgnoreRef3, IgnoreRef4)
endFunction

;/* FindAvailableActorByFaction
* * Searches within a given area for a SexLab valid actor with or without the specified faction
* * 
* * @param: Faction FactionRef - The faction that will be checked on the actor search. 
* * @param: ObjectReference CenterRef - The object to use as the center point in the search. 
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @param: int FindGender [OPTIONAL] - The desired gender id to look for, -1 for any, 0 for male, 1 for female.
* * @param: Actor IgnoreRef1/2/3/4 [OPTIONAL] - An actor you know for certain you do not want returned by this function.
* * @param: bool HasFaction [OPTIONAL true by default] - If False the returned actor won't be part of the given faction, if True the returned actor most be part of the given faction.
* * @return: Actor - A valid actor found, if any. None if no valid actor found.
*/;
Actor function FindAvailableActorByFaction(Faction FactionRef, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool HasFaction = True)
  return ThreadLib.FindAvailableActorInFaction(FactionRef, CenterRef, Radius, FindGender, IgnoreRef1, IgnoreRef2, IgnoreRef3, IgnoreRef4, HasFaction)
endFunction

;/* FindAvailableActorWornForm
* * Searches within a given area for a SexLab valid actor with or without the specified faction
* * 
* * @param: int slotMask - The slotMask that will be checked on the actor search. 
* * @param: ObjectReference CenterRef - The object to use as the center point in the search. 
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @param: int FindGender [OPTIONAL] - The desired gender id to look for, -1 for any, 0 for male, 1 for female.
* * @param: Actor IgnoreRef1/2/3/4 [OPTIONAL] - An actor you know for certain you do not want returned by this function.
* * @param: bool AvoidNoStripKeyword [OPTIONAL true by default] - If False the search won't check the equipped slotMask is treated as "NoStrip" (naked), if True the equipped slotMask treated as "NoStrip" (naked) will be considered unequipped.
* * @param: bool HasFaction [OPTIONAL true by default] - If False the returned actor won't have the given slotMask unequipped or empty, if True the returned actor most have the given slotMask equipped.
* * @return: Actor - A valid actor found, if any. None if no valid actor found.
*/;
Actor function FindAvailableActorWornForm(int slotMask, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool AvoidNoStripKeyword = True, bool HasWornForm = True)
  return ThreadLib.FindAvailableActorWornForm(slotMask, CenterRef, Radius, FindGender, IgnoreRef1, IgnoreRef2, IgnoreRef3, IgnoreRef4, AvoidNoStripKeyword, HasWornForm)
endFunction

;/* FindAvailableCreature
* * Searches within a given area for a SexLab valid creature
* * 
* * @param: string RaceKey - The SexLab RaceKey to find a creature whose race belongs to
* * @param: ObjectReference CenterRef - The object to use as the center point in the search. 
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @param: int FindGender [OPTIONAL] - The desired gender id to look for, 2 for male/no gender, 3 for female.
* * @param: Actor IgnoreRef1/2/3/4 [OPTIONAL] - A creature you know for certain you do not want returned by this function.
* * @return: Actor - A valid creature found, if any. Returns none if no valid creature found.
**/;
Actor function FindAvailableCreature(string RaceKey, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = 2, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none)
  return ThreadLib.FindAvailableActor(CenterRef, Radius, FindGender, IgnoreRef1, IgnoreRef2, IgnoreRef3, IgnoreRef4, RaceKey)
endFunction

;/* FindAvailableCreatureByFaction
* * Searches within a given area for a SexLab valid creature with or without the specified faction
* * 
* * @param: string RaceKey - The SexLab RaceKey to find a creature whose race belongs to
* * @param: Faction FactionRef - The faction that most have or don't have the creature searched. 
* * @param: ObjectReference CenterRef - The object to use as the center point in the search. 
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @param: int FindGender [OPTIONAL] - The desired gender id to look for, -1 for any, 0 for male, 1 for female.
* * @param: Actor IgnoreRef1/2/3/4 [OPTIONAL] - A creature you know for certain you do not want returned by this function.
* * @param: bool HasFaction [OPTIONAL true by default] - If False the returned creature won't be part of the given faction, if True the returned creature most be part of the given faction.
* * @return: Actor - A valid creature found, if any. None if no valid creature found.
*/;
Actor function FindAvailableCreatureByFaction(string RaceKey, Faction FactionRef, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool HasFaction = True)
  return ThreadLib.FindAvailableActorInFaction(FactionRef, CenterRef, Radius, FindGender, IgnoreRef1, IgnoreRef2, IgnoreRef3, IgnoreRef4, HasFaction, RaceKey)
endFunction

;/* FindAvailableCreatureWornForm
* * Searches within a given area for a SexLab valid creature with or without the specified faction
* * 
* * @param: string RaceKey - The SexLab RaceKey to find a creature whose race belongs to
* * @param: int slotMask - The slotMask that will be checked on the creature search. 
* * @param: ObjectReference CenterRef - The object to use as the center point in the search. 
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @param: int FindGender [OPTIONAL] - The desired gender id to look for, -1 for any, 0 for male, 1 for female.
* * @param: Actor IgnoreRef1/2/3/4 [OPTIONAL] - A creature you know for certain you do not want returned by this function.
* * @param: bool AvoidNoStripKeyword [OPTIONAL true by default] - If False the search won't check the equipped slotMask is treated as "NoStrip" (naked), if True the equipped slotMask treated as "NoStrip" (naked) will be considered unequipped.
* * @param: bool HasFaction [OPTIONAL true by default] - If False the returned creature won't have the given slotMask unequipped or empty, if True the returned creature most have the given slotMask equipped.
* * @return: Actor - A valid creature found, if any. None if no valid creature found.
*/;
Actor function FindAvailableCreatureWornForm(string RaceKey, int slotMask, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool AvoidNoStripKeyword = True, bool HasWornForm = True)
  return ThreadLib.FindAvailableActorWornForm(slotMask, CenterRef, Radius, FindGender, IgnoreRef1, IgnoreRef2, IgnoreRef3, IgnoreRef4, AvoidNoStripKeyword, HasWornForm, RaceKey)
endFunction

;/* FindAvailablePartners
* * Searches within a given area for multiple SexLab valid actors
* * 
* * @param: Actor[] Positions - A list of actors, where at least one is specified (the other items can be set to None)
* * @param: int TotalActors - The desired total number of actors you want in the return array.
* * @param: int Males [OPTIONAL] - From the TotalActors amount, you want at least this many males.
* * @param: int Females [OPTIONAL] - From the TotalActors amount, you want at least this many females.
* * @param: float Radius [OPTIONAL] - The distance from the center point to search.
* * @return: Actor[] - A list of valid actors, the length of the list is the same as the Positions parameter, then number of valid actors can be less than this value.
*/;
Actor[] function FindAvailablePartners(Actor[] Positions, int TotalActors, int Males = -1, int Females = -1, float Radius = 10000.0)
  return ThreadLib.FindAvailablePartners(Positions, TotalActors, Males, Females, Radius)
endFunction

; Sort a list of actors strictly by gender, putting humans (male or female) first, and creatures last
; Note that order in SexLab Scenes will **not** follow the same ordering
; --- Return:
; The array is modified directly and then returned again { assert(return == Positions) }
Actor[] function SortActors(Actor[] Positions, bool FemaleFirst = true)
  return ThreadLib.SortActors(Positions, FemaleFirst)
endFunction

; Sort a list of actors based on the passed scene. The order of the resulting array is unspecified
; --- Parameters:
; asSceneID:      The id of the scene to sort by
; akPositions:    The actors that should be sorted
; akSubmissives:  (Optional) A list of actors which are interpreted submissives during the ordering If the passed in actors are less/more than 
;                   the expected amount of victims, the first listed actors of the array will be implied as submissives instead
; --- Return:
; A new array with the sorted positions, or an empty array if the animation is incompatible with the passed in actors
Actor[] function SortActorsByScene(String asSceneID, Actor[] akPositions, Actor[] akSubmissives)
  return ThreadLib.SortActorsByAnimationImpl(asSceneID, akPositions, akSubmissives)
endFunction

;/* AddCum
* * Applies the cum effect to an actor for the given locations
* * 
* * @param: Actor ActorRef - The actor to apply the cum EffectShader to
* * @param: bool Vaginal [OPTIONAL] - if set to TRUE, then the cum will be applied (or staked if it was already there) to the Vagina.
* * @param: bool Oral [OPTIONAL] - if set to TRUE, then the cum will be applied (or staked if it was already there) to the Mouth.
* * @param: bool Anal [OPTIONAL] - if set to TRUE, then the cum will be applied (or staked if it was already there) to the Anus.
*/;
function AddCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
  ActorLib.AddCum(ActorRef, Vaginal, Oral, Anal)
endFunction

;/* ClearCum
* * Removes existing cum EffectShaders.
* * 
* * @param: Actor ActorRef - The actor you want to remove any trace of cum from the skin, it will actually remove the EffectShaders from the actor.
*/;
function ClearCum(Actor ActorRef)
  ActorLib.ClearCum(ActorRef)
endFunction

;/* CountCum
* * Checks how many stacks of cum an actor currently has in the given areas
* * 
* * @param: Actor ActorRef - The actor to check for cum EffectShader stacks
* * @param: bool Vaginal/Oral/Anal - Each location set to TRUE contributes to the returned count of cum stacks.
* * @return: an int with the number of stacked layers
*/;
int function CountCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
  return ActorLib.CountCum(ActorRef, Vaginal, Oral, Anal)
endFunction
int function CountCumVaginal(Actor ActorRef)
  return ActorLib.CountCum(ActorRef, true, false, false)
endFunction
int function CountCumOral(Actor ActorRef)
  return ActorLib.CountCum(ActorRef, false, true, false)
endFunction
int function CountCumAnal(Actor ActorRef)
  return ActorLib.CountCum(ActorRef, false, false, true)
endFunction

;/* StripActor
* * Strips an actor using SexLab's strip settings as chosen by the user from the SexLab MCM
* * 
* * @param: Actor ActorRef - The actor whose equipment shall be unequipped.
* * @param: Actor VictimRef [OPTIONAL] - If ActorRef matches VictimRef victim strip settings are used. If VictimRef is set but doesn't match, aggressor settings are used.
* * @param: bool DoAnimate [OPTIONAL true by default] - Whether or not to play the actor stripping animations during the strip
* * @param: bool LeadIn [OPTIONAL false by default] - If TRUE and VictimRef == none, Foreplay strip settings will be used.
* * @return: Form[] - An array of all equipment stripped from ActorRef
*/;
Form[] function StripActor(Actor ActorRef, Actor VictimRef = none, bool DoAnimate = true, bool LeadIn = false)
  return ActorLib.StripActor(ActorRef, VictimRef, DoAnimate, LeadIn)
endFunction

;/* StripSlots
* * Strips an actor of equipment using a custom selection of biped objects / slot masks.
* * See for the slot values: http://www.creationkit.com/Biped_Object
* * 
* * @param: Actor ActorRef - The actor whose equipment shall be unequipped.
* * @param: bool[] Strip - MUST be a bool array with a length of exactly 33 items. Any index set to TRUE will be stripped using nth + 30 = biped object / slot mask. The extra index Strip[32] is used to strip weapons
* * @param: bool DoAnimate - Whether or not to play the actor stripping animation during
* * @param: bool AllowNudesuit - Whether to allow the use of nudesuits, if the user has that option enabled in the MCM (the poor fool)
* * @return: Form[] - An array of all equipment stripped from ActorRef
*/;
Form[] function StripSlots(Actor ActorRef, bool[] Strip, bool DoAnimate = false, bool AllowNudesuit = true)
  return ActorLib.StripSlots(ActorRef, Strip, DoAnimate, AllowNudesuit)
endFunction

;/* UnstripActor
* * Equips an actor with the given equipment. Intended for reversing the results of the Strip functions using their return results.
* * 
* * @param: Actor ActorRef - The actor whose equipment shall be re-equipped.
* * @param: Form[] Stripped - A form array of all the equipment to be equipped on ActorRef. Typically the saved result of StripActor() or StripSlots()
* * @param: bool IsVictim - If TRUE and the user has the SexLab MCM option for Victims Redress disabled, the actor will not actually re-equip their gear.
*/;
function UnstripActor(Actor ActorRef, Form[] Stripped, bool IsVictim = false)
  ActorLib.UnstripActor(ActorRef, Stripped, IsVictim)
endFunction

;/* IsStrippable
* * Checks if a given item can be unequipped from actors by the SexLab strip functions.
* * 
* * @param: Form ItemRef - The item you want to check.
* * @return: bool - TRUE if the item does not have the keyword with the word "NoStrip" in it, or is flagged as "Always Strip" in the SexLab MCM Strip Editor.
*/;
bool function IsStrippable(Form ItemRef)
  return ActorLib.IsStrippable(ItemRef)
endFunction

;/* StripSlot
* * Removes and unequip an item from an actor that is in the position defined by the given slot mask.
* * The item is unequipped only if it is considered strippable by SexLab.
* * 
* * @param: Actor ActorRef - The actor to unequip the slot from
* * @param: int SlotMask - The slot mask id for your chosen biped object. See more: http://www.creationkit.com/Slot_Masks_-_Armor
* * @return: Form - The item equipped on the SlotMask if removed. None if it was not removed or nothing was there.
*/;
Form function StripSlot(Actor ActorRef, int SlotMask)
  return ActorLib.StripSlot(ActorRef, SlotMask)
endFunction

;/* WornStrapon
* * Checks and returns for any strapon that equipped by the actor and is considered as a registered strapon by SexLab. (Check LoadStrapon() to find how to add new strapons to SexLab)
* * 
* * @param: Actor ActorRef - The actor to look for a strapon on.
* * @return: Form - The SexLab registered strapon actor is currently wearing, if any.
*/;
Form function WornStrapon(Actor ActorRef)
  return Config.WornStrapon(ActorRef)
endFunction

;/* HasStrapon
* * Checks if the actor is wearing, or has in its inventory, any of the registered SexLab strapons.
* * 
* * @param: Actor ActorRef - The actor to look for a strapon on.
* * @return: bool - TRUE if the actor has a SexLab registered strapon equipped or in their inventory.
*/;
bool function HasStrapon(Actor ActorRef)
  return Config.HasStrapon(ActorRef)
endFunction

;/* PickStrapon
* * Picks a strapon from the SexLab registered strapons for the actor to use.
* * 
* * @param: Actor ActorRef - The actor to look for a strapon to use.
* * @return: Form - A randomly selected strapon or the strapon the actor already has in inventory, if any.
*/;
Form function PickStrapon(Actor ActorRef)
  return Config.PickStrapon(ActorRef)
endFunction

; Add an armor object to the list of available strapons
; --- Parameters:
; esp:    The .esp/.esm file containing the object to search for
; id:     The objects form id
; --- Return:
; Armor:  The object that has been added to the list
; None:   If there is no form with the given esp under the given form id
Armor function LoadStrapon(string esp, int id)
  return Config.LoadStrapon(esp, id)
EndFunction
Function LoadStraponEx(Armor akStrapon)
  Config.LoadStraponEx(akStrapon)
EndFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  ^^^                                                   END ACTOR FUNCTIONS                                                       ^^^  #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#


;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                       BEGIN BED FUNCTIONS                                                            #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/* FindBed
* * Searches for a bed within a given radius from a provided center, and returns its ObjectReference.
* * 
* * @param: ObjectReference CenterRef - An object/actor/marker to use as the center point of your search.
* * @param: float Radius - The radius distance to search within the given CenterRef for a bed. 
* * @param: bool IgnoreUsed - When searching for beds, attempt to check if any actor is currently using the bed, in this case the bed will be ignored. 
* * @param: ObjectReference IgnoreRef1/IgnoreRef2 - A bed object that might be within the search radius, but you know you don't want.
* * @return: ObjectReference - The found valid bed within the radius. NONE if no bed found. 
*/;
ObjectReference function FindBed(ObjectReference CenterRef, float Radius = 1000.0, bool IgnoreUsed = true, ObjectReference IgnoreRef1 = none, ObjectReference IgnoreRef2 = none)
  return ThreadLib.FindBed(CenterRef, Radius, IgnoreUsed, IgnoreRef1, IgnoreRef2)
endFunction

;/* IsBedRoll
* * Checks if a given bed is considered a bed roll.
* * 
* * @param: ObjectReference BedRef - The bed object you want to check.
* * @return: bool - TRUE if BedRef is considered a bed roll.
*/;
bool function IsBedRoll(ObjectReference BedRef)
  return ThreadLib.IsBedRoll(BedRef)
endFunction

;/* IsDoubleBed
* * Checks if a given bed is considered a 2 person bed.
* * 
* * @param: ObjectReference BedRef - The bed object you want to check.
* * @return: bool - TRUE if BedRef is considered a 2 person bed.
*/;
bool function IsDoubleBed(ObjectReference BedRef)
  return ThreadLib.IsDoubleBed(BedRef)
endFunction

;/* IsSingleBed
* * Checks if a given bed is considered a single bed.
* * 
* * @param: ObjectReference BedRef - The bed object you want to check.
* * @return: bool - TRUE if BedRef is considered a single bed.
*/;
bool function IsSingleBed(ObjectReference BedRef)
  return ThreadLib.IsSingleBed(BedRef)
endFunction

;/* IsBedAvailable
* * Checks if a given bed is appears to be in use by another actor.
* * 
* * @param: ObjectReference BedRef - The bed object you want to check.
* * @return: bool - TRUE if BedRef is not being used, FALSE if a NPC is sleeping on it or is used by another SexLab thread.
*/;
bool function IsBedAvailable(ObjectReference BedRef)
  return ThreadLib.IsBedAvailable(BedRef)
endFunction

;/* AddCustomBed
* * Adds a new bed to the list of beds SexLab will search for when starting an animation.
* * 
* * @param: Form BaseBed - The base object of the bed you wish to add.
* * @param: int BedType - Defines what kind of bed it is. 0 = normal bed, 1 = bedroll, 2 = double bed.
* * @return: bool - TRUE if bed was successfully added to the bed list. 
*/;
bool function AddCustomBed(Form BaseBed, int BedType = 0)
  return Config.AddCustomBed(BaseBed, BedType)
endFunction

;/* SetCustomBedOffset
* * Override the default bed offsets used by SexLab [30, 0, 37, 0] for a given base bed object during animation.
* * 
* * @param: Form BaseBed - The base object of the bed you wish to add custom offsets.
* * @param: float Forward - The amount the actor(s) should be pushed forward on the bed when playing an animation.
* * @param: float Sideward - The amount the actor(s) should be pushed sideward on the bed when playing an animation.
* * @param: float Upward - The amount the actor(s) should be pushed upward on the bed when playing an animation. (NOTE: Ignored for bedrolls)
* * @param: float Rotation - The amount the actor(s) should be rotated on the bed when playing an animation.
* * @return: bool - TRUE if BedRef if the bed succesfully had it's default offsets overriden.
*/;
bool function SetCustomBedOffset(Form BaseBed, float Forward = 30.0, float Sideward = 0.0, float Upward = 37.0, float Rotation = 0.0)
  return Config.SetCustomBedOffset(BaseBed, Forward, Sideward, Upward, Rotation)
endFunction

;/* ClearCustomBedOffset
* * Removes any bed offset overrides set by the SetCustomBedOffset() function. Reverting it's offsets to the SexLab default.
* * 
* * @param: Form BaseBed - The base object of the bed you wish to remove custom offsets from.
* * @return: bool - TRUE if BedRef if the bed succesfully had it's default offsets restored. FALSE if it didn't have any to begin with.
*/;
bool function ClearCustomBedOffset(Form BaseBed)
  return Config.ClearCustomBedOffset(BaseBed)
endFunction

;/* GetBedOffsets
* * Get an array of offsets that would be used by the given bed. 
 the 
* * @param: ObjectReference BedRef - The bed object you want to get offsets for.
* * @return: float[] - The array of offsets organized as [Forward, Sideward, Upward, Rotation]. If no customs defined, the default is returned.
*/;
float[] function GetBedOffsets(Form BaseBed)
  return Config.GetBedOffsets(BaseBed)
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  ^^^                                                       END BED FUNCTIONS                                                       ^^^  #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#


;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                        BEGIN TRACKING FUNCTIONS                                                         #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#


;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  TRACKING USAGE INSTRUCTIONS                                                                                                            #
;#                                                                                                                                         #
;# An actor is tracked either by specifically it being marked for tracking, or because it belongs to a faction that is tracked.            #
;# Tracked actors will receive special mod events.                                                                                         #
;# NOTE: The player has a default tracked event associated with them using the callback "PlayerTrack"                                      #
;#                                                                                                                                         #
;# The default tracked event types are: Added, Start, End, Orgasm.                                                                         #
;# Which correspond with an actor being added to a thread, starting an animation, ending an animation, and having an orgasm.               #
;#                                                                                                                                         #
;# Once you register a callback for an actor or faction, the mod event that is sent will be "<custom callback>_<event type>".              #
;#                                                                                                                                         #
;# Example:                                                                                                                                #
;# If you want to run some code, whenever a specific Actor finishes a SexLab animation, then you can do something like this:               #
;#                                                                                                                                         #
;#  Actor myActor = ...                              <-- you get your actor in any way you want                                            #
;#  SexLab.TrackActor(ActorRef, "MyHook")            <-- here you start to track the actor, and the hook that will be used is MyHook       #
;#  RegisterForModEvent("MyHook_End", "DoSomething")                                                                                        #
;#                                                                                                                                         #
;#  Event DoSomething(Form FormRef, int tid)                                                                                               #
;#    Debug.MessageBox("The Actor " + myActor.getDisplayname() just ended an animation.")                                                  #
;#  EndEvent                                                                                                                               #
;#                                                                                                                                         #
;# In the received event, the first parameter FormRef will be the Actor (you may want to cast it),                                         #
;# and the second parameter tid is the ID of the Tread Controller                                                                          #
;#                                                                                                                                         #
;# For an advanced description of the events management look into the HOOKS section.                                                       #
;#                                                                                                                                         #
;#                                                                                                                                         #
;# NOTE: In the following functions the parameter Callback is NOT a function, is a part of the name of the event that is generated.        #
;#                                                                                                                                         #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/* TrackActor
* * Associates a specific actor with a unique callback mod event that is sent whenever the actor performs certain actions within SexLab animations.
* * You need to RegisterForModEvents for an event with name <Callback>_<Event>, where events can be:
* * "Added" - The actor is added to a SexLab animation
* * "Start" - The SexLab animations where the actor was added is starting
* * "Orgasm" - The actor is having an orgasm
* * "End" - The SexLab animations where the actor was added is ended
* * 
* * @param: Actor ActorRef - The actor you want to receive tracked events for.
* * @param: string Callback - The unique callback name you want to associate with this actor.
*/;
function TrackActor(Actor ActorRef, string Callback)
  ThreadLib.TrackActor(ActorRef, Callback)
endFunction

;/* UntrackActor
* * Removes an associated callback name from an actor.
* * Mod Events of type <Callback>_Start, <Callback>_End, <Callback>_Orgasm, and <Callback>_Added, are no more sent for this actor.
* * Warning, do not remove the player, or some old mods may fail to work.
* * 
* * @param: Actor ActorRef - The actor you want to remove the tracked events for.
* * @param: string Callback - The unique callback event you want to disable.
*/;
function UntrackActor(Actor ActorRef, string Callback)
  ThreadLib.UntrackActor(ActorRef, Callback)
endFunction

;/* 
* * Associates a specific Faction with a unique callback mod event that is sent whenever an actor that is in this faction, performs certain actions within SexLab Animations.
* * You need to RegisterForModEvents for an event with name <Callback>_<Event>, where events can be:
* * "Added" - The actor is added to a SexLab animation
* * "Start" - The SexLab animations where the actor was added is starting
* * "Orgasm" - The actor is having an orgasm
* * "End" - The SexLab animations where the actor was added is ended
* * 
* * @param: Faction FactionRef - The faction whose members you want to receive tracked events for.
* * @param: string Callback - The unique callback name you want to associate with this faction's actors.
*/;
function TrackFaction(Faction FactionRef, string Callback)
  ThreadLib.TrackFaction(FactionRef, Callback)
endFunction

;/* UntrackFaction
* * Removes an associated callback from a faction.
* * 
* * @param: Faction FactionRef - The faction you want to remove the tracked events for.
* * @param: string Callback - The unique callback event you want to disable.
*/;
function UntrackFaction(Faction FactionRef, string Callback)
  ThreadLib.UntrackFaction(FactionRef, Callback)
endFunction

;/* SendTrackedEvent
* * Sends a custom tracked event for an actor that is tracked, if they have any associated callbacks themselves or belong to a tracked factions.
* * The actual event name that is sent is the <callback defined to track the actor>_<hook name>, and you have to RegisterForModEvents with this name to being able to receive them.
* * 
* * @param: Actor ActorRef - The actor you want to send a custom tracked event for.
* * @param: string Hook - The event type you want to send, used in place of the default Added, Start, End, Orgasm hook types as "<Hook>_<Callback>"
* * @param: int id [OPTIONAL] - An id number to send with your custom tracked event. This is normally the associated animation thread id number, but can be anything you want.
* * 
* * EXAMPLE:
* * Actor myActor = ...                                                                     <-- get you actor in some way
* * SexLab.TrackActor(myActor, "MyCallBackName")                                            <-- Track the actor for "MyCallBackName"
* * RegisterForModEvents("MyCallBackName_ThisIsATest", "WeReceivedTheCustomEvent")          <-- Register for events "MyCallBackName_ThisIsATest"
* * 
* * SexLab.SendTrackedEvent(myActor, "ThisIsATest", 123)                                    <-- Send a specific event "ThisIsATest"
* * 
* * 
* * Event WeReceivedTheCustomEvent(Form FormRef, int tid)
* *   Debug.MessageBox("The Actor "+(FormRef as Actor).GetDisplayname()+" just received the event ThisIsATest and the value is " + tid)
* *   ; The message displayed will be "The Actor <xxx> just received the event ThisIsATest and the value is 123"
* * EndEvent   
* * 
*/;
function SendTrackedEvent(Actor ActorRef, string Hook, int id = -1)
  ThreadLib.SendTrackedEvent(ActorRef, Hook, id)
endFunction

;/* IsActorTracked
* * Checks if a given actor will receive any tracked events. Will always return TRUE if used on the player, due to the built in "PlayerTrack" callback.
* * 
* * @param: Actor ActorRef - The actor to check.
* * @return: bool - TRUE if the actor has any associated callbacks, or belongs to any tracked factions.
*/;
bool function IsActorTracked(Actor ActorRef)
  return ThreadLib.IsActorTracked(ActorRef)
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  ^^^                                                     END TRACKING FUNCTIONS                                                    ^^^  #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                          BEGIN VOICE FUNCTIONS                                                          #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/* PickVoice
* * @RETURNS an actors saved voice object if the user has the "reuse voices" option enabled, otherwise random for gender.
* * 
* * @param: Actor ActorRef - The actor to pick a voice for.
* * @return: sslBaseVoice - A suitable voice object for the actor to use.
*/;
sslBaseVoice function PickVoice(Actor ActorRef)
  return VoiceSlots.PickVoice(ActorRef)
endFunction
sslBaseVoice function GetVoice(Actor ActorRef) ; Alias of PickVoice()
  return VoiceSlots.PickVoice(ActorRef)
endFunction

;/* 
* * Saves a given voice to an actor. Once saved the function GetSavedVoice() will always return their saved voice,
* * PickVoice() / GetVoice() will also return this voice for the actor if the user has the "reuse voices" option enabled 
* * 
* * @param: Actor ActorRef - The actor to pick a voice for.
* * @return: sslBaseVoice - A suitable voice object for the actor to use. Does not have to be a registered SexLab voice object.
*/;
function SaveVoice(Actor ActorRef, sslBaseVoice Saving)
  VoiceSlots.SaveVoice(ActorRef, Saving)
endFunction

;/* ForgetVoice
* * Removes any saved voice on an actor.
* * 
* * @param: Actor ActorRef - The actor you want to remove a saved voice from.
*/;
function ForgetVoice(Actor ActorRef)
  VoiceSlots.ForgetVoice(ActorRef)
endFunction

;/* GetSavedVoice
* * @RETURNS an actors saved voice object, if they have one saved.
* * 
* * @param: Actor ActorRef - The actor get the saved voice for.
* * @return: sslBaseVoice - The actors saved voice object if one exists, otherwise NONE.
*/;
sslBaseVoice function GetSavedVoice(Actor ActorRef)
  return VoiceSlots.GetSaved(ActorRef)
endFunction

;/* HasCustomVoice
* * Checks if the given Actor has a custom, non-registered SexLab voice.
* * 
* * @param: Actor ActorRef - The actor to check.
* * @return: sslBaseVoice - A suitable voice object for the actor to use.
*/;
bool function HasCustomVoice(Actor ActorRef)
  return VoiceSlots.HasCustomVoice(ActorRef)
endFunction

;/* GetVoiceByGender
* * Get a random voice for a given gender.
* * 
* * @param: int Gender - The gender number to get a random voice for. 0 = male 1 = female.
* * @return: sslBaseVoice - A suitable voice object for the given actor gender.
*/;
sslBaseVoice function GetVoiceByGender(int Gender)
  return VoiceSlots.PickGender(Gender)
endFunction

;/* GetVoicesByGender
* * Get an array of voices for a given gender.
* * 
* * @param: int Gender - The gender number to get a random voice for. 0 = male 1 = female.
* * @return: sslBaseVoice[] - An array of suitable voices for the given actor gender.
*/;
sslBaseVoice[] function GetVoicesByGender(int Gender)
  return VoiceSlots.GetAllGender(Gender)
endFunction

;/* GetVoiceByName
* * Get a single voice object by name. Ignores if a user has the voice enabled or not.
* * 
* * @param: string FindName - The name of an voice object as seen in the SexLab MCM.
* * @return: sslBaseVoice - The voice object whose name matches, if found.
*/;
sslBaseVoice function GetVoiceByName(string FindName)
  return VoiceSlots.GetByName(FindName)
endFunction

;/* FindVoiceByName
* * Find the registration slot number that an voice currently occupies.
* * 
* * @param: string FindName - The name of an voice as seen in the SexLab MCM.
* * @return: int - The registration slot number for the voice.
*/;
int function FindVoiceByName(string FindName)
  return VoiceSlots.FindByName(FindName)
endFunction

;/* GetVoiceBySlot
* * @RETURNS a voice object by it's registration slot number.
* * 
* * @param: int slot - The slot number of the voice object.
* * @return: sslBaseVoice - The voice object that currently occupies that slot, NONE if nothing occupies it.
*/;
sslBaseVoice function GetVoiceBySlot(int slot)
  return VoiceSlots.GetBySlot(slot)
endFunction

;/* GetVoiceByTags
* * Selects a single voice from a set of given tag options.
* * 
* * @param: string Tags - A comma separated list of voice tags you want to use as a filter.
* * @param: string TagSuppress - A comma separated list of voice tags you DO NOT want present on the returned voice.
* * @param: bool RequireAll - If TRUE, all tags in the provided "string Tags" list must be present in an voice to be returned. When FALSE only one tag in the list is needed.
* * @return: sslBaseVoice - A randomly selected voice object among any that match the provided search arguments.
*/;
sslBaseVoice function GetVoiceByTags(string Tags, string TagSuppress = "", bool RequireAll = true)
  return VoiceSlots.GetByTags(Tags, TagSuppress, RequireAll)
endFunction

;/* GetVoicesByTags
* * Selects a single voice from a set of given tag options.
* * 
* * @param: string Tags - A comma separated list of voice tags you want to use as a filter.
* * @param: string TagSuppress - A comma separated list of voice tags you DO NOT want present on the returned voice.
* * @param: bool RequireAll - If TRUE, all tags in the provided "string Tags" list must be present in an voice to be returned. When FALSE only one tag in the list is needed.
* * @return: sslBaseVoice[] - An array of voices that match the provided search arguments.
*/;
sslBaseVoice[] function GetVoicesByTags(string Tags, string TagSuppress = "", bool RequireAll = true)
  return VoiceSlots.GetAllByTags(Tags, TagSuppress, RequireAll)
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  ^^^                                                      END VOICE FUNCTIONS                                                      ^^^  #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                        BEGIN EXPRESSION FUNCTION                                                        #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/* PickExpression
* * Selects a random expression that fits the provided criteria. A slightly different method of having the expression compared to PickExpressionByStatus.
* * 
* * @param: Actor ActorRef - The actor who will be using this expression.
* * @param: Actor VictimRef - The actor considered a victim in an aggressive scene.
* * @return: sslBaseExpression - A randomly selected expression object among any that meet the needed criteria.
*/;
sslBaseExpression function PickExpression(Actor ActorRef, Actor VictimRef = none)
  return ExpressionSlots.PickByStatus(ActorRef, (VictimRef && VictimRef == ActorRef), (VictimRef && VictimRef != ActorRef))
endFunction

;/* PickExpressionByStatus
* * Selects a random expression that fits the provided criteria.
* * 
* * @param: Actor ActorRef - The actor who will be using this expression and the following conditions apply to.
* * @param: bool IsVictim - Set to TRUE if the actor is considered the victim in an aggressive scene.
* * @param: bool IsAggressor - Set to TRUE if the actor is considered the aggressor in an aggressive scene.
* * @return: sslBaseExpression - A randomly selected expression object among any that meet the needed criteria.
*/;
sslBaseExpression function PickExpressionByStatus(Actor ActorRef, bool IsVictim = false, bool IsAggressor = false)
  return ExpressionSlots.PickByStatus(ActorRef, IsVictim, IsAggressor)
endFunction

;/* GetExpressionsByStatus
* * Selects a random expression that fits the provided criteria.
* * 
* * @param: Actor ActorRef - The actor who will be using this expression and the following conditions apply to.
* * @param: bool IsVictim - Set to TRUE if the actor is considered the victim in an aggressive scene.
* * @param: bool IsAggressor - Set to TRUE if the actor is considered the aggressor in an aggressive scene.
* * @return: sslBaseExpression[] - An array of expressions that meet the needed criteria.
*/;
sslBaseExpression[] function GetExpressionsByStatus(Actor ActorRef, bool IsVictim = false, bool IsAggressor = false)
  return ExpressionSlots.GetByStatus(ActorRef, IsVictim, IsAggressor)
endFunction

;/* PickExpressionByTag
* * Selects a single expression from based on a single tag.
* * 
* * @param: Actor ActorRef - The actor who will be using this expression and the following conditions apply to.
* * @param: string Tags - A single expression tag to use as the filter when picking randomly. Warning, it is not possible to use a comma separated list of tags.
* * @return: sslBaseExpression - A randomly selected expression object among any that have the provided tag.
*/;
sslBaseExpression function PickExpressionsByTag(Actor ActorRef, string Tag)
  sslBaseExpression[] Found =  ExpressionSlots.GetByTag(Tag, ActorRef.GetLeveledActorBase().GetSex() == 1)
  if Found && Found.Length > 0
    return Found[(Utility.RandomInt(0, (Found.Length - 1)))]
  endIf
  return none
endFunction

;/* GetExpressionsByTag
* * Selects a single expression from based on a single tag.
* * 
* * @param: Actor ActorRef - The actor who will be using this expression and the following conditions apply to.
* * @param: string Tags - A single expression tag to use as the filter when picking randomly. Warning, it is not possible to use a comma separated list of tags.
* * @return: sslBaseExpression[] - An array of expressions that have the provided tag.
*/;
sslBaseExpression[] function GetExpressionsByTag(Actor ActorRef, string Tag)
  return ExpressionSlots.GetByTag(Tag, ActorRef.GetLeveledActorBase().GetSex() == 1)
endFunction

;/* GetExpressionByName
* * Get a single expression object by name. Ignores if a user has the expression enabled or not.
* * 
* * @param: string FindName - The name of an expression object as seen in the SexLab MCM.
* * @return: sslBaseExpression - The expression object whose name matches, if found.
*/;
sslBaseExpression function GetExpressionByName(string findName)
  return ExpressionSlots.GetByName(findName)
endFunction

;/* FindExpressionByName
* * Find the registration slot number that an expression currently occupies.
* * 
* * @param: string FindName - The name of an expression as seen in the SexLab MCM.
* * @return: int - The registration slot number for the expression.
*/;
int function FindExpressionByName(string findName)
  return ExpressionSlots.FindByName(findName)
endFunction

;/* GetExpressionBySlot
* * @RETURNS a expression object by it's registration slot number.
* * 
* * @param: int slot - The slot number of the expression object.
* * @return: sslBaseExpression - The expression object that currently occupies that slot, NONE if nothing occupies it.
*/;
sslBaseExpression function GetExpressionBySlot(int slot)
  return ExpressionSlots.GetBySlot(slot)
endFunction

;/* OpenMouth
* * Opens an actors mouth.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* * Example:
* * SexLab.OpenMouth(myActor)
* *   is equivalent, but less performat (because there is an extra call) compared to
* * sslBaseExpression.OpenMouth(myActor)
* * 
* * @param: Actor ActorRef - The actors whose mouth should open.
*/;
function OpenMouth(Actor ActorRef)
  if ActorRef
    int i
    while i < ThreadSlots.Threads.Length
      int ActorSlot = Threads[i].FindSlot(ActorRef)
      if ActorSlot != -1
        Threads[i].ActorAlias[ActorSlot].ForceOpenMouth = True
      endIf
      i += 1
    endwhile
    sslBaseExpression.OpenMouth(ActorRef)
  endIf
endFunction

;/* CloseMouth
* * Closes an actors mouth.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actors whose mouth should open.
*/;
function CloseMouth(Actor ActorRef)
  if ActorRef
    int i
    while i < ThreadSlots.Threads.Length
      int ActorSlot = Threads[i].FindSlot(ActorRef)
      if ActorSlot != -1
        Threads[i].ActorAlias[ActorSlot].ForceOpenMouth = False
      endIf
      i += 1
    endwhile
    sslBaseExpression.CloseMouth(ActorRef)
  endIf
endFunction

;/* IsMouthOpen
* * Checks if an actor's mouth is currently considered open or not.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actors whose may or may not currently be open.
* * @return: bool - TRUE if the actors mouth appears to be in an open state.
*/;
bool function IsMouthOpen(Actor ActorRef)
  return sslBaseExpression.IsMouthOpen(ActorRef)
endFunction

;/* GetCurrentMFG
* * Get an array with the mood, phonemes, and modifiers currently applied to the actor.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actors whose expression values should be returned.
* * @return: float[] - An float array of Length 32 that match the format and structure of the Preset parameter in the ApplyPresetFloats function.
*/;
float[] function GetCurrentMFG(Actor ActorRef)
  return sslBaseExpression.GetCurrentMFG(ActorRef)
endFunction

;/* ClearMFG
* * Resets an actors mood, phonemes, and modifiers.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actors whose expression should return to normal.
*/;
function ClearMFG(Actor ActorRef)
  sslBaseExpression.ClearMFG(ActorRef)
endFunction

;/* ClearPhoneme
* * Resets all of an actors phonemes to 0.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actor to clear phonemes on.
*/;
function ClearPhoneme(Actor ActorRef)
  sslBaseExpression.ClearPhoneme(ActorRef)
endFunction

;/* ClearModifier
* * Resets all of an actors modifiers to 0.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actor to clear modifiers on.
*/;
function ClearModifier(Actor ActorRef)
  sslBaseExpression.ClearModifier(ActorRef)
endFunction

;/* ApplyPresetFloats
* * Applies an array of values to an actor, automatically setting their phonemes, modifiers, and mood.
* * Mirrored function of a global in sslBaseExpressions. Is advised to use, in your scripts, the global one instead of this one.
* *
* * @param: Actor ActorRef - The actors to apply the preset to.
* * @param: float[] Preset - Must be a 32 length array. Each index corresponds to an MFG id. Values range from 0.0 to 1.0, with the exception of mood type.
* *                          Phonemes   0-15 = Preset[0]  to Preset[15]
* *                          Modifiers  0-13 = Preset[16] to Preset[29]
* *                          Mood Type       = Preset[30]
* *                          Mood Value      = Preset[31]
*/;
function ApplyPresetFloats(Actor ActorRef, float[] Preset)
  sslBaseExpression.ApplyPresetFloats(ActorRef, Preset)
endfunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  ^^^                                                    END EXPRESSION FUNCTIONS                                                   ^^^  #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                           START STAT FUNCTIONS                                                          #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/* RegisterStat
* * Adds a custom statistic in the list of Actor Statistics. If the stat already exists, then it does nothing.
* * 
* * @param: Name - the name of the statistic
* * @param: Value - The value for the statistic
* * @param: Preped - a string to put before the stat
* * @param: Append - a string to put after the stat
* * @return: an int that is the position of the newly created stat
*/;
int function RegisterStat(string Name, string Value, string Prepend = "", string Append = "")
  return Stats.RegisterStat(Name, Value, Prepend, Append)
endFunction

; Alters an existing stat that has already been registered from the above
function Alter(string Name, string NewName = "", string Value = "", string Prepend = "", string Append = "")
  Stats.Alter(Name, NewName, Value, Prepend, Append)
endFunction

;/* FindStat
* * Returns the index of a stat, or -1 if the stat does not exists
* * @param: the Name of the Statistics
* * @return: an int with the index of the stat, -1 if not found
*/;
int function FindStat(string Name)
  return Stats.FindStat(Name)
endFunction

;/* GetActorStat
* * Gets the value for a custom stat for the specified actor as a string
* *
* * @param: ActorRef, is the actor to get the value of the stat
* * @param: Name, is the name of the stat that will be get
* * @return: A string with the value of the stat for the actor, if the actor has no stat for the specified value, then the default value is returned
*/;
string function GetActorStat(Actor ActorRef, string Name)
  return Stats.GetStat(ActorRef, Name)
endFunction

;/* GetActorStatInt
* * Gets the value for a custom stat for the specified actor as an int
* *
* * @param: ActorRef, is the actor to get the value of the stat
* * @param: Name, is the name of the stat that will be get
* * @return: An int  with the value of the stat for the actor, if the actor has no stat for the specified value, then the default value is returned
*/;
int function GetActorStatInt(Actor ActorRef, string Name)
  return Stats.GetStatInt(ActorRef, Name)
endFunction

;/* GetActorStatFloat
* * Gets the value for a custom stat for the specified actor as a float
* *
* * @param: ActorRef, is the actor to get the value of the stat
* * @param: Name, is the name of the stat that will be get
* * @return: A float with the value of the stat for the actor, if the actor has no stat for the specified value, then the default value is returned
*/;
float function GetActorStatFloat(Actor ActorRef, string Name)
  return Stats.GetStatFloat(ActorRef, Name)
endFunction

;/* SetActorStat
* * Sets the value for a custom stat for the specified actor
* *
* * @param: ActorRef, is the actor to get the value of the stat
* * @param: Name, is the name of the stat that will be get
* * @return: The previous value for the stat (TO BE CONFIRMED!!!!)
*/;
string function SetActorStat(Actor ActorRef, string Name, string Value)
  return Stats.SetStat(ActorRef, Name, Value)
endFunction

;/* 
*/;
int function ActorAdjustBy(Actor ActorRef, string Name, int AdjustBy)
  return Stats.AdjustBy(ActorRef, Name, AdjustBy)
endFunction

;/* 
*/;
string function GetActorStatFull(Actor ActorRef, string Name)
  return Stats.GetStatFull(ActorRef, Name)
endFunction

;/* 
*/;
string function GetStatFull(string Name)
  return Stats.GetStatFull(PlayerRef, Name)
endFunction

;/* 
*/;
string function GetStat(string Name)
  return Stats.GetStat(PlayerRef, Name)
endFunction

;/* 
*/;
int function GetStatInt(string Name)
  return Stats.GetStatInt(PlayerRef, Name)
endFunction

;/* 
*/;
float function GetStatFloat(string Name)
  return Stats.GetStatFloat(PlayerRef, Name)
endFunction

;/* 
*/;
string function SetStat(string Name, string Value)
  return Stats.SetStat(PlayerRef, Name, Value)
endFunction

;/* 
*/;
int function AdjustBy(string Name, int AdjustBy)
  return Stats.AdjustBy(PlayerRef, Name, AdjustBy)
endFunction

;/* CalcSexuality
* * Calculates the sexuality given by the number of "partners" as number of males and females
* * This function is a global mathematical function, it is not specific for an actor.
* * 
* * @param: IsFemale, if set to true, then the calculation is done for a female, if set to FALSE then the calculation is done as a male
* * @param: males, is the number of sexual relations had with a male
* * @param: females, is the number of sexual relations had with a female
* * @return: an int between 0 and 100, where 0 is for full homosexual and 100 for full heterosexual. 50 is for bisexual.
*/;
int function CalcSexuality(bool IsFemale, int males, int females)
  return Stats.CalcSexuality(IsFemale, males, females)
endFunction

;/* CalcLevel
* * it is a mathematical function that calculates a level as the square root of the half of the first parameter multiplied by the curve parameter.
* *
* * @param: total, is the number used to calculate the value
* * @param: curve, is a parameter to have the result more smooth (<1.0) or sharp (>1.0)
* * @return: an inte as result of sqr(total / 2) * curve rounded to the integer value
*/;
int function CalcLevel(float total, float curve = 0.65)
  return Stats.CalcLevel(total, curve)
endFunction

;/* ParseTime
* * Utility function that converts an amount of seconds in a string representation with the format HH:MM:SS
* *
* * @param: int time, the number of seconds to convert in the string format
* * @return: a string with the amount of seconds converted in the HH:MM:SS format. If the amount of seconds is zero or negative, then the result is "--:--:--"
*/;
string function ParseTime(int time)
  return Stats.ParseTime(time)
endFunction

;/* PlayerSexCount
* * Returns the number of times the actor had sex with the player.
* *
* * @param: Actor ActorRef, is the actor to check the number of intercourses with the player
* * @return: The number of intercourses the actor had with the player
*/;
int function PlayerSexCount(Actor ActorRef)
  return Stats.PlayerSexCount(ActorRef)
endFunction

;/* HadPlayerSex
* * Checks if the actor ever had sex with the player
* *
* * @param: Actor ActorRef, is the actor to check the number of intercourses with the player
* * @return: TRUE if the actor had sex with the player
*/;
bool function HadPlayerSex(Actor ActorRef)
  return Stats.HadPlayerSex(ActorRef)
endFunction

;/* MostUsedPlayerSexPartner
* * Find which actor had more sex intercourse with the player
* *
* * @return: an Actor that is the partner of the player which had most intercourses with the player
*/;
Actor function MostUsedPlayerSexPartner()
  return Stats.MostUsedPlayerSexPartner()
endFunction

;/* MostUsedPlayerSexPartners
* * Find which actors had more sex intercourse with the player. 
* *
* * @param: int MaxActors [OPTIONAL] - The Max amount actor to add to the returned array 
* * @return: Actor[] - An intercourse sorted Actor array with the partners of the player which had most intercourses with the player
*/;
Actor[] function MostUsedPlayerSexPartners(int MaxActors = 5)
  return Stats.MostUsedPlayerSexPartners(MaxActors)
endFunction

;/* LastSexPartner
* * Find the last sex partner for a given actor
* * 
* * @param: Actor ActorRef, is the actor to check for finding the last sex partner
* * @return: An Actor that was the last actor the ActorRef had sex with
*/;
Actor function LastSexPartner(Actor ActorRef)
  return Stats.LastSexPartner(ActorRef)
endFunction

;/* HasHadSexTogether
* * Checks if the two actors ever had sex together
* *
* * @param: Actor ActorRef1, first of the two partners to check
* * @param: Actor ActorRef2, second of the two partners to check
* * @return: TRUE is the two actors ever had sex together
*/;
bool function HasHadSexTogether(Actor ActorRef1, Actor ActorRef2)
  return Stats.HasHadSexTogether(ActorRef1, ActorRef2)
endfunction

;/* LastAggressor
* * Returns the last actor that was an aggressor in a SexLab animation involving the actor parameter 
* *
* * @param: Actor ActorRef, is the actor to check for finding the last aggressor
* * @return: An Actor that was the last aggressor the ActorRef had, None if the actor never had an aggressor
*/;
Actor function LastAggressor(Actor ActorRef)
  return Stats.LastAggressor(ActorRef)
endFunction

;/* WasVictimOf
* * Very similar to LastAggressor(), but you can specify also a specific aggressor
* *
* * @param: Actor VictimRef, is the actor to check to understand if was aggressed by AggressorRef
* * @param: Actor AggressorRef, is the actor to check to understand VictimRef was aggressed by
* * @return: TRUE AggressorRef was an aggressor of VictimRef
*/;
bool function WasVictimOf(Actor VictimRef, Actor AggressorRef)
  return Stats.WasVictimOf(VictimRef, AggressorRef)
endFunction

;/* LastVictim
* * Finds who was the last vicitm of the specified actor
* *
* * @param: Actor ActorRef, the actor that was an aggressor
* * @return: an Actor that was the last victim of the specified aggressor.
*/;
Actor function LastVictim(Actor ActorRef)
  return Stats.LastVictim(ActorRef)
endFunction

;/* WasAggressorTo
* * Exactly the same of WasVictimOf(), but with the roles exchanged
* *
* * @param: Actor AggressorRef, is the actor to check to understand VictimRef was aggressed by
* * @param: Actor VictimRef, is the actor to check to understand if was aggressed by AggressorRef
* * @return: TRUE AggressorRef was an aggressor of VictimRef
*/;
bool function WasAggressorTo(Actor AggressorRef, Actor VictimRef)
  return Stats.WasAggressorTo(AggressorRef, VictimRef)
endFunction

;/* AdjustPurity
* * Changes the stats for the specified actor for "Pure" and "lewd". If the "amount" is positive then the "Pure" stat is increased. If the "amount" is negative, then the "lewd" stat is increased.
* *
* * @param: Actor ActorRef, is the actor for whom to change the stat
* * @param: float amount, is the amount that will be added to "Pure" (if amount is positive), or "Lewd" (if amount is negative) stats.
* * @return: the resulting value of the stat
*/;
float function AdjustPurity(Actor ActorRef, float amount)
  return Stats.AdjustPurity(ActorRef, amount)
endFunction

;/* SetSexuality
* * Defines the sexual orientation of the specified actor, where 1 is pure homosexual, and 100 is pure heterosexual
* *
* * @param: Actor ActorRef, is the actor for whom to change the sexual orientation (warning this is NOT touching the Sex Gender!)
* * @param: float amount, is the amount that will specify if the actor is 1=pure homosexual, 50=bisexual, 100=pure heterosexual
*/;
function SetSexuality(Actor ActorRef, int amount)
  Stats.SetSkill(ActorRef, "Sexuality", PapyrusUtil.ClampInt(amount, 1, 100))
endFunction

;/* SetSexualityStraight
* * Shortcut for SetSexuality(actor, 100), makes the actor pure heterosexual
* *
* * @param: Actor ActorRef, is the actor for whom to change the sexual orientation (warning this is NOT touching the Sex Gender!)
*/;
function SetSexualityStraight(Actor ActorRef)
  Stats.SetSkill(ActorRef, "Sexuality", 100)
endFunction

;/* SetSexualityBisexual
* * Shortcut for SetSexuality(actor, 50), makes the actor bisexual
* *
* * @param: Actor ActorRef, is the actor for whom to change the sexual orientation (warning this is NOT touching the Sex Gender!)
*/;
function SetSexualityBisexual(Actor ActorRef)
  Stats.SetSkill(ActorRef, "Sexuality", 50)
endFunction

;/* SetSexualityGay
* * Shortcut for SetSexuality(actor, 1), makes the actor pure homosexual
* *
* * @param: Actor ActorRef, is the actor for whom to change the sexual orientation (warning this is NOT touching the Sex Gender!)
*/;
function SetSexualityGay(Actor ActorRef)
  Stats.SetSkill(ActorRef, "Sexuality", 1)
endFunction

;/* GetSexuality
* * Returns the stat for the specified actor about its sexuality
* *
* * @param: Actor ActorRef, is the actor for whom to change the sexual orientation (warning this is NOT touching the Sex Gender!)
* * @return: an int with the sexual orientation of the actor. 1 will be pure homosexual, and 100 will be pure heterosexual
*/;
int function GetSexuality(Actor ActorRef)
  return Stats.GetSexuality(ActorRef)
endFunction

;/* GetSexualityTitle
* * Provides the sexuality not as a number but as a descriptive, translated, string
* *
* * @param: Actor ActorRef, is the actor for whom to change the sexual orientation (warning this is NOT touching the Sex Gender!)
* * @return: a string with "Heterosexual" if the sexuality score is greater or equal to 65; "Bisexual" if the score is between 65 and 35; "Gay" or "Lesbian" in case the sexuality is less than 35, of course the value depends on the actual gender of the actor.
*/;
string function GetSexualityTitle(Actor ActorRef)
  return Stats.GetSexualityTitle(ActorRef)
endFunction

;/* GetSkillTitle
* * Provide a description of the specified skill for the defined actor.
* * Possible values (that can be trnaslated) are: Unskilled, Novice, Apprentice, Journeyman, Expert, Master, and GrandMaster
* *
* * @param: Actor ActorRef, is the actor for whom to calculate the skill title
* * @param: string Skill, is the skill to calculate the title (standard skills are: Foreplay, Vaginal, Anal, Oral, Pure, and Lewd)
* * @return: a string with the title corresponding to the skill level for the actor
*/;
string function GetSkillTitle(Actor ActorRef, string Skill)
  return Stats.GetSkillTitle(ActorRef, Skill)
endFunction

;/* GetSkill
* * Returns the actual value of the specified skill for the specified actor
* *
* * @param: Actor ActorRef, is the actor for whom get the skill value
* * @param: string Skill, is the skill to get (standard skills are: Foreplay, Vaginal, Anal, Oral, Pure, and Lewd)
* * @return: an int with the raw value of the skill for the actor
*/;
int function GetSkill(Actor ActorRef, string Skill)
  return Stats.GetSkill(ActorRef, Skill)
endFunction

;/* GetSkillLevel
* * Returns the calculated level value of the specified skill for the specified actor
* *
* * @param: Actor ActorRef, is the actor for whom get the skill level
* * @param: string Skill, is the skill to get (standard skills are: Foreplay, Vaginal, Anal, Oral, Pure, and Lewd)
* * @return: an int with the calculate level of the skill for the actor
*/;
int function GetSkillLevel(Actor ActorRef, string Skill)
  return Stats.GetSkillLevel(ActorRef, Skill)
endFunction

;/* GetPurity
* * Return the raw walue for the Pure skill for the actor
* *
* * @param: Actor ActorRef, is the actor for whom get the skill value
* * @return: a float with the actual raw value of the "pure" skill
*/;
float function GetPurity(Actor ActorRef)
  return Stats.GetPurity(ActorRef)
endFunction

;/* GetPurityLevel
* * Return the level walue for the Pure skill for the actor
* *
* * @param: Actor ActorRef, is the actor for whom get the skill value
* * @return: an int with the leveled value of the "pure" skill
*/;
int function GetPurityLevel(Actor ActorRef)
  return Stats.GetPurityLevel(ActorRef)
endFunction

;/* GetPurityTitle
* * Provides a string with the title of the purity level for the actor
* * e.g. Neutral, Unsullied, CleanCut, Virtuous, EverFaithful, Lordly, Saintly
* *
* * @param: Actor ActorRef, is the actor for whom get the purity level
* * @return: a string with the purity title
*/;
string function GetPurityTitle(Actor ActorRef)
  return Stats.GetPurityTitle(ActorRef)
endFunction

;/* IsPure
* * Checks if an actor is pure or not
* *
* * @param: Actor ActorRef, is the actor to check for purity
* * @return: true if the actor is pure
*/;
bool function IsPure(Actor ActorRef)
  return Stats.IsPure(ActorRef)
endFunction


;/* IsLewd
* * Checks if an actor is lewd or not
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: true if the actor is lewd
*/;
bool function IsLewd(Actor ActorRef)
  return Stats.IsLewd(ActorRef)
endFunction

;/* IsStraight
* * Checks if the actor is straight, so if it had mainly heterosexual intercourses
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: true if the actor has a level of sexuality greater than 65% (mostly heterosexual)
*/;
bool function IsStraight(Actor ActorRef)
  return Stats.IsStraight(ActorRef)
endFunction

;/* IsBisexual
* * Checks if the actor is bisexual, so if it had a mix of homosexual and heterosexual intercourses
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: true if the actor has a level of sexuality between 35% and 65%
*/;
bool function IsBisexual(Actor ActorRef)
  return Stats.IsBisexual(ActorRef)
endFunction

;/* IsGay
* * Checks if the actor is gay/lesbian, so if it had mainly homosexual intercourses
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: true if the actor has a level of sexuality lower than 35% (mostly homosexual)
*/;
bool function IsGay(Actor ActorRef)
  return Stats.IsGay(ActorRef)
endFunction

;/* SexCount
* * Provides the number of times the actor participated in sex using sexlab
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: an int with the number of times the actor had sex using sexlab
*/;
int function SexCount(Actor ActorRef)
  return Stats.SexCount(ActorRef)
endFunction

;/* HadSex
* * Checks if an actor ever had sex before
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: true if the actor participated in at least one intercourse
*/;
bool function HadSex(Actor ActorRef)
  return Stats.HadSex(ActorRef)
endFunction

;/* LastSexGameTime
* * Provides the last time the actor had sex, in GameTime format
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the game time (same format as returned by Utility.GetCurrentGameTime()) when the actor had sex last time
*/;
; Last sex - Game time - float days
float function LastSexGameTime(Actor ActorRef)
  return Stats.LastSexGameTime(ActorRef)
endFunction

;/* DaysSinceLastSex
* * Provides the number of days (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of game days passed from the last time the actor had sex
*/;
float function DaysSinceLastSex(Actor ActorRef)
  return Stats.DaysSinceLastSex(ActorRef)
endFunction

;/* HoursSinceLastSex
* * Provides the number of hours (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of game hours passed from the last time the actor had sex
*/;
float function HoursSinceLastSex(Actor ActorRef)
  return Stats.HoursSinceLastSex(ActorRef)
endFunction

;/* MinutesSinceLastSex
* * Provides the number of minutes (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of game minutes passed from the last time the actor had sex
*/;
float function MinutesSinceLastSex(Actor ActorRef)
  return Stats.MinutesSinceLastSex(ActorRef)
endFunction

;/* SecondsSinceLastSex
* * Provides the number of seconds (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of game seconds passed from the last time the actor had sex
*/;
float function SecondsSinceLastSex(Actor ActorRef)
  return Stats.SecondsSinceLastSex(ActorRef)
endFunction

;/* LastSexTimerString
* * Provides the last time the actor had sex, in GameTime format but converted to a descriptive string
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a string with the game time (same format as returned by Utility.GetCurrentGameTime()) when the actor had sex last time
*/;
string function LastSexTimerString(Actor ActorRef)
  return Stats.LastSexTimerString(ActorRef)
endFunction

;/* LastSexRealTime
* * Provides the last time the actor had sex, in Real Time format
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the game time (same format as returned by Utility.GetCurrentRealTime()) when the actor had sex last time
*/;
float function LastSexRealTime(Actor ActorRef)
  return Stats.LastSexRealTime(ActorRef)
endFunction

;/* DaysSinceLastSexRealTime
* * Provides the number of days (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of game days passed from the last time the actor had sex
*/;
float function DaysSinceLastSexRealTime(Actor ActorRef)
  return Stats.DaysSinceLastSexRealTime(ActorRef)
endFunction

;/* HoursSinceLastSexRealTime
* * Provides the number of hours (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of real time hours passed from the last time the actor had sex
*/;
float function HoursSinceLastSexRealTime(Actor ActorRef)
  return Stats.HoursSinceLastSexRealTime(ActorRef)
endFunction

;/* MinutesSinceLastSexRealTime
* * Provides the number of minutes (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of real time minutes passed from the last time the actor had sex
*/;
float function MinutesSinceLastSexRealTime(Actor ActorRef)
  return Stats.MinutesSinceLastSexRealTime(ActorRef)
endFunction

;/* SecondsSinceLastSexRealTime
* * Provides the number of seconds (it can be a fraction) passed from the last time the actor had sex
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a float with the number of real time seconds passed from the last time the actor had sex
*/;
float function SecondsSinceLastSexRealTime(Actor ActorRef)
  return Stats.SecondsSinceLastSexRealTime(ActorRef)
endFunction

;/* LastSexTimerStringRealTime
* * Provides the last time the actor had sex, in Real Time format but converted to a descriptive string
* *
* * @param: Actor ActorRef, is the actor to check
* * @return: a string with the real timewhen the actor had sex last time
*/;
string function LastSexTimerStringRealTime(Actor ActorRef)
  return Stats.LastSexTimerStringRealTime(ActorRef)
endFunction

;/* AdjustPlayerPurity
* * Changes the stats for the p for "Pure" and "lewd". If the "amount" is positive then the "Pure" stat is increased. If the "amount" is negative, then the "lewd" stat is increased.
* * This function is a Player shortcut
* *
* * @param: float amount, is the amount that will be added to "Pure" (if amount is positive), or "Lewd" (if amount is negative) stats.
* * @return: the resulting value of the stat
*/;
float function AdjustPlayerPurity(float amount)
  return Stats.AdjustPurity(PlayerRef, amount)
endFunction

;/* GetPlayerPurityLevel
* * Return the level walue for the Pure skill for the player
* * This function is a Player shortcut
* *
* @return: an int with the leveled value of the "pure" skill
*/;
int function GetPlayerPurityLevel()
  return Stats.GetPurityLevel(PlayerRef)
endFunction

;/* GetPlayerPurityTitle
* * Provides a string with the title of the purity level for the player
* * e.g. Neutral, Unsullied, CleanCut, Virtuous, EverFaithful, Lordly, Saintly
* * This function is a Player shortcut
* *
* @return: a string with the purity title
*/;
string function GetPlayerPurityTitle()
  return Stats.GetPurityTitle(PlayerRef)
endFunction

;/* GetPlayerSexualityTitle
* * Provides the sexuality not as a number but as a descriptive, translated, string
* * This function is a Player shortcut
* *
* @return: a string with "Heterosexual" if the sexuality score of the player is greater or equal to 65; "Bisexual" if the score is between 65 and 35; "Gay" or "Lesbian" in case the sexuality is less than 35, of course the value depends on the actual gender of the player.
*/;
string function GetPlayerSexualityTitle()
  return Stats.GetSexualityTitle(PlayerRef)
endFunction

;/* GetPlayerSkillLevel
* * Returns the calculated level value of the specified skill for the player
* * This function is a Player shortcut
* *
* @return: an int with the calculate level of the skill for the player
*/;
int function GetPlayerSkillLevel(string Skill)
  return Stats.GetSkillLevel(PlayerRef, Skill)
endFunction

;/* GetPlayerSkillTitle
* * Provide a description of the specified skill for the player.
* * Possible values (that can be translated) are: Unskilled, Novice, Apprentice, Journeyman, Expert, Master, and GrandMaster
* * This function is a Player shortcut
* *
* * @param: string Skill, is the skill to calculate the title (standard skills are: Foreplay, Vaginal, Anal, Oral, Pure, and Lewd)
* * @return: a string with the title corresponding to the skill level for the player
*/;
string function GetPlayerSkillTitle(string Skill)
  return Stats.GetSkillTitle(PlayerRef, Skill)
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#  ^^^                                                       END STAT FUNCTIONS                                                      ^^^  #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                         START UTILITY FUNCTIONS                                                         #
;#                                                        See functions located at:                                                        #
;#                                                              SexLabUtil.psc                                                             #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/* MakeActorArray
* * Creates an array of actors with the specified actor objects.
* * Deprecated this script, use it directly from SexLabUtil instead.
* * 
* * @param: Actor Actor1, one actor to add in the array (can be unspefified and so ignored)
* * @param: Actor Actor2, one actor to add in the array (can be unspefified and so ignored)
* * @param: Actor Actor3, one actor to add in the array (can be unspefified and so ignored)
* * @param: Actor Actor4, one actor to add in the array (can be unspefified and so ignored)
* * @param: Actor Actor5, one actor to add in the array (can be unspefified and so ignored)
* * @return: an Actor[] of the size of the non null actors with the specified actors inside.
*/;
Actor[] function MakeActorArray(Actor Actor1 = none, Actor Actor2 = none, Actor Actor3 = none, Actor Actor4 = none, Actor Actor5 = none)
  return SexLabUtil.MakeActorArray(Actor1, Actor2, Actor3, Actor4, Actor5)
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                                          END UTILITY FUNCTIONS                                                          #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#


; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
;                                                                                                                                           ;
;                                      ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗                                          ;
;                                      ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║                                          ;
;                                      ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║                                          ;
;                                      ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║                                          ;
;                                      ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗                                     ;
;                                      ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝                                     ;
;                                                                                                                                           ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
;                                                     This is the end of the public API                                                     ;
;                                    Do not use or access any of the below listed functions or properties                                   ;  
; ----------------------------------------------------------------------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

;#-----------------------------------------------------------------------------------------------------------------------------------------#;
;#                                                                                                                                         #;
;#                                                 DEPRECATED FUNCTIONS - DO NOT USE THEM                                                  #;
;#         Replace these functions, if used in your mod, with the applicable new versions for easier usage and better performance.         #;
;#                                                                                                                                         #;
;#-----------------------------------------------------------------------------------------------------------------------------------------#;

;/ DEPRECATED /;
sslThreadController function HookController(string argString)
  return ThreadSlots.GetController(argString as int)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function HookAnimation(string argString)
  return ThreadSlots.GetController(argString as int).Animation
endFunction

;/* DEPRECATED! */;
int function HookStage(string argString)
  return ThreadSlots.GetController(argString as int).Stage
endFunction

;/* DEPRECATED! */;
Actor function HookVictim(string argString)
  return ThreadSlots.GetController(argString as int).VictimRef
endFunction

;/* DEPRECATED! */;
Actor[] function HookActors(string argString)
  return ThreadSlots.GetController(argString as int).Positions
endFunction

;/* DEPRECATED! */;
float function HookTime(string argString)
  return ThreadSlots.GetController(argString as int).TotalTime
endFunction

;/* DEPRECATED! */;
bool function HasCreatureAnimation(Race CreatureRace, int Gender = -1)
  return CreatureSlots.RaceHasAnimation(CreatureRace, -1, Gender)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetAnimationsByTag(int ActorCount, string Tag1, string Tag2 = "", string Tag3 = "", string TagSuppress = "", bool RequireAll = true)
  return AnimSlots.GetByTags(ActorCount, sslUtility.MakeArgs(",", Tag1, Tag2, Tag3), TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByTags(int ActorCount, string Tags, string TagSuppress = "", bool RequireAll = true)
  return CreatureSlots.GetByTags(ActorCount, Tags, TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseVoice function GetVoiceByTag(string Tag1, string Tag2 = "", string TagSuppress = "", bool RequireAll = true)
  return VoiceSlots.GetByTags(sslUtility.MakeArgs(",", Tag1, Tag2), TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
function ApplyCum(Actor ActorRef, int CumID)
  ActorLib.ApplyCum(ActorRef, CumID)
endFunction

;/* DEPRECATED! */;
form function StripWeapon(Actor ActorRef, bool RightHand = true)
  return none ; ActorLib.StripWeapon(ActorRef, RightHand)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] property Animations hidden
  sslBaseAnimation[] function get()
    return AnimSlots.GetSlots(0, 128)
  endFunction
endProperty

;/* DEPRECATED! */;
sslBaseAnimation[] property CreatureAnimations hidden
  sslBaseAnimation[] function get()
    return CreatureSlots.GetSlots(0, 128)
  endFunction
endProperty

;/* DEPRECATED! */;
sslBaseVoice[] property Voices hidden
  sslBaseVoice[] function get()
    return VoiceSlots.Voices
  endFunction
endProperty

;/* DEPRECATED! */;
sslBaseExpression[] property Expressions hidden
  sslBaseExpression[] function get()
    return ExpressionSlots.Expressions
  endFunction
endProperty

;/* DEPRECATED! */;
sslBaseExpression function RandomExpressionByTag(string Tag)
  return ExpressionSlots.RandomByTag(Tag)
endFunction

;/* DEPRECATED! */;
function ApplyPreset(Actor ActorRef, int[] Preset)
  sslBaseExpression.ApplyPreset(ActorRef, Preset)
endFunction

;/* DEPRECATED! */;
sslThreadController[] property Threads hidden
  sslThreadController[] function get()
    return ThreadSlots.Threads
  endFunction
endProperty

;/* DEPRECATED! */;
bool function IsImpure(Actor ActorRef)
  return Stats.IsLewd(ActorRef)
endFunction

;/* DEPRECATED! */;
int function GetPlayerStatLevel(string Skill)
  return Stats.GetSkillLevel(PlayerRef, Skill)
endFunction

;/* DEPRECATED! */;
int function StartSex(Actor[] Positions, sslBaseAnimation[] Anims, Actor Victim = none, ObjectReference CenterOn = none, bool AllowBed = true, string Hook = "")
  sslThreadModel thread = NewThread()
  If (!thread)
    Log("StartSex() - Failed to claim an available thread")
    return -1
  ElseIf (!thread.AddActors(Positions, Victim))
    Log("StartSex() - Failed to add some actors to thread")
    return -1
  EndIf
  thread.SetAnimations(Anims)
  thread.CenterOnObject(CenterOn)
  thread.DisableBedUse(!AllowBed)
  thread.SetHook(Hook)
  If (thread.StartThread())
    return thread.GetThreadID()
  EndIf
  return -1
EndFunction

;/* DEPRECATED! */;
sslThreadController Function QuickStart(Actor Actor1, Actor Actor2 = none, Actor Actor3 = none, Actor Actor4 = none, Actor Actor5 = none, Actor Victim = none, string Hook = "", string AnimationTags = "")
  Actor[] Positions = SexLabUtil.MakeActorArray(Actor1, Actor2, Actor3, Actor4, Actor5)
  return StartScene(Positions, AnimationTags, Victim, asHook = Hook) as sslThreadController
EndFunction

;/* DEPRECATED! */;
string function MakeAnimationGenderTag(Actor[] Positions)
  return ActorLib.MakeGenderTag(Positions)
endFunction

;/* DEPRECATED! */;
string function GetGenderTag(int Females = 0, int Males = 0, int Creatures = 0)
  return ActorLib.GetGenderTag(Females, Males, Creatures)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetAnimationsByTags(int ActorCount, string Tags, string TagSuppress = "", bool RequireAll = true)
  return AnimSlots.GetByTags(ActorCount, Tags, TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetAnimationsByType(int ActorCount, int Males = -1, int Females = -1, int StageCount = -1, bool Aggressive = false, bool Sexual = true)
  return AnimSlots.GetByType(ActorCount, Males, Females, StageCount, Aggressive, Sexual)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function PickAnimationsByActors(Actor[] Positions, int Limit = 64, bool Aggressive = false)
  return AnimSlots.PickByActors(Positions, limit, aggressive)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetAnimationsByDefault(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true)
  return AnimSlots.GetByDefault(Males, Females, IsAggressive, UsingBed, RestrictAggressive)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetAnimationsByDefaultTags(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true, string Tags, string TagsSuppressed = "", bool RequireAll = true)
  return AnimSlots.GetByDefaultTags(Males, Females, IsAggressive, UsingBed, RestrictAggressive, Tags, TagsSuppressed, RequireAll)
endFunction

;/* DEPRECATED! */;
Actor[] function SortCreatures(Actor[] Positions, sslBaseAnimation Animation = none)
  return ThreadLib.SortCreatures(Positions, Animation)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByRace(int ActorCount, Race RaceRef)
  return CreatureSlots.GetByRace(ActorCount, RaceRef)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByRaceTags(int ActorCount, Race RaceRef, string Tags, string TagSuppress = "", bool RequireAll = true)
  return CreatureSlots.GetByRaceTags(ActorCount, RaceRef, Tags, TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByRaceGenders(int ActorCount, Race RaceRef, int MaleCreatures = 0, int FemaleCreatures = 0, bool ForceUse = false)
  return CreatureSlots.GetByRaceGenders(ActorCount, RaceRef, MaleCreatures, FemaleCreatures, ForceUse)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByRaceGendersTags(int ActorCount, Race RaceRef, int MaleCreatures = 0, int FemaleCreatures = 0, string Tags, string TagSuppress = "", bool RequireAll = true)
  return CreatureSlots.GetByRaceGendersTags(ActorCount, RaceRef, MaleCreatures, FemaleCreatures, Tags, TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByRaceKey(int ActorCount, string RaceKey)
  return CreatureSlots.GetByRaceKey(ActorCount, RaceKey)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByRaceKeyTags(int ActorCount, string RaceKey, string Tags, string TagSuppress = "", bool RequireAll = true)
  return CreatureSlots.GetByRaceKeyTags(ActorCount, RaceKey, Tags, TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByActors(int ActorCount, Actor[] Positions)
  return CreatureSlots.GetByCreatureActors(ActorCount, Positions)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetCreatureAnimationsByActorsTags(int ActorCount, Actor[] Positions, string Tags, string TagSuppress = "", bool RequireAll = true)
  return CreatureSlots.GetByCreatureActorsTags(ActorCount, Positions, Tags, TagSuppress, RequireAll)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function RegisterAnimation(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function RegisterCreatureAnimation(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function NewAnimationObject(string Token, Form Owner)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function GetSetAnimationObject(string Token, string Callback, Form Owner)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function NewAnimationObjectCopy(string Token, sslBaseAnimation CopyFrom, Form Owner)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function GetAnimationObject(string Token)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function GetOwnerAnimations(Form Owner)
  return none
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function MakeAnimationRegistered(string Token)
  return none
endFunction

;/* DEPRECATED! */;
bool function HasAnimationObject(string Token)
  return Factory.HasAnimation(Token)
endFunction

;/* DEPRECATED! */;
bool function ReleaseAnimationObject(string Token)
  return Factory.ReleaseAnimation(Token)
endFunction

;/* DEPRECATED! */;
int function ReleaseOwnerAnimations(Form Owner)
  return Factory.ReleaseOwnerAnimations(Owner)
endFunction

;/* DEPRECATED! */;
bool function RemoveRegisteredAnimation(string Registrar)
  return AnimSlots.UnregisterAnimation(Registrar)
endFunction

;/* DEPRECATED! */;
bool function RemoveRegisteredCreatureAnimation(string Registrar)
  return CreatureSlots.UnregisterAnimation(Registrar)
endFunction

; --- NOTE: Removed since P+ Phase 2

;/* DEPRECATED! | See SexLabRegistry.psc */;
int function GetGender(Actor ActorRef)
  return ActorLib.GetGender(ActorRef)
endFunction

;/* DEPRECATED! | See TreatAsSex() */;
Function TreatAsGender(Actor ActorRef, bool AsFemale)
  ActorLib.TreatAsGender(ActorRef, AsFemale)
EndFunction

;/* DEPRECATED! | See ClearForcedSex() */;
function ClearForcedGender(Actor ActorRef)
  ActorLib.ClearForcedGender(ActorRef)
endFunction

;/* DEPRECATED! */;
int[] function GenderCount(Actor[] Positions)
  return ActorLib.GenderCount(Positions)
endFunction

;/* DEPRECATED! */;
int[] function TransGenderCount(Actor[] Positions)
  return ActorLib.TransCount(Positions)
endFunction

;/* DEPRECATED! */;
int function MaleCount(Actor[] Positions)
  return ActorLib.MaleCount(Positions)
endFunction

;/* DEPRECATED! */;
int function FemaleCount(Actor[] Positions)
  return ActorLib.FemaleCount(Positions)
endFunction

;/* DEPRECATED! */;
int function CreatureCount(Actor[] Positions)
  return ActorLib.CreatureCount(Positions)
endFunction

;/* DEPRECATED! */;
int function TransMaleCount(Actor[] Positions)
  return ActorLib.TransCount(Positions)[0]
endFunction

;/* DEPRECATED! */;
int function TransFemaleCount(Actor[] Positions)
  return ActorLib.TransCount(Positions)[1]
endFunction

;/* DEPRECATED! */;
int function TransCreatureCount(Actor[] Positions)
  int[] TransCount = ActorLib.TransCount(Positions)
  return TransCount[2] + TransCount[3]
endFunction

;/* DEPRECATED! */;
Form function EquipStrapon(Actor ActorRef)
  return Config.EquipStrapon(ActorRef)
endFunction

;/* DEPRECATED! */;
function UnequipStrapon(Actor ActorRef)
  Config.UnequipStrapon(ActorRef)
endFunction

;/* DEPRECATED! */;
bool function CheckBardAudience(Actor ActorRef, bool RemoveFromAudience = true)
  return Config.CheckBardAudience(ActorRef, RemoveFromAudience)
endFunction

; --- Old Threading API

;/* DEPRECATED! */;
sslThreadController function GetController(int tid)
  return ThreadSlots.GetController(tid)
endFunction

;/* DEPRECATED! */;
int function FindActorController(Actor ActorRef)
  return ThreadSlots.FindActorController(ActorRef)
endFunction

;/* DEPRECATED! */;
int function FindPlayerController()
  return ThreadSlots.FindActorController(PlayerRef)
endFunction

;/* DEPRECATED! */;
sslThreadController function GetActorController(Actor ActorRef)
  return ThreadSlots.GetActorController(ActorRef)
endFunction

;/* DEPRECATED! */;
sslThreadController function GetPlayerController()
  return ThreadSlots.GetActorController(PlayerRef)
endFunction

;/* DEPRECATED! */;
int function GetEnjoyment(int tid, Actor ActorRef)
  return ThreadSlots.GetController(tid).GetEnjoyment(ActorRef)
endfunction

;/* DEPRECATED! */;
bool function IsVictim(int tid, Actor ActorRef)
  return ThreadSlots.GetController(tid).IsVictim(ActorRef)
endFunction

;/* DEPRECATED! */;
bool function IsAggressor(int tid, Actor ActorRef)
  return ThreadSlots.GetController(tid).IsAggressor(ActorRef)
endFunction

;/* DEPRECATED! */;
bool function IsUsingStrapon(int tid, Actor ActorRef)
  return ThreadSlots.GetController(tid).ActorAlias(ActorRef).IsUsingStrapon()
endFunction

;/* DEPRECATED! */;
bool function PregnancyRisk(int tid, Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
  return ThreadSlots.GetController(tid).PregnancyRisk(ActorRef, AllowFemaleCum, AllowCreatureCum)
endfunction

; --- Legacy Animation Functions

;/* DEPRECATED! | See SortActorsByScene() */;
Actor[] function SortActorsByAnimation(Actor[] Positions, sslBaseAnimation Animation = none)
  return ThreadLib.SortActorsByAnimation(Positions, Animation)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function GetAnimationByName(string FindName)
  return AnimSlots.GetByName(FindName)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function GetAnimationByRegistry(string Registry)
  return AnimSlots.GetByRegistrar(Registry)
endFunction

;/* DEPRECATED! */;
int function FindAnimationByName(string FindName)
  return AnimSlots.FindByName(FindName)
endFunction

;/* DEPRECATED! */;
int function GetAnimationCount(bool IgnoreDisabled = true)
  return AnimSlots.GetCount(IgnoreDisabled)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function MergeAnimationLists(sslBaseAnimation[] List1, sslBaseAnimation[] List2)
  return sslUtility.MergeAnimationLists(List1, List2)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation[] function RemoveTagged(sslBaseAnimation[] Anims, string Tags)
  return sslUtility.RemoveTaggedAnimations(Anims, PapyrusUtil.StringSplit(Tags))
endFunction

;/* DEPRECATED! */;
int function CountTag(sslBaseAnimation[] Anims, string Tags)
  return AnimSlots.CountTag(Anims, Tags)
endFunction

;/* DEPRECATED! */;
int function CountTagUsage(string Tags, bool IgnoreDisabled = true)
  return AnimSlots.CountTagUsage(Tags, IgnoreDisabled)
endFunction

;/* DEPRECATED! */;
int function CountCreatureTagUsage(string Tags, bool IgnoreDisabled = true)
  return CreatureSlots.CountTagUsage(Tags, IgnoreDisabled)
endFunction

;/* DEPRECATED! */;
string[] function GetAllAnimationTags(int ActorCount = -1, bool IgnoreDisabled = true)
  return AnimSlots.GetAllTags(ActorCount, IgnoreDisabled)
endFunction

;/* DEPRECATED! */;
string[] function GetAllAnimationTagsInArray(sslBaseAnimation[] List)
  return sslUtility.GetAllAnimationTagsInArray(List)
endFunction

; --- Legacy Creature Functions

;/* DEPRECATED! */;
sslBaseAnimation function GetCreatureAnimationByName(string FindName)
  return CreatureSlots.GetByName(FindName)
endFunction

;/* DEPRECATED! */;
sslBaseAnimation function GetCreatureAnimationByRegistry(string Registry)
  return CreatureSlots.GetByRegistrar(Registry)
endFunction

;/* DEPRECATED! */;
bool function HasCreatureRaceAnimation(Race CreatureRace, int ActorCount = -1, int Gender = -1)
  return CreatureSlots.RaceHasAnimation(CreatureRace, ActorCount, Gender)
endFunction

;/* DEPRECATED! */;
bool function HasCreatureRaceKeyAnimation(string RaceKey, int ActorCount = -1, int Gender = -1)
  return CreatureSlots.RaceKeyHasAnimation(RaceKey, ActorCount, Gender)
endFunction

;/* DEPRECATED! */;
bool function AllowedCreature(Race CreatureRace)
  return CreatureSlots.AllowedCreature(CreatureRace)
endFunction

;/* DEPRECATED! */;
bool function AllowedCreatureCombination(Race CreatureRace, Race CreatureRace2)
  return CreatureSlots.AllowedCreatureCombination(CreatureRace, CreatureRace2)
endFunction

;/* DEPRECATED! */;
string[] function GetAllCreatureAnimationTags(int ActorCount = -1, bool IgnoreDisabled = true)
  return CreatureSlots.GetAllTags(ActorCount, IgnoreDisabled)
endFunction

;/* DEPRECATED! */;
string[] function GetAllBothAnimationTags(int ActorCount = -1, bool IgnoreDisabled = true)
  string[] Output = PapyrusUtil.MergeStringArray(AnimSlots.GetAllTags(ActorCount, IgnoreDisabled), CreatureSlots.GetAllTags(ActorCount, IgnoreDisabled))
  PapyrusUtil.SortStringArray(Output)
  return Output
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;# ^^^                                            END DEPRECATED FUNCTIONS - DO NOT USE THEM                                           ^^^ #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

;/
  NOTE: Following functions are not yet legacy but will likely be in some future update. Do not use them to stay compatible with future versions!
/;

;/* RegisterVoice
* * Find an available SexLabVoice slot and starts the callback to register it.
* * In case the SexLabVoice was already registered you get the already registered SexLabVoice without any update
* *
* * @param: string Registrar, the ID of the SexLabVoice, no spaces allowed.
* * @param: Form CallbackForm, the script (as object) that has the code to register the SexLabVoice, the script has to have an Event with the same name of the registrar
* * @param: ReferenceAlias CallbackAlias, can be used alternatively to CallbackForm, in case the script is inside a ReferenceAlias
* * @return: sslBaseVoice, the actual SexLabVoice registered
*/;
sslBaseVoice function RegisterVoice(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
  return VoiceSlots.RegisterVoice(Registrar, CallbackForm, CallbackAlias)
endFunction

;/* RegisterExpression
* * Find an available SexLabExpression slot and starts the callback to register it.
* * In case the SexLabExpression was already registered you get the already registered SexLabExpression without any update
* *
* * @param: string Registrar, the ID of the SexLabExpression, no spaces allowed.
* * @param: Form CallbackForm, the script (as object) that has the code to register the SexLabExpression, the script has to have an Event with the same name of the registrar
* * @param: ReferenceAlias CallbackAlias, can be used alternatively to CallbackForm, in case the script is inside a ReferenceAlias
* * @return: sslBaseVoice, the actual SexLabExpression registered
*/;
sslBaseExpression function RegisterExpression(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
  return ExpressionSlots.RegisterExpression(Registrar, CallbackForm, CallbackAlias)
endFunction

;/* NewVoiceObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseVoice function NewVoiceObject(string Token, Form Owner)
  return Factory.NewVoice(Token, Owner)
endFunction

;/* NewExpressionObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseExpression function NewExpressionObject(string Token, Form Owner)
  return Factory.NewExpression(Token, Owner)
endFunction

;/* GetSetVoiceObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseVoice function GetSetVoiceObject(string Token, string Callback, Form Owner)
  return Factory.GetSetVoice(Token, Callback, Owner)
endFunction

;/* GetSetExpressionObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseExpression function GetSetExpressionObject(string Token, string Callback, Form Owner)
  return Factory.GetSetExpression(Token, Callback, Owner)
endFunction

;/* NewVoiceObjectCopy
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseVoice function NewVoiceObjectCopy(string Token, sslBaseVoice CopyFrom, Form Owner)
  return Factory.NewVoiceCopy(Token, CopyFrom, Owner)
endFunction

;/* NewExpressionObjectCopy
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseExpression function NewExpressionObjectCopy(string Token, sslBaseExpression CopyFrom, Form Owner)
  return Factory.NewExpressionCopy(Token, CopyFrom, Owner)
endFunction

;/* GetVoiceObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseVoice function GetVoiceObject(string Token)
  return Factory.GetVoice(Token)
endFunction

;/* GetExpressionObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseExpression function GetExpressionObject(string Token)
  return Factory.GetExpression(Token)
endFunction

;/* GetOwnerVoices
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseVoice[] function GetOwnerVoices(Form Owner)
  return Factory.GetOwnerVoices(Owner)
endFunction

;/* GetOwnerExpressions
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseExpression[] function GetOwnerExpressions(Form Owner)
  return Factory.GetOwnerExpressions(Owner)
endFunction

;/* HasVoiceObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
bool function HasVoiceObject(string Token)
  return Factory.HasVoice(Token)
endFunction

;/* HasExpressionObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
bool function HasExpressionObject(string Token)
  return Factory.HasExpression(Token)
endFunction

;/* ReleaseVoiceObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
bool function ReleaseVoiceObject(string Token)
  return Factory.ReleaseVoice(Token)
endFunction

;/* ReleaseExpressionObject
* * TODO
* * 
* * @param: 
* * @return: 
*/;
bool function ReleaseExpressionObject(string Token)
  return Factory.ReleaseExpression(Token)
endFunction

;/* ReleaseOwnerVoices
* * TODO
* * 
* * @param: 
* * @return: 
*/;
int function ReleaseOwnerVoices(Form Owner)
  return Factory.ReleaseOwnerVoices(Owner)
endFunction

;/* ReleaseOwnerExpressions
* * TODO
* * 
* * @param: 
* * @return: 
*/;
int function ReleaseOwnerExpressions(Form Owner)
  return Factory.ReleaseOwnerExpressions(Owner)
endFunction

;/* MakeVoiceRegistered
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseVoice function MakeVoiceRegistered(string Token)
  return Factory.MakeVoiceRegistered(Token)
endFunction

;/* MakeExpressionRegistered
* * TODO
* * 
* * @param: 
* * @return: 
*/;
sslBaseExpression function MakeExpressionRegistered(string Token)
  return Factory.MakeExpressionRegistered(Token)
endFunction

;/* RemoveRegisteredVoice
* * TODO
* * 
* * @param: 
* * @return: 
*/;
bool function RemoveRegisteredVoice(string Registrar)
  return VoiceSlots.UnregisterVoice(Registrar)
endFunction

;/* RemoveRegisteredExpression
* * TODO
* * 
* * @param: 
* * @return: 
*/;
bool function RemoveRegisteredExpression(string Registrar)
  return ExpressionSlots.UnregisterExpression(Registrar)
endFunction

;#-----------------------------------------------------------------------------------------------------------------------------------------#
;#                                                                                                                                         #
;#                                    THE FOLLOWING PROPERTIES AND FUNCTION ARE FOR INTERNAL USE ONLY                                      #
;#                                                                                                                                         #
;#                                                                                                                                         #
;#                             ****       ***         *     *   ***   *******     *     *   ******  *******                                #
;#                             *   **    *   *        **    *  *   *     *        *     *  *      * *                                      #
;#                             *     *  *     *       * *   * *     *    *        *     *  *        *                                      #
;#                             *      * *     *       *  *  * *     *    *        *     *   ******  *****                                  #
;#                             *     *  *     *       *   * * *     *    *        *     *         * *                                      #
;#                             *   **    *   *        *    **  *   *     *         *   *   *      * *                                      #
;#                             ****       ***         *     *   ***      *          ***     ******  *******                                #
;#                                                                                                                                         #
;#                                                                                                                                         #
;#-----------------------------------------------------------------------------------------------------------------------------------------#

; Data
sslSystemConfig property Config Auto
Actor property PlayerRef Auto

; Function libraries
sslActorLibrary property ActorLib Auto
sslThreadLibrary property ThreadLib Auto
sslActorStats property Stats Auto

; Object registries
sslThreadSlots property ThreadSlots Auto
sslVoiceSlots property VoiceSlots Auto
sslExpressionSlots property ExpressionSlots Auto

function Setup()
	; Reset function Libraries - SexLabQuestFramework
	Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
	Config = SexLabQuestFramework as sslSystemConfig
	ThreadLib = SexLabQuestFramework as sslThreadLibrary
	ThreadSlots = SexLabQuestFramework as sslThreadSlots
	ActorLib = SexLabQuestFramework as sslActorLibrary
	Stats = SexLabQuestFramework as sslActorStats
	; Reset secondary object registry - SexLabQuestRegistry
	Form SexLabQuestRegistry = Game.GetFormFromFile(0x664FB, "SexLab.esm")
	ExpressionSlots = SexLabQuestRegistry as sslExpressionSlots
	VoiceSlots = SexLabQuestRegistry as sslVoiceSlots

	PlayerRef = Game.GetPlayer()
  Log(self + " - Loaded SexLabFramework")
endFunction

sslThreadModel function NewThread(float TimeOut = 5.0)
  return ThreadSlots.PickModel(TimeOut)
endFunction

Function Log(string Log, string Type = "NOTICE")
  Log = "[SEXLAB] - " + Type + " - " + Log
  SexLabUtil.PrintConsole(Log)
  If(Type == "FATAL")
    Debug.TraceStack(Log)
  Else
    Debug.Trace(Log)
  EndIf
EndFunction

state Disabled
  sslThreadModel function NewThread(float TimeOut = 5.0)
    Log("NewThread() - Failed to make new thread model; system is currently disabled or not installed", "FATAL")
    return none
  endFunction
  SexLabThread Function StartScene(Actor[] akPositions, String asTags, Actor akSubmissive = none, ObjectReference akCenter = none, int aiFurniture = 1, String asHook = "")
    Log("StartScene() - Failed to make new thread model; system is currently disabled or not installed", "FATAL")
    return none
  EndFunction
  sslThreadController function QuickStart(Actor Actor1, Actor Actor2 = none, Actor Actor3 = none, Actor Actor4 = none, Actor Actor5 = none, Actor Victim = none, string Hook = "", string AnimationTags = "")
    Log("QuickStart() - Failed to make new thread model; system is currently disabled or not installed", "FATAL")
    return none
  endFunction
  int function StartSex(Actor[] Positions, sslBaseAnimation[] Anims, Actor Victim = none, ObjectReference CenterOn = none, bool AllowBed = true, string Hook = "")
    Log("StartSex() - Failed to make new thread model; system is currently disabled or not installed", "FATAL")
    return -1
  endFunction
  event OnBeginState()
    Log("SexLabFramework - Disabled")
    ModEvent.Send(ModEvent.Create("SexLabDisabled"))
  endEvent
endState

state Enabled
  event OnBeginState()
    Log("SexLabFramework - Enabled")
    ModEvent.Send(ModEvent.Create("SexLabEnabled"))
  endEvent
endState

Faction Property AnimatingFaction
  Faction Function Get()
    return Config.AnimatingFaction
  EndFunction
EndProperty
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

event OnInit()
  ; p+ 2.0: Setup is exclusively handled by sslSystemAlias
	; Setup()
endEvent
