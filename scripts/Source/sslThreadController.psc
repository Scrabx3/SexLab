scriptname sslThreadController extends sslThreadModel
{ Animation Thread Controller: Runs manipulation logic of thread based on information from model. Access only through functions; NEVER create a property directly to this. }

; Animation
string[] AnimEvents
float SkillTime

; SFX
float SFXDelay
float SFXTimer

; Processing
bool hkReady
bool TimedStage
float StageTimer
int StageCount
int AdjustPos
sslActorAlias AdjustAlias

; ------------------------------------------------------- ;
; --- Thread Starter                                  --- ;
; ------------------------------------------------------- ;

state PrimeThread
	function FireAction()
		RegisterForSingleUpdate(0.05)
	endFunction
	event OnUpdate()
		; Init loop info
		SetAnimation()
		AutoAdvance = (!HasPlayer || (VictimRef == PlayerRef && Config.bDisablePlayer) || Config.bAutoAdvance)
		; Prepare actors
		AliasEvent("Prepare", "Animating")
		ActorAlias[0].StartAnimating()
		ActorAlias[1].StartAnimating()
		ActorAlias[2].StartAnimating()
		ActorAlias[3].StartAnimating()
		ActorAlias[4].StartAnimating()
		; Begin animating loop
		SendThreadEvent("AnimationStart")
		if LeadIn
			SendThreadEvent("LeadInStart")
		endIf
		Action("Advancing")
	endEvent
endState

; ------------------------------------------------------- ;
; --- Animation Loop                                  --- ;
; ------------------------------------------------------- ;

state Advancing
	function FireAction()
		if Stage < 1
			Stage = 1
		elseIf Stage > StageCount
			if LeadIn
				return EndLeadIn()
			else
				return EndAnimation()
			endIf
		endIf
		SFXDelay = sslUtility.ClampFloat(Config.fSFXDelay - ((Stage * 0.3) * ((Stage != 1) as int)), 0.5, 30.0)
		Action("Animating")
	endFunction
endState

