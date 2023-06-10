scriptname sslCreatureAnimationSlots extends sslAnimationSlots
{
	Internal Script expanding sslAnimationSlots with creature exclusive utility
	Interact with this Script through the main api only
}

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

string function GetRaceKey(Race RaceRef) global native
string function GetRaceKeyByID(string RaceID) global native
function AddRaceID(string RaceKey, string RaceID) global native
bool function HasRaceID(string RaceKey, string RaceID) global native
bool function HasRaceKey(string RaceKey) global native
bool function ClearRaceKey(string RaceKey) global native
bool function HasRaceIDType(string RaceID) global native
bool function HasCreatureType(Actor ActorRef) global native
bool function HasRaceType(Race RaceRef) global native
string[] function GetAllRaceKeys(Race RaceRef = none) global native
string[] function GetAllRaceIDs(string RaceKey) global native
Race[] function GetAllRaces(string RaceKey) global native

sslBaseAnimation[] Function _GetAnimations(int[] akPositions, String[] asTags)
	If(!Config.UseCreatureGender)
		sslActorData.NeutralizeCreatureGender(akPositions)
	EndIf
	return Parent._GetAnimations(akPositions, asTags)
EndFunction

; ------------------------------------------------------- ;
; --- Creature aniamtion support                      --- ;
; ------------------------------------------------------- ;

bool function RaceHasAnimation(Race RaceRef, int ActorCount = -1, int Gender = -1)
	string[] RaceTypes = GetAllRaceKeys(RaceRef)
	int i = 0
	While(i < RaceTypes.Length)
		If(RaceKeyHasAnimation(RaceTypes[i], ActorCount, Gender))
			return true
		EndIf
		i += 1
	EndWhile
	return false
endFunction

bool function RaceKeyHasAnimation(string RaceKey, int ActorCount = -1, int Gender = -1)
	If(!HasRaceKey(RaceKey))
		return false
	EndIf
	bool UseGender = Gender != -1 && Config.UseCreatureGender
	int i = Slotted
	while i
		i -= 1
		sslBaseAnimation Slot = GetBySlot(i)
		if Slot && Slot.Enabled && RaceKey == Slot.RaceType && (ActorCount == -1 || ActorCount == Slot.PositionCount) && ((!UseGender || !Slot.GenderedCreatures) || Slot.Genders[Gender] > 0)
			return true
		endIf
	endWhile
	return false
endFunction

bool function HasCreature(Actor ActorRef)
	return sslCreatureAnimationSlots.HasCreatureType(ActorRef)
endFunction

bool function HasRace(Race RaceRef)
	return sslCreatureAnimationSlots.HasRaceType(RaceRef)
endFunction

bool function AllowedCreature(Race RaceRef)
	return Config.AllowCreatures && HasAnimation(RaceRef)
endFunction

; ------------------------------------------------------- ;
; --- Initialization						                      --- ;
; ------------------------------------------------------- ;

function Setup()
	RegisterRaces()
	parent.Setup()
	CacheID = "SexLab.CreatureTags"
endfunction

function RegisterSlots()
	CacheID = "SexLab.CreatureTags"
	if Config.AllowCreatures
		(Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslCreatureAnimationDefaults).LoadCreatureAnimations()
		(Game.GetFormFromFile(0x664FB, "SexLab.esm") as sslVoiceDefaults).LoadCreatureVoices()
		ModEvent.Send(ModEvent.Create("SexLabSlotCreatureAnimations"))
		Debug.Notification("$SSL_NotifyCreatureAnimationInstall")
	else
		Config.Log("Creatures not enabled, skipping registration.", "RegisterSlots() Creature")
	endIf
endFunction

