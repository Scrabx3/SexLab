ScriptName sslActorData Hidden
{
  ActorData are integer keys storing a large quantity of for SexLab important data, such as Gender and Race of an Actor, as well as various
  extra data (victim, vampire, ...). These keys excell at comparison, sorting and accessing an actors meta data, but beware that they 
  do not keep any ownership information, so you need to keep track of which key belongs to which actor yourself

  Interaction through these keys should only be done through the listed functions, as key definition may change internally
}

; ------------------------------------------------------- ;
; --- Building                				                --- ;
; ------------------------------------------------------- ;
; TODO: Convince Ashal to hand me over the dll sources so I can move most of the key building into a dll and stabilize creature integration

; Build a DataKey from the given Actor, see flag definition above for more information
; return 0 if the key cannot be created for some reason
int Function BuildDataKey(Actor akActor, bool abIsVictim = false) global
  If(!akActor)
    return 0
  EndIf
	String rk = ""
	If(!AkActor.HasKeywordString("ActorTypeNPC"))
		rk = sslCreatureAnimationSlots.GetRaceKey(akActor.GetRace())
	EndIf
  return BuildDataKeyNative(akActor, abIsVictim, rk)
EndFunction

; Build an array of data keys from the given Actors Order is unchanged (return[i] is the key for akActors[i])
int[] Function BuildDataKeyArray(Actor[] akActors, int aiVictimIdx = -1) global
  bool[] victims = Utility.CreateBoolArray(akActors.Length, false)
  If(aiVictimIdx > -1 && aiVictimIdx < akActors.Length)
    victims[aiVictimIdx] = true
  EndIf
  return BuildDataKeyArrayEx(akActors, victims)
EndFunction

int[] Function BuildDataKeyArrayEx(Actor[] akActors, bool[] abIsVictim) global
  int[] ret = Utility.CreateIntArray(akActors.Length, 0)
  If(akActors.Length != abIsVictim.Length)
    return ret
  EndIf
  int i = 0
  While(i < akActors.Length)
    ret[i] = BuildDataKey(akActors[i], abIsVictim[i])
    i += 1
  EndWhile
  return ret
EndFunction

; Builds a sorted array of Keys, the given Actor array will NOT be changed
int[] Function BuildSortedDataKeyArray(Actor[] akActors, int aiVictimIdx = -1) global
  return SortDataKeys(BuildDataKeyArray(akActors, aiVictimIdx))
EndFunction
int[] Function BuildSortedDataKeyArrayEx(Actor[] akActors, bool[] abIsVictim) global
  return SortDataKeys(BuildDataKeyArrayEx(akActors, abIsVictim))
EndFunction

; EXTRA DATA FLAGS
int Property Victim = 0 AutoReadOnly
int Property Vampire = 1 AutoReadOnly

int Function BuildCustomKey(int aiGender, String asRaceKey) native global
int Function BuildCustomKeyA(int aiGender, String asRaceKey, bool[] abExtraData) native global

; ------------------------------------------------------- ;
; --- Comparing & Sorting      				                --- ;
; ------------------------------------------------------- ;

; returns a sorted copy of aiKeys
int[] Function SortDataKeys(int[] aiKeys) native global

; aiKey < aiCmp
bool Function IsLess(int aiKey, int aiCmp) native global

; Return if aiKey matches aiCmp, that is check if aiKey is allowed to fill a position requiring aiCmp
bool Function Match(int aiKey, int aiCmp) native global
bool Function MatchArray(int[] aiKeys, int[] aiCmp) native global

; ------------------------------------------------------- ;
; --- Reading                 				                --- ;
; ------------------------------------------------------- ;

; Return an integer id for the given keys gender, ignoring overwrites
; 0 - Male / 1 - Female / 2 - Futa / 3 - M Crt / 4 - F Crt
int Function GetGender(int aiKey) native global

; Wrappers for the above function. Does not respect overwrites
; Futa is a unique gender [IsFuta() => !IsFemale()], Creatures are gendered by default
bool Function IsMale(int aiKey) native global
bool Function IsFemale(int aiKey) native global
bool Function IsFuta(int aiKey) native global
bool Function IsCreature(int aiKey) native global
bool Function IsMaleCreature(int aiKey) native global
bool Function IsFemaleCreature(int aiKey) native global

bool Function IsVictim(int aiKey) native global
bool Function IsVampire(int aiKey) native global
bool Function IsDead(int aiKey) native global

; Gender overwrites are used to allow authors and users to manually assign a gender to an actor
; These only support male and female overwrites and are primarily used for animation filtering
bool Function HasOverwrite(int aiKey) native global
bool Function IsMaleOverwrite(int aiKey) native global
bool Function IsFemaleOverwrite(int aiKey) native global

; The racekey this key represents. See SexLabFramework.psc for an introduction on RaceKeys
String Function GetRaceKey(int aiKey) native global

; ------------------------------------------------------- ;
; --- Misc		                 				                --- ;
; ------------------------------------------------------- ;

; Add/Remove an overwrite flag to the given key
int Function AddOverWrite(int aiKey, bool abFemale) native global
int Function RemoveOverWrite(int aiKey, bool abFemale) native global

; Adds both male and female flags to the base gender of the given creatures
Function NeutralizeCreatureGender(int[] aiKeys) native global

; ------------------------------------------------------- ;
; --- Legacy Support          				                --- ;
; ------------------------------------------------------- ;

; 0 - Male / 1 - Female / 2 - M. Crt / 3 - F. Crt
int Function GetLegacyGenderByKey(int aiKey) native global

; Animation registration function for pre SLAL2. -1 for overloaded human gender
int Function BuildByLegacyGender(int aiLegacyGender, String asRaceKey = "human") native global

; Universal keys, primarily intended to support legacy content. They incredibly unreliable and should be avoided
int Function BuildBlankKey() native global

; ------------------------------------------------------- ;
; --- TEMPORARY                				                --- ;
; ------------------------------------------------------- ;

; NOTE: ALL BELOW CODE IS TEMPORARY AND ONLY EXISTS AS I DO NOT OWN SEXLABS ORIGINAL DLL SOURCE
; DO NOT USE ANY FUNCTION HERE AS IT WILL (hopefully) BE REMOVED AT ONE POINT WITHOUT WARNING

int Function BuildDataKeyNative(Actor akActor, bool abIsVictim, String asRaceKey) native global
