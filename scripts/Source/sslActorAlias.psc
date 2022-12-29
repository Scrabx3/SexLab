scriptname sslActorAlias extends ReferenceAlias
{
	Alias Script for Actors which are animated by a SexLab Thread
	There is no reason for you to be here, please use the API Functions defined 
	in sslThreadController.psc if you wish to access or write alias data
}

; ------------------------------------------------------- ;
; --- API Related Functions & Data                    --- ;
; ------------------------------------------------------- ;

Actor Property ActorRef Auto Hidden

String Function GetActorName()
	return ActorRef.GetLeveledActorBase().GetName()
EndFunction

Function SetStripping(int aiSlots, bool abStripWeapons)
	StripOverride[0] = aiSlots
	StripOverride[1] = abStripWeapons as int
EndFunction

int function GetGender()
	return ActorLib.GetGender(ActorRef)
endFunction

bool Function IsAggressor()
	return Thread.Victims.Find(ActorRef) == -1
EndFunction

bool function IsVictim()
	return Thread.Victims.Find(ActorRef) > -1
endFunction

string function GetActorKey()
	return ActorKeyStr
endFunction

function AdjustEnjoyment(int AdjustBy)
	BaseEnjoyment += AdjustBy
endfunction

; ------------------------------------------------------- ;
; --- Still under constructions                       --- ;
; ------------------------------------------------------- ;

; Framework access
sslSystemConfig Config
sslActorLibrary ActorLib
sslActorStats Stats
Actor PlayerRef

; TODO: Remove these 3453462342634 local vars for readabilities sake

; Actor Info
String ActorRaceKey
bool IsFemale
bool IsCreature
bool IsFuta
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

; Storage
int[] Flags
Form[] Equipment
Form LeftHand
Form RightHand

int[] StripOverride
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

Form Strapon
Form HadStrapon

Sound OrgasmFX

Spell HDTHeelSpell

; Thread.Animation Position/Thread.Stage flags
bool property ForceOpenMouth auto hidden
bool property OpenMouth hidden
	bool function get()
		return Flags[1] == 1 || ForceOpenMouth ; This is for compatibility reasons because mods like DDi realy need it.
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
; --- Load Alias For Use                              --- ;
; ------------------------------------------------------- ;

; Default Sate for an unused Alias. While in here, the Alias is empty and can be used for animation
; The Script will leave this State once an Actor has been properly filled in
Auto State Empty
	; TODO: Review
	bool function SetActorEx(Actor akReference, bool abIsVictim, sslBaseVoice akVoice, bool abSilent)
		if !akReference || akReference != GetReference()
			Log("ERROR: SetActor("+akReference+") on State:'Ready' is not allowed")
			return false
		endIf
		_ActorKey = sslActorKey.BuildActorKey(akReference, abIsVictim)
		ActorRef = akReference

		ActorBase b = ActorRef.GetLeveledActorBase()
		; ActorVoice = BaseRef.GetVoiceType()
		int Gender = ActorLib.GetGender(ActorRef)
		IsFemale   = Gender == 1
		IsCreature = Gender >= 2
		IsFuta     = ActorLib.GetTrans(ActorRef) != -1

		String r = MiscUtil.GetRaceEditorID(b.GetRace())
		; Player and creature specific
		If(sslActorKey.IsCreature(_ActorKey))
			; Thread.CreatureRef = b.GetRace()
			if sslCreatureAnimationSlots.HasRaceKey("Canines") && sslCreatureAnimationSlots.HasRaceID("Canines", r)
				ActorRaceKey = "Canines"
			else
				ActorRaceKey = sslCreatureAnimationSlots.GetRaceKeyByID(r)
			endIf
		ElseIf(ActorRef == PlayerRef)
			Stats.SeedActor(ActorRef)
		EndIf
		; Actor's Adjustment Key
		ActorKeyStr = r
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
			If sslActorKey.IsFemale(_ActorKey)
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
			bool female = sslActorKey.IsFemale(_ActorKey)
			string[] MOD_OVERRIDE_KEY = NiOverride.GetNodeTransformKeys(ActorRef, False, female, "NPC")
			int idx = 0
			While idx < MOD_OVERRIDE_KEY.Length
				if MOD_OVERRIDE_KEY[idx] != "SexLab.esm"
					TempScale = NiOverride.GetNodeTransformScale(ActorRef, False, female, "NPC", MOD_OVERRIDE_KEY[idx])
					if TempScale > 0
						NioScale = NioScale * TempScale
					endIf
				else ; Remove SexLab Node if present by error
					if NiOverride.RemoveNodeTransformScale(ActorRef, False, female, "NPC", MOD_OVERRIDE_KEY[idx])
						NiOverride.UpdateNodeTransform(ActorRef, False, female, "NPC")
					endIf
				endIf
				idx += 1
			endWhile
		;	Log(self, "NioScale("+NioScale+")")
		endIf

		if !Config.ScaleActors
			float ActorScalePlus
			if Config.RaceAdjustments
				ActorScalePlus = b.GetHeight()
			else
				ActorScalePlus = ActorRef.GetScale()
			endIf
			if NioScale > 0.0 && NioScale != 1.0
				ActorScalePlus = ActorScalePlus * NioScale
			endIf
			ActorScalePlus = ((ActorScalePlus * 25) + 0.5) as int
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
		; Ready
		RegisterEvents()
		TrackedEvent("Added")
		GoToState("Ready")
		Log(self, "SetActor("+ActorRef+")")
		return true
	endFunction
EndState

; ------------------------------------------------------- ;
; --- Actor Prepartion                                --- ;
; ------------------------------------------------------- ;

