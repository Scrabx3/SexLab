scriptname sslActorAlias extends ReferenceAlias

; Framework access
sslSystemConfig Config
sslActorLibrary ActorLib
sslActorStats Stats
Actor PlayerRef

; TODO: Remove these 3453462342634 local vars for readabilities sake. The ActorKey definition will make them redundant anyway

; Actor Info
Actor property ActorRef auto hidden
ActorBase BaseRef
string ActorName
string RaceEditorID
String ActorRaceKey
int BaseSex
int Gender
bool isRealFemale
bool IsMale
bool IsFemale
bool IsCreature
bool IsFuta
bool IsVictim
bool IsAggressor
bool IsTracked
bool IsSkilled
Faction AnimatingFaction

; Current Thread state
sslThreadController Thread
int Property Position
	int Function Get()
		return Thread.Positions.Find(ActorRef)
	EndFunction
EndProperty

float StartWait
string StartAnimEvent
string EndAnimEvent
string ActorKeyStr
bool NoOrgasm

; Voice
sslBaseVoice Voice
VoiceType ActorVoice
float BaseDelay
float VoiceDelay
float ExpressionDelay
bool IsForcedSilent

; Expression
sslBaseExpression Expression
sslBaseExpression[] Expressions

; Positioning
ObjectReference MarkerRef
float[] Offsets
float[] Loc

; Storage
int[] Flags
Form[] Equipment
bool[] StripOverride
float[] Skills
float[] OwnSkills

float StartedAt
float ActorScale
float AnimScale
float NioScale
float LastOrgasm
int BestRelation
int BaseEnjoyment
int QuitEnjoyment
int FullEnjoyment
int Orgasms
int NthTranslation

Form Strapon
Form HadStrapon

Sound OrgasmFX

Spell HDTHeelSpell
Form HadBoots

; Animation Position/Stage flags
bool property ForceOpenMouth auto hidden
bool property OpenMouth hidden
	bool function get()
		return Flags[1] == 1 || ForceOpenMouth == true ; This is for compatibility reasons because mods like DDi realy need it.
	endFunction
endProperty
bool property IsSilent hidden
	bool function get()
		return !Voice || IsForcedSilent || Flags[0] == 1 || Flags[1] == 1
	endFunction
endProperty
bool property UseStrapon hidden
	bool function get()
		return Flags[2] == 1 && Flags[4] == 0
	endFunction
endProperty
int property Schlong hidden
	int function get()
		return Flags[3]
	endFunction
endProperty
bool property MalePosition hidden
	bool function get()
		return Flags[4] == 0
	endFunction
endProperty


int _ActorKey
int Property ActorKey
	int Function Get()
		return _ActorKey
	EndFunction
EndProperty

; ------------------------------------------------------- ;
; --- Load/Clear Alias For Use                        --- ;
; ------------------------------------------------------- ;

bool Function SetActor(Actor ProspectRef)
	return SetActorEx(ProspectRef, false, none, false)
EndFunction

bool function SetActorEx(Actor akReference, bool abIsVictim, sslBaseVoice akVoice, bool abSilent)
	if !akReference || akReference != GetReference()
		Log("ERROR: SetActor("+akReference+") on State:'Ready' is not allowed")
		return false ; Failed to set prospective actor into alias
	endIf
	_ActorKey = sslActorKey.BuildActorKey(akReference, abIsVictim)

	; Init actor alias information
	ActorRef   = akReference
	BaseRef    = ActorRef.GetLeveledActorBase()
	ActorName  = BaseRef.GetName()
	; ActorVoice = BaseRef.GetVoiceType()
	BaseSex    = BaseRef.GetSex()
	isRealFemale = BaseSex == 1
	Gender     = ActorLib.GetGender(ActorRef)
	IsMale     = Gender == 0
	IsFemale   = Gender == 1
	IsCreature = Gender >= 2
	IsFuta     = ActorLib.GetTrans(ActorRef) != -1
	IsTracked  = Config.ThreadLib.IsActorTracked(ActorRef)
	RaceEditorID = MiscUtil.GetRaceEditorID(BaseRef.GetRace())
	; Player and creature specific
	If(sslActorKey.IsCreature(_ActorKey))
		Thread.CreatureRef = BaseRef.GetRace()
		if sslCreatureAnimationSlots.HasRaceKey("Canines") && sslCreatureAnimationSlots.HasRaceID("Canines", RaceEditorID)
			ActorRaceKey = "Canines"
		else
			ActorRaceKey = sslCreatureAnimationSlots.GetRaceKeyByID(RaceEditorID)
		endIf
	ElseIf(ActorRef == PlayerRef)
		Stats.SeedActor(ActorRef)
	EndIf
	; Actor's Adjustment Key
	ActorKeyStr = RaceEditorID
	if !Config.RaceAdjustments
		if IsCreature
			if ActorRaceKey
				ActorKeyStr = ActorRaceKey
			endIf
		else
			ActorKeyStr = "Humanoid"
		endIf
	endIf
	if IsCreature
		ActorKeyStr += "C"
	endIf
	if !IsCreature || Config.UseCreatureGender
		If isRealFemale
			ActorKeyStr += "F"
		else
			ActorKeyStr += "M"
		endIf
	endIf
	NioScale = 1.0
	float TempScale
	String Node = "NPC"
	if NetImmerse.HasNode(ActorRef, Node, False)
		TempScale = NetImmerse.GetNodeScale(ActorRef, Node, False)
		if TempScale > 0
			NioScale = NioScale * TempScale
		endIf
	endIf
	Node = "NPC Root [Root]"
	if NetImmerse.HasNode(ActorRef, Node, False)
		TempScale = NetImmerse.GetNodeScale(ActorRef, Node, False)
		if TempScale > 0
			NioScale = NioScale * TempScale
		endIf
	endIf
	
	if Config.HasNiOverride && !IsCreature
		string[] MOD_OVERRIDE_KEY = NiOverride.GetNodeTransformKeys(ActorRef, False, isRealFemale, "NPC")
		int idx = 0
		While idx < MOD_OVERRIDE_KEY.Length
			if MOD_OVERRIDE_KEY[idx] != "SexLab.esm"
				TempScale = NiOverride.GetNodeTransformScale(ActorRef, False, isRealFemale, "NPC", MOD_OVERRIDE_KEY[idx])
				if TempScale > 0
					NioScale = NioScale * TempScale
				endIf
			else ; Remove SexLab Node if present by error
				if NiOverride.RemoveNodeTransformScale(ActorRef, False, isRealFemale, "NPC", MOD_OVERRIDE_KEY[idx])
					NiOverride.UpdateNodeTransform(ActorRef, False, isRealFemale, "NPC")
				endIf
			endIf
			idx += 1
		endWhile
	;	Log(self, "NioScale("+NioScale+")")
	endIf

	if !Config.ScaleActors
		float ActorScalePlus
		if Config.RaceAdjustments
			ActorScalePlus = BaseRef.GetHeight()
		;	Log(self, "GetRaceScale("+ActorScalePlus+")")
		else
			ActorScalePlus = ActorRef.GetScale()
		;	Log(self, "GetScale("+ActorScalePlus+")")
		endIf
		if NioScale > 0.0 && NioScale != 1.0
			ActorScalePlus = ActorScalePlus * NioScale
		endIf
	;	Log(self, "ActorScalePlus("+ActorScalePlus+")")
		ActorScalePlus = ((ActorScalePlus * 25) + 0.5) as int
	;	Log(self, "ActorScalePlus("+ActorScalePlus+")")
		if ActorScalePlus != 25.0
			ActorKeyStr += ActorScalePlus as int
		endIf
	endIf
	; Set base voice/loop delay
	if IsCreature
		BaseDelay  = 3.0
	elseIf IsFemale
		BaseDelay  = Config.FemaleVoiceDelay
	else
		BaseDelay  = Config.MaleVoiceDelay
	endIf
	VoiceDelay = BaseDelay
	ExpressionDelay = Config.ExpressionDelay * BaseDelay
	; Init some needed arrays
	Flags   = new int[5]
	Offsets = new float[4]
	Loc     = new float[6]
	; Ready
	RegisterEvents()
	TrackedEvent("Added")
	GoToState("Ready")
	Log(self, "SetActor("+ActorRef+")")
	return true
endFunction

function ClearAlias()
	; Maybe got here prematurely, give it 10 seconds before forcing the clear
	if GetState() == "Resetting"
		float Failsafe = Utility.GetCurrentRealTime() + 10.0
		while GetState() == "Resetting" && Utility.GetCurrentRealTime() < Failsafe
			Utility.WaitMenuMode(0.2)
		endWhile
	endIf
	; Make sure actor is reset
	ActorRef = GetReference() as Actor
	if ActorRef
		; Init variables needed for reset
		BaseRef    = ActorRef.GetLeveledActorBase()
		ActorName  = BaseRef.GetName()
		BaseSex    = BaseRef.GetSex()
		isRealFemale = BaseSex == 1
		Gender     = ActorLib.GetGender(ActorRef)
		IsMale     = Gender == 0
		IsFemale   = Gender == 1
		IsCreature = Gender >= 2
		IsFuta     = ActorLib.GetTrans(ActorRef) != -1
		if !RaceEditorID || RaceEditorID == ""
			RaceEditorID = MiscUtil.GetRaceEditorID(BaseRef.GetRace())
		endIf
		if IsCreature
			ActorRaceKey = sslCreatureAnimationSlots.GetRaceKeyByID(RaceEditorID)
		endIf
		Log("Actor present during alias clear! This is usually harmless as the alias and actor will correct itself, but is usually a sign that a thread did not close cleanly.", "ClearAlias("+ActorRef+" / "+self+")")
		; Reset actor back to default
		ClearEvents()
		ClearEffects()
		StopAnimating(true)
		UnlockActor()
		RestoreActorDefaults()
		Unstrip()
	endIf
	Initialize()
	GoToState("")
endFunction

