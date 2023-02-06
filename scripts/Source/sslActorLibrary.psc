scriptname sslActorLibrary extends sslSystemLibrary

; Data
Faction property AnimatingFaction auto
Faction property GenderFaction auto
Faction property ForbiddenFaction auto

Spell property Vaginal1Oral1Anal1 auto
Spell property Vaginal2Oral1Anal1 auto
Spell property Vaginal2Oral2Anal1 auto
Spell property Vaginal2Oral1Anal2 auto
Spell property Vaginal1Oral2Anal1 auto
Spell property Vaginal1Oral2Anal2 auto
Spell property Vaginal1Oral1Anal2 auto
Spell property Vaginal2Oral2Anal2 auto
Spell property Oral1Anal1 auto
Spell property Oral2Anal1 auto
Spell property Oral1Anal2 auto
Spell property Oral2Anal2 auto
Spell property Vaginal1Oral1 auto
Spell property Vaginal2Oral1 auto
Spell property Vaginal1Oral2 auto
Spell property Vaginal2Oral2 auto
Spell property Vaginal1Anal1 auto
Spell property Vaginal2Anal1 auto
Spell property Vaginal1Anal2 auto
Spell property Vaginal2Anal2 auto
Spell property Vaginal1 auto
Spell property Vaginal2 auto
Spell property Oral1 auto
Spell property Oral2 auto
Spell property Anal1 auto
Spell property Anal2 auto

Keyword property CumOralKeyword auto
Keyword property CumAnalKeyword auto
Keyword property CumVaginalKeyword auto
Keyword property CumOralStackedKeyword auto
Keyword property CumAnalStackedKeyword auto
Keyword property CumVaginalStackedKeyword auto

Keyword property ActorTypeNPC auto

;/-----------------------------------------------\;
;|	Actor Handling/Effect Functions              |;
;\-----------------------------------------------/;

function ApplyCum(Actor ActorRef, int CumID)
	AddCum(ActorRef, (cumID == 1 || cumID == 4 || cumID == 5 || cumID == 7), (cumID == 2 || cumID == 4 || cumID == 6 || cumID == 7), (cumID == 3 || cumID == 5 || cumID == 6 || cumID == 7))
endFunction

function ClearCum(Actor ActorRef)
	if !ActorRef
		return
	endIf
	ActorRef.DispelSpell(Vaginal1Oral1Anal1)
	ActorRef.DispelSpell(Vaginal2Oral1Anal1)
	ActorRef.DispelSpell(Vaginal2Oral2Anal1)
	ActorRef.DispelSpell(Vaginal2Oral1Anal2)
	ActorRef.DispelSpell(Vaginal1Oral2Anal1)
	ActorRef.DispelSpell(Vaginal1Oral2Anal2)
	ActorRef.DispelSpell(Vaginal1Oral1Anal2)
	ActorRef.DispelSpell(Vaginal2Oral2Anal2)
	ActorRef.DispelSpell(Oral1Anal1)
	ActorRef.DispelSpell(Oral2Anal1)
	ActorRef.DispelSpell(Oral1Anal2)
	ActorRef.DispelSpell(Oral2Anal2)
	ActorRef.DispelSpell(Vaginal1Oral1)
	ActorRef.DispelSpell(Vaginal2Oral1)
	ActorRef.DispelSpell(Vaginal1Oral2)
	ActorRef.DispelSpell(Vaginal2Oral2)
	ActorRef.DispelSpell(Vaginal1Anal1)
	ActorRef.DispelSpell(Vaginal2Anal1)
	ActorRef.DispelSpell(Vaginal1Anal2)
	ActorRef.DispelSpell(Vaginal2Anal2)
	ActorRef.DispelSpell(Vaginal1)
	ActorRef.DispelSpell(Vaginal2)
	ActorRef.DispelSpell(Oral1)
	ActorRef.DispelSpell(Oral2)
	ActorRef.DispelSpell(Anal1)
	ActorRef.DispelSpell(Anal2)
endFunction

function AddCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
	if !ActorRef && !Vaginal && !Oral && !Anal
		return ; Nothing to do
	endIf

	int kVaginal = ((Vaginal || ActorRef.HasMagicEffectWithKeyword(CumVaginalStackedKeyword)) as int) + (ActorRef.HasMagicEffectWithKeyword(CumVaginalKeyword) as int)
	int kOral    = ((Oral || ActorRef.HasMagicEffectWithKeyword(CumOralStackedKeyword)) as int)       + (ActorRef.HasMagicEffectWithKeyword(CumOralKeyword) as int)
	int kAnal    = ((Anal || ActorRef.HasMagicEffectWithKeyword(CumAnalStackedKeyword)) as int)       + (ActorRef.HasMagicEffectWithKeyword(CumAnalKeyword) as int)
	Log("Vaginal:"+Vaginal+"-"+kVaginal+" Oral:"+Oral+"-"+kOral+" Anal:"+Anal+"-"+kAnal)

	if kVaginal == 1 && kOral == 1 && kAnal == 1
		Vaginal1Oral1Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 1 && kAnal == 1
		Vaginal2Oral1Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 2 && kAnal == 1
		Vaginal2Oral2Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 1 && kAnal == 2
		Vaginal2Oral1Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 2 && kAnal == 1
		Vaginal1Oral2Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 2 && kAnal == 2
		Vaginal1Oral2Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 1 && kAnal == 2
		Vaginal1Oral1Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 2 && kAnal == 2
		Vaginal2Oral2Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 1 && kAnal == 1
		Oral1Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 2 && kAnal == 1
		Oral2Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 1 && kAnal == 2
		Oral1Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 2 && kAnal == 2
		Oral2Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 1 && kAnal == 0
		Vaginal1Oral1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 1 && kAnal == 0
		Vaginal2Oral1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 2 && kAnal == 0
		Vaginal1Oral2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 2 && kAnal == 0
		Vaginal2Oral2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 0 && kAnal == 1
		Vaginal1Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 0 && kAnal == 1
		Vaginal2Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 0 && kAnal == 2
		Vaginal1Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 0 && kAnal == 2
		Vaginal2Anal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 1 && kOral == 0 && kAnal == 0
		Vaginal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 2 && kOral == 0 && kAnal == 0
		Vaginal2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 1 && kAnal == 0
		Oral1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 2 && kAnal == 0
		Oral2.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 0 && kAnal == 1
		Anal1.Cast(ActorRef, ActorRef)
	elseif kVaginal == 0 && kOral == 0 && kAnal == 2
		Anal2.Cast(ActorRef, ActorRef)
	endIf
endFunction

int function CountCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
	if !ActorRef && !Vaginal && !Oral && !Anal
		return -1; Nothing to do
	endIf
	int Amount
	if Vaginal
		Amount += ActorRef.HasMagicEffectWithKeyword(CumVaginalKeyword) as int
		Amount += ActorRef.HasMagicEffectWithKeyword(CumVaginalStackedKeyword) as int
	endIf
	if Oral
		Amount += ActorRef.HasMagicEffectWithKeyword(CumOralKeyword) as int
		Amount += ActorRef.HasMagicEffectWithKeyword(CumOralStackedKeyword) as int
	endIf
	if Anal
		Amount += ActorRef.HasMagicEffectWithKeyword(CumAnalKeyword) as int
		Amount += ActorRef.HasMagicEffectWithKeyword(CumAnalStackedKeyword) as int
	endIf
	return Amount
endFunction

;/-----------------------------------------------\;
;|	Equipment Functions                          |;
;\-----------------------------------------------/;

Form[] function StripActor(Actor ActorRef, Actor VictimRef = none, bool DoAnimate = true, bool LeadIn = false)
	int[] strips = Config.GetStripSettings(GetGender(ActorRef) == 1, LeadIn, VictimRef, ActorRef == VictimRef)
	return StripActorImpl(ActorRef, strips[0], strips[1], DoAnimate)
endFunction

function MakeNoStrip(Form ItemRef)
	sslpp.WriteStrip(ItemRef, true)
endFunction

function MakeAlwaysStrip(Form ItemRef)
	sslpp.WriteStrip(ItemRef, false)
endFunction

function ClearStripOverride(Form ItemRef)
	sslpp.EraseStrip(ItemRef)
endFunction

function ResetStripOverrides()
	sslpp.EraseStripAll()
endFunction