; This State is invoked after an Actor has been picked up by this Alias
; This state acts as an "preparing" instance, the only way out of it is to either stop the
; animation in its entirety or properly begin the animation
State Ready
	; Declare all animation related variables for this Actor & move into position
	; This does NOT have any influence on the underlying actor instance
	; The alias is considered "ready for animating" when done
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
		String LogInfo = ""
		; Voice
		if !Voice && !IsForcedSilent
			if IsCreature
				Voice = Config.VoiceSlots.PickByRaceKey(sslCreatureAnimationSlots.GetRaceKey(ActorRef.GetRace()))
			else
				Voice = Config.VoiceSlots.PickVoice(ActorRef)
			endIf
		endIf
		LogInfo += "Voice[" + Voice.Name + "] "
		; Strapon & Expression (for NPC only)
		If(!sslActorKey.IsCreature(_ActorKey))
			If(Config.UseStrapons && sslActorKey.IsFemalePure(_ActorKey))
				HadStrapon = Config.WornStrapon(ActorRef)
				If(!HadStrapon)
					Strapon = Config.GetStrapon()
				Else
					Strapon = HadStrapon
				EndIf
			EndIf
			LogInfo += "Strapn[" + Strapon + "] "
			if !Expression && Config.UseExpressions
				Expressions = Config.ExpressionSlots.GetByStatus(ActorRef, IsVictim(), Thread.IsType[0] && !IsVictim())
				if Expressions && Expressions.Length > 0
					Expression = Expressions[Utility.RandomInt(0, (Expressions.Length - 1))]
				endIf
			endIf
			LogInfo += "Expression[" + Expression.Name + "] "
		EndIf
		; Position
		If(ActorRef.GetActorValue("Paralysis") > 0)
			ActorRef.SetActorValue("Paralysis", 0.0)
			SendDefaultAnimEvent()
		EndIf
		If(DoPathToCenter)
			PathToCenter()
		EndIf
		Thread.SyncEventDone(Thread.kPrepareActor)

		; --- Ready to animate --- Misc Data below ---

		; COMEBACK: Everything below still needs reviewing
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
			BaseEnjoyment -= Math.Abs(CalcEnjoyment(Thread.SkillBonus, Skills, Thread.LeadIn, IsFemale, FirsStageTime, 1, Thread.Animation.StageCount)) as int
			if BaseEnjoyment < -5
				BaseEnjoyment += 10
			endIf
			; Add Bonus Enjoyment
			if IsVictim()
				BestRelation = Thread.GetLowestPresentRelationshipRank(ActorRef)
				BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(1, 10)
			else
				BestRelation = Thread.GetHighestPresentRelationshipRank(ActorRef)
				if IsAggressor()
					BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(1, 10)
				else
					BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(1, 10)
				endIf
			endIf
		else
			if IsVictim()
				BestRelation = Thread.GetLowestPresentRelationshipRank(ActorRef)
				BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(1, 10)
			else
				BestRelation = Thread.GetHighestPresentRelationshipRank(ActorRef)
				if IsAggressor()
					BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(1, 10)
				else
					BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(1, 10)
				endIf
			endIf
		endIf
		LogInfo += "BaseEnjoyment["+BaseEnjoyment+"]"
		Log(LogInfo)
	EndEvent

	; Have the Actor path towards center. Latent
	function PathToCenter()
		ObjectReference _center = Thread.CenterRef
		If(ActorRef == _center)
			return
		EndIf
		; float d = ActorRef.GetDistance(_center)
		; Only do pathing if we are reasonably close, otherwise thisd slow down too much
		If(ActorRef.GetDistance(_center) > 6144.0)
			return
		EndIf
		float t = SexLabUtil.GetCurrentGameRealTime() + 15.0
		ActorRef.SetFactionRank(AnimatingFaction, 2)
		ActorRef.EvaluatePackage()
		While (ActorRef.GetDistance(_center) > 256.0 && SexLabUtil.GetCurrentGameRealTime() < t)
			Utility.Wait(0.035)
			; float dd = d
			; d = ActorRef.GetDistance(_center)
			; If(d - dd > -0.1)
			; 	Log("Alias got stuck attempting to path to center. Progressing without path completion...")
			; EndIf
		EndWhile
		ActorRef.SetFactionRank(AnimatingFaction, 1)
		ActorRef.EvaluatePackage()
	EndFunction

	; Called when the main thread wants to start the first animation
	Function PlayAnimation(String asAnimation)
		Debug.SendAnimationEvent(ActorRef, asAnimation)
		PlayingSA = Thread.Animation.Registry
		PlayingAE = asAnimation
		GoToState("Animating")
	EndFunction

	; Can only be called before PrepareActor() is invoked
	Function Clear()
		ClearEvents()
		If(ActorRef == PlayerRef)
			FormList FrostExceptions = Config.FrostExceptions
			If(FrostExceptions)
				FrostExceptions.RemoveAddedForm(Config.BaseMarker)
			EndIf
		EndIf
		Parent.Clear()
		Initialize()
	EndFunction
EndState

; ------------------------------------------------------- ;
; --- Animation Loop       				                    --- ;
; ------------------------------------------------------- ;

string PlayingSA
string PlayingAE
float LoopDelay
float LoopExpressionDelay

; These Events use a slightly hacky workaround, by going directly to the Idling State,
; the EndAnimation() call will invoke the default UnplaceActor() and skip the Animation specific
; cleanup which can no longer be executed properly due to the actor being dead/unloaded
; These can only be received the Alias is filled
Event OnCellDetach()
	Log("An Alias is out of range and cannot be animated anymore. Stopping Thread...")
	GoToState("Idling")
	Thread.EndAnimation()
EndEvent
Event OnUnload()
	Log("An Alias is out of range and cannot be animated anymore. Stopping Thread...")
	GoToState("Idling")
	Thread.EndAnimation()
EndEvent
Event OnDying(Actor akKiller)
	Log("An Alias is dying and cannot be animated anymore. Stopping Thread...")
	GoToState("Idling")
	Thread.EndAnimation()
EndEvent

