ScriptName sslThreadModel extends Quest Hidden
{
	Primary class for scene management. Builds and controls scene-flow and keeps track of scene actors
	The only reason for you to be here is if you want to construct a scene manually by obtaining a prepared thread through
	SexLabFramework.MakeThread(), In this case, please see the Functions in the "Making" State for documentation on how to build a scene
	If this is not the case and you simply wish to access or write an already constructed thread please see sslThreadController.psc
}

int thread_id
int Property tid hidden
	int Function get()
		return thread_id
	EndFunction
EndProperty

bool Property IsLocked hidden
	bool Function get()
		return GetState() != "Unlocked"
	EndFunction
EndProperty

; Constants
int Property POSITION_COUNT_MAX = 5 AutoReadOnly

; Library & Data
sslSystemConfig Property Config auto
sslActorLibrary Property ActorLib auto
sslThreadLibrary Property ThreadLib auto
sslAnimationSlots Property AnimSlots auto
sslCreatureAnimationSlots Property CreatureSlots auto

; Actor Info
sslActorAlias[] Property ActorAlias auto hidden
Actor[] Property Positions Auto Hidden
; assert(ActorAlias[i].GetRef() == Positions[i])

Actor Property PlayerRef auto hidden

; Thread status
int Property Stage Auto Hidden
bool Property HasPlayer
	bool Function Get()
		return Positions.Find(PlayerRef) > -1
	EndFunction
EndProperty

bool Property AutoAdvance auto hidden
bool Property LeadIn auto hidden

; Animation Info
Sound Property SoundFX auto hidden
string Property AdjustKey
	String Function Get()
		return "Global"
		; if !Config.RaceAdjustments && Config.ScaleActors
		; 	AdjustKey = "Global"
		; else
		; 	int i
		; 	string NewKey
		; 	while i < ActorCount
		; 		NewKey += PositionAlias(i).GetActorKey()
		; 		i += 1
		; 		if i < ActorCount
		; 			NewKey += "."
		; 		endIf
		; 	endWhile
		; 	AdjustKey = NewKey
		; endIf
	EndFunction
EndProperty
string[] Property AnimEvents auto hidden

sslBaseAnimation Property Animation auto hidden						; The currently playing Animation
sslBaseAnimation Property StartingAnimation auto hidden		; The first animation this thread player
sslBaseAnimation[] CustomAnimations												; animation overrides (will always be used if not empty)
sslBaseAnimation[] PrimaryAnimations											; set of valid animations
sslBaseAnimation[] LeadAnimations													; set of valid lead-in (intro) animations
sslBaseAnimation[] Property Animations hidden							; currently active set of animation
	sslBaseAnimation[] Function get()
		If(CustomAnimations.Length > 0)
			return CustomAnimations
		ElseIf(LeadIn)
			return LeadAnimations
		Else
			return PrimaryAnimations
		EndIf
	EndFunction
EndProperty

; Stat Tracking Info
float[] Property SkillBonus auto hidden ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd
float[] Property SkillXP auto hidden    ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd

