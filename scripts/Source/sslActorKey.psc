ScriptName sslActorKey Hidden
{ Fancy bitflag magic to store actor data }



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
/;

; NOTE: This might be worth defining within a dll solely due to how much it might get called
; its one of the most important functions in this new architecture design
int Function BuildActorKey(Actor akActor, bool abPreferVictim) global
  int genderid ; TODO: getgender()
  int raceidx ; TODO: getracekeyidx()
  int ret = Math.LogicalOr(raceidx, genderid)
  If(abPreferVictim)
    ret += 64
  EndIf
  return ret
EndFunction

; This is just a wrapper in case the key is ever expanded with some set bit as default
int Function BuildBlankKeyByLegacyGender(int aiLegacyGender) global
  return GetGenderByLegacyGender(aiLegacyGender)
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

int[] Function SortActorKeyArray(int[] aiKeys) global
  int i = 0
	While(i < aiKeys.Length)
		int it = aiKeys[i]
		int n = i - 1
		While(n && !IsLesserKey(aiKeys[n], it))
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

int Function GetLegacyGenderByGender(int aiGender) global
  If(Math.LogicalAnd(aiGender, 5))       ; Female | Futa
    return 1
  ElseIf(Math.LogicalAnd(aiGender, 2))   ; Male
    return 0
  ElseIf(Math.LogicalAnd(aiGender, 8))   ; FCr
    return 3
  ElseIf(Math.LogicalAnd(aiGender, 16))  ; MCr
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

int Function AddGenderToKey(int aiKey, int aiGender) global
  return Math.LogicalOr(aiGender, aiKey)
EndFunction

int Function AddLegacyGenderToKey(int aiKey, int aiLegacyGender) global
  return AddGenderToKey(aiKey, GetGenderByLegacyGender(aiLegacyGender))
EndFunction

bool Function IsVictim(int aiKey) global
  return Math.LogicalAnd(aiKey, 65536) ; 1 << 16
EndFunction

bool Function IsMale(int aiKey) global
  return Math.LogicalAnd(aiKey, 2)
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

String Function GetRaceKey(int aiKey) global
  int raceidx = GetRawKey_Creature(aiKey)
  ; TODO: switch(raceidx) case 0: Human case 2: Draugr case 3: ...
  ; best to predefine them in some array and just get the [raceidx]'th entry
  return "human"
EndFunction
