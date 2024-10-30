ScriptName sslLovense Hidden

bool Function IsLovenseInstalled() global
  return SKSE.GetPluginVersion("SkyrimLovense") > -1
EndFunction

Function StartAnalAction(int aiStrength) global
  String[] analToys = Lovense.GetToysByCategory("Anal")
  StartDefaultActions(analToys, aiStrength)
EndFunction

Function StartGenitalAction(int aiStrength) global
  String[] analToys = Lovense.GetToysByCategory("Genital")
  StartDefaultActions(analToys, aiStrength)
EndFunction

Function StartOrgasmAction(int aiStrength) global
  String[] toys = new String[1]
  StartDefaultActions(toys, aiStrength)
EndFunction

Function StartDefaultActions(String[] toys, int strength) global
  If (strength <= 0)
    return
  EndIf
  int[] argStrength = new int[1]
  String[] argType = new String[1]
  argType[0] = "All"
  argStrength[0] = strength
  int i = 0
  While (i < toys.Length)
    Lovense.FunctionRequest(argType, argStrength, 0.0, asToy = toys[i])
    i += 1
  EndWhile
EndFunction