bool[] Property IsType auto hidden ; [0] IsAggressive, [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty
bool Property IsAggressive hidden
	bool Function get()
		return IsType[0] || Victims.Length || Tags.Find("Aggressive")
	endfunction
	Function set(bool value)
		IsType[0] = value
	EndFunction
EndProperty
bool Property IsVaginal hidden
	bool Function get()
		return IsType[1]
	endfunction
	Function set(bool value)
		IsType[1] = value
	EndFunction
EndProperty
bool Property IsAnal hidden
	bool Function get()
		return IsType[2]
	endfunction
	Function set(bool value)
		IsType[2] = value
	EndFunction
EndProperty
bool Property IsOral hidden
	bool Function get()
		return IsType[3]
	endfunction
	Function set(bool value)
		IsType[3] = value
	EndFunction
EndProperty
bool Property IsLoving hidden
	bool Function get()
		return IsType[4]
	endfunction
	Function set(bool value)
		IsType[4] = value
	EndFunction
EndProperty
bool Property IsDirty hidden
	bool Function get()
		return IsType[5]
	endfunction
	Function set(bool value)
		IsType[5] = value
	EndFunction
EndProperty

; Timer Info
bool UseCustomTimers
float[] CustomTimers
float[] ConfigTimers
float[] Property Timers hidden
	float[] Function get()
		if UseCustomTimers
			return CustomTimers
		endIf
		return ConfigTimers
	EndFunction
	Function set(float[] value)
	if !value.Length
		Log("Set() - Empty timers given for Property Timers.", "ERROR")
	else
		CustomTimers    = value
		UseCustomTimers = true
	endIf
	EndFunction
EndProperty

; Thread info
float[] Property CenterLocation Auto Hidden

ObjectReference _Center													; the actual center object the animation is using
ReferenceAlias Property CenterAlias Auto Hidden	; the alias holding the object used as center
ObjectReference Property CenterRef							; the aliases reference
	ObjectReference Function Get()
		return CenterAlias.GetReference()
	EndFunction
	Function Set(ObjectReference akNewCenter)
		CenterOnObject(akNewCenter)
	EndFunction
EndProperty

float Property StartedAt auto hidden
float Property TotalTime hidden
	float Function get()
		return SexLabUtil.GetCurrentGameRealTime() - StartedAt
	EndFunction
EndProperty

Actor[] property Victims auto hidden
Actor property VictimRef hidden
	Actor Function Get()
		If(Victims.Length)
			return Victims[0]
		EndIf
		return none
	EndFunction
	Function Set(Actor ActorRef)
		If(!ActorRef)
			return
		ElseIf(Victims.Find(ActorRef) == -1)
			Victims = PapyrusUtil.PushActor(Victims, ActorRef)
		EndIf
		IsAggressive = true
	EndFunction
EndProperty

bool property DisableOrgasms auto hidden

; Beds
int[] Property BedStatus auto hidden
; BedStatus[0] = -1 forbid, 0 allow, 1 force
; BedStatus[1] = 0 none, 1 bedroll, 2 single, 3 double
ObjectReference Property BedRef auto hidden
int Property BedTypeID hidden
	int Function get()
		return BedStatus[1]
	EndFunction
EndProperty
bool Property UsingBed hidden
	bool Function get()
		return BedStatus[1] > 0
	EndFunction
EndProperty
bool Property UsingBedRoll hidden
	bool Function get()
		return BedStatus[1] == 1
	EndFunction
EndProperty
bool Property UsingSingleBed hidden
	bool Function get()
		return BedStatus[1] == 2
	EndFunction
EndProperty
bool Property UsingDoubleBed hidden
	bool Function get()
		return BedStatus[1] == 3
	EndFunction
EndProperty
bool Property UseNPCBed hidden
	bool Function get()
		int NPCBed = Config.NPCBed
		return NPCBed == 2 || (NPCBed == 1 && (Utility.RandomInt(0, 1) as bool))
	EndFunction
EndProperty

; Genders
int[] Property Genders auto hidden
int Property Males hidden
	int Function get()
		return Genders[0]
	EndFunction
EndProperty
int Property Females hidden
	int Function get()
		return Genders[1]
	EndFunction
EndProperty

bool Property HasCreature hidden
	bool Function get()
		return Creatures > 0
	EndFunction
EndProperty
int Property Creatures hidden
	int Function get()
		return Genders[2] + Genders[3]
	EndFunction
EndProperty
int Property MaleCreatures hidden
	int Function get()
		return Genders[2]
	EndFunction
EndProperty
int Property FemaleCreatures hidden
	int Function get()
		return Genders[3]
	EndFunction
EndProperty

; Local readonly
string[] Hooks
string[] Tags
string ActorKeys

; Animating
float SkillTime

; Debug testing
bool Property DebugMode auto hidden
float Property t auto hidden

; During validation, where positions shifted to adjust to the given animations?
; This is only allowed once, so mark it here if they were shifted once before
bool positions_shifted

int[] Function GetPositionData()
	int[] ret = Utility.CreateIntArray(Positions.Length)
	int j = 0
	While(j < Positions.Length)
		ret[j] = ActorAlias[j].GetActorData()
		j += 1
	EndWhile
	return ret
EndFunction

; Same as GetPositionData() but will account for gender specific configurations
; Mostly a wrapper to loosely match animation keys/validate animations
; Remember that GetAnimation() functions have their own backups in place
int[] Function GetPositionDataConfig()
	int[] ret = GetPositionData()
	If(!Config.UseCreatureGender)
		sslActorData.NeutralizeCreatureGender(ret)
	EndIf
	return ret
EndFunction

; ------------------------------------------------------- ;
; --- Thread Making API                               --- ;
; ------------------------------------------------------- ;

; The Making State
State Making
	int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
		If(!ActorRef)
			ReportAndFail("Failed to add actor -- Actor is a figment of your imagination", "AddActor(NONE)")
			return -1
		ElseIf(ActorCount >= POSITION_COUNT_MAX)
			ReportAndFail("Failed to add actor -- Thread has reached actor limit", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		ElseIf(Positions.Find(ActorRef) != -1)
			ReportAndFail("Failed to add actor -- They have been already added to this thread", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		ElseIf(ActorLib.ValidateActor(ActorRef) < 0)
			ReportAndFail("Failed to add actor -- They are not a valid target for animation", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		sslActorAlias Slot = PickAlias(ActorRef)
		If(!Slot || !Slot.SetActorEx(ActorRef, IsVictim, Voice, ForceSilent))
			ReportAndFail("Failed to add actor -- They were unable to fill an actor alias", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		Positions = PapyrusUtil.PushActor(Positions, ActorRef)
		return Positions.Find(ActorRef)
	EndFunction

	bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
		int i = 0
		While(i < ActorList.Length)
			If(AddActor(ActorList[i], ActorList[i] == VictimActor) == -1)
				return false
			EndIf
			i += 1
		EndWhile
		return true
	EndFunction

	bool Function SetAnimationsByTags(String asTags, int aiUseBed)
		int[] keys = GetPositionData()
		If(!keys.Length)
			return false
		EndIf
		keys = sslActorData.SortDataKeys(keys)
		sslBaseAnimation[] anims = AnimSlots.GetAnimationsByKeys(keys, asTags, aiUseBed - 1)
		If(anims.Length)
			PrimaryAnimations = anims
			return true
		EndIf
		return false
	EndFunction

	Function SetAnimations(sslBaseAnimation[] AnimationList)
		If(AnimationList.Length)
			PrimaryAnimations = AnimationList
		EndIf
	EndFunction

	sslThreadController Function StartThread()
		SendThreadEvent("AnimationStarting")
		UnregisterForUpdate()

		ThreadHooks = Config.GetThreadHooks()
		HookAnimationStarting()

		; ------------------------- ;
		; --   Validate Actors   -- ;
		; ------------------------- ;

		Positions = PapyrusUtil.RemoveActor(Positions, none)
		If(Positions.Length < 1 || Positions.Length >= POSITION_COUNT_MAX)
			ReportAndFail("Failed to start Thread -- No valid actors available for animation")
			return none
		ElseIf(Positions.Find(none) != -1)
			ReportAndFail("Failed to start Thread -- Positions array contains invalid values")
			return none
		EndIf
		ArrangePositions()

		; Legacy Data
		int[] g = ActorLib.GetGendersAll(Positions)
		Genders[0] = PapyrusUtil.CountInt(g, 0)
		Genders[1] = PapyrusUtil.CountInt(g, 1)
		Genders[2] = PapyrusUtil.CountInt(g, 2)
		Genders[3] = PapyrusUtil.CountInt(g, 3)

		; ------------------------- ;
		; -- Validate Animations -- ;
		; ------------------------- ;

		CustomAnimations = ValidateAnimations(CustomAnimations)
		If(CustomAnimations.Length)
			AddCommonTags(CustomAnimations)
			If(LeadIn)
				Log("WARNING: LeadIn detected on custom Animations. Disabling LeadIn")
				LeadIn = false
			EndIf
		Else
			; No Custom Animations. If there were thered be no point validating these
			PrimaryAnimations = ValidateAnimations(PrimaryAnimations)
			If(LeadIn)
				LeadAnimations = ValidateAnimations(LeadAnimations)
				If(!LeadAnimations.Length)
					LeadAnimations = AnimSlots._GetAnimations(GetPositionData(), Utility.CreateStringArray(0))
					LeadIn = LeadAnimations.Length
				EndIf
			Else
				; COMEBACK: This doesnt actually do anything, idk why its there or if I should remove it
				; float LeadInCoolDown = Math.Abs(SexLabUtil.GetCurrentGameRealTime() - StorageUtil.GetFloatValue(Config,"SexLab.LastLeadInEnd",0))
				; If(LeadInCoolDown < Config.LeadInCoolDown)
				; 	Log("LeadIn CoolDown " + LeadInCoolDown + "::" + Config.LeadInCoolDown)
				; 	DisableLeadIn(True)
				; ElseIf(Config.LeadInCoolDown > 0 && PrimaryAnimations && PrimaryAnimations.Length && AnimSlots.CountTag(PrimaryAnimations, "Anal,Vaginal") < 1)
				; 	Log("None of the PrimaryAnimations have 'Anal' or 'Vaginal' tags. Disabling LeadIn")
				; 	DisableLeadIn(True)
				; EndIf
			EndIf
			If(PrimaryAnimations.Length)
				AddCommonTags(PrimaryAnimations)
			ElseIf(!LeadAnimations.Length)
				ReportAndFail("Failed to start Thread -- No valid animations for given actors")
				return none
			EndIf
		EndIf
		
		; ------------------------- ;
		; --   Validate Center   -- ;
		; ------------------------- ;

		If(!CenterRef)
			; Lil bit odd to read. 'CenterOnBed' return true if a center bed was set, thus never entering this branch
			If(ActorCount == Creatures || HasTag("Furniture") || !CenterOnBed(HasPlayer, 750.0))
				int n = Positions.Find(PlayerRef)
				If(n == -1)
					int j = 0
					While(j < Positions.Length)
						If(!Positions[j].GetFurnitureReference() && !Positions[j].IsSwimming() && !Positions[j].IsFlying())
							n = j
							j = Positions.Length
						Else
							j += 1
						EndIf
					EndWhile
					If(n == -1)
						n = 0
					EndIf
				EndIf
				CenterOnObject(Positions[n])
			EndIf
		EndIf
		If(Config.ShowInMap && !HasPlayer && PlayerRef.GetDistance(CenterRef) > 750)
			SetObjectiveDisplayed(0, True)
		EndIf

		; ------------------------- ;
		; --   Start Animatino   -- ;
		; ------------------------- ;

		Log("Successfully Validated Thread")
		HookAnimationPrepare()
		If(!StartingAnimation || Animations.Find(StartingAnimation) == -1)
			int r = Utility.RandomInt(0, Animations.Length - 1)
			StartingAnimation = Animations[r]
		EndIf
		SetAnimationImpl(StartingAnimation)
		SyncEvent(kPrepareActor)
		If(HasPlayer)
			Config.ApplyFade()
		EndIf
		return self as sslThreadController
	EndFunction

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

	Event OnBeginState()
		Log("Entering Making State")
		RegisterForSingleUpdate(60.0)
		; Action Events
		; COMEBACK: Realign Actors can be called rightaway after rewrite, this event should become unnecessary
		RegisterForModEvent(Key("RealignActors"), "RealignActors") ; To be used by the ConfigMenu without the CloseConfig issue ; Just dont use Utility.Wait?
		RegisterForModEvent(Key(EventTypes[0]+"Done"), EventTypes[0]+"Done")
	EndEvent
	Event OnUpdate()
		ReportAndFail("Thread has timed out of the making process; resetting model for selection pool")
	EndEvent

	; Invoked after SyncEvent(kPrepareActor) is done for all actors
	Event PrepareDone()
		PlaceActors()
		Stage = 1
		GoToState("Animating")
		If(HasPlayer)
			Config.RemoveFade()
		EndIf
	EndEvent

	; Can only be called between Alias setup & 1st sync call (no need to consider async calls)
	Function ReportAndFail(string msg, string src = "", bool halt = true)
		int i = 0
		While(i < ActorAlias.Length)
			ActorAlias[i].TryToClear()
			i += 1
		EndWhile
		GoToState("")
		ReportAndFail(msg, src, true)
	EndFunction
EndState

; ------------------------------------------------------- ;
; --- Animation Loop		                              --- ;
; ------------------------------------------------------- ;

; SFX
float SFXDelay
float SFXTimer

; Processing
bool TimedStage
float StageTimer

State Animating
	Event OnBeginState()
		SendThreadEvent("AnimationStart")
		If(LeadIn)
			SendThreadEvent("LeadInStart")
		EndIf
		StartedAt = SexLabUtil.GetCurrentGameRealTime()
		SkillTime = SkillTime
		SFXDelay = Config.SFXDelay
		PlayStageAnimations()
		ResolveTimers()
		StageTimer = StartedAt + GetTimer()
		RegisterForSingleUpdate(0.5)
		SendThreadEvent("StageStart")
		HookStageStart()
	EndEvent

	Function GoToStage(int ToStage)
		UnregisterForUpdate()
		SendThreadEvent("StageEnd")
		HookStageEnd()
		Stage = ToStage
		If(Stage > Animation.StageCount)
			If(LeadIn)
				EndLeadInImpl()
			Else
				EndAnimation()
			EndIf
			return
		EndIf
		PlayStageAnimations()
		If(!LeadIn && Stage >= Animation.StageCount && !DisableOrgasms)
			SendThreadEvent("OrgasmStart")
			TriggerOrgasm()
		EndIf
		SFXDelay = PapyrusUtil.ClampFloat(Config.SFXDelay - (Stage * 0.3), 0.5, 30.0)
		ResolveTimers()
		StageTimer = SexLabUtil.GetCurrentGameRealTime() + GetTimer()
		RegisterForSingleUpdate(0.5)
		SendThreadEvent("StageStart")
		HookStageStart()
	EndFunction
	
	Event OnUpdate()
		float rt = SexLabUtil.GetCurrentGameRealTime()
		If((AutoAdvance || TimedStage || Animation.HasTimer(Stage)) && StageTimer < rt)
			GoToStage(Stage + 1)
			return
		EndIf
		; Play SFX	
		; IDEA: Decouple from main loop and use actor specific ones instead
		If(SoundFX && SFXTimer < rt)
			SoundFX.Play(_Center)
			SFXTimer = rt + SFXDelay
		EndIf
		RegisterForSingleUpdate(0.5)
	EndEvent

; ------------------------------------------------------- ;
; --- TODO: REVIEW EVERYTHING BELOW                   --- ;
; ------------------------------------------------------- ;

	Function TriggerOrgasm()
		UnregisterForUpdate()
		if SoundFX
			SoundFX.Play(_Center)
		endIf
		QuickEvent("Orgasm")
		RegisterForSingleUpdate(0.5)
	EndFunction

	Function ChangeActors(Actor[] NewPositions)
		NewPositions = PapyrusUtil.RemoveActor(NewPositions, none)
		If(NewPositions.Length == Positions.Length)
			int i = 0
			While(i < NewPositions.Length)
				If(Positions.Find(NewPositions[i]) == -1)
					i = NewPositions.Length
				EndIf
				i += 1
			EndWhile
			If(i == NewPositions.Length)
				return
			EndIf
		ElseIf(!NewPositions.Length || NewPositions.Length > POSITION_COUNT_MAX)
			return
		EndIf
		UnregisterforUpdate()
		SendThreadEvent("ActorChangeStart")
		int i = 0
		While(i < Positions.Length)
			int w = NewPositions.Find(Positions[i])
			If(w == -1)
				ActorAlias[i].UnplaceActor()
				ActorAlias[i].Clear()
			EndIf
			i += 1
		EndWhile
		int n = 0
		While(n < NewPositions.Length)
			int w = Positions.Find(NewPositions[n])
			If(w == -1)
				sslActorAlias slot = PickAlias(NewPositions[n])
				If(slot.SetActor(NewPositions[n]))
					slot.SetData()
					If(NewPositions[n].GetActorValue("Paralysis") > 0)
						NewPositions[n].SetActorValue("Paralysis", 0.0)
						slot.SendDefaultAnimEvent()
						slot.PlaceActor(_Center)
					EndIf
				EndIf
			EndIf
			n += 1
		EndWhile
		ArrangePositions()
		float[] offsets = Animation.PositionOffsetsEx(AdjustKey, Stage, BedStatus[1])
		sslpp.SetPositionsEx(Positions, _Center, offsets)

		int[] g = ActorLib.GetGendersAll(Positions)
		Genders[0] = PapyrusUtil.CountInt(g, 0)
		Genders[1] = PapyrusUtil.CountInt(g, 1)
		Genders[2] = PapyrusUtil.CountInt(g, 2)
		Genders[3] = PapyrusUtil.CountInt(g, 3)

		int[] keys = GetPositionDataConfig()
		If(!Animation.MatchKeys(keys))
			If(Genders[2] || Genders[3])
				PrimaryAnimations = CreatureSlots._GetAnimations(keys, Tags)
			Else
				PrimaryAnimations = AnimSlots._GetAnimations(keys, Tags)
			EndIf
			If(!PrimaryAnimations.Length)
				If(Genders[2] || Genders[3])
					PrimaryAnimations = CreatureSlots._GetAnimations(keys, none)
				Else
					PrimaryAnimations = AnimSlots._GetAnimations(keys, none)
				EndIf
			EndIf
			If(PrimaryAnimations.Length)
				int r = Utility.RandomInt(0, PrimaryAnimations.Length - 1)
				Animation = PrimaryAnimations[r]
				If(LeadIn)
					EndLeadInImpl()
				Else
					GoToStage(Stage)
				EndIf
			Else
				Log("ERROR - Changing Actors but no animations available to animate new Set. Ending animation...")
				EndAnimation()
			EndIf
		Else
			GoToStage(Stage)
		EndIf
		SendThreadEvent("ActorChangeEnd")
	EndFunction

	Event OnEndState()
		UnregisterForUpdate()
		If(!LeadIn && Stage >= Animation.StageCount && !DisableOrgasms)
			SendThreadEvent("OrgasmEnd")
		EndIF
	EndEvent
EndState

; ------------------------------------------------------- ;
; --- Actor Setup                                     --- ;
; ------------------------------------------------------- ;

bool Function UseLimitedStrip()
	bool LeadInNoBody = !(Config.StripLeadInMale[2] || Config.StripLeadInFemale[2])
	return (LeadIn && (!LeadInNoBody || AnimSlots.CountTag(Animations, "LimitedStrip") == Animations.Length)) || (Config.LimitedStrip && ((!LeadInNoBody && AnimSlots.CountTag(Animations, "Kissing,Foreplay,LeadIn,LimitedStrip") == Animations.Length) || (LeadInNoBody && AnimSlots.CountTag(Animations, "LimitedStrip") == Animations.Length)))
EndFunction

; Actor Overrides
Function SetStrip(Actor ActorRef, bool[] StripSlots)
	if StripSlots && StripSlots.Length == 33
		ActorAlias(ActorRef).OverrideStrip(StripSlots)
	else
		Log("Malformed StripSlots bool[] passed, must be 33 length bool array, "+StripSlots.Length+" given", "ERROR")
	endIf
EndFunction

Function SetNoStripping(Actor ActorRef)
	if ActorRef
		bool[] StripSlots = new bool[33]
		sslActorAlias Slot = ActorAlias(ActorRef)
		if Slot
			Slot.OverrideStrip(StripSlots)
			Slot.DoUndress = false
		endIf
	endIf
EndFunction

Function DisableUndressAnimation(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoUndress = !disabling
	else
		ActorAlias[0].DoUndress = !disabling
		ActorAlias[1].DoUndress = !disabling
		ActorAlias[2].DoUndress = !disabling
		ActorAlias[3].DoUndress = !disabling
		ActorAlias[4].DoUndress = !disabling
	endIf
EndFunction

Function DisableRedress(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoRedress = !disabling
	else
		ActorAlias[0].DoRedress = !disabling
		ActorAlias[1].DoRedress = !disabling
		ActorAlias[2].DoRedress = !disabling
		ActorAlias[3].DoRedress = !disabling
		ActorAlias[4].DoRedress = !disabling
	endIf
EndFunction

Function DisableRagdollEnd(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoRagdoll = !disabling
	else
		ActorAlias[0].DoRagdoll = !disabling
		ActorAlias[1].DoRagdoll = !disabling
		ActorAlias[2].DoRagdoll = !disabling
		ActorAlias[3].DoRagdoll = !disabling
		ActorAlias[4].DoRagdoll = !disabling
	endIf
EndFunction

Function DisablePathToCenter(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DisablePathToCenter(disabling)
	else
		ActorAlias[0].DisablePathToCenter(disabling)
		ActorAlias[1].DisablePathToCenter(disabling)
		ActorAlias[2].DisablePathToCenter(disabling)
		ActorAlias[3].DisablePathToCenter(disabling)
		ActorAlias[4].DisablePathToCenter(disabling)
	endIf
EndFunction

Function ForcePathToCenter(Actor ActorRef = none, bool forced = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).ForcePathToCenter(forced)
	else
		ActorAlias[0].ForcePathToCenter(forced)
		ActorAlias[1].ForcePathToCenter(forced)
		ActorAlias[2].ForcePathToCenter(forced)
		ActorAlias[3].ForcePathToCenter(forced)
		ActorAlias[4].ForcePathToCenter(forced)
	endIf
EndFunction

Function SetStartAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState", float PlayTime = 0.1)
	ActorAlias(ActorRef).SetStartAnimationEvent(EventName, PlayTime)
EndFunction

Function SetEndAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState")
	ActorAlias(ActorRef).SetEndAnimationEvent(EventName)
EndFunction

; Orgasms
Function DisableAllOrgasms(bool OrgasmsDisabled = true)
	DisableOrgasms = OrgasmsDisabled
EndFunction

Function DisableOrgasm(Actor ActorRef, bool OrgasmDisabled = true)
	if ActorRef
		ActorAlias(ActorRef).DisableOrgasm(OrgasmDisabled)
	endIf
EndFunction

bool Function IsOrgasmAllowed(Actor ActorRef)
	return ActorAlias(ActorRef).IsOrgasmAllowed()
EndFunction

bool Function NeedsOrgasm(Actor ActorRef)
	return ActorAlias(ActorRef).NeedsOrgasm()
EndFunction

Function ForceOrgasm(Actor ActorRef)
	if ActorRef
		ActorAlias(ActorRef).DoOrgasm(true)
	endIf
EndFunction

; Voice
Function SetVoice(Actor ActorRef, sslBaseVoice Voice, bool ForceSilent = false)
	ActorAlias(ActorRef).SetVoice(Voice, ForceSilent)
EndFunction

sslBaseVoice Function GetVoice(Actor ActorRef)
	return ActorAlias(ActorRef).GetVoice()
EndFunction

; Actor Strapons
bool Function IsUsingStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).IsUsingStrapon()
EndFunction

Function EquipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).EquipStrapon()
EndFunction

Function UnequipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).UnequipStrapon()
EndFunction

Function SetStrapon(Actor ActorRef, Form ToStrapon)
	ActorAlias(ActorRef).SetStrapon(ToStrapon)
endfunction

Form Function GetStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).GetStrapon()
endfunction

; Expressions
Function SetExpression(Actor ActorRef, sslBaseExpression Expression)
	ActorAlias(ActorRef).SetExpression(Expression)
EndFunction
sslBaseExpression Function GetExpression(Actor ActorRef)
	return ActorAlias(ActorRef).GetExpression()
EndFunction

; Enjoyment/Pain
int Function GetEnjoyment(Actor ActorRef)
	return ActorAlias(ActorRef).GetEnjoyment()
EndFunction
int Function GetPain(Actor ActorRef)
	return ActorAlias(ActorRef).GetPain()
EndFunction

; Actor Information
int Function GetPlayerPosition()
	return Positions.Find(PlayerRef)
EndFunction

int Function GetPosition(Actor ActorRef)
	return Positions.Find(ActorRef)
EndFunction

bool Function IsPlayerActor(Actor ActorRef)
	return ActorRef == PlayerRef
EndFunction

bool Function IsPlayerPosition(int Position)
	return Position == Positions.Find(PlayerRef)
EndFunction

bool Function HasActor(Actor ActorRef)
	return ActorRef && Positions.Find(ActorRef) != -1
EndFunction

bool Function PregnancyRisk(Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
	return ActorRef && HasActor(ActorRef) && ActorCount > 1 && ActorAlias(ActorRef).PregnancyRisk() \
		&& (Males > 0 || (AllowFemaleCum && Females > 1 && Config.AllowFFCum) || (AllowCreatureCum && MaleCreatures > 0))
EndFunction

; Aggressive/Victim Setup
Function SetVictim(Actor ActorRef, bool Victimize = true)
	ActorAlias(ActorRef).SetVictim(Victimize)
EndFunction

bool Function IsVictim(Actor ActorRef)
	return HasActor(ActorRef) && Victims && Victims.Find(ActorRef) != -1
EndFunction

bool Function IsAggressor(Actor ActorRef)
	return HasActor(ActorRef) && Victims && Victims.Find(ActorRef) == -1
EndFunction

int Function GetHighestPresentRelationshipRank(Actor ActorRef)
	if Positions.Length <= 1
		If(ActorRef == Positions[0])
			return 0
		Else
			return ActorRef.GetRelationshipRank(Positions[0])
		EndIf
	endIf
	int out = -4 ; lowest possible
	int i = Positions.Length
	while i > 0 && out < 4
		i -= 1
		if Positions[i] != ActorRef
			int rank = ActorRef.GetRelationshipRank(Positions[i])
			if rank > out
				out = rank
			endIf
		endIf
	endWhile
	return out
EndFunction

int Function GetLowestPresentRelationshipRank(Actor ActorRef)
	if Positions.Length <= 1
		If(ActorRef == Positions[0])
			return 0
		Else
			return ActorRef.GetRelationshipRank(Positions[0])
		EndIf
	endIf
	int out = 4 ; highest possible
	int i = Positions.Length
	while i > 0 && out > -4
		i -= 1
		if Positions[i] != ActorRef
			int rank = ActorRef.GetRelationshipRank(Positions[i])
			if rank < out
				out = rank
			endIf
		endIf
	endWhile
	return out
EndFunction


; ------------------------------------------------------- ;
; --- Animation Setup                                 --- ;
; ------------------------------------------------------- ;

Function SetForcedAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList.Length
		CustomAnimations = AnimationList
	endIf
EndFunction

sslBaseAnimation[] Function GetForcedAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(CustomAnimations.Length)
	int i = CustomAnimations.Length
	while i > 0
		i -= 1
		Output[i] = CustomAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearForcedAnimations()
	CustomAnimations = sslUtility.AnimationArray(0)
EndFunction

Function SetAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList.Length
		PrimaryAnimations = AnimationList
	endIf
EndFunction

sslBaseAnimation[] Function GetAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(PrimaryAnimations.Length)
	int i = PrimaryAnimations.Length
	while i > 0
		i -= 1
		Output[i] = PrimaryAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearAnimations()
	PrimaryAnimations = sslUtility.AnimationArray(0)
EndFunction

Function SetLeadAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList.Length
		LeadIn = true
		LeadAnimations = AnimationList
	endIf
EndFunction

sslBaseAnimation[] Function GetLeadAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(LeadAnimations.Length)
	int i = LeadAnimations.Length
	while i > 0
		i -= 1
		Output[i] = LeadAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearLeadAnimations()
	LeadAnimations = sslUtility.AnimationArray(0)
EndFunction

; NOTE: This here is not consistent with the general idea of overriding animation arrays
Function AddAnimation(sslBaseAnimation AddAnimation, bool ForceTo = false)
	if AddAnimation
		If(PrimaryAnimations.Length == 128)
			If(!ForceTo)
				return
			EndIf
			int w = PrimaryAnimations.Find(Animation)
			If(w != 0)
				PrimaryAnimations[0] = AddAnimation
			ElseIf(PrimaryAnimations.Length > 0)
				PrimaryAnimations[1] = AddAnimation
			EndIf
		EndIf
		sslBaseAnimation[] Adding = new sslBaseAnimation[1]
		Adding[0] = AddAnimation
		PrimaryAnimations = sslUtility.MergeAnimationLists(PrimaryAnimations, Adding)
	endIf
EndFunction

Function SetStartingAnimation(sslBaseAnimation FirstAnimation)
	StartingAnimation = FirstAnimation
EndFunction

; ------------------------------------------------------- ;
; ---	NOTE: BELOW IS REVIEWED || !IMPORTANT ABOVE NEEDS REVIEW
; ------------------------------------------------------- ;

; ------------------------------------------------------- ;
; --- Thread Settings                                 --- ;
; ------------------------------------------------------- ;

Function DisableLeadIn(bool disabling = true)
	LeadIn = !disabling
EndFunction

Function DisableBedUse(bool disabling = true)
	BedStatus[0] = 0 - (disabling as int)
EndFunction

Function SetBedFlag(int flag = 0)
	BedStatus[0] = flag
EndFunction

; If any of the given Actors is using a Furniture
; return: -1 if not, 1+ for bed, 0 for any other furniture
int Function AreUsingFurniture(Actor[] ActorList)	
	int i = 0
	While(i < ActorList.Length)
		ObjectReference ref = ActorList[i].GetFurnitureReference()
		If(ref)
			return ThreadLib.GetBedType(ref)
		EndIf
		i += 1
	EndWhile
	return -1
EndFunction

; ------------------------------------------------------- ;
; --- Center			                                    --- ;
; ------------------------------------------------------- ;

Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
	CenterOnObjectImpl(CenterOn)
	; IDEA: use the resync parameter to call SetPosition here if currently in AnimationState 
EndFunction

; ------------------------------------------------------- ;
; --- Event Hooks                                     --- ;
; ------------------------------------------------------- ;

Function SetHook(string AddHooks)
	string[] newHooks = PapyrusUtil.StringSplit(AddHooks)
	Hooks = sslpp.MergeStringArrayEx(Hooks, newHooks, true)
EndFunction

string[] Function GetHooks()
	return PapyrusUtil.ClearEmpty(Hooks)
EndFunction

Function RemoveHook(string DelHooks)
	string[] remove = PapyrusUtil.StringSplit(DelHooks)
	int i = 0
	While(i < remove.Length)
		int where = Hooks.Find(remove[i])
		If(where > -1)
			Hooks[where] = ""
		EndIf
		i += 1
	EndWhile
	Hooks = PapyrusUtil.ClearEmpty(Hooks)
EndFunction

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;

string[] Function GetTags()
	return PapyrusUtil.ClearEmpty(Tags)
EndFunction

bool Function HasTag(string Tag)
	return Tags.Find(Tag) != -1
EndFunction

bool Function AddTag(string Tag)
	if Tag != "" && Tags.Find(Tag) == -1
		Tags = PapyrusUtil.PushString(Tags, Tag)
		return true
	endIf
	return false
EndFunction

bool Function AddTags(String[] asTags)
	Tags = sslpp.MergeStringArrayEx(Tags, asTags, true)
	return true
EndFunction

bool Function RemoveTag(string Tag)
	if Tag != "" && Tags.Find(Tag) != -1
		Tags = PapyrusUtil.RemoveString(Tags, Tag)
		return true
	endIf
	return false
EndFunction

; ------------------------------------------------------- ;
; --- Actor Alias                                     --- ;
; ------------------------------------------------------- ;

int Function FindSlot(Actor ActorRef)
	if !ActorRef
		return -1
	endIf
	int i
	while i < 5
		if ActorAlias[i].ActorRef == ActorRef
			return i
		endIf
		i += 1
	endWhile
	return -1
EndFunction

sslActorAlias Function ActorAlias(Actor ActorRef)
	int SlotID = FindSlot(ActorRef)
	if SlotID != -1
		return ActorAlias[SlotID]
	endIf
	return none
EndFunction

sslActorAlias Function PositionAlias(int Position)
	if Position < 0 || !(Position < Positions.Length)
		return none
	endIf
	return ActorAlias[Position]
EndFunction

; ------------------------------------------------------- ;
; ---	Animation	Start                                 --- ;
; ------------------------------------------------------- ;

sslBaseAnimation[] Function ValidateAnimations(sslBaseAnimation[] akAnimations)
	If(!akAnimations.Length)
		return akAnimations
	EndIf
	int[] valids = Utility.CreateIntArray(akAnimations.Length, -1)
	int[] pkeys = GetPositionDataConfig()
	Log("Validating " + akAnimations.Length + " Animations with keys = " + pkeys + " | Scene tags = " + tags)
	int n = 0
	While(n < akAnimations.Length)
		Log("Validating Animation Nr. " + n + " | Keys = " + akAnimations[n].DataKeys() + " | Tags = " + akAnimations[n].GetTags())
		If(akAnimations[n] && akAnimations[n].MatchKeys(pkeys) && akAnimations[n].MatchTags(Tags))
			valids[n] = n
		EndIf
		n += 1
	EndWhile
	valids = PapyrusUtil.RemoveInt(valids, -1)
	If(!valids.Length)
		Log("No animations left, attempting shift...")
		valids = Utility.CreateIntArray(akAnimations.Length, -1)
		int j = 0
		While(j < akAnimations.Length)
			Log("Validating Animation Nr. " + j + " | Keys = " + akAnimations[j].DataKeys() + " | Tags = " + akAnimations[j].GetTags())
			If(akAnimations[j] && (!positions_shifted && ValidateShift(pkeys, akAnimations[j]) || akAnimations[j].MatchKeys(pkeys)) && akAnimations[j].MatchTags(Tags))
				positions_shifted = true
				valids[j] = j
			EndIf
			j += 1
		EndWhile
		valids = PapyrusUtil.RemoveInt(valids, -1)
	EndIf
	sslBaseAnimation[] ret
	If(valids.Length != akAnimations.Length)
		ret = sslUtility.AnimationArray(valids.Length)
		int i = 0
		While(i < ret.Length)
			ret[i] = akAnimations[valids[i]]
			i += 1
		EndWhile
	Else
		ret = akAnimations
	EndIf
	Log("Post Validation, Animations left: " + ret.Length)
	return ret
EndFunction

bool Function ValidateShift(int[] aiKeys, sslBaseAnimation akValidate)
	Log("Validating Shift")
	; TODO: Consider Config to validate, let futas be female first then male or so
	int k = aiKeys.Length
	While(k > 0)
		k -= 1
		If(sslActorData.IsFuta(aiKeys[k]))
			aiKeys[k] = ActorAlias[k].OverwriteMyGender(false)
			If(akValidate.MatchKeys(sslActorData.SortDataKeys(aiKeys)))
				ArrangePositions()
				return true
			EndIf
		EndIf
	EndWhile
	int j = aiKeys.Length
	While(j > 0)
		j -= 1
		If(sslActorData.IsFemale(aiKeys[j]))
			aiKeys[k] = ActorAlias[k].OverwriteMyGender(false)
			If(akValidate.MatchKeys(sslActorData.SortDataKeys(aiKeys)))
				ArrangePositions()
				return true
			EndIf
		EndIf
	EndWhile
	; No animations found, make sure that all key manipulation is reset
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].ResetDataKey()
		ArrangePositions()
		i += 1
	EndWhile
	return false
EndFunction

; Assume all Actors have all necessary data set
Function PlaceActors()
	float w = 0.0
	int i = 0
	While(i < Positions.Length)
		float ww = ActorAlias[i].PlaceActor(_Center)
		If(ww > w)
			w = ww
		EndIf
		i += 1
	EndWhile
	; If placing includes an animation, wait for longest to finish
	If(w > 0)
		Utility.Wait(w)
	EndIf
	float[] offsets = Animation.PositionOffsetsEx(AdjustKey, Stage, BedStatus[1])
	sslpp.SetPositionsEx(Positions, _Center, offsets)
EndFunction

; ------------------------------------------------------- ;
; ---	Animation				                                --- ;
; ------------------------------------------------------- ;

; Set the Active Animation & update the stage
; This should only be called from State "Animating"
Function SetAnimation(int aid = -1)
	; Randomize if -1
	if aid < 0 || aid >= Animations.Length
		aid = Utility.RandomInt(0, (Animations.Length - 1))
	endIf
	RecordSkills()
	SetAnimationImpl(Animations[aid])
	; Reset the currently playing animation
	; ResetPositions()	; TODO: New Animation => Check Position Adjustments
	If(Stage >= Animation.StageCount)
		GoToStage(Animation.StageCount - 1)
	Else
		GoToStage(Stage)
	EndIf
EndFunction

; Set active animation data only
Function SetAnimationImpl(sslBaseAnimation akAnimation)
	Animation = akAnimation
	LogConsole("Setting Animation to " + Animation.Name)
	String[] animtags = Animation.GetTags()
	; IsType = [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty, [6] HadVaginal, [7] HadAnal, [8] HadOral
	IsType[1] = Females && Tags.Find("Vaginal") != -1
	IsType[2] = animtags.Find("Anal") 	!= -1 || !Females && Tags.Find("Vaginal") != -1
	IsType[3] = animtags.Find("Oral") 	!= -1
	IsType[4] = animtags.Find("Loving") != -1
	IsType[5] = animtags.Find("Dirty") 	!= -1
	SetBonuses()
	SoundFX = Animation.GetSoundFX(Stage)
	; TODO: Define Position Adjustment Data
EndFunction

Function PlayStageAnimations()
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].SyncThread()
		i += 1
	EndWhile
	; Wanna split this into 2 loops to minimize possible delays for anim event calls
	Animation.GetAnimEvents(AnimEvents, Stage)
	Log("Playing Stage Animations for animation " + Animation.Name + " with Events = " + AnimEvents)
	int n = 0
	While(n < Positions.Length)
		ActorAlias[n].PlayAnimation(AnimEvents[n])
		n += 1
	EndWhile
	float[] offsets = Animation.PositionOffsetsEx(AdjustKey, Stage, BedStatus[1])
	sslpp.SetPositionsEx(Positions, _Center, offsets)
EndFunction

; End leadin -> Start default animation
Function EndLeadInImpl()
	Stage  = 1
	LeadIn = false
	SetAnimation()
	; Add runtime to foreplay skill xp
	SkillXP[0] = SkillXP[0] + (TotalTime / 10.0)
	; Restrip with new strip options
	; TODO: Get rid of this "QuickEvent" stuff
	QuickEvent("Strip")
	; Start primary animations at stage 1
	StorageUtil.SetFloatValue(Config, "SexLab.LastLeadInEnd", SexLabUtil.GetCurrentGameRealTime())
	SendThreadEvent("LeadInEnd")
	GoToStage(1)
EndFunction

; ------------------------------------------------------- ;
; ---	Timers  				                                --- ;
; ------------------------------------------------------- ;

; COMEBACK: Check if this works as intended
Function ResolveTimers()
	TimedStage = Animation.HasTimer(Stage)
	If(TimedStage)
		Log("Stage has timer: "+Animation.GetTimer(Stage))
	EndIf
	If(!UseCustomTimers)
		if LeadIn
			ConfigTimers = Config.StageTimerLeadIn
		elseIf IsAggressive
			ConfigTimers = Config.StageTimerAggr
		else
			ConfigTimers = Config.StageTimer
		endIf
	EndIf
EndFunction

Function UpdateTimer(float AddSeconds = 0.0)
	TimedStage = true
	StageTimer += AddSeconds
EndFunction

Function SetTimers(float[] SetTimers)
	if !SetTimers || SetTimers.Length < 1
		Log("SetTimers() - Empty timers given.", "ERROR")
	else
		CustomTimers    = SetTimers
		UseCustomTimers = true
	endIf
EndFunction

float Function GetTimer()
	TimedStage = Animation.HasTimer(Stage)
	if TimedStage
		return Animation.GetTimer(Stage)
	endIf
	return GetStageTimer(Animation.StageCount)
EndFunction

float Function GetStageTimer(int maxstage)
	int last = Timers.Length - 1
	if Stage < last
		return Timers[(Stage - 1)]
	elseIf Stage >= maxstage
		return Timers[last]
	endIf
	return Timers[(last - 1)]
endfunction

; ------------------------------------------------------- ;
; ---	Animation	End		                                --- ;
; ------------------------------------------------------- ;

Function EndAnimation(bool Quickly = false)
	UnregisterForUpdate()
	; Apparently the OnUpdate() cycle can carry over into a new state despite being unregistered
	; I dont want to believe it myself its apparently a thing, so waiting 1 update cycle here just to be sure
	Utility.Wait(0.6)	
	GoToState("Ending")
EndFunction

State Ending
	Event OnBeginState()
		SendThreadEvent("AnimationEnding")
		HookAnimationEnding()
		Config.DisableThreadControl(self as sslThreadController)
		UnregisterForAllKeys()
		If(IsObjectiveDisplayed(0))
			SetObjectiveDisplayed(0, False)
		EndIf
		RecordSkills()
		UnplaceActors()
		If(UsingBed && CenterRef.IsActivationBlocked())
			SetFurnitureIgnored(false)
		EndIf
		SendThreadEvent("AnimationEnd")
		HookAnimationEnd()
		int i = 0
		While(i < Positions.Length)
			ActorAlias[i].DoStatistics()
			ActorAlias[i].Clear()
			i += 1
		EndWhile
		; Some time for Thread Events to finish running
		RegisterForSingleUpdate(15)
	EndEvent

	Event OnUpdate()
		Initialize()
	EndEvent

	Event OnEndState()
		Log("Returning to thread pool...")
	EndEvent

	; Don't allow to be called twice
	Function EndAnimation(bool Quickly = false)
	EndFunction
EndState

; Only call on placed actors, will unplace all actors, allowing them to move freely again
; Will take them out of the animation if currently animating
Function UnplaceActors()
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].UnplaceActor()
		i += 1
	EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Tagging                                         --- ;
; ------------------------------------------------------- ;

Function AddCommonTags(sslBaseAnimation[] akAnimations)
	String[] commons = akAnimations[0].GetTags()
	int i = 1
	While(i < akAnimations.Length)
		String[] animtags = akAnimations[i].GetTags()
		int k = commons.Length
		While(k > 0)
			k -= 1
			If(animtags.Find(commons[k]) == -1)
				commons = sslpp.RemoveStringEx(commons, commons[k])
				If(!commons.Length)
					return
				EndIf
			EndIf
		EndWhile
		i += 1
	EndWhile
	AddTags(commons)
EndFunction

; ------------------------------------------------------- ;
; --- Center                                          --- ;
; ------------------------------------------------------- ;

Function CenterOnObjectImpl(ObjectReference akNewCenter)
	If(!akNewCenter)
		return
	EndIf
	_Center = akNewCenter.PlaceAtMe(Config.BaseMarker)
	CenterAlias.ForceRefTo(akNewCenter)
	CenterLocation[0] = akNewCenter.GetPositionX()
	CenterLocation[1] = akNewCenter.GetPositionY()
	CenterLocation[2] = akNewCenter.GetPositionZ()
	CenterLocation[3] = akNewCenter.GetAngleX()
	CenterLocation[4] = akNewCenter.GetAngleY()
	CenterLocation[5] = akNewCenter.GetAngleZ()
	If(sslpp.IsBed(akNewCenter))
		BedStatus[1] = ThreadLib.GetBedType(akNewCenter)
		BedRef = akNewCenter
		SetFurnitureIgnored(true)
		float offsetX
		float offsetY
		float offsetZ
		float offsAnZ
		If(BedStatus[1] == 1)
			offsetZ = 7.5 ; Average Z offset for bedrolls
			offsAnZ = 180 ; bedrolls are usually rotated 180° on Z
		Else
			int offset = -31 ; + ((_Positions_var.find(playerref) > -1) as int) * 36
			offsetX = Math.Cos(sslUtility.TrigAngleZ(CenterLocation[5])) * offset
			offsetY = Math.Sin(sslUtility.TrigAngleZ(CenterLocation[5])) * offset
			offsetZ = 45 ; Z offset for beds
		EndIf
		float scale = akNewCenter.GetScale()
		If(scale != 1.0)
			offsetX *= scale
			offsetY *= scale
			If(CenterLocation[2] < 0)
				offsetZ *= (2 - scale) ; Assming Scale will always be in [0; 2)
			Else
				offsetZ *= scale
			EndIf
		EndIf
		CenterLocation[0] = CenterLocation[0] + offsetX
		CenterLocation[1] = CenterLocation[1] + offsetY
		CenterLocation[2] = CenterLocation[2] + offsetZ
		CenterLocation[5] = CenterLocation[5] - offsAnZ
		CenterRef.SetPosition(CenterLocation[0], CenterLocation[1], CenterLocation[2])
		CenterRef.SetAngle(CenterLocation[3], CenterLocation[4], CenterLocation[5])
	Else
		BedStatus[1] = 0
		BedRef = none
	EndIf
	Log("Creating new Center Ref from = " + akNewCenter + " at Coordinates = " + CenterLocation + "(New Center is Bed Type: " + BedStatus[1] + ")")
EndFunction

; COMEBACK: This here should be completely pointless but might wanna check that it doesnt break anythin just to be sure
Function CenterOnCoords(float LocX = 0.0, float LocY = 0.0, float LocZ = 0.0, float RotX = 0.0, float RotY = 0.0, float RotZ = 0.0, bool resync = true)
	; CenterLocation[0] = LocX
	; CenterLocation[1] = LocY
	; CenterLocation[2] = LocZ
	; CenterLocation[3] = RotX
	; CenterLocation[4] = RotY
	; CenterLocation[5] = RotZ
EndFunction

bool Function CenterOnBed(bool AskPlayer = true, float Radius = 750.0)
	If(BedStatus[0] == -1)
		return false
	ElseIf(GetState() == "Making" && (!HasPlayer && Config.NPCBed == 0 || HasPlayer && Config.AskBed == 0))
		return false
	EndIf
 	ObjectReference FoundBed
	int i = 0
	While (i < Positions.Length)
		FoundBed = Positions[i].GetFurnitureReference()
		int BedType = ThreadLib.GetBedType(FoundBed)	; 0 if no bed
		If(BedType > 0 && (Positions.Length <= 2 || BedType != 2))
			CenterOnObject(FoundBed)
			return true
		Else
			i += 1
		EndIf
	EndWhile
	Radius *= 1 + BedStatus[0]	; Double r if forced (BedStatus[0] == 1)
	If(HasPlayer)
		; Config.AskBed: 0 - Never, 1 - Alwys, 2 - If not victim
		If(;/ !InStart || /; Config.AskBed == 1 || Config.AskBed == 2 && (!IsVictim(PlayerRef) || UseNPCBed))
			FoundBed = sslpp.GetNearestUnusedBed(PlayerRef, Radius)
			AskPlayer = AskPlayer && (;/ !InStart || /; Config.AskBed < 1 || !IsVictim(PlayerRef))
		EndIf
	Else
		AskPlayer = false
		If(!FoundBed && UseNPCBed)
			FoundBed = sslpp.GetNearestUnusedBed(PlayerRef, Radius)
		EndIf
	EndIf
	If(FoundBed && (BedStatus[0] == 1 || !AskPlayer || Config.UseBed.Show() as bool))
		CenterOnObject(FoundBed)
		return true
	endIf
	return false
EndFunction

; ------------------------------------------------------- ;
; --- Skill System			                              --- ;
; ------------------------------------------------------- ;

Function RecordSkills()
	float TimeNow = SexLabUtil.GetCurrentGameRealTime()
	float xp = ((TimeNow - SkillTime) / 8.0)
	if xp >= 0.5
		if IsType[1]
			SkillXP[1] = SkillXP[1] + xp
		endIf
		if IsType[2]
			SkillXP[2] = SkillXP[2] + xp
		endIf
		if IsType[3]
			SkillXP[3] = SkillXP[3] + xp
		endIf
		if IsType[4]
			SkillXP[4] = SkillXP[4] + xp
		endIf
		if IsType[5]
			SkillXP[5] = SkillXP[5] + xp
		endIf
	endIf
	SkillTime = TimeNow
endfunction

Function SetBonuses()
	SkillBonus[0] = SkillXP[0]
	if IsType[1]
		SkillBonus[1] = SkillXP[1]
	endIf
	if IsType[2]
		SkillBonus[2] = SkillXP[2]
	endIf
	if IsType[3]
		SkillBonus[3] = SkillXP[3]
	endIf
	if IsType[4]
		SkillBonus[4] = SkillXP[4]
	endIf
	if IsType[5]
		SkillBonus[5] = SkillXP[5]
	endIf
EndFunction

; ------------------------------------------------------- ;
; --- Misc Utility					                          --- ;
; ------------------------------------------------------- ;

Function ArrangePositions()
	Log("Arranging Positions - Pre Arrange -> Alias = " + ActorAlias + " | Positions = " + Positions + " | Keys = " + GetPositionData())
	int i = 1
	While(i < ActorAlias.Length)
		sslActorAlias it = ActorAlias[i]
		int n = i - 1
		While(n >= 0 && sslActorData.IsLess(it.GetActorData(), ActorAlias[n].GetActorData()))
			ActorAlias[n + 1] = ActorAlias[n]
			n -= 1
		EndWhile
		ActorAlias[n + 1] = it
		i += 1
	EndWhile
	int k = 0
	While(k < Positions.Length)
		Positions[k] = ActorAlias[k].GetReference() as Actor
		k +=1
	EndWhile
	Log("Arranging Positions - Post Arrange -> Alias = " + ActorAlias + " | Positions = " + Positions + " | Keys = " + GetPositionData())
EndFunction

Function SetFurnitureIgnored(bool disabling = true)
	If(!BedRef)
		return
	EndIf
	BedRef.SetDestroyed(disabling)
	BedRef.BlockActivation(disabling)
	BedRef.SetNoFavorAllowed(disabling)
EndFunction

sslActorAlias Function PickAlias(Actor ActorRef)
	int i
	while i < 5
		if ActorAlias[i].ForceRefIfEmpty(ActorRef)
			return ActorAlias[i]
		endIf
		i += 1
	endWhile
	return none
EndFunction

; ------------------------------------------------------- ;
; --- Thread Hooks & Events                           --- ;
; ------------------------------------------------------- ;

sslThreadHook[] ThreadHooks
Function HookAnimationStarting()
	; Log("HookAnimationStarting() - "+ThreadHooks)
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationStarting(self)
			Log("Global Hook AnimationStarting("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationStarting() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationPrepare()
	; Log("HookAnimationPrepare() - "+ThreadHooks)
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationPrepare(self as sslThreadController)
			Log("Global Hook AnimationPrepare("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationPrepare() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookStageStart()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].StageStart(self as sslThreadController)
			Log("Global Hook StageStart("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookStageStart() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookStageEnd()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].StageEnd(self as sslThreadController)
			Log("Global Hook StageEnd("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookStageEnd() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationEnding()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationEnding(self as sslThreadController)
			Log("Global Hook AnimationEnding("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationEnding() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationEnd()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationEnd(self as sslThreadController)
			Log("Global Hook AnimationEnd("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationEnd() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function SendThreadEvent(string HookEvent)
	Log(HookEvent, "Event Hook")
	SetupThreadEvent(HookEvent)
	int i = Hooks.Length
	while i
		i -= 1
		SetupThreadEvent(HookEvent+"_"+Hooks[i])
	endWhile
	; Legacy support for < v1.50 - To be removed eventually
	if HasPlayer
		SendModEvent("Player"+HookEvent, thread_id)
	endIf
EndFunction

Function SetupThreadEvent(string HookEvent)
	int eid = ModEvent.Create("Hook"+HookEvent)
	if eid
		ModEvent.PushInt(eid, thread_id)
		ModEvent.PushBool(eid, HasPlayer)
		ModEvent.Send(eid)
		; Log("Thread Hook Sent: "+HookEvent)
	endIf
	SendModEvent(HookEvent, thread_id)
EndFunction

; ------------------------------------------------------- ;
; --- Alias Events									                  --- ;
; ------------------------------------------------------- ;

string[] EventTypes
int[] AliasDone

int Property kPrepareActor = 0 autoreadonly hidden

string Function Key(string Callback)
	return "SSL_" + thread_id + "_" + Callback
EndFunction

Function QuickEvent(string Callback)
	ModEvent.Send(ModEvent.Create(Key(Callback)))
endfunction

Function SyncEvent(int id)
	AliasDone[id]  = 0
	String e = Key(EventTypes[id])
	Log("Sending Sync Event " + e + " | ID = " + id)
 	ModEvent.Send(ModEvent.Create(e))
EndFunction

bool SyncLock = false
Function SyncEventDone(int id)
	while SyncLock
		Utility.WaitMenuMode(0.01)
	endWhile
	SyncLock = true
	Log("Sync Event Done for ID = " + id)
	AliasDone[id] = AliasDone[id] + 1
	If(AliasDone[id] == Positions.Length)
		ModEvent.Send(ModEvent.Create(Key(EventTypes[id]+"Done")))
	EndIf
	SyncLock = false
EndFunction

; ------------------------------------------------------- ;
; --- Thread Setup    								                --- ;
; ------------------------------------------------------- ;

Auto State Unlocked
	sslThreadModel Function Make()
		InitShares()
		if !Initialized
			Initialize()
		endIf
		Initialized = false
		GoToState("Making")
		return self
	EndFunction

	Function EndAnimation(bool Quickly = false)
	EndFunction
EndState

Function Log(string msg, string src = "")
	msg = "Thread["+thread_id+"] "+src+" - "+msg
	Debug.Trace("SEXLAB - " + msg)
	If(DebugMode)
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	EndIf
EndFunction

Function LogConsole(String asReport)
	String msg = "Thread[" + thread_id + "] - " + asReport
	SexLabUtil.PrintConsole(msg)
	Debug.Trace("SEXLAB - " + msg)
EndFunction

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.")
EndFunction

Function ReportAndFail(string msg, string src = "", bool halt = true)
	msg = "SEXLAB - FATAL - Thread["+thread_id+"] " + src + " - " + msg
	Debug.TraceStack(msg)
	SexLabUtil.PrintConsole(msg)
	If(DebugMode)
		Debug.TraceUser("SexLabDebug", msg)
	EndIf
	Initialize()
EndFunction

Function SetTID(int id)
	thread_id = id
	PlayerRef = Game.GetPlayer()
	DebugMode = Config.DebugMode

	Log(self, "Setup")
	; Reset Function Libraries - SexLabQuestFramework
	if !Config || !ThreadLib || !ActorLib
		Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
		if SexLabQuestFramework
			Config    = SexLabQuestFramework as sslSystemConfig
			ThreadLib = SexLabQuestFramework as sslThreadLibrary
			ActorLib  = SexLabQuestFramework as sslActorLibrary
		endIf
	endIf
	; Reset secondary object registry - SexLabQuestRegistry
	if !CreatureSlots
		Form SexLabQuestRegistry = Game.GetFormFromFile(0x664FB, "SexLab.esm")
		if SexLabQuestRegistry
			CreatureSlots = SexLabQuestRegistry as sslCreatureAnimationSlots
		endIf
	endIf
	; Reset animation registry - SexLabQuestAnimations
	if !AnimSlots
		Form SexLabQuestAnimations = Game.GetFormFromFile(0x639DF, "SexLab.esm")
		if SexLabQuestAnimations
			AnimSlots = SexLabQuestAnimations as sslAnimationSlots
		endIf
	endIf
	
	; Init thread info
	EventTypes = new string[5]
	EventTypes[0] = "Prepare"
	EventTypes[1] = "Sync"
	EventTypes[2] = "Reset"
	EventTypes[3] = "Refresh"
	EventTypes[4] = "Startup"

	CenterAlias = GetNthAlias(5) as ReferenceAlias

	ActorAlias = new sslActorAlias[5]
	ActorAlias[0] = GetNthAlias(0) as sslActorAlias
	ActorAlias[1] = GetNthAlias(1) as sslActorAlias
	ActorAlias[2] = GetNthAlias(2) as sslActorAlias
	ActorAlias[3] = GetNthAlias(3) as sslActorAlias
	ActorAlias[4] = GetNthAlias(4) as sslActorAlias

	ActorAlias[0].Setup()
	ActorAlias[1].Setup()
	ActorAlias[2].Setup()
	ActorAlias[3].Setup()
	ActorAlias[4].Setup()
	
	InitShares()
	Initialize()
EndFunction

Function InitShares()
	DebugMode      = Config.DebugMode
	AnimEvents     = new string[5]
	IsType         = new bool[9]
	BedStatus      = new int[2]
	AliasDone      = new int[6]
	SkillXP        = new float[6]
	SkillBonus     = new float[6]
	CenterLocation = new float[6]
	if EventTypes.Length != 5 || EventTypes.Find("") != -1
		EventTypes = new string[5]
		EventTypes[0] = "Prepare"
		EventTypes[1] = "Sync"
		EventTypes[2] = "Reset"
		EventTypes[3] = "Refresh"
		EventTypes[4] = "Startup"
	endIf
	if !CenterAlias
		CenterAlias = GetAliasByName("CenterAlias") as ReferenceAlias
	endIf
EndFunction

bool Initialized
Function Initialize()
	UnregisterForUpdate()
	If(CenterAlias.GetReference())
		CenterAlias.Clear()
	EndIf
	; Forms
	Animation = none
	CenterRef = none
	SoundFX = none
	BedRef = none
	StartingAnimation = none
	; Boolean
	positions_shifted = false
	UseCustomTimers = false
	DisableOrgasms = false
	AutoAdvance = true
	LeadIn = false
	; Floats
	StartedAt = 0.0
	SkillTime = 0.0
	; Integers
	Stage = 1
	; Storage Data
	Genders = new int[4]
	Victims = PapyrusUtil.ActorArray(0)
	Positions = PapyrusUtil.ActorArray(0)
	CustomAnimations = sslUtility.AnimationArray(0)
	PrimaryAnimations = sslUtility.AnimationArray(0)
	LeadAnimations = sslUtility.AnimationArray(0)
	Hooks = Utility.CreateStringArray(0)
	Tags = Utility.CreateStringArray(0)
	CustomTimers = Utility.CreateFloatArray(0)
	; Enter thread selection pool
	GoToState("Unlocked")
	Initialized = true
EndFunction

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; Making
sslThreadModel Function Make()
	Log("Cannot enter make on a locked thread", "Make() ERROR")
	return none
EndFunction
sslThreadController Function StartThread()
	Log("Cannot start thread while not in a Making State", "StartThread() ERROR")
	return none
EndFunction
int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
	Log("Cannot add an actor to a locked thread", "AddActor() ERROR")
	return -1
EndFunction
bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
	Log("Cannot add a list of actors to a locked thread", "AddActors() ERROR")
	return false
EndFunction
; State varied
Function FireAction()
EndFunction
Function EndAction()
EndFunction
Function SyncDone()
EndFunction
Function RefreshDone()
EndFunction
Function PrepareDone()
EndFunction
Function ResetDone()
EndFunction
Function StripDone()
EndFunction
Function OrgasmDone()
EndFunction
Function StartupDone()
EndFunction
bool Function SetAnimationsByTags(String asTags, int aiUseBed)
EndFunction
; Animating
Function TriggerOrgasm()
EndFunction
Function GoToStage(int ToStage)
EndFunction
Function ChangeActors(Actor[] NewPositions)
EndFunction
Function EnableHotkeys(bool forced = false)
EndFunction
Function RealignActors()
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

bool Function HasPlayer()
	return HasPlayer
EndFunction
Actor Function GetPlayer()
	return PlayerRef
EndFunction
Actor Function GetVictim()
	return VictimRef
EndFunction
float Function GetTime()
	return StartedAt
endfunction
Function SetBedding(int flag = 0)
	SetBedFlag(flag)
EndFunction

bool Property FastEnd auto hidden

; Unnecessary, just use OnBeginState()/OnEndState()
Function Action(string FireState)
	UnregisterForUpdate()
	EndAction()
	GoToState(FireState)
	FireAction()
endfunction

Function RemoveFade()
	if HasPlayer
		Config.RemoveFade()
	endIf
EndFunction

Function ApplyFade()
	if HasPlayer
		Config.ApplyFade()
	endIf
EndFunction

int Property ActorCount
	int Function Get()
		return Positions.Length
	EndFunction
EndProperty

Race Property CreatureRef
	Race Function Get()
		Keyword npc = Keyword.GetKeyword("ActorTypeNPC")
		int i = 0
		While(i < Positions.Length)
			If(!Positions[i].HasKeyword(npc))
				return Positions[i].GetRace()
			EndIf
		EndWhile
		return none
	EndFunction
EndProperty

float[] Property RealTime
	float[] Function Get()
		float[] ret = new float[1]
		ret[0] = SexLabUtil.GetCurrentGameRealTime()
		return ret
	EndFunction
EndProperty

Function UpdateAdjustKey()
EndFunction

bool Function CheckTags(string[] CheckTags, bool RequireAll = true, bool Suppress = false)
	int i = CheckTags.Length
	while i
		i -= 1
		if CheckTags[i] != ""
			bool Check = Tags.Find(CheckTags[i]) != -1
			if (Suppress && Check) || (!Suppress && RequireAll && !Check)
				return false ; Stop if we need all and don't have it, or are supressing the found tag
			elseIf !Suppress && !RequireAll && Check
				return true ; Stop if we don't need all and have one
			endIf
		endIf
	endWhile
	return true
EndFunction

; Might want to come back to this just to check that we actually consider all configs in the DataKey \o/
int Function FilterAnimations()
	; Filter animations based on user settings and scene
	if !CustomAnimations || CustomAnimations.Length < 1
		Log("FilterAnimations() BEGIN - LeadAnimations="+LeadAnimations.Length+", PrimaryAnimations="+PrimaryAnimations.Length)
		string[] Filters
		string[] BasicFilters
		string[] BedFilters
		sslBaseAnimation[] FilteredPrimary
		sslBaseAnimation[] FilteredLead
		int[] Futas = ActorLib.TransCount(Positions)
		int i

		; Filter tags for Male Vaginal restrictions
		if (Futas[0] + Futas[1]) < 1 && ((!Config.UseCreatureGender && ActorCount == Males) || (Config.UseCreatureGender && ActorCount == (Males + MaleCreatures)))
			BasicFilters = AddString(BasicFilters, "Vaginal")
		elseIf (HasTag("Vaginal") || HasTag("Pussy") || HasTag("Cunnilingus"))
			if FemaleCreatures <= 0
				Filters = AddString(Filters, "CreatureSub")
			endIf
		endIf

		if IsAggressive && Config.FixVictimPos
			if VictimRef == Positions[0] && ActorLib.GetGender(VictimRef) == 0 && ActorLib.GetTrans(VictimRef) == -1
				BasicFilters = AddString(BasicFilters, "Vaginal")
			endIf
			if Males > 0 && ActorLib.GetGender(VictimRef) == 1 && ActorLib.GetTrans(VictimRef) == -1
				Filters = AddString(Filters, "FemDom")
			elseIf Creatures > 0 && !ActorLib.IsCreature(VictimRef) && Males <= 0 && (!Config.UseCreatureGender || (Males + MaleCreatures) <= 0)
				Filters = AddString(Filters, "CreatureSub")
			endIf
		endIf
		
		; Filter tags for same sex restrictions
		if ActorCount == 2 && Creatures == 0 && (Males == 0 || Females == 0) && Config.RestrictSameSex
			BasicFilters = AddString(BasicFilters, SexLabUtil.StringIfElse(Females == 2, "FM", "Breast"))
		endIf
		if Config.UseStrapons && Config.RestrictStrapons && (ActorCount - Creatures) == Females && Females > 0
			Filters = AddString(Filters, "Straight")
			Filters = AddString(Filters, "Gay")
		endIf
		if BasicFilters.Find("Breast") >= 0
			Filters = AddString(Filters, "Boobjob")
		endIf

		;Remove filtered basic tags from primary
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, BasicFilters, false)
		if PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+BasicFilters)
			PrimaryAnimations = FilteredPrimary
		endIf

		; Filter tags for non-bed friendly animations
		if BedRef
			BedFilters = AddString(BedFilters, "Furniture")
			BedFilters = AddString(BedFilters, "NoBed")
			if Config.BedRemoveStanding
				BedFilters = AddString(BedFilters, "Standing")
			endIf
			if UsingBedRoll
				BedFilters = AddString(BedFilters, "BedOnly")
			elseIf UsingSingleBed
				BedFilters = AddString(BedFilters, "DoubleBed") ; For bed animations made specific for DoubleBed or requiring too mush space to use single beds
			elseIf UsingDoubleBed
				BedFilters = AddString(BedFilters, "SingleBed") ; For bed animations made specific for SingleBed
			endIf
		else
			BedFilters = AddString(BedFilters, "BedOnly")
		endIf

		; Remove any animations with filtered tags
		Filters = PapyrusUtil.RemoveString(Filters, "")
		BasicFilters = PapyrusUtil.RemoveString(BasicFilters, "")
		BedFilters = PapyrusUtil.RemoveString(BedFilters, "")
		
		; Get default creature animations if none
		if HasCreature
			if Config.UseCreatureGender
				if ActorCount != Creatures 
					PrimaryAnimations = CreatureSlots.FilterCreatureGenders(PrimaryAnimations, Genders[2], Genders[3])
				else
					;TODO: Find bether solution instead of Exclude CC animations from filter  
				endIf
			endIf
			; Pick default creature animations if currently empty (none or failed above check)
			if PrimaryAnimations.Length == 0 ; || (BasicFilters.Length > 1 && PrimaryAnimations[0].CheckTags(BasicFilters, False))
				Log("Selecting new creature animations - "+PrimaryAnimations)
				Log("Creature Genders: "+Genders)
				SetAnimations(CreatureSlots.GetByCreatureActorsTags(ActorCount, Positions, "", PapyrusUtil.StringJoin(BasicFilters, ",")))
				if PrimaryAnimations.Length == 0
					SetAnimations(CreatureSlots.GetByCreatureActors(ActorCount, Positions))
					if PrimaryAnimations.Length == 0
						ReportAndFail("Failed to find valid creature animations.")
						return -1
					endIf
				endIf
			endIf
			; Sort the actors to creature order
		;	Positions = ThreadLib.SortCreatures(Positions, Animations[0]) ; not longer needed since is already on the SetAnimation fuction

		; Get default primary animations if none
		elseIf PrimaryAnimations.Length == 0 ; || (BasicFilters.Length > 1 && PrimaryAnimations[0].CheckTags(BasicFilters, False))
			SetAnimations(AnimSlots.GetByDefaultTags(Males, Females, IsAggressive, (BedRef != none), Config.RestrictAggressive, "", PapyrusUtil.StringJoin(BasicFilters, ",")))
			if PrimaryAnimations.Length == 0
				SetAnimations(AnimSlots.GetByDefault(Males, Females, IsAggressive, (BedRef != none), Config.RestrictAggressive))
				if PrimaryAnimations.Length == 0
					ReportAndFail("Unable to find valid default animations")
					return -1
				endIf
			endIf
		endIf

		; Remove any animations without filtered gender tags
		if Config.RestrictGenderTag
			string DefGenderTag = ""
			i = ActorCount
			int[] GendersAll = ActorLib.GetGendersAll(Positions)
			int[] FutasAll = ActorLib.GetTransAll(Positions)
			while i ;Make Position Gender Tag
				i -= 1
				if GendersAll[i] == 0
					DefGenderTag = "M" + DefGenderTag
				elseIf GendersAll[i] == 1
					DefGenderTag = "F" + DefGenderTag
				elseIf GendersAll[i] >= 2
					DefGenderTag = "C" + DefGenderTag
				endIf
			endWhile
			if DefGenderTag != ""
				string[] GenderTag = Utility.CreateStringArray(1, DefGenderTag)
				;Filtering Futa animations
				if (Futas[0] + Futas[1]) < 1
					BasicFilters = AddString(BasicFilters, "Futa")
				elseIf (Futas[0] + Futas[1]) != (Genders[0] + Genders[1])
					Filters = AddString(Filters, "AllFuta")
				endIf
				;Make Extra Position Gender Tag if actor is Futanari or female use strapon
				i = ActorCount
				while i
					i -= 1
					if (Config.UseStrapons && GendersAll[i] == 1) || (FutasAll[i] == 1)
						if StringUtil.GetNthChar(DefGenderTag, ActorCount - i) == "F"
							GenderTag = AddString(GenderTag, StringUtil.Substring(DefGenderTag, 0, ActorCount - i) + "M" + StringUtil.Substring(DefGenderTag, (ActorCount - i) + 1))
						endIf
					elseIf (FutasAll[i] == 0)
						if StringUtil.GetNthChar(DefGenderTag, ActorCount - i) == "M"
							GenderTag = AddString(GenderTag, StringUtil.Substring(DefGenderTag, 0, ActorCount - i) + "F" + StringUtil.Substring(DefGenderTag, (ActorCount - i) + 1))
						endIf
					endIf
				endWhile
				if Config.UseStrapons
					DefGenderTag = ActorLib.GetGenderTag(0, Males + Females, Creatures)
					GenderTag = AddString(GenderTag, DefGenderTag)
				endIf
				DefGenderTag = ActorLib.GetGenderTag(Females, Males, Creatures)
				GenderTag = AddString(GenderTag, DefGenderTag)
				
				DefGenderTag = ActorLib.GetGenderTag(Females + Futas[0] - Futas[1], Males - Futas[0] + Futas[1], Creatures)
				GenderTag = AddString(GenderTag, DefGenderTag)
				; Remove filtered gender tags from primary
				FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, GenderTag, true)
				if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
					Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations without tags: "+GenderTag)
					PrimaryAnimations = FilteredPrimary
				endIf
				; Remove filtered gender tags from lead in
				if LeadAnimations && LeadAnimations.Length > 0
					FilteredLead = sslUtility.FilterTaggedAnimations(LeadAnimations, GenderTag, true)
					if LeadAnimations.Length > FilteredLead.Length
						Log("Filtered out '"+(LeadAnimations.Length - FilteredLead.Length)+"' lead in animations without tags: "+GenderTag)
						LeadAnimations = FilteredLead
					endIf
				endIf
			endIf
		endIf
		
		; Remove filtered tags from primary step by step
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, BedFilters, false)
		if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+BedFilters)
			PrimaryAnimations = FilteredPrimary
		endIf
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, BasicFilters, false)
		if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+BasicFilters)
			PrimaryAnimations = FilteredPrimary
		endIf
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, Filters, false)
		if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+Filters)
			PrimaryAnimations = FilteredPrimary
		endIf
		; Remove filtered tags from lead in
		if LeadAnimations && LeadAnimations.Length > 0
			Filters = PapyrusUtil.MergeStringArray(Filters, BasicFilters, true)
			Filters = PapyrusUtil.MergeStringArray(Filters, BedFilters, true)
			FilteredLead = sslUtility.FilterTaggedAnimations(LeadAnimations, Filters, false)
			if LeadAnimations.Length > FilteredLead.Length
				Log("Filtered out '"+(LeadAnimations.Length - FilteredLead.Length)+"' lead in animations with tags: "+Filters)
				LeadAnimations = FilteredLead
			endIf
		endIf
		; Remove Dupes
		if LeadAnimations && PrimaryAnimations && PrimaryAnimations.Length > LeadAnimations.Length
			PrimaryAnimations = sslUtility.RemoveDupesFromList(PrimaryAnimations, LeadAnimations)
		endIf
		; Make sure we are still good to start after all the filters
		if !LeadAnimations || LeadAnimations.Length < 1
			LeadIn = false
		endIf
		if !PrimaryAnimations || PrimaryAnimations.Length < 1
			ReportAndFail("Empty primary animations after filters")
			return -1
		endIf
		Log("FilterAnimations() END - LeadAnimations="+LeadAnimations.Length+", PrimaryAnimations="+PrimaryAnimations.Length)
		return 1
	endIf
	return 0
