ScriptName sslActorKey Hidden
{ Fancy bitflag magic to store actor data }

;/ Bit flags are defined as follows:
0  - Female
1  - Male
2  - Futa
3  - FCr
4  - MCr
5  - Pad6
6  - Prefer as Victim
7  - Pad8
8  - CreatureType Bit  0 - 1
9  - CreatureType Bit  2 - 3
10 - CreatureType Bit  4 - 7
11 - CreatureType Bit  8 - 15
12 - CreatureType Bit 16 - 31
13 - CreatureType Bit 32 - 63
14 - Pad15
15 - Pad16
16 - Pad17
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

; This might be worth putting into a dll solely due to how much it might get called
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

int[] Function BuildActorKeyArray(Actor[] akActors, int aiVictimIdx) global
  int[] ret = Utility.CreateIntArray(akActors.Length)
  int i = 0
  While(i < akActors.Length)
    ret[i] = BuildActorKey(akActors[i], i == aiVictimIdx)
    i += 1
  EndWhile
  return ret
EndFunction

int[] Function BuildSortedActorKeyArray(Actor[] akActors, int aiVictimIdx) global
  int[] ret = BuildActorKeyArray(akActors, aiVictimIdx)
  ; TODO: sort ret
  return ret
EndFunction

int Function GetLegacyGenderByGender(int a_gender) global
  If(Math.LogicalAnd(a_gender, 5))       ; Female | Futa
    return 1
  ElseIf(Math.LogicalAnd(a_gender, 2))   ; Male
    return 0
  ElseIf(Math.LogicalAnd(a_gender, 8))   ; FCr
    return 3
  ElseIf(Math.LogicalAnd(a_gender, 16))  ; MCr
    return 2
  EndIf
EndFunction

int Function GetGenderByLegacyGender(int a_legacygender) global
  If(a_legacygender == 0)
    return 2
  ElseIf(a_legacygender == 1)
    ; IDEA: If HasSchlong() return 5
    return 1
  ElseIf(a_legacygender == 2)
    return 8
  ElseIf(a_legacygender == 3)
    return 16
  EndIf
  return 2
EndFunction

int Function AddGenderToKey(int a_key, int a_gender) global
  return Math.LogicalOr(a_gender, a_key)
EndFunction

int Function AddLegacyGenderToKey(int a_key, int a_legacygender) global
  return AddGenderToKey(a_key, GetGenderByLegacyGender(a_legacygender))
EndFunction

bool Function IsMale(int a_key) global
  return Math.LogicalAnd(a_key, 2)
EndFunction

bool Function IsFemale(int a_key) global
  return Math.LogicalAnd(a_key, 1)
EndFunction

bool Function IsFuta(int a_key) global
  return Math.LogicalAnd(a_key, 4)
EndFunction

bool Function IsCreature(int a_key) global
  return Math.LogicalAnd(a_key, 24)
EndFunction

bool Function IsMaleCreature(int a_key) global
  return Math.LogicalAnd(a_key, 16)
EndFunction

bool Function IsFemaleCreature(int a_key) global
  return Math.LogicalAnd(a_key, 8)
EndFunction


String Function GetRaceKey(int a_key) global
  int raceidx = Math.RightShift(a_key, 8)
  ; TODO: switch(raceidx) case 0: Human case 2: Draugr case 3: ...
  ; best to predefine them in some array and just get the [raceidx]'th entry
  return "human"
EndFunction
