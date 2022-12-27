scriptname sslThreadController extends sslThreadModel
{ Animation Thread Controller: Runs manipulation logic of thread based on information from model. Access only through functions; NEVER create a property directly to this. }

; TODO: SetFirstAnimation() - allow custom defined starter anims instead of random

; Adjustment hotkeys
sslActorAlias AdjustAlias		; COMEBACK: Adjustments will be remade from ground up, this will no longer be necessary
bool Adjusted								; COMEBACK: Idk why that here is even a thing. Its only set, never read

; TODO: Add state-independent API

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

	; TODO: Review all these Hotkey Functions. Esp the ones moving the Scene

	; Function AdvanceStage(bool backwards = false)
	; 	if !backwards
	; 		GoToStage((Stage + 1))
	; 	elseIf backwards && Stage > 1
	; 		if Config.IsAdjustStagePressed()
	; 			GoToStage(1)
	; 		else
	; 			GoToStage((Stage - 1))
	; 		endIf
	; 	endIf
	; EndFunction

	; Function ChangeAnimation(bool backwards = false)
	; 	if Animations.Length < 2
	; 		return ; Nothing to change
	; 	endIf
	; 	UnregisterForUpdate()
		
	; 	if !Config.AdjustStagePressed()
	; 		; Forward/Backward
	; 		SetAnimation(sslUtility.IndexTravel(Animations.Find(Animation), Animations.Length, backwards))
	; 	else
	; 		; Random
	; 		int current = Animations.Find(Animation)
	; 		int r = Utility.RandomInt(0, (Animations.Length - 1))
	; 		; Try to get something other than the current animation
	; 		if r == current
	; 			int tries = 10
	; 			while r == current && tries > 0
	; 				tries -= 1
	; 				r = Utility.RandomInt(0, (Animations.Length - 1))
	; 			endWhile
	; 		endIf
	; 		SetAnimation(r)
	; 	endIf

	; 	SendThreadEvent("AnimationChange")
	; 	RegisterForSingleUpdate(0.2)
	; EndFunction

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

	; Function AdjustSchlong(bool backwards = false)
	; 	int Amount  = PapyrusUtil.SignInt(backwards, 1)
	; 	int AdjustPos = GetAdjustPos()
	; 	int Schlong = Animation.GetSchlong(AdjustKey, AdjustPos, Stage) + Amount
	; 	if Math.Abs(Schlong) <= 9
	; 		Adjusted = true
	; 		Animation.AdjustSchlong(AdjustKey, AdjustPos, Stage, Amount)
	; 		AdjustAlias.GetPositionInfo()
	; 		Debug.SendAnimationEvent(Positions[AdjustPos], "SOSBend"+Schlong)
	; 		PlayHotkeyFX(2, !backwards)
	; 	endIf
	; EndFunction

	; Function AdjustChange(bool backwards = false)
	; 	UnregisterForUpdate()
	; 	if ActorCount > 1
	; 		int AdjustPos = GetAdjustPos()
	; 		AdjustPos = sslUtility.IndexTravel(AdjustPos, ActorCount, backwards)
	; 		if Positions[AdjustPos] != PlayerRef
	; 			Config.TargetRef = Positions[AdjustPos]
	; 		endIf
	; 		AdjustAlias = PositionAlias(AdjustPos)
	; 		Config.SelectedSpell.Cast(Positions[AdjustPos], Positions[AdjustPos])
	; 		PlayHotkeyFX(0, !backwards)
	; 		string msg = "Adjusting Position For: "+Positions[AdjustPos].GetLeveledActorBase().GetName()
	; 		Debug.Notification(msg)
	; 		SexLabUtil.PrintConsole(msg)
	; 	endIf
	; 	RegisterForSingleUpdate(0.2)
	; EndFunction

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

	; Function MoveScene()
	; 	; Stop animation loop
	; 	UnregisterForUpdate()
	; 	; Processing Furnitures
	; 	int PreFurnitureStatus = BedTypeID
	; 	if UsingBed && CenterRef.IsActivationBlocked()
	; 		SetFurnitureIgnored(false)
	; 	endIf
	; 	; Enable Controls
	; 	sslActorAlias PlayerSlot = ActorAlias(PlayerRef)
	; 	if Config.GetThreadControlled() == self || PlayerRef.IsInFaction(Config.AnimatingFaction) && PlayerRef.GetFactionRank(Config.AnimatingFaction) != 0
	; 		if PlayerSlot && PlayerSlot != none
	; 			PlayerSlot.UnlockActor()
	; 			PlayerSlot.StopAnimating(true)
	; 			PlayerRef.StopTranslation()
	; 		else
	; 			Config.DisableThreadControl(self)
	; 			PlayerRef.SetFactionRank(Config.AnimatingFaction, 0)
	; 		endIf
	; 		Debug.Notification("Player movement unlocked - repositioning scene in 30 seconds...")
	; 		UnregisterForUpdate()
	; 		int i
	; 		while i < ActorCount
	; 			sslActorAlias ActorSlot = ActorAlias[i]
	; 			if ActorSlot != none && ActorSlot != PlayerSlot
	; 				ActorSlot.UnlockActor()
	; 				ActorSlot.StopAnimating(true)
	; 				ActorSlot.ActorRef.SetFactionRank(Config.AnimatingFaction, 2)
	; 			endIf
	; 			i += 1
	; 		endWhile
			
	; 		CenterAlias.TryToClear()
	; 		CenterAlias.ForceRefTo(PlayerRef) ; Make them follow me

	; 		UnregisterForUpdate()
			
	; 		; Lock hotkeys and wait 30 seconds
	; 		Utility.WaitMenuMode(1.0)
	; 		RegisterForKey(Hotkeys[kMoveScene])
	; 		; Ready
	; 		i = 28 ; Time to wait
	; 		while i
	; 			i -= 1
	; 			Utility.Wait(1.0)
	; 			if !PlayerRef.IsInFaction(Config.AnimatingFaction)
	; 				PlayerRef.SetFactionRank(Config.AnimatingFaction, 0) ; In case some mod call ValidateActor function.
	; 			endIf
	; 		endWhile
	; 	endIf
	; 	if GetState() == "Animating" && PlayerRef.GetFactionRank(Config.AnimatingFaction) == 0
	; 		Debug.Notification("Player movement locked - repositioning scene...")
	; 		ApplyFade()
	; 		; Disable Controls
	; 		if PlayerSlot != none
	; 			if PlayerRef.GetFurnitureReference() == none
	; 				PlayerSlot.SendDefaultAnimEvent() ; Seems like the CenterRef don't change if PlayerRef is running
	; 			endIf
	; 			PlayerSlot.LockActor()
	; 		else
	; 			Config.GetThreadControl(self)
	; 		endIf
	; 		int i
	; 		while i < ActorCount
	; 			sslActorAlias ActorSlot = ActorAlias[i]
	; 			if ActorSlot != none && ActorSlot != PlayerSlot
	; 				ActorSlot.LockActor()
	; 			endIf
	; 			i += 1
	; 		endWhile
	; 		; Clear CenterAlias to avoid player repositioning to previous position
	; 		if CenterAlias.GetReference() != none
	; 			CenterAlias.TryToClear()
	; 		endIf
	; 		UnregisterForUpdate()
	; 		; Give player time to settle incase airborne
	; 		Utility.Wait(1.0)
	; 		; Recenter on coords to avoid stager + resync animations
	; 		if AreUsingFurniture(Positions) > 0
	; 			CenterOnBed(false, 300.0)
	; 		endIf
	; 		Log("PreFurnitureStatus:"+PreFurnitureStatus+" BedTypeID:"+BedTypeID)
	; 		if PreFurnitureStatus != BedTypeID || (PreFurnitureStatus > 0 && CenterAlias.GetReference() == none)
	; 			ClearAnimations()
	; 			if CenterAlias.GetReference() == none ;Is not longer using Furniture
	; 				; Center on fallback choices
	; 				if HasPlayer && !(PlayerRef.GetFurnitureReference() || PlayerRef.IsSwimming() || PlayerRef.IsFlying())
	; 					CenterOnObject(PlayerRef, false)
	; 				elseIf IsAggressive && !(VictimRef.GetFurnitureReference() || VictimRef.IsSwimming() || VictimRef.IsFlying())
	; 					CenterOnObject(VictimRef, false)
	; 				else
	; 					i = 0
	; 					while i < ActorCount
	; 						if !(Positions[i].GetFurnitureReference() || Positions[i].IsSwimming() || Positions[i].IsFlying())
	; 							CenterOnObject(Positions[i], false)
	; 							i = ActorCount
	; 						endIf
	; 						i += 1
	; 					endWhile
	; 				endIf
	; 				CenterOnObject(PlayerRef, false)
	; 			endIf
	; 			ChangeActors(Positions)
	; 			SendThreadEvent("ActorsRelocated")
	; 		elseIf CenterAlias.GetReference() != none ;Is using Furniture
	; 			RealignActors()
	; 			SendThreadEvent("ActorsRelocated")
	; 		else
	; 			CenterOnObject(PlayerRef, true)
	; 		endIf
	; 		; Return to animation loop
	; 		ResetPositions()
	; 	endIf
	; EndFunction

	event OnKeyDown(int KeyCode)
		; StateCheck()
		if !Utility.IsInMenuMode(); || UI.IsMenuOpen("Console") || UI.IsMenuOpen("Loading Menu")
			int i = Hotkeys.Find(KeyCode)
			; Advance Stage
			if i == kAdvanceAnimation
				UnregisterForKey(kAdvanceAnimation)
				AdvanceStage(Config.BackwardsPressed())
				RegisterForKey(kAdvanceAnimation)

			; Change Animation
			elseIf i == kChangeAnimation
				UnregisterForKey(kChangeAnimation)
				ChangeAnimation(Config.BackwardsPressed())
				RegisterForKey(kChangeAnimation)

			; Forward / Backward adjustments
			elseIf i == kAdjustForward
				UnregisterForKey(kAdjustForward)
				AdjustForward(Config.BackwardsPressed(), Config.AdjustStagePressed())
				RegisterForKey(kAdjustForward)

			; Up / Down adjustments
			elseIf i == kAdjustUpward
				UnregisterForKey(kAdjustUpward)
				AdjustUpward(Config.BackwardsPressed(), Config.AdjustStagePressed())
				RegisterForKey(kAdjustUpward)

			; Left / Right adjustments
			elseIf i == kAdjustSideways
				UnregisterForKey(kAdjustSideways)
				AdjustSideways(Config.BackwardsPressed(), Config.AdjustStagePressed())
				RegisterForKey(kAdjustSideways)

			; Rotate Scene
			elseIf i == kRotateScene
				UnregisterForKey(kRotateScene)
				RotateScene(Config.BackwardsPressed())
				RegisterForKey(kRotateScene)

			; Adjust schlong bend
			elseIf i == kAdjustSchlong
				UnregisterForKey(kAdjustSchlong)
				AdjustSchlong(Config.BackwardsPressed())
				RegisterForKey(kAdjustSchlong)

			; Change Adjusted Actor
			elseIf i == kAdjustChange
				UnregisterForKey(kAdjustChange)
				AdjustChange(Config.BackwardsPressed())
				RegisterForKey(kAdjustChange)

			; RePosition Actors
			elseIf i == kRealignActors
				UnregisterForKey(kRealignActors)
				ResetPositions()
				RegisterForKey(kRealignActors)

			; Change Positions
			elseIf i == kChangePositions
				UnregisterForKey(kChangePositions)
				ChangePositions(Config.BackwardsPressed())
				RegisterForKey(kChangePositions)

			; Restore animation offsets
			elseIf i == kRestoreOffsets
				UnregisterForKey(kRestoreOffsets)
				RestoreOffsets()
				RegisterForKey(kRestoreOffsets)

			; Move Scene
			elseIf i == kMoveScene
				MoveScene()

			; EndAnimation
			elseIf i == kEndAnimation
				UnregisterForKey(kEndAnimation)
				if Config.BackwardsPressed()
					; End all threads
					Config.ThreadSlots.StopAll()
				else
					; End only current thread
					EndAnimation(true)
				endIf
				RegisterForKey(kEndAnimation)
			endIf
		endIf
	endEvent

	; Function MoveActors()
	; 	int i = 0
	; 	While(i < Positions.Length)
	; 		ActorAlias[i].RefreshLoc()
	; 		i += 1
	; 	EndWhile
	; EndFunction

	; TODO: This shouldnt need to Sync, just call the SetPosition again with updated PosAdjust Data
	; Function RealignActors()
	; 	UnregisterForUpdate()
	; 	int i = 0
	; 	While(i < Positions.Length)
	; 		ActorAlias[i].SyncThread()
	; 		i += 1
	; 	EndWhile
	; 	RegisterForSingleUpdate(0.5)
	; EndFunction

	; Function ResetPositions()
	; 	UnregisterForUpdate()
	; 	ApplyFade()
	; 	GoToState("Refresh")
	; 	SyncEvent(kRefreshActor, 15.0)
	; EndFunction
