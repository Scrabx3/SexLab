scriptname sslAnimationSlots extends Quest
{
  Legacy Animation Registry Base Script
  Use SexLabRegistry.psc instead
}

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;               ██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗              ;
;               ██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝              ;
;               ██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝               ;
;               ██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝                ;
;               ███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║                 ;
;               ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝                 ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

int Function GetAllocatedSize() native

int property Slotted
  int Function Get()
    return GetAllocatedSize()
  EndFunction
  Function Set(int aSet)
  EndFunction
EndProperty

Actor Property PlayerRef
  Actor Function Get()
    return Game.GetPlayer()
  EndFunction
  Function Set(Actor aSet)
  EndFunction
EndProperty
sslSystemConfig property Config
  sslSystemConfig Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslSystemConfig
  EndFunction
  Function Set(sslSystemConfig aSet)
  EndFunction
EndProperty
sslActorLibrary property ActorLib
  sslActorLibrary Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslActorLibrary
  EndFunction
  Function Set(sslActorLibrary aSet)
  EndFunction
EndProperty
sslThreadLibrary property ThreadLib
  sslThreadLibrary Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslThreadLibrary
  EndFunction
  Function Set(sslThreadLibrary aSet)
  EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Animation Filtering                             --- ;
; ------------------------------------------------------- ;

ReferenceAlias[] Function GetByTagsImpl(int aiActorCount, String[] asTags) native
ReferenceAlias[] Function GetByTypeImpl(int aiActorCount, int aiMales, int aiFemales, String[] asTags) native
ReferenceAlias[] Function PickByActorsImpl(Actor[] akActors, String[] asTags) native

String[] Function MergeSplitTags(String asTags, String asTagsSuppress, bool abRequireAll)
  String[] ret1 = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(asTags, ","))
  String[] ret2 = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(asTagsSuppress, ","))
  If (ret1.Length + ret2.Length == 0)
    return Utility.CreateStringArray(0)
  EndIf
  If (!abRequireAll)
    int i = 0
    While (i < ret1.Length)
      ret1[i] = "~" + ret1[i]
      i += 1
    EndWhile
  EndIf
  int n = 0
  While (n < ret2.Length)
    ret2[n] = "-" + ret2[n]
    n += 1
  EndWhile
  If (ret1.Length && ret2.Length)
    return PapyrusUtil.MergeStringArray(ret1, ret2, true)
  ElseIf(ret1.Length)
    return ret1
  Else
    return ret2
  EndIf
EndFunction

sslBaseAnimation[] Function AsBaseAnimation(ReferenceAlias[] akReferences)
  sslBaseAnimation[] ret = sslUtility.AnimationArray(akReferences.Length)
  int i = 0
  While (i < ret.Length)
    ret[i] = akReferences[i] as sslBaseAnimation
    i += 1
  EndWhile
  return ret
EndFunction

sslBaseAnimation[] Function GetByTags(int ActorCount, string Tags, string TagsSuppressed = "", bool RequireAll = true)
  return AsBaseAnimation(GetByTagsImpl(ActorCount, MergeSplitTags(Tags, TagsSuppressed, RequireAll)))
EndFunction

sslBaseAnimation[] function GetByCommonTags(int ActorCount, string CommonTags, string Tags, string TagsSuppressed = "", bool RequireAll = true)
  String[] common = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(CommonTags, ","))
  String[] tags_ = PapyrusUtil.MergeStringArray(common, MergeSplitTags(Tags, TagsSuppressed, RequireAll), true)
  return AsBaseAnimation(GetByTagsImpl(ActorCount, tags_))
endFunction

; NOTE: StageCount is ignored as its no longer applicable to the new scene graph system
sslBaseAnimation[] function GetByType(int ActorCount, int Males = -1, int Females = -1, int StageCount = -1, bool Aggressive = false, bool Sexual = true)
  String[] tags = new String[2]
  tags[0] = "Forced"
  tags[1] = "LeadIn"
  If (!Config.RestrictAggressive)
    tags[0] = ""
  ElseIf (!Aggressive)
    tags[0] = "-Forced"
  EndIf
  If (Sexual)
    tags[1] = "-LeadIn"
  Else
    tags[1] = "LeadIn"
  EndIf
  return AsBaseAnimation(GetByTypeImpl(ActorCount, Males, Females, PapyrusUtil.ClearEmpty(tags)))
endFunction