; Thread/alias shares
int Stage
int StageCount
sslBaseAnimation Animation

; ------------------------------------------------------- ;
; --- Actor Prepartion                                --- ;
; ------------------------------------------------------- ;

State Ready
	; Invoked when the thread is about to start the animation
	; Once this function reports back (through SyncEventDone) the actor is considered 'Ready to animate'
	Event PrepareActor()
		If(ActorRef == PlayerRef)
			Game.SetPlayerAIDriven()
			sslThreadController Control = Config.GetThreadControlled()
			If(Control)
				Config.DisableThreadControl(Control)
			EndIf
			FormList FrostExceptions = Config.FrostExceptions
			If(FrostExceptions)
				FrostExceptions.AddForm(Config.BaseMarker)
			EndIf
		Else
			Config.CheckBardAudience(ActorRef, true)
		EndIf
		ActorRef.SetFactionRank(AnimatingFaction, 1)
		ActorRef.EvaluatePackage()
		; Starting Information
		IsAggressor = Thread.VictimRef && Thread.Victims.Find(ActorRef) == -1
		string LogInfo

		; !IMPORTANT TODO: Move this into the actual starting code
		; Calculate scales
		; if !Config.DisableScale
		; 	Thread.ApplyFade()
		; 	float display = ActorRef.GetScale()
		; 	ActorRef.SetScale(1.0)
		; 	float base = ActorRef.GetScale()
		; 	ActorScale = ( display / base )
		; 	AnimScale  = ActorScale
		; 	if ActorScale > 0.0 && ActorScale != 1.0
		; 		ActorRef.SetScale(ActorScale)
		; 	endIf
		; 	float FixNioScale = 1.0
		; 	if (Thread.ActorCount > 1 || Thread.BedStatus[1] >= 4) && Config.ScaleActors
		; 		if Config.HasNiOverride && !IsCreature && NioScale > 0.0 && NioScale != 1.0
		; 			FixNioScale = (FixNioScale / NioScale)
		; 			NiOverride.AddNodeTransformScale(ActorRef, False, isRealFemale, "NPC", "SexLab.esm",FixNioScale)
		; 			NiOverride.UpdateNodeTransform(ActorRef, False, isRealFemale, "NPC")
		; 		endIf
		; 		AnimScale = (1.0 / base)
		; 	endIf
		; 	LogInfo = "Scales["+display+"/"+base+"/"+ActorScale+"/"+AnimScale+"/"+NioScale+"] "
		; else
		; 	AnimScale = 1.0
		; 	LogInfo = "Scales["+ActorRef.GetScale()+"/DISABLED/DISABLED/DISABLED/DISABLED/"+NioScale+"] "
		; endIf

		; Pick a voice if needed
		if !Voice && !IsForcedSilent
			if IsCreature
				SetVoice(Config.VoiceSlots.PickByRaceKey(sslCreatureAnimationSlots.GetRaceKey(BaseRef.GetRace())), IsForcedSilent)
			else
				SetVoice(Config.VoiceSlots.PickVoice(ActorRef), IsForcedSilent)
			endIf
		endIf
		if Voice
			LogInfo += "Voice["+Voice.Name+"] "
		endIf

		; COMEBACK: Not sure if this should be here or in the actual moving func
		If(!sslActorKey.IsCreature(_ActorKey))
			If(Config.UseStrapons && sslActorKey.IsFemalePure(_ActorKey))
				; COMEBACK: Idk why we use 2 variables here
				HadStrapon = Config.WornStrapon(ActorRef)
				Strapon = HadStrapon
				If(!HadStrapon)
					Strapon = Config.GetStrapon()
				EndIf
			EndIf
			Strip()
			ResolveStrapon()
			Debug.SendAnimationEvent(ActorRef, "SOSFastErect")
			; Remove HDT High Heels	 COMEBACK: This here should be moved into a dll func
			; if Config.RemoveHeelEffect && ActorRef.GetWornForm(0x00000080)
			; 	HDTHeelSpell = Config.GetHDTSpell(ActorRef)
			; 	if HDTHeelSpell
			; 		Log(HDTHeelSpell, "RemoveHeelEffect (HDTHeelSpell)")
			; 		ActorRef.RemoveSpell(HDTHeelSpell)
			; 	endIf
			; endIf
			; Pick an expression if needed
			if !Expression && Config.UseExpressions
				Expressions = Config.ExpressionSlots.GetByStatus(ActorRef, IsVictim, Thread.IsType[0] && !IsVictim)
				if Expressions && Expressions.Length > 0
					Expression = Expressions[Utility.RandomInt(0, (Expressions.Length - 1))]
				endIf
			endIf
			if Expression
				LogInfo += "Expression["+Expression.Name+"] "
			endIf
		endIf
		If(ActorRef.GetActorValue("Paralysis") > 0)
			ActorRef.SetActorValue("Paralysis", 0.0)
			SendDefaultAnimEvent()
		EndIf
		If(DoPathToCenter)
			PathToCenter() ; latent until in position/timeout
		EndIf
		; Play custom starting animation event
		; COMEBACK: Might want to remove this. Cant really make out why anyone would want to use this
		; Perhaps this could be used to push a clean strip animation?
		; If(StartAnimEvent != "")
		; 	Debug.SendAnimationEvent(ActorRef, StartAnimEvent)
		; 	If(StartWait < 0.1)
		; 		Utility.Wait(0.1)
		; 	Else
		; 		Utility.Wait(StartWait)
		; 	EndIf
		; EndIf
		Thread.SyncEventDone(kPrepareActor)

		; --- Ready to animate --- Misc Data below ---

		IsSkilled = !IsCreature || sslActorStats.IsSkilled(ActorRef)
		if IsSkilled
			; Always use players stats for NPCS if present, so players stats mean something more
			Actor SkilledActor = ActorRef
			If(Thread.HasPlayer && ActorRef != PlayerRef)
				SkilledActor = PlayerRef
			; If a non-creature couple, base skills off partner
			ElseIf(Thread.ActorCount > 1 && !Thread.HasCreature)
				SkilledActor = Thread.Positions[sslUtility.IndexTravel(Position, Thread.ActorCount)]
			EndIf
			; Get sex skills of partner/player
			Skills       = Stats.GetSkillLevels(SkilledActor)
			OwnSkills    = Stats.GetSkillLevels(ActorRef)
			; Try to prevent orgasms on fist stage resting enjoyment
			float FirsStageTime
			if Thread.LeadIn
				FirsStageTime = Config.StageTimerLeadIn[0]
			elseIf Thread.IsType[0]
				FirsStageTime = Config.StageTimerAggr[0]
			else
				FirsStageTime = Config.StageTimer[0]
			endIf
			; COMEBACK: Enjoyment should prolly get a full on rework or smth, i really dunno why or how or what here
			BaseEnjoyment -= Math.Abs(CalcEnjoyment(Thread.SkillBonus, Skills, Thread.LeadIn, IsFemale, FirsStageTime, 1, StageCount)) as int
			if BaseEnjoyment < -5
				BaseEnjoyment += 10
			endIf
			; Add Bonus Enjoyment
			if IsVictim
				BestRelation = Thread.GetLowestPresentRelationshipRank(ActorRef)
				BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(1, 10)
			else
				BestRelation = Thread.GetHighestPresentRelationshipRank(ActorRef)
				if IsAggressor
					BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(1, 10)
				else
					BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(1, 10)
				endIf
			endIf
		else
			if IsVictim
				BestRelation = Thread.GetLowestPresentRelationshipRank(ActorRef)
				BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(1, 10)
			else
				BestRelation = Thread.GetHighestPresentRelationshipRank(ActorRef)
				if IsAggressor
					BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(1, 10)
				else
					BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(1, 10)
				endIf
			endIf
		endIf
		LogInfo += "BaseEnjoyment["+BaseEnjoyment+"]"
		Log(LogInfo)
	EndEvent

	Function CompletePreperation()
		TrackedEvent("Start")
		GoToState("Animating")
	EndFunction

	; COMEBACK: This one do be lookin kinda sketchy
	function PathToCenter()
		ObjectReference CenterRef = Thread.CenterAlias.GetReference()
		if CenterRef && (Thread.ActorCount > 1 || CenterRef != ActorRef)
			ObjectReference WaitRef = CenterRef
			if CenterRef == ActorRef
				WaitRef = Thread.Positions[IntIfElse(Position != 0, 0, 1)]
			endIf
			float Distance = ActorRef.GetDistance(WaitRef)
			if WaitRef && Distance < 8000.0 && Distance > 135.0
				if CenterRef != ActorRef
					ActorRef.SetFactionRank(AnimatingFaction, 2)
					ActorRef.EvaluatePackage()
				endIf
				ActorRef.SetLookAt(WaitRef, false)

				; Start wait loop for actor pathing.
				int StuckCheck  = 0
				float Failsafe  = SexLabUtil.GetCurrentGameRealTime() + 30.0
				while Distance > 100.0 && SexLabUtil.GetCurrentGameRealTime() < Failsafe
					Utility.Wait(1.0)
					float Previous = Distance
					Distance = ActorRef.GetDistance(WaitRef)
					Log("Current Distance From WaitRef["+WaitRef+"]: "+Distance+" // Moved: "+(Previous - Distance))
					; Check if same distance as last time.
					if Math.Abs(Previous - Distance) < 1.0
						if StuckCheck > 2 ; Stuck for 2nd time, end loop.
							Distance = 0.0
						endIf
						StuckCheck += 1 ; End loop on next iteration if still stuck.
						Log("StuckCheck("+StuckCheck+") No progress while waiting for ["+WaitRef+"]")
					else
						StuckCheck -= 1 ; Reset stuckcheck if progress was made.
					endIf
				endWhile

				ActorRef.ClearLookAt()
				if CenterRef != ActorRef
					ActorRef.SetFactionRank(AnimatingFaction, 1)
					ActorRef.EvaluatePackage()
				endIf
			endIf
		endIf
	endFunction
	
	Event ResetActor()
		ClearEvents()
		GoToState("Resetting")
		Log("Resetting!")
		; Clear TFC
		If(ActorRef == PlayerRef)
			Config.ApplyFade()
			MiscUtil.SetFreeCameraState(false)
		EndIf
		StopAnimating(true)
		; UnlockActor()
		RestoreActorDefaults()
		; Tracked events
		TrackedEvent("End")
		; Unstrip items in storage, if any
		if !IsCreature && !ActorRef.IsDead()
			; Unstrip()
			; Add back high heel effects
			if Config.RemoveHeelEffect
				; HDT High Heel
				if HDTHeelSpell && ActorRef.GetWornForm(0x00000080) && !ActorRef.HasSpell(HDTHeelSpell)
					ActorRef.AddSpell(HDTHeelSpell)
				endIf
				; NiOverride High Heels move out to prevent isues and add NiOverride Scale for race menu compatibility
			endIf
			if Config.HasNiOverride
				bool UpdateNiOPosition = NiOverride.RemoveNodeTransformPosition(ActorRef, false, isRealFemale, "NPC", "SexLab.esm")
				bool UpdateNiOScale = NiOverride.RemoveNodeTransformScale(ActorRef, false, isRealFemale, "NPC", "SexLab.esm")
				if UpdateNiOPosition || UpdateNiOScale ; I make the variables because not sure if execute both funtion in OR condition.
					NiOverride.UpdateNodeTransform(ActorRef, false, isRealFemale, "NPC")
				endIf
			endIf
		endIf
		; Free alias slot
		Clear()
		GoToState("")
		Thread.SyncEventDone(kResetActor)
	EndEvent

	bool Function SetActor(Actor ProspectRef)
		Log("ERROR: SetActor(" + ProspectRef.GetLeveledActorBase().GetName() + ") on State:'Ready' is not allowed")
		return false
	EndFunction
	bool Function SetActorEx(Actor akReference, bool abIsVictim, sslBaseVoice akVoice, bool abSilent)
		return SetActor(akReference)
	EndFunction
