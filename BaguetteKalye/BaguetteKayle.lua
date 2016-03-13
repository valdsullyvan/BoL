--[[

Script by spyk for Kayle.

=> BaguetteKayle.lua

- Github link : https://github.com/spyk1/BoL/blob/master/BaguetteKayle/BaguetteKayle.lua

- Forum Thread : http://forum.botoflegends.com/topic/89837-beta-baguette-malzahar/

]]--

local charNames = {
    
    ['Kayle'] = true,
    ['kayle'] = true
}

if not charNames[myHero.charName] then return end

function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteKayle]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end


local TextList = {"Ignite = Kill", "Q = Kill"}
local KillText = {}
local dmgQ = 10 + 50 * myHero:GetSpellData(_Q).level + .6 * myHero.ap + myHero.addDamage
local dmgE = (5 + 5 * myHero:GetSpellData(_E).level + 0.15 * myHero.ap) + (10 + 10 * myHero:GetSpellData(_E).level + 0.3 * myHero.ap + (0.15 + 0.5 * myHero:GetSpellData(_E).level) * myHero.totalDamage )
local Last_LevelSpell = 0
local DAD = 0
local DAD2 = 0
local DAD3 = 0
local DAD4 = 0
local DTT = 0
local GuinsooGet, NashorGet, HurricanGet, Item_Jungle_Get = 0,0,0,0
local Last_Item_Check = 0
local GuinsooStacks = 0

--- Starting AutoUpdate
local version = "0.01"
local author = "spyk"
local SCRIPT_NAME = "BaguetteKayle"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteKayle/BaguetteKayle.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local whatsnew = 0

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteKayle/BaguetteKayle.version")
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
	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteKayle]</b></font> <font color=\"#ffffff\">by spyk</font>")
	--
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerExhaust") then Exhaust = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerExhaust") then Exhaust = SUMMONER_2 end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then Ignite = SUMMONER_2 end
	--
	if whatsnew == 1 then
		DelayAction(function() EnvoiMessage("What's new : Release.")end, 0)
		whatsnew = 0
	end

	Menu()

	CustomLoad()


end

