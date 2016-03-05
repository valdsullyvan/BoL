--[[

Script by spyk for Malzahar.

=> BaguetteMalzahar.lua

- Github link : https://github.com/spyk1/BoL/blob/master/BaguetteMalzahar/BaguetteMalzahar.lua

- Forum Thread : http://forum.botoflegends.com/topic/89837-beta-baguette-malzahar/

]]--

local charNames = {
    
    ['Malzahar'] = true,
    ['malzahar'] = true
}

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
    ["bansheesveil"] = true,
    ["SivirE"] = true,
    ["NocturneW"] = true,
    ["kindredrnodeathbuff"] = true
}

if not charNames[myHero.charName] then return end

function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteMalzahar]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end

local Qdmg, Edmg, Rdmg, iDmg, totalDamage, health, mana, maxHealth, maxMana = 0 , 0, 0, 0, 0, 0, 0, 0, 0, 0
local TextList = {"Ignite = Kill","Q = Kill", "E = Kill", "Q + E = Kill", "Q + E + Ignite = Kill", "Q + E + Ignite + R = Kill", "Full Combo = Kill", "Not Killable"}
local KillText = {}
local mods = "None"
local damageQ = 30 * myHero:GetSpellData(_Q).level + 30 + .5 * myHero.ap
local damageW = 0.5 * myHero:GetSpellData(_W).level + 3.5 + 0.01 * myHero.ap
local damageE = 60 * myHero:GetSpellData(_E).level + 20 + 0.8 * myHero.ap
local damageR = 150 * myHero:GetSpellData(_R).level + 100 + 1.3 * myHero.ap
local AutoKillTimer = 0
local ultTimer = 0

