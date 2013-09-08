scriptname sslThreadController extends sslThreadModel
{ Animation Thread Controller: Runs manipulation logic of thread based on information from model. Access only through functions; NEVER create a property directly to this. }

;/-----------------------------------------------\;
;|	Primary Starter                              |;
;\-------------------Access only through functions; NEVER create a property directly to this.----------------------------/;

bool primed
bool scaled

sslThreadController function PrimeThread()
	if GetState() != "Making"
		return none
	endIf
	stage = 0
	sfx = new float[2]
	GotoState("Preparing")
	return self
endFunction

bool function ActorsReady()
	int i
	while i < ActorCount
		if ActorAlias(i).GetState() != "Ready"
			return false
		endIf
		i += 1
	endWhile
	return true
endFunction

state Preparing
	event OnBeginState()
		primed = true
		RegisterForSingleUpdate(0.15)
	endEvent
	event OnUpdate()
		if !primed
			return
		endIf
		primed = false
		; Set random starting animation
		SetAnimation()
		; Setup actors
		SendActorEvent("StartThread")

		; Wait for actors ready, or for 5 seconds to pass
		float failsafe = Utility.GetCurrentRealTime() + 5.0
		while !ActorsReady() && failsafe > Utility.GetCurrentRealTime()
			Utility.Wait(0.20)
		endWhile

		if IsPlayerPosition(AdjustingPosition) && ActorCount > 1
			AdjustingPosition = PositionWrap((AdjustingPosition + 1))
		endIf

		; RealignActors()
		SendThreadEvent("AnimationStart")
		if leadIn
			SendThreadEvent("LeadInStart")
		endIf
		primed = true
		GotoState("BeginLoop")
	endEvent
endState

;/-----------------------------------------------\;
;|	Animation Loops                              |;
;\-----------------------------------------------/;

bool beginLoop
bool beginStage
bool animating
bool stageBack
bool advance
bool orgasm
float advanceTimer
int previousStage

float[] sfx
float started
float timer

state BeginLoop
	event OnBeginState()
		beginLoop = true
		RegisterForSingleUpdate(0.10)
	endEvent
	event OnUpdate()
		if !beginLoop
			return
		endIf
		beginLoop = false

		int i
		while i < ActorCount
			ActorAlias(i).StartAnimating()
			i += 1
		endWhile

		RealignActors()

		animating = true
		advance = true
		GoToState("Advance")

		; Set the SFX
		int sfxInstance
		float sfxVolume = Lib.fSFXVolume

		started = Utility.GetCurrentRealTime()
		while animating
			; Play SFX
			if sfx[0] <= timer - sfx[1] && sfxType != none
				sfxInstance = sfxType.Play(Positions[0])
				Sound.SetInstanceVolume(sfxInstance, sfxVolume)
				sfx[1] = timer
			endIf
			timer = Utility.GetCurrentRealTime() - started
			Utility.Wait(0.4)
		endWhile
	endEvent
endState

state Advance
	event OnBeginState()
		if advance == true
			RegisterForSingleUpdate(0.10)
		else
			EndAnimation(true)
		endIf
	endEvent

	event OnUpdate()
		if !advance
			return
		endIf
		advance = false

		previousStage = stage

		; Next stage
		if stageBack
			stage -= 1
		else
			stage += 1
		endIf
		if stage < 1
			stage = 1
		endIf

		stageBack = false

		if leadIn && stage > Animation.StageCount()
			; End leadIn animations and go into normal animations
			stage = 1
			leadIn = false
			SetAnimation()
			SendThreadEvent("LeadInEnd")
			; Restrip with new strip options
			if Animation.IsSexual()
				int i
				while i < ActorCount
					form[] equipment = Lib.Actors.StripSlots(Positions[i], GetStrip(Positions[i]), false)
					ActorAlias(i).StoreEquipment(equipment)
					i += 1
				endWhile
			endIf
			; Start Animations loop
			RealignActors()
			GoToState("Animating")
		elseIf stage <= Animation.StageCount()
			; Make sure stage exists first
			if !leadIn && stage == Animation.StageCount()
				orgasm = true
			else
				orgasm = false
			endIf
			; Start Animations loop
			GoToState("Animating")
		else
			; No valid stages left
			EndAnimation()
		endIf
	endEvent

	event OnEndState()
		if !animating
			return
		endIf
		; Stage Delay
		if stage > 1
			sfx[0] = sfx[0] - (stage * 0.2)
		endIf
		; min 1.0 delay
		if sfx[0] < 1.0
			sfx[0] = 1.0
		endIf
		; Inform ActorAlias of change
		int i
		while i < ActorCount
			ActorAlias(i).ThreadStage(stage)
			i += 1
		endWhile
	endEvent