endState

; ------------------------------------------------------- ;
; --- Animation Loop                                  --- ;
; ------------------------------------------------------- ;


function SendAnimation()
endFunction

function GetPositionInfo()
	if ActorRef
		Stage      = Thread.Stage
		Animation  = Thread.Animation
		StageCount = Animation.StageCount
		if Stage > StageCount
			return
		endIf
		;	Log("Animation:"+Animation.Name+" AdjustKey:"+Thread.AdjustKey+" Position:"+Position+" Stage:"+Stage)
		Flags     = Animation.PositionFlags(Flags, Thread.AdjustKey, Position, Stage)
		Offsets   = Animation.PositionOffsets(Offsets, Thread.AdjustKey, Position, Stage, Thread.BedStatus[1])
		CurrentSA = Animation.Registry
		; Thread.AnimEvents[Position] = Animation.FetchPositionStage(Position, Stage)
	endIf
endFunction

string PlayingSA
string CurrentSA
string PlayingAE
string CurrentAE
float LoopDelay
float LoopExpressionDelay
state Animating
	Event OnBeginState()
		; StopAnimating(true)	; Why?
		StartedAt  = SexLabUtil.GetCurrentGameRealTime()
		LastOrgasm = StartedAt
		PlayingSA = Animation.Registry
		SyncAll(true)
		RegisterForSingleUpdate(Utility.RandomFloat(1.0, 3.0))
	EndEvent

	; COMEBACK: Idk why this single call needs so much stuff and why we precache all this data here
	; could easily do all of this through the main controller
	function SendAnimation()
		CurrentAE = Thread.AnimEvents[Position]
		; Reenter SA - On stage 1 while animation hasn't changed since last call
		if Stage == 1 && (PlayingAE != CurrentAE || PlayingSA == CurrentSA)
			SendDefaultAnimEvent()
		;	Utility.WaitMenuMode(0.2)
			Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
			; Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1)+"_REENTER")
		else
			; Enter a new SA - Not necessary on stage 1 since both events would be the same
			if Stage != 1 && PlayingSA != CurrentSA
				; SendDefaultAnimEvent() ; To unequip the AnimObject TODO: Find better solution ; ?????????
				Debug.SendAnimationEvent(ActorRef, "AnimObjectUnequip")
				Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
				Utility.Wait(0.2)
				; Log("NEW SA - "+Animation.FetchPositionStage(Position, 1))
			endIf
			; Play the primary animation
		 	Debug.SendAnimationEvent(ActorRef, CurrentAE)
		 	; Log(CurrentAE)
		endIf
		; Save id of last SA played
		PlayingSA = Animation.Registry
		; Save id of last AE played
		PlayingAE  = CurrentAE
	endFunction

	event OnUpdate()
		; Pause further updates if in menu
		while Utility.IsInMenuMode()
			Utility.WaitMenuMode(1.5)
			StartedAt += 1.2
		endWhile
		; Check if still among the living and able.
		if !ActorRef || ActorRef == none || !ActorRef.Is3DLoaded() || ActorRef.IsDisabled() || (ActorRef.IsDead() && ActorRef.GetActorValue("Health") < 1.0)
			Log("Actor is out of cell, disabled, or has no health - Unable to continue animating")
			Thread.EndAnimation(true)
		;	return don't work on events
		else ; Else instead of return becouse return don't work on Events (at less in LE)
			; Lip sync and refresh expression
			if GetState() == "Animating"
				int Strength = CalcReaction()
				if LoopDelay >= VoiceDelay && (Config.LipsFixedValue || Strength > 10)
					LoopDelay = 0.0
					bool UseLipSync = Config.UseLipSync && !IsCreature
					if OpenMouth && UseLipSync && !Config.LipsFixedValue
						sslBaseVoice.MoveLips(ActorRef, none, 0.3)
						Log("PlayMoan:False; UseLipSync:"+UseLipSync+"; OpenMouth:"+OpenMouth)
					elseIf !IsSilent
						Voice.PlayMoan(ActorRef, Strength, IsVictim, UseLipSync)
						Log("PlayMoan:True; UseLipSync:"+UseLipSync+"; OpenMouth:"+OpenMouth)
					endIf
				endIf
				if Expressions && Expressions.Length > 0
					if LoopExpressionDelay >= ExpressionDelay && Config.RefreshExpressions
						sslBaseExpression oldExpression = Expression
						Expression = Expressions[Utility.RandomInt(0, (Expressions.Length - 1))]
						Log("Expression["+Expression.Name+"] BaseVoiceDelay["+BaseDelay+"] ExpressionDelay["+ExpressionDelay+"] LoopExpressionDelay["+LoopExpressionDelay+"] ")
						if oldExpression != Expression
							RefreshExpression()
						endIf
						LoopExpressionDelay = 0.0
					endIf
				endIf
				if RefreshExpressionDelay > 8.0
					RefreshExpression()
				endIf
				; Trigger orgasm
				If(!NoOrgasm && Config.SeparateOrgasms && Strength >= 100 && Stage < StageCount)
					int cmp
					If(sslActorKey.IsMale(_ActorKey))
						cmp = 20
					ElseIf(sslActorKey.IsMaleCreature(_ActorKey))
						cmp = 30
					EndIf
					If(Thread.RealTime[0] - LastOrgasm > cmp)
						OrgasmEffect()
					EndIf
				EndIf
			endIf
			; Loop
			LoopDelay += (VoiceDelay * 0.35)
			LoopExpressionDelay += (VoiceDelay * 0.35)
			RefreshExpressionDelay += (VoiceDelay * 0.35)
			RegisterForSingleUpdate(VoiceDelay * 0.35)
		endIf
	endEvent

	function SyncThread()
		; Sync with thread info
		GetPositionInfo()
		VoiceDelay = BaseDelay
		ExpressionDelay = Config.ExpressionDelay * BaseDelay
		if !IsSilent && Stage > 1
			VoiceDelay -= (Stage * 0.8) + Utility.RandomFloat(-0.2, 0.4)
		endIf
		if VoiceDelay < 0.8
			VoiceDelay = Utility.RandomFloat(0.8, 1.4) ; Can't have delay shorter than animation update loop
		endIf
		; Update alias info
	;	GetEnjoyment()
		; Sync status
		if !IsCreature
			ResolveStrapon()
			RefreshExpression()
		endIf
		Debug.SendAnimationEvent(ActorRef, "SOSBend"+Schlong)
		; SyncLocation(false)
	endFunction

	; Event called when animation is advancing to a new stage
	function SyncActor()
		SyncThread()
		; SyncLocation(false)
		Thread.SyncEventDone(kSyncActor)
	endFunction

	; TODO: Check when and why this is called. May want to call native SetPositions() from whatever calls this
	function SyncAll(bool Force = false)
		SyncThread()
		; SyncLocation(Force)
	endFunction

	; TODO: Check when and why this is called. May want to call native SetPositions() from whatever calls this
	function RefreshActor()	
		UnregisterForUpdate()
		SyncThread()
		StopAnimating(true)
		; SyncLocation(false)
		CurrentSA = "SexLabSequenceExit1"
		CurrentAE = PlayingSA
		Debug.SendAnimationEvent(ActorRef, CurrentAE)
		SendDefaultAnimEvent()
		Utility.WaitMenuMode(0.2)
		CurrentSA = Animation.Registry
		CurrentAE = Animation.FetchPositionStage(Position, 1)
		Debug.SendAnimationEvent(ActorRef, CurrentAE)
		PlayingSA = CurrentSA
		PlayingAE = CurrentAE
		; SyncLocation(true)
		SendAnimation()
		RegisterForSingleUpdate(1.0)
		Thread.SyncEventDone(kRefreshActor)
	endFunction

	function RefreshLoc()
		Offsets = Animation.PositionOffsets(Offsets, Thread.AdjustKey, Position, Stage, Thread.BedStatus[1])
		; SyncLocation(true)
	endFunction

	; function SyncLocation(bool Force = false)
	; 	OffsetCoords(Loc, Center, Offsets)
	; 	MarkerRef.SetPosition(Loc[0], Loc[1], Loc[2])
	; 	MarkerRef.SetAngle(Loc[3], Loc[4], Loc[5])
	; 	; Avoid forcibly setting on player coords if avoidable - causes annoying graphical flickering
	; 	if Force && IsPlayer && IsInPosition(ActorRef, MarkerRef, 40.0)
	; 		AttachMarker()
	; 		ActorRef.TranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5], 50000, 0)
	; 		return ; OnTranslationComplete() will take over when in place
	; 	elseIf Force
	; 		ActorRef.SetPosition(Loc[0], Loc[1], Loc[2])
	; 		ActorRef.SetAngle(Loc[3], Loc[4], Loc[5])
	; 	endIf
	; 	AttachMarker()
	; 	Snap()
	; endFunction

	; function Snap()
	; 	if !(ActorRef && ActorRef.Is3DLoaded())
	; 		return
	; 	endIf
	; 	; Quickly move into place and angle if actor is off by a lot
	; 	float distance = ActorRef.GetDistance(MarkerRef)
	; 	if distance > 125.0 || !IsInPosition(ActorRef, MarkerRef, 75.0)
	; 		ActorRef.SetPosition(Loc[0], Loc[1], Loc[2])
	; 		ActorRef.SetAngle(Loc[3], Loc[4], Loc[5])
	; 		AttachMarker()
	; 	elseIf distance > 2.0
	; 		ActorRef.TranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5], 50000, 0.0)
	; 		return ; OnTranslationComplete() will take over when in place
	; 	endIf
	; 	; Begin very slowly rotating a small amount to hold position
	; 	ActorRef.TranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5]+0.01, 500.0, 0.0001)
	; endFunction

	; TODO: Check when and why this is called. May want to call native SetPositions() from whatever calls this
	event OnTranslationComplete()
		; Log("OnTranslationComplete")
		; Snap()
	endEvent

	;/ event OnTranslationFailed()
		Log("OnTranslationFailed")
		; SyncLocation(false)
	endEvent /;

	function OrgasmEffect()
		DoOrgasm()
	endFunction

	function DoOrgasm(bool Forced = false)
		if !ActorRef
			return
		endIf
		int Enjoyment = GetEnjoyment()
		if !Forced && (NoOrgasm || Thread.DisableOrgasms)
			; Orgasm Disabled for actor or whole thread
			return 
		elseIf !Forced && Enjoyment < 1
			; Actor have the orgasm few seconds ago or is in pain and can't orgasm
			return
		elseIf Math.Abs(Thread.RealTime[0] - LastOrgasm) < 5.0
			Log("Excessive OrgasmEffect Triggered")
			return
		endIf

		; Check if the animation allow Orgasm. By default all the animations with a CumID>0 are type SEX and allow orgasm 
		; But the Lesbian Animations usually don't have CumId assigned and still the orgasm should be allowed at least for Females.
		bool CanOrgasm = Forced || ((IsFemale || IsFuta) && (Animation.HasTag("Lesbian") || Animation.Females == Animation.PositionCount))
		int i = Thread.ActorCount
		while !CanOrgasm && i > 0
			i -= 1
			CanOrgasm = Animation.GetCumID(i, Stage) > 0 || Animation.GetCum(i) > 0
		endWhile
		if !CanOrgasm
			; Orgasm Disabled for the animation
			return
		endIf

		; Check Separate Orgasm conditions 
		if !Forced && Config.SeparateOrgasms
			if Enjoyment < 100 && (Stage < StageCount || Orgasms > 0)
				; Prevent the orgasm with low enjoyment at least the last stage be reached without orgasms
				return
			endIf
			bool IsCumSource = False
			i = Thread.ActorCount
			while !IsCumSource && i > 0
				i -= 1
				IsCumSource = Animation.GetCumSource(i, Stage) == Position
			endWhile
			if !IsCumSource
				if IsFuta && !(Animation.HasTag("Anal") || Animation.HasTag("Vaginal") || Animation.HasTag("Pussy") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Fisting") || Animation.HasTag("Handjob") || Animation.HasTag("Blowjob") || Animation.HasTag("Boobjob") || Animation.HasTag("Footjob") || Animation.HasTag("Penis"))
					return
				elseIf IsMale && !(Animation.HasTag("Anal") || Animation.HasTag("Vaginal") || Animation.HasTag("Handjob") || Animation.HasTag("Blowjob") || Animation.HasTag("Boobjob") || Animation.HasTag("Footjob") || Animation.HasTag("Penis"))
					return
				elseIf IsFemale && !(Animation.HasTag("Anal") || Animation.HasTag("Vaginal") || Animation.HasTag("Pussy") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Fisting") || Animation.HasTag("Breast"))
					return
				endIf
			endIf
		endIf
		UnregisterForUpdate()
		LastOrgasm = Thread.RealTime[0]
		Orgasms   += 1
		; Send an orgasm event hook with actor and orgasm count
		int eid = ModEvent.Create("SexLabOrgasm")
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, FullEnjoyment)
		ModEvent.PushInt(eid, Orgasms)
		ModEvent.Send(eid)
		TrackedEvent("Orgasm")
		Log(ActorName + ": Orgasms["+Orgasms+"] FullEnjoyment ["+FullEnjoyment+"] BaseEnjoyment["+BaseEnjoyment+"] Enjoyment["+Enjoyment+"]")
		If(Config.OrgasmEffects)
			; Shake camera for player
			If(ActorRef == PlayerRef && Config.ShakeStrength > 0 && Game.GetCameraState() >= 8 )
				Game.ShakeCamera(none, Config.ShakeStrength, Config.ShakeStrength + 1.0)
			EndIf
			; Play SFX/Voice
			If(!IsSilent)
				PlayLouder(Voice.GetSound(100, false), ActorRef, Config.VoiceVolume)
			EndIf
			PlayLouder(OrgasmFX, ActorRef, Config.SFXVolume)
		EndIf
		; Apply cum to female positions from male position orgasm
		i = Thread.ActorCount
		if i > 1 && Config.UseCum && (MalePosition || IsCreature) && (IsMale || IsFuta || IsCreature || (Config.AllowFFCum && IsFemale))
			if i == 2
				Thread.PositionAlias(IntIfElse(Position == 1, 0, 1)).ApplyCum()
			else
				while i > 0
					i -= 1
					if Position != i && Position < Animation.PositionCount && Animation.IsCumSource(Position, i, Stage)
						Thread.PositionAlias(i).ApplyCum()
					endIf
				endWhile
			endIf
		endIf
		Utility.WaitMenuMode(0.2)
		; Reset enjoyment build up, if using multiple orgasms
		QuitEnjoyment += Enjoyment
		if IsSkilled
			if IsVictim
				BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(5, 10)
			else
				if IsAggressor
					BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(5, 10)
				endIf
			endIf
		else
			if IsVictim
				BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(5, 10)
			else
				if IsAggressor
					BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(5, 10)
				endIf
			endIf
		endIf
		; VoiceDelay = 0.8
		RegisterForSingleUpdate(0.8)
	endFunction

	event ResetActor()
		ClearEvents()
		GoToState("Resetting")
		Log("Resetting!")
		; Update stats
		if IsSkilled
			Actor VictimRef = Thread.VictimRef
			if IsVictim
				VictimRef = ActorRef
			endIf
			sslActorStats.RecordThread(ActorRef, Gender, BestRelation, StartedAt, Thread.RealTime[0], Utility.GetCurrentGameTime(), Thread.HasPlayer, VictimRef, Thread.Genders, Thread.SkillXP)
			Stats.AddPartners(ActorRef, Thread.Positions, Thread.Victims)
			if Thread.IsType[6]
				Stats.AdjustSkill(ActorRef, "VaginalCount", 1)
			endIf
			if Thread.IsType[7]
				Stats.AdjustSkill(ActorRef, "AnalCount", 1)
			endIf
			if Thread.IsType[8]
				Stats.AdjustSkill(ActorRef, "OralCount", 1)
			endIf
		endIf
		; Apply cum
		;/ int CumID = Animation.GetCum(Position)
		if CumID > 0 && !Thread.FastEnd && Config.UseCum && (Thread.Males > 0 || Config.AllowFFCum || Thread.HasCreature)
			ActorLib.ApplyCum(ActorRef, CumID)
		endIf /;
		; Make sure of play the last animation stage to prevet AnimObject issues
		CurrentAE = Animation.FetchPositionStage(Position, StageCount)
		if PlayingAE != CurrentAE
			Debug.SendAnimationEvent(ActorRef, CurrentAE)
		;	Utility.WaitMenuMode(0.2)
			PlayingAE = CurrentAE
		endIf
		StopAnimating(Thread.FastEnd, EndAnimEvent)
		; UnlockActor()
		RestoreActorDefaults()
		; Tracked events
		TrackedEvent("End")
		; Unstrip items in storage, if any
		if !IsCreature && !ActorRef.IsDead()
			; Unstrip()
			; Add back high heel effects
			if Config.RemoveHeelEffect
				; HDT High Heel
				if HDTHeelSpell && ActorRef.GetWornForm(0x00000080) && !ActorRef.HasSpell(HDTHeelSpell)
					ActorRef.AddSpell(HDTHeelSpell)
				endIf
				; NiOverride High Heels move out to prevent isues and add NiOverride Scale for race menu compatibility
			endIf
			if Config.HasNiOverride
				bool UpdateNiOPosition = NiOverride.RemoveNodeTransformPosition(ActorRef, false, isRealFemale, "NPC", "SexLab.esm")
				bool UpdateNiOScale = NiOverride.RemoveNodeTransformScale(ActorRef, false, isRealFemale, "NPC", "SexLab.esm")
				if UpdateNiOPosition || UpdateNiOScale ; I make the variables because not sure if execute both funtion in OR condition.
					NiOverride.UpdateNodeTransform(ActorRef, false, isRealFemale, "NPC")
				endIf
			endIf
		endIf
		; Free alias slot
		TryToClear()
		GoToState("")
		Thread.SyncEventDone(kResetActor)
	endEvent
endState

state Resetting
	function ClearAlias()
	endFunction
	event OnUpdate()
	endEvent
	function Initialize()
	endFunction
endState

function SyncAll(bool Force = false)
endFunction

; ------------------------------------------------------- ;
; --- Actor Manipulation                              --- ;
; ------------------------------------------------------- ;

function StopAnimating(bool Quick = false, string ResetAnim = "IdleForceDefaultState")
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "StopAnimating("+Quick+")")
		return
	endIf
	; Disable free camera, if in it
	; if IsPlayer
	; 	MiscUtil.SetFreeCameraState(false)
	; endIf
	; Clear possibly troublesome effects
	ActorRef.StopTranslation()
	bool Resetting = GetState() == "Resetting" || !Quick
	if Resetting
		int StageOffset = Stage
		if StageOffset > StageCount
			StageOffset = StageCount
		endIf
		if Thread.AdjustKey != ""
			Offsets    = Animation.PositionOffsets(Offsets, Thread.AdjustKey, Position, StageOffset, Thread.BedStatus[1])
		endIf
		float OffsetZ = 10.0
		if Offsets[2] < 1.0 ; Fix for animation default missaligned 
			Offsets[2] = OffsetZ ; hopefully prevents some users underground/teleport to giant camp problem?
		endIf
		; OffsetCoords(Loc, Center, Offsets)	; COMEBACK: Why
		float PositionX = ActorRef.GetPositionX()
		float PositionY = ActorRef.GetPositionY()
		float AngleZ = ActorRef.GetAngleZ()
		float Rotate = AngleZ
		String Node = "NPC Root [Root]"
		if !IsCreature
			Node = "MagicEffectsNode"
		endIf
		if NetImmerse.HasNode(ActorRef, Node, False)
			PositionX = NetImmerse.GetNodeWorldPositionX(ActorRef, Node, False)
			PositionY = NetImmerse.GetNodeWorldPositionY(ActorRef, Node, False)
			float[] Rotation = new float[3]
			if NetImmerse.GetNodeLocalRotationEuler(ActorRef, Node, Rotation, False)
				Rotate = AngleZ + Rotation[2]
				if Rotate >= 360.0
					Rotate = Rotate - 360.0
				elseIf Rotate < 0.0
					Rotate = Rotate + 360.0
				endIf
				Log(Node +" Rotation:"+Rotation+" AngleZ:"+AngleZ+" Rotate:"+Rotate)
			endIf
		endIf
		; --- COMEBACK: Why
		; if AngleZ != Rotate		
		; 	ActorRef.SetAngle(Loc[3], Loc[4], Rotate)
		; endIf
		; ActorRef.SetPosition(PositionX, PositionY, Loc[2])
		; ---
	;	Utility.WaitMenuMode(0.1)
	endIf
	ActorRef.SetVehicle(none)
	; Stop animevent
	bool usesfreecam = ActorRef == PlayerRef && Game.GetCameraState() == 3
	if IsCreature
		; Reset creature idle
		SendDefaultAnimEvent(Resetting)
		if ResetAnim != "IdleForceDefaultState" && ResetAnim != "" && !usesfreecam
			ActorRef.PushActorAway(ActorRef, 0.001)
		elseIf !Quick && ResetAnim == "IdleForceDefaultState" && DoRagdoll && !usesfreecam
			if ActorRef.IsDead() || ActorRef.IsUnconscious()
				Debug.SendAnimationEvent(ActorRef, "DeathAnimation")
			elseIf ActorRef.GetActorValuePercentage("Health") < 0.1
				ActorRef.KillSilent()
			elseIf (ActorRaceKey == "Spiders" || ActorRaceKey == "LargeSpiders" || ActorRaceKey == "GiantSpiders")
				ActorRef.PushActorAway(ActorRef, 0.001) ; Temporal Fix TODO:
			endIf
		endIf
	else
		; Reset NPC/PC Idle Quickly
		if ResetAnim != "IdleForceDefaultState" && ResetAnim != ""
			Debug.SendAnimationEvent(ActorRef, ResetAnim)
			Utility.Wait(0.1)
			; Ragdoll NPC/PC if enabled and not in TFC
			if !Quick && DoRagdoll && !usesfreecam
				ActorRef.PushActorAway(ActorRef, 0.001)
			endIf
		elseIf Quick
			Debug.SendAnimationEvent(ActorRef, ResetAnim)
		elseIf !Quick && ResetAnim == "IdleForceDefaultState" && DoRagdoll && !usesfreecam
			;TODO: Detect the real actor position based on Node property intead of the Animation Tags
			if ActorRef.IsDead() || ActorRef.IsUnconscious()
				Debug.SendAnimationEvent(ActorRef, ResetAnim)
				Utility.Wait(0.1)
				Debug.SendAnimationEvent(ActorRef, "IdleSoupDeath")
			elseIf ActorRef.GetActorValuePercentage("Health") < 0.1
				ActorRef.KillSilent()
			elseIf Animation && (Animation.HasTag("Furniture") || (Animation.HasTag("Standing") && !Thread.IsType[0]))
				Debug.SendAnimationEvent(ActorRef, ResetAnim)
			elseIf Thread.IsType[0] && IsVictim && Animation && Animation.HasTag("Rape") && !Animation.HasTag("Standing") && \
				!usesfreecam && (Animation.HasTag("DoggyStyle") || Animation.HasTag("Missionary") || Animation.HasTag("Laying"))
				ActorRef.PushActorAway(ActorRef, 0.001)
			else
				Debug.SendAnimationEvent(ActorRef, ResetAnim)
			endIf
		else
			Debug.SendAnimationEvent(ActorRef, ResetAnim)
		endIf
	endIf
	;	Log(ActorName +"- Angle:[X:"+ActorRef.GetAngleX()+"Y:"+ActorRef.GetAngleY()+"Z:"+ActorRef.GetAngleZ()+"] Position:[X:"+ActorRef.GetPositionX()+"Y:"+ActorRef.GetPositionY()+"Z:"+ActorRef.GetPositionZ()+"]", "StopAnimating("+Quick+")")
	PlayingSA = "SexLabSequenceExit1"
	PlayingAE = "SexLabSequenceExit1"