; For the entire duration of the Animating State, an Actor is to be "placed"
; ONLY leave this state using "UnplaceActor"
state Animating
	Event OnBeginState()
		TrackedEvent("Start")
		StartedAt = SexLabUtil.GetCurrentGameRealTime()
		LastOrgasm = StartedAt
		SyncThread()
		RegisterForSingleUpdate(Utility.RandomFloat(1.0, 3.0))
	EndEvent

	Function UnplaceActor()
		; Clear SFX & expression & any other animation-exclusive effects
		; Make sure of play the last animation stage to prevet AnimObject issues
		String last_anim = Thread.Animation.FetchPositionStage(Position, Thread.Animation.StageCount)
		If(PlayingAE != last_anim)
			PlayingAE = last_anim
			Debug.SendAnimationEvent(ActorRef, last_anim)
		EndIf
		; Reset Expression
		If(Expression || sslBaseExpression.IsMouthOpen(ActorRef))
			sslBaseExpression.CloseMouth(ActorRef)
		EndIf
		ActorRef.ClearExpressionOverride()
		ActorRef.ResetExpressionOverrides()
		sslBaseExpression.ClearMFG(ActorRef)
		GoToState("Idling")
		UnplaceActor()
	EndFunction

	Function Clear()
		Error("Cannot call 'Clear' in Animating State")
	EndFunction

	Event OnUpdate()
		If(Thread.GetState() != "Animating")
			Error("OnUpdate() call but my thread is no longer animating")
			return
		EndIf
		; TODO: Review this block below
		int Strength = CalcReaction()
		if LoopDelay >= VoiceDelay && (Config.LipsFixedValue || Strength > 10)
			LoopDelay = 0.0
			bool UseLipSync = Config.UseLipSync && !IsCreature
			if OpenMouth && UseLipSync && !Config.LipsFixedValue
				sslBaseVoice.MoveLips(ActorRef, none, 0.3)
				Log("PlayMoan:False; UseLipSync:"+UseLipSync+"; OpenMouth:"+OpenMouth)
			elseIf !IsSilent
				Voice.PlayMoan(ActorRef, Strength, IsVictim(), UseLipSync)
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
		If(!NoOrgasm && Config.SeparateOrgasms && Strength >= 100 && Thread.Stage < Thread.Animation.StageCount)
			int cmp
			If(sslActorKey.IsMale(_ActorKey))
				cmp = 20
			ElseIf(sslActorKey.IsMaleCreature(_ActorKey))
				cmp = 30
			EndIf
			If(SexLabUtil.GetCurrentGameRealTime() - LastOrgasm > cmp)
				OrgasmEffect()
			EndIf
		EndIf
		; Loop
		LoopDelay += (VoiceDelay * 0.35)
		LoopExpressionDelay += (VoiceDelay * 0.35)
		RefreshExpressionDelay += (VoiceDelay * 0.35)
		RegisterForSingleUpdate(VoiceDelay * 0.35)
	EndEvent

	; ---- Below Function are called through the Mainthread only ---

	Function PlayAnimation(String asAnimation)
		; Dont restart the animation, might create some odd stuttering otherwise
		If(PlayingAE == asAnimation)
			return
		ElseIf(PlayingSA != Thread.Animation.Registry)
			; This only happens when the active animation is changed
			Debug.SendAnimationEvent(ActorRef, "AnimObjectUnequip")
			SendDefaultAnimEvent()
		EndIf
		Debug.SendAnimationEvent(ActorRef, asAnimation)
		PlayingAE = asAnimation
	EndFunction

	; Unsure why this is here but would theoreitcally solve an issue if someone calls "TranslateTo" on an animating actor, eh
	Event OnTranslationComplete()
		Snap()
	EndEvent

	; --- TODO: Review & reimplement these

	; Basically just an "update for current animation stage"
	function SyncThread()
		Flags = Thread.Animation.PositionFlags(Flags, Thread.AdjustKey, Position, Thread.Stage)

		VoiceDelay = BaseDelay
		ExpressionDelay = Config.ExpressionDelay * BaseDelay
		if !IsSilent && Thread.Stage > 1
			VoiceDelay -= (Thread.Stage * 0.8) + Utility.RandomFloat(-0.2, 0.4)
		endIf
		if VoiceDelay < 0.8
			VoiceDelay = Utility.RandomFloat(0.8, 1.4) ; Can't have delay shorter than animation update loop
		endIf
		Debug.SendAnimationEvent(ActorRef, "SOSBend"+Schlong)
	endFunction

	function RefreshLoc()	; COMEBACK: Call "SetPositions" again with the new offset data
		; Thread.ResetLocation()
	endFunction

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
		elseIf Math.Abs(SexLabUtil.GetCurrentGameRealTime() - LastOrgasm) < 5.0
			Log("Excessive OrgasmEffect Triggered")
			return
		endIf

		; Check if the animation allow Orgasm. By default all the animations with a CumID>0 are type SEX and allow orgasm 
		; But the Lesbian Animations usually don't have CumId assigned and still the orgasm should be allowed at least for Females.
		bool CanOrgasm = Forced || (sslActorKey.IsFemale(_ActorKey) && (Thread.Animation.HasTag("Lesbian") || Thread.Animation.Females == Thread.Animation.PositionCount))
		int i = Thread.ActorCount
		while !CanOrgasm && i > 0
			i -= 1
			CanOrgasm = Thread.Animation.GetCumID(i, Thread.Stage) > 0 || Thread.Animation.GetCum(i) > 0
		endWhile
		if !CanOrgasm
			; Orgasm Disabled for the animation
			return
		endIf

		; Check Separate Orgasm conditions 
		if !Forced && Config.SeparateOrgasms
			if Enjoyment < 100 && (Thread.Stage < Thread.Animation.StageCount || Orgasms > 0)
				; Prevent the orgasm with low enjoyment at least the last stage be reached without orgasms
				return
			endIf
			bool IsCumSource = False
			i = Thread.ActorCount
			while !IsCumSource && i > 0
				i -= 1
				IsCumSource = Thread.Animation.GetCumSource(i, Thread.Stage) == Position
			endWhile
			if !IsCumSource
				if IsFuta && !(Thread.Animation.HasTag("Anal") || Thread.Animation.HasTag("Vaginal") || Thread.Animation.HasTag("Pussy") || Thread.Animation.HasTag("Cunnilingus") || Thread.Animation.HasTag("Fisting") || Thread.Animation.HasTag("Handjob") || Thread.Animation.HasTag("Blowjob") || Thread.Animation.HasTag("Boobjob") || Thread.Animation.HasTag("Footjob") || Thread.Animation.HasTag("Penis"))
					return
				elseIf sslActorKey.IsMale(_ActorKey) && !(Thread.Animation.HasTag("Anal") || Thread.Animation.HasTag("Vaginal") || Thread.Animation.HasTag("Handjob") || Thread.Animation.HasTag("Blowjob") || Thread.Animation.HasTag("Boobjob") || Thread.Animation.HasTag("Footjob") || Thread.Animation.HasTag("Penis"))
					return
				elseIf sslActorKey.IsFemale(_ActorKey) && !(Thread.Animation.HasTag("Anal") || Thread.Animation.HasTag("Vaginal") || Thread.Animation.HasTag("Pussy") || Thread.Animation.HasTag("Cunnilingus") || Thread.Animation.HasTag("Fisting") || Thread.Animation.HasTag("Breast"))
					return
				endIf
			endIf
		endIf
		UnregisterForUpdate()
		LastOrgasm = SexLabUtil.GetCurrentGameRealTime()
		Orgasms   += 1
		; Send an orgasm event hook with actor and orgasm count
		int eid = ModEvent.Create("SexLabOrgasm")
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, FullEnjoyment)
		ModEvent.PushInt(eid, Orgasms)
		ModEvent.Send(eid)
		TrackedEvent("Orgasm")
		Log(GetActorName() + ": Orgasms["+Orgasms+"] FullEnjoyment ["+FullEnjoyment+"] BaseEnjoyment["+BaseEnjoyment+"] Enjoyment["+Enjoyment+"]")
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
		if Thread.ActorCount > 1 && Config.UseCum && (MalePosition || IsCreature) && (Config.AllowFFCum || !sslActorKey.IsFemalePure(_ActorKey) && !sslActorKey.IsFemaleCreature(_ActorKey))
			if Thread.ActorCount == 2
				Thread.PositionAlias(1 - Position).ApplyCum()
			else
				while i > 0
					i -= 1
					if Position != i && Position < Thread.Animation.PositionCount && Thread.Animation.IsCumSource(Position, i, Thread.Stage)
						Thread.PositionAlias(i).ApplyCum()
					endIf
				endWhile
			endIf
		endIf
		Utility.WaitMenuMode(0.2)
		; Reset enjoyment build up, if using multiple orgasms
		QuitEnjoyment += Enjoyment
		if IsSkilled
			if IsVictim()
				BaseEnjoyment += ((BestRelation - 3) + PapyrusUtil.ClampInt((OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure]) as int,-6,6)) * Utility.RandomInt(5, 10)
			else
				if IsAggressor()
					BaseEnjoyment += (-1*((BestRelation - 4) + PapyrusUtil.ClampInt(((Skills[Stats.kLewd]-Skills[Stats.kPure])-(OwnSkills[Stats.kLewd]-OwnSkills[Stats.kPure])) as int,-6,6))) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + PapyrusUtil.ClampInt((((Skills[Stats.kLewd]+OwnSkills[Stats.kLewd])*0.5)-((Skills[Stats.kPure]+OwnSkills[Stats.kPure])*0.5)) as int,0,6)) * Utility.RandomInt(5, 10)
				endIf
			endIf
		else
			if IsVictim()
				BaseEnjoyment += (BestRelation - 3) * Utility.RandomInt(5, 10)
			else
				if IsAggressor()
					BaseEnjoyment += (-1*(BestRelation - 4)) * Utility.RandomInt(5, 10)
				else
					BaseEnjoyment += (BestRelation + 3) * Utility.RandomInt(5, 10)
				endIf
			endIf
		endIf
		; VoiceDelay = 0.8
		RegisterForSingleUpdate(0.8)
	endFunction

	; --- LEGACY
	function SyncLocation(bool Force = false)	; COMEBACK: Add SetPositions() call in here
	endFunction

	function Snap()	; COMEBACK: Add SetPositions() call in here
	endFunction
