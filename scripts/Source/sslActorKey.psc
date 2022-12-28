ScriptName sslActorKey Hidden
{ Fancy bitflag magic to store actor data }

; COMEBACK: It might be worth pushing this entire Script into a .dll
; none of the operations here are overly expensive but its a lot of arithmetic and they are called quite a lot
; and cpp syntax + compiler might be able to optimize this code quite significantly

;/ Bit flags are defined as follows:
0  - Female
1  - Male
2  - Futa
3  - FCr
4  - MCr
5  - Pad6
6  - Pad7
7  - Pad8
8  - CreatureType Bit  0 - 1
9  - CreatureType Bit  2 - 3
10 - CreatureType Bit  4 - 7
11 - CreatureType Bit  8 - 15
12 - CreatureType Bit 16 - 31
13 - CreatureType Bit 32 - 63
14 - Pad15
15 - Pad16
16 - Prefer as Victim
17 - Pad18
18 - Pad19
19 - Pad20
20 - Pad21
21 - Pad22
22 - Pad23
23 - Pad24
24 - Pad25
25 - Pad26
26 - Pad27
27 - Pad28
28 - Pad29
29 - Pad30
30 - Pad31
31 - Blank Key
/;


; Return if aiCmp accepts aiKey, this mans:
; aiKey is a blank key and thus always accepted
; aiKey and aiCmp represent the same Race
; aiKey is at least aiCmps gender
; if aiCmp is a Victim, then aiKey is a victim too
bool Function IsKeyAccepted(int aiKey, int aiCmp) global
  If(IsBlankKey(aiKey))
    return true
  ElseIf(GetRawKey_Creature(aiKey) != GetRawKey_Creature(aiCmp))
    return false
  ElseIf(Math.LogicalAND(GetRawKey_Gender(aiKey), GetRawKey_Gender(aiCmp)) != aiCmp)
    return false
  ElseIf(IsVictim(aiCmp) && !IsVictim(aiKey))
    return false
  EndIf
  return true
EndFunction

int Function BuildActorKey(Actor akActor, bool abIsVictim) global
  int genderid = BuildGenderKey(akActor)
  int raceidx = CreateRaceKeyId(akActor)
  int ret = Math.LogicalOr(raceidx, genderid)
  If(abIsVictim)
    ret += 65536  ; 1 << 16
  EndIf
  return ret
EndFunction

int Function BuildBlankKeyByLegacyGender(int aiLegacyGender) global
  If(aiLegacyGender < 0)
    return Math.LeftShift(1, 31)
  EndIf
  int ret = GetGenderByLegacyGender(aiLegacyGender)
  If(IsCreature(ret))
    ; Set every creature bit
    ret += 0xFF00
  EndIf
  return ret
EndFunction

int[] Function BuildActorKeyArray(Actor[] akActors, int aiVictimIdx = -1) global
  int[] ret = Utility.CreateIntArray(akActors.Length)
  int i = 0
  While(i < akActors.Length)
    ret[i] = BuildActorKey(akActors[i], i == aiVictimIdx)
    i += 1
  EndWhile
  return ret
EndFunction

int[] Function BuildSortedActorKeyArray(Actor[] akActors, int aiVictimIdx = -1) global
  return SortActorKeyArray(BuildActorKeyArray(akActors, aiVictimIdx))
EndFunction

int Function BuildBlankKey() global
  return Math.LeftShift(1, 31)
EndFunction

int[] Function SortActorKeyArray(int[] aiKeys) global
  int i = 1
	While(i < aiKeys.Length)
		int it = aiKeys[i]
		int n = i - 1
		While(n >= 0 && !IsLesserKey(aiKeys[n], it))
			aiKeys[n + 1] = aiKeys[n]
			n -= 1
		EndWhile
		aiKeys[n + 1] = it
		i += 1
	EndWhile
EndFunction

bool Function IsLesserKey(int aiKey, int aiCmp) global
  int r1 = GetRawKey_Creature(aiKey)
  If(r1 == 0)
    return IsLesserKey_GenderAndVictim(aiKey, aiCmp)
  Else
    int r2 = GetRawKey_Creature(aiCmp)
    If(r1 == r2)
      return IsLesserKey_GenderAndVictim(aiKey, aiCmp)
    Else
      return r1 <= r2
    EndIf
  EndIf
EndFunction

bool Function IsLesserKey_Gender(int aiKey, int aiCmp) global
  return GetRawKey_Gender(aiKey) <= GetRawKey_Gender(aiCmp)
EndFunction