endState

; ------------------------------------------------------- ;
; --- Context Sensitive Info                          --- ;
; ------------------------------------------------------- ;

float Function GetAnimationRunTime()
	return Animation.GetTimersRunTime(Timers)
EndFunction

Function EnableHotkeys(bool forced = false)
	if HasPlayer || forced
		; Prepare bound keys
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
		; Prepare soundfx
		HotkeyUp   = Config.HotkeyUp
		HotkeyDown = Config.HotkeyDown
	endIf
EndFunction

Function Initialize()
	Config.DisableThreadControl(self)
	DisableHotkeys()
	Adjusted    = false
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

; ------------------------------------------------------- ;
; --- Thread Events - SYSTEM USE ONLY                 --- ;
; ------------------------------------------------------- ;



; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

auto state Unlocked
	Function EndAnimation(bool Quickly = false)
	EndFunction
endState

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
Function RealignActors()
EndFunction
Function MoveActors()
EndFunction
Function GoToStage(int ToStage)
EndFunction
Function ResetPositions()
EndFunction

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

Sound[] HotkeyDown
Sound[] HotkeyUp
Function PlayHotkeyFX(int i, bool backwards)
	int AdjustPos = GetAdjustPos()
	if backwards
		HotkeyDown[i].Play(Positions[AdjustPos])
	else
		HotkeyUp[i].Play(Positions[AdjustPos])
	endIf
EndFunction

event OnKeyDown(int keyCode)
	; StateCheck()
endEvent

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

Function DisableHotkeys()
	UnregisterForAllKeys()
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