sslBaseAnimation[] function PickByActors(Actor[] Positions, int Limit = 64, bool Aggressive = false)
  String[] tags
  If (Config.RestrictAggressive)
    tags = new String[1]
    If (Aggressive)
      tags[0] = "Forced"
    Else
      tags[0] = "-Forced"
    EndIf
  EndIf
  return AsBaseAnimation(PickByActorsImpl(Positions, tags))
endFunction

sslBaseAnimation[] function GetByDefault(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true)
  return GetByDefaultTags(Males, Females, IsAggressive, UsingBed, RestrictAggressive, "")
endFunction

sslBaseAnimation[] function GetByDefaultTags(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true, string Tags, string TagsSuppressed = "", bool RequireAll = true)
  If (Males < 0 || Females < 0 || Males + Females == 0)
    ; Will throw a error on the log with the same format as other errors :shrug:
    return GetByType(-1)
  EndIf
  String[] tags_ = MergeSplitTags(Tags, TagsSuppressed, RequireAll)
  If (IsAggressive && !RestrictAggressive)
    tags_ = PapyrusUtil.PushString(tags_, "Forced")
  ElseIf(RestrictAggressive)
    tags_ = PapyrusUtil.PushString(tags_, "-Forced")
  EndIf
  If (UsingBed)
    int where = tags_.Find("Furniture")
    If (where == -1)
      tags_.Find("~Furniture")
    EndIf
    If (where == -1)
      tags_ = PapyrusUtil.PushString(tags_, "-Furniture")
    Else
      tags_[where] = "-Furniture"
    EndIf
    where = tags_.Find("Standing")
    If (where == -1)
      tags_.Find("~Standing")
    EndIf
    If (where == -1)
      tags_ = PapyrusUtil.PushString(tags_, "-Standing")
    Else
      tags_[where] = "-Standing"
    EndIf
  Else
    int where = tags_.Find("BedOnly")
    If (where == -1)
      tags_.Find("~BedOnly")
    EndIf
    If (where == -1)
      tags_ = PapyrusUtil.PushString(tags_, "-BedOnly")
    Else
      tags_[where] = "-BedOnly"
    EndIf
  EndIf
  return AsBaseAnimation(GetByTypeImpl(Males + Females, Males, Females, PapyrusUtil.ClearEmpty(tags_)))
EndFunction

; ------------------------------------------------------- ;
; --- Registry Access                                     ;
; ------------------------------------------------------- ;

sslBaseAnimation Function GetBySlot(int index)
  Alias[] aliases = GetAliases()
  If (index < 0 || aliases.Length <= index)
    return none
  EndIf
  return aliases[index] as sslBaseAnimation
EndFunction

sslBaseAnimation function GetByName(string FindName)
  return GetBySlot(FindByName(FindName))
endFunction

sslBaseAnimation function GetbyRegistrar(string Registrar)
  return GetBySlot(FindByRegistrar(Registrar))
endFunction

int function FindByRegistrar(string Registrar)
  Alias[] aliases = GetAliases()
  int i = 0
  While (i < aliases.Length)
    sslBaseAnimation item = aliases[i] as sslBaseAnimation
    If (item.PROXY_ID == Registrar)
      return i
    EndIf
    i += 1
  EndWhile
  return -1
endFunction

int function FindByName(string FindName)
  Alias[] aliases = GetAliases()
  int i = 0
  While (i < aliases.Length)
    sslBaseAnimation item = aliases[i] as sslBaseAnimation
    If (item.Name == FindName)
      return i
    EndIf
    i += 1
  EndWhile
  return -1
endFunction

bool function IsRegistered(string Registrar)
  return FindByRegistrar(Registrar) != -1
endFunction

; ------------------------------------------------------- ;
; --- Object Utilities                                --- ;
; ------------------------------------------------------- ;

sslBaseAnimation[] function GetList(bool[] Valid)
  sslBaseAnimation[] Output
  if Valid && Valid.Length > 0 && Valid.Find(true) != -1
    int n = Valid.Find(true)
    int i = PapyrusUtil.CountBool(Valid, true)
    ; Trim over 100 to random selection
    if i > 125
      int end = Valid.RFind(true) - 1
      while i > 125
        int rand = Valid.Find(true, Utility.RandomInt(n, end))
        if rand != -1 && Valid[rand]
          Valid[rand] = false
          i -= 1
        endIf
        if i == 126 ; To be sure only 125 stay
          i = PapyrusUtil.CountBool(Valid, true)
          n = Valid.Find(true)
          end = Valid.RFind(true) - 1
        endIf
      endWhile
    endIf
    ; Get list
    int allocated = GetAllocatedSize()
    Output = sslUtility.AnimationArray(i)
    while n != -1 && i > 0
      i -= 1
      sslBaseAnimation tmp = GetBySlot(n)
      If (tmp)
        Output[i] = tmp
        n += 1
        if n < allocated
          n = Valid.Find(true, n)
        else
          n = -1
        endIf
      EndIf
    endWhile
  endIf
  return Output