bool function IsNoStrip(Form ItemRef)
	return sslpp.CheckStrip(ItemRef) == -1
endFunction

bool function IsAlwaysStrip(Form ItemRef)
	return sslpp.CheckStrip(ItemRef) == 1
endFunction

bool function IsStrippable(Form ItemRef)
	return !IsNoStrip(ItemRef)
endFunction

Form[] Function StripActorImpl(Actor akActor, int aiSlots, bool abStripWeapons = true, bool abAnimate = false)
	If(!akActor)
		return Utility.CreateFormArray(0)
	EndIf
	abAnimate = abAnimate && akActor.GetWornForm(0x4)	; Body armor slot
	If(abAnimate)
		int Gender = akActor.GetLeveledActorBase().GetSex()
		Debug.SendAnimationEvent(akActor, "Arrok_Undress_G" + Gender)
		Utility.Wait(0.6)
	EndIf
	Form[] ret = sslpp.StripActor(akActor, aiSlots)
	If(abStripWeapons)
		Form RightHand = akActor.GetEquippedObject(1)
		If(RightHand && IsStrippable(RightHand))
			akActor.UnequipItemEX(RightHand, akActor.EquipSlot_RightHand, false)
			ret = PapyrusUtil.PushForm(ret, LeftHand)
			StorageUtil.SetIntValue(RightHand, "Hand", 1)
		EndIf
		Form LeftHand = akActor.GetEquippedObject(0)
		If(LeftHand && IsStrippable(LeftHand))
			akActor.UnequipItemEX(LeftHand, akActor.EquipSlot_LeftHand, false)
			ret = PapyrusUtil.PushForm(ret, LeftHand)
			StorageUtil.SetIntValue(RightHand, "Hand", 2)
		EndIf
	EndIf
	If(abAnimate)
		Utility.Wait(0.4)
	EndIf
	return ret
EndFunction

function UnstripActor(Actor ActorRef, Form[] Stripped, bool IsVictim = false)
	If(!ActorRef)
		return
	EndIf
	If(IsVictim && !Config.RedressVictim)
		return
	EndIf
	int i = 0
	While(i < Stripped.Length)
		If(Stripped[i])
 			int hand = StorageUtil.GetIntValue(Stripped[i], "Hand", 0)
 			If(hand)
	 			StorageUtil.UnsetIntValue(Stripped[i], "Hand")
			EndIf
	 		ActorRef.EquipItemEx(Stripped[i], hand, false)
		EndIf
		i += 1
	EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Actor Validation                                --- ;
; ------------------------------------------------------- ;

; If the actor in some state that disallows animation by SL
bool Function CanAnimateActor(Actor akActor) native global
bool Function GetIsActorValid(Actor akActor)
	If(!akActor)
		Log("ValidateActor(NONE) -- FALSE -- Because they don't exist.")
		return false
	EndIf
	String name = akActor.GetLeveledActorBase().GetName()
	If(!CanAnimateActor(akActor))
		Log("ValidateActor(" + name + ") -- FALSE -- They cannot be animated")
		return false
	ElseIf(akActor.IsInFaction(AnimatingFaction))
		Log("ValidateActor(" + name + ") -- FALSE -- They appear to already be animating")
		return false
	ElseIf(akActor.IsInFaction(ForbiddenFaction))
		Log("ValidateActor(" + name + ") -- FALSE -- They are not allowed to be animated")
		return false
	ElseIf(!akActor.HasKeyword(ActorTypeNPC) && (!Config.AllowCreatures || !sslCreatureAnimationSlots.HasCreatureType(akActor)))
		Log("ValidateActor(" + name + ") -- FALSE -- They are an invalid creature")
		return false
	EndIf
	Log("ValidateActor(" + name + ") -- TRUE -- MISS")
	return true
EndFunction

function ForbidActor(Actor ActorRef)
	if ActorRef
		ActorRef.AddToFaction(ForbiddenFaction)
	endIf
endFunction

function AllowActor(Actor ActorRef)
	if ActorRef
		ActorRef.RemoveFromFaction(ForbiddenFaction)
	endIf
endFunction

bool function IsForbidden(Actor ActorRef)
	return ActorRef && ActorRef.IsInFaction(ForbiddenFaction)
