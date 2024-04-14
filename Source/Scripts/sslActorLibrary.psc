ScriptName sslActorLibrary extends sslSystemLibrary
{
	Threading/Animation related Actor specific utility
}

; ------------------------------------------------------- ;
; --- Actor Effects Functions                         --- ;
; ------------------------------------------------------- ;
; TODO: overhaul the entire system here and move it into the dll
; NOTE: CumID system is no longer in use !IMPORTANT

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

function ApplyCum(Actor ActorRef, int CumID)
	AddCum(ActorRef, (cumID == 1 || cumID == 4 || cumID == 5 || cumID == 7), (cumID == 2 || cumID == 4 || cumID == 6 || cumID == 7), (cumID == 3 || cumID == 5 || cumID == 6 || cumID == 7))
endFunction

function ClearCum(Actor ActorRef)
	if !ActorRef
		return
	endIf

	int handle = ModEvent.Create("Sexlab_ClearCum")
	if handle
		ModEvent.PushForm(handle, ActorRef)
		ModEvent.Send(handle)
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

	int handle = ModEvent.Create("Sexlab_AddCum")
	if handle
		ModEvent.PushForm(handle, ActorRef)
		ModEvent.PushBool(handle, Vaginal)
		ModEvent.PushBool(handle, Oral)
		ModEvent.PushBool(handle, Anal)
		ModEvent.Send(handle)
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

; ------------------------------------------------------- ;
; --- Equipment Functions                             --- ;
; ------------------------------------------------------- ;

; Flag/Clear an item for special strip behavior
Function WriteStrip(Form akExcludeForm, bool abNeverStrip) native global
Function EraseStrip(Form akExcludeForm) native global
Function EraseStripAll() native global
; -1 - Never Strip, 0 - No Info, 1 - Always Strip
int Function CheckStrip(Form akCheckForm) native global

function MakeNoStrip(Form ItemRef)
	WriteStrip(ItemRef, true)
endFunction
function MakeAlwaysStrip(Form ItemRef)
	WriteStrip(ItemRef, false)
endFunction
function ClearStripOverride(Form ItemRef)
	EraseStrip(ItemRef)
endFunction
function ResetStripOverrides()
	EraseStripAll()
endFunction

bool function IsNoStrip(Form ItemRef)
	return CheckStrip(ItemRef) == -1
endFunction
bool function IsAlwaysStrip(Form ItemRef)
	return CheckStrip(ItemRef) == 1
endFunction
bool function IsStrippable(Form ItemRef)
	return !IsNoStrip(ItemRef)
endFunction

Form[] function StripActor(Actor ActorRef, Actor VictimRef = none, bool DoAnimate = true, bool LeadIn = false)
	int[] strips = sslSystemConfig.GetStripForms(ActorRef == VictimRef || SexLabRegistry.GetSex(ActorRef, false) == 1, VictimRef)
	return StripActorImpl(ActorRef, strips[0], strips[1], DoAnimate)
endFunction
Form[] function StripSlots(Actor ActorRef, bool[] Strip, bool DoAnimate = false, bool AllowNudesuit = true)
	If(!ActorRef || Strip.Length < 33)
		return Utility.CreateFormArray(0)
	EndIf
	return StripActorImpl(ActorRef, sslUtility.BoolToBit(Strip), Strip[32], DoAnimate)
EndFunction
Form Function StripSlot(Actor ActorRef, int SlotMask)
	Form ItemRef = ActorRef.GetWornForm(SlotMask)
	If (ItemRef && IsStrippable(ItemRef))
		ActorRef.UnequipItemEX(ItemRef, 0, false)
		return ItemRef
	EndIf
	return none
EndFunction

Function UnstripActor(Actor ActorRef, Form[] Stripped, bool IsVictim = false)
	If (IsVictim && !Config.RedressVictim)
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

Faction property ForbiddenFaction auto

int Function ValidateActorImpl(Actor akActor) native global
int function ValidateActor(Actor ActorRef)
	return ValidateActorImpl(ActorRef)
EndFunction
bool function IsValidActor(Actor ActorRef)
	return ValidateActor(ActorRef) > 0
endFunction

function ForbidActor(Actor ActorRef)
	ActorRef.AddToFaction(ForbiddenFaction)
endFunction
function AllowActor(Actor ActorRef)
	ActorRef.RemoveFromFaction(ForbiddenFaction)
endFunction
bool function IsForbidden(Actor ActorRef)
	return ActorRef.IsInFaction(ForbiddenFaction)
endFunction

; ------------------------------------------------------- ;
; --- Gender Functions                                --- ;
; ------------------------------------------------------- ;

Faction property GenderFaction auto

int[] Function GetSexAll(Actor[] akPositions) global
	int[] ret = Utility.CreateIntArray(akPositions.Length)
	int i = 0
	While (i < akPositions.Length)
		ret[i] = SexLabRegistry.GetSex(akPositions[i], false)
		i += 1
	EndWhile
	return ret
EndFunction

