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


	; TODO: Review all these Hotkey Functions. Esp the ones moving the Scene
	; COMEBACK: For the time being leaving this disabled as I want to know how reliable the keys are and imrpove on them
	; Rather have people complain about it than leaving bugs in silently decaying unnoticed by me
	
	; Function AdjustForward(bool backwards = false, bool AdjustStage = false)
	; 	UnregisterforUpdate()
	; 	float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
	; 	Adjusted = true
	; 	PlayHotkeyFX(0, backwards)
	; 	int AdjustPos = GetAdjustPos()
	; 	Animation.AdjustForward(AdjustKey, AdjustPos, Stage, Amount, AdjustStage)
	; 	AdjustAlias.RefreshLoc()
	; 	int k = Config.AdjustForward
	; 	while Input.IsKeyPressed(k)
	; 		PlayHotkeyFX(0, backwards)
	; 		Animation.AdjustForward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
	; 		AdjustAlias.RefreshLoc()
	; 		Utility.Wait(0.5)
	; 	endWhile
	; 	RegisterForSingleUpdate(0.1)
	; EndFunction

	; Function AdjustSideways(bool backwards = false, bool AdjustStage = false)
	; 	UnregisterforUpdate()
	; 	float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
	; 	Adjusted = true
	; 	PlayHotkeyFX(0, backwards)
	; 	int AdjustPos = GetAdjustPos()
	; 	Animation.AdjustSideways(AdjustKey, AdjustPos, Stage, Amount, AdjustStage)
	; 	AdjustAlias.RefreshLoc()
	; 	int k = Config.AdjustSideways
	; 	while Input.IsKeyPressed(k)
	; 		PlayHotkeyFX(0, backwards)
	; 		Animation.AdjustSideways(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
	; 		AdjustAlias.RefreshLoc()
	; 		Utility.Wait(0.5)
	; 	endWhile
	; 	RegisterForSingleUpdate(0.1)
	; EndFunction

	; Function AdjustUpward(bool backwards = false, bool AdjustStage = false)
	; 	float Amount = PapyrusUtil.SignFloat(backwards, 0.50)
	; 	UnregisterforUpdate()
	; 	Adjusted = true
	; 	PlayHotkeyFX(2, backwards)
	; 	int AdjustPos = GetAdjustPos()
	; 	Animation.AdjustUpward(AdjustKey, AdjustPos, Stage, Amount, AdjustStage)
	; 	AdjustAlias.RefreshLoc()
	; 	int k = Config.AdjustUpward
	; 	while Input.IsKeyPressed(k)
	; 		PlayHotkeyFX(2, backwards)
	; 		Animation.AdjustUpward(AdjustKey, AdjustPos, Stage, Amount, Config.AdjustStagePressed())
	; 		AdjustAlias.RefreshLoc()
	; 		Utility.Wait(0.5)
	; 	endWhile
	; 	RegisterForSingleUpdate(0.1)
	; EndFunction

	; Function RotateScene(bool backwards = false)
	; 	UnregisterForUpdate()
	; 	float Amount = 15.0
	; 	if Config.IsAdjustStagePressed()
	; 		Amount = 180.0
	; 	endIf
	; 	Amount = PapyrusUtil.SignFloat(backwards, Amount)
	; 	PlayHotkeyFX(1, !backwards)
	; 	CenterLocation[5] = CenterLocation[5] + Amount
	; 	if CenterLocation[5] >= 360.0
	; 		CenterLocation[5] = CenterLocation[5] - 360.0
	; 	elseIf CenterLocation[5] < 0.0
	; 		CenterLocation[5] = CenterLocation[5] + 360.0
	; 	endIf
	; 	ActorAlias[0].RefreshLoc()
	; 	ActorAlias[1].RefreshLoc()
	; 	ActorAlias[2].RefreshLoc()
	; 	ActorAlias[3].RefreshLoc()
	; 	ActorAlias[4].RefreshLoc()
	; 	int k = Config.RotateScene
	; 	while Input.IsKeyPressed(k)
	; 		PlayHotkeyFX(1, !backwards)
	; 		if Config.IsAdjustStagePressed()
	; 			Amount = 180.0
	; 		else
	; 			Amount = 15.0
	; 		endIf
	; 		Amount = PapyrusUtil.SignFloat(backwards, Amount)
	; 		CenterLocation[5] = CenterLocation[5] + Amount
	; 		if CenterLocation[5] >= 360.0
	; 			CenterLocation[5] = CenterLocation[5] - 360.0
	; 		elseIf CenterLocation[5] < 0.0
	; 			CenterLocation[5] = CenterLocation[5] + 360.0
	; 		endIf
	; 		ActorAlias[0].RefreshLoc()
	; 		ActorAlias[1].RefreshLoc()
	; 		ActorAlias[2].RefreshLoc()
	; 		ActorAlias[3].RefreshLoc()
	; 		ActorAlias[4].RefreshLoc()
	; 		Utility.Wait(0.5)
	; 	endWhile
	; 	RegisterForSingleUpdate(0.2)
	; EndFunction

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

	; Function RestoreOffsets()
	; 	UnregisterForUpdate()
	; 	Animation.RestoreOffsets(AdjustKey)
	; 	RealignActors()
	; 	RegisterForSingleUpdate(0.2)
	; EndFunction

	; Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
	; 	parent.CenterOnObject(CenterOn, resync)
	; 	if resync
	; 		RealignActors()
	; 		SendThreadEvent("ActorsRelocated")
	; 	endIf
	; EndFunction

	; Function CenterOnCoords(float LocX = 0.0, float LocY = 0.0, float LocZ = 0.0, float RotX = 0.0, float RotY = 0.0, float RotZ = 0.0, bool resync = true)
	; 	parent.CenterOnCoords(LocX, LocY, LocZ, RotX, RotY, RotZ, resync)
	; 	if resync
	; 		RealignActors()
	; 		SendThreadEvent("ActorsRelocated")
	; 	endIf
	; EndFunction

	Function MoveScene()
		UnregisterForUpdate()
		; Processing Furnitures
		int PreFurnitureStatus = BedTypeID
		if UsingBed && CenterRef.IsActivationBlocked()
			SetFurnitureIgnored(false)
		endIf
		; Enable Controls
		sslActorAlias PlayerSlot = ActorAlias(PlayerRef)
		; COMEBACK: This is a tautology. Wouldnt be able to call this is ControlThread != self?
		If(Config.GetThreadControlled() == self || PlayerRef.IsInFaction(Config.AnimatingFaction) && PlayerRef.GetFactionRank(Config.AnimatingFaction) != 0)
			If(!PlayerSlot)
				; ... does this just act as a toggle here? instead of just using a simple bool toggle?
				Config.DisableThreadControl(self)
			EndIf
			; Allow everyone to move freely & make them follow the player
			UnplaceActors()
			CenterAlias.ForceRefTo(PlayerRef)
			PlayerRef.SetFactionRank(Config.AnimatingFaction, 0)
			int i = 0
			While(i < Positions.Length)
				ActorAlias[i].ActorRef.SetFactionRank(Config.AnimatingFaction, 2)
				ActorAlias[i].ActorRef.EvaluatePackage()
				i += 1
			EndWhile
			Debug.Notification("Player movement unlocked - repositioning scene in 30 seconds...")
			; Lock hotkeys and wait 30 seconds
			Utility.WaitMenuMode(1.0)
			; COMEBACK: There should be a better way to do this
			RegisterForKey(Hotkeys[kMoveScene])
			; Ready
			i = 28 ; Time to wait NOTE: It doesnt take 1 second to get here, we only wait 29 secs here wtf
			while i
				i -= 1
				Utility.Wait(1.0)
				if !PlayerRef.IsInFaction(Config.AnimatingFaction)
					PlayerRef.SetFactionRank(Config.AnimatingFaction, 0) ; In case some mod call ValidateActor function.
				endIf
			endWhile
		endIf
		
		if GetState() == "Animating" && PlayerRef.GetFactionRank(Config.AnimatingFaction) == 0
			Debug.Notification("Player movement locked - repositioning scene...")
			ApplyFade()
			; Disable Controls
			if PlayerSlot != none
				if PlayerRef.GetFurnitureReference() == none
					PlayerSlot.SendDefaultAnimEvent() ; Seems like the CenterRef don't change if PlayerRef is running
				endIf
				PlayerSlot.LockActor()
			else
				Config.GetThreadControl(self)
			endIf
			int i
			while i < ActorCount
				sslActorAlias ActorSlot = ActorAlias[i]
				if ActorSlot != none && ActorSlot != PlayerSlot
					ActorSlot.LockActor()
				endIf
				i += 1
			endWhile
			; Clear CenterAlias to avoid player repositioning to previous position
			if CenterAlias.GetReference() != none
				CenterAlias.TryToClear()
			endIf
			UnregisterForUpdate()
			; Give player time to settle incase airborne
			Utility.Wait(1.0)
			; Recenter on coords to avoid stager + resync animations
			if AreUsingFurniture(Positions) > 0
				CenterOnBed(false, 300.0)
			endIf
			Log("PreFurnitureStatus:"+PreFurnitureStatus+" BedTypeID:"+BedTypeID)
			if PreFurnitureStatus != BedTypeID || (PreFurnitureStatus > 0 && CenterAlias.GetReference() == none)
				ClearAnimations()
				if CenterAlias.GetReference() == none ;Is not longer using Furniture
					; Center on fallback choices
					if HasPlayer && !(PlayerRef.GetFurnitureReference() || PlayerRef.IsSwimming() || PlayerRef.IsFlying())
						CenterOnObject(PlayerRef, false)
					elseIf IsAggressive && !(VictimRef.GetFurnitureReference() || VictimRef.IsSwimming() || VictimRef.IsFlying())
						CenterOnObject(VictimRef, false)
					else
						i = 0
						while i < ActorCount
							if !(Positions[i].GetFurnitureReference() || Positions[i].IsSwimming() || Positions[i].IsFlying())
								CenterOnObject(Positions[i], false)
								i = ActorCount
							endIf
							i += 1
						endWhile
					endIf
					CenterOnObject(PlayerRef, false)
				endIf
				ChangeActors(Positions)
				SendThreadEvent("ActorsRelocated")
			elseIf CenterAlias.GetReference() != none ;Is using Furniture
				RealignActors()
				SendThreadEvent("ActorsRelocated")
			else
				CenterOnObject(PlayerRef, true)
			endIf
			; Return to animation loop
			ResetPositions()
		endIf
	EndFunction

	Event OnKeyDown(int KeyCode)
		If(Utility.IsInMenuMode())
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
		ElseIf (hotkey == kAdjustUpward)
			AdjustUpward(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf (hotkey == kAdjustSideways)
			AdjustSideways(Config.BackwardsPressed(), Config.AdjustStagePressed())
		ElseIf (hotkey == kRotateScene)
			RotateScene(Config.BackwardsPressed())
		ElseIf (hotkey == kAdjustSchlong)
			AdjustSchlong(Config.BackwardsPressed())
		ElseIf (hotkey == kAdjustChange)		; Change Adjusting Position
			AdjustChange(Config.BackwardsPressed())
		ElseIf hotkey == kRealignActors
			ResetPositions()
		ElseIf (hotkey == kChangePositions)	; Change Positions
			ChangePositions(Config.BackwardsPressed())
		ElseIf (hotkey == kRestoreOffsets)	; Restore animation offsets
			RestoreOffsets()
		ElseIf (hotkey == kMoveScene)
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

	Function ResetPositions()
		RealignActors()
	EndFunction
endState

; ------------------------------------------------------- ;
; --- Hotkeys								                          --- ;
; ------------------------------------------------------- ;

; Adjustment hotkeys
sslActorAlias AdjustAlias		; The actor currently selected for position adjustments
bool moving_scene

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
	moving_scene = false
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
Function ChangePositions(bool backwards = false)
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
Function GoToStage(int ToStage)
EndFunction
Function ResetPositions()
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
	Function ResetPositions()
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
	Function ResetPositions()
		LogRedundant("ResetPositions")
	EndFunction
endState