state Animating
	function FireAction()
		; Update information for stage
		AnimEvents = Animation.FetchStage(Stage)
		StageTimer = Utility.GetCurrentRealTime() + GetTimer()
		PlayAnimation()
		MoveActors()
		; Send events
		if !LeadIn && Stage >= StageCount
			SendThreadEvent("OrgasmStart")
			if Config.bOrgasmEffects
				TriggerOrgasm()
			endIf
		else
			SendThreadEvent("StageStart")
		endIf
		; Begin loop
		Log("Starting Stage: "+Stage, "Animating Loop")
		RegisterForSingleUpdate(0.01)
	endFunction

	event OnUpdate()
		float CurrentTime = Utility.GetCurrentRealTime()
		; Advance stage on timer
		if (AutoAdvance || TimedStage) && StageTimer < CurrentTime
			GoToStage((Stage + 1))
			return
		endIf
		; Play SFX
		if SFXTimer < CurrentTime && Animation.SoundFX != none
			Animation.SoundFX.Play(CenterRef)
			SFXTimer = CurrentTime + SFXDelay
		endIf
		; Loop
		RegisterForSingleUpdate(0.2)
	endEvent

	function EndAction()
		if !LeadIn && Stage > StageCount
			SendThreadEvent("OrgasmEnd")
		else
			SendThreadEvent("StageEnd")
		endIf
	endFunction

	; ------------------------------------------------------- ;
	; --- Loop functions                                  --- ;
	; ------------------------------------------------------- ;

	function GoToStage(int ToStage)
		Stage = ToStage
		Action("Advancing")
	endFunction

	function PlayAnimation()
		; Send with as little overhead as possible to improve syncing
		if ActorCount == 1
			Debug.SendAnimationEvent(Positions[0], AnimEvents[0])
		elseIf ActorCount == 2
			Debug.SendAnimationEvent(Positions[0], AnimEvents[0])
			Debug.SendAnimationEvent(Positions[1], AnimEvents[1])
		elseIf ActorCount == 3
			Debug.SendAnimationEvent(Positions[0], AnimEvents[0])
			Debug.SendAnimationEvent(Positions[1], AnimEvents[1])
			Debug.SendAnimationEvent(Positions[2], AnimEvents[2])
		elseIf ActorCount == 4
			Debug.SendAnimationEvent(Positions[0], AnimEvents[0])
			Debug.SendAnimationEvent(Positions[1], AnimEvents[1])
			Debug.SendAnimationEvent(Positions[2], AnimEvents[2])
			Debug.SendAnimationEvent(Positions[3], AnimEvents[3])
		elseIf ActorCount == 5
			Debug.SendAnimationEvent(Positions[0], AnimEvents[0])
			Debug.SendAnimationEvent(Positions[1], AnimEvents[1])
			Debug.SendAnimationEvent(Positions[2], AnimEvents[2])
			Debug.SendAnimationEvent(Positions[3], AnimEvents[3])
			Debug.SendAnimationEvent(Positions[4], AnimEvents[4])
		endIf
	endFunction

	function RealignActors()
		ActorAlias[0].SyncThread()
		ActorAlias[1].SyncThread()
		ActorAlias[2].SyncThread()
		ActorAlias[3].SyncThread()
		ActorAlias[4].SyncThread()
		ActorAlias[0].SyncLocation(true)
		ActorAlias[1].SyncLocation(true)
		ActorAlias[2].SyncLocation(true)
		ActorAlias[3].SyncLocation(true)
		ActorAlias[4].SyncLocation(true)
		PlayAnimation()
	endFunction

	function MoveActors()
		ActorAlias[0].SyncThread()
		ActorAlias[1].SyncThread()
		ActorAlias[2].SyncThread()
		ActorAlias[3].SyncThread()
		ActorAlias[4].SyncThread()
		ActorAlias[0].SyncLocation(false)
		ActorAlias[1].SyncLocation(false)
		ActorAlias[2].SyncLocation(false)
		ActorAlias[3].SyncLocation(false)
		ActorAlias[4].SyncLocation(false)
	endFunction

	; ------------------------------------------------------- ;
	; --- Hotkey functions                                  --- ;
	; ------------------------------------------------------- ;

	function AdvanceStage(bool backwards = false)
		if !backwards
			GoToStage((Stage + 1))
		elseIf backwards && Stage > 1
			GoToStage((Stage - 1))
		endIf
	endFunction

	function ChangeAnimation(bool backwards = false)
		SetAnimation(sslUtility.IndexTravel(Animations.Find(Animation), Animations.Length, backwards))
		SendThreadEvent("AnimationChange")
	endFunction

	function ChangePositions(bool backwards = false)
		if ActorCount < 2 || HasCreature
			return ; Solo/Creature Animation, nobody to swap with
		endIf
		; Find position to swap to
		int MovedPos = sslUtility.IndexTravel(AdjustPos, ActorCount, backwards)
		; Shuffle actor positions
		Positions[AdjustPos] = PositionAlias(MovedPos).ActorRef
		Positions[MovedPos] = AdjustAlias.ActorRef
		; Sync new positions
		AdjustPos = MovedPos
		UpdateAdjustKey()
		RealignActors()
		SendThreadEvent("PositionChange")
	endFunction

	function AdjustForward(bool backwards = false, bool adjustStage = false)
		Animation.AdjustForward(AdjustKey, AdjustPos, Stage, sslUtility.SignFloat(backwards, 1.0), adjustStage)
		AdjustAlias.UpdateOffsets()
	endFunction

	function AdjustSideways(bool backwards = false, bool adjustStage = false)
		Animation.AdjustSideways(AdjustKey, AdjustPos, Stage, sslUtility.SignFloat(backwards, 1.0), adjustStage)
		AdjustAlias.UpdateOffsets()
	endFunction

	function AdjustUpward(bool backwards = false, bool adjustStage = false)
		Animation.AdjustUpward(AdjustKey, AdjustPos, Stage, sslUtility.SignFloat(backwards, 1.0), adjustStage)
		AdjustAlias.UpdateOffsets()
	endFunction

	function RotateScene(bool backwards = false)
		CenterLocation[5] = CenterLocation[5] + sslUtility.SignFloat(backwards, 45.0)
		if CenterLocation[5] >= 360.0
			CenterLocation[5] = CenterLocation[5] - 360.0
		elseIf CenterLocation[5] < 0.0
			CenterLocation[5] = CenterLocation[5] + 360.0
		endIf
		RealignActors()
	endFunction

	function AdjustChange(bool backwards = false)
		if ActorCount > 1
			AdjustPos = sslUtility.IndexTravel(Positions.Find(AdjustAlias.ActorRef), ActorCount, backwards)
			AdjustAlias = PositionAlias(AdjustPos)
			Debug.Notification("Adjusting Position For: "+AdjustAlias.ActorRef.GetLeveledActorBase().GetName())
		endIf
	endFunction

	function RestoreOffsets()
		Animation.RestoreOffsets(AdjustKey)
		RealignActors()
	endFunction

	function MoveScene()
		; Stop animation loop
		UnregisterForUpdate()
		; Enable Controls
		sslActorAlias Slot = ActorAlias(PlayerRef)
		Slot.UnlockActor()
		Debug.SendAnimationEvent(PlayerRef, "IdleForceDefaultState")
		; Slot.StopAnimating(true)
		PlayerRef.StopTranslation()
		; Lock hotkeys and wait 7 seconds
		Debug.Notification("Player movement unlocked - repositioning scene in 7 seconds...")
		SexLabUtil.Wait(7.0)
		; Disable Controls
		Slot.LockActor()
		; Give player time to settle incase airborne
		Utility.Wait(1.0)
		; Recenter on coords to avoid stager + resync animations
		if !CenterOnBed(true, 400.0)
			CenterOnObject(PlayerRef, true)
		endIf
		; Return to animation loop
		StageTimer += 8.0
		RegisterForSingleUpdate(0.05)
	endFunction

	event OnKeyDown(int KeyCode)
		if hkReady && !Utility.IsInMenuMode() ; || UI.IsMenuOpen("Console") || UI.IsMenuOpen("Loading Menu")
			hkReady = false
			Config.HotkeyCallback(self, KeyCode)
			hkReady = true
		endIf
	endEvent

