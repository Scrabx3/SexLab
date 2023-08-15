ScriptName SexlabRegistry Hidden
{
  Global Script for Registry Access

  All registry objects have a unique NanoID attached to them which is expected as the first argument of every function
  These IDs will persist across save games and usually dont change unless the provider of the registry object manually changes the ID
  You can think of them as FormEditorIDs except that they are maintained by SexLab itself, not the game and usually arent human-readable
}

; ------------------------------------------------------- ;
; --- Define                                          --- ;
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

; Return this actors sex. If overwrite is not ignored, will respect the overwrite flag (set by the user or some mod author)
; Mapping: Male = 0 | Female = 1 | Futa = 2 | CrtMale = 3 | CrtFemale = 4
int Function GetSex(Actor akActor, bool abIgnoreOverwrite) native global

; ------------------------------------------------------- ;
; --- Lookup                                          --- ;
; ------------------------------------------------------- ;

; Lookup Scenes for the stated actors, bounded by the given tags
; aiFurniturePreference is one of: 0 - Disallow Furnitures | 1 - Allow Furnitures | 2 - Prefer Furnitures (use iff one can be found)
; if akCenter is set, aiFurniturePreference will be ignored and only animations which are compatible with the given center will be chosen. Example: passing a table
; will only look for table animations, a non furniture center has no influence on the animations which may be picked
String[] Function LookupScenes(Actor[] akPositions, String asTags, Actor akSubmissive, int aiFurniturePreference, ObjectReference akCenter) native global
String[] Function LookupScenesA(Actor[] akPositions, String asTags, Actor[] akSubmissives, int aiFurniturePreference, ObjectReference akCenter) native global

; Check if the given Actors can play the stated scene under the stated tag constraints. Return an array of all valid scenes
bool Function ValidateScene(String asSceneID, Actor[] akPositions, String asTags, Actor akSubmissive) native global
bool Function ValidateSceneA(String asSceneID, Actor[] akPositions, String asTags, Actor[] akSubmissives) native global
String[] Function ValidateScenes(String[] asSceneIDs, Actor[] akPositions, String asTags, Actor akSubmissive) native global
String[] Function ValidateScenesA(String[] asSceneIDs, Actor[] akPositions, String asTags, Actor[] akSubmissive) native global

; Gets the closests valid center object that the stated scene can use to play, if akCenter is none, will use the player instead
; Will return none for scenes that dont require some furniture center
ObjectReference Function GetSceneCenter(String asSceneID, ObjectReference akCenter) native global
bool Function IsCompatibleCenter(String asSceneID, ObjectReference akCenter) native global

; Sort akPosition based on the provided scene. The array will be modified directly, the order of the sorted array is unspecified
; The extended version will take an array and return the index of the n'th scene which the actors are sorted by
; If fallbacks are enabled, will attempt to reinterpret the given actors to find an allowed ordering if the first pass was not successful
; Return false/-1 if the positions couldnt be sorted; E.g. because the scene is incompatible for the stated actors
bool Function SortByScene(Actor[] akPositions, String asScene, bool abAllowFallback) native global
int Function SortBySceneEx(Actor[] akPositions, String[] asScenes, bool abAllowFallback) native global

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
; Check if all of the given scene ids represent a scene object and return all those that do
String[] Function SceneExistA(String[] asSceneIDs) native global

; --- Meta Data

; Get/Change the enabled state of the given Scene. A disabled scene is excluded from lookup functions
bool Function IsSceneEnabled(String asID) native global
Function SetSceneEnabled(String asID, bool abEnabled) native global

; The (human readable) name of the given scene
String Function GetSceneName(String asID) native global

; Check if some given tag is part of a given scene
bool Function IsSceneTag(String asID, String asTag) native global
bool Function IsSceneTagA(String asID, String[] asTags) native global
; Check if some given tag is part of a given stage
bool Function IsStageTag(String asID, String asStage, String asTag) native global
bool Function IsStageTagA(String asID, String asStage, String[] asTags) native global
; Get all tags of this Scene. Scene tags are a merged representation of all stage tags
String[] Function GetSceneTags(String asID) native global
; Get all of this stages tags
String[] Function GetStageTags(String asID, String asStage) native global
; From a list of scenes, get the tags which are shared among all of them
String[] Function GetCommonTags(String[] asIDs) native global

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
; return: 0 - Root | 1 - Common Node | 2 - Sink
int Function GetNodeType(String asID, String asStage) native global

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
; Return a bitflag with following interpretation:
; Male = 0x1 | Female = 0x2 | Futa = 0x4 | CrtMale = 0x8 | CrtFemale = 0x16
int Function GetPositionSex(String asID, int n) native global
int[] Function GetPositionSexA(String asID) native global
bool Function GetIsMalePosition(String asID, int n) global
  return Math.LogicalAnd(GetPositionSex(asID, n), 0x1)
EndFunction
bool Function GetIsFemalePosition(String asID, int n) global
  return Math.LogicalAnd(GetPositionSex(asID, n), 0x2)
EndFunction
bool Function GetIsFutaPositon(String asID, int n) global
  return Math.LogicalAnd(GetPositionSex(asID, n), 0x4)
EndFunction
bool Function GetIsCreaturePositon(String asID, int n) global
  return Math.LogicalAnd(GetPositionSex(asID, n), 0x24)
EndFunction
bool Function GetIsMaleCreaturePositon(String asID, int n) global
  return Math.LogicalAnd(GetPositionSex(asID, n), 0x8)
EndFunction
bool Function GetIsFemaleCreaturePositon(String asID, int n) global
  return Math.LogicalAnd(GetPositionSex(asID, n), 0x16)
EndFunction

; Are position n and m similar in the scenes context? That is, can an actor filling position n also fill position m and vice versa?
bool Function IsSimilarPosition(String asID, int n, int m) native global

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

; Get relevant strip info for the specified stage and position
; Strip Data is represented by a 8 bit flag:
; None = 0 | Helmet = 0x1 | Gloves = 0x2 | Boots = 0x4 | Default = 0x80 | All = 0xFF
int Function GetStripData(String asID, String asStage, int n) native global
int[] Function GetStripDataA(String asID, String asStage) native global