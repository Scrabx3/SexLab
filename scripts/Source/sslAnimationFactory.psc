scriptname sslAnimationFactory extends Quest hidden

sslAnimationSlots property Slots auto hidden

; Gender Types
int property Male = 0 autoreadonly hidden
int property Female = 1 autoreadonly hidden
int property Creature = 2 autoreadonly hidden
int property CreatureMale = 2 autoreadonly hidden
int property CreatureFemale = 3 autoreadonly hidden
; Cum Types
int property Vaginal = 1 autoreadonly hidden
int property Oral = 2 autoreadonly hidden
int property Anal = 3 autoreadonly hidden
int property VaginalOral = 4 autoreadonly hidden
int property VaginalAnal = 5 autoreadonly hidden
int property OralAnal = 6 autoreadonly hidden
int property VaginalOralAnal = 7 autoreadonly hidden
; Content Types
int property Misc = 0 autoreadonly hidden
int property Sexual = 1 autoreadonly hidden
int property Foreplay = 2 autoreadonly hidden
; SFX Types
Sound property Squishing auto hidden
Sound property Sucking auto hidden
Sound property SexMix auto hidden
Sound property Squirting auto hidden

; ------------------------------------------------------- ;
; --- Registering Animations                          --- ;
; ------------------------------------------------------- ;

; Prepare the factory for use with the default animation slots
function PrepareFactory()
	sslAnimationSlots AnimSlots = Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationSlots
	if !Slots || Slots != AnimSlots
		Slots = AnimSlots
	endIf
	if !Squishing
		Squishing = Game.GetFormFromFile(0x65A31, "SexLab.esm") as Sound
	endIf
	if !Sucking
		Sucking   = Game.GetFormFromFile(0x65A32, "SexLab.esm") as Sound
	endIf
	if !SexMix
		SexMix    = Game.GetFormFromFile(0x65A33, "SexLab.esm") as Sound
	endIf
	if !Squirting
		Squirting = Game.GetFormFromFile(0x65A34, "SexLab.esm") as Sound
	endIf
endFunction

; Prepare the factory for use with the default creature animation slots
function PrepareFactoryCreatures()
	sslCreatureAnimationSlots AnimSlots = Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationSlots
	if !Slots || Slots != AnimSlots
		Slots = AnimSlots
	endIf
	if !Squishing
		Squishing = Game.GetFormFromFile(0x65A31, "SexLab.esm") as Sound
	endIf
	if !Sucking
		Sucking   = Game.GetFormFromFile(0x65A32, "SexLab.esm") as Sound
	endIf
	if !SexMix
		SexMix    = Game.GetFormFromFile(0x65A33, "SexLab.esm") as Sound
	endIf
	if !Squirting
		Squirting = Game.GetFormFromFile(0x65A34, "SexLab.esm") as Sound
	endIf
endFunction

; Send callback event to start registration
function RegisterAnimation(string Registrar)
	; Get free Animation slot
	int id = Slots.Register(Registrar)
	if id != -1
		; Init slot
		sslBaseAnimation Slot = Slots.GetBySlot(id)
		Slot.Initialize()
		Slot.Registry = Registrar
		Slot.Enabled  = true
		; Send load event
		RegisterForModEvent(Registrar, Registrar)
		int eid = ModEvent.Create(Registrar)
		ModEvent.PushInt(eid, id)
		ModEvent.Send(eid)
		; Utility.WaitMenuMode(0.2)
		; Debug.Trace("RegisterAnimation["+id+"] - Wait")
	endIf
endFunction

; Gets the Animation resource object for use in the callback, MUST be called at start of callback to get the appropiate resource
sslBaseAnimation function Create(int id)
	sslBaseAnimation Slot = Slots.GetbySlot(id)
	UnregisterForModEvent(Slot.Registry)
	return Slot
endFunction

function Initialize()
	PrepareFactory()
endfunction

;/function RegisterAutoLoads(bool RegisterCreatures = false)
	
	; string[] TMP = JsonUtil.JsonInFolder("../SexLab/Creatures")
	; Log("TEMP CHECK: "+TMP) 
	; string[] TMP2 = JsonUtil.JsonInFolder("../SexLab/Creatures/Missing")
	; Log("TEMP CHECK 2: "+TMP2) 
	; string[] TMP3 = JsonUtil.JsonInFolder("../SexLab")
	; Log("TEMP CHECK 3: "+TMP3) 

	string[] Files = JsonUtil.JsonInFolder("../SexLab/Animations")
	if !Files || Files.Length < 1
		return
	endIf
	int i = Files.Length
	Log("JSON Animation Files("+i+"): "+Files)
	while i
		i -= 1
		string File = "../SexLab/Animations/"+Files[i]
		string Registrar = StringUtil.Substring(Files[i], 0, (StringUtil.GetLength(Files[i]) - 5))
		Log("Checking: "+Registrar+" / "+File)



	endWhile

endFunction


function Log(string Log, string Type = "NOTICE")
	Log = Type+": "+Log
	SexLabUtil.PrintConsole(Log)
	Debug.TraceUser("SexLabDebug", Log)
	Debug.Trace("SEXLAB - "+Log)
endFunction/;