function RegisterRaces()
	;Ashhoppers = Actors\DLC02\Scrib\ScribProject.hkx
		ClearRaceKey("Ashhoppers")
		AddRaceID("Ashhoppers", "DLC2AshHopperRace")

	;Bears = Actors\Bear\BearProject.hkx
		ClearRaceKey("Bears")
		AddRaceID("Bears", "BearBlackRace")
		AddRaceID("Bears", "BearBrownRace")
		AddRaceID("Bears", "BearSnowRace")

	;Boars = Actors\DLC02\BoarRiekling\BoarProject.hkx
		ClearRaceKey("Boars")
		AddRaceID("Boars", "DLC2BoarRace")

	;BoarsAny = Actors\DLC02\BoarRiekling\BoarProject.hkx
		ClearRaceKey("BoarsAny")
		AddRaceID("BoarsAny", "DLC2BoarRace")
		AddRaceID("BoarsAny", "DLC2MountedRieklingRace")

	;BoarsMounted = Actors\DLC02\BoarRiekling\BoarProject.hkx
		ClearRaceKey("BoarsMounted")
		AddRaceID("BoarsMounted", "DLC2MountedRieklingRace")

	;Canines = Actors\Canine\DogProject.hkx AND Actors\Canine\WolfProject.hkx
		ClearRaceKey("Canines")
		AddRaceID("Canines", "DogRace")
		AddRaceID("Canines", "DogCompanionRace")
		AddRaceID("Canines", "MG07DogRace")
		AddRaceID("Canines", "DA03BarbasDogRace")
		AddRaceID("Canines", "DLC1HuskyArmoredCompanionRace")
		AddRaceID("Canines", "DLC1HuskyArmoredRace")
		AddRaceID("Canines", "DLC1HuskyBareCompanionRace")
		AddRaceID("Canines", "DLC1HuskyBareRace")
		AddRaceID("Canines", "WolfRace")
		AddRaceID("Canines", "DLC1DeathHoundCompanionRace")
		AddRaceID("Canines", "DLC1DeathHoundRace")

	;Chaurus = Actors\Chaurus\ChaurusProject.hkx
		ClearRaceKey("Chaurus")
		AddRaceID("Chaurus", "ChaurusRace")
		AddRaceID("Chaurus", "DLC1_BF_ChaurusRace")

	;ChaurusHunters = Actors\DLC01\ChaurusFlyer\ChaurusFlyer.hkx
		ClearRaceKey("ChaurusHunters")
		AddRaceID("ChaurusHunters", "DLC1ChaurusHunterRace")

	;ChaurusReapers = Actors\Chaurus\ChaurusProject.hkx
		ClearRaceKey("ChaurusReapers")
		AddRaceID("ChaurusReapers", "ChaurusReaperRace")

	;Chickens = Actors\Ambient\Chicken\ChickenProject.hkx
		ClearRaceKey("Chickens")
		AddRaceID("Chickens", "ChickenRace")

	;Cows = Actors\Cow\HighlandCowProject.hkx
		ClearRaceKey("Cows")
		AddRaceID("Cows", "CowRace")

	;Deers = Actors\Deer\DeerProject.hkx
		ClearRaceKey("Deers")
		AddRaceID("Deers", "DeerRace")
		AddRaceID("Deers", "ElkRace")
		AddRaceID("Deers", "WhiteStagRace")
		AddRaceID("Deers", "DLC1DeerGlowRace")

	;Dogs = Actors\Canine\DogProject.hkx
		ClearRaceKey("Dogs")
		AddRaceID("Dogs", "DogRace")
		AddRaceID("Dogs", "DogCompanionRace")
		AddRaceID("Dogs", "MG07DogRace")
		AddRaceID("Dogs", "DA03BarbasDogRace")
		AddRaceID("Dogs", "DLC1HuskyArmoredCompanionRace")
		AddRaceID("Dogs", "DLC1HuskyArmoredRace")
		AddRaceID("Dogs", "DLC1HuskyBareCompanionRace")
		AddRaceID("Dogs", "DLC1HuskyBareRace")

	;DragonPriests = Actors\DragonPriest\Dragon_Priest.hkx
		ClearRaceKey("DragonPriests")
		AddRaceID("DragonPriests", "DragonPriestRace")
		AddRaceID("DragonPriests", "SkeletonNecroPriestRace")
		AddRaceID("DragonPriests", "DLC2AcolyteDragonPriestRace")

	;Dragons = Actors\Dragon\DragonProject.hkx
		ClearRaceKey("Dragons")
		AddRaceID("Dragons", "DragonRace")
		AddRaceID("Dragons", "AlduinRace")
		AddRaceID("Dragons", "UndeadDragonRace")
		AddRaceID("Dragons", "DLC1UndeadDragonRace")
		AddRaceID("Dragons", "DragonBlackRace")
		AddRaceID("Dragons", "DLC2DragonBlackRace")

	;Draugrs = Actors\Draugr\DraugrProject.hkx
		ClearRaceKey("Draugrs")
		AddRaceID("Draugrs", "DraugrRace")
		AddRaceID("Draugrs", "DraugrMagicRace")
		AddRaceID("Draugrs", "RigidSkeletonRace")
		AddRaceID("Draugrs", "SkeletonNecroRace")
		AddRaceID("Draugrs", "SkeletonRace")
		AddRaceID("Draugrs", "SkeletonArmorRace")
		AddRaceID("Draugrs", "DLC1SoulCairnKeeperRace")
		AddRaceID("Draugrs", "DLC1SoulCairnSkeletonArmorRace")
		AddRaceID("Draugrs", "DLC1BlackSkeletonRace")
		AddRaceID("Draugrs", "DLC1SoulCairnSkeletonNecroRace")
		AddRaceID("Draugrs", "DLC2HulkingDraugrRace")
		AddRaceID("Draugrs", "DLC2AshSpawnRace")
		AddRaceID("Draugrs", "DLC2RigidSkeletonRace")

	;DwarvenBallistas = Actors\DLC02\DwarvenBallistaCenturion\BallistaCenturion.hkx
		ClearRaceKey("DwarvenBallistas")
		AddRaceID("DwarvenBallistas", "DLC2DwarvenBallistaRace")

	;DwarvenCenturions = Actors\DwarvenSteamCenturion\SteamProject.hkx
		ClearRaceKey("DwarvenCenturions")
		AddRaceID("DwarvenCenturions", "DwarvenCenturionRace")
		AddRaceID("DwarvenCenturions", "DLC1LD_ForgemasterRace")

	;DwarvenSpheres = Actors\DwarvenSphereCenturion\SphereCenturion.hkx
		ClearRaceKey("DwarvenSpheres")
		AddRaceID("DwarvenSpheres", "DwarvenSphereRace")

	;DwarvenSpiders = Actors\DwarvenSpider\DwarvenSpiderCenturionProject.hkx
		ClearRaceKey("DwarvenSpiders")
		AddRaceID("DwarvenSpiders", "DwarvenSpiderRace")

	;Falmers = Actors\Falmer\FalmerProject.hkx
		ClearRaceKey("Falmers")
		AddRaceID("Falmers", "FalmerRace")
		AddRaceID("Falmers", "DLC1SkinVampireFalmer")
		AddRaceID("Falmers", "FalmerFrozenVampRace")

	;FlameAtronach = Actors\AtronachFlame\AtronachFlame.hkx
		ClearRaceKey("FlameAtronach")
		AddRaceID("FlameAtronach", "AtronachFlameRace")

	;Foxes = Actors\Canine\WolfProject.hkx
		ClearRaceKey("Foxes")
		AddRaceID("Foxes", "FoxRace")

	;FrostAtronach = Actors\AtronachFrost\AtronachFrostProject.hkx
		ClearRaceKey("FrostAtronach")
		AddRaceID("FrostAtronach", "AtronachFrostRace")

	;Gargoyles = Actors\DLC01\VampireBrute\VampireBruteProject.hkx
		ClearRaceKey("Gargoyles")
		AddRaceID("Gargoyles", "DLC1GargoyleRace")
		AddRaceID("Gargoyles", "DLC1GargoyleVariantBossRace")
		AddRaceID("Gargoyles", "DLC1GargoyleVariantGreenRace")

	;Giants = Actors\Giant\GiantProject.hkx
		ClearRaceKey("Giants")
		AddRaceID("Giants", "GiantRace")
		AddRaceID("Giants", "DLC2GhostFrostGiantRace")

	;Goats = Actors\Goat\GoatProject.hkx
		ClearRaceKey("Goats")
		AddRaceID("Goats", "GoatDomesticRace")
		AddRaceID("Goats", "GoatRace")

	;Hagravens = Actors\Hagraven\HagravenProject.hkx
		ClearRaceKey("Hagravens")
		AddRaceID("Hagravens", "HagravenRace")

	;Horkers = Actors\Horker\HorkerProject.hkx
		ClearRaceKey("Horkers")
		AddRaceID("Horkers", "HorkerRace")

	;Horses = Actors\Horse\HorseProject.hkx
		ClearRaceKey("Horses")
		AddRaceID("Horses", "HorseRace")

	;IceWraiths = Actors\IceWraith\IceWraithProject.hkx
		ClearRaceKey("IceWraiths")
		AddRaceID("IceWraiths", "IceWraithRace")
		AddRaceID("IceWraiths", "dlc2SpectralDragonRace")

	;Lurkers = Actors\DLC02\BenthicLurker\BenthicLurkerProject.hkx
		ClearRaceKey("Lurkers")
		AddRaceID("Lurkers", "DLC2LurkerRace")

	;Mammoths = Actors\Mammoth\MammothProject.hkx
		ClearRaceKey("Mammoths")
		AddRaceID("Mammoths", "MammothRace")

	;Mudcrabs = Actors\Mudcrab\MudcrabProject.hkx
		ClearRaceKey("Mudcrabs")
		AddRaceID("Mudcrabs", "MudcrabRace")
		AddRaceID("Mudcrabs", "DLC2MudcrabSolstheimRace")

	;Netches = Actors\DLC02\Netch\NetchProject.hkx
		ClearRaceKey("Netches")
		AddRaceID("Netches", "DLC2NetchRace")

	;Rabbits = Actors\Ambient\Hare\HareProject.hkx
		ClearRaceKey("Rabbits")
		AddRaceID("Rabbits", "HareRace")

	;Rieklings = Actors\DLC02\Riekling\RieklingProject.hkx
		ClearRaceKey("Rieklings")
		AddRaceID("Rieklings", "DLC2RieklingRace")
		AddRaceID("Rieklings", "DLC2ThirskRieklingRace")

	;SabreCats = Actors\SabreCat\SabreCatProject.hkx
		ClearRaceKey("SabreCats")
		AddRaceID("SabreCats", "SabreCatRace")
		AddRaceID("SabreCats", "SabreCatSnowyRace")
		AddRaceID("SabreCats", "DLC1SabreCatGlowRace")

	;Seekers = Actors\DLC02\HMDaedra\HMDaedra.hkx
		ClearRaceKey("Seekers")
		AddRaceID("Seekers", "DLC2SeekerRace")

	;Skeevers = Actors\Skeever\SkeeverProject.hkx
		ClearRaceKey("Skeevers")
		AddRaceID("Skeevers", "SkeeverRace")
		AddRaceID("skeevers", "SkeeverWhiteRace")

	;Slaughterfishes = Actors\Slaughterfish\SlaughterfishProject.hkx
		ClearRaceKey("Slaughterfishes")
		AddRaceID("Slaughterfishes", "SlaughterfishRace")

	;StormAtronach = Actors\AtronachStorm\AtronachStormProject.hkx
		ClearRaceKey("StormAtronach")
		AddRaceID("StormAtronach", "AtronachStormRace")
		AddRaceID("StormAtronach", "dlc2AshGuardianRace")

	;Spiders = Actors\FrostbiteSpider\FrostbiteSpiderProject.hkx
		ClearRaceKey("Spiders")
		AddRaceID("Spiders", "FrostbiteSpiderRace")
		AddRaceID("Spiders", "DLC2ExpSpiderBaseRace")
		AddRaceID("Spiders", "DLC2ExpSpiderPackmuleRace")

	;LargeSpiders = Actors\FrostbiteSpider\FrostbiteSpiderProject.hkx
		ClearRaceKey("LargeSpiders")
		AddRaceID("LargeSpiders", "FrostbiteSpiderRaceLarge")

	;GiantSpiders = Actors\FrostbiteSpider\FrostbiteSpiderProject.hkx
		ClearRaceKey("GiantSpiders")
		AddRaceID("GiantSpiders", "FrostbiteSpiderRaceGiant")

	;Spriggans = Actors\Spriggan\Spriggan.hkx
		ClearRaceKey("Spriggans")
		AddRaceID("Spriggans", "SprigganRace")
		AddRaceID("Spriggans", "SprigganMatronRace")
		AddRaceID("Spriggans", "SprigganEarthMotherRace")
		AddRaceID("Spriggans", "DLC2SprigganBurntRace")

	;Trolls = Actors\Troll\TrollProject.hkx
		ClearRaceKey("Trolls")
		AddRaceID("Trolls", "TrollRace")
		AddRaceID("Trolls", "TrollFrostRace")
		AddRaceID("Trolls", "DLC1TrollFrostRaceArmored")
		AddRaceID("Trolls", "DLC1TrollRaceArmored")

	;VampireLords = Actors\VampireLord\VampireLord.hkx
		ClearRaceKey("VampireLords")
		AddRaceID("VampireLords", "DLC1VampireBeastRace")

	;Werewolves = Actors\WerewolfBeast\WerewolfBeastProject.hkx
		ClearRaceKey("Werewolves")
		AddRaceID("Werewolves", "WerewolfBeastRace")
		AddRaceID("Werewolves", "DLC2WerebearBeastRace")

	;WispMothers = Actors\Wisp\WispProject.hkx
		ClearRaceKey("WispMothers")
		AddRaceID("WispMothers", "WispRace")
		AddRaceID("WispMothers", "WispShadeRace")

	;Wisps = Actors\Witchlight\WitchlightProject.hkx
		ClearRaceKey("Wisps")
		AddRaceID("Wisps", "WitchlightRace")
		AddRaceID("Wisps", "DLC1SoulCairnSoulWispRace")
		AddRaceID("Wisps", "DLC2dunInstrumentsRace")

	;Wolves = Actors\Canine\WolfProject.hkx
		ClearRaceKey("Wolves")
		AddRaceID("Wolves", "WolfRace")
		AddRaceID("Wolves", "DLC1DeathHoundCompanionRace")
		AddRaceID("Wolves", "DLC1DeathHoundRace")

	; Send creature race key registration event
	ModEvent.Send(ModEvent.Create("SexLabRegisterCreatureKey"))
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