endFunction

function SendDefaultAnimEvent(bool Exit = False)
	Debug.SendAnimationEvent(ActorRef, "AnimObjectUnequip")
	if !IsCreature
		Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
		Utility.Wait(0.1)
	elseIf ActorRaceKey != ""
		if ActorRaceKey == "Dragons"
			Debug.SendAnimationEvent(ActorRef, "FlyStopDefault") ; for Dragons only
			Utility.Wait(0.1)
			Debug.SendAnimationEvent(ActorRef, "Reset") ; for Dragons only
		elseIf ActorRaceKey == "Hagravens"
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") ; for Dragons only
			Utility.Wait(0.1)
			if Exit
				Debug.SendAnimationEvent(ActorRef, "Reset") ; for Dragons only
			endIf
		elseIf ActorRaceKey == "Chaurus" || ActorRaceKey == "ChaurusReapers"
			Debug.SendAnimationEvent(ActorRef, "FNISDefault") ; for dwarvenspider and chaurus without time bettwen.
			Utility.Wait(0.1)
			if Exit
		;		Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
			endIf
		elseIf ActorRaceKey == "DwarvenSpiders"
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
			Utility.Wait(0.1)
			if Exit
		;		Debug.SendAnimationEvent(ActorRef, "FNISDefault") ; for dwarvenspider and chaurus
			endIf
		elseIf ActorRaceKey == "Draugrs" || ActorRaceKey == "Seekers" || ActorRaceKey == "DwarvenBallistas" || ActorRaceKey == "DwarvenSpheres" || ActorRaceKey == "DwarvenCenturions"
			Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") ; for draugr, trolls daedras and all dwarven exept spiders
		elseIf ActorRaceKey == "Trolls"
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
			Utility.Wait(0.1)
			if Exit
				Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") ; the troll need this afther "ReturnToDefault" to allow the attack idles
			endIf
		elseIf ActorRaceKey == "Chickens" || ActorRaceKey == "Rabbits" || ActorRaceKey == "Slaughterfishes"
			Debug.SendAnimationEvent(ActorRef, "ReturnDefaultState") ; for chicken, hare and slaughterfish
			Utility.Wait(0.1)
			if Exit
				Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
			endIf
		elseIf ActorRaceKey == "Werewolves" || ActorRaceKey == "VampireLords"
			Debug.SendAnimationEvent(ActorRef, "IdleReturnToDefault") ; for Werewolves and VampirwLords
			Utility.Wait(0.1)
		else
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") ; the rest creature-animal
			Utility.Wait(0.1)
		endIf
	elseIf Exit
		Debug.SendAnimationEvent(ActorRef, "ReturnDefaultState") ; for chicken, hare and slaughterfish before the "ReturnToDefault"
		Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") ; the rest creature-animal
		Debug.SendAnimationEvent(ActorRef, "FNISDefault") ; for dwarvenspider and chaurus
		Debug.SendAnimationEvent(ActorRef, "IdleReturnToDefault") ; for Werewolves and VampirwLords
		Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") ; for Trolls afther the "ReturnToDefault" and draugr, daedras and all dwarven exept spiders
		Debug.SendAnimationEvent(ActorRef, "Reset") ; for Hagravens afther the "ReturnToDefault" and Dragons
		Utility.Wait(0.1)
	endIf
	; Utility.Wait(0.2)