endState

; ------------------------------------------------------- ;
; --- Animation Pause		                              --- ;
; ------------------------------------------------------- ;

; Intermediate clear
; In this State, the actor may move around freely without any animation specific status restricting them
; The status can be used to force an actor back into the animating state without having to reset the entire script
State Idling
	Function Clear()
		ClearEvents()
		If(ActorRef == PlayerRef)
			FormList FrostExceptions = Config.FrostExceptions
			If(FrostExceptions)
				FrostExceptions.RemoveAddedForm(Config.BaseMarker)
			EndIf
		EndIf
		ActorRef.SetFactionRank(AnimatingFaction, -1)
		ActorRef.RemoveFromFaction(AnimatingFaction)
		TrackedEvent("End")
		Parent.Clear()
		Initialize()
	EndFunction
EndState

; ------------------------------------------------------- ;
; --- Data Accessors                                  --- ;
; ------------------------------------------------------- ;

int function GetEnjoyment()
	if !IsSkilled
		FullEnjoyment = BaseEnjoyment + (PapyrusUtil.ClampFloat(((SexLabUtil.GetCurrentGameRealTime() - StartedAt) + 1.0) / 5.0, 0.0, 40.0) + ((Thread.Stage as float / Thread.Animation.StageCount as float) * 60.0)) as int
	else
		if Position == 0	; COMEBACK: ???
			Thread.RecordSkills()
			Thread.SetBonuses()
		endIf
		FullEnjoyment = BaseEnjoyment + CalcEnjoyment(Thread.SkillBonus, Skills, Thread.LeadIn, sslActorKey.IsFemale(_ActorKey), (SexLabUtil.GetCurrentGameRealTime() - StartedAt), Thread.Stage, Thread.Animation.StageCount)
		; Log("FullEnjoyment["+FullEnjoyment+"] / BaseEnjoyment["+BaseEnjoyment+"] / Enjoyment["+(FullEnjoyment - BaseEnjoyment)+"]")
	endIf

	int Enjoyment = FullEnjoyment - QuitEnjoyment
	if Enjoyment > 0
		return Enjoyment
	endIf
	return 0
