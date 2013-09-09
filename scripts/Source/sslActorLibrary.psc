scriptname sslActorLibrary extends Quest

; Scripts
sslActorStats property Stats auto
sslActorSlots property Slots auto

; Data
faction property AnimatingFaction auto
actor property PlayerRef auto
EffectShader property CumVaginalOralAnal auto
EffectShader property CumOralAnal auto
EffectShader property CumVaginalOral auto
EffectShader property CumVaginalAnal auto
EffectShader property CumVaginal auto
EffectShader property CumOral auto
EffectShader property CumAnal auto
weapon property DummyWeapon auto
armor property NudeSuit auto
form[] property Strapons auto hidden

; Config Settings
bool property SOSEnabled auto hidden
bool property bDisablePlayer auto hidden
float property fMaleVoiceDelay auto hidden
float property fFemaleVoiceDelay auto hidden
float property fVoiceVolume auto hidden
bool property bEnableTCL auto hidden 
bool property bScaleActors auto hidden
bool property bUseCum auto hidden
bool property bAllowFFCum auto hidden
float property fCumTimer auto hidden
bool property bUseStrapons auto hidden
bool property bReDressVictim auto hidden
bool property bRagdollEnd auto hidden
bool property bUseMaleNudeSuit auto hidden
bool property bUseFemaleNudeSuit auto hidden
bool property bUndressAnimation auto hidden

int property kBackwards auto hidden ; Right Shift 
int property kAdjustStage auto hidden; Right Ctrl
int property kAdvanceAnimation auto hidden ; Space
int property kChangeAnimation auto hidden ; O
int property kChangePositions auto hidden ; =
int property kAdjustChange auto hidden ; K
int property kAdjustForward auto hidden ; L
int property kAdjustSideways auto hidden ; '
int property kAdjustUpward auto hidden ; ;
int property kRealignActors auto hidden ; [
int property kMoveScene auto hidden ; ]
int property kRestoreOffsets auto hidden ; -
int property kRotateScene auto hidden ; U



; Local
bool hkReady
sslThreadController PlayerController

int function ValidateActor(actor position)
	if Slots.FindSlot(position) != -1
		Debug.TraceAndBox("Failed to add actor to animation; actor appears to already be animating")
		return -10
	endIf

	if position.HasKeyWordString("SexLabForbid")
		Debug.TraceAndBox("Failed to add actor to animation; actor is forbidden from animating")
		return -11
	endIf

	if !position.Is3DLoaded()
		Debug.TraceAndBox("Failed to add actor to animation; actor is not loaded")
		return -12
	endIf

	if position.IsDead()
		Debug.TraceAndBox("Failed to add actor to animation; actor is dead")
		return -13
	endIf

	if position.IsDisabled()
		Debug.TraceAndBox("Failed to add actor to animation; actor is disabled")
		return -14
	endIf

	Race ActorRace = position.GetLeveledActorBase().GetRace()
	if position.IsChild() || ActorRace.IsRaceFlagSet(0x00000004) || StringUtil.Find(ActorRace.GetName(), "Child") != -1 || StringUtil.Find(ActorRace.GetName(), "117") != -1
		Debug.TraceAndBox("Failed to add actor to animation; actor is child")
		return -15
	endIf

	if position.HasKeyWordString("ActorTypeCreature") || position.HasKeyWordString("ActorTypeDwarven")
		Debug.TraceAndBox("Failed to add actor to animation; actor is a creature or Dwemer that is currently not supported")
		return -16
	endIf
	return 1
endFunction

actor[] function SortActors(actor[] actorList, bool femaleFirst = true)
	int actorCount = actorList.Length
	if actorCount == 1
		return actorList ; Why reorder a single actor?
	endIf
	int priorityGender = 1
	if !femaleFirst
		priorityGender = 0
	endIf
	int orderSlot = 0
	int i = 0
	while i < actorCount
		actor a = actorList[i]
		if GetGender(a) == priorityGender && i > orderSlot
			actor moved = actorList[orderSlot]
			actorList[orderSlot] = a
			actorList[i] = moved
			orderSlot += 1
		endIf
		i += 1
	endWhile
	return actorList
endFunction

function ApplyCum(actor a, int cumID)
	if cumID < 1
		return
	elseif cumID == 1
		CumVaginal.Play(a, fCumTimer)
	elseif cumID == 2
		CumOral.Play(a, fCumTimer)
	elseif cumID == 3
		CumAnal.Play(a, fCumTimer)
	elseif cumID == 4
		CumVaginalOral.Play(a, fCumTimer)
	elseif cumID == 5
		CumVaginalAnal.Play(a, fCumTimer)
	elseif cumID == 6
		CumOralAnal.Play(a, fCumTimer)
	elseif cumID == 7
		CumVaginalOralAnal.Play(a, fCumTimer)
	endIf
endFunction