bool function HasAnimation(Race RaceRef, int Gender = -1)
	return RaceHasAnimation(RaceRef, -1, Gender)
endFunction

sslBaseAnimation[] function GetByRace(int ActorCount, Race RaceRef)
	return GetByRaceTags(ActorCount, RaceRef, "")
endFunction

sslBaseAnimation[] function GetByRaceTags(int ActorCount, Race RaceRef, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("GetByRaceTags(ActorCount="+ActorCount+", RaceRef="+RaceRef+", Tags="+Tags+", TagsSuppressed="+TagsSuppressed+", RequireAll="+RequireAll+")")
	string[] RaceTypes = GetAllRaceKeys(RaceRef)
	if RaceTypes.Length < 1
		return sslUtility.AnimationArray(0)
	endIf
	String[] t = BuildArgTags(PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags)), PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed)), RequireAll)
	sslBaseAnimation[] ret = new sslBaseAnimation[128]
	int i = 0
	int ii = 0
	While(i < Slotted)
		sslBaseAnimation slot = GetBySlot(i)
		If(slot && slot.Enabled && ActorCount == Slot.PositionCount && RaceTypes.Find(Slot.RaceType) != -1 && slot.MatchTags(t))
			ret[ii] = slot
			If(ii == 127)
				Log("GetByRace returned 128 Animations")
				return ret
			EndIf
		EndIf
		i += 1
	EndWhile
	sslBaseAnimation[] _ret = sslUtility.AnimationArray(ii)
	int j = 0
	While(j < ii)
		_ret[j] = ret[j]
		j += 1
	EndWhile
	Log("_GetAnimations returned " + _ret.Length + " animations")
	return _ret