--- Starting AutoUpdate
local version = "0.21"
local author = "spyk"
local SCRIPT_NAME = "BaguetteMalzahar"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteMalzahar/BaguetteMalzahar.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local whatsnew = 0

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteMalzahar/BaguetteMalzahar.version")
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
	--
	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteMalzahar]</b></font> <font color=\"#ffffff\">by spyk</font>")
	--
	if whatsnew == 1 then
		DelayAction(function() EnvoiMessage("What's new : Update with many things, read changelog.")end, 0)
		whatsnew = 0
	end
	--
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then Ignite = SUMMONER_2 end
	--
	Param = scriptConfig("[Baguette] Malzahar", "BaguetteMalzahar")
	--
	Param:addParam("n5", "Current Mode :", SCRIPT_PARAM_LIST, 1, {" None", " Combo", " Harass", " LaneClear", " WaveClear", " JungleClear", "AutoKill"})
		Param:permaShow("n5")
	--
	Param:addSubMenu("SBTW!","Combo")
			Param.Combo:addParam("Key", "Combo Key :", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseW", "Use (W) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseE", "Use (E) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseR", "Use (R) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		--
	Param:addSubMenu("Harass","Harass")
		Param.Harass:addParam("Key", "Harass Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Param.Harass:addParam("Auto", "Auto Harass (On toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("Y"))
		Param.Harass:addParam("Mana", "Required Mana to Harass :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.Harass:addParam("UseQ", "Use (Q) Spell in Harass?" , SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addParam("UseW", "Use (W) Spell in Harass?" , SCRIPT_PARAM_ONOFF, false)
		Param.Harass:addParam("UseE", "Use (E) Spell in Harass?" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("Clear","Clear")
		Param.Clear:addSubMenu("WaveClear", "WaveClear")
			Param.Clear.WaveClear:addParam("Key", "WaveClear Key :",SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			Param.Clear.WaveClear:addParam("Mana", "Required Mana to WaveClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
			Param.Clear.WaveClear:addParam("UseQ", "Use (Q) Spell in WaveClear?" , SCRIPT_PARAM_ONOFF, true)
			Param.Clear.WaveClear:addParam("UseW", "Use (W) Spell in WaveClear?" , SCRIPT_PARAM_ONOFF, true)
			Param.Clear.WaveClear:addParam("UseE", "Use (E) Spell in WaveClear?" , SCRIPT_PARAM_ONOFF, true)
		--
		Param.Clear:addSubMenu("JungleClear", "JungleClear")
			Param.Clear.JungleClear:addParam("Key", "JungleClear Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			Param.Clear.JungleClear:addParam("Mana", "Required Mana to JungleClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
			Param.Clear.JungleClear:addParam("UseQ", "Use (Q) Spell in JungleClear?" , SCRIPT_PARAM_ONOFF, true)
			Param.Clear.JungleClear:addParam("UseW", "Use (W) Spell in JungleClear?" , SCRIPT_PARAM_ONOFF, true)
			Param.Clear.JungleClear:addParam("UseE", "Use (E) Spell in JungleClear?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("KillSteal", "KillSteal")
		Param.KillSteal:addParam("Enable", "Enable KillSteal?" , SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseQ", "Use (Q) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseW", "Use (W) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseE", "Use (E) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseR", "Use (R) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Summoner Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true) end
	--
	Param:addSubMenu("Auto Kill", "AutoKill")
		Param.AutoKill:addParam("Key", "Enable the AutoKill?" , SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
		Param.AutoKill:addParam("UseQ", "Use (Q) Spell in AutoKill?", SCRIPT_PARAM_ONOFF, true)
		Param.AutoKill:addParam("UseW", "Use (W) Spell in AutoKill?", SCRIPT_PARAM_ONOFF, true)
		Param.AutoKill:addParam("UseE", "Use (E) Spell in AutoKill?", SCRIPT_PARAM_ONOFF, true)
		Param.AutoKill:addParam("UseR", "Use (R) Spell in AutoKill?", SCRIPT_PARAM_ONOFF, true)
		if Ignite then Param.AutoKill:addParam("UseIgnite", "Use (Ignite) Summoner Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true) end
		Param.AutoKill:addParam("n1", "", SCRIPT_PARAM_INFO, "")
		Param.AutoKill:addParam("n2", "Well, Be carefull, this mode should be activated only when you will kill someone. It's like combo mode.", SCRIPT_PARAM_INFO, "")
		Param.AutoKill:addParam("n3", "Don't use him everytime to get much powerness with the script. Like, only when you are running to an enemy to kill him.", SCRIPT_PARAM_INFO, "")

	--
	Param:addSubMenu("Miscellaneous", "miscellaneous")
	--
		if VIP_USER then Param.miscellaneous:addSubMenu("Auto LVL Spell :", "LVL") end
			if VIP_USER then Param.miscellaneous.LVL:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.miscellaneous.LVL:addParam("Combo", "LVL Spell Order :", SCRIPT_PARAM_LIST, 1, {"Q > E > E > W (Max E)"}) end
			if VIP_USER then Param.miscellaneous.LVL:setCallback("Combo", function (nV)
				if nV then
					AutoLvlSpellCombo()
				else 
					AutoLvlSpellCombo()
				end
			end)
			end
			if VIP_USER then Last_LevelSpell = 0 end
		--
		if VIP_USER then Param.miscellaneous:addSubMenu("Skin Changer", "Skin") end
			if VIP_USER then Param.miscellaneous.Skin:addParam("Enable", "Enable Skin Changer : ", SCRIPT_PARAM_ONOFF, false)
				Param.miscellaneous.Skin:setCallback("Enable", function (nV)
					if nV then
						SetSkin(myHero, Param.miscellaneous.Skin.skins -1)
					else
						SetSkin(myHero, -1)
					end
				end)
			end				
			if VIP_USER then Param.miscellaneous.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 1,  {"Classic", "Vizier", "Shadow Prince", "Djinn", "Overlord", "Snow Day"})
				Param.miscellaneous.Skin:setCallback("skins", function (nV)
					if nV then
						if Param.miscellaneous.Skin.Enable then
							SetSkin(myHero, Param.miscellaneous.Skin.skins -1)
						end
					end
				end)
			end
		--
		if VIP_USER then Param.miscellaneous:addSubMenu("Auto Buy Starter :", "Starter") end
			if VIP_USER then Param.miscellaneous.Starter:addParam("Doran", "Buy a doran blade :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.miscellaneous.Starter:addParam("Pots", "Buy a potion :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.miscellaneous.Starter:addParam("Trinket", "Buy a Green Trinket :", SCRIPT_PARAM_ONOFF, true) end
			if VIP_USER then Param.miscellaneous.Starter:addParam("n1blank", "", SCRIPT_PARAM_INFO, "") end
			if VIP_USER then Param.miscellaneous.Starter:addParam("TrinketBleu", "Buy a Blue Trinket at lvl.9 :", SCRIPT_PARAM_ONOFF, true) end
		--
		Param.miscellaneous:addSubMenu("GapCloser", "GapCloser")
			Param.miscellaneous.GapCloser:addParam("Enable", "Enable GapCloser with R?", SCRIPT_PARAM_ONOFF, true)
			Param.miscellaneous.GapCloser:addParam("UseW", "Use (W) Spell in GapCloser?", SCRIPT_PARAM_ONOFF, true)
			Param.miscellaneous.GapCloser:addParam("UseE", "Use (E) Spell in GapCloser?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("Drawing", "draw")
		Param.draw:addParam("disable","Disable all draws?", SCRIPT_PARAM_ONOFF, false)
		Param.draw:addParam("tText", "Draw Current Target Text?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("drawKillable", "Draw Killable Text?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("drawDamage", "Draw Damage?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("hitbox", "Draw HitBox?", SCRIPT_PARAM_ONOFF, true)
		--
		Param.draw:addSubMenu("Charactere Draws","spell")
			Param.draw.spell:addParam("Qdraw","Display (Q) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("Wdraw","Display (W) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("Edraw","Display (E) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("PoisonDraw","Display (E) Damages prediction draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("Rdraw","Display (R) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("AAdraw", "Display Auto Attack draw?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("", "nil")
	--
	Param:addSubMenu("OrbWalker", "orbwalker")
		Param.orbwalker:addParam("n1", "OrbWalker :", SCRIPT_PARAM_LIST, 1, {"SxOrbWalk","BigFat OrbWalker", "Nebelwolfi's Orb Walker"})
		Param.orbwalker:addParam("n2", "If you want to change OrbWalker,", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n4", "", SCRIPT_PARAM_INFO, "")
		Param.orbwalker:addParam("n5", "SAC:R is automaticly loaded(enable in BoLStudio)", SCRIPT_PARAM_INFO, "")
	--
	Param:addSubMenu("", "nil")
	--
	Param:addSubMenu("Prediction", "prediction")
		Param.prediction:addParam("n1", "Prediction :", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction", "SPrediction"})
		Param.prediction:addParam("n2", "If you want to change Prediction,", SCRIPT_PARAM_INFO, "")
		Param.prediction:addParam("n3", "Then, change it and press double F9.", SCRIPT_PARAM_INFO, "")
		Param.prediction:addParam("nil", "", SCRIPT_PARAM_INFO, "")
		Param.prediction:addParam("n4", "Basicly, the best way is VPrediction.", SCRIPT_PARAM_INFO, "")
		Param.prediction:addParam("n5", "Only if you like another prediction,", SCRIPT_PARAM_INFO, "")
		Param.prediction:addParam("n6", "then, I agree Keepo", SCRIPT_PARAM_INFO, "")
	
	Param:addSubMenu("", "nil")
	--
	Param:addParam("n4", "Baguette Malzahar | Version", SCRIPT_PARAM_INFO, ""..version.."")
	Param:permaShow("n4")

	CustomLoad()
end

function OnUnload()
	EnvoiMessage("Unloaded.")
	EnvoiMessage("There is no void anymore between us... Ciao!")
	if Param.miscellaneous.Skin.Enable then
		SetSkin(myHero, -1)
	end
end

function CustomLoad()

	LoadSpikeLib()

	if VIP_USER then
		AutoLvlSpellCombo()
	end

	DelayAction(function()AutoBuy()end, 3)

	PredictionOrbWalkSwitch()
	Skills()
	enemyMinions = minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 700, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Malzahar"
	Param:addTS(ts)
	PriorityOnLoad()

	if Param.miscellaneous.Skin.Enable then
		SetSkin(myHero, Param.miscellaneous.Skin.skins -1)
	end
end

function PredictionOrbWalkSwitch()
	if Param.prediction.n1 == 1 then
		EnvoiMessage("VPrediction loading..")
		LoadVPred()
	elseif Param.prediction.n1 == 2 then
		EnvoiMessage("HPrediction loading..")
		LoadHPred()
	elseif Param.prediction.n1 == 3 then
		EnvoiMessage("SPrediction loading..")
		LoadSPred()
	else
		EnvoiMessage("No prediction loaded.")
	end

	if Param.prediction.n1 == 1 then Param.Combo:addParam("HitChance", "Set (Q) HitChance" , SCRIPT_PARAM_SLICE, 2, 1, 5) end
	if Param.prediction.n1 == 2 then Param.Combo:addParam("HitChance", "Set (Q) HitChance" , SCRIPT_PARAM_SLICE, 0, 0, 3) end
	if Param.prediction.n1 == 3 then Param.Combo:addParam("HitChance", "Set (Q) HitChance" , SCRIPT_PARAM_SLICE, 1, 0, 3) end

	if Param.prediction.n1 == 1 then Param.Harass:addParam("HitChance", "Set (Q) HitChance" , SCRIPT_PARAM_SLICE, 2, 1, 5) end
	if Param.prediction.n1 == 2 then Param.Harass:addParam("HitChance", "Set (Q) HitChance" , SCRIPT_PARAM_SLICE, 0, 0, 3) end
	if Param.prediction.n1 == 3 then Param.Harass:addParam("HitChance", "Set (Q) HitChance" , SCRIPT_PARAM_SLICE, 1, 0, 3) end

	if _G.Reborn_Loaded ~= nil then
   		LoadSACR()
   	elseif _Pewalk then
   		LoadPewalk()
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
end

function LoadSpikeLib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.github.com"
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000)
		DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		DelayAction(function () require("SpikeLib") end, 5)
	else
		require("SpikeLib")
		DelayAction(function ()EnvoiMessage("Loaded Libraries with success!") end, 3)
	end
end

function LoadPewalk()
	if _Pewalk then
		EnvoiMessage("Loaded Pewalk")
		DelayAction(function ()EnvoiMessage("[Pewalk] Disable every spell usage in Pewalk for better performances with my script.")end, 7)
	elseif not _Pewalk then
		EnvoiMessage("Pewalk loading error")
	end
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

function LoadHPred()
	if FileExist(LIB_PATH .. "/HPrediction.lua") then
		require("HPrediction")
		EnvoiMessage("Succesfully loaded HPred")
		HPred = HPrediction()
		HP_Q = HPSkillshot({type = "DelayLine", delay = 0.250, range = 900, width = 400, speed = 850})
		UseHP = true
	else
		local ToUpdate = {}
		ToUpdate.Version = 3
		ToUpdate.UseHttps = true
		ToUpdate.Name = "HPrediction"
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/BolHTTF/BoL/master/HTTF/Common/HPrediction.version"
		ToUpdate.ScriptPath =  "/BolHTTF/BoL/master/HTTF/Common/HPrediction.lua"
		ToUpdate.SavePath = LIB_PATH.."/HPrediction.lua"
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
		ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
		ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
		ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
		ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
end

function LoadSPred()
	if FileExist(LIB_PATH .. "/SPrediction.lua") then
		require("SPrediction")
		EnvoiMessage("Succesfully loaded SPred")
		SP = SPrediction()
	else
		local ToUpdate = {}
		ToUpdate.Version = 3
		ToUpdate.UseHttps = true
		ToUpdate.Name = "SPrediction"
		ToUpdate.Host = "raw.githubusercontent.com"
		ToUpdate.VersionPath = "/nebelwolfi/BoL/master/Common/SPrediction.version"
		ToUpdate.ScriptPath =  "/nebelwolfi/BoL/master/Common/SPrediction.lua"
		ToUpdate.SavePath = LIB_PATH.."/SPrediction.lua"
		ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
		ToUpdate.CallbackNoUpdate = function(OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
		ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
		ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
		ScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
	end
end

function OnTick()
	if myHero.dead then return end
	if ultTimer > CurrentTimeInMillis() then return end
		ts:update()
		target = GetCustomTarget()
		Misc()
		KillSteal()
end

function Combo(unit)
	if ultTimer > CurrentTimeInMillis() then return end
		if target ~= nil and target.type == myHero.type and not Immune(unit) then
			if myHero:CanUseSpell(_Q) == READY and Param.Combo.UseQ then
				LogicQ(unit)
			elseif myHero:CanUseSpell(_E) == READY and Param.Combo.UseE then
				LogicE(unit)
			elseif myHero:CanUseSpell(_W) == READY and Param.Combo.UseW then
				LogicW(unit)
			elseif myHero:CanUseSpell(_R) == READY and Param.Combo.UseR then
				LogicR(unit)
			end
		end
	--
end

function Harass()
	if ultTimer > CurrentTimeInMillis() then return end
	ts:update()
	if ValidTarget(target) and target ~= nil and target.type == myHero.type then
		if(myHero:CanUseSpell(_Q) == READY and (myHero.mana / myHero.maxMana > Param.Harass.Mana /100 ) and ts.target ~= nil and Param.Harass.UseQ ) then 
	  		LogicQ(target)
		end
		if(myHero:CanUseSpell(_W) == READY and (myHero.mana / myHero.maxMana > Param.Harass.Mana /100 ) and ts.target ~= nil and Param.Harass.UseW ) then 
	 		LogicW(target)
		end
		if(myHero:CanUseSpell(_E) == READY and (myHero.mana / myHero.maxMana > Param.Harass.Mana /100) and ts.target ~= nil and Param.Harass.UseE ) then
			LogicE(target)
		end
	end
end

function AutoKill()
	if ultTimer > CurrentTimeInMillis() then return end
		for _, unit in pairs(GetEnemyHeroes()) do
			if GetDistance(unit) < 600 and Param.AutoKill.Key and not unit.dead then
				health = unit.health
				Qdmg = ((myHero:CanUseSpell(_Q) == READY and damageQ) or 0)
				Wdmg = ((myHero:CanUseSpell(_Q) == READY and unit.maxHealth * damageW / 100) or 0)
				Edmg = ((myHero:CanUseSpell(_E) == READY and damageE) or 0)
				Rdmg = ((myHero:CanUseSpell(_R) == READY and damageR) or 0)
				TotalDMG = Qdmg + Wdmg*3 + Edmg + Rdmg
				if myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_W) == READY and myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_R) == READY and health < TotalDMG then
					AutoKillTimer = 1
				end
				if AutoKillTimer == 1 then
					if myHero:CanUseSpell(_Q) == READY and Param.AutoKill.UseQ then
						LogicQ(unit)
					elseif myHero:CanUseSpell(_E) == READY and Param.AutoKill.UseE then
						LogicE(unit)
					elseif Ignite and myHero:CanUseSpell(Ignite) == READY and Param.AutoKill.UseIgnite then
						CastSpell(Ignite, unit)
					elseif myHero:CanUseSpell(_W) == READY and Param.AutoKill.UseW then
						LogicW(unit)
					elseif myHero:CanUseSpell(_R) == READY and Param.AutoKill.UseR then
						LogicR(unit)
					else 
						AutoKillTimer = 0
					end
				end
			end
		end
	--
end

function WaveClear()
	if ultTimer > CurrentTimeInMillis() then return end
	enemyMinions:update()
	local canonheal = ((CurrentTimeInMillis()/6000)+700)
	if not ManaWaveClear() then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and (minion.maxHealth >= canonheal) then
				if GetDistance(minion) <= SkillE.range and myHero:CanUseSpell(_E) == READY and (minion.maxHealth >= canonheal) and Param.Clear.WaveClear.UseE then
					CastSpell(_E, minion)
				elseif GetDistance(minion) <= SkillW.range and myHero:CanUseSpell(_W) == READY and (minion.maxHealth >= canonheal) and Param.Clear.WaveClear.UseW then
					CastSpell(_W, minion.x, minion.z)
				elseif GetDistance(minion) <= SkillQ.range and myHero:CanUseSpell(_Q) == READY and (minion.maxHealth >= canonheal) and Param.Clear.WaveClear.UseQ then
					CastSpell(_Q, minion.x, minion.z)
				end 
			elseif ValidTarget(minion) and minion ~= nil then
				if Param.Clear.WaveClear.UseE and GetDistance(minion) <= SkillE.range and myHero:CanUseSpell(_E) == READY then
					CastSpell(_E, minion)
				elseif Param.Clear.WaveClear.UseW and GetDistance(minion) <= SkillW.range and myHero:CanUseSpell(_W) == READY then
					CastSpell(_W, minion.x, minion.z)
				elseif Param.Clear.WaveClear.UseQ and GetDistance(minion) <= SkillQ.range and myHero:CanUseSpell(_Q) == READY then
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
	end
end

function ManaWaveClear()
    if myHero.mana < (myHero.maxMana * ( Param.Clear.WaveClear.Mana / 100)) then
        return true
    else
        return false
    end
end

function ManaHarass()
    if myHero.mana < (myHero.maxMana * ( Param.Harass.Mana / 100)) then
        return true
    else
        return false
    end
end

function ManaJungleClear()
    if myHero.mana < (myHero.maxMana * ( Param.Clear.JungleClear.Mana / 100)) then
        return true
    else
        return false
    end
end

function JungleClear()
	if ultTimer > CurrentTimeInMillis() then return end
	jungleMinions:update()
		if not ManaJungleClear() then
			for i, jungleMinion in pairs(jungleMinions.objects) do
				if jungleMinion ~= nil then
					if Param.Clear.JungleClear.UseE and GetDistance(jungleMinion) <= SkillE.range and myHero:CanUseSpell(_E) == READY then
						CastSpell(_E, jungleMinion)
					elseif Param.Clear.JungleClear.UseW and GetDistance(jungleMinion) <= SkillW.range and myHero:CanUseSpell(_W) == READY then 
						CastSpell(_W, jungleMinion.x, jungleMinion.z)
					elseif Param.Clear.JungleClear.UseQ and GetDistance(jungleMinion) <= SkillQ.range and myHero:CanUseSpell(_Q) == READY then
						CastSpell(_Q, jungleMinion.x, jungleMinion.z)
					end
				end
			end
		end
	--
end

function KillSteal()
	if ultTimer > CurrentTimeInMillis() then return end
		for _, unit in pairs(GetEnemyHeroes()) do
			if GetDistance(unit) < 900 and Param.KillSteal.Enable and not unit.dead then
				health = unit.health
				Qdmg = ((30 * myHero:GetSpellData(_Q).level + 30 + .5 * myHero.ap) or 0)
				Wdmg = ((0.5 * myHero:GetSpellData(_W).level + 3.5 + 0.01 * myHero.ap) or 0)
				Edmg = ((60 * myHero:GetSpellData(_E).level + 20 + 0.8 * myHero.ap) or 0)
				Rdmg = ((150 * myHero:GetSpellData(_R).level + 100 + 1.3 * myHero.ap) or 0)
				if myHero:CanUseSpell(_Q) == READY and health < myHero:CalcMagicDamage(unit, Qdmg) and Param.KillSteal.UseQ and GetDistance(unit) < SkillQ.range then
					LogicQ(unit)
				elseif myHero:CanUseSpell(_W) == READY and health < (unit.maxHealth * Wdmg / 100) * 2 and Param.KillSteal.UseW and GetDistance(unit) < SkillW.range then
					LogicW(unit)
				elseif myHero:CanUseSpell(_E) == READY and health < myHero:CalcMagicDamage(unit, Edmg) and Param.KillSteal.UseE and GetDistance(unit) < SkillE.range then
					LogicE(unit)
				elseif myHero:CanUseSpell(_R) == READY and health < myHero:CalcMagicDamage(unit, Rdmg) and Param.KillSteal.UseR and GetDistance(unit) < SkillR.range then
					LogicR(unit)
				elseif Ignite and myHero:CanUseSpell(Ignite) == READY and health < (50 + 20 * myHero.level) and Param.KillSteal.UseIgnite and ValidTarget(unit, 600) then
					CastSpell(Ignite, unit)
				end
			end
		end
	--
end

function OnDraw()
	if not myHero.dead and not Param.draw.disable then
		if myHero:CanUseSpell(_Q) == READY and Param.draw.spell.Qdraw then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillQ.range, 1, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_W) == READY and Param.draw.spell.Wdraw then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillW.range, 1, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_E) == READY and Param.draw.spell.Edraw then 
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillE.range, 1, 0xFFFFFFFF)
		end
		if myHero:CanUseSpell(_R) == READY and Param.draw.spell.Rdraw then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, SkillR.range, 1, 0xFFFFFFFF)
		end
		if Param.draw.spell.AAdraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range, 0xFFFFFFFF)
		end
		if Param.draw.hitbox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
		end
		if target ~= nil and ValidTarget(target) then
			if Param.draw.tText then
				DrawText3D("ACTUAL BITCH",target.x-100, target.y-50, target.z, 20, 0xFFFFFFFF) -- Acknowledgments to http://forum.botoflegends.com/user/25371-big-fat-corki/ and his Mark IV script for giving me the idea of the target name.
			end
		end
		if Param.draw.drawKillable then
			for i = 1, heroManager.iCount do
				local enemy = heroManager:getHero(i)
				if enemy and ValidTarget(enemy) then
					local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					local PosX = barPos.x - 35
					local PosY = barPos.y - 50
					DrawText(TextList[KillText[i]], 15, PosX, PosY, ARGB(255,255,204,0))
				end 
			end 
		end 
		if Param.draw.drawDamage then 
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if enemy and ValidTarget(enemy) then
					DrawIndicator(enemy)
				end
			end
		end
		if Param.draw.spell.PoisonDraw then 
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and GetDistance(unit) < 3000 then
					local Center = GetUnitHPBarPos(unit)
					local Qdmg, Edmg, Rdmg = CalcSpellDamage(enemy)
					Edmg = ((myHero:CanUseSpell(_E) == READY and damageE) or 0)
					local Y3QER = math.floor(myHero:CalcDamage(unit,Edmg))
					if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
						local off = GetUnitHPBarOffset(unit)
						local y=Center.y + (off.y * 53) + 2
						local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName]
						local x = Center.x + ((xOff or 0) * 140) - 66
						if not TargetHaveBuff("SummonerExhaust", myHero) then
							dmg = unit.health - Y3QER
						elseif TargetHaveBuff("SummonerExhaust", myHero) then
							dmg = unit.health - (Y3QER-((Y3QER*40)/100))
						end
						DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF)
					end
				end
			end
		end
	end
end

function CalcSpellDamage(enemy)
	if not enemy then return end 
		return ((myHero:GetSpellData(_Q).level >= 1 and myHero:CalcMagicDamage(enemy, damageQ)) or 0), ((myHero:GetSpellData(_E).level >= 1 and myHero:CalcMagicDamage(enemy, damageE)) or 0), ((myHero:GetSpellData(_Q).level >= 1 and myHero:CalcMagicDamage(enemy, damageR)) or 0)
	end 
	for i, enemy in ipairs(GetEnemyHeroes()) do
    	enemy.barData = {PercentageOffset = {x = 0, y = 0} }
	end

function GetEnemyHPBarPos(enemy)
    if not enemy.barData then return end
    local barPos = GetUnitHPBarPos(enemy)
    local barPosOffset = GetUnitHPBarOffset(enemy)
    local barOffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)
    local barPosPercentageOffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)
    local BarPosOffsetX = 169
    local BarPosOffsetY = 47
    local CorrectionX = 16
    local CorrectionY = 4
    barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + CorrectionX
    barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY 
    local StartPos = Point(barPos.x, barPos.y)
    local EndPos = Point(barPos.x + 103, barPos.y)
    return Point(StartPos.x, StartPos.y), Point(EndPos.x, EndPos.y)
end

function DrawIndicator(enemy)
	local Qdmg, Edmg, Rdmg = CalcSpellDamage(enemy)
	Qdmg = ((myHero:CanUseSpell(_Q) == READY and damageQ) or 0)
	Wdmg = ((0.5 * myHero:GetSpellData(_W).level + 3.5 + 0.01 * myHero.ap) or 0)
	Edmg = ((myHero:CanUseSpell(_E) == READY and damageE) or 0)
	Rdmg = ((myHero:CanUseSpell(_R) == READY and damageR) or 0)
    local damage = Qdmg + Edmg + Rdmg + (Wdmg * 2.5)
    local SPos, EPos = GetEnemyHPBarPos(enemy)
    if not SPos then return end
    local barwidth = EPos.x - SPos.x
    local Position = SPos.x + math.max(0, (enemy.health - damage) / enemy.maxHealth * barwidth)
    DrawText(" | ", 16, math.floor(Position), math.floor(SPos.y + 8), ARGB(255,0,255,0))
    DrawText("HP: "..math.floor(enemy.health - damage), 12, math.floor(SPos.x + 25), math.floor(SPos.y - 15), (enemy.health - damage) > 0 and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 0, 0))
end
 
function DrawKillable()
	for i = 1, heroManager.iCount, 1 do
		local enemy = heroManager:getHero(i)
		if enemy and ValidTarget(enemy) then
			if enemy.team ~= myHero.team then
				if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") or myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
					if (myHero:CanUseSpell(Ignite) == READY) then
						iDmg = 40 + (20 * myHero.level)
					elseif (myHero:CanUseSpell(Ignite) ~= READY) then
						iDmg = 0
					end
				end
				local Qdmg, Edmg, Rdmg = CalcSpellDamage(enemy)
				Qdmg = ((myHero:CanUseSpell(_Q) == READY and damageQ) or 0)
				Wdmg = ((0.5 * myHero:GetSpellData(_W).level + 3.5 + 0.01 * myHero.ap) or 0)
				Edmg = ((myHero:CanUseSpell(_E) == READY and damageE) or 0)
				Rdmg = ((myHero:CanUseSpell(_R) == READY and damageR) or 0)
				if iDmg > enemy.health then
					KillText[i] = 1
				elseif Qdmg > enemy.health then
					KillText[i] = 2
				elseif Edmg > enemy.health then
					KillText[i] = 3
				elseif Qdmg + Edmg > enemy.health then
					KillText[i] = 4
				elseif Qdmg + Edmg + iDmg > enemy.health then
					KillText[i] = 5
				elseif Qdmg + Edmg + iDmg + Rdmg > enemy.health then
					KillText[i] = 6
				elseif Qdmg + Edmg + iDmg + Rdmg + (((enemy.maxHealth * Wdmg) / 100)*2.5) > enemy.health then
					KillText[i] = 7
				else
					KillText[i] = 8
				end
			end 
		end 
	end 
end

function Skills()
	SkillQ = { name = "AlZaharCalloftheVoid", range = 1000, delay = 1, speed = math.huge, width = 400, ready = false }
	SkillW = { name = "AlZaharNullZone", range = 800, delay = 0, speed = math.huge, width = 350, ready = false }
	SkillE = { name = "AlZaharMaleficVisions", range = 650, delay = 0.25, speed = math.huge, width = nil, ready = false }
	SkillR = { name = "AlZaharNetherGrasp", range = 700, delay = 0.1, speed = math.huge, width = 350, ready = false }
end

function LogicQ(unit)
	if ultTimer > CurrentTimeInMillis() then return end
	if target ~= nil and GetDistance(target) <= SkillQ.range and myHero:CanUseSpell(_Q) == READY and not target.dead then
		if ComboKey or HarassKey then
			if ComboKey then
				ChanceHit = Param.Combo.HitChance
			elseif HarassKey then
				ChanceHit = Param.Harass.HitChance
			end
		else 
			if Param.prediction.n1 == 1 then
				ChanceHit = 2
			elseif Param.prediction.n1 == 2 then
				ChanceHit = 0
			elseif Param.prediction.n1 == 3 then
				ChanceHit = 1
			end
		end
		if Param.prediction.n1 == 1 then
			CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, false)
			if HitChance >= ChanceHit then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		elseif Param.prediction.n1 == 2 then
			local CastPosition, HitChance = HPred:GetPredict(HP_Q, target, myHero)
			if HitChance > ChanceHit then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		elseif Param.prediction.n1 == 3 then
			CastPosition, HitChance, PredPos = SP:Predict(target, SkillQ.range, SkillQ.speed, SkillQ.delay, SkillQ.width, false, myHero)
			if HitChance >= ChanceHit then
				CastSpell(_Q, target)
			end
		end
	end
end

function LogicW()
	if ultTimer > CurrentTimeInMillis() then return end
	if target ~= nil and GetDistance(target) <= SkillW.range and myHero:CanUseSpell(_W) == READY and not target.dead then
		if Param.prediction.n1 == 1 then
			CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, false)
			if HitChance >= 2 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end
		elseif Param.prediction.n1 == 2 then
			local CastPosition, HitChance = HPred:GetPredict(HP_R, target, myHero)
			if HitChance > 0 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end
		elseif Param.prediction.n1 == 3 then
			CastPosition, HitChance, PredPos = SP:Predict(target, SkillW.range, SkillW.speed, SkillW.delay, SkillW.width, false, myHero)
			if HitChance >= 0 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function LogicE()
	if ultTimer > CurrentTimeInMillis() then return end
	if myHero:CanUseSpell(_E) == READY and GetDistance(target) < SkillE.range and not target.dead then
		CastSpell(_E, target)
	end
end

function LogicR()
	if ultTimer > CurrentTimeInMillis() then return end
	if myHero:CanUseSpell(_R) == READY and GetDistance(target) < SkillR.range and target.health > 250 and not target.dead then
		ultTimer = CurrentTimeInMillis() + 2800
		DisableOrbwalker()
		DelayAction(function()
			CastSpell(_R, target)
		end, 0.001)
		DelayAction(function()
			EnableOrbwalker()
		end, 2.8)
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

function Misc()
	KeyPermaShow()
	DrawKillable()
	AutoLvlSpell()
end

function KeyPermaShow()
	if ultTimer > CurrentTimeInMillis() then return end
	ComboKey = Param.Combo.Key
	HarassKey = Param.Harass.Key or Param.Harass.Auto
	AutoKillKey = Param.AutoKill.Key
	JungleClearKey = Param.Clear.JungleClear.Key
	WaveClearKey = Param.Clear.WaveClear.Key


	if ComboKey then 
		Combo(Target)
		Param.n5 = 2
	elseif not ComboKey then
		if AutoKillKey then
			AutoKill()
			Param.n5 = 7
		end
		if HarassKey then
			Harass(Target)
			Param.n5 = 3
		end
		if WaveClearKey then
			WaveClear()
			Param.n5 = 5
		end
		if JungleClearKey then
			JungleClear()
			Param.n5 = 6
		end
	end
	if Param.n5 ~= 1 and not ComboKey and not HarassKey and not AutoKillKey and not JungleClearKey and not WaveClearKey then
		Param.n5 = 1
	end
end

local priorityTable = {
 
    AP_Carry = {
        "Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
        "Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi", "VelKoz", "Azir", "Ekko",
    },
    Support = {
        "Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum", "Bard", "TahmKench",
    },
 
    Tank = {
        "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
        "Warwick", "Yorick", "Zac", "Illaoi", "RekSai",
    },
 
    AD_Carry = {
        "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
        "Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed", "Lucian", "Jinx",
 
    },
 
    Bruiser = {
        "Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
        "Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Gnar", "Kindred"
    },
 
}

function SetPriority(table, hero, priority)
    for i=1, #table, 1 do
    	if hero.charName:find(table[i]) ~= nil then
        	TS_SetHeroPriority(priority, hero.charName)
        end
    end
end

function arrangePrioritys()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        SetPriority(priorityTable.AD_Carry, enemy, 1)
        SetPriority(priorityTable.AP_Carry, enemy, 2)
        SetPriority(priorityTable.Support,  enemy, 3)
        SetPriority(priorityTable.Bruiser,  enemy, 4)
        SetPriority(priorityTable.Tank,     enemy, 5)
    end
end
 
function PriorityOnLoad()
        if heroManager.iCount < 10 then
			EnvoiMessage("Impossible to Arrange Priority Table.. There is not enough champions... (less than 10)")	
        else
            arrangePrioritys()
        end
end

function AutoBuy()
	if VIP_USER and GetGameTimer() < 60 then
		if Param.miscellaneous.Starter.Doran then
			BuyItem(1056)
		end
		if Param.miscellaneous.Starter.Pots then
			BuyItem(2003)
		end
		if Param.miscellaneous.Starter.Pots then
			BuyItem(2003)
		end
		if Param.miscellaneous.Starter.Trinket then
			BuyItem(3340)
		end
	end
end

function AutoLvlSpell()
	if (string.find(GetGameVersion(), 'Releases/6.4') ~= nil) then
	 	if VIP_USER and os.clock()-Last_LevelSpell > 0.5 then
	 		if Param.miscellaneous.LVL.Enable then
		    	autoLevelSetSequence(levelSequence)
		    	Last_LevelSpell = os.clock()
		    elseif not Param.miscellaneous.LVL.Enable then
		    	autoLevelSetSequence(nil)
		    	Last_LevelSpell = os.clock()+10
		    end
	  	end
	else
		do return end
	end
end

function AutoLvlSpellCombo()
	if Param.miscellaneous.LVL.Combo == 1 then
		levelSequence =  { 1,3,3,2,3,4,3,1,3,1,4,1,1,2,2,4,2,2}
	end
end

function EnableOrbwalker()
	if _G.AutoCarry then
		_G.AutoCarry.MyHero:MovementEnabled(true)
		_G.AutoCarry.MyHero:AttacksEnabled(true)
	elseif Param.prediction.n1 == 3 then
		_G.NebelwolfisOrbWalker:SetOrb(true)
	elseif Param.prediction.n1 == 1 then
		SxOrb:EnableMove()
		SxOrb:EnableAttacks()
	elseif Param.prediction.n1 == 2 then
		_G["BigFatOrb_DisableMove"] = false
		_G["BigFatOrb_DisableAttacks"] = false
	end
end

function DisableOrbwalker()
	if _G.AutoCarry then
		_G.AutoCarry.MyHero:AttacksEnabled(false)
		_G.AutoCarry.MyHero:MovementEnabled(false)
	elseif Param.prediction.n1 == 3 then
		_G.NebelwolfisOrbWalker:SetOrb(false)
	elseif Param.prediction.n1 == 1 then
		SxOrb:DisableAttacks()
		SxOrb:DisableMove()
	elseif Param.prediction.n1 == 2 then
		_G["BigFatOrb_DisableMove"] = true
		_G["BigFatOrb_DisableAttacks"] = true
	end
end

isAGapcloserToDo = {
	['KatarinaR'] = {true, Champ = 'Katarina',	spellKey = 'R'},
	['MissFortuneBulletTime'] = {true, Champ = 'MissFortune',	spellKey = 'R'},
	['LucianR']	= {true, Champ = 'Lucian',	spellKey = 'R'},
	['GalioIdolOfDurand'] = {true, Champ = 'Galio',	spellKey = 'R'},
	['UFSlash']	= {true, Champ = 'Malphite', range = 1000, projSpeed = 1800, spellKey = 'R'},
	['YasuoDashWrapper'] = {true, Champ = 'Yasuo',	spellKey = 'E'},
	['RengarLeap'] = {true, Champ = 'Rengar',	spellKey = 'Q/R'},
	['InfiniteDuress'] = {true, Champ = 'Warwick',	spellKey = 'R'},
	['AlZaharNetherGrasp'] = {true, Champ = 'Malzahar',	spellKey = 'R'},
	['MonkeyKingSpinToWin'] = {true, Champ = 'MonkeyKing', spellKey = 'R'},
	['Crowstorm'] = {true, Champ = 'FiddleSticks',spellKey = 'R'},
	['UrgotSwap2']	= {true, Champ = 'Urgot',	spellKey = 'R'},
	['ZedR'] = {true, Champ = 'Zed', spellKey = 'R'},
	['GravesMove']	= {true, Champ = 'Graves', 	range = 425, projSpeed = 2000, spellKey = 'E'},
	['LucianR']	= {true, Champ = 'Lucian',	spellKey = 'R'},
	['KhazixE']	= {true, Champ = 'Khazix', 	range = 900, projSpeed = 2000, spellKey = 'E'},
	['khazixelong']	= {true, Champ = 'Khazix', 	range = 900, projSpeed = 2000, spellKey = 'E'},
	['LeblancSlide']	= {true, Champ = 'Leblanc', range = 600, projSpeed = 2000, spellKey = 'W'},
	['LeblancSlideM']	= {true, Champ = 'Leblanc', range = 600, projSpeed = 2000, spellKey = 'WMimic'},
	['RocketJump']	= {true, Champ = 'Tristana', range = 900,  	projSpeed = 2000, spellKey = 'W'},
	['DianaTeleport'] = {true, Champ = 'Diana', spellKey = 'R'}
}

function OnProcessSpell(unit, spell)
	if Param.miscellaneous.GapCloser.Enable then
		if unit.team ~= myHero.team and myHero:CanUseSpell(_R) == READY then
			if isAGapcloserToDo[spell.name] and unit.health < 2300 then
				if spell.name ==  "ZedR" and spell.target and spell.target.networkID == myHero.networkID then
					if myHero:CanUseSpell(_W) == READY and Param.miscellaneous.GapCloser.UseW then
						CastSpell(_W, myHero.x, myHero.z)
					end
					if myHero:CanUseSpell(_Q) == READY then
						DelayAction(function()
							CastSpell(_Q, myHero.x-50, myHero.z-50)
						end, 0.50)
					end
					DelayAction(function()
						if myHero:CanUseSpell(_E) == READY and Param.miscellaneous.GapCloser.UseE then
							DelayAction(function()
								LogicE(unit)
							end, 0.05)
						end
						if myHero:CanUseSpell(_R) == READY then
							DelayAction(function()
								LogicR(unit)
							end, 0.20)
						end
					end, 0.80)
				end

				if spell.name ~= "ZedR" then
					DelayAction(function()
					if myHero:CanUseSpell(_E) == READY and Param.miscellaneous.GapCloser.UseE then
						LogicE(unit)
					end
					end, 0.05)
					if myHero:CanUseSpell(_W) == READY and Param.miscellaneous.GapCloser.UseW then
						LogicW(unit)
					end
					DelayAction(function()
					if myHero:CanUseSpell(_R) == READY then
						LogicR(unit)
					end
					end, 0.20)
				end
			end
		end
	end
end

function OnRemoveBuff(unit, buff)
	if buff.name == "recall" and unit.isMe then
		if myHero.level >= 9 then
			if Param.miscellaneous.Starter.TrinketBleu then
				BuyItem(3363)
			end
		end
	end
end

function Immune(unit)
	if unit ~= nil then
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
end
