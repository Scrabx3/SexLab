scriptname sslBaseObject extends ReferenceAlias hidden

int Property SlotID Auto Hidden
string Property Name Auto Hidden
bool Property Enabled Auto Hidden

string Property Registry Auto Hidden
bool Property Registered hidden
	bool Function get()
		return Registry != ""
	EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;

string[] Tags
string[] function GetTags()
	return PapyrusUtil.ClearEmpty(Tags)
endFunction

; Check if this BaseObject matches the given tag boundaries
; Supports prefixes: [~A, ~B] = A or B | [-A] = not A
; Ex: [A, ~B, ~C, -D] == true <=> Object has A, does not have D and has at least C or B
bool Function MatchTags(String[] asTags)
	return sslpp.MatchTags(Tags, asTags)
EndFunction

bool Function HasTag(string Tag)
	return Tags.Find(Tag) != -1
EndFunction

bool function AddTag(string Tag)
	if Tag != "" && Tags.Find(Tag) == -1
		Tags = PapyrusUtil.PushString(Tags, Tag)
		return true
	endIf
	return false
endFunction

bool function RemoveTag(string Tag)
	if Tag != "" && Tags.Find(Tag) != -1
		Tags = PapyrusUtil.RemoveString(Tags, Tag)
		return true
	endIf
	return false
endFunction

function AddTags(string[] TagList)
	int i = TagList.Length
	while i
		i -= 1
		AddTag(TagList[i])
	endWhile
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;        ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗            ;
;        ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║            ;
;        ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║            ;
;        ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║            ;
;        ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗       ;
;        ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝       ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

sslSystemConfig Property Config Auto Hidden

string function Key(string type = "")
	return Registry+"."+type
endFunction

function Log(string Log, string Type = "NOTICE")
	Log = Type+" "+Registry+" - "+Log
	if Config.DebugMode
		SexLabUtil.PrintConsole(Log)
	endIf
	Debug.Trace("SEXLAB - "+Log)
endFunction

bool bSaved = false
bool Property Saved hidden
	bool function get()
		return bSaved
	endFunction
endProperty
function Save(int id = -1)
	bSaved = true
	SlotID = id
	; Trim tags
	int i = Tags.Find("")
	if i != -1
		Tags = Utility.ResizeStringArray(Tags, (i + 1))
	endIf
endFunction

function Initialize()
	if !Config
		Config = Game.GetFormFromFile(0xD62, "SexLab.esm") as sslSystemConfig
	endIf
	Name     = ""
	Registry = ""
	SlotID   = -1
	Enabled  = false
	bSaved   = false
	Tags     = Utility.CreateStringArray(0)
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	;
;																																											;
;									██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗									;
;									██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝									;
;									██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 									;
;									██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  									;
;									███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   									;
;									╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   									;
;																																											;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*	;

string[] function GetRawTags()
	return GetTags()
endFunction

; Below functions are technically fine to use
; Most are legacy because their usage is ambiguous or go too complicated for basic access & manipulation

bool function CheckTags(string[] CheckTags, bool RequireAll = true, bool Suppress = false)
	bool Valid = ParseTags(CheckTags, RequireAll)
	return (Valid && !Suppress) || (!Valid && Suppress)
endFunction

bool function ParseTags(string[] TagList, bool RequireAll = true)
	return (RequireAll && HasAllTag(TagList)) || (!RequireAll && HasOneTag(TagList))
endFunction

bool function TagSearch(string[] TagList, string[] Suppress, bool RequireAll)
	return ((RequireAll && HasAllTag(TagList)) || (!RequireAll && HasOneTag(TagList))) \ 
		&& (!Suppress || !HasOneTag(Suppress))
endFunction

bool function HasOneTag(string[] TagList)
	int i = TagList.Length
	while i
		i -= 1
		if TagList[i] != "" && Tags.Find(TagList[i]) != -1
			return true
		endIf
	endWhile
	return false
endFunction

bool function HasAllTag(string[] TagList)
	return sslpp.MatchTags(Tags, TagList)
endFunction

bool function AddTagConditional(string Tag, bool AddTag)
	If(AddTag)
		return AddTag(Tag)
	Else
		return RemoveTag(Tag)
	EndIf
endFunction

function SetTags(string TagList)
	AddTags(PapyrusUtil.StringSplit(TagList))
endFunction

bool function ToggleTag(string Tag)
	return (RemoveTag(Tag) || AddTag(Tag)) && HasTag(Tag)
endFunction

Form Property Storage = none Auto Hidden
bool Property Ephemeral hidden
	bool function get()
		return Storage != none
	endFunction
endProperty

function MakeEphemeral(string Token, Form OwnerForm)
	Initialize()
	Enabled   = true
	Registry  = Token
	Storage   = OwnerForm
	Log("Created Non-Global Object '"+Token+"'", Storage)
endFunction
