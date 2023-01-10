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
	int racekeyidx
	If(AkActor.HasKeywordString("ActorTypeNPC"))
		racekeyidx = 0
	Else
		Race actorrace = akActor.GetRace()
		String rk = sslCreatureAnimationSlots.GetRaceKey(actorrace)
		If(rk == "Wolves" || rk == "Dogs")
			rk == "Canines"
		EndIf
		racekeyidx = GetAllRaceKeys().Find(rk) + 1
		If(racekeyidx == 0)
			Debug.Trace("SEXLAB - ERROR -Actor " + akActor + " is not using a recognized Race: " + actorrace + "(" + rk + ")")
			return 0
		EndIf
	EndIf
  return BuildDataKeyNative(akActor, abIsVictim, racekeyidx)
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
; Gender: 0 - Male / 1 - Female / 2 - Futa / 3 - Crt. Male / 4 - Crt. Female
int Function BuildCustomKey(int aiGender, int aiRaceID, bool[] abExtraData) native global

; ------------------------------------------------------- ;
; --- Comparing & Sorting      				                --- ;
; ------------------------------------------------------- ;

int[] Function SortDataKeys(int[] aiKeys) native global

; Return if aiKey <= aiCmp
; Note that empty keys (0) and blank keys are considered equal here and are both sorted at the end of the array
bool Function IsLess(int aiKey, int aiCmp) native global

; Return if aiKey matches aiCmp, that is
; check if aiKey is a valid key to fill a position requiring aiCmp
bool Function Match(int aiKey, int aiCmp) native global
bool Function MatchArray(int[] aiKeys, int[] aiCmp) native global

; ------------------------------------------------------- ;
; --- Reading                 				                --- ;
; ------------------------------------------------------- ;

; Return an integer ID for the given key
; 0 - Male
; 1 - Female
; 2 - Futa
; 3 - M Crt
; 4 - F Crt
int Function GetGender(int aiKey) native global

; Return the real gender of this actor, ie the gender without respect to overwrites
; A futa is defined as a female with a schlong from SoS, a Creature is always gendered
bool Function IsMale(int aiKey) native global
bool Function IsFemale(int aiKey) native global
bool Function IsPureFemale(int aiKey) native global			; assert(IsFemale() && !IsFuta())
bool Function IsFuta(int aiKey) native global      			; assert(IsFemale() && !IsPureFemale())
bool Function IsCreature(int aiKey) native global  			; assert(IsMaleCreature() || IsFemaleCreature())
bool Function IsMaleCreature(int aiKey) native global		;	may return false positive if creature gender is disabled
bool Function IsFemaleCreature(int aiKey) native global	;	may return false positive if creature gender is disabled

bool Function IsVictim(int aiKey) native global
bool Function IsVampire(int aiKey) native global

; Gender overwrites are used to allow authors and users to manually assign a gender to an actor
; These only support male and female overwrites and are primarily used for animation filtering
bool Function HasOverwrite(int aiKey) native global
bool Function IsMaleOverwrite(int aiKey) native global
bool Function IsFemaleOverwrite(int aiKey) native global

; The RaceID this Key uses. Will be 0 for humans and some positive integer for creatures
; please beware there is no guarantee that the same race always uses the same integer ID
; use the RaceKey (String) for bookmarking or comparing specific races
int Function GetRaceID(int aiKey) native global

; Gets the RaceKey this DataKey represents. Every group of races uses a distinct RaceKey, see
; SexlabFramework.psc for a short introduction on RaceKeys
String Function GetRaceKey(int aiKey) global
  int idx = GetRaceID(aiKey)
  If(idx > 0)
    return GetAllRaceKeys()[idx - 1]
  EndIf
  return "human"
EndFunction

; Get the ID from the given RaceKey
int Function GetRaceIDByRaceKey(String asRaceKey) global
  return GetAllRaceKeys().Find(asRaceKey) + 1
EndFunction

; ------------------------------------------------------- ;
; --- Legacy Support          				                --- ;
; ------------------------------------------------------- ;