Function TreatAsSex(Actor akActor, int aiSexTag)
	int baseSex = SexLabRegistry.GetSex(akActor, true)
	If (aiSexTag == baseSex)
		akActor.RemoveFromFaction(GenderFaction)
	Else
		akActor.SetFactionRank(GenderFaction, aiSexTag)
	EndIf
	int handle = ModEvent.Create("SexLabActorGenderChange")
	If (handle)
		ModEvent.PushForm(handle, akActor)
		ModEvent.PushInt(handle, aiSexTag)
		ModEvent.Send(handle)
	EndIf
EndFunction

Function ClearForcedSex(Actor akActor)
	TreatAsSex(akActor, SexLabRegistry.GetSex(akActor, true))
EndFunction

int[] Function CountSexAll(Actor[] akPositions)
	int[] ret = new int[5]
	int i = 0
	While (i < akPositions.Length)
		int sex = SexLabRegistry.GetSex(akPositions[i], false)
		ret[sex] = ret[sex] + 1
		i += 1
	EndWhile
	return ret
EndFunction

int Function CountMale(Actor[] akPositions)
	return CountSexAll(akPositions)[0]
EndFunction
int Function CountFemale(Actor[] akPositions)
	return CountSexAll(akPositions)[1]
EndFunction
int Function CountFuta(Actor[] akPositions)
	return CountSexAll(akPositions)[2]
EndFunction
int Function CountCreatures(Actor[] akPositions)
	int[] count = CountSexAll(akPositions)
	return count[3] + count[4]
EndFunction
int Function CountCrtMale(Actor[] akPositions)
	return CountSexAll(akPositions)[3]
EndFunction
int Function CountCrtFemale(Actor[] akPositions)
	return CountSexAll(akPositions)[4]
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

bool Function HasVehicle(Actor akActor) native global
Form[] Function UnequipSlots(Actor akActor, int aiSlots) native global

Form[] Function StripActorImpl(Actor akActor, int aiSlots, bool abStripWeapons = true, bool abAnimate = false)
	abAnimate = abAnimate && akActor.GetWornForm(0x4)	; Body armor slot
	If(abAnimate)
		int Gender = akActor.GetLeveledActorBase().GetSex()
		Debug.SendAnimationEvent(akActor, "Arrok_Undress_G" + Gender)
		Utility.Wait(0.6)
	EndIf
	Form[] ret = UnequipSlots(akActor, aiSlots)
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

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;               ██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗              ;
;               ██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝              ;
;               ██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝               ;
;               ██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝                ;
;               ███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║                 ;
;               ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝                 ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

Faction property AnimatingFaction auto
Keyword property ActorTypeNPC auto

bool function IsCreature(Actor ActorRef)
	return SexLabRegistry.GetRaceID(ActorRef) > 0
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

Function TreatAsGender(Actor ActorRef, bool AsFemale)
	If (AsFemale)
		TreatAsSex(ActorRef, 1)
	Else
		TreatAsSex(ActorRef, 0)
	EndIf
EndFunction
function ClearForcedGender(Actor ActorRef)	; Replaced to stay consistent with vocabulary
	ClearForcedSex(ActorRef)
endFunction

function TreatAsMale(Actor ActorRef)
	TreatAsGender(ActorRef, false)
endFunction
function TreatAsFemale(Actor ActorRef)
	TreatAsGender(ActorRef, true)
endFunction

int function GetTrans(Actor ActorRef)
	int configSex = SexLabRegistry.GetSex(ActorRef, true)
	If (configSex != 2 && configSex == SexLabRegistry.GetSex(ActorRef, false))
		; configSex == vanillaSex => No overwrite <=> no "trans"
		return -1
	ElseIf (configSex >= 2)
		; Futa+ has its tag shifted 1 up, since this is a legcay function they need to be shifted down once again
		return configSex - 1
	EndIf
	return configSex
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

; A framework shouldnt be "random" and the keyword convention should be established strongly enough to not rely on StorageUtil anymore
bool function ContinueStrip(Form ItemRef, bool DoStrip = true) global
	int t = CheckStrip(ItemRef)
	if t == 1
		return True
	endIf
	return DoStrip && t != -1
endFunction

bool function CanAnimate(Actor ActorRef)
	if !ActorRef
		return false
	endIf
	Race ActorRace  = ActorRef.GetLeveledActorBase().GetRace()
	string RaceName = ActorRace.GetName()+MiscUtil.GetRaceEditorID(ActorRace)
	return !(ActorRace.IsRaceFlagSet(0x00000004) || StringUtil.Find(RaceName, "Moli") != -1 || StringUtil.Find(RaceName, "Child") != -1  || StringUtil.Find(RaceName, "Little") != -1 || StringUtil.Find(RaceName, "117") != -1 || StringUtil.Find(RaceName, "Enfant") != -1 || StringUtil.Find(RaceName, "Teen") != -1 || (StringUtil.Find(RaceName, "Elin") != -1 && ActorRef.GetScale() < 0.92) ||  (StringUtil.Find(RaceName, "Monli") != -1 && ActorRef.GetScale() < 0.92))
endFunction
