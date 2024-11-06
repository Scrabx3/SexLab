ScriptName sslLovense Hidden

bool Function IsLovenseInstalled() global
  return SKSE.GetPluginVersion("SkyrimLovense") > -1
EndFunction

; ------------------------------------------------------- ;
; --- Start Actions                                   --- ;
; ------------------------------------------------------- ;

Function StartGenitalAction(int aiStrength) global
  String[] analToys = Lovense.GetToysByCategory("Genital")
  StartDefaultActions(analToys, aiStrength)
EndFunction

Function StartAnalAction(int aiStrength) global
  String[] analToys = Lovense.GetToysByCategory("Anal")
  StartDefaultActions(analToys, aiStrength)
EndFunction

Function StartOrgasmAction(int aiStrength, float duration) global
  String[] toys = new String[1]
  StartDefaultActions(toys, aiStrength, duration)
EndFunction

Function StartDefaultActions(String[] toys, int strength, float duration = 0.0) global
  If (strength <= 0)
    return
  EndIf
  int[] argStrength = new int[1]
  argStrength[0] = strength
  String[] argType = new String[1]
  argType[0] = "All"
  int i = 0
  While (i < toys.Length)
    Lovense.FunctionRequest(argType, argStrength, duration, asToy = toys[i])
    i += 1
  EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Stop Actions                                    --- ;
; ------------------------------------------------------- ;

Function StopGenitalAction() global
  String[] analToys = Lovense.GetToysByCategory("Genital")
  StopAction(analToys)
EndFunction

Function StopAnalAction() global
  String[] analToys = Lovense.GetToysByCategory("Anal")
  StopAction(analToys)
EndFunction

Function StopAction(String[] toys) global
  int i = 0
  While (i < toys.Length)
    Lovense.StopRequest(toys[i])
    i += 1
  EndWhile
EndFunction

Function StopAllActions() global
  Lovense.StopRequest()
EndFunction