; These functions only exists to ensure compatibility with legacy code. Avoid using them for any other reason

int Function GetLegacyGenderByKey(int aiKey) native global

; Animation registration function for pre SLAL2
int Function BuildByLegacyGender(int aiLegacyGender, String asRaceKey = "human") global
  int id = GetRaceIDByRaceKey(asRaceKey)
  return BuildByLegacyGenderNative(aiLegacyGender, id + 1)
EndFunction
; -1 for overloaded human gender, -2 for overloaded creature gender 
int Function BuildByLegacyGenderNative(int aiLegacyGender, int aiRaceID) native global

; Blank Keys are universal keys, primarily intended to support legacy content
; Needless to say, they incredibly unreliable and should thus not be used
int Function BuildBlankKey() native global

; ------------------------------------------------------- ;
; --- Misc		                 				                --- ;
; ------------------------------------------------------- ;

; 0 - Male, 1 - Female, 2 - Futa, 3 - M Crt, 4 - F Crt, 5 - Overwrite Male, 6 - Overwrite Female
int Function AddGenderToKey(int aiKey, int aiGender) native global
int Function RemoveGenderFromKey(int aiKey, int aiGender) native global

; Adds male and female gender to the multivariable gender definition
Function NeutralizeCreatureGender(int[] aiKeys) native global

; ------------------------------------------------------- ;
; --- TEMPORARY                				                --- ;
; ------------------------------------------------------- ;

; NOTE: ALL BELOW CODE IS TEMPORARY AND ONLY EXISTS AS I DO NOT OWN SEXLABS ORIGINAL DLL SOURCE
; DO NOT USE ANY FUNCTION HERE AS IT WILL (hopefully) BE REMOVED AT ONE POINT WITHOUT WARNING

int Function BuildDataKeyNative(Actor akActor, bool abIsVictim, int aiRaceID) native global

String[] Function GetAllRaceKeys() global
  String[] ret = new String[52]
  ret[0] = "Ashhoppers"
	ret[1] = "Bears"
	ret[2] = "Boars"
	ret[3] = "BoarsAny"
	ret[4] = "BoarsMounted"
	ret[5] = "Canines"
	ret[6] = "Chaurus"
	ret[7] = "ChaurusHunters"
	ret[8] = "ChaurusReapers"
	ret[9] = "Chickens"
	ret[10] = "Cows"
	ret[11] = "Deers"
	ret[12] = "Dogs"
	ret[13] = "DragonPriests"
	ret[14] = "Dragons"
	ret[15] = "Draugrs"
	ret[16] = "DwarvenBallistas"
	ret[17] = "DwarvenCenturions"
	ret[18] = "DwarvenSpheres"
	ret[19] = "DwarvenSpiders"
	ret[20] = "Falmers"
	ret[21] = "FlameAtronach"
	ret[22] = "Foxes"
	ret[23] = "FrostAtronach"
	ret[24] = "Gargoyles"
	ret[25] = "Giants"
	ret[26] = "Goats"
	ret[27] = "Hagravens"
	ret[28] = "Horkers"
	ret[29] = "Horses"
	ret[30] = "IceWraiths"
	ret[31] = "Lurkers"
	ret[32] = "Mammoths"
	ret[33] = "Mudcrabs"
	ret[34] = "Netches"
	ret[35] = "Rabbits"
	ret[36] = "Rieklings"
	ret[37] = "SabreCats"
	ret[38] = "Seekers"
	ret[39] = "Skeevers"
	ret[40] = "Slaughterfishes"
	ret[41] = "StormAtronach"
	ret[42] = "Spiders"
	ret[43] = "LargeSpiders"
	ret[44] = "GiantSpiders"
	ret[45] = "Spriggans"
	ret[46] = "Trolls"
	ret[47] = "VampireLords"
	ret[48] = "Werewolves"
	ret[49] = "WispMothers"
	ret[50] = "Wisps"
	ret[51] = "Wolves"
  return ret
EndFunction