; form[] function StripActor(actor a, actor victim = none, bool animate = true, bool leadIn = false)
; 	int gender = GetGender(a)
; 	bool[] strip
; 	if leadIn && gender < 1
; 		strip = bStripLeadInMale
; 	elseif leadIn && gender > 0
; 		strip = bStripLeadInFemale
; 	elseif victim != none && a == victim
; 		strip = bStripVictim
; 	elseif victim != none && a != victim
; 		strip = bStripAggressor
; 	elseif victim == none && gender < 1
; 		strip = bStripMale
; 	else
; 		strip = bstripFemale
; 	endIf
; 	return StripSlots(a, strip, animate)
; endFunction

form[] function StripSlots(actor a, bool[] strip, bool animate = false, bool allowNudesuit = true)

	if strip.Length != 33
		return none
	endIf

	int gender = GetGender(a)
	form[] items
	int mask
	armor item
	weapon eWeap

	if bUndressAnimation && animate
		if gender > 0 
			Debug.SendAnimationEvent(a, "Arrok_FemaleUndress")
		else
			Debug.SendAnimationEvent(a, "Arrok_MaleUndress")
		endIf
	else
		animate = false
	endIf
	
	; Use Strip settings
	int i = 0
	while i < 33
		if strip[i] && i != 32
			mask = armor.GetMaskForSlot(i + 30)
			item = a.GetWornForm(mask) as armor
			if item != none && !item.HasKeyWordString("SexLabNoStrip")
				a.UnequipItem(item, false, true)
				items = sslUtility.PushForm(item, items)
				if animate
					utility.wait(0.35)
				endIf
			endIf 
		elseif strip[i] && i == 32			
			eWeap = a.GetEquippedWeapon(true)
			if eWeap != none && !eWeap.HasKeyWordString("SexLabNoStrip")
				int type = a.GetEquippedItemType(1)
				if type == 5 || type == 6 || type == 7
					a.AddItem(DummyWeapon, abSilent = true)
					a.EquipItem(DummyWeapon, abSilent = true)
					a.UnEquipItem(DummyWeapon, abSilent = true)
					a.RemoveItem(DummyWeapon, abSilent = true)
				else
					a.UnequipItem(eWeap, false, true)
				endIf
				items = sslUtility.PushForm(eWeap, items)
			endIf
			eWeap = a.GetEquippedWeapon(false)
			if eWeap != none && !eWeap.HasKeyWordString("SexLabNoStrip")
				a.UnequipItem(eWeap, false, true)
				items = sslUtility.PushForm(eWeap, items)
			endIf
		endIf
		i += 1
	endWhile

	; Apply Nudesuit
	if strip[2] && allowNudesuit
		if (gender < 1 && bUseMaleNudeSuit) || (gender == 1  && bUseFemaleNudeSuit)
			a.EquipItem(NudeSuit, false, true)
		endIf
	endIf

	if animate
		Debug.SendAnimationEvent(a, "IdleForceDefaultState")
	endIf

	return items
endFunction

function UnstripActor(actor a, form[] stripped, actor victim = none)
	int i = stripped.Length
	if i < 1
		return
	endIf

	; Remove nudesuits
	int gender = GetGender(a)
	if (gender < 2 && bUseMaleNudeSuit) || (gender == 1  && bUseFemaleNudeSuit)
		a.UnequipItem(NudeSuit, true, true)
		a.RemoveItem(NudeSuit, 1, true)
	endIf

	if a == victim && !bReDressVictim
		return ; Don't requip victims
	endIf
	; Requip stripped
	int hand = 1

	while i
		i -= 1
		int type = stripped[i].GetType()
		if type == 22 || type == 82
			a.EquipSpell(stripped[i] as spell, hand)
		else
			a.EquipItem(stripped[i], false, true)
		endIf
		; Move to other hand if weapon, light, spell, or leveledspell
		if type == 41 || type == 31 || type == 22 || type == 82
			hand = 0
		endIf
	endWhile
endFunction

form function EquipStrapon(actor a)
	int straponCount = Strapons.Length
	if straponCount == 0
		return none
	endIf

	if GetGender(a) == 1
		int sid = utility.RandomInt(0, straponCount - 1)
		a.EquipItem(Strapons[sid], false, true)
		return Strapons[sid]
	else
		return none
	endIf
endFunction

function UnequipStrapon(actor a)
	int straponCount = Strapons.Length
	if straponCount == 0
		return
	endIf

	if GetGender(a) == 1
		int i = 0
		while i < straponCount
			Form strapon = Strapons[i]
			if a.IsEquipped(strapon)
				a.UnequipItem(strapon, false, true)
				a.RemoveItem(strapon, 1, true)
			endIf
			i += 1
		endWhile
	endIf
endFunction


int function GetGender(actor a)
	ActorBase base = a.GetLeveledActorBase()
	if a.HasKeyWordString("SexLabTreatMale") || base.HasKeyWordString("SexLabTreatMale")
		return 0
	elseif a.HasKeyWordString("SexLabTreatFemale") || base.HasKeyWordString("SexLabTreatFemale")
		return 1
	else
		return base.GetSex()
	endIf
endFunction