endFunction

string[] function GetNames(sslBaseAnimation[] SlotList)
  int i = SlotList.Length
  string[] Names = Utility.CreateStringArray(i)
  while i
    i -= 1
    if SlotList[i]
      Names[i] = SlotList[i].Name
    endIf
  endWhile
  if Names.Find("") != -1
    Names = PapyrusUtil.RemoveString(Names, "")
  endIf
  return Names
endFunction

int function CountTag(sslBaseAnimation[] Anims, string Tags)
  string[] Checking = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
  if Checking.Length == 0
    return 0
  endIf
  int count
  int i = Anims.Length
  while i
    i -= 1
    count += Anims[i].HasOneTag(Checking) as int
  endWhile
  return count
endFunction

int function GetCount(bool IgnoreDisabled = true)
  if !IgnoreDisabled
    return GetAllocatedSize()
  endIf
  int Count
  int i = GetAllocatedSize()
  while i
    i -= 1
    Count += ((GetBySlot(i) && GetBySlot(i).Enabled) as int)
  endWhile
  return Count
endFunction

int function FindFirstTagged(string Tags, bool IgnoreDisabled = true, bool Reverse = false)
  string[] Checking = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
  if Checking.Length == 0
    return -1
  endIf
  int count
  int i = 0
  if !Reverse 
    i = GetAllocatedSize()
  endIf
  while (i && !Reverse) || (Reverse && i < GetAllocatedSize())
    if !Reverse 
      i -= 1
    endIf
    sslBaseAnimation tmp = GetBySlot(i)
    if tmp
      if ((tmp.Enabled || !IgnoreDisabled) && tmp.HasAllTag(Checking))
        return i
      endIf
    endIf
    if Reverse 
      i += 1
    endIf
  endWhile
  return -1
endFunction

int function CountTagUsage(string Tags, bool IgnoreDisabled = true)
  string[] Checking = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
  if Checking.Length == 0
    return 0
  endIf
  int count
  int i = GetAllocatedSize()
  while i
    i -= 1
    sslBaseAnimation tmp = GetBySlot(i)
    if tmp
      count += ((tmp.Enabled || !IgnoreDisabled) && tmp.HasAllTag(Checking)) as int
    endIf
  endWhile
  return count
endfunction

string[] function GetAllTags(int ActorCount = -1, bool IgnoreDisabled = true)
  IgnoreDisabled = !IgnoreDisabled
  string[] Output
  int i = GetAllocatedSize()
  while i
    i -= 1
    sslBaseAnimation tmp = GetBySlot(i)
    if tmp && (IgnoreDisabled || tmp.Enabled) && (ActorCount == -1 || tmp.PositionCount == ActorCount)
      Output = PapyrusUtil.MergeStringArray(Output, tmp.GetRawTags(), true)
    endIf
  endwhile
  return PapyrusUtil.RemoveString(PapyrusUtil.SortStringArray(Output), "")
endFunction

; ------------------------------------------------------- ;
; --- Cached Tag Search                                   ;
; ------------------------------------------------------- ;

function ClearAnimCache()
endFunction
bool function ValidateCache()
  return true
endFunction
bool function IsCached(string CacheName)
  return false
endFunction
sslBaseAnimation[] function CheckCache(string CacheName)
  sslBaseAnimation[] Output
  return Output
endFunction
function CacheAnims(string CacheName, sslBaseAnimation[] Anims)
endFunction
sslBaseAnimation[] function GetCacheSlot(int i)
  sslBaseAnimation[] ret
  return ret
endFunction
int function OldestCache()
  return 0
endFunction
function InvalidateByAnimation(sslBaseAnimation removing)
endFunction
function InvalidateByTags(string Tags)
endFunction
function InvalidateBySlot(int i)
endFunction
string function CacheInfo(int i)
  return ""