endState

state Animating
	event OnBeginState()
		if animating
			beginStage = true
			RegisterForSingleUpdate(0.10)
		endIf
	endEvent

	event OnUpdate()
		if !beginStage
			return
		endIf
		beginStage = false

		if orgasm
			SendThreadEvent("OrgasmStart")
		else
			SendThreadEvent("StageStart")
		endIf

		PlayAnimation()

		; Check if actor needs to be realigned for stage
		if previousStage != 0
			int position = 0
			while position < ActorCount
				float[] current = Animation.GetPositionOffsets(position, stage)
				float[] previous = Animation.GetPositionOffsets(position, previousStage)
				int offset = 0
				while offset < 4
					if current[offset] != previous[offset]
						MoveActor(position)
						offset = 4
					endIf
					offset += 1
				endWhile
				position += 1
			endWhile
		endIf

		advanceTimer = Utility.GetCurrentRealTime() + GetStageTimer(Animation.StageCount())

		advance = false
		while !advance && animating
			; Delay loop
			Utility.Wait(1.0)
			; Auto Advance
			if autoAdvance && advanceTimer < Utility.GetCurrentRealTime()
				advance = true
			endIf
		endWhile

		if orgasm
			SendThreadEvent("OrgasmEnd")
		else
			SendThreadEvent("StageEnd")
		endIf

		; stage == Animation.StageCount() && Animation.StageCount() >= 2 && Animation.IsSexual() && !leadIn
		GoToState("Advance")
	endEvent
endState

;/-----------------------------------------------\;
;|	Hotkey Functions                             |;
;\-----------------------------------------------/;

int AdjustingPosition
bool MovingScene

function AdvanceStage(bool backwards = false)
	if !animating
		return
	endIf
	if backwards && stage == 1
		return
	elseif backwards && stage > 1
		stageBack = true
	endIf
	advance = true
endFunction

function ChangeAnimation(bool backwards = false)
	if !animating || animations.Length == 1
		return ; Single animation selected, nothing to change to
	endIf
	if !backwards
		aid += 1
	else
		aid -= 1
	endIf
	if aid >= animations.Length
		aid = 0
	elseIf aid < 0
		aid = animations.Length - 1
	endIf

	SetAnimation(aid)

	RealignActors()

	SendThreadEvent("AnimationChange")
endFunction

function ChangePositions(bool backwards = false)
	if !animating || ActorCount < 2
		return ; Solo Animation, nobody to swap with
	endIf
	; Set direction of swapping
	int MovedTo
	if backwards
		MovedTo = PositionWrap((AdjustingPosition - 1))
	else
		MovedTo = PositionWrap((AdjustingPosition + 1))
	endIf
	; Actors to swap
	actor adjusting = Positions[AdjustingPosition]
	actor moved = Positions[MovedTo]
	; Actor slots
	sslActorAlias AdjustAlias = GetActorAlias(adjusting)
	sslActorAlias MovedAlias = GetActorAlias(moved)
	; Shuffle
	actor[] NewPositions = Positions
	NewPositions[AdjustingPosition] = moved
	NewPositions[MovedTo] = adjusting
	Positions = NewPositions
	; Removed extras/strapons
	AdjustAlias.RemoveExtras()
	MovedAlias.RemoveExtras()
	; Update positions
	AdjustAlias.ThreadPosition(GetPosition(adjusting))
	MovedAlias.ThreadPosition(GetPosition(moved))
	; Equip new extras
	AdjustAlias.EquipExtras()
	MovedAlias.EquipExtras()
	; Restart animations
	RealignActors()
	AdjustChange(backwards)
	SendThreadEvent("PositionChange")
