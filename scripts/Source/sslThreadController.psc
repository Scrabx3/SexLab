scriptname sslThreadController extends sslThreadModel
{
	Class to access and write scene data
	Use the functions listed here to manipulate a running scene or retrieve data from it, to get a (valid) instance
	of this API use SexLabFramework.GetController(tid). The 'tid' or thread-id can be obtained through a variety of functions
	also found in the main API. It is also (and most commonly) accessed by listening to one of the various events invoked by a running thread

	Do NOT read or write a thread through any functions not listed here. There is no guarntee for backwards compatibility otherwise
	There is NEVER a reason to link to this via a direct property
}

; TODO: Add state-independent API

; ------------------------------------------------------- ;
; --- Animation End	                                  --- ;
; ------------------------------------------------------- ;

State Ending

	; TODO: Add API elements to ending scenes, eg "RestartScene(sslBaseAnimation)"

EndState

; ------------------------------------------------------- ;
; --- Animation Loop                                  --- ;
; ------------------------------------------------------- ;

State Animating

	; TODO: Add API elements to active Scenes

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

	; ------------------------------------------------------- ;
	; --- Hotkey functions                                --- ;
	; ------------------------------------------------------- ;

	Function AdvanceStage(bool backwards = false)
		If(!backwards)
			GoToStage(Stage + 1)
		Elseif(Config.IsAdjustStagePressed())
			GoToStage(1)
		ElseIf(Stage > 1)
			GoToStage(Stage - 1)
		EndIf
	EndFunction

	Function ChangeAnimation(bool backwards = false)
		If(Animations.Length <= 1)
			return
		EndIf
		UnregisterForUpdate()
		Log("Changing Animation")
		If(!Config.AdjustStagePressed())	; Forward/Backward
			SetAnimation(sslUtility.IndexTravel(Animations.Find(Animation), Animations.Length, backwards))
		Else	; Random
			int current = Animations.Find(Animation)
			int r = Utility.RandomInt(0, Animations.Length - 1)
			While(r == current)
				r = Utility.RandomInt(0, Animations.Length - 1)
			EndWhile
			SetAnimation(r)
		endIf
		SendThreadEvent("AnimationChange")
		RegisterForSingleUpdate(0.2)
	EndFunction
	
	Function AdjustForward(bool backwards = false, bool AdjustStage = false)
		UnregisterforUpdate()
		float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
		int AdjustPos = GetAdjustPos()
		While(true)
			PlayHotkeyFX(0, backwards)
			Animation.AdjustForward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
			AdjustAlias.RefreshLoc()
			Utility.Wait(0.5)
			If(!Input.IsKeyPressed(Hotkeys[kAdjustForward]))
				RegisterForSingleUpdate(0.2)
				return
			EndIf
		EndWhile
	EndFunction

	Function AdjustSideways(bool backwards = false, bool AdjustStage = false)
		UnregisterforUpdate()
		int AdjustPos = GetAdjustPos()
		float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
		While(true)
			PlayHotkeyFX(0, backwards)
			Animation.AdjustSideways(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
			RealignActors()
			Utility.Wait(0.5)
			If(!Input.IsKeyPressed(Hotkeys[kAdjustSideways]))
				RegisterForSingleUpdate(0.2)
				return
			EndIf
		EndWhile
	EndFunction

	Function AdjustUpward(bool backwards = false, bool AdjustStage = false)
		UnregisterforUpdate()
		int AdjustPos = GetAdjustPos()
		float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
		While(true) 
			PlayHotkeyFX(2, backwards)
			Animation.AdjustUpward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
			RealignActors()
			Utility.Wait(0.5)
			If(!Input.IsKeyPressed(Hotkeys[kAdjustUpward]))
				RegisterForSingleUpdate(0.2)
				return
			EndIf
		EndWhile
	EndFunction

	Function RotateScene(bool backwards = false)
		UnregisterForUpdate()
		float Amount = 15.0
		If(Config.IsAdjustStagePressed())
			Amount = 180.0
		EndIf
		Amount = PapyrusUtil.SignFloat(backwards, Amount)
		While(true)	; Pseudo do-while loop
			PlayHotkeyFX(1, !backwards)
			CenterLocation[5] = CenterLocation[5] + Amount
			If(CenterLocation[5] >= 360.0)
				CenterLocation[5] = CenterLocation[5] - 360.0
			ElseIf(CenterLocation[5] < 0.0)
				CenterLocation[5] = CenterLocation[5] + 360.0
			EndIf
			CenterOnCoords(CenterLocation[0], CenterLocation[1], CenterLocation[2], 0, 0, CenterLocation[5], true)
			Utility.Wait(0.5)
			If(!Input.IsKeyPressed(Hotkeys[kRotateScene]))
				RegisterForSingleUpdate(0.2)
				return
			EndIf
		EndWhile
	EndFunction

	Function AdjustSchlong(bool backwards = false)
		int Amount  = PapyrusUtil.SignInt(backwards, 1)
		int AdjustPos = GetAdjustPos()
		int Schlong = Animation.GetSchlong(AdjustKey, AdjustPos, Stage) + Amount
		If(Math.Abs(Schlong) <= 9)
			Animation.AdjustSchlong(AdjustKey, AdjustPos, Stage, Amount)
			AdjustAlias.GetPositionInfo()
			Debug.SendAnimationEvent(Positions[AdjustPos], "SOSBend"+Schlong)
			PlayHotkeyFX(2, !backwards)
		EndIf
	EndFunction

	Function AdjustChange(bool backwards = false)
		If(Positions.Length <= 1)
			return
		EndIf
		int i = GetAdjustPos()
		i = sslUtility.IndexTravel(i, ActorCount, backwards)
		If(Positions[i] != PlayerRef)
			Config.TargetRef = Positions[i]
		EndIf
		AdjustAlias = ActorAlias[i]
		Config.SelectedSpell.Cast(Positions[i])	; SFX for visual feedback
		PlayHotkeyFX(0, !backwards)
		String msg = "Adjusting Position For: " + AdjustAlias.GetActorName()
		Debug.Notification(msg)
		SexLabUtil.PrintConsole(msg)
	EndFunction

	Function RestoreOffsets()
		Animation.RestoreOffsets(AdjustKey)
		RealignActors()
	EndFunction

	Function MoveScene()
		UnregisterForUpdate()
		; Processing Furnitures
		If(BedStatus[1])
			SetFurnitureIgnored(false)
		EndIf
		; Make sure the player cannot activate anything, change worldspaces or start combat on their own
		Game.DisablePlayerControls(false, true, false, false, true)
		sslActorAlias PlayerSlot = ActorAlias(PlayerRef)
		int n = 0
		While(n < Positions.Length)
			Debug.Trace("Resetting Actor: " + n)
			If(ActorAlias[n] == PlayerSlot)
				ActorAlias[n].UnplaceActor()
			Else
				ActorAlias[n].SendDefaultAnimEvent(true)
			EndIf
			n += 1
		EndWhile
		Utility.Wait(1)
		; TODO: Make some message objects to display here
		Debug.Messagebox("You have 30 secs to position yourself to a new center location.\nHold down the 'Move Scene' hotkey to relocate the center instantly to your current position")
		int i = 0
		While(i < 60 && !Input.IsKeyPressed(Hotkeys[kMoveScene]))
			Utility.Wait(0.5)
			i += 1
		EndWhile
		Game.DisablePlayerControls()	; make sure player isnt moving before resync
		float x = PlayerRef.X
		float y = PlayerRef.Y
		float z = PlayerRef.Z
		Utility.Wait(0.5)							; wait for momentum to stop
		While(x != PlayerRef.X || y != PlayerRef.Y || z != PlayerRef.Z)
			x = PlayerRef.X
			y = PlayerRef.Y
			z = PlayerRef.Z
			Utility.Wait(0.5)
		EndWhile
		If(PlayerSlot)
			PlayerSlot.PlaceActor(GetRealCenter())
		EndIf
		If(BedStatus[1] >= 2)					; Bed or DoubleBled
			CenterOnBedEx(false, 300.0, true)
		Else
			CenterOnObject(PlayerRef, true)
		EndIf
		Game.EnablePlayerControls()		; placing doesnt interact with player controls
		GoToStage(1)									; Will re-register the update loop
	EndFunction

	Event OnKeyDown(int KeyCode)
		If(Utility.IsInMenuMode() || _HOTKEYLOCK)
			Log("Input while locked. Skipping ...")
			return
		EndIf
		_HOTKEYLOCK = true
		int hotkey = Hotkeys.Find(KeyCode)
		If(hotkey == kAdvanceAnimation)
			AdvanceStage(Config.BackwardsPressed())
		ElseIf(hotkey == kChangeAnimation)
			ChangeAnimation(Config.BackwardsPressed())
		ElseIf(hotkey == kAdjustForward)
			AdjustForward(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf(hotkey == kAdjustUpward)
			AdjustUpward(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf(hotkey == kAdjustSideways)
			AdjustSideways(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf(hotkey == kRotateScene)
			RotateScene(Config.BackwardsPressed())
		ElseIf(hotkey == kAdjustSchlong)
			AdjustSchlong(Config.BackwardsPressed())
		ElseIf(hotkey == kAdjustChange)			; Change Adjusting Position
			AdjustChange(Config.BackwardsPressed())
		ElseIf(hotkey == kRealignActors)
			RealignActors()
		; ElseIf(hotkey == kChangePositions)	; Change Positions
		; 	ChangePositions(Config.BackwardsPressed())
		ElseIf(hotkey == kRestoreOffsets)		; Restore animation offsets
			RestoreOffsets()
		ElseIf(hotkey == kMoveScene)
			MoveScene()
		ElseIf(hotkey == kEndAnimation)
			If(Config.BackwardsPressed())
				Config.ThreadSlots.StopAll()
			Else
				EndAnimation()
			EndIf
			return
		EndIf
		_HOTKEYLOCK = false
	endEvent
endState

; ------------------------------------------------------- ;
; --- Hotkeys								                          --- ;
; ------------------------------------------------------- ;

; Adjustment hotkeys
sslActorAlias AdjustAlias		; The actor currently selected for position adjustments

bool _HOTKEYLOCK
int[] Hotkeys
int property kAdvanceAnimation = 0  autoreadonly hidden
int property kChangeAnimation  = 1  autoreadonly hidden
int property kChangePositions  = 2  autoreadonly hidden
int property kAdjustChange     = 3  autoreadonly hidden
int property kAdjustForward    = 4  autoreadonly hidden
int property kAdjustSideways   = 5  autoreadonly hidden
int property kAdjustUpward     = 6  autoreadonly hidden
int property kRealignActors    = 7  autoreadonly hidden
int property kRestoreOffsets   = 8  autoreadonly hidden
int property kMoveScene        = 9  autoreadonly hidden
int property kRotateScene      = 10 autoreadonly hidden
int property kEndAnimation     = 11 autoreadonly hidden
int property kAdjustSchlong    = 12 autoreadonly hidden

Function EnableHotkeys(bool forced = false)
	If(HasPlayer || forced)
		_HOTKEYLOCK = true
		Hotkeys = new int[13]
		Hotkeys[kAdvanceAnimation] = Config.AdvanceAnimation
		Hotkeys[kChangeAnimation]  = Config.ChangeAnimation
		Hotkeys[kChangePositions]  = Config.ChangePositions
		Hotkeys[kAdjustChange]     = Config.AdjustChange
		Hotkeys[kAdjustForward]    = Config.AdjustForward
		Hotkeys[kAdjustSideways]   = Config.AdjustSideways
		Hotkeys[kAdjustUpward]     = Config.AdjustUpward
		Hotkeys[kRealignActors]    = Config.RealignActors
		Hotkeys[kRestoreOffsets]   = Config.RestoreOffsets
		Hotkeys[kMoveScene]        = Config.MoveScene
		Hotkeys[kRotateScene]      = Config.RotateScene
		Hotkeys[kEndAnimation]     = Config.EndAnimation
		Hotkeys[kAdjustSchlong]    = Config.AdjustSchlong
		int i
		while i < Hotkeys.Length
			RegisterForKey(Hotkeys[i])
			i += 1
		endwhile
		_HOTKEYLOCK = false
	EndIf
EndFunction

Function DisableHotkeys()
	UnregisterForAllKeys()
EndFunction

Function Initialize()
	Config.DisableThreadControl(self)
	DisableHotkeys()
	AdjustAlias = ActorAlias[0]
	parent.Initialize()
EndFunction

int Function GetAdjustPos()
	int AdjustPos = -1
	if AdjustAlias && AdjustAlias.ActorRef
		AdjustPos = Positions.Find(AdjustAlias.ActorRef)
	endIf
	if AdjustPos == -1 && Config.TargetRef
		AdjustPos = Positions.Find(Config.TargetRef)
	endIf
	if AdjustPos == -1
		AdjustPos = (ActorCount > 1) as int
	endIf
	if Positions[AdjustPos] != PlayerRef
		Config.TargetRef = Positions[AdjustPos]
	endIf
	AdjustAlias = PositionAlias(AdjustPos)
	return AdjustPos
EndFunction

Function PlayHotkeyFX(int i, bool backwards)
	if backwards
		Config.HotkeyDown[i].Play(PlayerRef)
	else
		Config.HotkeyUp[i].Play(PlayerRef)
	endIf
EndFunction

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; State Animating
Function AdvanceStage(bool backwards = false)
EndFunction
Function ChangeAnimation(bool backwards = false)
EndFunction
Function AdjustForward(bool backwards = false, bool AdjustStage = false)
EndFunction
Function AdjustSideways(bool backwards = false, bool AdjustStage = false)
EndFunction
Function AdjustUpward(bool backwards = false, bool AdjustStage = false)
EndFunction
Function RotateScene(bool backwards = false)
EndFunction
Function AdjustSchlong(bool backwards = false)
EndFunction
Function AdjustChange(bool backwards = false)
EndFunction
Function RestoreOffsets()
EndFunction
Function MoveScene()
EndFunction
Function MoveActors()
EndFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;								██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗							;
;								██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝							;
;								██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 							;
;								██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  							;
;								███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   							;
;								╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   							;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

Function ChangePositions(bool backwards = false)
EndFunction
; TODO: This here should only allow a swap between same gender positions
; Function ChangePositions(bool backwards = false)
; 	if ActorCount < 2 || HasCreature
; 		return ; Solo/Creature Animation, nobody to swap with
; 	endIf
; 	UnregisterforUpdate()
; 	; GoToState("")
; 	; Find position to swap to
; 	int AdjustPos = GetAdjustPos()
; 	int NewPos = sslUtility.IndexTravel(AdjustPos, ActorCount, backwards)
; 	Actor AdjustActor = Positions[AdjustPos]
; 	Actor MovedActor  = Positions[NewPos]
; 	if MovedActor == AdjustActor
; 		Log("MovedActor["+NewPos+"] == AdjustActor["+AdjustPos+"] -- "+Positions, "ChangePositions() Error")
; 		RegisterForSingleUpdate(0.2)
; 		return
; 	endIf
; 	; Shuffle actor positions
; 	Positions[AdjustPos] = MovedActor
; 	Positions[NewPos] = AdjustActor
; 	; New adjustment profile
; 	; UpdateActorKey()
; 	UpdateAdjustKey()
; 	Log(AdjustKey, "Adjustment Profile")
; 	; Sync new positions
; 	AdjustPos = NewPos
; 	; GoToState("Animating")
; 	ResetPositions()
; 	SendThreadEvent("PositionChange")
; 	RegisterForSingleUpdate(1.0)
; EndFunction

float Function GetAnimationRunTime()
	return Animation.GetTimersRunTime(Timers)
EndFunction

Function ResetPositions()
	RealignActors()
EndFunction

ObjectReference Function GetCenterFX()
	if CenterRef != none && CenterRef.Is3DLoaded()
		return CenterRef
	else
		int i = 0
		while i < ActorCount
			if Positions[i] != none && Positions[i].Is3DLoaded()
				return Positions[i]
			endIf
			i += 1
		endWhile
	endIf
EndFunction

State Prepare
	Event FireAction()
		LogRedundant("FireAction")
	EndEvent
	Event PrepareDone()
		LogRedundant("PrepareDone")
	EndEvent
	Event StartupDone()
		LogRedundant("StartupDone")
	EndEvent

	Function PlayStageAnimations()
	EndFunction
	Function RecordSkills()
	EndFunction
	Function SetBonuses()
	EndFunction
EndState

state Refresh
	Function RefreshDone()
		LogRedundant("RefreshDone")
	EndFunction
endState