endState

; ------------------------------------------------------- ;
; --- Context Sensitive Info                          --- ;
; ------------------------------------------------------- ;

function SetAnimation(int aid = -1)
	; Randomize if -1
	if aid < 0 || aid >= Animations.Length
		aid = Utility.RandomInt(0, (Animations.Length - 1))
	endIf
	; Set active animation
	Animation = Animations[aid]
	; Update animation info
	RecordSkills()
	StageCount = Animation.StageCount
	IsVaginal  = AddTagConditional("Vaginal", (Animation.HasTag("Vaginal") && Genders[1] > 0))
	IsAnal     = AddTagConditional("Anal", (Animation.HasTag("Anal") || (Genders[1] == 0 && Animation.HasTag("Vaginal"))))
	IsOral     = AddTagConditional("Oral", Animation.HasTag("Oral"))
	IsLoving   = AddTagConditional("Loving", Animation.HasTag("Loving"))
	IsDirty    = AddTagConditional("Dirty", Animation.HasTag("Dirty"))
	; Offset adjustment key
	UpdateAdjustKey()
	; Inform player of animation being played now
	if HasPlayer
		MiscUtil.PrintConsole("Playing Animation: " + Animation.Name)
	endIf
	; Check for out of range stage
	if Stage >= StageCount
		GoToStage((StageCount - 1))
	else
		AnimEvents = Animation.FetchStage(Stage)
		StageTimer = Utility.GetCurrentRealTime() + GetTimer()
		MoveActors()
		PlayAnimation()
	endIf
endFunction

float function GetTimer()
	; Custom acyclic stage timer
	if Animation.HasTimer(Stage)
		TimedStage = true
		return Animation.GetTimer(Stage)
	endIf
	; Default stage timers
	TimedStage = false
	int last = ( Timers.Length - 1 )
	if Stage < last
		return Timers[(Stage - 1)]
	elseIf Stage >= StageCount
		return Timers[last]
	endIf
	return Timers[(last - 1)]
endFunction

function UpdateTimer(float AddSeconds = 0.0)
	TimedStage = true
	StageTimer += AddSeconds
endFunction

function TriggerOrgasm()
	AliasEvent("Orgasm")
endFunction

function EndLeadIn()
	if LeadIn
		; Swap to non lead in animations
		Stage = 1
		LeadIn = false
		SetAnimation()
		; Add runtime to foreplay skill xp
		AddXP(0, (TotalTime / 11.0))
		; Restrip with new strip options
		ActorAlias[0].Strip(false)
		ActorAlias[1].Strip(false)
		ActorAlias[2].Strip(false)
		ActorAlias[3].Strip(false)
		ActorAlias[4].Strip(false)
		; Start primary animations at stage 1
		SendThreadEvent("LeadInEnd")
		Action("Advancing")
	endIf
