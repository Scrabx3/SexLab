scriptname sslThreadLibrary extends sslSystemLibrary
{
	Generic Utility to simplify thread building
	ONLY call these functions through the main API
}

Keyword property FurnitureBedRoll Auto

; ------------------------------------------------------- ;
; --- Bed Utility			                                --- ;
; ------------------------------------------------------- ;

; 0 - No bed / 1 - Bedroll / 2 - Single Bed / 3 - Double Bed
int Function GetBedType(ObjectReference BedRef)
	If(!BedRef || !sslpp.IsBed(BedRef))
		return 0
	EndIf
	Form BaseRef = BedRef.GetBaseObject()
	If(BedRef.HasKeyword(FurnitureBedRoll))
		return 1
	ElseIf(StringUtil.Find(sslpp.GetEditorID(BaseRef), "Double") > -1 || StringUtil.Find(sslpp.GetEditorID(BaseRef), "Single") == -1)
		return 3
	EndIf
	return 2
EndFunction

bool Function IsBedAvailable(ObjectReference BedRef)
	If(!BedRef || BedRef.IsFurnitureInUse(true))
		return false
	EndIf
	int i = 0
	While(i < ThreadSlots.Threads.Length)
		If(ThreadSlots.Threads[i].BedRef == BedRef)
			return false
		EndIf
		i += 1
	Endwhile
	return true
EndFunction

ObjectReference Function FindBed(ObjectReference CenterRef, float Radius = 1000.0, bool IgnoreUsed = true, ObjectReference IgnoreRef1 = none, ObjectReference IgnoreRef2 = none)
	If(!CenterRef || Radius < 1.0)
		return none
	EndIf
	ObjectReference[] beds = sslpp.FindBeds(CenterRef, Radius)
	int i = 0
	While(i < beds.Length)
		If(beds[i] != IgnoreRef1 && beds[i] != IgnoreRef2 && (IgnoreUsed || !beds[i].IsFurnitureInUse()))
			return beds[i]
		EndIf
		i += 1
	EndWhile
	return none
endFunction

; ------------------------------------------------------- ;
; --- Position Sorting                                --- ;
; ------------------------------------------------------- ;

; NOTE: Order of actors in SL scenes is unspecified
; While this function will sort your array with strict ordering, it is highly unlikely that this ordering will
; be identical to the ordering used by SL to play its scene
; Hence there is no performance benefit to calling this function for non-personal reasons
Actor[] Function SortActors(Actor[] Positions, bool FemaleFirst = true)
	Log("Sort Actors | Original Array = " + Positions)
	int[] genders = ActorLib.GetGendersAll(Positions)
	int i = 1
	While(i < Positions.Length)
		Actor it = Positions[i]
		int _it = genders[i]
		int n = i - 1
		While(n >= 0 && !IsLesserGender(genders[n], _it, FemaleFirst))
			Positions[n + 1] = Positions[n]
			genders[n + 1] = genders[n]
			n -= 1
		EndWhile
		Positions[n + 1] = it
		genders[n + 1] = _it
		i += 1
	EndWhile
	Log("Sort Actors | Sorted Array = " + Positions)
	return Positions
EndFunction
bool Function IsLesserGender(int i, int n, bool abFemaleFirst)
	return n != i && (i == (abFemaleFirst as int) || i == 3 && n == 2 || i < n)
EndFunction

Function SortActorsByAnimationImpl(String asSceneID, Actor[] akPositions) native
Actor[] function SortActorsByAnimation(actor[] Positions, sslBaseAnimation Animation = none)
	If (!Animation || !Animation.PROXY_ID)
		return SortActors(Positions)
	EndIf
	SortActorsByAnimationImpl(Animation.PROXY_ID, Positions)
	return Positions
endFunction

; ------------------------------------------------------- ;
; --- Cell Searching                              		--- ;
; ------------------------------------------------------- ;

Actor[] function FindAvailableActors(ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, string RaceKey = "") native
Actor function FindAvailableActor(ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, string RaceKey = "") native
Actor function FindAvailableActorInFaction(Faction FactionRef, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool HasFaction = True, string RaceKey = "", bool JustSameFloor = False) native
Actor function FindAvailableActorWornForm(int slotMask, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool AvoidNoStripKeyword = True, bool HasWornForm = True, string RaceKey = "", bool JustSameFloor = False) native

Actor[] function FindAvailablePartners(actor[] Positions, int total, int males = -1, int females = -1, float radius = 10000.0) native
Actor[] function FindAnimationPartnersImpl(String asAnimID, ObjectReference akCenterRef, float afRadius, Actor[] akIncludes) native
Actor[] function FindAnimationPartners(sslBaseAnimation Animation, ObjectReference CenterRef, float Radius = 5000.0, Actor IncludedRef1 = none, Actor IncludedRef2 = none, Actor IncludedRef3 = none, Actor IncludedRef4 = none)
	Actor[] includes = new Actor[4]
	includes[0] = IncludedRef1
	includes[1] = IncludedRef2
	includes[2] = IncludedRef3
	includes[3] = IncludedRef4
	return FindAnimationPartnersImpl(Animation.PROXY_ID, CenterRef, Radius, PapyrusUtil.RemoveActor(includes, none))
endFunction

