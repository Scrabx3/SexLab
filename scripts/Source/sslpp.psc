ScriptName sslpp Hidden  

String[] Function MergeStringArrayEx(String[] asArray1, String[] asArray2, bool abRemoveDupes) global native
String[] Function RemoveStringEx(String[] asArray, String abRemove) global native

Function SetPositions(Actor[] akReferences, ObjectReference akCenter) global native
bool Function MatchTags(String[] asTags, String[] asMatch) global native

Ammo Function GetEquippedAmmo(Actor akActor) global native

;	Scan the area for bed furnitue objects and return all objects found
; --- Params
; akCenterRef: 	The center from which to search
; afRadius:			The maximum distance a bed may be from the given center. Pass 0 to search the entire loaded area
; afRadiusZ:		The maximum height difference between center and bed. Pass 0 to ignore
; --- Return
; An array of bed object refs, sorted by distance from center
ObjectReference[] Function FindBeds(ObjectReference akCenterRef, float afRadius = 4096.0, float afRadiusZ = 512.0) global native

; if the given reference is a bed. This operates on the 3d of the object directly. Does not check if the bed is used
bool Function IsBed(ObjectReference akReference) global native

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