endFunction

function AdjustForward(bool backwards = false, bool adjuststage = false)
	if !animating
		return
	endIf
	float adjustment = 0.75
	if backwards
		adjustment = adjustment * -1
	endIf
	if adjuststage
		Animation.UpdateForward(AdjustingPosition, stage, adjustment)
	else
		Animation.UpdateAllForward(AdjustingPosition, adjustment)
	endIf
	MoveActor(AdjustingPosition)
endFunction

function AdjustSideways(bool backwards = false, bool adjuststage = false)
	if !animating
		return
	endIf
	float adjustment = 0.75
	if backwards
		adjustment = adjustment * -1
	endIf
	if adjuststage
		Animation.UpdateSide(AdjustingPosition, stage, adjustment)
	else
		Animation.UpdateAllSide(AdjustingPosition, adjustment)
	endIf
	MoveActor(AdjustingPosition)
endFunction

function AdjustUpward(bool backwards = false, bool adjuststage = false)
	if !animating || IsPlayerPosition(AdjustingPosition)
		return
	endIf
	float adjustment = 0.75
	if backwards
		adjustment = adjustment * -1
	endIf
	if adjuststage
		Animation.UpdateUp(AdjustingPosition, stage, adjustment)
	else
		Animation.UpdateAllUp(AdjustingPosition, adjustment)
	endIf
	MoveActor(AdjustingPosition)
endFunction

function RotateScene(bool backwards = false)
	if !animating
		return
	endIf
	; Adjust current center's Z angle
	float adjustment = 45
	if backwards
		adjustment = adjustment * -1
	endIf
	UpdateRotation(adjustment) 
	MoveActors()
endFunction

function AdjustChange(bool backwards = false)
	if !animating
		return
	endIf
	if backwards
		AdjustingPosition -= 1 
	else
		AdjustingPosition += 1
	endIf
	AdjustingPosition = PositionWrap(AdjustingPosition)
	Lib.mAdjustChange.Show((AdjustingPosition + 1))
endFunction

function RestoreOffsets()
	if !animating
		return
	endIf
	Animation.RestoreOffsets()
	RealignActors()
endFunction

function MoveScene()
	if !animating
		return
	endIf
	bool advanceToggle
	; Toggle auto advance off
	if autoAdvance
		started -= 8.0
		autoAdvance = false
		advanceToggle = true
	endIf
	; Enable Controls
	MovingScene = true
	Game.SetPlayerAIDriven(false)
	;Game.EnablePlayerControls()
	Debug.SendAnimationEvent(Lib.PlayerRef, "IdleForceDefaultState")
	; Lock hotkeys here for timer
	Lib.mMoveScene.Show(6)
	float stopat = Utility.GetCurrentRealTime() + 6
	while stopat > Utility.GetCurrentRealTime()
		Utility.Wait(0.8)
	endWhile
	; Disable Controls
	;Game.DisablePlayerControls(true, true, true, false, true, false, false, true, 0)
	Game.SetPlayerAIDriven()
	; Give player time to settle incase airborne
	Utility.Wait(1.0)
	; Recenter + sync
	CenterOnObject(GetPlayer(), true)
	; Toggle auto advance back
	if advanceToggle
		autoAdvance = true
	endIf
	MovingScene = false
endFunction

function RealignActors()
	PlayAnimation()
	MoveActors()
endFunction

;/-----------------------------------------------\;
;|	Actor Manipulation                           |;
;\-----------------------------------------------/;

function MoveActor(int position)
	actor a = Positions[position]
	float[] offsets = Animation.GetPositionOffsets(position, stage)
	float[] center = CenterLocation
	float[] loc = new float[6]

	; Determine offsets coordinates from center
	loc[0] = ( center[0] + ( Math.sin(center[5]) * offsets[0] + Math.cos(center[5]) * offsets[1] ) )
	loc[1] = ( center[1] + ( Math.cos(center[5]) * offsets[0] + Math.sin(center[5]) * offsets[1] ) )
	loc[2] = ( center[2] + offsets[2] )
	; Determine rotation coordinates from center
	loc[3] = center[3]
	loc[4] = center[4]
	loc[5] = ( center[5] + offsets[3] )
	if loc[5] >= 360
		loc[5] = ( loc[5] - 360 )
	elseIf loc[5] < 0
		loc[5] = ( loc[5] + 360 )
	endIf
	a.SetPosition(loc[0], loc[1], loc[2])
	a.SetAngle(loc[3], loc[4], loc[5])
