scriptname sslExpressionSlots extends Quest

sslExpressionDefaults property Defaults auto
sslExpressionLibrary property Lib auto

sslBaseExpression[] Slots
sslBaseExpression[] property Expression hidden
	sslBaseExpression[] function get()
		return Slots
	endFunction
endProperty

string[] registry
int property Slotted auto hidden

bool property FreeSlots hidden
	bool function get()
		return slotted < 40
	endFunction
endProperty

;/-----------------------------------------------\;
;|	Search Expression                            |;
;\-----------------------------------------------/;

sslBaseExpression function RandomByTag(string tag)
	int count
	; Get tagged count
	int i = slotted
	while i
		i -= 1
		count += Slots[i].HasTag(tag) as int
	endWhile
	if count == 0
		return none ; No valid slots found
	endIf
	; Determine random
	int random = Utility.RandomInt(1, count)
	; Get random
	i = slotted
	while i
		i -= 1
		if Slots[i].HasTag(tag)
			if random == count
				return Slots[i]
			endIf
			count -= 1
		endIf
	endWhile
	return none
endFunction

sslBaseExpression function GetByName(string findName)
	int i
	while i < slotted
		if Slots[i].Registered && Slots[i].name == findName
			return Slots[i]
		endIf
		i += 1
	endWhile
	return none
endFunction

sslBaseExpression function GetByTag(string tag1, string tag2 = "", string tagSuppress = "", bool requireAll = true)
	int i
	while i < slotted
		bool check1 = Slots[i].HasTag(tag1)
		bool check2 = Slots[i].HasTag(tag2)
		bool supress = Slots[i].HasTag(tagSuppress)
		if requireAll && check1 && (check2 || tag2 == "") && !(supress && tagSuppress != "")
			return Slots[i]
		elseif !requireAll && (check1 || check2) && !(supress && tagSuppress != "")
			return Slots[i]
		endIf
		i += 1
	endWhile
	return none
endFunction

sslBaseExpression function GetBySlot(int slot)
	return Slots[slot]
endFunction

;/-----------------------------------------------\;
;|	Locate Expressions                           |;
;\-----------------------------------------------/;

int function FindByName(string findName)
	int i
	while i < slotted
		if Slots[i].Registered && Slots[i].Name == findName
			return i
		endIf
		i += 1
	endWhile
	return -1
endFunction

int function FindByRegistrar(string registrar)
	return registry.Find(registrar)
endFunction

int function Find(sslBaseExpression findExpression)
	return Slots.Find(findExpression)
endFunction

;/-----------------------------------------------\;
;|	Manage Expressions                           |;
;\-----------------------------------------------/;

sslBaseExpression function GetFree()
	return Slots[slotted]
endFunction

int function Register(sslBaseExpression Claiming, string registrar)
	registry = sslUtility.PushString(registrar, registry)
	slotted = registry.Length
	Claiming.Initialize()
	return Slots.Find(Claiming)
endFunction

int function GetCount()
	return registry.Length
endFunction

;/-----------------------------------------------\;
;|	System Expressions                           |;
;\-----------------------------------------------/;

function _Setup()
	Slots = new sslBaseExpression[40]
	int i = 40
	while i
		i -= 1
		Slots[i] = GetNthAlias(i) as sslBaseExpression
		Slots[i].Initialize()
	endWhile
	Initialize()
	Defaults.LoadExpressions()
	SendModEvent("SexLabSlotExpressions")
	Debug.Notification("$SSL_NotifyExpressionInstall")
endFunction

function Initialize()
	string[] init
	registry = init
	Slotted = 0
endFunction