bool Function IsLesserKey_Creature(int aiKey, int aiCmp) global
  return GetRawKey_Creature(aiKey) <= GetRawKey_Creature(aiCmp)
EndFunction

bool Function IsLesserKey_GenderAndVictim(int aiKey, int aiCmp) global
  int g1 = GetRawKey_Gender(aiKey) 
  int g2 = GetRawKey_Gender(aiCmp)
  If(g1 == g2)
    If(IsVictim(aiKey))
      return true
    Else
      return !IsVictim(aiCmp)
    EndIf
  Else
    return g1 < g2
  EndIf
EndFunction

; COMEBACK: This do be kinda hacky. Wanna rewrite eventually
int function BuildGenderKey(Actor akActor) global
  return GetGenderByLegacyGender(SexLabUtil.GetGender(akActor))
endFunction

int Function GetLegacyGenderByKey(int aiKey) global
  If(Math.LogicalAnd(aiKey, 2))      ; Male
    return 0
  ElseIf(Math.LogicalAnd(aiKey, 5))  ; Female | Futa
    return 1
  ElseIf(Math.LogicalAnd(aiKey, 8))  ; FCr
    return 3
  ElseIf(Math.LogicalAnd(aiKey, 16)) ; MCr
    return 2
  EndIf
EndFunction

int Function GetGenderByLegacyGender(int aiLegacyGender) global
  If(aiLegacyGender == 0)
    return 2
  ElseIf(aiLegacyGender == 1)
    ; IDEA: If HasSchlong() return 5
    return 1
  ElseIf(aiLegacyGender == 2)
    return 8
  ElseIf(aiLegacyGender == 3)
    return 16
  EndIf
  return 2
EndFunction

int Function CreateRaceKeyId(Actor akActor) global
  return CreateRaceKeyIdByRaceKey(sslCreatureAnimationSlots.GetRaceKey(akActor.GetRace()))
EndFunction

int Function CreateRaceKeyIdByRaceKey(String asRaceKey) global
  int racekey = GetRaceKeyId(asRaceKey)
  If(racekey <= 0)
    return 0
  EndIf
  return Math.LeftShift(racekey, 8)
EndFunction

int Function AddGenderToKey(int aiKey, int aiGender) global
  return Math.LogicalOr(aiGender, aiKey)
EndFunction

int Function AddLegacyGenderToKey(int aiKey, int aiLegacyGender) global
  return AddGenderToKey(aiKey, GetGenderByLegacyGender(aiLegacyGender))
EndFunction

bool Function IsBlankKey(int aiKey) global
  return Math.RightShift(aiKey, 31)
EndFunction

bool Function IsVictim(int aiKey) global
  return Math.LogicalAnd(aiKey, 65536) ; 1 << 16
EndFunction

bool Function IsMale(int aiKey) global
  return Math.LogicalAnd(aiKey, 2)
EndFunction

bool Function IsFemalePure(int aiKey) global
  return Math.LogicalAnd(aiKey, 0xFF) == 1
EndFunction

bool Function IsFemale(int aiKey) global
  return Math.LogicalAnd(aiKey, 1)
EndFunction

bool Function IsFuta(int aiKey) global
  return Math.LogicalAnd(aiKey, 4)
EndFunction

bool Function IsCreature(int aiKey) global
  return Math.LogicalAnd(aiKey, 24)
EndFunction

bool Function IsMaleCreature(int aiKey) global
  return Math.LogicalAnd(aiKey, 16)
EndFunction

bool Function IsFemaleCreature(int aiKey) global
  return Math.LogicalAnd(aiKey, 8)
EndFunction

int Function GetRawKey_Creature(int aiKey) global
  return Math.LogicalAND(Math.RightShift(aiKey, 8), 0xFF)
EndFunction

int Function GetRawKey_Gender(int aiKey) global
  return Math.LogicalAND(aiKey, 0xFF)
EndFunction

String Function GetRaceKeyByKey(int aiKey) global
  int idx = GetRawKey_Creature(aiKey)
  If(idx > 0)
    return GetAllRaceKeys()[idx - 1]
  EndIf
  return "human"
EndFunction

int Function GetRaceKeyId(String asRaceKey) global
  return GetAllRaceKeys().Find(asRaceKey)
EndFunction

; No docs on what sslCreatureAnimationSlots.GetRaceKeys() does so I just gotta improvise for the time being, sigh...
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
  String[] other = sslCreatureAnimationSlots.GetAllRaceKeys()
  Debug.Trace("[SLPP] GetAllCreatureKeys => " + other + " | Is same as ret = " + (ret == other))
  return ret
EndFunction
