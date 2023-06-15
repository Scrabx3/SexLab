scriptname sslAnimationFactory extends Quest hidden
{
  LEGACY SCRIPTS. DO NOT USE
  ANIMATIONS ARE HANDLED BY SL NATIVELY USING .SLR FILES
  PAPYRUS REGISTRATION IS NO LONGER SUPPORTED
}

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

sslAnimationSlots property Slots auto hidden

; Gender Types
int property Male = 0 autoreadonly hidden
int property Female = 1 autoreadonly hidden
int property Creature = 2 autoreadonly hidden
int property CreatureMale = 2 autoreadonly hidden
int property CreatureFemale = 3 autoreadonly hidden
; Cum Types
int property Vaginal = 1 autoreadonly hidden
int property Oral = 2 autoreadonly hidden
int property Anal = 3 autoreadonly hidden
int property VaginalOral = 4 autoreadonly hidden
int property VaginalAnal = 5 autoreadonly hidden
int property OralAnal = 6 autoreadonly hidden
int property VaginalOralAnal = 7 autoreadonly hidden
; Content Types
int property Misc = 0 autoreadonly hidden
int property Sexual = 1 autoreadonly hidden
int property Foreplay = 2 autoreadonly hidden
; SFX Types
Sound property Squishing auto hidden
Sound property Sucking auto hidden
Sound property SexMix auto hidden
Sound property Squirting auto hidden
; System Use
bool property IsCreatureFactory auto hidden

; ------------------------------------------------------- ;
; --- Setup                                           --- ;
; ------------------------------------------------------- ;

; Prepare the factory for use with the default animation slots
function PrepareFactory()
endFunction

; Prepare the factory for use with the default creature animation slots
function PrepareFactoryCreatures()
endFunction

Function Initialize()
Endfunction

; ------------------------------------------------------- ;
; --- Registering Animations                          --- ;
; ------------------------------------------------------- ;

; Send callback event to start registration
function RegisterAnimation(string Registrar)
endFunction

; Gets the Animation resource object for use in the callback, MUST be called at start of callback to get the appropiate resource
sslBaseAnimation function Create(int id)
  return none
endFunction

function RegisterOtherCategories()
endFunction

function RegisterCategory(string Category)
endFunction

sslBaseAnimation function RegisterJSON(string Filename)
  return none
endFunction

bool function ValidateJSON(string Filename)
  return false
endFunction

Sound function StringSFX(string sfx)
  return none
endFunction

function FactoryLog(string msg)
  MiscUtil.PrintConsole(msg)
  Debug.Trace("SEXLAB - "+msg)
endFunction
