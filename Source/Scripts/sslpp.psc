ScriptName sslpp Hidden  

String[] Function MergeStringArrayEx(String[] asArray1, String[] asArray2, bool abRemoveDupes) native global
String[] Function RemoveStringEx(String[] asArray, String asRemove) native global

; Offsets is a [akReferences.Lenth] x 4 - matrix, each row containing data in the following order: [x offset, y offset, z offset, z angle offset]
Function SetPositions(Actor[] akReferences, ObjectReference akCenter) native global
Function LocateReferences(Actor[] akReferences, ObjectReference akCenter, float[] afOffsets) native global
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