endFunction

function EndAnimation(bool Quickly = false)
	UnregisterForUpdate()
	GoToState("Ending")
	; Set fast flag to skip slow ending functions
	Stage = StageCount
	; Save skill xp for actor update
	RecordSkills()
	; Reset actors & wait for clear state
	AliasEvent("Reset", "")
	; Send end event
	SendThreadEvent("AnimationEnd")
	if !Quickly
		SexLabUtil.Wait(2.0)
	endIf
	; Clear & Reset animation thread
	Initialize()
endFunction

function CenterOnObject(ObjectReference CenterOn, bool resync = true)
	parent.CenterOnObject(CenterOn, resync)
	if resync && GetState() == "Animating"
		RealignActors()
		SendThreadEvent("ActorsRelocated")
	endIf
endFunction

function CenterOnCoords(float LocX = 0.0, float LocY = 0.0, float LocZ = 0.0, float RotX = 0.0, float RotY = 0.0, float RotZ = 0.0, bool resync = true)
	parent.CenterOnCoords(LocX, LocY, LocZ, RotX, RotY, RotZ, resync)
	if resync && GetState() == "Animating"
		RealignActors()
		SendThreadEvent("ActorsRelocated")
	endIf
endFunction

; ------------------------------------------------------- ;
; --- System Use Only                                 --- ;
; ------------------------------------------------------- ;

function RecordSkills()
	float xp = ((TotalTime - SkillTime) / 15.0)
	AddXP(1, xp, IsVaginal)
	AddXP(2, xp, IsAnal)
	AddXP(3, xp, IsOral)
	AddXP(4, xp, IsLoving)
	AddXP(5, xp, IsDirty)
	; Log("ADDING XP: "+xp+" -- Foreplay: "+GetXP(0)+" Vaginal: "+GetXP(1)+" Anal: "+GetXP(2)+" Oral: "+GetXP(3))
	SkillTime = TotalTime
endfunction

function EnableHotkeys()
	if HasPlayer
		; RegisterForKey(Config.kBackwards)
		; RegisterForKey(Config.kAdjustStage)
		RegisterForKey(Config.kAdvanceAnimation)
		RegisterForKey(Config.kChangeAnimation)
		RegisterForKey(Config.kChangePositions)
		RegisterForKey(Config.kAdjustChange)
		RegisterForKey(Config.kAdjustForward)
		RegisterForKey(Config.kAdjustSideways)
		RegisterForKey(Config.kAdjustUpward)
		RegisterForKey(Config.kRealignActors)
		RegisterForKey(Config.kRestoreOffsets)
		RegisterForKey(Config.kMoveScene)
		RegisterForKey(Config.kRotateScene)
		RegisterForKey(Config.kEndAnimation)
		hkReady = true
	endIf
endFunction

function DisableHotkeys()
	UnregisterForAllKeys()
	hkReady = false
endFunction

function Initialize()
	DisableHotkeys()
	SkillTime   = 0.0
	TimedStage  = false
	AdjustAlias = ActorAlias[0]
	parent.Initialize()
endFunction


auto state Unlocked
	function EndAnimation(bool Quickly = false)
	endFunction
endState

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; State Animating
function PlayAnimation()
endFunction
function AdvanceStage(bool backwards = false)
endFunction
function ChangeAnimation(bool backwards = false)
endFunction
function ChangePositions(bool backwards = false)
endFunction
function AdjustForward(bool backwards = false, bool adjuststage = false)
endFunction
function AdjustSideways(bool backwards = false, bool adjuststage = false)
endFunction
function AdjustUpward(bool backwards = false, bool adjuststage = false)
endFunction
function RotateScene(bool backwards = false)
endFunction
function AdjustChange(bool backwards = false)
endFunction
function RestoreOffsets()
endFunction
function MoveScene()
endFunction
function RealignActors()
endFunction
function MoveActors()
endFunction
function GoToStage(int ToStage)
endFunction
; State varied
function FireAction()
endFunction
function EndAction()
endFunction
