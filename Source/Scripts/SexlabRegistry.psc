ScriptName SexlabRegistry Hidden
{
  Global Script for Registry Access

  All registry objects have a unique NanoID attached to them which is expected as the first argument of every function
  These IDs will persist across save games and usually dont change unless the provider of the registry object manually changes the ID
  You can think of them as FormEditorIDs except that they are maintained by SexLab itself, not the game and usually arent human-readable
}

; ------------------------------------------------------- ;
; --- DEFINE                                          --- ;
; ------------------------------------------------------- ;

; Obtain an integer 0-52 representing this actors race
; -1 - Invalid query | 0 - Human | 1+ - Creature
int Function GetRaceID(Actor akActor) native global
int Function MapRaceKeyToID(String asRaceKey) native global
int[] Function GetRaceIDA(Actor akActor) native global
int[] Function MapRaceKeyToIDA(String asRaceKey) native global
; Obtain a human readable string reprentation of some racekey
String Function GetRaceKey(Actor akActor) native global
String Function GetRaceKeyByRace(Race akRace) native global
String Function MapRaceIDToRaceKey(int aiRaceID) native global
String[] Function GetRaceKeyA(Actor akActor) native global
String[] Function GetRaceKeyByRaceA(Race akRace) native global
String[] Function MapRaceIDToRaceKeyA(int aiRaceID) native global
; Obtain a list of all supported RaceKeys; An example for an ambiuous races would be
; "Canines" which represent dogs and wolves at the same time
String[] Function GetAllRaceKeys(bool abIgnoreAmbiguous) native global

; ------------------------------------------------------- ;
; --- Scenes                                          --- ;
; ------------------------------------------------------- ;
;/
  Scenes in SexLab are implemented as directed graphs
  Each graph has exactly 1 start node/source and any amount of end nodes/sinks
  To refer to the start node, use an empty stage ID (""). The graph may contain cycles
  These functions will only throw errors if the scene ID is invalid. Accessing branches/depths out of range or
  passing an invalid stage ID is well defined and will return the return types associated default value (0/"")

  I highly recommend to make yourself familiar with some DFS and BFS algorithm before attempting to
  recursively analyze a scene on your own:
  https://en.wikipedia.org/wiki/Depth-first_search | https://en.wikipedia.org/wiki/Breadth-first_search
/;

; Check if a specific ID belongs to some valid scene object
bool Function SceneExists(String asID) native global

; Get/Change the enabled state of the given Scene. A disabled scene is excluded from lookup functions
bool Function IsSceneEnabled(String asID) native global
Function SetSceneEnabled(String asID, bool abEnabled) native global

; The (human readable) name of the given scene
String Function GetSceneName(String asID) native global

; --- Animation

; Get the animation events for the n'th position of the given stage
String Function GetAnimationEvent(String asID, String asStage, int n) native global
; Get all animation events for every position for the given Stage
String[] Function GetAnimationEventA(String asID, String asStage) native global

; --- Navigation

; Get the first animation of this scene
String Function GetStartAnimation(String asID) native global

; Get the n'th outgoing edge from the given Stage
String Function BranchTo(String asID, String asStage, int n) native global
; Get the number of outgoing edges from a given stage
int Function GetNumBranches(String asID, String asStage) native global

; Get the shortest/longest path from the given stage to a sink
; Return value is a path from asStage (inclusive) to some sink: [asStage, ..., Sink]
String[] Function GetPathMin(String asID, String asStage) native global
String[] Function GetPathMax(String asID, String asStage) native global

; --- Data

; Return the number of actors animated in this scene, including or excluding optional positions
int Function GetActorCount(String asID, bool bIncludeOptionals) native global

; Obtain all stages having a fixed length flag set
String[] Function GetFixedLengthStages(String asID) native global
; Return the fixed length timer of this stage, 0 if the stage isnt flagged as fixed length
float Function GetFixedLength(String asID, String asStage) native global

; Obtain all stages having a climax flag set
String[] Function GetClimaxStages(String asID) native global

; Get compatible sexes of this scenes n'th position
; Bitflag with following interpretation:
; Male = 0x1 | Female = 0x2 | Futa = 0x4 | CrtMale = 0x8 | CrtFemale = 0x16
int Function GetSexP(String asID, int n) native global
bool Function GetIsMalePosition(String asID, int n) global
  return Math.LogicalAnd(GetSexP(asID, n), 0x1)
EndFunction
bool Function GetIsFemalePosition(String asID, int n) global
  return Math.LogicalAnd(GetSexP(asID, n), 0x2)
EndFunction
bool Function GetIsFutaPositon(String asID, int n) global
  return Math.LogicalAnd(GetSexP(asID, n), 0x4)
EndFunction
bool Function GetIsCreaturePositon(String asID, int n) global
  return Math.LogicalAnd(GetSexP(asID, n), 0x24)
EndFunction
bool Function GetIsMaleCreaturePositon(String asID, int n) global
  return Math.LogicalAnd(GetSexP(asID, n), 0x8)
EndFunction
bool Function GetIsFemaleCreaturePositon(String asID, int n) global
  return Math.LogicalAnd(GetSexP(asID, n), 0x16)
EndFunction

; Get the racekey ID of this scenes n'th position
; The racekey ID for humans is 0, and some positive value for creature
int Function GetRaceIDPosition(String asID, int n) native global
int[] Function GetRaceIDPositionA(String asID, int n) native global
; Get a human readable intepretation of some RaceKey
String Function GetRaceKeyPosition(String asID, int n) native global
String[] Function GetRaceKeyPositionA(String asID, int n) native global

; Offset data for the specified position in the given stage, Raw ignores user settings
; returned as [X, Y, Z, Rotation]
float[] Function GetOffset(String asID, String asStage, int n) native global
float[] Function GetOffsetRaw(String asID, String asStage, int n) native global