endFunction

function MoveActors()
	int i
	while i < actorCount
		MoveActor(i)
		i += 1
	endWhile
endFunction

;/-----------------------------------------------\;
;|	Animation Functions                           |;
;\-----------------------------------------------/;

sslBaseAnimation animationCurrent
sslBaseAnimation property Animation hidden
	sslBaseAnimation function get()
		return animationCurrent
	endFunction
endProperty

int aid
Sound sfxType
bool[] silence

function SetAnimation(int anim = -1)
	if !_MakeWait("SetAnimation")
		return
	endIf
	aid = anim
	if aid < 0 ; randomize if -1
		aid = utility.RandomInt(0, animations.Length - 1)
	endIf
	animationCurrent = animations[aid]

	if Animation.GetSFX() == 1 ; Squishing
		sfxType = Lib.sfxSquishing01
	elseIf Animation.GetSFX() == 2 ; Sucking
		sfxType = Lib.sfxSucking01
	elseIf Animation.GetSFX() == 3 ; SexMix
		sfxType = Lib.sfxSexMix01
	else
		sfxType = none
	endIf

	int i = 0
	while i < ActorCount
		;SexLab.StripActor(pos[i], victim)
		sslActorAlias Slot = GetActorAlias(Positions[i])
		Slot.ThreadPosition(i)
		Slot.ThreadAnimation(Animation)
		Slot.ThreadStage(Stage)
		i += 1
	endWhile

endFunction

function PlayAnimation()
	int i
	while i < ActorCount
		ActorAlias(i).PlayAnimation()
		i += 1
	endWhile
endFunction

;/-----------------------------------------------\;
;|	Ending Functions                             |;
;\-----------------------------------------------/;

bool[] ending

function EndAnimation(bool quick = false)
	if !animating
		UnlockThread()
		return
	endIf
	animating = false
	SendThreadEvent("AnimationEnd")

	if !quick
		; Apply Cum
		if Animation.IsSexual() && Lib.Actors.bUseCum
			int[] genders = Lib.Actors.GenderCount(positions)
			if genders[0] > 0 || Lib.Actors.bAllowFFCum
				int i
				while i < ActorCount
					Lib.Actors.ApplyCum(Positions[i], Animation.GetCum(i))
					i += 1
				endWhile
			endIf
		endIf
		; Reset Actor & Clear Alias
		SendActorEvent("EndThread")
		Utility.Wait(2.0)
	else
		; Reset Actor & Clear Alias (Quickly)
		SendActorEvent("QuickEndThread")
	endIf

	UnlockThread()
endFunction

function Initialize()
	; Clear model
	parent.Initialize()
	; Set states
	animating = false
	stageBack = false
	primed = false
	scaled = false
	advance = false
	orgasm = false
	; Empty Strings
	; Empty actors
	actor[] acDel
	; Empty Floats
	float[] fDel
	sfx = fDel
	timer = 0.0
	started = 0.0
	advanceTimer = 0.0
	; Empty bools
	bool[] bDel
	silence = bDel
	; Empty integers
	int[] iDel
	AdjustingPosition = 0
	previousStage = 0
	aid = 0
	; Empty voice slots
	; Empty animations
	animationCurrent = none
	; Empty forms
	sfxType = none
endFunction

;/-----------------------------------------------\;
;|	Chain Events                                 |;
;\-----------------------------------------------/;

function SendActorEvent(string callback)
	int i
	while i < ActorCount
		ActorAlias(i).ActorEvent(callback)
		i += 1
	endWhile
endFunction

;/-----------------------------------------------\;
;|	API Functions                                |;
;\-----------------------------------------------/;

float function GetTime()
	return timer
endfunction