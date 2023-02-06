scriptname sslThreadSlots extends Quest
{
	Internal Script to maintain and access SexLab threads
	You should NOT be interacting with this Script directly. Use the main API instead
}

SexLabFramework property SexLab auto
sslThreadController[] property Threads Auto

; ------------------------------------------------------- ;
; --- Thread Access 	                                --- ;
; ------------------------------------------------------- ;

sslThreadModel function PickModel(float TimeOut = 5.0)
	if SexLab.GetState() == "Disabled"
		SexLabUtil.DebugLog("Failed to start new thread - SexLab is currently disabled.", "PickModel", true)
		return none
	endIf
	float failsafe = Utility.GetCurrentRealTime() + TimeOut
	while GetState() == "Locked" && Utility.GetCurrentRealTime() < failsafe
		Utility.WaitMenuMode(0.1)
	endWhile
	GoToState("Locked")
	sslThreadModel Thread
	int i
	while !Thread && i < Threads.Length
		if !Threads[i].IsLocked
			Thread = Threads[i].Make()
		endIf
		i += 1
	endWhile
	; Failsafe - check for possibly stuck/ending threads and use them.
	if !Thread
		i = 0
		while !Thread && i < Threads.Length
			string ThreadState = Threads[i].GetState()
			if ThreadState == "Ending"
				Threads[i].ReportAndFail("Resetting possibly stuck thread: "+Threads[i], "PickModel")
				Thread = Threads[i].Make()
			endIf
			i += 1
		endWhile
	endIf
	GoToState("")
	return Thread
endFunction

sslThreadController function GetController(int tid)
	return Threads[tid]
endfunction

int function FindActorController(Actor ActorRef)
	int i = 0
	While(i < Threads.Length)
		If(Threads[i].FindSlot(ActorRef) != -1)
			return i
		EndIf
		i += 1
	Endwhile
	return -1
endFunction

sslThreadController function GetActorController(Actor ActorRef)
	int i = FindActorController(ActorRef)
	If(i == -1)
		return none
	EndIf
	return GetController(i)
endFunction

bool function IsRunning()
	return ActiveThreads() > 0
endfunction

int function ActiveThreads()
	int c = 0
	int i = Threads.Length
	while i
		i -= 1
		c += Threads[i].IsLocked as int
	endwhile
	return c
endfunction

function StopAll()
	int i = Threads.Length
	while i
		i -= 1
		StopThread(Threads[i])
	endWhile
	ModEvent.Send(ModEvent.Create("SexLabStoppedActive"))
endFunction

function StopThread(sslThreadController Slot)
	string SlotState = Slot.GetState()
	if SlotState == "Making"
		; NOTE: This is bad. We might already have returned that the Animation starts successfully and are currently waiting for
		; the prepare actor events to finish or the code to create the animation is still running
		; ---
		; SexLabUtil.DebugLog("Making during StopAll - Initializing.", Slot, true)
		; Slot.Initialize()
	elseIf SlotState == "Ending"
		; NOTE: Will auto clear itself after Cooldown is done
		; ---
		; Slot.Initialize()
	elseIf SlotState != "Unlocked"
		SexLabUtil.DebugLog(SlotState+" during StopAll - EndAnimation.", Slot, true)
		Slot.EndAnimation(true)
	endIf
endFunction

; ------------------------------------------------------- ;
; --- Setup						                                --- ;
; ------------------------------------------------------- ;

Function Setup()
	GoToState("Locked")
	int i = 0
	While(i < Threads.Length)
		Threads[i].SetTID(i)
		i += 1
	EndWhile
	GoToState("")
EndFunction

bool function TestSlots()
	return true
endFunction

state Locked
	function Setup()
	endFunction
endState