endFunction

sslBaseAnimation[] function GetByRaceKey(int ActorCount, string RaceKey)
	return GetByRaceKeyTags(ActorCount, RaceKey, "")
endFunction

sslBaseAnimation[] function GetByRaceKeyTags(int ActorCount, string RaceKey, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("GetByRaceKeyTags(ActorCount="+ActorCount+", RaceKey="+RaceKey+", Tags="+Tags+", TagsSuppressed="+TagsSuppressed+", RequireAll="+RequireAll+")")
	if !HasRaceKey(RaceKey)
		return sslUtility.AnimationArray(0)
	endIf
	String[] t = BuildArgTags(PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags)), PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed)), RequireAll)
	sslBaseAnimation[] ret = new sslBaseAnimation[128]
	int i = 0
	int ii = 0
	While(i < Slotted)
		sslBaseAnimation slot = GetBySlot(i)
		If(slot && slot.Enabled && ActorCount == Slot.PositionCount && Slot.RaceType == RaceKey && slot.MatchTags(t))
			ret[ii] = slot
			If(ii == 127)
				Log("GetByRace returned 128 Animations")
				return ret
			EndIf
		EndIf
		i += 1
	EndWhile
	sslBaseAnimation[] _ret = sslUtility.AnimationArray(ii)
	int j = 0
	While(j < ii)
		_ret[j] = ret[j]
		j += 1
	EndWhile
	Log("_GetAnimations returned " + _ret.Length + " animations")
	return _ret