endFunction

int function GetPain()
	GetEnjoyment()
	if FullEnjoyment < 0
		return Math.Abs(FullEnjoyment) as int
	endIf
	return 0	
endFunction

int function CalcReaction()
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
		int CumID = Thread.Animation.GetCumID(Position, Thread.Stage)
		if CumID > 0 && ParentCell && ParentCell.IsAttached() ; Error treatment for Spells out of Cell
			ActorLib.ApplyCum(ActorRef, CumID)
		endIf
	endIf
endFunction

function DisableOrgasm(bool bNoOrgasm)
	NoOrgasm = bNoOrgasm
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
		ResolveStrapon()
	endIf
endFunction

Form function GetStrapon()
	return Strapon
endFunction

bool function PregnancyRisk()
	int cumID = Thread.Animation.GetCumID(Position, Thread.Stage)
	return cumID > 0 && (cumID == 1 || cumID == 4 || cumID == 5 || cumID == 7) && IsFemale && !MalePosition && Thread.IsVaginal
endFunction

Function UnStrip()
	int suit_count = ActorRef.GetItemCount(Config.NudeSuit)
	If(suit_count)
		ActorRef.RemoveItem(Config.NudeSuit, suit_count, true)
	EndIf
 	If(!DoRedress)
 		return
	EndIf
	If(LeftHand)
		ActorRef.EquipItemEx(LeftHand, ActorRef.EquipSlot_LeftHand)
	EndIf
	If(RightHand)
		ActorRef.EquipItemEx(RightHand, ActorRef.EquipSlot_RightHand)
	EndIf
 	int i = 0
 	While(i < Equipment.Length)
	 	ActorRef.EquipItemEx(Equipment[i], ActorRef.EquipSlot_Default)
		i += 1
 	EndWhile
EndFunction

bool NoRagdoll
bool property DoRagdoll hidden
	bool function get()
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
		if NoRedress || (IsVictim() && !Config.RedressVictim)
			return false
		endIf
		return !IsVictim() || (IsVictim() && Config.RedressVictim)
	endFunction
	function set(bool value)
		NoRedress = !value
	endFunction
endProperty

int PathingFlag
function ForcePathToCenter(bool forced)
	PathingFlag = forced as int
endFunction
function DisablePathToCenter(bool disabling)
	If(disabling)
		PathingFlag = -1
	Else
		PathingFlag = (PathingFlag == 1) as int
	EndIf
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
			Expression.Apply(ActorRef, Strength, ActorRef.GetLeveledActorBase().GetSex())
			Log("Expression.Applied("+Expression.Name+") Strength:"+Strength+"; OpenMouth:"+OpenMouth)
		endIf
	else
		if Expression && Expression != none && !ActorRef.IsDead() && !ActorRef.IsUnconscious() && ActorRef.GetActorValue("Health") > 1.0
			int Strength = CalcReaction()
			sslBaseExpression.CloseMouth(ActorRef)
			Expression.Apply(ActorRef, Strength, ActorRef.GetLeveledActorBase().GetSex())
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

int function CalcEnjoyment(float[] XP, float[] SkillsAmounts, bool IsLeadin, bool IsFemaleActor, float Timer, int OnStage, int MaxStage) global native

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
; ---	Out Animation                                   --- ;
; ------------------------------------------------------- ;

; Prepare this actor for positioning
; Return duration for the pre-placement starting animation, if any
float Function PlaceActor(ObjectReference akCenter)
	LockActor()
	If(!sslActorKey.IsCreature(_ActorKey))
		If(StartAnimEvent == "")
			; Set intro animation to undressing if none defined & undress anim requested
			If(DoUndress)
				Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G" + (sslActorKey.IsFemale(_ActorKey) as int))
				StartWait = 1.0
			EndIf
		Else
			Debug.SendAnimationEvent(ActorRef, StartAnimEvent)
		EndIf
		Strip()
		ResolveStrapon()
		; Remove HDT High Heels
		If(Config.RemoveHeelEffect)
			HDTHeelSpell = sslpp.GetHDTHeelSpell(ActorRef)
			If(HDTHeelSpell)
				Log("Removing HDT Heel Effect: " + HDTHeelSpell)
				ActorRef.RemoveSpell(HDTHeelSpell)
			EndIf
		EndIf
	ElseIf(StartAnimEvent != "")
		Debug.SendAnimationEvent(ActorRef, StartAnimEvent)
	EndIf
	ActorRef.SetVehicle(akCenter)
	; Scale after SetVehicle
	If(Config.DisableScale)
		ActorScale = 1.0
		AnimScale = 1.0
	Else
		float display = ActorRef.GetScale()
		ActorRef.SetScale(1.0)
		float base = ActorRef.GetScale()
		ActorScale = display / base
		AnimScale  = ActorScale
		If(ActorScale > 0.0 && ActorScale != 1.0)
			ActorRef.SetScale(ActorScale)
		EndIf
		If(Thread.ActorCount > 1 && Config.ScaleActors)
			If(Config.HasNiOverride && !IsCreature && NioScale > 0.0 && NioScale != 1.0)
				bool female = sslActorKey.IsFemale(_ActorKey)
				float FixNioScale = FixNioScale / NioScale
				NiOverride.AddNodeTransformScale(ActorRef, false, female, "NPC", "SexLab.esm", FixNioScale)
				NiOverride.UpdateNodeTransform(ActorRef, false, female, "NPC")
			EndIf
			AnimScale = 1.0 / base
		EndIf
		If(ActorScale != 1.0 && AnimScale != 1.0)
			ActorRef.SetScale(AnimScale)
		EndIf
		Log("Applying Scale on Actor " + ActorRef + ": ["+display+"/"+base+"/"+ActorScale+"/"+AnimScale+"/"+NioScale+"]")
	EndIf
	Debug.SendAnimationEvent(ActorRef, "SOSFastErect")
	return StartWait
