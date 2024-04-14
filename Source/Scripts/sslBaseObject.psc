scriptname sslBaseObject extends ReferenceAlias hidden

String _name
string Property Name
	String Function Get()
		return _GetName()
	EndFunction
	Function Set(String aSet)
		_SetName(aSet)
	EndFunction
EndProperty
String Function _GetName()
	return _name
EndFunction
Function _SetName(String aSet)
	_name = aSet
EndFunction

bool _enabled
bool Property Enabled
	bool Function Get()
		return _GetEnabled()
	EndFunction
	Function Set(bool aSet)
		_SetEnabled(aSet)
	EndFunction
EndProperty
bool Function _GetEnabled()
	return _enabled
EndFunction
Function _SetEnabled(bool aSet)
	_enabled
EndFunction

String _registryID
string Property Registry
	String Function Get()
		return _GetRegistryID()
	EndFunction
	Function Set(String asSet)
		_SetRegistryID(asSet)
	EndFunction
EndProperty
bool Property Registered hidden
	bool Function get()
		return Registry != ""
	EndFunction
EndProperty
String Function _GetRegistryID()
	return _registryID
EndFunction
Function _SetRegistryID(String asSet)
	_registryID = asSet
EndFunction

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;

String[] _Tags
string[] Property Tags Hidden
	String[] Function Get()
		return _GetTags()
	EndFunction
	Function Set(String[] asSet)
		_SetTags(asSet)
	EndFunction
EndProperty
String[] Function _GetTags()
	return _Tags
EndFunction
Function _SetTags(String[] asSet)
	_Tags = asSet
EndFunction

string[] function GetTags()
	return PapyrusUtil.ClearEmpty(Tags)
endFunction

bool Function HasTag(string Tag)
	return Tag && !Tags.Length || Tags.Find(Tag) != -1
EndFunction

bool function AddTag(string Tag)
	if Tag != "" && !Tags.Length || Tags.Find(Tag) == -1
		Tags = PapyrusUtil.PushString(Tags, Tag)
		return true
	endIf
	return false
endFunction

bool function RemoveTag(string Tag)
	if Tag != "" && !Tags.Length || Tags.Find(Tag) != -1
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

function Log(string Log, string Type = "NOTICE")
	Log = Type+" "+Registry+" - "+Log
	if Config.DebugMode
		SexLabUtil.PrintConsole(Log)
	endIf
	Debug.Trace("SEXLAB - "+Log)
endFunction

function Initialize()
	Config 	 = Game.GetFormFromFile(0xD62, "SexLab.esm") as sslSystemConfig
	Name     = ""
	Registry = ""
	Enabled  = false
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

int Property SlotID Hidden
	int Function Get()
		return -1
	EndFunction
EndProperty

bool Property Saved hidden
	bool function get()
		return true
	endFunction
endProperty
function Save(int id = -1)
endFunction

string function Key(string type = "")
	return Registry+"."+type
endFunction

string[] function GetRawTags()
	return GetTags()
endFunction

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
		if HasTag(TagList[i])
			return true
		endIf
	endWhile
	return false
endFunction

bool function HasAllTag(string[] TagList)
	int i = TagList.Length
	while i
		i -= 1
		if (!HasTag(TagList[i]))
			return false
		endIf
	endWhile
	return true
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
