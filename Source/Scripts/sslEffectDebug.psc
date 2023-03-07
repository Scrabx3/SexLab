Scriptname sslEffectDebug extends ActiveMagicEffect

import PapyrusUtil

SexLabFramework property SexLab auto
sslSystemConfig property Config auto
Actor property PlayerRef auto

Actor Ref1
Actor Ref2

float scale1
float scale2

string ActorName
ObjectReference MarkerRef

sslBenchmark function Benchmark(int Tests = 1, int Iterations = 5000, int Loops = 10, bool UseBaseLoop = false)
	return (Quest.GetQuest("SexLabDev") as sslBenchmark).StartBenchmark(Tests, Iterations, Loops, UseBaseLoop)
endFunction




; GlobalVariable TimeScale
; float TimeStart
; float TimeEnd
event OnEffectStart(Actor TargetRef, Actor CasterRef)
	SexLab.QuickStart(CasterRef, TargetRef)
	; TargetRef.SetDontMove(true)
	; Actor[] p = new Actor[2]
	; p[0] = CasterRef
	; p[1] = TargetRef
	; float[] o = new float[8]

	; Form xMarker = Game.GetForm(0x3B)
	; ObjectReference center = CasterRef.PlaceAtMe(xMarker, 1)
	; TargetRef.SetVehicle(center)
	; CasterRef.SetVehicle(center)

	; ; sslpp.SetPositionsEx(p, center, o)

	; Utility.Wait(10)

	; TargetRef.SetVehicle(none)
	; CasterRef.SetVehicle(none)
	; Debug.Notification("Vehicle cleared")

	; Form carriage = Game.GetForm(0x75C16)
	; ObjectReference vehicle = CasterRef.PlaceAtMe(carriage, 1, false, true)
	; vehicle.MoveTo(CasterRef, 500.0)
	; vehicle.Enable()

	; CasterRef.SetVehicle(vehicle)

	; Idle sway = Game.GetForm(0x106AE3) as Idle
	; CasterRef.PlayIdle(sway)

	; Idle Reset = Game.GetForm(0xE6538) as Idle
	; CasterRef.PlayIdle(Reset)

	; Form UmbraBossQuest = Game.GetFormFromFile(0xBFC, "ccbgssse016-umbra.esm")
	; Log("UmbraBossQuest: "+UmbraBossQuest)
	; Form Lurker = Game.GetFormFromFile(0x817, "ccpewsse002-armsofchaos.esl")
	; Log("Lurker: "+Lurker)

	; StorageUtil.SetFormValue(UmbraBossQuest, "test1", Lurker)
	; Log("Test 1: "+StorageUtil.GetFormValue(UmbraBossQuest, "test1"))

	; StorageUtil.SetFormValue(Lurker, "test2", UmbraBossQuest)
	; Log("Test 2: "+StorageUtil.GetFormValue(Lurker, "test2"))

	; StorageUtil.FormListAdd(None, "test3", UmbraBossQuest, false)
	; StorageUtil.FormListAdd(None, "test3", Lurker, false)
	; StorageUtil.FormListAdd(None, "test3", SexLab, false)
	; StorageUtil.FormListAdd(None, "test3", TargetRef, false)
	; StorageUtil.FormListAdd(None, "test3", none, false)
	; form[] listtest = StorageUtil.FormListToArray(None, "test3")
	; Log("Test 3: "+listtest)

	; int cleaned = StorageUtil.debug_Cleanup()
	; Log("Cleaned: "+cleaned)

	; MiscUtil.ToggleFreeCamera()

	; Log("Result: "+TestList2)

	; TimeScale = Game.GetFormFromFile(0x3A, "Skyrim.esm") as GlobalVariable
	; TimeStart = SexLabUtil.GetCurrentGameRealTime()
	; TimeEnd = TimeStart + 5.0

	; Log("TimeScale: "+(TimeScale.GetValue() as float))
	; Log("TimeStart: "+TimeStart)
	; Log("TimeEnd: "+TimeEnd)

	; Log("Timer Start!")

	; RegisterForSingleUpdate(0.1)


	; Log("GetCurrentRealTime: "+Utility.GetCurrentRealTime())
	; Log("GetCurrentGameTime: "+Utility.GetCurrentGameTime())
	; Log("GetCurrentGameRealTime: "+SexLabUtil.GetCurrentGameRealTime())


	Dispel()
endEvent

event OnUpdate()
	;/ float CurrentTime = SexLabUtil.GetCurrentGameRealTime()
	if CurrentTime < TimeEnd
		; Log("Timer Continues!\n\t - CurrentTime: "+CurrentTime+"\n\t - TimeStart: "+TimeStart+"\n\t - TimeEnd: "+TimeEnd)
		RegisterForSingleUpdate(0.1)
	else
		float Overage = (TimeEnd - CurrentTime)
		Log("Timer End!\n\t - CurrentTime: "+CurrentTime+"\n\t - TimeStart: "+TimeStart+"\n\t - TimeEnd: "+TimeEnd+"\n\t - Overage: "+Overage)
		Debug.MessageBox("Timer End!\nOverage: "+Overage)
		Dispel()
	endIf/;
endEvent

event OnEffectFinish(Actor TargetRef, Actor CasterRef)
	if MarkerRef
		TargetRef.SetVehicle(none)
		MarkerRef.Disable()
		MarkerRef.Delete()
		MarkerRef = none
	endIf
	SexLabUtil.PrintConsole("---- DEBUG EFFECT FINISHED ----")
endEvent

;/-----------------------------------------------\;
;|	Debug Utility Functions                      |;
;\-----------------------------------------------/;

function Log(string log)
	; Debug.Notification(log)
	Debug.Trace(log)
	Debug.TraceUser("SexLabDebug", log)
	SexLabUtil.PrintConsole(log)
endfunction
