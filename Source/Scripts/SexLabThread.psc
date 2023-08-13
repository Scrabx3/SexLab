ScriptName SexLabThread extends Quest
{
  API Script to directly interact with SexLab Threads
}

; The thread ID of the current thread
; These are unique and can be used to reference this specific thread throughout other parts of the framework
int Function GetThreadID()
EndFunction

; Get all submissives for the current animation
Actor[] Function GetSubmissives()
EndFunction

; If the current animation is assumed to be consent
bool Function IsConsent()
EndFunction
