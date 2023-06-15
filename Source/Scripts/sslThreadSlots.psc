ScriptName sslThreadSlots extends Quest
{
  Maintain and access SexLab threads
}

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

sslThreadController[] Property Threads Auto

; ------------------------------------------------------- ;
; --- Thread Access                                   --- ;
; ------------------------------------------------------- ;

State Ready
  sslThreadModel Function PickModel(float TimeOut = 5.0)
    GoToState("Locked")
    int i = 0
    While (i < Threads.Length)
      If (!Threads[i].IsLocked)
        GoToState("Ready")
        return Threads[i]
      EndIf
      i += 1
    EndWhile
    Debug.Trace("[SexLab] Unable to obtain new thread. All threads in locked State", 1)
    GoToState("Ready")
    return none
  EndFunction

  sslThreadController Function GetController(int tid)
    return Threads[tid]
  endfunction

  int Function FindActorController(Actor ActorRef)
    float f = 0
    int ret = -1
    int i = 0
    While (i < Threads.Length)
      If (Threads[i].FindSlot(ActorRef) != -1)
        ; An actor may be recognized in multiple threads if it is thrown into multiple scenes back to back
        ; To ensure this returns the most recent scene, check for active State or start time 
        String s = Threads[i].GetState()
        If (s == "Animating" || s == "Making")
          return i
        ElseIf (Threads[i].StartedAt > f)
          f = Threads[i].StartedAt
          ret = i
        EndIf
      EndIf
      i += 1
    Endwhile
    return ret
  EndFunction

  sslThreadController Function GetActorController(Actor ActorRef)
    int i = FindActorController(ActorRef)
    If (i == -1)
      return none
    EndIf
    return GetController(i)
  EndFunction

  int Function ActiveThreads()
    int c = 0
    int i = Threads.Length
    while i
      i -= 1
      c += Threads[i].IsLocked as int
    endwhile
    return c
  endfunction

  bool Function IsRunning()
    return ActiveThreads() > 0
  endfunction

  Function StopAll()
    int i = Threads.Length
    while i
      i -= 1
      StopThread(Threads[i])
    endWhile
    ModEvent.Send(ModEvent.Create("SexLabStoppedActive"))
  EndFunction

  Function StopThread(sslThreadController Slot)
    SexLabUtil.DebugLog("Force stop-request on thread + " + Slot + " during State " + Slot.GetState(), "", true)
    Slot.Initialize()
  EndFunction

  Function Setup()
    StopAll()
    GoToState("")
    Setup()
  EndFunction
EndState

sslThreadModel Function PickModel(float TimeOut = 5.0)
  return none
EndFunction
sslThreadController Function GetController(int tid)
  return none
endfunction
int Function FindActorController(Actor ActorRef)
  return -1
EndFunction
sslThreadController Function GetActorController(Actor ActorRef)
  return none
EndFunction
int Function ActiveThreads()
  return 0
endfunction
bool Function IsRunning()
  return false
endfunction
Function StopAll()
EndFunction
Function StopThread(sslThreadController Slot)
EndFunction

; ------------------------------------------------------- ;
; --- Setup                                            --- ;
; ------------------------------------------------------- ;

Event OnInit()
  If (!IsRunning())
    return
  EndIf
  Debug.MessageBox("Setting up sslThreadSlots.psc")
  Setup()
EndEvent

Function Setup()
  GoToState("Locked")
  If (!TestSlots())
    InstallSlots()
  Else
    int i = 0
    While (i < Threads.Length)
      Threads[i].SetTID(i)
      i += 1
    EndWhile
  EndIf
  GoToState("Ready")
EndFunction

bool Function TestSlots()
  return Threads.Length == 15 && Threads.Find(none) == -1
EndFunction
Function InstallSlots()
  int[] SlotFormID = new int[15]
  SlotFormID[0]  = 0x61EEF
  SlotFormID[1]  = 0x62452
  SlotFormID[2]  = 0x6C62C
  SlotFormID[3]  = 0x6C62D
  SlotFormID[4]  = 0x6C62E
  SlotFormID[5]  = 0x6C62F
  SlotFormID[6]  = 0x6C630
  SlotFormID[7]  = 0x6C631
  SlotFormID[8]  = 0x6C632
  SlotFormID[9]  = 0x6C633
  SlotFormID[10] = 0x6C634
  SlotFormID[11] = 0x6C635
  SlotFormID[12] = 0x6C636
  SlotFormID[13] = 0x6C637
  SlotFormID[14] = 0x6C638

  Threads = new sslThreadController[15]
  int i = 0
  While (i < Threads.Length)
    Threads[i] = Game.GetFormFromFile(SlotFormID[i], "SexLab.esm") as sslThreadController
    Threads[i].SetTID(i)
    i += 1
  EndWhile
EndFunction

State Locked
  Function Setup()
    While (GetState() == "Locked")
      Utility.WaitMenuMode(0.1)
    EndWhile
    Setup()
  EndFunction

  sslThreadModel Function PickModel(float TimeOut = 5.0)
    While (GetState() == "Locked")
      Utility.WaitMenuMode(0.1)
    EndWhile
    PickModel()
  EndFunction
EndState

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

sslSystemConfig Property Config
  sslSystemConfig Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as sslSystemConfig
  EndFunction
  Function Set(sslSystemConfig aSet)
  EndFunction
EndProperty

SexLabFramework Property SexLab
  SexLabFramework Function Get()
    return Game.GetFormFromFile(0xD62, "SexLab.esm") as SexLabFramework
  EndFunction
  Function Set(SexLabFramework aSet)
  EndFunction
EndProperty