EndFunction

; Freeze this actor in place and stop them from moving
Function LockActor()
	ActorRef.StopCombat()
	if ActorRef.IsWeaponDrawn()
		ActorRef.SheatheWeapon()
	endIf
	if ActorRef.IsSneaking()
		ActorRef.StartSneaking()
	endIf
	ActorRef.ClearKeepOffsetFromActor()
	ActorRef.StopTranslation()
	ActorRef.SetFactionRank(AnimatingFaction, 1)
	If(ActorRef == PlayerRef)
		Game.SetPlayerAIDriven()
		If(Game.GetCameraState() == 0)
			Game.ForceThirdPerson()
		EndIf
		If(Config.AutoTFC)
			MiscUtil.SetFreeCameraState(true)
			MiscUtil.SetFreeCameraSpeed(Config.AutoSUCSM)
		EndIf
		; COMEBACK: Not sure if we want this or nah. Its a good way to disable the UI but also stops notifications from displaying
		; UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)
		; Enable hotkeys if needed, and disable autoadvance if not needed
		If(IsVictim() && Config.DisablePlayer)
			Thread.AutoAdvance = true
		Else
			Thread.AutoAdvance = Config.AutoAdvance
			Thread.EnableHotkeys()
		EndIf
	Else
		ActorRef.SetRestrained(true)
		; Start DoNothing package	-- Dont do this for the player
		ActorUtil.AddPackageOverride(ActorRef, Config.DoNothing, 100, 1)
		ActorRef.EvaluatePackage()
	EndIf
	ActorRef.SetAnimationVariableBool("bHumanoidFootIKDisable", true)
EndFunction

; ------------------------------------------------------- ;
; ---	In Animation				                            --- ;
; ------------------------------------------------------- ;

; Reset this Actor into a pre-animation state, allowing them to freely move etc
; Is overwritten by the Animation State to consider animation exclusive statuses, eg expression
Function UnplaceActor()
	SendDefaultAnimEvent(true)
	UnlockActor()
	If(!sslActorKey.IsCreature(_ActorKey))
		Unstrip()
		If(Strapon && !HadStrapon)
			ActorRef.RemoveItem(Strapon, 1, true)
		EndIf
		; HDTSpell is null if not removed by this script previously
		If(HDTHeelSpell && ActorRef.GetWornForm(0x00000080) && !ActorRef.HasSpell(HDTHeelSpell))
			ActorRef.AddSpell(HDTHeelSpell)
		EndIf
	EndIf
	ActorRef.SetVehicle(none)
	If(ActorScale != 1.0 || AnimScale != 1.0)
		ActorRef.SetScale(ActorScale)
	EndIf
	If(Config.HasNiOverride)
		bool female = sslActorKey.IsFemale(_ActorKey)
		bool UpdateNiOPosition = NiOverride.RemoveNodeTransformPosition(ActorRef, false, female, "NPC", "SexLab.esm")
		bool UpdateNiOScale = NiOverride.RemoveNodeTransformScale(ActorRef, false, female, "NPC", "SexLab.esm")
		if UpdateNiOPosition || UpdateNiOScale
			NiOverride.UpdateNodeTransform(ActorRef, false, female, "NPC")
		endIf
	EndIf
	Debug.SendAnimationEvent(ActorRef, "SOSFlaccid")
EndFunction

; Undo "LockActor"
Function UnlockActor()
	ActorRef.SetFactionRank(AnimatingFaction, 0)
	ActorRef.RemoveFromFaction(AnimatingFaction)
	If(ActorRef == PlayerRef)
		Game.SetPlayerAIDriven(false)
		If(Config.AutoTFC)
			MiscUtil.SetFreeCameraState(false)
		EndIf
		; COMEBACK: See LockActor()
    ; UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)
		Thread.DisableHotkeys()
	Else
		ActorUtil.RemovePackageOverride(ActorRef, Config.DoNothing)
		ActorRef.EvaluatePackage()
		ActorRef.SetRestrained(false)
	endIf
	ActorRef.SetAnimationVariableBool("bHumanoidFootIKDisable", false)
EndFunction

Function DoStatistics()
	Actor VictimRef = Thread.VictimRef
	if IsVictim()
		VictimRef = ActorRef
	endIf
	int g = sslActorKey.GetLegacyGenderByKey(_ActorKey)
	float rt = SexLabUtil.GetCurrentGameRealTime()
	sslActorStats.RecordThread(ActorRef, g, BestRelation, StartedAt, rt, Utility.GetCurrentGameTime(), Thread.HasPlayer, VictimRef, Thread.Genders, Thread.SkillXP)
	Stats.AddPartners(ActorRef, Thread.Positions, Thread.Victims)
	if Thread.IsVaginal
		Stats.AdjustSkill(ActorRef, "VaginalCount", 1)
	endIf
	if Thread.IsAnal
		Stats.AdjustSkill(ActorRef, "AnalCount", 1)
	endIf
	if Thread.IsOral
		Stats.AdjustSkill(ActorRef, "OlCount", 1)
	endIf
EndFunction

; ------------------------------------------------------- ;
; --- Misc Utility					                          --- ;
; ------------------------------------------------------- ;