endFunction

sslBaseAnimation[] function GetByCreatureActors(int ActorCount, Actor[] Positions)
	return GetByCreatureActorsTags(ActorCount, Positions, "")
endFunction

sslBaseAnimation[] function GetByCreatureActorsTags(int ActorCount, Actor[] Positions, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("GetByCreatureActorsTags(ActorCount="+ActorCount+", Positions="+Positions+", Tags="+Tags+", TagsSuppressed="+TagsSuppressed+", RequireAll="+RequireAll+")")
	if !Positions.Length || Positions.Length > ActorCount
		return sslUtility.AnimationArray(0)
	endIf
	int[] keys = Utility.CreateIntArray(ActorCount, 0)
	int[] data = sslActorData.BuildDataKeyArray(Positions)
	If(!Config.UseCreatureGender)
		sslActorData.NeutralizeCreatureGender(data)
	EndIf
	int i = keys.Length
	int ii = data.Length
	While(ii > 0)
		; We assume that the actors not listed in Positions are humans..
		i -= 1
		If(ii > 0)
			ii -= 1
			keys[i] = data[ii]
		Else
			keys[i] = sslActorData.BuildByLegacyGender(-1)
		EndIf
	EndWhile
	String[] t = BuildArgTags(PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags)), PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed)), RequireAll)
	return _GetAnimations(keys, t)