endfunction
function OutputCacheLog()
endFunction

; ------------------------------------------------------- ;
; --- Object MCM Pagination                               ;
; ------------------------------------------------------- ;

int function PageCount(int perpage = 125)
  return ((GetAllocatedSize() as float / perpage as float) as int) + 1
endFunction

int function FindPage(string Registrar, int perpage = 125)
  int i = FindByRegistrar(Registrar)
  if i != -1
    return ((i as float / perpage as float) as int) + 1
  endIf
  return -1
endFunction

string[] function GetSlotNames(int page = 1, int perpage = 125)
  return GetNames(GetSlots(page, perpage))
endfunction

sslBaseAnimation[] function GetSlots(int page = 1, int perpage = 125)
  perpage = PapyrusUtil.ClampInt(perpage, 1, 128)
  if page > PageCount(perpage) || page < 1
    return sslUtility.AnimationArray(0)
  endIf
  int n
  sslBaseAnimation[] PageSlots
  if page == PageCount(perpage)
    n = GetAllocatedSize()
    PageSlots = sslUtility.AnimationArray((GetAllocatedSize() - ((page - 1) * perpage)))
  else
    n = page * perpage
    PageSlots = sslUtility.AnimationArray(perpage)
  endIf
  int i = PageSlots.Length
  while i
    i -= 1
    n -= 1
    sslBaseanimation tmp = GetBySlot(n)
    if tmp
      PageSlots[i] = tmp
    endIf
  endWhile
  return PageSlots
endFunction

; ------------------------------------------------------- ;
; --- Object Registration                                 ;
; ------------------------------------------------------- ;

function RegisterSlots()
endFunction
int function Register(string Registrar)
  return -1
endFunction
sslBaseAnimation function RegisterAnimation(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
  return none
endFunction
bool function UnregisterAnimation(string Registrar)
  return false
endFunction
bool function IsSuppressed(string Registrar)
  return false
endFunction
function NeverRegister(string Registrar)
endFunction
function AllowRegister(string Registrar)
endFunction
int function ClearSuppressed()
  return 0
endFunction
int function GetDisabledCount()
  return 0
endFunction
int function GetSuppressedCount()
  return 0
endFunction
int function SuppressDisabled()
  return 0
endFunction
string[] function GetSuppressedList()
  return Utility.CreateStringArray(0)
endFunction
function PreloadCategoryLoaders()
endFunction

; ------------------------------------------------------- ;
; --- System Use Only                                 --- ;
; ------------------------------------------------------- ;

string property JLoaders
  String Function Get()
    String ret = "../SexLab/Animations/"
    if self == Config.CreatureSlots
      ret += "Creatures/"
    endIf
    return ret
  EndFunction
  Function Set(String aSet)
  EndFunction
EndProperty

function Setup()
endFunction

string property CacheID
  String Function Get()
    if self != Config.CreatureSlots
      return "SexLab.AnimationTags"
    Else
      return "SexLab.CreatureTags"
    endIf
  EndFunction
  Function Set(String aSet)
  EndFunction
EndProperty

string[] function GetTagCache(bool IgnoreCache = false)
  return Utility.CreateStringArray(0)
endFunction
bool function HasTagCache(string Tag ,bool IgnoreCache = false)
  return false
endFunction
function ClearTagCache()
endFunction
function DoCache()
endFunction

function Log(string msg)
  if Config.DebugMode
    MiscUtil.PrintConsole(msg)
    Debug.TraceUser("SexLabDebug", msg)
  endIf
  Debug.Trace("[SexLab] - "+msg)
endFunction

state Locked
  function Setup()
  endFunction
endState

bool function TestSlots()
  return true
endFunction

; ------------------------------------------------------- ;
; --- Legacy Use Only                                 --- ;
; ------------------------------------------------------- ;

sslBaseAnimation[] function RemoveTagged(sslBaseAnimation[] Anims, string Tags)
  return sslUtility.FilterTaggedAnimations(Anims, PapyrusUtil.StringSplit(Tags), false)
endFunction
sslBaseAnimation[] function MergeLists(sslBaseAnimation[] List1, sslBaseAnimation[] List2)
  return sslUtility.MergeAnimationLists(List1, List2)
endFunction
bool[] function FindTagged(sslBaseAnimation[] Anims, string Tags)
  return sslUtility.FindTaggedAnimations(Anims, PapyrusUtil.StringSplit(Tags))
endFunction