endFunction


function LockActor()
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "LockActor()")
		return
	endIf
	; Move if actor out of cell
	; ObjectReference CenterRef = Thread.CenterAlias.GetReference()
	; if CenterRef && CenterRef != none && CenterRef != ActorRef as ObjectReference && ActorRef.GetDistance(CenterRef) > 3000
	; 	ActorRef.MoveTo(CenterRef)
	; endIf
	; Remove any unwanted combat effects
	ClearEffects()
	; Stop whatever they are doing
	; SendDefaultAnimEvent()
	; Start DoNothing package
	ActorRef.SetFactionRank(AnimatingFaction, 1)
	; ActorUtil.AddPackageOverride(ActorRef, Config.DoNothing, 100, 1)
	; ActorRef.SetFactionRank(AnimatingFaction, 1)
	; ActorRef.EvaluatePackage()
	; Disable movement
	ActorRef.StopTranslation()
	if ActorRef == PlayerRef
		if Game.GetCameraState() == 0
			Game.ForceThirdPerson()
		endIf
		; abMovement = true, abFighting = true, abCamSwitch = false, abLooking = false, abSneaking = false, abMenu = true, abActivate = true, abJournalTabs = false, aiDisablePOVType = 0
		; Game.DisablePlayerControls(true, true, false, false, false, false, false, false, 0)	; Unnecessary
		Game.SetPlayerAIDriven()
		; UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)								; COMEBACK: Not sure if we want this or nah
		; Enable hotkeys if needed, and disable autoadvance if not needed
		if IsVictim && Config.DisablePlayer
			Thread.AutoAdvance = true
		else
			Thread.AutoAdvance = Config.AutoAdvance
			Thread.EnableHotkeys()
		endIf
	else
		ActorRef.SetRestrained(true)
		; ActorRef.SetDontMove(true)		; unnecessary
		; Start DoNothing package	-- Dont do this for the player
		ActorUtil.AddPackageOverride(ActorRef, Config.DoNothing, 100, 1)
		ActorRef.EvaluatePackage()
	endIf
	; _Positions_var[i].SetAnimationVariableBool("bHumanoidFootIKDisable", true)	; COMEBACK: Necessary?
	; Attach positioning marker				; Unified marker stored in main script
	; if !MarkerRef
	; 	MarkerRef = ActorRef.PlaceAtMe(Config.BaseMarker)
	; 	int cycle											; All this is pointless
	; 	while !MarkerRef.Is3DLoaded() && cycle < 50
	; 		Utility.Wait(0.1)
	; 		cycle += 1
	; 	endWhile
	; 	if cycle
	; 		Log("Waited ["+cycle+"] cycles for MarkerRef["+MarkerRef+"]")
	; 	endIf
	; endIf
	; MarkerRef.Enable()					; Done by main script
	; ActorRef.StopTranslation()	; We already did this
	; MarkerRef.MoveTo(ActorRef)	; Done by main script
	; AttachMarker()