endFunction

sslBaseAnimation[] function GetByRaceGenders(int ActorCount, Race RaceRef, int MaleCreatures = 0, int FemaleCreatures = 0, bool ForceUse = false)
	return GetByRaceGendersTags(ActorCount, RaceRef, MaleCreatures, FemaleCreatures, "")
endFunction

; NOTE: only loosely reviewed
sslBaseAnimation[] function GetByRaceGendersTags(int ActorCount, Race RaceRef, int MaleCreatures = 0, int FemaleCreatures = 0, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("GetByRaceGenders(ActorCount="+ActorCount+", RaceRef="+RaceRef+", MaleCreatures="+MaleCreatures+", FemaleCreatures="+FemaleCreatures+", Tags="+Tags+", TagsSuppressed="+TagsSuppressed+", RequireAll="+RequireAll+")")
	if !Config.UseCreatureGender && ActorCount <= 2 && (MaleCreatures + FemaleCreatures) < 2
		return GetByRaceTags(ActorCount, RaceRef, Tags, TagsSuppressed, RequireAll)
	endIf
	string[] RaceTypes = GetAllRaceKeys(RaceRef)
	if RaceTypes.Length < 1
		return sslUtility.AnimationArray(0)
	endIf
	String[] Suppress = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed))
	String[] Search = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
	String[] t = BuildArgTags(Search, Suppress, RequireAll)

	sslBaseAnimation[] Output
	bool[] Valid  = Utility.CreateBoolArray(Slotted)
	int i = Slotted
	while i
		i -= 1
		sslBaseAnimation Slot = GetBySlot(i)
		Valid[i] = Slot && Slot.Enabled && RaceTypes.Find(Slot.RaceType) != -1 && ActorCount == Slot.PositionCount && Slot.MatchTags(t)
		if Valid[i]
			if Config.UseCreatureGender && Slot.GenderedCreatures
				Valid[i] = MaleCreatures == Slot.MaleCreatures && FemaleCreatures == Slot.FemaleCreatures
			else
				Valid[i] = (MaleCreatures + FemaleCreatures) == Slot.Creatures
			endIf
		endIf
	endWhile
	Output = GetList(Valid)
	return Output
