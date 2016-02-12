--[[

Script by spyk for Kalista.

=> BaguetteKalista.lua

- Github link : https://github.com/spyk1/BoL/blob/master/BaguetteKalista/BaguetteKalista.lua

- Forum Thread : http://forum.botoflegends.com/

]]--

local charNames = {
    
    ['Kalista'] = true,
    ['kalista'] = true
}

if not charNames[myHero.charName] then return end

function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteKalista]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end

-- Evadeee 
-- local Evadeee = 0
-- Immune check
local buffs = {
    ["JudicatorIntervention"] = true,
    ["UndyingRage"] = true,
    ["ZacRebirthReady"] = true,
    ["AatroxPassiveDeath"] = true,
    ["FerociousHowl"] = true,
    ["VladimirSanguinePool"] = true,
    ["ChronoRevive"] = true,
    ["ChronoShift"] = true,
    ["KarthusDeathDefiedBuff"] = true,
    ["zhonyasringshield"] = true,
    ["lissandrarself"] = true,
    ["Kindredrnodeathbuff"] = true
}
-- E
local unitStacks = {}
local LastBlitz = 999999999
-- Jgl security
local LastMSG = 0
local Dragons = 0
-- Pred dmgs
local dmgQ = 60 * myHero:GetSpellData(_Q).level + 10 + myHero.totalDamage
local dmgE = 15 * myHero:GetSpellData(_E).level + 5 + .6 * myHero.totalDamage
-- Potions
local lastPotion = 0
local ActualPotTime = 15
local ActualPotName = "None"
local ActualPotData = "None"
-- Qss
local lastRemove = 0
-- Kite
local AAON = 0
-- Skin Changer
local LetterChampion = {"Kalista", "Karma", "Karthus", "Kassadin", "Katarina", "Kayle", "Kennen", "Khazix", "Kindred", "KogMaw"}
local HeroSkin = "Kalista"
local skinsPB = {};
local skinObjectPos = nil;
local skinHeader = nil;
local dispellHeader = nil;
local skinH = nil;
local skinHPos = nil;
local theMenu = nil;
local lastTimeTickCalled = 0;
local lastSkin = 0;
--- Starting AutoUpdate
local version = "0.01"
local author = "spyk"
local SCRIPT_NAME = "BaguetteKalista"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteKalista/BaguetteKalista.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local whatsnew = 0

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteKalista/BaguetteKalista.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				EnvoiMessage("New version available "..ServerVersion)
				EnvoiMessage(">>Updating, please don't press F9<<")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () EnvoiMessage("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
				whatsnew = 1
			else
				DelayAction(function() EnvoiMessage("Hello, "..GetUser()..". You got the latest version! :) ("..ServerVersion..")") end, 3)
			end
		end
		else
			EnvoiMessage("Error downloading version info")
	end
end
 --- End Of AutoUpdate

function OnLoad()
 	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteKalista]</b></font> <font color=\"#ffffff\">by spyk</font>")

	if whatsnew == 1 then
		EnvoiMessage("What's new : Release.")
		whatsnew = 0
	end

 	-------------------MENU|PARAMETRES--------------------------
	Param = scriptConfig("[Baguette] Kalista", "BaguetteKalista")
	-------------------COMBO|OPTION-----------------------------
	Param:addSubMenu("Combo Settings", "Combo")
		Param.Combo:addParam("Q", "Use (Q) Spell in Combo :", SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("E", "Use (E) Spell in Combo :", SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("Kite", "Kite on minion if the target is outrange :", SCRIPT_PARAM_ONOFF, true)
		-- Bush Revealer - http://forum.botoflegends.com/topic/53449-hi-i-dont-understand-item-slot-please-help/?hl=%2Bbush+%2Brevealer
	-------------------HARASS|OPTION----------------------------
	Param:addSubMenu("Harass Settings", "Harass")
		Param.Harass:addParam("Q", "Use (Q) Spell in Harass :", SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addParam("E", "Use (E) Spell in Harass :", SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addSubMenu("(E) Spell Settings", "E")
			Param.Harass.E:addParam("Auto", "Enable Auto (E) Harass :", SCRIPT_PARAM_ONOFF, true)
			Param.Harass.E:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("n1blank", "Set a value for how many minions", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("Minions", "have to be killed :", SCRIPT_PARAM_SLICE, 1, 0, 6)
			Param.Harass.E:addParam("n2blank", "", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("n3blank", "Set a value for how many (E) Stacks", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("AAHero", "have to be on Hero :", SCRIPT_PARAM_SLICE, 1, 0, 10)
			Param.Harass.E:addParam("n4blank", "", SCRIPT_PARAM_INFO, "")
			Param.Harass.E:addParam("Mana", "Set a value for the Mana (%)", SCRIPT_PARAM_SLICE, 50, 0, 100)
	------------------------------------------------------------
	Param:addSubMenu("", "n1")
	------------------------------------------------------------

	-------------------KILLSTEAL|OPTION-------------------------
	Param:addSubMenu("KillSteal Settings", "KillSteal")
		Param.KillSteal:addParam("Enable", "Enable KillSteal :", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("Q", "Use (Q) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("E", "Use (E) Spell in KillSteal :", SCRIPT_PARAM_ONOFF, true)

	------------------------------------------------------------
	Param:addSubMenu("", "n2")
	------------------------------------------------------------

	-------------------LASTHIT|OPTION---------------------------
	Param:addSubMenu("LastHit Settings", "LastHit")
		Param.LastHit:addSubMenu("(E) Spell Settings", "E")
			Param.LastHit.E:addParam("Enable", "Enable (E) Spell to LastHit :", SCRIPT_PARAM_ONOFF, true)
			Param.LastHit.E:addParam("Count", "How many creeps to kill :", SCRIPT_PARAM_SLICE, 2, 1, 6)
			Param.LastHit.E:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.LastHit.E:addParam("Hurrican", "Enable Hurrican Check :", SCRIPT_PARAM_ONOFF, false)
			Param.LastHit.E:addParam("CountHurrican", "How many with Hurrican :", SCRIPT_PARAM_SLICE, 3, 1, 6)
	-------------------WAVECLEAR|OPTION-------------------------
	Param:addSubMenu("WaveClear Settings", "WaveClear")
		--Param.WaveClear:addParam("Key", "Advanced WaveClear Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	-------------------JUNGLE|OPTIONS---------------------------
	Param:addSubMenu("Jungle Settings", "Jungle")
		Param.Jungle:addSubMenu("(E) Spell Settings", "E")
			Param.Jungle.E:addParam("Enable", "Enable (E) Spell with Jungle Mobs :", SCRIPT_PARAM_ONOFF, true)
			--
			Param.Jungle.E:addParam("n0Blank", "", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("SpecialMob", "Enable Auto Kill on SpecialMobs :", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("n1SpecialMob", "SpecialMobs : Drake, Rift Herald and Baron.", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("BuffMob", "Enable Auto Kill on BuffMobs :", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("n1BuffMob", "BuffMobs : Red Buff and Blue Buff on the both sides.", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("n2Blank", "", SCRIPT_PARAM_INFO, "")
			--
			Param.Jungle.E:addParam("NormalMob", "Enable Auto Kill on NormalMob :", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("n1NormalMob", "NormalMob : Krug, Razorbeak, Murkwolf, Crab, Gromp.", SCRIPT_PARAM_INFO, "")
			Param.Jungle.E:addParam("All", "Use (E) Spell if you has > 1 mobs to kill?", SCRIPT_PARAM_ONOFF, true)
			Param.Jungle.E:addParam("early", "Enable Early Jungle Help Security?", SCRIPT_PARAM_ONOFF, true)
	
	------------------------------------------------------------
	Param:addSubMenu("", "n3")
	------------------------------------------------------------

	-------------------DRAW|OPTIONS-----------------------------------
	Param:addSubMenu("Draw", "Draw")
		Param.Draw:addParam("Disable", "Disable every Draws :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addParam("AA", "Display (AA) Range :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("HitBox", "Display (HitBox) of Kalista :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("Q", "Display (Q) Spell Range :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("W", "Display (W) Spell Range :", SCRIPT_PARAM_ONOFF, false)
		Param.Draw:addParam("E", "Display (E) Spell Range :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addSubMenu("Special Draw Settings for (E) Spell :", "EDraw")
			Param.Draw.EDraw:addParam("Hero", "Display percent deal by (E) on Heroes :", SCRIPT_PARAM_ONOFF, true) 
			Param.Draw.EDraw:addParam("Mob", "Display percent deal by (E) on Mobs :", SCRIPT_PARAM_ONOFF, true) 
			Param.Draw.EDraw:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Draw.EDraw:addParam("Hero2", "Display AA remaining for (E) Spell on Mob :", SCRIPT_PARAM_ONOFF, true)
			Param.Draw.EDraw:addParam("Mob2", "Display AA reamining for (E) Spell on Mob :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("R", "Display (R) Spell Range :", SCRIPT_PARAM_ONOFF, true)
		Param.Draw:addParam("Target", "Display Target Draw :", SCRIPT_PARAM_ONOFF, true)
		if VIP_USER then Param.Draw:addSubMenu("Skin Changer", "Skin") end
			if VIP_USER then Param.Draw.Skin:addParam("saveSkin", "Save the skin?", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Draw.Skin:addParam("changeSkin", "Apply changes? ", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Draw.Skin:addParam("LetterChamp", "Select the first letter of you'r champion :", SCRIPT_PARAM_LIST, 11, {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}) end
			if VIP_USER then 
				if Param.Draw.Skin.LetterChamp == 1 then LetterChampion = {"Aatrox", "Ahri", "Akali", "Alistar", "Amumu", "Anivia", "Annie", "Ashe", "Azir"} 
					elseif Param.Draw.Skin.LetterChamp == 2 then LetterChampion = {"Bard", "Blitzcrank", "Brand", "Braum"}
					elseif Param.Draw.Skin.LetterChamp == 3 then LetterChampion = {"Caitlyn", "Cassiopeia", "Chogath", "Corki"} 
					elseif Param.Draw.Skin.LetterChamp == 4 then LetterChampion = {"Darius", "Diana", "DrMundo", "Draven"} 
					elseif Param.Draw.Skin.LetterChamp == 5 then LetterChampion = {"Ekko", "Elise", "Evelynn", "Ezreal"} 
					elseif Param.Draw.Skin.LetterChamp == 6 then LetterChampion = {"FiddleSticks", "Fiora", "Fizz"} 
					elseif Param.Draw.Skin.LetterChamp == 7 then LetterChampion = {"Galio", "Gangplank", "Garen", "Gnar", "Gragas", "Graves"} 
					elseif Param.Draw.Skin.LetterChamp == 8 then LetterChampion = {"Hecarim", "Heimerdinger"}
					elseif Param.Draw.Skin.LetterChamp == 9 then LetterChampion = {"Illaoi", "Irelia"}
					elseif Param.Draw.Skin.LetterChamp == 10 then LetterChampion = {"Janna", "JarvanIV", "Jax", "Jayce", "Jinx"}
					elseif Param.Draw.Skin.LetterChamp == 11 then LetterChampion = {"Kalista", "Karma", "Karthus", "Kassadin", "Katarina", "Kayle", "Kennen", "Khazix", "Kindred", "KogMaw"}
					elseif Param.Draw.Skin.LetterChamp == 12 then LetterChampion = {"Leblanc", "LeeSin", "Leona", "Lissandra", "Lucian", "Lulu", "Lux"}
					elseif Param.Draw.Skin.LetterChamp == 13 then LetterChampion = {"Malphite", "Malzahar", "Maokai", "MasterYi", "MissFortune", "Mordekaiser", "Morgana"}
					elseif Param.Draw.Skin.LetterChamp == 14 then LetterChampion = {"Nami", "Nasus", "Nautilus", "Nidalee", "Nocturne", "Nunu"}
					elseif Param.Draw.Skin.LetterChamp == 15 then LetterChampion = {"Olaf", "Orianna"}
					elseif Param.Draw.Skin.LetterChamp == 16 then LetterChampion = {"Pantheon", "Poppy"}
					elseif Param.Draw.Skin.LetterChamp == 17 then LetterChampion = {"Quinn"}
					elseif Param.Draw.Skin.LetterChamp == 18 then LetterChampion = {"Rammus", "Reksai", "Renekton", "Rengar", "Riven", "Rumble", "Ryze"}
					elseif Param.Draw.Skin.LetterChamp == 19 then LetterChampion = {"Sejuani", "Shaco", "Shen", "Shyvana", "Singed", "Sion", "Sivir", "Skarner", "Sona", "Soraka", "Swain", "Syndra"}
					elseif Param.Draw.Skin.LetterChamp == 20 then LetterChampion = {"TahmKench", "Talon", "Taric", "Teemo", "Tresh", "Tristana", "Trundle", "Tryndamere", "TwistedFate", "Twitch"}
					elseif Param.Draw.Skin.LetterChamp == 21 then LetterChampion = {"Udyr", "Urgot"}
					elseif Param.Draw.Skin.LetterChamp == 22 then LetterChampion = {"Varus", "Vayne", "Veigar", "Velkoz", "Vi", "Viktor", "Vladimir", "Volibear"}
					elseif Param.Draw.Skin.LetterChamp == 23 then LetterChampion = {"Warwick", "MonkeyKing"}
					elseif Param.Draw.Skin.LetterChamp == 24 then LetterChampion = {"Xerath", "XinZhao"}
					elseif Param.Draw.Skin.LetterChamp == 25 then LetterChampion = {"Yasuo", "Yorick"}
					elseif Param.Draw.Skin.LetterChamp == 26 then LetterChampion = {"Zac", "Zed", "Ziggs", "Zilean", "Zyra"}
				end
			end
			if VIP_USER then Param.Draw.Skin:addParam("SelectChamp", "Select you'r Champion :", SCRIPT_PARAM_LIST, 1, LetterChampion) end
			if VIP_USER then 
				if Param.Draw.Skin.LetterChamp == 1 then
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Aatrox"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Ahri"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Akali"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Alistar"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Amumu"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Anivia"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Annie"
						elseif Param.Draw.Skin.SelectChamp == 8 then HeroSkin = "Ashe"
						elseif Param.Draw.Skin.SelectChamp == 9 then HeroSkin = "Azir"
					end
				elseif Param.Draw.Skin.LetterChamp == 2 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Bard"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Blitzcrank"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Brand"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Braum"
					end
				elseif Param.Draw.Skin.LetterChamp == 3 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Caitlyn"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Cassiopeia"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Chogath"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Corki"
					end
				elseif Param.Draw.Skin.LetterChamp == 4 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Darius"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Diana"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "DrMundo"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Draven"
					end
				elseif Param.Draw.Skin.LetterChamp == 5 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Ekko"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Elise"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Evelynn"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Ezreal"
					end
				elseif Param.Draw.Skin.LetterChamp == 6 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "FiddleSticks"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Fiora"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Fizz"
					end
				elseif Param.Draw.Skin.LetterChamp == 7 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Galio"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Gangplank"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Garen"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Gnar"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Gragas"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Graves"
					end
				elseif Param.Draw.Skin.LetterChamp == 8 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Hecarim"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Heimerdinger"
					end
				elseif Param.Draw.Skin.LetterChamp == 9 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Illaoi"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Irelia"
					end
				elseif Param.Draw.Skin.LetterChamp == 10 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Janna"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "JarvanIV"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Jax"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Jayce"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Jinx"
					end
				elseif Param.Draw.Skin.LetterChamp == 11 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Kalista"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Karma"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Karthus"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Kassadin"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Katarina"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Kayle"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Kennen"
						elseif Param.Draw.Skin.SelectChamp == 8 then HeroSkin = "Khazix"
						elseif Param.Draw.Skin.SelectChamp == 9 then HeroSkin = "Kindred"
						elseif Param.Draw.Skin.SelectChamp == 10 then HeroSkin = "KogMaw"
					end
				elseif Param.Draw.Skin.LetterChamp == 12 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Leblanc"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "LeeSin"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Leona"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Lissandra"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Lucian"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Lulu"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Lux"
					end
				elseif Param.Draw.Skin.LetterChamp == 13 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Malphite"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Malzahar"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Maokai"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "MasterYi"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "MissFortune"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Mordekaiser"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Morgana"
					end
				elseif Param.Draw.Skin.LetterChamp == 14 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Nami"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Nasus"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Nautilus"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Nidalee"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Nocturne"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Nunu"
					end
				elseif Param.Draw.Skin.LetterChamp == 15 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Olaf"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Orianna"
					end
				elseif Param.Draw.Skin.LetterChamp == 16 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Pantheon"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Poppy"
					end
				elseif Param.Draw.Skin.LetterChamp == 17 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Quinn"
					end
				elseif Param.Draw.Skin.LetterChamp == 18 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Rammus"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Reksai"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Renekton"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Rengar"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Riven"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Rumble"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Ryze"
					end
				elseif Param.Draw.Skin.LetterChamp == 19 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Sejuani"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Shaco"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Shen"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Shyvana"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Singed"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Sion"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Sivir"
						elseif Param.Draw.Skin.SelectChamp == 8 then HeroSkin = "Skarner"
						elseif Param.Draw.Skin.SelectChamp == 9 then HeroSkin = "Sona"
						elseif Param.Draw.Skin.SelectChamp == 10 then HeroSkin = "Soraka"
						elseif Param.Draw.Skin.SelectChamp == 11 then HeroSkin = "Swain"
						elseif Param.Draw.Skin.SelectChamp == 12 then HeroSkin = "Syndra"
					end
				elseif Param.Draw.Skin.LetterChamp == 20 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "TahmKench"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Talon"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Taric"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Teemo"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Tresh"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Tristana"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Trundle"
						elseif Param.Draw.Skin.SelectChamp == 8 then HeroSkin = "Tryndamere"
						elseif Param.Draw.Skin.SelectChamp == 9 then HeroSkin = "TwistedFate"
						elseif Param.Draw.Skin.SelectChamp == 10 then HeroSkin = "Twitch"
					end
				elseif Param.Draw.Skin.LetterChamp == 21 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Udyr"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Urgot"
					end
				elseif Param.Draw.Skin.LetterChamp == 22 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Varus"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Vayne"
						elseif Param.Draw.Skin.SelectChamp == 3 then HeroSkin = "Veigar"
						elseif Param.Draw.Skin.SelectChamp == 4 then HeroSkin = "Velkoz"
						elseif Param.Draw.Skin.SelectChamp == 5 then HeroSkin = "Vi"
						elseif Param.Draw.Skin.SelectChamp == 6 then HeroSkin = "Viktor"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Vladimir"
						elseif Param.Draw.Skin.SelectChamp == 7 then HeroSkin = "Volibear"
					end
				elseif Param.Draw.Skin.LetterChamp == 23 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Warwick"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "MonkeyKing"
					end
				elseif Param.Draw.Skin.LetterChamp == 24 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Xerath"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "XinZhao"
					end
				elseif Param.Draw.Skin.LetterChamp == 25 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Yasuo"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Yorick"
					end
				elseif Param.Draw.Skin.LetterChamp == 26 then 
					if Param.Draw.Skin.SelectChamp == 1 then HeroSkin = "Zac"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Zed"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Ziggs"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Zilean"
						elseif Param.Draw.Skin.SelectChamp == 2 then HeroSkin = "Zyra"
					end
				end
			end
			if VIP_USER then Param.Draw.Skin:addParam("selectedSkin", "Which Skin :", SCRIPT_PARAM_LIST, 2, skinMeta[HeroSkin]) end

	------------------------------------------------------------
	Param:addSubMenu("", "n4")
	------------------------------------------------------------

	-------------------MISC|OPTIONS-----------------------------------
	Param:addSubMenu("Miscellaneous", "Misc")
		if VIP_USER then Param.Misc:addSubMenu("Auto LVL Spell :", "LVL") end
			if VIP_USER then Param.Misc.LVL:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 1, {"E > W > Q (Max E)"}) end
			if VIP_USER then Last_LevelSpell = 0 end
		Param.Misc:addSubMenu("Masteries :", "Masteries")
			Param.Misc.Masteries:addParam("DoubleEdgedSword", "Double Edeged Sword :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("BountyHunter", "Bounty Hunter :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("Merciless", "Merciless :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("Oppresor", "Oppresor :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("Assassin", "Assassin :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Masteries:addParam("n1Blank", "If you took my Masteries Config on the forum, then,", SCRIPT_PARAM_INFO, "")
			Param.Misc.Masteries:addParam("n1Blank", "set only : 'Merciless' and 'Oppresor' to true.", SCRIPT_PARAM_INFO, "")
		if VIP_USER then Param.Misc:addSubMenu("Auto Buy Starter :", "Starter") end
			if VIP_USER then Param.Misc.Starter:addParam("Doran", "Buy a doran blade :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.Starter:addParam("Pots", "Buy a potion :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.Misc.Starter:addParam("Trinket", "Buy a Green Trinket :", SCRIPT_PARAM_ONOFF, true) end
		Param.Misc:addSubMenu("Sentinel Trick :", "WTrick")
			Param.Misc.WTrick:addParam("Drake", "Cast (W) Spell trick on Drake?", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.WTrick:addParam("Baron", "Cast (W) Spell trick on Baron?", SCRIPT_PARAM_ONOFF, false)
		Param.Misc:addSubMenu("Items :", "Items")
			Param.Misc.Items:addParam("Pot", "Use potions with this script :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("PotXHP", "At how many %HP :", SCRIPT_PARAM_SLICE, 60, 0, 100)
			Param.Misc.Items:addParam("PotCombo", "Use potions only in ComboMode :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("n1blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.Items:addParam("Qss", "Use Qss with this script :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("Qssdelay", "Humanizer (ms)", SCRIPT_PARAM_SLICE, 0, 0, 1000)
			Param.Misc.Items:addParam("QssZedR", "Clean Zed (R) Spell :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("QssStun", "Clean on 'Stun': ", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("QssRoot", "Clean on 'Root' :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Items:addParam("QssSilence", "Clean on 'Silence' :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Items:addParam("QssTaunt", "Clean on 'Taunt' :", SCRIPT_PARAM_ONOFF, false)
			Param.Misc.Items:addParam("QssExhaust", "Clean on Summoner spell 'Exhaust' :", SCRIPT_PARAM_ONOFF, true)
		Param.Misc:addSubMenu("Balista / Tahmista :", "Blitz")
			Param.Misc.Blitz:addParam("Blitz", "Enable Balista Combo :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Blitz:addParam("BlitzRangeMin", "Set the minimum range to use :", SCRIPT_PARAM_SLICE, 400, 0, 1400)
			Param.Misc.Blitz:addParam("BlitzRangeMax", "Set the maximum range to use :", SCRIPT_PARAM_SLICE, 1400, 0, 1400)
			Param.Misc.Blitz:addParam("n1Blank", "", SCRIPT_PARAM_INFO, "")
			Param.Misc.Blitz:addParam("Tahm", "Enable TahmKench Combo :", SCRIPT_PARAM_ONOFF, true)
			Param.Misc.Blitz:addParam("TahmRangeMin", "Set the minimum range to use :", SCRIPT_PARAM_SLICE, 800, 0, 1400)
			Param.Misc.Blitz:addParam("TahmRangeMax", "Set the maximum range to use :", SCRIPT_PARAM_SLICE, 1400, 0, 1400)
		Param.Misc:addParam("PermaE", "Enable (E) to kill when it's possible :", SCRIPT_PARAM_ONOFF, true)

		-- Use E before your death
		-- Wall jump
		-- Explode Key
		-- Disable E
		-- Packets features
		-- Humanizer vision (écran)

	------------------------------------------------------------
	Param:addSubMenu("", "n5")
	------------------------------------------------------------

	-------------------ORBWALKER & PREDICTION-------------------------
	Param:addSubMenu("OrbWalker", "orbwalker")
		Param.orbwalker:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 3, {"SxOrbWalk", "BigFat OrbWalker", "Nebelwolfi's Orb Walker"})
		Param.orbwalker:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n4", "", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n5", "SAC:R is automaticly loaded.(Enable it in BoLStudio)", SCRIPT_PARAM_INFO, "")
	--

	------------------------------------------------------------
	Param:addSubMenu("", "n6")
	------------------------------------------------------------

	Param:addParam("n4", "Baguette Kalista | Version", SCRIPT_PARAM_INFO, ""..version.."")
	Param:permaShow("n4")

	CustomLoad()
end

function CustomLoad()

	Param.Misc.WTrick.Drake = false
	Param.Misc.WTrick.Baron = false

	enemyMinions = minionManager(MINION_ENEMY, 3000, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 3000, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Kalista"
	Param:addTS(ts)
	LoadVPred()

	if VIP_USER and Param.Misc.LVL.Enable then
		AutoLvlSpellCombo()
	end

	if VIP_USER then
		if (not Param.Draw.Skin['saveSkin']) then
			Param.Draw.Skin['changeSkin'] = false
			Param.Draw.Skin['selectedSkin'] = 1
		elseif (Param.Draw.Skin['changeSkin']) then
			SendSkinPacket(myHero.charName, skinsPB[Param.Draw.Skin['selectedSkin']], myHero.networkID)
		end
	end

	if _G.Reborn_Loaded ~= nil then
   		LoadSACR()
	elseif Param.orbwalker.n1 == 1 then
		EnvoiMessage("SxOrbWalk loading..")
		LoadSXOrb()
	elseif Param.orbwalker.n1 == 2 then
		EnvoiMessage("BigFat OrbWalker loading..")
		LoadBFOrb()
	elseif Param.orbwalker.n1 == 3 then
		local neo = 1
		EnvoiMessage("Nebelwolfi's Orb Walker loading..")
		LoadNEBOrb()
	end

	DelayAction(function()AutoBuy()end, 3)

end

function LoadSXOrb()

	if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
		require("SxOrbWalk")
		EnvoiMessage("Loaded SxOrbWalk")
		Param:addSubMenu("SxOrbWalk", "SXMenu")
		SxOrb:LoadToMenu(Param.SXMenu)
	else
		local ToUpdate = {}
		    ToUpdate.Version = 1
		   	ToUpdate.UseHttps = true
		    ToUpdate.Host = "raw.githubusercontent.com"
		   	ToUpdate.VersionPath = "/Superx321/BoL/master/common/SxOrbWalk.Version"
		   	ToUpdate.ScriptPath =  "/Superx321/BoL/master/common/SxOrbWalk.lua"
		    ToUpdate.SavePath = LIB_PATH.."/SxOrbWalk.lua"
		   	ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". </b></font>") end
		    ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
		    ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
		   	ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>SxOrbWalk: </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
		   	ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
end

function LoadBFOrb()
	local LibPath = LIB_PATH.."Big Fat Orbwalker.lua"
	local ScriptPath = SCRIPT_PATH.."Big Fat Orbwalker.lua"
	if not (FileExist(ScriptPath) and _G["BigFatOrb_Loaded"] == true) then
			local Host = "raw.github.com"
			local Path = "/BigFatNidalee/BoL-Releases/master/LimitedAccess/Big Fat Orbwalker.lua?rand="..math.random(1,10000)
			DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		require "Big Fat Orbwalker"
	end
end

function LoadNEBOrb()
		if not _G.NebelwolfisOrbWalkerLoaded then
			require "Nebelwolfi's Orb Walker"
			NebelwolfisOrbWalkerClass()
		end
	end
	if not FileExist(LIB_PATH.."Nebelwolfi's Orb Walker.lua") then
		DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
			LoadNEBOrb()
		end)
	else
		local f = io.open(LIB_PATH.."Nebelwolfi's Orb Walker.lua")
		f = f:read("*all")
		if f:sub(1,4) == "func" then
			DownloadFile("http://raw.githubusercontent.com/nebelwolfi/BoL/master/Common/Nebelwolfi's Orb Walker.lua", LIB_PATH.."Nebelwolfi's Orb Walker.lua", function()
				LoadNEBOrb()
			end)
		else
			if neo == 1 then
				LoadNEBOrb()
			end
		end
	end

function LoadSACR()
	if _G.Reborn_Initialised then
	elseif _G.Reborn_Loaded then
		EnvoiMessage("Loaded SAC:R")
	else
		DelayAction(function()EnvoiMessage("Failed to Load SAC:R")end, 7)
	end 
end

function LoadVPred()
	if FileExist(LIB_PATH .. "/VPrediction.lua") then
		require("VPrediction")
		EnvoiMessage("Succesfully loaded VPred")
		VP = VPrediction()
	else
		local ToUpdate = {}
		ToUpdate.Version = 0.0
		ToUpdate.UseHttps = true
		ToUpdate.Name = "VPrediction"
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/SidaBoL/Scripts/master/Common/VPrediction.version"
		ToUpdate.ScriptPath =  "/SidaBoL/Scripts/master/Common/VPrediction.lua"
		ToUpdate.SavePath = LIB_PATH.."/VPrediction.lua"
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
		ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
		ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
		ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
		ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
end

function OnTick()

	if not myHero.dead then

		ts:update()

		Target = GetCustomTarget()

		Keys()

		KillSteal()

		Spell()

		Consommables()

	end

	if Param.Draw.Skin.changeSkin then
		DrawSkin()
	end

end

function Keys()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then

		if _G.AutoCarry.Keys.AutoCarry then 
			Combo()
		elseif  _G.AutoCarry.Keys.MixedMode then 
			Harass()
		elseif  _G.AutoCarry.Keys.LaneClear then 
			LaneClear()
		elseif  _G.AutoCarry.Keys.LastHit then 
			LastHit()
		end

	elseif Param.orbwalker.n1 == 1 and _G.SxOrbMenu then

		if _G.SxOrbMenu.AutoCarry then 
			Combo()
		elseif  _G.SxOrbMenu.MixedMode then 
			Harass()
		elseif  _G.SxOrbMenu.LaneClear then 
			LaneClear() 
		elseif  _G.SxOrbMenu.LastHit then 
			LastHit()
		end

	elseif Param.orbwalker.n1 == 2 and _G["BigFatOrb_Loaded"] == true then

		if _G["BigFatOrb_Mode"] == 'Combo' then
			Combo()
		elseif _G["BigFatOrb_Mode"] == 'Harass' then
			Harass()
		elseif _G["BigFatOrb_Mode"] == 'LastHit' then
			LastHit()
		elseif _G["BigFatOrb_Mode"] == 'LaneClear' then
			LaneClear()
		end

	elseif Param.orbwalker.n1 == 3 and _G.NebelwolfisOrbWalkerLoaded then

		if _G.NebelwolfisOrbWalker.Config.k.Combo then
			Combo()
		elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
			Harass()
		elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
			LastHit()
		elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
			LaneClear()
		end

		if not _G.NebelwolfisOrbWalker.Config.k.Combo and AAON == 1 then
			_G.NebelwolfisOrbWalker.Config.k.LaneClear = false 
			AAON = 0
		end

	end
end


function GetCustomTarget()
	ts:update()	
	if ValidTarget(ts.target) and ts.target.type == myHero.type then
		return ts.target
	else
		return nil
	end
end

function KillSteal()
	if Param.KillSteal.Enable then
		for _, unit in pairs(GetEnemyHeroes()) do
			Qdmg = ((myHero:CanUseSpell(_Q) == READY and dmgQ) or 0)
			if GetDistance(unit) < SkillQ.range then
				if unit.health < Qdmg and Param.KillSteal.Q and myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) and unit ~= nil then
					local castPos, HitChance, pos = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
					if HitChance >= 2 then
						CastSpell(_Q, castPos.x, castPos.z)
					end
				end
				if Param.KillSteal.E and not Param.Misc.PermaE and myHero:CanUseSpell(_E) == READY and ValidTarget(unit) and GetDistance(unit) < SkillE.range then
					AutoEHero()
				end
			end
		end
	end
end

function Spell()
	if Param.Misc.PermaE then
		AutoEHero()
	end
	if Param.LastHit.E.Enable then
		AutoEMinion()
	end
	if Param.Jungle.E.Enable then
		AutoEMob()
	end
	if Param.Harass.E.Auto then
		EHarass()
	end
	if Param.Misc.WTrick.Drake == true then
		CastSpell(_W, 9866.148, -71, 4414.014)
		Param.Misc.WTrick.Drake = false
	end
	if Param.Misc.WTrick.Baron == true then
		CastSpell(_W, 5007.124, -71, 10471.45)
		Param.Misc.WTrick.Baron = false
	end
end

function Combo()
	if Param.Combo.Q then
		LogicQ()
	end
	if Param.Combo.E then
		AutoEHero()
	end
	if Param.Misc.Items.Pot and Param.Misc.Items.PotCombo then
		AutoPotions()
	end
	if Param.Combo.Kite then
		OutOfAA()
	end
end

function OutOfAA()
	for _, unit in pairs(GetEnemyHeroes()) do
		if GetDistance(unit) < myHero.range+myHero.boundingRadius+50 and not unit.dead then
			if Param.orbwalker.n1 == 3 and _G.NebelwolfisOrbWalkerLoaded then
				_G.NebelwolfisOrbWalker.Config.k.LaneClear = false
			end
		elseif GetDistance(unit) > myHero.range+myHero.boundingRadius+50 and AAON == 0 or GetDistance(unit) < myHero.range+myHero.boundingRadius+50 and unit.dead then
			if Param.orbwalker.n1 == 3 and _G.NebelwolfisOrbWalkerLoaded then
				_G.NebelwolfisOrbWalker.Config.k.LaneClear = true
				AAON = 1
			end
		end
	end
end

function LaneClear()
end

function Harass()
	if Param.Harass.Q then
		LogicQ()
	end
	if Param.Harass.E then
		EHarass()
	end
end

function EHarass()
	if not ManaEHarass() then
		if myHero:CanUseSpell(_E) == READY then
			enemyMinions:update()
			local ccount = 0
			for i, minion in pairs(enemyMinions.objects) do
				if ValidTarget(minion) and minion ~= nil and not minion.dead then
					if GetStacks(minion) > 0 then
						D1 = math.floor(myHero:CalcDamage(minion,dmgE))

						ELvl()

						D2 = math.floor(myHero:CalcDamage(minion,dmgEX))
						D3 = D1 + ((GetStacks(minion)-1) * D2)

						if D3 > minion.health then
							ccount = ccount + 1
						end
					end
				end
			end
			local ccounthero = 0
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and GetDistance(unit) < SkillE.range and not unit.dead then
					if GetStacks(unit) > 0 and not unit.dead then
						if GetStacks(unit) >= Param.Harass.E.AAHero then
							ccounthero = ccounthero + GetStacks(unit)
						end
					end
				end
			end
			if ccounthero >= Param.Harass.E.AAHero and ccount >= Param.Harass.E.Minions then
				CastSpell(_E)
			end
		end
	end
end

function ManaEHarass()
    if myHero.mana < (myHero.maxMana * ( Param.Harass.E.Mana / 100)) then
        return true
    else
        return false
    end
end

function LastHit()
end

function LogicQ()
	if Target ~= nil and myHero:CanUseSpell(_Q) == READY then
		local castPos, HitChance, pos = VP:GetLineCastPosition(Target, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
		if HitChance >= 2 then
			CastSpell(_Q, castPos.x, castPos.z)
		end
	end
end

function AutoEMinion()
	if myHero:CanUseSpell(_E) == READY then
		enemyMinions:update()
		local ccount = 0
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil then
				if GetStacks(minion) > 0 then

					D1 = math.floor(myHero:CalcDamage(minion,dmgE))

					ELvl()

					D2 = math.floor(myHero:CalcDamage(minion,dmgEX))
					D3 = D1 + ((GetStacks(minion)-1) * D2)

					if D3 > minion.health then
						ccount = ccount + 1
					end
				end
			end
		end
		if ccount >= Param.LastHit.E.Count then
			CastSpell(_E)
		end
	end
end

function ELvl()
	if myHero:GetSpellData(_E).level == 1 then
		dmgEX = 10 + 0.2 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 2 then	
		dmgEX = 14 + 0.225 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 3 then
		dmgEX = 19 + 0.25 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 4 then
		dmgEX = 25 + 0.275 * myHero.totalDamage
	elseif myHero:GetSpellData(_E).level == 5 then
		dmgEX = 32 + 0.3 * myHero.totalDamage
	end
end

function AutoEMob()
	if Param.Jungle.E.Enable then
		if myHero:CanUseSpell(_E) == READY then
			jungleMinions:update()
			local ccount = 0
			for i, jungleMinion in pairs(jungleMinions.objects) do
				if jungleMinion ~= nil then
					if GetStacks(jungleMinion) > 0 and GetDistance(jungleMinion) < SkillE.range then

						D1 = math.floor(myHero:CalcDamage(jungleMinion,dmgE))

						ELvl()

						D2 = math.floor(myHero:CalcDamage(jungleMinion,dmgEX))
						D3 = D1 + ((GetStacks(jungleMinion)-1) * D2)

						if not TargetHaveBuff("summonerexhaust", myHero) then
							if (D3 > (jungleMinion.health)) and IsSpecialAMobToE[jungleMinion.name] and Param.Jungle.E.SpecialMob and jungleMinion.name ~= "SRU_Dragon6.1.1" then
									CastSpell(_E)
							end

							if (D3 > (jungleMinion.health)) and IsSpecialAMobToE[jungleMinion.name] and Param.Jungle.E.SpecialMob and jungleMinion.name == "SRU_Dragon6.1.1" then
								if Dragons ~= 0 then
									if (D3-(((D3*7)/100)*Dragons)) > jungleMinion.health then
										CastSpell(_E)
									end
								elseif Dragons == 0 then
									CastSpell(_E)
								end
							end

							if D3 > jungleMinion.health and IsABuffMobToE[jungleMinion.name] and Param.Jungle.E.BuffMob then
								CastSpell(_E)
							end

							if D3 > jungleMinion.health and IsANormalMobToE[jungleMinion.name] and Param.Jungle.E.NormalMob then
								if Param.Jungle.E.early and GetGameTimer() > 170 then
									CastSpell(_E)
								elseif not Param.Jungle.E.early then
									CastSpell(_E)
								elseif Param.Jungle.E.early and GetGameTimer() < 170 then
									if os.clock() - LastMSG > 2 then
										LastMSG = os.clock()
										EnvoiMessage("Cannont Steal, Menu > Jungle > (E) > Security")
									end
								end
							end

							if D3 > jungleMinion.health and Param.Jungle.E.All then
								ccount = ccount + 1
							end

						elseif TargetHaveBuff("summonerexhaust", myHero) then
							if (D3 - ((D3 * 40)/100)-100) > jungleMinion.health and IsSpecialAMobToE[jungleMinion.name] and Param.Jungle.E.SpecialMob then -- - 10Temporaire, buff drake & de-buff nash pls
								CastSpell(_E)
							end

							if (D3 - ((D3 * 40)/100)) > jungleMinion.health and IsABuffMobToE[jungleMinion.name] and Param.Jungle.E.BuffMob then
								CastSpell(_E)
							end

							if (D3 - ((D3 * 40)/100)) > jungleMinion.health and IsANormalMobToE[jungleMinion.name] and Param.Jungle.E.NormalMob then
								if Param.Jungle.E.early and GetGameTimer() > 170 then
									CastSpell(_E)
								elseif not Param.Jungle.E.early then
									CastSpell(_E)
								elseif Param.Jungle.E.early and GetGameTimer() < 170 then
									if os.clock() - LastMSG > 2 then
										LastMSG = os.clock()
										EnvoiMessage("Cannont Steal, Menu > Jungle > (E) > Security")
									end
								end
							end

							if (D3 - ((D3 * 40)/100)) > jungleMinion.health and Param.Jungle.E.All then
								ccount = ccount + 1
							end
						end
					end 
				end
			end
			if not TargetHaveBuff("summonerexhaust", myHero) then
				if ccount > 1 then
					CastSpell(_E)
				end
			elseif TargetHaveBuff("summonerexhaust", myHero) then
				if ccount > 1 then
					CastSpell(_E)
				end
			end
		end
	end
end

IsSpecialAMobToE = {
	['SRU_RiftHerald17.1.1'] = {true}, -- Blue | Haut
	['SRU_Baron12.1.1'] = {true}, -- Blue | Haut
	['SRU_Dragon6.1.1'] = {true} -- Blue | Bas
}

IsABuffMobToE = {
	['SRU_Red4.1.1'] = {true}, -- Blue | Bas
	['SRU_Blue1.1.1'] = {true}, -- Blue | Haut
	['SRU_Blue7.1.1'] = {true}, -- Red | Bas
	['SRU_Red10.1.1'] = {true} -- Red | Haut
}

IsANormalMobToE = {
	-- Blue | Bas
	['SRU_Krug5.1.2'] = {true},
	['SRU_Razorbeak3.1.1'] = {true},
	['Sru_Crab15.1.1'] = {true},
	-- Blue | Haut
	['SRU_Murkwolf2.1.1'] = {true},
	['SRU_Gromp13.1.1'] = {true},
	['Sru_Crab16.1.1'] = {true},
	-- Red | Bas
	['SRU_Gromp14.1.1'] = {true},
	['SRU_Murkwolf8.1.1'] = {true},
	-- Red | Haut
	['SRU_Razorbeak9.1.1'] = {true},
	['SRU_Krug11.1.2'] = {true}
}

function AutoEHero()
	if myHero:CanUseSpell(_E) == READY then
		for _, unit in pairs(GetEnemyHeroes()) do
			if unit ~= nil and GetDistance(unit) < SkillE.range and not unit.dead then
				if GetStacks(unit) > 0 then

					D1 = math.floor(myHero:CalcDamage(unit,dmgE))

					ELvl()

					D2 = math.floor(myHero:CalcDamage(unit,dmgEX))
					D3 = D1 + ((GetStacks(unit)-1) * D2)

					if not TargetHaveBuff("summonerexhaust", myHero) then
						if unit.charName == "Blitzcrank" then
							if LastBlitz > os.clock() then
								if (D3 > (unit.health+((unit.mana*50)/100))) and not Immune(unit) and unit.shield < 1 then
									CastSpell(_E)
								elseif (D3 > (unit.health+unit.shield+((unit.mana*50)/100))) and not Immune(unit) and unit.shield > 1 then
									CastSpell(_E)
									--EnvoiMessage("Blitzcrank Passive DOWN.")
								end
							elseif LastBlitz < os.clock() then
								if D3 > unit.health and not Immune(unit) and unit.shield < 1 then
									CastSpell(_E)
								elseif (D3 > (unit.health+unit.shield)) and not Immune(unit) and unit.shield > 1 then
									CastSpell(_E)
								end
							end
						end
						if D3 > unit.health and not Immune(unit) and unit.shield < 1 and unit.charName ~= "Blitzcrank" then
							CastSpell(_E)
						elseif (D3 > (unit.health+unit.shield)) and not Immune(unit) and unit.shield > 1 and unit.charName ~= "Blitzcrank"  then
							CastSpell(_E)
						end
					elseif TargetHaveBuff("summonerexhaust", myHero) then
						if unit.charName == "Blitzcrank" then
							if LastBlitz > os.clock() then
								if (D3 > (unit.health+((unit.mana*50)/100))) and not Immune(unit) and unit.shield < 1 then
									CastSpell(_E)
									EnvoiMessage("Blitzcrank Passive DOWN.")
								elseif (D3 > (unit.health+unit.shield+((unit.mana*50)/100))) and not Immune(unit) and unit.shield > 1 then
									CastSpell(_E)
									EnvoiMessage("Blitzcrank Passive DOWN.")
								end
							elseif LastBlitz < os.clock() then
								if D3 > unit.health and not Immune(unit) and unit.shield < 1 then
									CastSpell(_E)
								elseif (D3 > (unit.health+unit.shield)) and not Immune(unit) and unit.shield > 1 then
									CastSpell(_E)
								end
							end
						end
						if (D3 - ((D3 * 40)/100)) > unit.health and not Immune(unit) and unit.shield < 1 and unit.charName ~= "Blitzcrank" then
							CastSpell(_E)
						elseif (D3 > (unit.health+unit.shield)) and not Immune(unit) and unit.shield > 1 and unit.charName ~= "Blitzcrank" then
							CastSpell(_E)
						end
					end
				end
			end
		end
	end
end

function CheckBuff()

end

function CheckShield()

end

function OnUpdateBuff(Unit, buff, Stacks)
   if buff.name == "kalistaexpungemarker" then
      unitStacks[Unit.networkID] = Stacks
   end
end
 
function OnRemoveBuff(Unit, buff)
    if buff.name == "kalistaexpungemarker" then
      unitStacks[Unit.networkID] = nil
    end
	 if buff.name == "manabarrier" then
		LastBlitz = os.clock()+90
		--EnvoiMessage("Blitzcrank Passive DOWN.")
	end
end

function OnApplyBuff(source, unit, buff)
	if buff.name == "s5tooltip_dragonslayerbuffv1" and unit.isMe then
		Dragons = 1
	elseif buff.name == "s5tooltip_dragonslayerbuffv2" and unit.isMe then
		Dragons = 2
	elseif buff.name == "s5tooltip_dragonslayerbuffv3" and unit.isMe then
		Dragons = 3
	elseif buff.name == "s5tooltip_dragonslayerbuffv4" and unit.isMe then
		Dragons = 4
	elseif buff.name == "s5tooltip_dragonslayerbuffv5" and unit.isMe then
		Dragons = 5
	end
	if buff.name == "DarkBindingMissile" and unit.isMe and Param.Misc.Items.QssRoot then
		QSS()
	end
	if buff.name == "Stun" and unit.isMe and Param.Misc.Items.QssStun then
		QSS()
	end
	if buff.name == "summonerexhaust" and unit.isMe and Param.Misc.Items.QssExhaust then
		QSS()
	end
	--if buff.name == "Taunt" and unit.isMe and Param.Misc.Items.QssTaunt then
		--QSS()
	--end
	if buff.name == "Silence" and unit.isMe and Param.Misc.Items.QssSilence then
		QSS()
	end
	if buff.name == "Root" and unit.isMe and Param.Mics.Items.QssRoot then
		QSS()
	end
	if TargetHaveBuff("rocketgrab2", unit) and Param.Misc.Blitz.Blitz then
		if unit.team ~= myHero.team then
			if GetDistance(unit) > Param.Misc.Blitz.BlitzRangeMin and GetDistance(unit) < Param.Misc.Blitz.BlitzRangeMax then
				CastSpell(_R)
			end
		end
	end
	if TargetHaveBuff("tamhkenchdevoured", unit) and Param.Misc.Blitz.Tahm then
		if unit.team ~= myHero.team then
			if GetDistance(unit) > Param.Misc.Blitz.TahmRangeMin and GetDistance(unit) < Param.Misc.Blitz.TahmRangeMax then
				CastSpell(_R)
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if spell.name == "ZedR" and spell.target and spell.target.networkID == myHero.networkID then
		if Param.Misc.Items.QssZedR then
			DelayAction(function()
				QSS()
			end, 2.8)
		end
	end
end

function GetStacks(unit)
	return unitStacks[unit.networkID] or 0
end

SkillQ = { name = "Pierce", range = 1150, delay = 0.25, speed = 1750, width = 70, ready = false}
SkillW = { name = "Sentinel", range = 5000, delay = 0.25, speed = math.huge, width = 250, ready = false }
SkillE = { name = "Rend", range = 1000, delay = 0.50, speed = nil, width = nil, ready = false }
SkillR = { name = "Fate's Call", range = 1500, delay = nil, speed = nil, width = nil, ready = false }

function OnDraw()
	if not myHero.dead and not Param.Draw.Disable then

		-- SPELL DRAW
		if myHero:CanUseSpell(_Q) == READY and Param.Draw.Q then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_W) == READY and Param.Draw.W then 
			DrawCircleMinimap(myHero.x, myHero.y, myHero.z, SkillW.range)
		end
		if myHero:CanUseSpell(_E) == READY and Param.Draw.E then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_R) == READY and Param.Draw.R then
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, 0xFFFFFFFF)
		end
		if Param.Draw.AA then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 0xFFFFFFFF)
		end
		if Param.Draw.HitBox then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 0xFFFFFFFF)
		end

		-- TARGET DRAW
		if Target ~= nil and ValidTarget(Target) then
			if Param.Draw.Target then
				DrawText3D(">> Current|Target <<",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFFFF)
			end
		end

		-- Percent E draw

		-- Heroes
		if Param.Draw.EDraw.Hero then
			if myHero:CanUseSpell(_E) == READY then

				for _, unit in pairs(GetEnemyHeroes()) do

					if unit ~= nil and GetDistance(unit) < 3000 then

						if GetStacks(unit) > 0 then

							D1 = math.round(myHero:CalcDamage(unit,dmgE))

							ELvl()

							D2 = math.round(myHero:CalcDamage(unit,dmgEX))
							D3E = D1 + ((GetStacks(unit)-1) * D2)
							local D3E1 = math.floor(D3E/unit.health*100)

							if not TargetHaveBuff("summonerexhaust", myHero) then 
								if D3E1 < 80 then
									DrawText3D(D3E1.."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
								elseif D3E1 >= 80 and D3E1 < 100 then
									DrawText3D(D3E1.."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								elseif D3E1 >= 100 then
									DrawText3D("100% !", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								end
							elseif TargetHaveBuff("summonerexhaust", myHero) then
								if (D3E1-((D3E1*40)/100)) < 80 then
									DrawText3D((D3E1-((D3E1*40)/100)).."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
								elseif (D3E1-((D3E1*40)/100)) >= 80 and (D3E1-((D3E1*40)/100)) < 100 then
									DrawText3D((D3E1-((D3E1*40)/100)).."%", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								elseif (D3E1-((D3E1*40)/100)) >= 100 then
									DrawText3D("100% !", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
								end
							end
						end
					end
				end
			end
		end

		-- Mobs

		if Param.Draw.EDraw.Mob then
			if myHero:CanUseSpell(_E) == READY then

				jungleMinions:update()

				for i, jungleMinion in pairs(jungleMinions.objects) do

					if jungleMinion ~= nil and GetDistance(jungleMinion) < 3000 then

						if IsANormalMobToE[jungleMinion.name] or IsABuffMobToE[jungleMinion.name] or IsSpecialAMobToE[jungleMinion.name] then

							if GetStacks(jungleMinion) > 0 then

								D1 = math.round(myHero:CalcDamage(jungleMinion,dmgE))

								ELvl()

								D2 = math.round(myHero:CalcDamage(jungleMinion,dmgEX))
								D3E = D1 + ((GetStacks(jungleMinion)-1) * D2)
								local D3E1 = math.floor(D3E/jungleMinion.health*100)


								if D3E1 < 80 then
									DrawText3D(D3E1.."%", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,250,250,250), 0)
								elseif D3E1 >= 80 and D3E1 < 100 then
									DrawText3D(D3E1.."%", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
								elseif D3E1 >= 100 then
								DrawText3D("100% !", jungleMinion.x+125, jungleMinion.y+85, jungleMinion.z+155, 30, ARGB(255,205,51,51), 0)
							end
							end
						end
					end
				end
			end
		end

	end
end

function Consommables()
	if VIP_USER then
		if Param.Misc.LVL.Enable then
	 		AutoLvlSpell()
		end
	end
	if Param.Misc.Items.Pot and not Param.Misc.Items.PotCombo then
		AutoPotions()
	end
end

function AutoLvlSpell()
 	if VIP_USER and os.clock()-Last_LevelSpell > 0.5 then
    	autoLevelSetSequence(levelSequence)
    	Last_LevelSpell = os.clock()
  	end
end

_G.LevelSpell = function(id)
	if (string.find(GetGameVersion(), 'Releases/6.3') ~= nil) then
		 local offsets = { 
		  [_Q] = 0x8A,
		  [_W] = 0xE1,
		  [_E] = 0x23,
		  [_R] = 0x14,
		  }
		  local p = CLoLPacket(0x00E7)
		  p.vTable = 0xF9C650
		  p:EncodeF(myHero.networkID)
		  p:Encode1(0x9B)
		  p:Encode1(offsets[id])
		  for i = 1, 4 do p:Encode1(0x2D) end
		  for i = 1, 4 do p:Encode1(0x6A) end
		  for i = 1, 4 do p:Encode1(0x0F) end
		  SendPacket(p)
	end
end

function AutoLvlSpellCombo()
	if Param.Misc.LVL.Combo == 1 then
		levelSequence =  {3,2,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2}
	end
end

--======START======--
-- Developers: 
-- Divine (http://forum.botoflegends.com/user/86308-divine/)
-- PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
-- https://raw.githubusercontent.com/Nader-Sl/BoLStudio/master/Scripts/p_skinChanger.lua
--==================--
function DrawSkin()
	if VIP_USER then 
		if ((CurrentTimeInMillis() - lastTimeTickCalled) > 200) then
			lastTimeTickCalled = CurrentTimeInMillis()
			if (Param.Draw.Skin['changeSkin']) then
				if (Param.Draw.Skin['selectedSkin'] ~= lastSkin) then
					lastSkin = Param.Draw.Skin['selectedSkin']
					SendSkinPacket(HeroSkin, skinsPB[Param.Draw.Skin['selectedSkin']], myHero.networkID) -- Hero
				end
			elseif not (Param.Draw.Skin['changeSkin']) then
				SendSkinPacket(myHero.charName, nil, myHero.networkID) -- Hero
			elseif (lastSkin ~= 0) then
				SendSkinPacket(myHero.charName, nil, myHero.networkID)
				lastSkin = 0
			end
		end
	end
end

if (string.find(GetGameVersion(), 'Releases/6.2') ~= nil) then
	skinsPB = {
		[1] = 0xD4,
		[10] = 0xAD,
		[8] = 0xCD,
		[4] = 0x95,
		[12] = 0x8D,
		[5] = 0x94,
		[9] = 0xCC,
		[7] = 0xEC,
		[3] = 0xB4,
		[11] = 0xAC,
		[6] = 0xED,
		[2] = 0xB5,
	};
	skinObjectPos = 37;
	skinHeader = 0x0E
	dispellHeader = 0x130;
	skinH = 0xD4;
	skinHPos = 32;
  	header = 0x0E
end

function SendSkinPacket(mObject, skinPB, networkID)
	if (string.find(GetGameVersion(), 'Releases/6.2') ~= nil) then
		local mP = CLoLPacket(header);
		mP.vTable = 0xFB7464;
		mP:EncodeF(myHero.networkID);
		mP:Encode1(0x00);
		for I = 1, string.len(mObject) do
			mP:Encode1(string.byte(string.sub(mObject, I, I)));
		end;

		for I = 1, (14 - string.len(mObject)) do
			mP:Encode1(0x00);
		end;

		mP:Encode2(0x0000);
		mP:Encode4(0x0000000D);
		mP:Encode4(0x0000000F);
		mP:Encode4(0x00000000);
		mP:Encode2(0x0000);

		if (skinnedObject) then
			mP:Encode4(0xD5D5D5D5);
		else
			mP:Encode1(skinPB);
			for I = 1, 3 do
				mP:Encode1(skinH);
			end;
		end
		mP:Hide();
		RecvPacket(mP);
	end
end

skinMeta = {

  -- A
	["Aatrox"]       = {"Classic", "Justicar", "Mecha", "Sea Hunter"},
	["Ahri"]         = {"Classic", "Dynasty", "Midnight", "Foxfire", "Popstar", "Challenger", "Academy"},
	["Akali"]        = {"Classic", "Stinger", "Crimson", "All-star", "Nurse", "Blood Moon", "Silverfang", "Headhunter"},
	["Alistar"]      = {"Classic", "Black", "Golden", "Matador", "Longhorn", "Unchained", "Infernal", "Sweeper", "Marauder"},
	["Amumu"]        = {"Classic", "Pharaoh", "Vancouver", "Emumu", "Re-Gifted", "Almost-Prom King", "Little Knight", "Sad Robot", "Surprise Party"},
	["Anivia"]       = {"Classic", "Team Spirit", "Bird of Prey", "Noxus Hunter", "Hextech", "Blackfrost", "Prehistoric"},
	["Annie"]        = {"Classic", "Goth", "Red Riding", "Annie in Wonderland", "Prom Queen", "Frostfire", "Reverse", "FrankenTibbers", "Panda", "Sweetheart"},
	["Ashe"]         = {"Classic", "Freljord", "Sherwood Forest", "Woad", "Queen", "Amethyst", "Heartseeker", "Marauder"},
	["Azir"]         = {"Classic", "Galactic", "Gravelord"},
	  -- B  
	["Bard"]         = {"Classic", "Elderwood", "Chroma Pack: Marigold", "Chroma Pack: Ivy", "Chroma Pack: Sage"},
	["Blitzcrank"]   = {"Classic", "Rusty", "Goalkeeper", "Boom Boom", "Piltover Customs", "Definitely Not", "iBlitzcrank", "Riot", "Chroma Pack: Molten", "Chroma Pack: Cobalt", "Chroma Pack: Gunmetal", "Battle Boss"},
	["Brand"]        = {"Classic", "Apocalyptic", "Vandal", "Cryocore", "Zombie", "Spirit Fire"},
	["Braum"]        = {"Classic", "Dragonslayer", "El Tigre", "Lionheart"},
	  -- C  
	["Caitlyn"]      = {"Classic", "Resistance", "Sheriff", "Safari", "Arctic Warfare", "Officer", "Headhunter", "Chroma Pack: Pink", "Chroma Pack: Green", "Chroma Pack: Blue","Lunar"},
	["Cassiopeia"]   = {"Classic", "Desperada", "Siren", "Mythic", "Jade Fang", "Chroma Pack: Day", "Chroma Pack: Dusk", "Chroma Pack: Night"},
	["Chogath"]      = {"Classic", "Nightmare", "Gentleman", "Loch Ness", "Jurassic", "Battlecast Prime", "Prehistoric"},
	["Corki"]        = {"Classic", "UFO", "Ice Toboggan", "Red Baron", "Hot Rod", "Urfrider", "Dragonwing", "Fnatic"},
	  -- D
	["Darius"]       = {"Classic", "Lord", "Bioforge", "Woad King", "Dunkmaster", "Chroma Pack: Black Iron", "Chroma Pack: Bronze", "Chroma Pack: Copper", "Academy"},
	["Diana"]        = {"Classic", "Dark Valkyrie", "Lunar Goddess"},
	["DrMundo"]      = {"Classic", "Toxic", "Mr. Mundoverse", "Corporate Mundo", "Mundo Mundo", "Executioner Mundo", "Rageborn Mundo", "TPA Mundo", "Pool Party"},
	["Draven"]       = {"Classic", "Soul Reaver", "Gladiator", "Primetime", "Pool Party"},
	  -- E 
	["Ekko"]         = {"Classic", "Sandstorm", "Academy"},
	["Elise"]        = {"Classic", "Death Blossom", "Victorious", "Blood Moon"},
	["Evelynn"]      = {"Classic", "Shadow", "Masquerade", "Tango", "Safecracker"},
	["Ezreal"]       = {"Classic", "Nottingham", "Striker", "Frosted", "Explorer", "Pulsefire", "TPA", "Debonair", "Ace of Spades"},
	  -- F 
	["FiddleSticks"] = {"Classic", "Spectral", "Union Jack", "Bandito", "Pumpkinhead", "Fiddle Me Timbers", "Surprise Party", "Dark Candy", "Risen"},
	["Fiora"]        = {"Classic", "Royal Guard", "Nightraven", "Headmistress", "PROJECT"},
	["Fizz"]         = {"Classic", "Atlantean", "Tundra", "Fisherman", "Void", "Chroma Pack: Orange", "Chroma Pack: Black", "Chroma Pack: Red", "Cottontail"},
	  -- G  
	["Galio"]        = {"Classic", "Enchanted", "Hextech", "Commando", "Gatekeeper", "Debonair"},
	["Gangplank"]    = {"Classic", "Spooky", "Minuteman", "Sailor", "Toy Soldier", "Special Forces", "Sultan", "Captain"},
	["Garen"]        = {"Classic", "Sanguine", "Desert Trooper", "Commando", "Dreadknight", "Rugged", "Steel Legion", "Chroma Pack: Garnet", "Chroma Pack: Plum", "Chroma Pack: Ivory", "Rogue Admiral"},
	["Gnar"]         = {"Classic", "Dino", "Gentleman"},
	["Gragas"]       = {"Classic", "Scuba", "Hillbilly", "Santa", "Gragas, Esq.", "Vandal", "Oktoberfest", "Superfan", "Fnatic", "Caskbreaker"},
	["Graves"]       = {"Classic", "Hired Gun", "Jailbreak", "Mafia", "Riot", "Pool Party", "Cutthroat"},
	  -- H 
	["Hecarim"]      = {"Classic", "Blood Knight", "Reaper", "Headless", "Arcade", "Elderwood"},
	["Heimerdinger"] = {"Classic", "Alien Invader", "Blast Zone", "Piltover Customs", "Snowmerdinger", "Hazmat"},
	  -- I 
	["Illaoi"]       = {"Classic", "Void Bringer"},
	["Irelia"]       = {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostblade", "Order of the Lotus"},
	  -- J 
	["Janna"]        = {"Classic", "Tempest", "Hextech", "Frost Queen", "Victorious", "Forecast", "Fnatic"},
	["JarvanIV"]     = {"Classic", "Commando", "Dragonslayer", "Darkforge", "Victorious", "Warring Kingdoms", "Fnatic"},
	["Jax"]          = {"Classic", "The Mighty", "Vandal", "Angler", "PAX", "Jaximus", "Temple", "Nemesis", "SKT T1", "Chroma Pack: Cream", "Chroma Pack: Amber", "Chroma Pack: Brick", "Warden"},
	["Jayce"]        = {"Classic", "Full Metal", "Debonair", "Forsaken"},
	["Jinx"]         = {"Classic", "Mafia", "Firecracker", "Slayer"},
	  -- K 
	["Kalista"]      = {"Classic", "Blood Moon", "Championship"},
	["Karma"]        = {"Classic", "Sun Goddess", "Sakura", "Traditional", "Order of the Lotus", "Warden"},
	["Karthus"]      = {"Classic", "Phantom", "Statue of", "Grim Reaper", "Pentakill", "Fnatic", "Chroma Pack: Burn", "Chroma Pack: Blight", "Chroma Pack: Frostbite"},
	["Kassadin"]     = {"Classic", "Festival", "Deep One", "Pre-Void", "Harbinger", "Cosmic Reaver"},
	["Katarina"]     = {"Classic", "Mercenary", "Red Card", "Bilgewater", "Kitty Cat", "High Command", "Sandstorm", "Slay Belle", "Warring Kingdoms"},
	["Kayle"]        = {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot"},
	["Kennen"]       = {"Classic", "Deadly", "Swamp Master", "Karate", "Kennen M.D.", "Arctic Ops"},
	["Khazix"]       = {"Classic", "Mecha", "Guardian of the Sands"},
	["Kindred"]      = {"Classic", "Shadowfire"},
	["KogMaw"]       = {"Classic", "Caterpillar", "Sonoran", "Monarch", "Reindeer", "Lion Dance", "Deep Sea", "Jurassic", "Battlecast"},
	  -- L 
	["Leblanc"]      = {"Classic", "Wicked", "Prestigious", "Mistletoe", "Ravenborn"},
	["LeeSin"]       = {"Classic", "Traditional", "Acolyte", "Dragon Fist", "Muay Thai", "Pool Party", "SKT T1", "Chroma Pack: Black", "Chroma Pack: Blue", "Chroma Pack: Yellow", "Knockout"},
	["Leona"]        = {"Classic", "Valkyrie", "Defender", "Iron Solari", "Pool Party", "Chroma Pack: Pink", "Chroma Pack: Azure", "Chroma Pack: Lemon", "PROJECT"},
	["Lissandra"]    = {"Classic", "Bloodstone", "Blade Queen"},
	["Lucian"]       = {"Classic", "Hired Gun", "Striker", "Chroma Pack: Yellow", "Chroma Pack: Red", "Chroma Pack: Blue", "PROJECT"},
	["Lulu"]         = {"Classic", "Bittersweet", "Wicked", "Dragon Trainer", "Winter Wonder", "Pool Party"},
	["Lux"]          = {"Classic", "Sorceress", "Spellthief", "Commando", "Imperial", "Steel Legion", "Star Guardian"},
	  -- M 
	["Malphite"]     = {"Classic", "Shamrock", "Coral Reef", "Marble", "Obsidian", "Glacial", "Mecha", "Ironside"},
	["Malzahar"]     = {"Classic", "Vizier", "Shadow Prince", "Djinn", "Overlord", "Snow Day"},
	["Maokai"]       = {"Classic", "Charred", "Totemic", "Festive", "Haunted", "Goalkeeper"},
	["MasterYi"]     = {"Classic", "Assassin", "Chosen", "Ionia", "Samurai Yi", "Headhunter", "Chroma Pack: Gold", "Chroma Pack: Aqua", "Chroma Pack: Crimson", "PROJECT"},
	["MissFortune"]  = {"Classic", "Cowgirl", "Waterloo", "Secret Agent", "Candy Cane", "Road Warrior", "Mafia", "Arcade", "Captain"},
	["Mordekaiser"]  = {"Classic", "Dragon Knight", "Infernal", "Pentakill", "Lord", "King of Clubs"},
	["Morgana"]      = {"Classic", "Exiled", "Sinful Succulence", "Blade Mistress", "Blackthorn", "Ghost Bride", "Victorious", "Chroma Pack: Toxic", "Chroma Pack: Pale", "Chroma Pack: Ebony","Lunar"},
	  -- N 
	["Nami"]         = {"Classic", "Koi", "River Spirit", "Urf", "Chroma Pack: Sunbeam", "Chroma Pack: Smoke", "Chroma Pack: Twilight"},
	["Nasus"]        = {"Classic", "Galactic", "Pharaoh", "Dreadknight", "Riot K-9", "Infernal", "Archduke", "Chroma Pack: Burn", "Chroma Pack: Blight", "Chroma Pack: Frostbite",},
	["Nautilus"]     = {"Classic", "Abyssal", "Subterranean", "AstroNautilus", "Warden"},
	["Nidalee"]      = {"Classic", "Snow Bunny", "Leopard", "French Maid", "Pharaoh", "Bewitching", "Headhunter", "Warring Kingdoms"},
	["Nocturne"]     = {"Classic", "Frozen Terror", "Void", "Ravager", "Haunting", "Eternum"},
	["Nunu"]         = {"Classic", "Sasquatch", "Workshop", "Grungy", "Nunu Bot", "Demolisher", "TPA", "Zombie"},
	  -- O 
	["Olaf"]         = {"Classic", "Forsaken", "Glacial", "Brolaf", "Pentakill", "Marauder"},
	["Orianna"]      = {"Classic", "Gothic", "Sewn Chaos", "Bladecraft", "TPA", "Winter Wonder"},
	  -- P 
	["Pantheon"]     = {"Classic", "Myrmidon", "Ruthless", "Perseus", "Full Metal", "Glaive Warrior", "Dragonslayer", "Slayer"},
	["Poppy"]        = {"Classic", "Noxus", "Lollipoppy", "Blacksmith", "Ragdoll", "Battle Regalia", "Scarlet Hammer"},
	  -- Q 
	["Quinn"]        = {"Classic", "Phoenix", "Woad Scout", "Corsair"},
	  -- R 
	["Rammus"]       = {"Classic", "King", "Chrome", "Molten", "Freljord", "Ninja", "Full Metal", "Guardian of the Sands"},
	["Reksai"]       = {"Classic", "Eternum", "Pool Party"},
	["Renekton"]     = {"Classic", "Galactic", "Outback", "Bloodfury", "Rune Wars", "Scorched Earth", "Pool Party", "Scorched Earth", "Prehistoric"},
	["Rengar"]       = {"Classic", "Headhunter", "Night Hunter", "SSW"},
	["Riven"]        = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"},
	["Rumble"]       = {"Classic", "Rumble in the Jungle", "Bilgerat", "Super Galaxy"},
	["Ryze"]         = {"Classic", "Human", "Tribal", "Uncle", "Triumphant", "Professor", "Zombie", "Dark Crystal", "Pirate", "Whitebeard"},
	  -- S 
	["Sejuani"]      = {"Classic", "Sabretusk", "Darkrider", "Traditional", "Bear Cavalry", "Poro Rider"},
	["Shaco"]        = {"Classic", "Mad Hatter", "Royal", "Nutcracko", "Workshop", "Asylum", "Masked", "Wild Card"},
	["Shen"]         = {"Classic", "Frozen", "Yellow Jacket", "Surgeon", "Blood Moon", "Warlord", "TPA"},
	["Shyvana"]      = {"Classic", "Ironscale", "Boneclaw", "Darkflame", "Ice Drake", "Championship"},
	["Singed"]       = {"Classic", "Riot Squad", "Hextech", "Surfer", "Mad Scientist", "Augmented", "Snow Day", "SSW"},
	["Sion"]         = {"Classic", "Hextech", "Barbarian", "Lumberjack", "Warmonger"},
	["Sivir"]        = {"Classic", "Warrior Princess", "Spectacular", "Huntress", "Bandit", "PAX", "Snowstorm", "Warden", "Victorious"},
	["Skarner"]      = {"Classic", "Sandscourge", "Earthrune", "Battlecast Alpha", "Guardian of the Sands"},
	["Sona"]         = {"Classic", "Muse", "Pentakill", "Silent Night", "Guqin", "Arcade", "DJ"},
	["Soraka"]       = {"Classic", "Dryad", "Divine", "Celestine", "Reaper", "Order of the Banana"},
	["Swain"]        = {"Classic", "Northern Front", "Bilgewater", "Tyrant"},
	["Syndra"]       = {"Classic", "Justicar", "Atlantean", "Queen of Diamonds"},
	  -- T 
	["TahmKench"]    = {"Classic", "Master Chef"},
	["Talon"]        = {"Classic", "Renegade", "Crimson Elite", "Dragonblade", "SSW"},
	["Taric"]        = {"Classic", "Emerald", "Armor of the Fifth Age", "Bloodstone"},
	["Teemo"]        = {"Classic", "Happy Elf", "Recon", "Badger", "Astronaut", "Cottontail", "Super", "Panda", "Omega Squad"},
	["Thresh"]       = {"Classic", "Deep Terror", "Championship", "Blood Moon", "SSW"},
	["Tristana"]     = {"Classic", "Riot Girl", "Earnest Elf", "Firefighter", "Guerilla", "Buccaneer", "Rocket Girl", "Chroma Pack: Navy", "Chroma Pack: Purple", "Chroma Pack: Orange", "Dragon Trainer"},
	["Trundle"]      = {"Classic", "Lil' Slugger", "Junkyard", "Traditional", "Constable"},
	["Tryndamere"]   = {"Classic", "Highland", "King", "Viking", "Demonblade", "Sultan", "Warring Kingdoms", "Nightmare"},
	["TwistedFate"]  = {"Classic", "PAX", "Jack of Hearts", "The Magnificent", "Tango", "High Noon", "Musketeer", "Underworld", "Red Card", "Cutpurse"},
	["Twitch"]       = {"Classic", "Kingpin", "Whistler Village", "Medieval", "Gangster", "Vandal", "Pickpocket", "SSW"},
	  -- U 
	["Udyr"]         = {"Classic", "Black Belt", "Primal", "Spirit Guard", "Definitely Not"},
	["Urgot"]        = {"Classic", "Giant Enemy Crabgot", "Butcher", "Battlecast"},
	  -- V 
	["Varus"]        = {"Classic", "Blight Crystal", "Arclight", "Arctic Ops", "Heartseeker", "Swiftbolt"},
	["Vayne"]        = {"Classic", "Vindicator", "Aristocrat", "Dragonslayer", "Heartseeker", "SKT T1", "Arclight", "Chroma Pack: Green", "Chroma Pack: Red", "Chroma Pack: Silver"},
	["Veigar"]       = {"Classic", "White Mage", "Curling", "Veigar Greybeard", "Leprechaun", "Baron Von", "Superb Villain", "Bad Santa", "Final Boss"},
	["Velkoz"]       = {"Classic", "Battlecast", "Arclight"},
	["Vi"]           = {"Classic", "Neon Strike", "Officer", "Debonair", "Demon"},
	["Viktor"]       = {"Classic", "Full Machine", "Prototype", "Creator"},
	["Vladimir"]     = {"Classic", "Count", "Marquis", "Nosferatu", "Vandal", "Blood Lord", "Soulstealer", "Academy"},
	["Volibear"]     = {"Classic", "Thunder Lord", "Northern Storm", "Runeguard", "Captain"},
	  -- W 
	["Warwick"]      = {"Classic", "Grey", "Urf the Manatee", "Big Bad", "Tundra Hunter", "Feral", "Firefang", "Hyena", "Marauder"},
	["MonkeyKing"]   = {"Classic", "Volcanic", "General", "Jade Dragon", "Underworld","Radiant"},
	  -- X 
	["Xerath"]       = {"Classic", "Runeborn", "Battlecast", "Scorched Earth", "Guardian of the Sands"},
	["XinZhao"]      = {"Classic", "Commando", "Imperial", "Viscero", "Winged Hussar", "Warring Kingdoms", "Secret Agent"},
	  -- Y 
	["Yasuo"]        = {"Classic", "High Noon", "PROJECT"},
	["Yorick"]       = {"Classic", "Undertaker", "Pentakill"},
	  -- Z 
	["Zac"]          = {"Classic", "Special Weapon", "Pool Party", "Chroma Pack: Orange", "Chroma Pack: Bubblegum", "Chroma Pack: Honey"},
	["Zed"]          = {"Classic", "Shockblade", "SKT T1", "PROJECT"},
	["Ziggs"]        = {"Classic", "Mad Scientist", "Major", "Pool Party", "Snow Day", "Master Arcanist"},
	["Zilean"]       = {"Classic", "Old Saint", "Groovy", "Shurima Desert", "Time Machine", "Blood Moon"},
	["Zyra"]         = {"Classic", "Wildfire", "Haunted", "SKT T1"},

}

function AutoBuy()
	if VIP_USER and GetGameTimer() < 60 then
		if Param.Misc.Starter.Doran then
			BuyItem(1055)
		end
		if Param.Misc.Starter.Pots then
			BuyItem(2003)
		end
		if Param.Misc.Starter.Trinket then
			BuyItem(3340)
		end
	end
end

--=======END========--
-- Developers: 
-- Divine (http://forum.botoflegends.com/user/86308-divine/)
-- PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
-- https://raw.githubusercontent.com/Nader-Sl/BoLStudio/master/Scripts/p_skinChanger.lua
--==================--

function AutoPotions()
	if not Param.Misc.Items.Pot then return end
		if os.clock() - lastPotion < ActualPotTime then return end
			for SLOT = ITEM_1, ITEM_6 do
				if myHero:GetSpellData(SLOT).name == "RegenerationPotion" then 
					ActualPotName = "Health Potion"
					ActualPotTime = 15
					ActualPotData = "RegenerationPotion"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemMiniRegenPotion" then
					ActualPotName = "Cookie"
					ActualPotTime = 15
					ActualPotData = "ItemMiniRegenPotion"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlaskJungle" then
					ActualPotName = "Hunter's Potion"
					ActualPotTime = 8
					ActualPotData = "ItemCrystalFlaskJungle"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemCrystalFlask" then
					ActualPotName = "Refillable Potion"
					ActualPotTime = 12
					ActualPotData = "ItemCrystalFlask"
					Usepot()
				elseif myHero:GetSpellData(SLOT).name == "ItemDarkCrystalFlask" then
					ActualPotName = "Corrupting Potion"
					ActualPotTime = 12
					ActualPotData = "ItemDarkCrystalFlask" 
					Usepot()
				else end
			end
		--
	--
end

function Usepot()
	for SLOT = ITEM_1, ITEM_6 do
		if myHero:GetSpellData(SLOT).name == ActualPotData then
			if myHero:CanUseSpell(SLOT) == READY and (myHero.health*100)/myHero.maxHealth < Param.Misc.Items.PotXHP then
				CastSpell(SLOT)
				lastPotion = os.clock()
				EnvoiMessage("1x "..ActualPotName.." => Used.")
			end
		end
	end
end

Items = {
		["QSS"]	        = { id = 3140, range = 2500, target = false},
		["MercScim"]	= { id = 3139, range = 2500, target = false},
}

function QSS()
	if os.clock() - lastRemove < 1 then return end
		for i, Item in pairs(Items) do
			if Item.id ==  3140 or Item.id == 3139 then
				lastRemove = os.clock()+90
				DelayAction(function()
					CastItem(Item.id)
				end, Param.Misc.Items.Qssdelay/1000)
			end
		--
	end
end

function Immune(unit)
    for i = 1, unit.buffCount do
        local tBuff = unit:getBuff(i)
        if BuffIsValid(tBuff) then
            if buffs[tBuff.name] then
                return true
            end
        end
    end
    return false
end