; ------------------------------------------------------- ;
; --- Actor Tracking                                  --- ;
; ------------------------------------------------------- ;

function TrackActor(Actor ActorRef, string Callback)
	StorageUtil.FormListAdd(Config, "TrackedActors", ActorRef, false)
	StorageUtil.StringListAdd(ActorRef, "SexLabEvents", Callback, false)
endFunction

function TrackFaction(Faction FactionRef, string Callback)
	If(FactionRef)
		StorageUtil.FormListAdd(Config, "TrackedFactions", FactionRef, false)
		StorageUtil.StringListAdd(FactionRef, "SexLabEvents", Callback, false)
	EndIf
endFunction

function UntrackActor(Actor ActorRef, string Callback)
	StorageUtil.StringListRemove(ActorRef, "SexLabEvents", Callback, true)
	if StorageUtil.StringListCount(ActorRef, "SexLabEvents") < 1
		StorageUtil.FormListRemove(Config, "TrackedActors", ActorRef, true)
	endif
endFunction

function UntrackFaction(Faction FactionRef, string Callback)
	StorageUtil.StringListRemove(FactionRef, "SexLabEvents", Callback, true)
	if StorageUtil.StringListCount(FactionRef, "SexLabEvents") < 1
		StorageUtil.FormListRemove(Config, "TrackedFactions", FactionRef, true)
	endif
endFunction

bool function IsActorTracked(Actor ActorRef)
	if ActorRef == PlayerRef || StorageUtil.StringListCount(ActorRef, "SexLabEvents") > 0
		return true
	endIf
	Form[] f = StorageUtil.FormListToArray(Config, "TrackedFactions")
	int i = 0
	While(i < f.Length)
		If(ActorRef.IsInFaction(f[i] as Faction))
			return true
		EndIf
		i += 1
	EndWhile
	return false
endFunction

function SendTrackedEvent(Actor ActorRef, string Hook = "", int id = -1)
	If(Hook)
		Hook = "_" + Hook
	EndIf
	If(ActorRef == PlayerRef)
		SetupActorEvent(PlayerRef, "PlayerTrack" + Hook, id)
	EndIf
	String[] genericcallbacks = StorageUtil.StringListToArray(ActorRef, "SexLabEvents")
	int i = 0
	While(i < genericcallbacks.Length)
		SetupActorEvent(PlayerRef, genericcallbacks[i] + Hook, id)
		i += 1
	EndWhile
	Form[] factioncallbacks = StorageUtil.FormListToArray(Config, "TrackedFactions")
	int n = 0
	While(n < factioncallbacks.Length)
		If(ActorRef.IsInFaction(factioncallbacks[n] as Faction))
			String[] factionevents = StorageUtil.StringListToArray(factioncallbacks[n], "SexLabEvents")
			int k = 0
			While(k < factionevents.Length)
				SetupActorEvent(PlayerRef, factionevents[k] + Hook, id)
				k += 1
			EndWhile
		EndIf
		n += 1
	EndWhile
EndFunction

function SetupActorEvent(Actor ActorRef, string Callback, int id = -1)
	int eid = ModEvent.Create(Callback)
	ModEvent.PushForm(eid, ActorRef)
	ModEvent.PushInt(eid, id)
	ModEvent.Send(eid)
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

FormList property BedsList Auto
FormList property DoubleBedsList Auto
FormList property BedRollsList Auto

bool Function IsBedRoll(ObjectReference BedRef)
	return GetBedType(BedRef) == 1
EndFunction

bool function IsDoubleBed(ObjectReference BedRef)
	return GetBedType(BedRef) == 3
endFunction

bool function IsSingleBed(ObjectReference BedRef)
	return GetBedType(BedRef) == 2
endFunction

bool function SameFloor(ObjectReference BedRef, float Z, float Tolerance = 15.0)
	return BedRef && Math.Abs(Z - BedRef.GetPositionZ()) <= Tolerance
endFunction

bool function CheckActor(Actor CheckRef, int CheckGender = -1)
	if !CheckRef
		return false
	endIf
	int IsGender = ActorLib.GetGender(CheckRef)
	return ((CheckGender < 2 && IsGender < 2) || (CheckGender >= 2 && IsGender >= 2)) && (CheckGender == -1 || IsGender == CheckGender) && ActorLib.IsValidActor(CheckRef)
endFunction

int function FindNext(Actor[] Positions, sslBaseAnimation Animation, int offset, bool FindCreature)
	while offset
		offset -= 1
		if Animation.HasRace(Positions[offset].GetLeveledActorBase().GetRace()) == FindCreature
			return offset
		endIf
	endwhile
	return -1
endFunction
bool function CheckBed(ObjectReference BedRef, bool IgnoreUsed = true)
	return BedRef && BedRef.IsEnabled() && BedRef.Is3DLoaded() && (!IgnoreUsed || (IgnoreUsed && IsBedAvailable(BedRef)))
endFunction
bool function LeveledAngle(ObjectReference ObjectRef, float Tolerance = 5.0)
	return ObjectRef && Math.Abs(ObjectRef.GetAngleX()) <= Tolerance && Math.Abs(ObjectRef.GetAngleY()) <= Tolerance
endFunction

Actor[] function SortCreatures(actor[] Positions, sslBaseAnimation Animation = none)
	return SortActorsByAnimation(Positions, Animation)
endFunction