function Menu()
	--
	Param = scriptConfig("[Baguette] Kayle", "BaguetteKayle")
	--
	Param:addSubMenu("SBTW!","Combo")
			Param.Combo:addParam("Key", "Combo Key :", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseW", "Use (W) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
			Param.Combo:addParam("UseE", "Use (E) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
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
			Param.Clear.WaveClear:addParam("UseE", "Use (E) Spell in WaveClear?" , SCRIPT_PARAM_ONOFF, true)
		--
		Param.Clear:addSubMenu("JungleClear", "JungleClear")
			Param.Clear.JungleClear:addParam("Key", "JungleClear Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
			Param.Clear.JungleClear:addParam("Mana", "Required Mana to JungleClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
			Param.Clear.JungleClear:addParam("UseQ", "Use (Q) Spell in JungleClear?" , SCRIPT_PARAM_ONOFF, true)
			Param.Clear.JungleClear:addParam("UseE", "Use (E) Spell in JungleClear?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("KillSteal", "KillSteal")
		Param.KillSteal:addParam("Enable", "Enable KillSteal?" , SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseE", "Use (E) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Summoner Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true) end

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
			if VIP_USER then Param.miscellaneous.Skin:addParam("skins", 'Which Skin :', SCRIPT_PARAM_LIST, 1, {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot"})
				Param.miscellaneous.Skin:setCallback("skins", function (nV)
					if nV then
						if Param.miscellaneous.Skin.Enable then
							SetSkin(myHero, Param.miscellaneous.Skin.skins -1)
						end
					end
				end)
			end
		--
		if VIP_USER then Param.miscellaneous:addSubMenu("Auto Buy :", "Starter") end
			if VIP_USER then Param.miscellaneous.Starter:addParam("TrinketBleu", "Buy a Blue Trinket at lvl.9 :", SCRIPT_PARAM_ONOFF, true) end
		--
		Param.miscellaneous:addSubMenu("GapCloser", "GapCloser")
			Param.miscellaneous.GapCloser:addParam("Enable", "Enable GapCloser with R?", SCRIPT_PARAM_ONOFF, true)
			Param.miscellaneous.GapCloser:addParam("UseW", "Use (W) Spell in GapCloser?", SCRIPT_PARAM_ONOFF, true)
			Param.miscellaneous.GapCloser:addParam("UseE", "Use (E) Spell in GapCloser?", SCRIPT_PARAM_ONOFF, true)

		Param.miscellaneous:addParam("AutoHeal", "Auto Heal enable :", SCRIPT_PARAM_ONOFF, true)
		Param.miscellaneous:addParam("AutoHealMana","Required Mana to AutoHeal :", SCRIPT_PARAM_SLICE, 50, 0, 100)
	--
	Param:addSubMenu("Drawing", "draw")
		Param.draw:addParam("disable","Disable all draws?", SCRIPT_PARAM_ONOFF, false)
		Param.draw:addParam("target", "Draw Current Target Text?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("drawKillable", "Draw Killable Text?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("drawDamage", "Draw Damage?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("hitbox", "Draw HitBox?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("hero", "Draw AA before kill?", SCRIPT_PARAM_ONOFF, true)
		Param.draw:addParam("heroblock", "Draw on health bar before kill?", SCRIPT_PARAM_ONOFF, true)
		--
		Param.draw:addSubMenu("Charactere Draws","spell")
			Param.draw.spell:addParam("Qdraw","Display (Q) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("Wdraw","Display (W) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("Edraw","Display (E) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("Rdraw","Display (R) Spell draw?", SCRIPT_PARAM_ONOFF, true)
			Param.draw.spell:addParam("AAdraw", "Display Auto Attack draw?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addParam("n4", "Baguette Kayle | Version", SCRIPT_PARAM_INFO, ""..version.."")
	Param:permaShow("n4")
end

function OnUnload()
	EnvoiMessage("Unloaded.")
	EnvoiMessage("There is no justice anymore between us... Ciao!")
	if Param.miscellaneous.Skin.Enable then
		SetSkin(myHero, -1)
	end
end

function CustomLoad()

	enemyMinions = minionManager(MINION_ENEMY, 3000, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 3000, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Kayle"
	Param:addTS(ts)
	LoadVPred()

	if _G.Reborn_Loaded ~= nil then
   		LoadSACR()
   	elseif _Pewalk then
   		LoadPewalk()
	else
		EnvoiMessage("Nebelwolfi's Orb Walker loading..")
		LoadNEBOrb()
	end

	LoadSpikeLib()

	Skills()

	AutoLvlSpellCombo()

	if Param.miscellaneous.Skin.Enable then
		SetSkin(myHero, Param.Draw.Skin.skins -1)
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

function LoadPewalk()
	if _Pewalk then
		EnvoiMessage("Loaded Pewalk")
		DelayAction(function ()EnvoiMessage("[Pewalk] Disable every spell usage in Pewalk for better performances with my script.")end, 7)
	elseif not _Pewalk then
		EnvoiMessage("Pewalk loading error")
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
		target = GetCustomTarget()
		Misc()
		KillSteal()

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

	elseif _Pewalk then

		if _G._Pewalk.GetActiveMode().Carry then 
			Combo()
		elseif _G._Pewalk.GetActiveMode().Mixed then 
			Harass()
		elseif _G._Pewalk.GetActiveMode().LaneClear then
			LaneClear()
		elseif _G._Pewalk.GetActiveMode().Farm then 
			LastHit()
		end

	elseif _G.NebelwolfisOrbWalkerLoaded then

		if _G.NebelwolfisOrbWalker.Config.k.Combo then
			Combo()
		elseif _G.NebelwolfisOrbWalker.Config.k.Harass then
			Harass()
		elseif _G.NebelwolfisOrbWalker.Config.k.LastHit then
			LastHit()
		elseif _G.NebelwolfisOrbWalker.Config.k.LaneClear then
			LaneClear()
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
					CastSpell(_Q, unit)
				end
			end
		end
	end
end

function Spell()

end

function Combo()
	if Param.Combo.UseQ then
		if target ~= nil and myHero:CanUseSpell(_Q) == READY and GetDistance(target) < SkillQ.range then
			CastSpell(_Q, target)
		end
	end
	if Param.Combo.UseE then
		if target ~= nil and myHero:CanUseSpell(_E) == READY and GetDistance(target) < SkillE.range+100 then
			CastSpell(_E)
		end
	end
end

function LogicW()
	if Param.miscellaneous.AutoHeal then
		for _, unit in pairs(GetAllyHeroes()) do
			health = unit.health
			if GetDistance(unit) < SkillW.range and myHero.mana < (myHero.maxMana * ( Param.miscellaneous.AutoHealMana / 100)) then
				if unit.health < (unit.maxHealth * (Param.miscellaneous.AutoHealMana/100)) then
					CastSpell(_W)
				end
			elseif myHero.health < (myHero.maxHealth * (Param.miscellaneous.AutoHealMana/100)) and myHero.mana < (myHero.maxMana * ( Param.miscellaneous.AutoHealMana / 100)) then
				CastSpell(_W)
			end
		end
	end
end

function Skills()
	SkillQ = { name = "JudicatorReckoning", range = 650, delay = 0, speed = math.huge, width = nil, ready = false }
	SkillW = { name = "JudicatorDivineBlessing", range = 900, delay = 0, speed = math.huge, width = nil, ready = false }
	SkillE = { name = "JudicatorRighteousFury", range = 525, delay = 0, speed = math.huge, width = 150, ready = false }
	SkillR = { name = "JudictorIntervention", range = 900, delay = 0, speed = math.huge, width = nil, ready = false }
end

function Misc()
	DrawKillable()
	AutoLvlSpell()
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

function AutoLvlSpell()
	if (string.find(GetGameVersion(), 'Releases/6.5') ~= nil) then
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
		levelSequence =  { 3,1,2,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2}
	end
end

function OnRemoveBuff(unit, buff)
	if buff.name == "rageblade" and unit.isMe then
      GuinsooStacks = 0
    end
	if buff.name == "recall" and unit.isMe then
		if myHero.level >= 9 then
			if Param.miscellaneous.Starter.TrinketBleu then
				BuyItem(3363)
			end
		end
	end
end

function OnUpdateBuff(unit, buff, Stacks)
   if buff.name == "rageblade" and unit.isMe then
      if Stacks > 8 then
      	GuinsooStacks = 8
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

function DrawKillable()
	for i = 1, heroManager.iCount, 1 do
		local enemy = heroManager:getHero(i)
		if enemy and ValidTarget(enemy) then
			if enemy.team ~= myHero.team then
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") or myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
					if (myHero:CanUseSpell(Ignite) == READY) then
						iDmg = 40 + (20 * myHero.level)
					elseif (myHero:CanUseSpell(Ignite) ~= READY) then
						iDmg = 0
					end
				end
				Qdmg = ((myHero:CanUseSpell(_Q) == READY and damageQ) or 0)
				if iDmg > enemy.health then
					KillText[i] = 1
				elseif Qdmg > enemy.health then
					KillText[i] = 2
				else
					KillText[i] = nil
				end
			end 
		end 
	end 
end

function OnDraw()
	if not myHero.dead and not Param.draw.disable then

		-- SPELL DRAW

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
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.range+myHero.boundingRadius, 1, 0xFFFFFFFF)
		end
		if Param.draw.hitbox then
			DrawCircle3D(myHero.x, myHero.y, myHero.z, myHero.boundingRadius, 1, 0xFFFFFFFF)
		end

		-- TARGET DRAW
		if Target ~= nil and ValidTarget(Target) then
			if Param.draw.target then
				DrawText3D(">> Current |Target <<",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFFFF)
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

		if Param.draw.hero then
			for _, unit in pairs(GetEnemyHeroes()) do
				if unit ~= nil and GetDistance(unit) < 3000 then

					D1 = math.floor(myHero:CalcDamage(unit,dmgE))

					ItemCheck_Dmg()

					DA = DTT + D1

					D3E = math.floor(myHero:CalcDamage(unit,DA))

					DAA1 = math.round(myHero:CalcDamage(unit,myHero.totalDamage*90/100))

					if not TargetHaveBuff("SummonerExhaust", myHero) then
						D3E1 = math.floor(D3E/unit.health*100)
						DAA = math.floor(unit.health/(D3E+DAA1))
					elseif TargetHaveBuff("SummonerExhaust", myHero) then
						D3E1 = math.floor(D3E/unit.health*100)-((math.floor(D3E/unit.health*100)*40)/100)
						DAA = math.floor(unit.health/(D3E+DAA1))
					end

					-- AA remaining & %

					if Param.draw.hero then

						if D3E1 < 80 then
							DrawText3D(D3E1.."%".." | "..DAA, unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,250,250,250), 0)
						elseif D3E1 >= 80 and D3E1 < 100 then
							DrawText3D(D3E1.."%".." | "..DAA, unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
						elseif D3E1 >= 100 then
							DrawText3D("100% ! | 0 !", unit.x+125, unit.y+85, unit.z+155, 30, ARGB(255,205,51,51), 0)
						end
					end

					-- COLOR BLOCK
					if Param.draw.heroblock then
						local Center = GetUnitHPBarPos(unit)
						if Center.x > -100 and Center.x < WINDOW_W+100 and Center.y > -100 and Center.y < WINDOW_H+100 then
							local off = GetUnitHPBarOffset(unit)
							local y=Center.y + (off.y * 53) + 2
							local xOff = ({['AniviaEgg'] = -0.1,['Darius'] = -0.05,['Renekton'] = -0.05,['Sion'] = -0.05,['Thresh'] = -0.03,})[unit.charName]
							local x = Center.x + ((xOff or 0) * 140) - 66
							if not TargetHaveBuff("SummonerExhaust", myHero) then
								dmg = unit.health - D3E
							elseif TargetHaveBuff("SummonerExhaust", myHero) then
								dmg = unit.health - (D3E-((D3E*40)/100))
							end
							DrawLine(x + ((unit.health /unit.maxHealth) * 104),y, x+(((dmg > 0 and dmg or 0) / unit.maxHealth) * 104),y,9, GetDistance(unit) < 3000 and 0x6699FFFF)
						end
					end
				end
			end
		end
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

function ItemCheck_Dmg()
	ItemCheck()
	if HurricanGet == 1 then
		DAD = 15 
	else
		DAD = 0
	end
	if NashorGet == 1 then
		DAD2 = 15 + .15 * myHero.ap
	else
		DAD2 = 0
	end
	if GuinsooGet == 1 and TargetHaveBuff("Guinsoo",myHero) then
		if GuinsooStacks == 8 then
			DAD3 = 20 + .15 * myHero.totalDamage + .075 * myHero.ap
		end
	else
		DAD3 = 0
	end
	if Item_Jungle_Get == 1 then
		DAD4 = 60
	else		
		DAD4 = 0 
	end

	DTT = DAD + DAD2 + DAD3 + DAD4

end

function ItemCheck()
	if os.clock()-Last_Item_Check > 20 then
		Last_Item_Check = os.clock()
		for SLOT = ITEM_1, ITEM_6 do
			if GetInventoryHaveItem(3085) and HurricanGet == 0 then
				HurricanGet = 1
				EnvoiMessage("Found : Runaan's Hurricane")
			end
			if GetInventoryHaveItem(3115) and NashorGet == 0 then
				NashorGet = 1
				EnvoiMessage("Found : Nashor's Tooth")
			end
			if GetInventoryHaveItem(3124) and GuinsooGet == 0 then
				GuinsooGet = 1
				EnvoiMessage("Found : Guinsoo's Rageblade")
			end
			if (GetInventoryHaveItem(3931) and Item_Jungle_Get == 0) or (GetInventoryHaveItem(3932) and Item_Jungle_Get == 0) or (GetInventoryHaveItem(3930) and Item_Jungle_Get == 0) then
				Item_Jungle_Get = 1
				EnvoiMessage("Found : Enchantment: Sated Devourer")
			end
		end
	end
end

function OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	if unit.isMe then--and --Param.Miscellaneous.ESettings.Fast then
		if myHero:CanUseSpell(_W) == READY then
			if GetGame().map.shortName == "summonerRift" and GetDistance(myHero.endPath) > 3000 then
				CastSpell(_W, myHero)
			end
		end
	end
end