endFunction

; No longer used
sslBaseAnimation[] function FilterCreatureGenders(sslBaseAnimation[] Anims, int MaleCreatures = 0, int FemaleCreatures = 0)
	if !Config.UseCreatureGender || !Anims.Length
		return Anims
	endIf
	int Del
	int i = Anims.Length
	while i
		i -= 1
		if Anims[i] && Anims[i].GenderedCreatures && (MaleCreatures != Anims[i].MaleCreatures || FemaleCreatures != Anims[i].FemaleCreatures)
			Anims[i] = none
			Del += 1
		endIf
	endWhile
	if Del == 0
		return Anims
	endIf
	i = Anims.Length
	int n = (i - Del)
	sslBaseAnimation[] Output = sslUtility.AnimationArray(n)
	while i && n
		i -= 1
		if Anims[i] != none
			n -= 1
			Output[n] = Anims[i]
		endIf
	endWhile
	return Output
endFunction

; These dont support multi race animations
bool Function AllowedCreatureCombination(Race RaceRef1, Race RaceRef2)
	If(!Config.AllowCreatures || !RaceRef1 || !RaceRef2)
		return false
	ElseIf(RaceRef1 == RaceRef2)
		return true
	EndIf
	return AllowedRaceKeyCombination(GetAllRaceKeys(RaceRef1), GetAllRaceKeys(RaceRef2))
EndFunction
bool function AllowedRaceKeyCombination(string[] Keys1, string[] Keys2)
	If(!Config.AllowCreatures || !Keys1.Length || !Keys2.Length)
		return false
	EndIf
	int i = 0
	While(i < Keys1.Length)
		If(Keys2.Find(Keys1[i]) > -1)
			return true
		EndIf
		i += 1
	EndWhile
	return false
EndFunction