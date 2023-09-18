scriptname sslThreadController extends sslThreadModel
{
	Controller script to recognize player actions (hotkey inputs etc) to manually interact with scene logic
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

Message Property RepositionInfoMsg Auto
{[Ok, Cancel, Don't show again]}

sslActorAlias AdjustAlias		; The actor currently selected for position adjustments
bool _SkipHotkeyEvents

int[] Hotkeys
int Property kAdvanceAnimation = 0 AutoReadOnly
int Property kChangeAnimation  = 1 AutoReadOnly
int Property kChangePositions  = 2 AutoReadOnly
int Property kAdjustChange     = 3 AutoReadOnly
int Property kAdjustForward    = 4 AutoReadOnly
int Property kAdjustSideways   = 5 AutoReadOnly
int Property kAdjustUpward     = 6 AutoReadOnly
int Property kRealignActors    = 7 AutoReadOnly
int Property kRestoreOffsets   = 8 AutoReadOnly
int Property kMoveScene        = 9 AutoReadOnly
int Property kRotateScene      = 10 AutoReadOnly
int Property kEndAnimation     = 11 AutoReadOnly
int Property kAdjustSchlong    = 12 AutoReadOnly

Function EnableHotkeys(bool forced = false)
	If(!HasPlayer && !forced)
		return
	EndIf
	Hotkeys = new int[13]
	Hotkeys[kAdvanceAnimation] = Config.AdvanceAnimation
	Hotkeys[kChangeAnimation] = Config.ChangeAnimation
	Hotkeys[kChangePositions] = Config.ChangePositions
	Hotkeys[kAdjustSideways] = Config.AdjustSideways
	Hotkeys[kRestoreOffsets] = Config.RestoreOffsets
	Hotkeys[kAdjustForward] = Config.AdjustForward
	Hotkeys[kRealignActors] = Config.RealignActors
	Hotkeys[kAdjustSchlong] = Config.AdjustSchlong
	Hotkeys[kAdjustUpward] = Config.AdjustUpward
	Hotkeys[kAdjustChange] = Config.AdjustChange
	Hotkeys[kEndAnimation] = Config.EndAnimation
	Hotkeys[kRotateScene] = Config.RotateScene
	Hotkeys[kMoveScene] = Config.MoveScene
	int i = 0
	While(i < Hotkeys.Length)
		RegisterForKey(Hotkeys[i])
		i += 1
	Endwhile
EndFunction
	
Event OnKeyDown(int KeyCode)
	If(Utility.IsInMenuMode() || _SkipHotkeyEvents)
		return
	EndIf
	_SkipHotkeyEvents = true
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
	ElseIf(hotkey == kChangePositions)	; Change Positions
		ChangePositions()
	ElseIf(hotkey == kRestoreOffsets)		; Reset animation offsets
		RestoreOffsets()
	ElseIf(hotkey == kMoveScene)
		MoveScene()
	ElseIf(hotkey == kEndAnimation)
		If(Config.BackwardsPressed())
			Config.ThreadSlots.StopAll()
		Else
			EndAnimation()
		EndIf
	EndIf
	_SkipHotkeyEvents = false
EndEvent

Function DisableHotkeys()
	UnregisterForAllKeys()
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
	String newScene
	If (!Config.AdjustStagePressed())	; Forward/Backward
		newScene = Scenes[sslUtility.IndexTravel(Animations.Find(Animation), Animations.Length, backwards)]
	Else	; Random
		int current = Animations.Find(Animation)
		int r = Utility.RandomInt(0, Animations.Length - 1)
		While(r == current)
			r = Utility.RandomInt(0, Animations.Length - 1)
		EndWhile
		newScene = Scenes[r]
	EndIf
	Log("Changing running scene from " + GetActiveScene() + " to " + newScene)
	SendThreadEvent("AnimationChange")
	ResetScene(newScene)
EndFunction

Function AdjustForward(bool backwards = false, bool AdjustStage = false)
	UnregisterforUpdate()
	float Amount = 0.5 - (backwards as float)
	int AdjustPos = GetAdjustPos()
	bool first_pass = true
	While(true)
		PlayHotkeyFX(0, backwards)
		Animation.AdjustForward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
		AdjustAlias.RefreshLoc()
		Utility.Wait(0.03)
		If(!Input.IsKeyPressed(Hotkeys[kAdjustForward]))
			RegisterForSingleUpdate(0.2)
			return
		ElseIf (first_pass)
			first_pass = false
			Utility.Wait(0.4)
		EndIf
	EndWhile
EndFunction

Function AdjustSideways(bool backwards = false, bool AdjustStage = false)
	UnregisterforUpdate()
	int AdjustPos = GetAdjustPos()
	float Amount = 0.5 - (backwards as float)
	bool first_pass = true
	While(true)
		PlayHotkeyFX(0, backwards)
		Animation.AdjustSideways(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
		RealignActors()
		Utility.Wait(0.03)
		If(!Input.IsKeyPressed(Hotkeys[kAdjustSideways]))
			RegisterForSingleUpdate(0.2)
			return
		ElseIf (first_pass)
			first_pass = false
			Utility.Wait(0.4)
		EndIf
	EndWhile
EndFunction

Function AdjustUpward(bool backwards = false, bool AdjustStage = false)
	UnregisterforUpdate()
	int AdjustPos = GetAdjustPos()
	float Amount = 0.5 - (backwards as float)
	bool first_pass = true
	While(true) 
		PlayHotkeyFX(2, backwards)
		Animation.AdjustUpward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
		RealignActors()
		Utility.Wait(0.03)
		If(!Input.IsKeyPressed(Hotkeys[kAdjustUpward]))
			RegisterForSingleUpdate(0.2)
			return
		ElseIf (first_pass)
			first_pass = false
			Utility.Wait(0.4)
		EndIf
	EndWhile
EndFunction

Function RotateScene(bool backwards = false)
	UnregisterForUpdate()
	float Amount = 15.0
	If(Config.IsAdjustStagePressed())
		Amount = 180.0
	EndIf
	Amount = (-1 * backwards as float) * Amount
	bool first_pass = true
	While(true)
		PlayHotkeyFX(1, !backwards)
		CenterLocation[5] = CenterLocation[5] + Amount
		If(CenterLocation[5] >= 360.0)
			CenterLocation[5] = CenterLocation[5] - 360.0
		ElseIf(CenterLocation[5] < 0.0)
			CenterLocation[5] = CenterLocation[5] + 360.0
		EndIf
		CenterOnCoords(CenterLocation[0], CenterLocation[1], CenterLocation[2], 0, 0, CenterLocation[5], true)
		Utility.Wait(0.03)
		If(!Input.IsKeyPressed(Hotkeys[kRotateScene]))
			RegisterForSingleUpdate(0.2)
			return
		ElseIf (first_pass)
			first_pass = false
			Utility.Wait(0.4)
		EndIf
	EndWhile
EndFunction

Function AdjustSchlong(bool backwards = false)
	int Amount  = ((0.5 - (backwards as float)) * 2) as int
	int AdjustPos = GetAdjustPos()
	int Schlong = Animation.GetSchlong(AdjustKey, AdjustPos, Stage) + Amount
	If(Math.Abs(Schlong) <= 9)
		Animation.AdjustSchlong(AdjustKey, AdjustPos, Stage, Amount)
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
	If (StorageUtil.GetIntValue(none, "SEXLAB_REPOSITIONMSG_INFO", 0) == 0)
		; "You have 30 secs to position yourself to a new center location.\nHold down the 'Move Scene' hotkey to relocate the center instantly to your current position"
		int choice = RepositionInfoMsg.Show()
		If (choice == 1)
			return
		ElseIf (choice == 2)
			StorageUtil.SetIntValue(none, "SEXLAB_REPOSITIONMSG_INFO", 1)
		EndIf
	EndIf
	; Make sure the player cannot activate anything, change worldspaces or start combat on their own
	Game.DisablePlayerControls(false, true, false, false, true)
	sslActorAlias PlayerSlot = ActorAlias(PlayerRef)
	int n = 0
	While(n < Positions.Length)
		If(ActorAlias[n] == PlayerSlot)
			ActorAlias[n].TryUnlock()
		Else
			ActorAlias[n].SendDefaultAnimEvent(true)
		EndIf
		n += 1
	EndWhile
	Utility.Wait(1)
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
		PlayerSlot.LockActor()
	EndIf
	Game.EnablePlayerControls()		; placing doesnt interact with player controls
	CenterOnObject(PlayerRef)			; Will re-register the update loop
EndFunction

Function ChangePositions(bool backwards = false)
	If(Positions.Length < 2)
		return
	EndIf
	String activeScene = GetActiveScene()
	int pos = GetAdjustPos()
	int i = pos + 1
	While(i < Positions.Length + pos)
		If(i >= Positions.Length)
			i -= Positions.Length
		EndIf
		If(SexLabRegistry.IsSimilarPosition(activeScene, pos, i))
			Actor tmpAct = Positions[pos]
			Positions[pos] = Positions[i]
			Positions[i] = tmpAct

			sslActorAlias tmpAli = ActorAlias[pos]
			ActorAlias[pos] = ActorAlias[i]
			ActorAlias[i] = tmpAli

			SendThreadEvent("PositionChange")
			ResetStage()
			return
		EndIf
		i += 1
	EndWhile
	Debug.Notification("Selected actor cannot switch positions")
EndFunction

Function PlayHotkeyFX(int i, bool backwards)
	if backwards
		Config.HotkeyDown[i].Play(PlayerRef)
	else
		Config.HotkeyUp[i].Play(PlayerRef)
	endIf
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