endFunction

; ------------------------------------------------------- ;
; --- Gender Functions                                --- ;
; ------------------------------------------------------- ;

function TreatAsMale(Actor ActorRef)
	TreatAsGender(ActorRef, false)
endFunction

function TreatAsFemale(Actor ActorRef)
	TreatAsGender(ActorRef, true)
endFunction

function ClearForcedGender(Actor ActorRef)
	if !ActorRef
		return
	endIf
	ActorRef.RemoveFromFaction(GenderFaction)
	int eid = ModEvent.Create("SexLabActorGenderChange")
	if eid
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, ActorRef.GetLeveledActorBase().GetSex())
		ModEvent.Send(eid)
	endIf
endFunction

function TreatAsGender(Actor ActorRef, bool AsFemale)
	if !ActorRef
		return
	endIf
	ActorRef.RemoveFromFaction(GenderFaction)
	int sex = ActorRef.GetLeveledActorBase().GetSex()
	if (sex != 0 && !AsFemale) || (sex != 1 && AsFemale) 
		ActorRef.SetFactionRank(GenderFaction, AsFemale as int)
	endIf
	; Send event for whenever an actor's gender is altered
	int eid = ModEvent.Create("SexLabActorGenderChange")
	if eid
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, AsFemale as int)
		ModEvent.Send(eid)
	endIf
endFunction

int function GetTrans(Actor ActorRef)
	if ActorRef && ActorRef.IsInFaction(Config.GenderFaction)
		ActorBase BaseRef = ActorRef.GetLeveledActorBase()
		if !BaseRef || ActorRef.GetFactionRank(GenderFaction) == BaseRef.GetSex()
			return -1
		elseIf sslCreatureAnimationSlots.HasRaceType(BaseRef.GetRace())
			return 2 + ActorRef.GetFactionRank(Config.GenderFaction)
		else
			return ActorRef.GetFactionRank(Config.GenderFaction)
		endIf
	endIf
	return -1
endFunction

int[] function GetTransAll(Actor[] Positions)
	int i = Positions.Length
	int[] Trans = Utility.CreateIntArray(i)
	while i > 0
		i -= 1
		Trans[i] = GetTrans(Positions[i])
	endWhile
	return Trans
endFunction

int[] function TransCount(Actor[] Positions)
	int[] Trans = new int[4]
	int i = Positions.Length
	while i > 0
		i -= 1
		int g = GetTrans(Positions[i])
		if g >= 0 && g < 4
			Trans[g] = Trans[g] + 1
		endIf
	endWhile
	return Trans
endFunction

int function GetGender(Actor ActorRef)
	if ActorRef
		ActorBase BaseRef = ActorRef.GetLeveledActorBase()
		if sslCreatureAnimationSlots.HasRaceType(BaseRef.GetRace())
			if !Config.UseCreatureGender
				return 2 ; Creature - All Male
			elseIf ActorRef.IsInFaction(GenderFaction)
				return 2 + ActorRef.GetFactionRank(GenderFaction) ; CreatureGender + Override
			else
				return 2 + BaseRef.GetSex() ; CreatureGenders: 2+
			endIf
		elseIf ActorRef.IsInFaction(GenderFaction)
			return ActorRef.GetFactionRank(GenderFaction) ; Override
		else
			return BaseRef.GetSex() ; Default
		endIf
	endIf
	return 0 ; Invalid actor - default to male for compatibility
endFunction

int[] function GetGendersAll(Actor[] Positions)
	int i = Positions.Length
	int[] Genders = Utility.CreateIntArray(i)
	while i > 0
		i -= 1
		Genders[i] = GetGender(Positions[i])
	endWhile
	return Genders
endFunction

int[] function GenderCount(Actor[] Positions)
	int[] Genders = new int[4]
	int i = Positions.Length
	while i > 0
		i -= 1
		int g = GetGender(Positions[i])
		Genders[g] = Genders[g] + 1
	endWhile
	return Genders
endFunction

bool function IsCreature(Actor ActorRef)
	return ActorRef && CreatureSlots.AllowedCreature(ActorRef.GetLeveledActorBase().GetRace())
endFunction