float Function Strip()
	int[] Strip
	If(StripOverride.Length == 2)
		Strip = StripOverride
	Else
		; COMEBACK: Config Menu is too much of an unreadable nightmare to do this properly but eventually Ill have to, eh
		bool[] s = Config.GetStrip(IsFemale, Thread.UseLimitedStrip(), Thread.IsType[0], IsVictim())
		Strip = new int[2]
		int i = 0
		While(i < 32)
			If(s[i])
				Strip[0] = Strip[0] + Math.LeftShift(1, i)
			EndIf
			i += 1
		EndWhile
		Strip[1] = s[32] as int
	EndIf
	; Weapons
	If(Strip[1])
		RightHand = ActorRef.GetEquippedObject(1)
		If(RightHand && !SexLabUtil.HasKeywordSub(RightHand, "NoStrip"))
			ActorRef.UnequipItemEX(RightHand, ActorRef.EquipSlot_RightHand, false)
		EndIf
		LeftHand = ActorRef.GetEquippedObject(0)
		If(LeftHand && !SexLabUtil.HasKeywordSub(LeftHand, "NoStrip"))
			ActorRef.UnequipItemEX(LeftHand, ActorRef.EquipSlot_LeftHand, false)
		EndIf
	Else
		RightHand = none
		LeftHand = none
	EndIf
	; Armor
	Equipment = sslpp.StripActor(ActorRef, Strip[0])
	Log("<Strip> Left Weapon: " + LeftHand + " | Right Weapon: " + RightHand + " | Equipment: " + Equipment)
	; Equip the nudesuit
	if Math.LogicalAnd(Strip[0], 4) && (sslActorKey.IsMale(_ActorKey) && Config.UseMaleNudeSuit || sslActorKey.IsFemale(_ActorKey) && Config.UseFemaleNudeSuit)
		ActorRef.EquipItem(Config.NudeSuit, true, true)
	endIf
	; Suppress NiOverride High Heels
	if Config.RemoveHeelEffect && ActorRef.GetWornForm(0x00000080)
		if Config.HasNiOverride
			bool female = sslActorKey.IsFemale(_ActorKey)
			; Remove NiOverride SexLab High Heels
			bool UpdateNiOPosition = NiOverride.RemoveNodeTransformPosition(ActorRef, false, female, "NPC", "SexLab.esm")
			; Remove NiOverride High Heels
			if NiOverride.HasNodeTransformPosition(ActorRef, false, female, "NPC", "internal")
				float[] pos = NiOverride.GetNodeTransformPosition(ActorRef, false, female, "NPC", "internal")
				Log(pos, "RemoveHeelEffect (NiOverride)")
				pos[0] = -pos[0]
				pos[1] = -pos[1]
				pos[2] = -pos[2]
				NiOverride.AddNodeTransformPosition(ActorRef, false, female, "NPC", "SexLab.esm", pos)
				NiOverride.UpdateNodeTransform(ActorRef, false, female, "NPC")
			elseIf UpdateNiOPosition
				NiOverride.UpdateNodeTransform(ActorRef, false, female, "NPC")
			endIf
		endIf
	endIf
endFunction

Function SendDefaultAnimEvent(bool Exit = False)
	Debug.SendAnimationEvent(ActorRef, "AnimObjectUnequip")
	If(!sslActorKey.IsCreature(_ActorKey))
		Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
		return
	EndIf
	String racekey = sslActorKey.GetRaceKeyByKey(_ActorKey)
	If(racekey != "")
		if racekey == "Dragons"
			Debug.SendAnimationEvent(ActorRef, "FlyStopDefault") ; for Dragons only
			Debug.SendAnimationEvent(ActorRef, "Reset") ; for Dragons only
		elseIf racekey == "Hagravens"
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") ; for Dragons only
			if Exit
				Debug.SendAnimationEvent(ActorRef, "Reset") ; for Dragons only
			endIf
		elseIf racekey == "Chaurus" || racekey == "ChaurusReapers"
			Debug.SendAnimationEvent(ActorRef, "FNISDefault") ; for dwarvenspider and chaurus without time bettwen.
		elseIf racekey == "DwarvenSpiders"
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
		elseIf racekey == "Draugrs" || racekey == "Seekers" || racekey == "DwarvenBallistas" || racekey == "DwarvenSpheres" || racekey == "DwarvenCenturions"
			Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") ; for draugr, trolls daedras and all dwarven exept spiders
		elseIf racekey == "Trolls"
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
			if Exit
				Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") ; the troll need this afther "ReturnToDefault" to allow the attack idles
			endIf
		elseIf racekey == "Chickens" || racekey == "Rabbits" || racekey == "Slaughterfishes"
			Debug.SendAnimationEvent(ActorRef, "ReturnDefaultState") ; for chicken, hare and slaughterfish
			if Exit
				Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
			endIf
		elseIf racekey == "Werewolves" || racekey == "VampireLords"
			Debug.SendAnimationEvent(ActorRef, "IdleReturnToDefault") ; for Werewolves and VampirwLords
		Else
			Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") ; the rest creature-animal
		EndIf
	ElseIf(Exit)
		Debug.SendAnimationEvent(ActorRef, "ReturnDefaultState") ; for chicken, hare and slaughterfish before the "ReturnToDefault"
		Debug.SendAnimationEvent(ActorRef, "ReturnToDefault") ; the rest creature-animal
		Debug.SendAnimationEvent(ActorRef, "FNISDefault") ; for dwarvenspider and chaurus
		Debug.SendAnimationEvent(ActorRef, "IdleReturnToDefault") ; for Werewolves and VampirwLords
		Debug.SendAnimationEvent(ActorRef, "ForceFurnExit") ; for Trolls afther the "ReturnToDefault" and draugr, daedras and all dwarven exept spiders
		Debug.SendAnimationEvent(ActorRef, "Reset") ; for Hagravens afther the "ReturnToDefault" and Dragons
	EndIf
EndFunction

; ------------------------------------------------------- ;
; --- Thread Events           				                --- ;
; ------------------------------------------------------- ;

function TrackedEvent(string EventName)
	If(Config.ThreadLib.IsActorTracked(ActorRef))
		Thread.SendTrackedEvent(ActorRef, EventName)
	EndIf
endFunction

function RegisterEvents()
	string e = Thread.Key("")
	; Quick Events
	RegisterForModEvent(e+"Orgasm", "OrgasmEffect")
	RegisterForModEvent(e+"Strip", "Strip")
	; Sync Events
	RegisterForModEvent(e+"Prepare", "PrepareActor")
