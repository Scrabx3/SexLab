ScriptName sslpp Hidden  

String[] Function MergeStringArrayEx(String[] asArray1, String[] asArray2, bool abRemoveDupes) native global
String[] Function RemoveStringEx(String[] asArray, String asRemove) native global

; Offsets is a [akReferences.Lenth] x 4 - matrix, each row containing data in the following order: [x offset, y offset, z offset, z angle offset]
Function SetPositions(Actor[] akReferences, ObjectReference akCenter) native global
Function SetPositionsEx(Actor[] akReferences, ObjectReference akCenter, float[] afOffsets) native global
bool Function MatchTags(String[] asTags, String[] asMatch) native global

Ammo Function GetEquippedAmmo(Actor akActor) native global
Form[] Function StripActor(Actor akActor, int aiSlotMasks) native global

; Insert, update or delete a custom strip setting
Function WriteStrip(Form akExclude, bool abNeverStrip) native global
Function EraseStrip(Form akExclude) native global
Function EraseStripAll() native global
; -1 - Disallow Strip / 0 - No Info / 1 - Always Strip
int Function CheckStrip(Form akForm) native global

Spell Function GetHDTHeelSpell(Actor akActor) native global

String Function GetEditorID(Form akForm) native global

; return an array of bed object refs, sorted by distance from center
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