int[] function GenderCount(actor[] pos)
	int[] genders = new int[2]
	int i = 0
	while i < pos.Length
		if GetGender(pos[i]) > 0
			genders[1] = ( genders[1] + 1 )
		else
			genders[0] = ( genders[0] + 1 )
		endIf
		i += 1
	endWhile
	return genders
endFunction

int function MaleCount(actor[] pos)
	int[] gender = GenderCount(pos)
	return gender[0]
endFunction

int function FemaleCount(actor[] pos)
	int[] gender = GenderCount(pos)
	return gender[1]
endFunction



;#---------------------------#
;#    Hotkeys For Player     #
;#---------------------------#
function _HKStart(sslThreadController Controller)
	RegisterForKey(kBackwards)
	RegisterForKey(kAdjustStage)
	RegisterForKey(kAdvanceAnimation)
	RegisterForKey(kChangeAnimation)
	RegisterForKey(kChangePositions)
	RegisterForKey(kAdjustChange)
	RegisterForKey(kAdjustForward)
	RegisterForKey(kAdjustSideways)
	RegisterForKey(kAdjustUpward)
	RegisterForKey(kRealignActors)
	RegisterForKey(kRestoreOffsets)
	RegisterForKey(kMoveScene)
	RegisterForKey(kRotateScene)
	PlayerController = Controller
	hkReady = true
endFunction

function _HKClear()
	UnregisterForAllKeys()
	PlayerController = none
	hkReady = true
endFunction

event OnKeyDown(int keyCode)
	if PlayerController != none && hkReady
		hkReady = false

		bool backwards
		if kBackwards == 42 || kBackwards == 54
			; Check both shift keys
			backwards = ( input.IsKeyPressed(42) || input.IsKeyPressed(54) )
		else
			backwards = input.IsKeyPressed(kBackwards)
		endIf

		bool adjustingstage
		if kAdjustStage == 157 || kAdjustStage == 29
			; Check both ctrl keys
			adjustingstage = ( input.IsKeyPressed(157) || input.IsKeyPressed(29) )
		else
			adjustingstage = input.IsKeyPressed(kBackwards)
		endIf
		
		; Advance Stage
		if keyCode == kAdvanceAnimation
			PlayerController.AdvanceStage(backwards)
		; Change Animation
		elseIf keyCode == kChangeAnimation
			PlayerController.ChangeAnimation(backwards)
		; Change Positions
		elseIf keyCode == kChangePositions
			PlayerController.ChangePositions(backwards)
		; Forward / Backward adjustments
		elseIf keyCode == kAdjustForward
			PlayerController.AdjustForward(backwards, adjustingstage)
		; Left / Right adjustments
		elseIf keyCode == kAdjustSideways
			PlayerController.AdjustSideways(backwards, adjustingstage)
		; Up / Down adjustments
		elseIf keyCode == kAdjustUpward
			PlayerController.AdjustUpward(backwards, adjustingstage)
		; Change Adjusted Actor
		elseIf keyCode == kAdjustChange
			PlayerController.AdjustChange(backwards)
		; Reposition Actors
		elseIf keyCode == kRealignActors
			PlayerController.RealignActors()
		; Restore animation offsets
		elseIf keyCode == kRestoreOffsets
			PlayerController.RestoreOffsets()
		; Move Scene
		elseIf keyCode == kMoveScene
			PlayerController.MoveScene()
		; Rotate Scene
		elseIf keyCode == kRotateScene
			PlayerController.RotateScene(backwards)
		endIf
		hkReady = true
	endIf
endEvent
;#---------------------------#
;#  END Hotkeys For Player   #
;#---------------------------#
armor function LoadStrapon(string esp, int id)
	armor strapon = Game.GetFormFromFile(id, esp) as armor
	if strapon != none
		Strapons = sslUtility.PushForm(strapon, Strapons)
	endif
	return strapon
endFunction

function _Defaults()
	; Config
	SOSEnabled = false
	bDisablePlayer = false
	fMaleVoiceDelay = 7.0
	fFemaleVoiceDelay = 6.0
	fVoiceVolume = 0.7
	bEnableTCL = true 
	bScaleActors = true
	bUseCum = true
	bAllowFFCum = false
	fCumTimer = 120.0
	bUseStrapons = true
	bReDressVictim = true
	bRagdollEnd = false
	bUseMaleNudeSuit = false
	bUseFemaleNudeSuit = false
	bUndressAnimation = true

	; Hotkeys
	kBackwards = 54 ; Right Shift 
	kAdjustStage = 157; Right Ctrl
	kAdvanceAnimation = 57 ; Space
	kChangeAnimation =  24 ; O
	kChangePositions = 13 ; =
	kAdjustChange = 37 ; K
	kAdjustForward = 38 ; L
	kAdjustSideways = 40 ; '
	kAdjustUpward = 39 ; ;
	kRealignActors = 26 ; [
	kMoveScene = 27 ; ]
	kRestoreOffsets = 12 ; -
	kRotateScene = 22 ; U
endFunction