endFunction

function ClearEvents()
	string e = Thread.Key("")
	; Quick Events
	UnregisterForModEvent(e+"Orgasm")
	UnregisterForModEvent(e+"Strip")
	; Sync Events
	UnregisterForModEvent(e+"Prepare")
endFunction

; ------------------------------------------------------- ;
; --- Thread Setup    								                --- ;
; ------------------------------------------------------- ;

function Log(string msg, string src = "")
	msg = "Thread[" + Thread.tid + "] ActorAlias["+GetActorName()+"] "+src+" - "+msg
	Debug.Trace("SEXLAB - " + msg)
	if Config.DebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
endFunction

Function Error(String msg)
	msg = "ActorAlias["+GetActorName()+"] - "+msg
	Debug.TraceStack("SEXLAB - " + msg)
	if Config.DebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
EndFunction

Function Initialize()
	; Forms
	ActorRef       = none
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
	StartWait      = 0.0
	; Strings
	EndAnimEvent   = "IdleForceDefaultState"
	StartAnimEvent = ""
	ActorKeyStr    = ""
	PlayingSA      = ""
	PlayingAE      = ""
	; Storage
	StripOverride  = Utility.CreateIntArray(0)
	Equipment      = Utility.CreateFormArray(0)
	GoToState("Empty")
EndFunction

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

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; Empty
bool Function SetActor(Actor ProspectRef)
	return SetActorEx(ProspectRef, false, none, false)
EndFunction
bool function SetActorEx(Actor akReference, bool abIsVictim, sslBaseVoice akVoice, bool abSilent)
	return false
endFunction
; Ready
function PrepareActor()
endFunction
function PathToCenter()
endFunction
; Animating
function SyncThread()
endFunction
function SyncLocation(bool Force = false)
endFunction
function RefreshLoc()
endFunction
function Snap()
endFunction
Function PlayAnimation(String asAnimation)
EndFunction
function OrgasmEffect()
endFunction
function DoOrgasm(bool Forced = false)
endFunction

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

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.\n\nPlease report this to Scrab with a Papyrus Log attached")
	Debug.TraceStack("Invoking Legacy Content Function " + asFunction)
EndFunction

; ------------------------------------------------------- ;
; --- Legacy Content Supported                        --- ;
; ------------------------------------------------------- ;

function SetAdjustKey(string KeyVar)
	if ActorRef
		Thread.AdjustKey = KeyVar
	endIf
endfunction

function OverrideStrip(bool[] SetStrip)
	if SetStrip.Length != 33
		Thread.Log("Invalid strip override bool[] - Must be length 33 - was "+SetStrip.Length, "OverrideStrip()")
	else
		StripOverride[0] = 0
		int i = 0
		While(i < 32)
			If(SetStrip[i])
				i += Math.LeftShift(1, i)
			EndIF
		EndWhile
		StripOverride[1] = SetStrip[32] as int
	endIf
endFunction

function SetVictim(bool Victimize)
	If(Victimize)
		If(!IsVictim())
			Thread.Victims = PapyrusUtil.PushActor(Thread.Victims, ActorRef)
		EndIf
	ElseIf(!IsVictim())
		Thread.Victims = PapyrusUtil.RemoveActor(Thread.Victims, ActorRef)
	EndIf
endFunction

event OnOrgasm()
	OrgasmEffect()
endEvent
event OrgasmStage()
	OrgasmEffect()
endEvent

; ------------------------------------------------------- ;
; --- Internal Redundant                              --- ;
; ------------------------------------------------------- ;

function OffsetCoords(float[] Output, float[] CenterCoords, float[] OffsetBy) global native
bool function IsInPosition(Actor CheckActor, ObjectReference CheckMarker, float maxdistance = 30.0) global native

; A framework shouldnt be "random" and the keyword convention should be established strongly enough to not rely on StorageUtil anymore
; Not deleting contents for the unlikely cause it causes issues
bool function ContinueStrip(Form ItemRef, bool DoStrip = true)
	if StorageUtil.FormListHas(none, "AlwaysStrip", ItemRef) || SexLabUtil.HasKeywordSub(ItemRef, "AlwaysStrip")
		if StorageUtil.GetIntValue(ItemRef, "SometimesStrip", 100) < 100
			if !DoStrip
				return (StorageUtil.GetIntValue(ItemRef, "SometimesStrip", 100) >= Utility.RandomInt(76, 100))
			endIf
			return (StorageUtil.GetIntValue(ItemRef, "SometimesStrip", 100) >= Utility.RandomInt(1, 100))
		endIf
		return True
	endIf
	return DoStrip && !(StorageUtil.FormListHas(none, "NoStrip", ItemRef) || SexLabUtil.HasKeywordSub(ItemRef, "NoStrip"))
endFunction

int function IntIfElse(bool check, int isTrue, int isFalse)
	if check
		return isTrue
	endIf
	return isFalse
endfunction

function AttachMarker()
	LogRedundant("AttachMarker")
endFunction
function LoadShares()
	LogRedundant("LoadShares")
endFunction
function GetPositionInfo()
	LogRedundant("GetPositionInfo")
endFunction
function SyncActor()
	LogRedundant("SyncActor")
endFunction
function SyncAll(bool Force = false)
	LogRedundant("SyncAll")
endFunction
function RefreshActor()
	LogRedundant("RefreshActor")
endFunction
function ClearAlias()
	LogRedundant("ClearAlias")
endFunction
function RestoreActorDefaults()
	LogRedundant("RestoreActorDefaults")
endFunction
function SendAnimation()
	LogRedundant("SendAnimation")
endFunction
function StopAnimating(bool Quick = false, string ResetAnim = "IdleForceDefaultState")
	LogRedundant("StopAnimating")
endFunction
function StartAnimating()
	LogRedundant("OnBeginState")
endFunction
event ResetActor()
	LogRedundant("ResetActor")
endEvent
function ClearEffects()
	LogRedundant("ClearEffects")
endFunction