endFunction

function UnlockActor()
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "UnlockActor()")
		return
	endIf
	; Detach positioning marker
	; ActorRef.StopTranslation()
	; ActorRef.SetVehicle(none)
	; Remove from animation faction	-- ???? Remove and then add again? COMEBACK: Find out tf is going on here
	ActorRef.RemoveFromFaction(AnimatingFaction)
	ActorRef.SetFactionRank(AnimatingFaction, 0)
	; Enable movement
	if ActorRef == PlayerRef
		Thread.RemoveFade()
		Thread.DisableHotkeys()
		MiscUtil.SetFreeCameraState(false)
		; Game.EnablePlayerControls(true, true, false, false, false, false, false, false, 0)
		Game.SetPlayerAIDriven(false)
    ; UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)	; COMEBACK: Not sure if we want this or nah
	else
		ActorUtil.RemovePackageOverride(ActorRef, Config.DoNothing)
		ActorRef.EvaluatePackage()
		ActorRef.SetRestrained(false)
		; ActorRef.SetDontMove(false)
	endIf
	; _Positions_var[i].SetAnimationVariableBool("bHumanoidFootIKDisable", false)	; COMEBACK: Necessary?
	;	Log(ActorName +"- Angle:[X:"+ActorRef.GetAngleX()+"Y:"+ActorRef.GetAngleY()+"Z:"+ActorRef.GetAngleZ()+"] Position:[X:"+ActorRef.GetPositionX()+"Y:"+ActorRef.GetPositionY()+"Z:"+ActorRef.GetPositionZ()+"]", "UnlockActor()")
endFunction

function RestoreActorDefaults()
	; Make sure  have actor, can't afford to miss this block
	if !ActorRef
		ActorRef = GetReference() as Actor
		if !ActorRef
			Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "RestoreActorDefaults()")
			return ; No actor, reset prematurely or bad call to alias
		endIf
	endIf	
	; Reset to starting scale
	if !Config.DisableScale && ActorScale > 0.0 && (ActorScale != 1.0 || AnimScale != 1.0)
		ActorRef.SetScale(ActorScale)
	endIf
	if !IsCreature
		; Reset voicetype
		; if ActorVoice && ActorVoice != BaseRef.GetVoiceType()
		; 	BaseRef.SetVoiceType(ActorVoice)
		; endIf
		; Remove strapon
		if Strapon && !HadStrapon; && Strapon != HadStrapon
			ActorRef.RemoveItem(Strapon, 1, true)
		endIf
		; Reset expression
		if ActorRef.Is3DLoaded() && !(ActorRef.IsDisabled() || ActorRef.IsDead() || ActorRef.GetActorValue("Health") < 1.0)
			if Expression
				sslBaseExpression.CloseMouth(ActorRef)
			elseIf sslBaseExpression.IsMouthOpen(ActorRef)
				sslBaseExpression.CloseMouth(ActorRef)			
			endIf
			ActorRef.ClearExpressionOverride()
			ActorRef.ResetExpressionOverrides()
			sslBaseExpression.ClearMFG(ActorRef)
		endIf
	endIf
	; Player specific actions
	if ActorRef == PlayerRef
		; Remove player from frostfall exposure exception
		FormList FrostExceptions = Config.FrostExceptions
		if FrostExceptions
			FrostExceptions.RemoveAddedForm(Config.BaseMarker)
		endIf
		Thread.RemoveFade()
	endIf
	; Remove SOS erection
	Debug.SendAnimationEvent(ActorRef, "SOSFlaccid")
	; Clear from animating faction
	ActorRef.SetFactionRank(AnimatingFaction, -1)
	ActorRef.RemoveFromFaction(AnimatingFaction)
	ActorUtil.RemovePackageOverride(ActorRef, Config.DoNothing)
	ActorRef.EvaluatePackage()
	;	Log(ActorName +"- Angle:[X:"+ActorRef.GetAngleX()+"Y:"+ActorRef.GetAngleY()+"Z:"+ActorRef.GetAngleZ()+"] Position:[X:"+ActorRef.GetPositionX()+"Y:"+ActorRef.GetPositionY()+"Z:"+ActorRef.GetPositionZ()+"]", "RestoreActorDefaults()")
endFunction

function RefreshActor()
endFunction

; ------------------------------------------------------- ;
; --- Data Accessors                                  --- ;
; ------------------------------------------------------- ;

int function GetGender()
	return Gender
endFunction

function SetVictim(bool Victimize)
	Actor[] Victims = Thread.Victims
	; Make victim
	if Victimize && (!Victims || Victims.Find(ActorRef) == -1)
		Victims = PapyrusUtil.PushActor(Victims, ActorRef)
		Thread.Victims = Victims
		Thread.IsAggressive = true
	; Was victim but now isn't, update thread
	elseIf IsVictim && !Victimize
		Victims = PapyrusUtil.RemoveActor(Victims, ActorRef)
		Thread.Victims = Victims
		if !Victims || Victims.Length < 1
			Thread.IsAggressive = false
		endIf
	endIf
	IsVictim = Victimize
endFunction

bool function IsVictim()
	return IsVictim
endFunction

string function GetActorKey()
	return ActorKeyStr
endFunction

function AdjustEnjoyment(int AdjustBy)
	BaseEnjoyment += AdjustBy
endfunction