int function MaleCount(Actor[] Positions)
	return GenderCount(Positions)[0]
endFunction

int function FemaleCount(Actor[] Positions)
	return GenderCount(Positions)[1]
endFunction

int function CreatureCount(Actor[] Positions)
	int[] Genders = GenderCount(Positions)
	return Genders[2] + Genders[3]
endFunction

int function CreatureMaleCount(Actor[] Positions)
	return GenderCount(Positions)[2]
endFunction

int function CreatureFemaleCount(Actor[] Positions)
	return GenderCount(Positions)[3]
endFunction

string function MakeGenderTag(Actor[] Positions)
	return SexLabUtil.MakeGenderTag(Positions)
endFunction

string function GetGenderTag(int Females = 0, int Males = 0, int Creatures = 0)
	return SexLabUtil.GetGenderTag(Females, Males, Creatures)
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

; A framework shouldnt be "random" and the keyword convention should be established strongly enough to not rely on StorageUtil anymore
; Not deleting contents for the unlikely cause it causes issues
bool function ContinueStrip(Form ItemRef, bool DoStrip = true) global
	int t = sslpp.CheckStrip(ItemRef)
	if t == 1
		return True
	endIf
	return DoStrip && t != -1
endFunction

; Do it yourself?
Form function StripSlot(Actor ActorRef, int SlotMask)
	if !ActorRef
		return none
	endIf
	Form ItemRef = ActorRef.GetWornForm(SlotMask)
	if IsStrippable(ItemRef)
		ActorRef.UnequipItemEX(ItemRef, 0, false)
		return ItemRef
	endIf
	return none
endFunction

Form[] function StripSlots(Actor ActorRef, bool[] Strip, bool DoAnimate = false, bool AllowNudesuit = true)
	If(!ActorRef || Strip.Length < 33)
		return Utility.CreateFormArray(0)
	EndIf
	return StripActorImpl(ActorRef, sslUtility.BoolToBit(Strip), Strip[32], DoAnimate)
EndFunction

function legacy_AddCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
	LogRedundant("legacy_AddCum")
endFunction

bool function IsValidActor(Actor ActorRef)
	return GetIsActorValid(ActorRef)
endFunction

int function ValidateActor(Actor ActorRef)
	If(!ActorRef)
		Log("ValidateActor(NONE) -- FALSE -- Because they don't exist.")
		return -1
	EndIf
	ActorBase BaseRef = ActorRef.GetLeveledActorBase()
	; Primary checks
	if ActorRef.IsInFaction(AnimatingFaction)
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They appear to already be animating")
		return -10
	elseIf !ActorRef.Is3DLoaded()
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are not loaded")
		return -12
	elseIf ActorRef.IsDead() && ActorRef.GetActorValue("Health") < 1.0
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- He's dead Jim.")
		return -13
	elseIf ActorRef.IsDisabled()
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are disabled")
		return -14
	elseIf ActorRef.IsFlying()
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are flying.")
		return -15
	elseIf ActorRef.IsOnMount()
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are currently mounted.")
		return -16
	elseIf ActorRef.IsInFaction(ForbiddenFaction)
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are flagged as forbidden from animating.")
		return -11
	elseIf !CanAnimate(ActorRef)
		ActorRef.AddToFaction(ForbiddenFaction)
		Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are not supported for animation.")
		return -11
	elseIf !ActorRef.HasKeyword(ActorTypeNPC)
		if !Config.AllowCreatures
			Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are possibly a creature but creature animations are currently disabled")
			return -17
		elseIf !sslCreatureAnimationSlots.HasCreatureType(ActorRef)
			Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are a creature type that is currently not supported ("+MiscUtil.GetRaceEditorID(BaseRef.GetRace())+")")
			return -18
		elseIf !CreatureSlots.HasAnimation(BaseRef.GetRace(), GetGender(ActorRef))
			Log("ValidateActor("+BaseRef.GetName()+") -- FALSE -- They are valid creature type, but have no valid animations currently enabled or installed.")
			return -19
		endIf
	endIf
	Log("ValidateActor("+BaseRef.GetName()+") -- TRUE -- MISS")
	return 1
endFunction

bool function CanAnimate(Actor ActorRef) native