EndFunction

bool Function ToggleTag(string Tag)
	return (RemoveTag(Tag) || AddTag(Tag)) && HasTag(Tag)
EndFunction

bool Function AddTagConditional(string Tag, bool AddTag)
	if AddTag
		return AddTag(Tag)
	else
		return RemoveTag(Tag)
	endIf
EndFunction

Function SendTrackedEvent(Actor ActorRef, string Hook = "")
	ThreadLib.SendTrackedEvent(ActorRef, Hook, thread_id)
EndFunction

Function SetupActorEvent(Actor ActorRef, string Callback)
	ThreadLib.SetupActorEvent(ActorRef, Callback, thread_id)
EndFunction

; Because PapyrusUtil don't Remove Dupes from the Array
string[] Function AddString(string[] ArrayValues, string ToAdd, bool RemoveDupes = true)
	String[] add = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(ToAdd, ","))
	return sslpp.MergeStringArrayEx(ArrayValues, add, true)
EndFunction

string Function GetHook()
	return Hooks[0] ; v1.35 Legacy support, pre multiple hooks
EndFunction

state Advancing
	Event OnBeginState()
		GoToStage(Stage + 1)
	EndEvent
	Function SyncDone()
		LogRedundant("SyncDone")
	EndFunction
	event OnUpdate()
		LogRedundant("OnUpdate")
	endEvent
endState