int function GetEnjoyment()
	;	Log(ActorName +"- Thread.RealTime:["+Utility.GetCurrentRealTime()+"], GameTime:["+SexLabUtil.GetCurrentGameRealTime()+"] IsMenuMode:"+Utility.IsInMenuMode(), "GetEnjoyment()")
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "GetEnjoyment()")
		FullEnjoyment = 0
		return 0
	elseif !IsSkilled
		FullEnjoyment = BaseEnjoyment + (PapyrusUtil.ClampFloat(((Thread.RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0) + ((Stage as float / StageCount as float) * 60.0)) as int
	else
		if Position == 0
			Thread.RecordSkills()
			Thread.SetBonuses()
		endIf
		FullEnjoyment = BaseEnjoyment + CalcEnjoyment(Thread.SkillBonus, Skills, Thread.LeadIn, IsFemale, (Thread.RealTime[0] - StartedAt), Stage, StageCount)
		; Log("FullEnjoyment["+FullEnjoyment+"] / BaseEnjoyment["+BaseEnjoyment+"] / Enjoyment["+(FullEnjoyment - BaseEnjoyment)+"]")
	endIf

	int Enjoyment = FullEnjoyment - QuitEnjoyment
	if Enjoyment > 0
		return Enjoyment
	endIf
	return 0
endFunction

int function GetPain()
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "GetPain()")
		return 0
	endIf
	GetEnjoyment()
	if FullEnjoyment < 0
		return Math.Abs(FullEnjoyment) as int
	endIf
	return 0	
endFunction

int function CalcReaction()
	if !ActorRef
		Log(ActorName +"- WARNING: ActorRef if Missing or Invalid", "CalcReaction()")
		return 0
	endIf
	int Strength = GetEnjoyment()
	; Check if the actor is in pain or too excited to care about pain
	if FullEnjoyment < 0 && Strength < Math.Abs(FullEnjoyment)
		Strength = FullEnjoyment
	endIf
	return PapyrusUtil.ClampInt(Math.Abs(Strength) as int, 0, 100)
endFunction

function ApplyCum()
	if ActorRef && ActorRef.Is3DLoaded()
		Cell ParentCell = ActorRef.GetParentCell()
		int CumID = Animation.GetCumID(Position, Stage)
		if CumID > 0 && ParentCell && ParentCell.IsAttached() ; Error treatment for Spells out of Cell
			ActorLib.ApplyCum(ActorRef, CumID)
		endIf
	endIf
endFunction

function DisableOrgasm(bool bNoOrgasm)
	if ActorRef
		NoOrgasm = bNoOrgasm
	endIf
endFunction

bool function IsOrgasmAllowed()
	return !NoOrgasm && !Thread.DisableOrgasms
endFunction

bool function NeedsOrgasm()
	return GetEnjoyment() >= 100 && FullEnjoyment >= 100
endFunction

function SetVoice(sslBaseVoice ToVoice = none, bool ForceSilence = false)
	IsForcedSilent = ForceSilence
	if ToVoice && IsCreature == ToVoice.Creature
		Voice = ToVoice
	endIf
endFunction

sslBaseVoice function GetVoice()
	return Voice
endFunction

function SetExpression(sslBaseExpression ToExpression)
	if ToExpression
		Expression = ToExpression
	endIf
endFunction

sslBaseExpression function GetExpression()
	return Expression
endFunction

function SetStartAnimationEvent(string EventName, float PlayTime)
	StartAnimEvent = EventName
	StartWait = PapyrusUtil.ClampFloat(PlayTime, 0.1, 10.0)
endFunction

function SetEndAnimationEvent(string EventName)
	EndAnimEvent = EventName
endFunction

bool function IsUsingStrapon()
	return Strapon && ActorRef.IsEquipped(Strapon)
endFunction

function ResolveStrapon(bool force = false)
	if Strapon
		bool equipped = ActorRef.IsEquipped(Strapon)
		if UseStrapon && !equipped
			ActorRef.EquipItem(Strapon, true, true)
		elseIf !UseStrapon && equipped
			ActorRef.UnequipItem(Strapon, true, true)
		endIf
	endIf
endFunction

function EquipStrapon()
	if Strapon && !ActorRef.IsEquipped(Strapon)
		ActorRef.EquipItem(Strapon, true, true)
	endIf
endFunction

function UnequipStrapon()
	if Strapon && ActorRef.IsEquipped(Strapon)
		ActorRef.UnequipItem(Strapon, true, true)
	endIf
endFunction

function SetStrapon(Form ToStrapon)
	if Strapon && !HadStrapon && Strapon != ToStrapon
		ActorRef.RemoveItem(Strapon, 1, true)
	endIf
	Strapon = ToStrapon
	if GetState() == "Animating"
		SyncThread()
	endIf
endFunction

Form function GetStrapon()
	return Strapon
endFunction

bool function PregnancyRisk()
	int cumID = Animation.GetCumID(Position, Stage)
	return cumID > 0 && (cumID == 1 || cumID == 4 || cumID == 5 || cumID == 7) && IsFemale && !MalePosition && Thread.IsVaginal
endFunction

function OverrideStrip(bool[] SetStrip)
	if SetStrip.Length != 33
		Thread.Log("Invalid strip override bool[] - Must be length 33 - was "+SetStrip.Length, "OverrideStrip()")
	else
		StripOverride = SetStrip
	endIf
endFunction

bool function ContinueStrip(Form ItemRef, bool DoStrip = true)
	if !ItemRef
		return False
	endIf
	if StorageUtil.FormListHas(none, "AlwaysStrip", ItemRef) || SexLabUtil.HasKeywordSub(ItemRef, "AlwaysStrip")
		if StorageUtil.GetIntValue(ItemRef, "SometimesStrip", 100) < 100
			if !DoStrip
				return (StorageUtil.GetIntValue(ItemRef, "SometimesStrip", 100) >= Utility.RandomInt(76, 100))
			endIf
			return (StorageUtil.GetIntValue(ItemRef, "SometimesStrip", 100) >= Utility.RandomInt(1, 100))
		endIf
		return True
	endIf
	return (DoStrip && !(StorageUtil.FormListHas(none, "NoStrip", ItemRef) || SexLabUtil.HasKeywordSub(ItemRef, "NoStrip")))
endFunction

function Strip()
	if !ActorRef || IsCreature
		return
	endIf
	; Start stripping animation
	;if DoUndress
	;	Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G"+BaseSex)
	;	NoUndress = true
	;endIf
	; Select stripping array
	bool[] Strip
	if StripOverride.Length == 33
		Strip = StripOverride
	else
		Strip = Config.GetStrip(IsFemale, Thread.UseLimitedStrip(), Thread.IsType[0], IsVictim)
	endIf
	; Log("Strip: "+Strip)
	; Stripped storage
	Form ItemRef
	Form[] Stripped = new Form[34]
	if ActorRef.IsWeaponDrawn() || ActorRef == PlayerRef
		ActorRef.SheatheWeapon()
	endIf
	; Right hand
	ItemRef = ActorRef.GetEquippedObject(1)
	if ContinueStrip(ItemRef, Strip[32])
		Stripped[33] = ItemRef
		ActorRef.UnequipItemEX(ItemRef, 1, false)
		StorageUtil.SetIntValue(ItemRef, "Hand", 1)
	endIf
	; Left hand
	ItemRef = ActorRef.GetEquippedObject(0)
	if ContinueStrip(ItemRef, Strip[32])
		Stripped[32] = ItemRef
		ActorRef.UnequipItemEX(ItemRef, 2, false)
		StorageUtil.SetIntValue(ItemRef, "Hand", 2) 
	endIf
	; Strip armor slots
	Form BodyRef = ActorRef.GetWornForm(Armor.GetMaskForSlot(32))
	int i = 31
	while i >= 0
		; Grab item in slot
		ItemRef = ActorRef.GetWornForm(Armor.GetMaskForSlot(i + 30))
		if ContinueStrip(ItemRef, Strip[i])
			; Start stripping animation
			if DoUndress && ItemRef == BodyRef ;Body
				Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G"+BaseSex)
				Utility.Wait(1.0)
				NoUndress = true
			endIf
			ActorRef.UnequipItemEX(ItemRef, 0, false)
			Stripped[i] = ItemRef
		endIf
		; Move to next slot
		i -= 1
	endWhile
	; Equip the nudesuit
	if Strip[2] && ((Gender == 0 && Config.UseMaleNudeSuit) || (Gender == 1 && Config.UseFemaleNudeSuit))
		ActorRef.EquipItem(Config.NudeSuit, true, true)
	endIf
	; Store stripped items
	Equipment = PapyrusUtil.MergeFormArray(Equipment, PapyrusUtil.ClearNone(Stripped), true)
	Log("Equipment: "+Equipment)
	; Suppress NiOverride High Heels
	if Config.RemoveHeelEffect && ActorRef.GetWornForm(0x00000080)
		if Config.HasNiOverride
			; Remove NiOverride SexLab High Heels
			bool UpdateNiOPosition = NiOverride.RemoveNodeTransformPosition(ActorRef, false, isRealFemale, "NPC", "SexLab.esm")
			; Remove NiOverride High Heels
			if NiOverride.HasNodeTransformPosition(ActorRef, false, isRealFemale, "NPC", "internal")
				float[] pos = NiOverride.GetNodeTransformPosition(ActorRef, false, isRealFemale, "NPC", "internal")
				Log(pos, "RemoveHeelEffect (NiOverride)")
				pos[0] = -pos[0]
				pos[1] = -pos[1]
				pos[2] = -pos[2]
				NiOverride.AddNodeTransformPosition(ActorRef, false, isRealFemale, "NPC", "SexLab.esm", pos)
				NiOverride.UpdateNodeTransform(ActorRef, false, isRealFemale, "NPC")
			elseIf UpdateNiOPosition
				NiOverride.UpdateNodeTransform(ActorRef, false, isRealFemale, "NPC")
			endIf
		endIf
	endIf
endFunction

function UnStrip()
 	if !ActorRef || IsCreature || Equipment.Length == 0
 		return
 	endIf
	; Remove nudesuit if present
	int n = ActorRef.GetItemCount(Config.NudeSuit)
	if n > 0
		ActorRef.RemoveItem(Config.NudeSuit, n, true)
	endIf
	; Continue with undress, or am I disabled?
 	if !DoRedress
 		return ; Fuck clothes, bitch.
 	endIf
 	; Equip Stripped
 	int i = Equipment.Length
 	while i
 		i -= 1
 		if Equipment[i]
 			int hand = StorageUtil.GetIntValue(Equipment[i], "Hand", 0)
 			if hand != 0
	 			StorageUtil.UnsetIntValue(Equipment[i], "Hand")
	 		endIf
	 		ActorRef.EquipItemEx(Equipment[i], hand, false)
  		endIf
 	endWhile
endFunction

bool NoRagdoll
bool property DoRagdoll hidden
	bool function get()
		if NoRagdoll
			return false
		endIf
		return !NoRagdoll && Config.RagdollEnd
	endFunction
	function set(bool value)
		NoRagdoll = !value
	endFunction
endProperty

bool NoUndress
bool property DoUndress hidden
	bool function get()
		if NoUndress || GetState() == "Animating"
			return false
		endIf
		return Config.UndressAnimation
	endFunction
	function set(bool value)
		NoUndress = !value
	endFunction
endProperty

bool NoRedress
bool property DoRedress hidden
	bool function get()
		if NoRedress || (IsVictim && !Config.RedressVictim)
			return false
		endIf
		return !IsVictim || (IsVictim && Config.RedressVictim)
	endFunction
	function set(bool value)
		NoRedress = !value
	endFunction
endProperty

int PathingFlag
function ForcePathToCenter(bool forced)
	PathingFlag = (forced as int)
endFunction
function DisablePathToCenter(bool disabling)
	PathingFlag = IntIfElse(disabling, -1, (PathingFlag == 1) as int)
endFunction
bool property DoPathToCenter
	bool function get()
		return (PathingFlag == 0 && Config.DisableTeleport) || PathingFlag == 1
	endFunction
endProperty

float RefreshExpressionDelay
function RefreshExpression()
	if !ActorRef || IsCreature || !ActorRef.Is3DLoaded() || ActorRef.IsDisabled()
		; Do nothing
	elseIf OpenMouth
		sslBaseExpression.OpenMouth(ActorRef)
		Utility.Wait(1.0)
		if Config.RefreshExpressions && Expression && Expression != none && !ActorRef.IsDead() && !ActorRef.IsUnconscious() && ActorRef.GetActorValue("Health") > 1.0
			int Strength = CalcReaction()
			Expression.Apply(ActorRef, Strength, BaseSex)
			Log("Expression.Applied("+Expression.Name+") Strength:"+Strength+"; OpenMouth:"+OpenMouth)
		endIf
	else
		if Expression && Expression != none && !ActorRef.IsDead() && !ActorRef.IsUnconscious() && ActorRef.GetActorValue("Health") > 1.0
			int Strength = CalcReaction()
			sslBaseExpression.CloseMouth(ActorRef)
			Expression.Apply(ActorRef, Strength, BaseSex)
			Log("Expression.Applied("+Expression.Name+") Strength:"+Strength+"; OpenMouth:"+OpenMouth)
		elseIf sslBaseExpression.IsMouthOpen(ActorRef)
			sslBaseExpression.CloseMouth(ActorRef)			
		endIf
	endIf
	RefreshExpressionDelay = 0.0
endFunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

function TrackedEvent(string EventName)
	if IsTracked
		Thread.SendTrackedEvent(ActorRef, EventName)
	endif
endFunction

function ClearEffects()
	if ActorRef == PlayerRef && GetState() != "Animating"
		; MiscUtil.SetFreeCameraState(false)
		if Game.GetCameraState() == 0
			Game.ForceThirdPerson()
		endIf
	endIf
	ActorRef.StopCombat()
	if ActorRef.IsWeaponDrawn()
		ActorRef.SheatheWeapon()
	endIf
	if ActorRef.IsSneaking()
		ActorRef.StartSneaking()
	endIf
	ActorRef.ClearKeepOffsetFromActor()
endFunction

int property kPrepareActor = 0 autoreadonly hidden
int property kSyncActor    = 1 autoreadonly hidden
int property kResetActor   = 2 autoreadonly hidden
int property kRefreshActor = 3 autoreadonly hidden
int property kStartup      = 4 autoreadonly hidden

function RegisterEvents()
	string e = Thread.Key("")
	; Quick Events
	RegisterForModEvent(e+"Animate", "SendAnimation")
	RegisterForModEvent(e+"Orgasm", "OrgasmEffect")
	RegisterForModEvent(e+"Strip", "Strip")
	; Sync Events
	RegisterForModEvent(e+"Prepare", "PrepareActor")
	RegisterForModEvent(e+"Sync", "SyncActor")
	RegisterForModEvent(e+"Reset", "ResetActor")
	RegisterForModEvent(e+"Refresh", "RefreshActor")
	RegisterForModEvent(e+"Startup", "StartAnimating")
endFunction

function ClearEvents()
	UnregisterForUpdate()
	string e = Thread.Key("")
	; Quick Events
	UnregisterForModEvent(e+"Animate")
	UnregisterForModEvent(e+"Orgasm")
	UnregisterForModEvent(e+"Strip")
	; Sync Events
	UnregisterForModEvent(e+"Prepare")
	UnregisterForModEvent(e+"Sync")
	UnregisterForModEvent(e+"Reset")
	UnregisterForModEvent(e+"Refresh")
	UnregisterForModEvent(e+"Startup")
endFunction

function Initialize()
	; Clear actor
	if ActorRef && ActorRef != none
		; Stop events
		ClearEvents()
		; RestoreActorDefaults()
		; Remove nudesuit if present
		int n = ActorRef.GetItemCount(Config.NudeSuit)
		if n > 0
			ActorRef.RemoveItem(Config.NudeSuit, n, true)
		endIf
	endIf
	; Delete positioning marker
	if MarkerRef
		MarkerRef.Disable()
		MarkerRef.Delete()
	endIf
	; Forms
	ActorRef       = none
	MarkerRef      = none
	HadStrapon     = none
	Strapon        = none
	HDTHeelSpell   = none
	; Voice
	Voice          = none
	ActorVoice     = none
	IsForcedSilent = false
	; Expression
	Expression     = none
	Expressions    = sslUtility.ExpressionArray(0)
	; Flags
	NoRagdoll      = false
	NoUndress      = false
	NoRedress      = false
	NoOrgasm       = false
	ForceOpenMouth = false
	; Integers
	Orgasms        = 0
	BestRelation   = 0
	BaseEnjoyment  = 0
	QuitEnjoyment  = 0
	FullEnjoyment  = 0
	PathingFlag    = 0
	; Floats
	LastOrgasm     = 0.0
	ActorScale     = 1.0
	AnimScale      = 1.0
	NioScale       = 1.0
	StartWait      = 0.1
	; Strings
	EndAnimEvent   = "IdleForceDefaultState"
	StartAnimEvent = ""
	ActorKeyStr    = ""
	PlayingSA      = ""
	CurrentSA      = ""
	PlayingAE      = ""
	CurrentAE      = ""
	; Storage
	StripOverride  = Utility.CreateBoolArray(0)
	Equipment      = Utility.CreateFormArray(0)
	; Make sure alias is emptied
	TryToClear()
endFunction

function Setup()
	; Reset function Libraries - SexLabQuestFramework
	if !Config || !ActorLib || !Stats
		Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
		if SexLabQuestFramework
			Config   = SexLabQuestFramework as sslSystemConfig
			ActorLib = SexLabQuestFramework as sslActorLibrary
			Stats    = SexLabQuestFramework as sslActorStats
		endIf
	endIf
	PlayerRef = Game.GetPlayer()
	Thread    = GetOwningQuest() as sslThreadController
	OrgasmFX  = Config.OrgasmFX
	AnimatingFaction = Config.AnimatingFaction
endFunction

function Log(string msg, string src = "")
	msg = "ActorAlias["+ActorName+"] "+src+" - "+msg
	Debug.Trace("SEXLAB - " + msg)
	if Config.DebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
endFunction

function PlayLouder(Sound SFX, ObjectReference FromRef, float Volume)
	if SFX && FromRef && FromRef.Is3DLoaded() && Volume > 0.0
		if Volume > 0.5
			Sound.SetInstanceVolume(SFX.Play(FromRef), 1.0)
		else
			Sound.SetInstanceVolume(SFX.Play(FromRef), Volume)
		endIf
	endIf
endFunction

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; Ready
function PrepareActor()
endFunction
function PathToCenter()
endFunction
Function CompletePreperation()
EndFunction
; Animating
function StartAnimating()
endFunction
function SyncActor()
endFunction
function SyncThread()
endFunction
function SyncLocation(bool Force = false)
endFunction
function RefreshLoc()
endFunction
function Snap()
endFunction
event OnTranslationComplete()
endEvent
function OrgasmEffect()
endFunction
function DoOrgasm(bool Forced = false)
endFunction
event ResetActor()
endEvent
;/ function RefreshActor()
endFunction /;
event OnOrgasm()
	OrgasmEffect()
endEvent
event OrgasmStage()
	OrgasmEffect()
endEvent

int function CalcEnjoyment(float[] XP, float[] SkillsAmounts, bool IsLeadin, bool IsFemaleActor, float Timer, int OnStage, int MaxStage) global native

int function IntIfElse(bool check, int isTrue, int isFalse)
	if check
		return isTrue
	endIf
	return isFalse
endfunction

; function AdjustCoords(float[] Output, float[] CenterCoords, ) global native
; function AdjustOffset(int i, float amount, bool backwards, bool adjustStage)
; 	Animation.
; endFunction

; function OffsetBed(float[] Output, float[] BedOffsets, float CenterRot) global native

; bool function _SetActor(Actor ProspectRef) native
; function _ApplyExpression(Actor ProspectRef, int[] Presets) global native


; function GetVars()
; 	IntShare = Thread.IntShare
; 	FloatShare = Thread.FloatS1hare
; 	StringShare = Thread.StringShare
; 	BoolShare
; endFunction

; int[] property IntShare auto hidden ; Stage, ActorCount, Thread.BedStatus[1]
; float[] property FloatShare auto hidden ; RealTime, StartedAt
; string[] property StringShare auto hidden ; AdjustKey
; bool[] property BoolShare auto hidden ; 
; sslBaseAnimation[] property _Animation auto hidden ; Animation

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.")
EndFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	;
;																																											;
;									██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗									;
;									██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝									;
;									██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 									;
;									██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  									;
;									███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   									;
;									╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   									;
;																																											;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*	;

function OffsetCoords(float[] Output, float[] CenterCoords, float[] OffsetBy) global native
bool function IsInPosition(Actor CheckActor, ObjectReference CheckMarker, float maxdistance = 30.0) global native

function AttachMarker()	; COMEBACK: The SetScale stuff needs to be reimplemented, prolly
	ActorRef.SetVehicle(MarkerRef)
	if !Config.DisableScale && AnimScale > 0.1 && AnimScale != 1.0
		ActorRef.SetScale(AnimScale)
	endIf
endFunction

function SetAdjustKey(string KeyVar)
	if ActorRef
		Thread.AdjustKey = KeyVar
	endIf
endfunction

state Prepare
	Event OnBeginState()
		LogRedundant("OnBeginState")
	EndEvent

	function StartAnimating()
		LogRedundant("OnBeginState")
	endFunction
	
	event ResetActor()
		LogRedundant("ResetActor")
	endEvent
endState
