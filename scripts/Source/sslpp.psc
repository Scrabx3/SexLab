ScriptName sslpp Hidden  

String[] Function MergeStringArrayEx(String[] asArray1, String[] asArray2, bool abRemoveDupes) native global
String[] Function RemoveStringEx(String[] asArray, String abRemove) native global

Function SetPositions(Actor[] akReferences, ObjectReference akCenter) native global
bool Function MatchTags(String[] asTags, String[] asMatch) native global

Ammo Function GetEquippedAmmo(Actor akActor) native global
Form[] Function StripActor(Actor akActor, int aiSlotMasks) native global

Spell Function GetHDTHeelSpell(Actor akActor) native global

String Function GetEditorID(Form akForm) native global

;	Scan the area for bed furnitue objects and return all objects found
; --- Params
; akCenterRef: 	The center from which to search
; afRadius:			The maximum distance a bed may be from the given center. Pass 0 to search the entire loaded area
; afRadiusZ:		The maximum height difference between center and bed. Pass 0 to ignore
; --- Return
; An array of bed object refs, sorted by distance from center
ObjectReference[] Function FindBeds(ObjectReference akCenterRef, float afRadius = 4096.0, float afRadiusZ = 512.0) native global

; if the given reference is a bed. This operates on the 3d of the object directly. Does not check if the bed is used
bool Function IsBed(ObjectReference akReference) native global

ObjectReference Function GetNearestUnusedBed(ObjectReference akCenterRef, float afRadius) global
	ObjectReference[] beds = FindBeds(akCenterRef, afRadius)
	int i = 0
	While(i < beds.Length)
		If(!beds[i].IsFurnitureInUse())
			return beds[i]
		EndIf
		i += 1
	EndWhile
	return none
EndFunction

