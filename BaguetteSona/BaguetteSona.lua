--[[

Script by spyk for Sona.

BaguetteSona.lua

Github link : https://github.com/spyk1/BoL/blob/master/BaguetteSona/BaguetteSona.lua

Forum Thread : 

]]--

local charNames = {
    
    ['Sona'] = true,
    ['sona'] = true
}

if not charNames[myHero.charName] then return end

function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteSona]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end

local MenuPerso = "Premier"
local n1, n2, n3, n4, n5 = ""
local CurrentMode = "DMGS"
local passivecount = 0
local TextList = {"AA+ = Kill", "Ignite = Kill", "Q = Kill", "Q + Ignite = Kill", "Q + R = Kill", "Q + R + Ignite = Kill", "Q + R + Ignite + AA+ = KILL", "Not Killable"}
local KillText = {}
local Ignite = "Aatrox", "FiddleSticks", "Galio", "Irelia", "Maokai", "MasterYi", "Nasus", "Nidalee", "Olaf", "Nunu", "Riven", "Ryze", "Soraka", "TahmKench", "Vladimir", "Warwick", "Zac"
local Exhaust = "Annie", "Akali", "Azir", "Brand", "Cassiopeia", "Darius", "Diana", "Draven", "Elise", "Fiora", "FiddleSticks", "Fizz", "Graves", "Illaoi", "Jax", "Karthus", "Katarina", "Khazix", "Kindred", "Leblanc", "Lux", "MasterYi", "Nasus", "Olaf", "Orianna", "Poppy", "Renekton", "Rengar", "Riven", "Ryze", "Syndra", "Talon", "Tryndamere", "Trundle", "Udyr", "Veigar", "Vayne", "Viktor", "VelKoz", "MonkeyKing", "Yasuo", "Zed", "Zyra"
local ExhaustI = "Zed", "Yasuo", "Vayne", "Twitch", "Varus", "Tryndamere", "Tristana", "Talon", "Sivir", "Ryze", "Riven", "Rengar", "Quinn", "MasterYi", "MissFortune", "Lucian", "KogMaw", "Kindred", "Katarina", "Kalista", "Jinx", "Ezreal", "Caitlyn", "Ashe", "Corki"

--- Starting AutoUpdate
local version = "0.123"
local author = "spyk"
local SCRIPT_NAME = "BaguetteSona"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteSona/BaguetteSona.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
local whatsnew = 0

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteSona/BaguetteSona.version")
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
	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteSona]</b></font> <font color=\"#ffffff\">by spyk</font>")
	--
	if whatsnew == 1 then
		DelayAction(function() EnvoiMessage("What's new : 'Auto LvL spell fixed for the update.'")end, 0)
		whatsnew = 0
	end
	--
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then Ignite = SUMMONER_2 else Ignite = NONE end
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerexhaust") then Exhaust = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerexhaust") then Exhaust = SUMMONER_2 else Exhaust = NONE end
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") then Flash = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("summonereflast") then Flash = SUMMONER_2 else Flash = NONE end
	--
	Param = scriptConfig("[Baguette] Sona", "BaguetteSona")
	--
	Param:addParam("n5", "Current Mode :", SCRIPT_PARAM_LIST, 1, {"None", "Combo", "Harass", "WaveClear", "JungleClear", "Harass (Toggle)"})
		Param:permaShow("n5")
	if Param.Logic == 2 then Param:addParam("n170", "Prefered Logic (Mode)", SCRIPT_PARAM_LIST, 1, {"DMGS", "SLOW", "EXHT", "None"}) end
		if Param.Logic == 2 then Param:permaShow("n170") end
	--
	Param:addSubMenu("SBTW!","Combo")
		Param.Combo:addParam("Key", "Combo Key :", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		if Ignite or Exhaust then Param.Combo:addParam("Summoner", "When it will cast summoners?", SCRIPT_PARAM_LIST, 2, {"At the Start of the fight + ComboMode or to KS (Deny Burst / HP Heal)", "During fight (KS, Burst Reduction)"}) end
		Param.Combo:addParam("UseQ", "Use (Q) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("UseW", "Use (W) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("UseE", "Use (E) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("UseR", "Use (R) Spell in Combo?" , SCRIPT_PARAM_ONOFF, true)
		Param.Combo:addParam("MinR", "How many in R to ult?", SCRIPT_PARAM_SLICE, 2, 1, 5)
		if Param.Logic == 1 or Param.Logic == 2 then Param.Combo:addParam("ManaSpam", "Set the Value to Spam Spell to do the AA Combo :", SCRIPT_PARAM_SLICE, 400, 0, 5000) end
		if Param.Logic == 2 then Param.Combo:addParam("Logic", "Prefered Logic for SBTW :", SCRIPT_PARAM_LIST, 3, {"DMGS", "SLOW", "EXHT"}) end
	--
	Param:addSubMenu("Harass","Harass")
		Param.Harass:addParam("Key", "Harass Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Param.Harass:addParam("Auto", "Toggle Harass (Auto)", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("I"))
		Param.Harass:addParam("Mana", "Required Mana to Harass :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.Harass:addParam("UseQ", "Use (Q) Spell in Harass?" , SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addParam("UseW", "Use (W) Spell in Harass?" , SCRIPT_PARAM_ONOFF, true)
		Param.Harass:addParam("UseE", "Use (E) Spell in Harass?" , SCRIPT_PARAM_ONOFF, true)
		if Param.Logic == 2 then Param.Harass:addParam("Logic", "Prefered Logic for Harass :", SCRIPT_PARAM_LIST, 1, {"DMGS", "SLOW", "EXHT"}) end
	--
	Param:addSubMenu("WaveClear", "WaveClear")
		Param.WaveClear:addParam("Key", "WaveClear Key :",SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Param.WaveClear:addParam("Mana", "Required Mana to WaveClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.WaveClear:addParam("UseQ", "Use (Q) Spell in WaveClear?" , SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("JungleClear", "JungleClear")
		Param.JungleClear:addParam("Key", "JungleClear Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Param.JungleClear:addParam("Mana", "Required Mana to JungleClear :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		Param.JungleClear:addParam("UseQ", "Use (Q) Spell in JungleClear?" , SCRIPT_PARAM_ONOFF, true)
		if Param.Logic == 2 then Param.JungleClear:addParam("Logic", "Prefered Logic for JungleClear :", SCRIPT_PARAM_LIST, 1, {"DMGS", "SLOW", "EXHT"}) end
	--
	Param:addSubMenu("KillSteal", "KillSteal")
		Param.KillSteal:addParam("Active", "Enable KillSteal?" , SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseQ", "Use (Q) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true)
		Param.KillSteal:addParam("UseR", "Use (R) Spell to KillSteal?", SCRIPT_PARAM_ONOFF, false)
		if Ignite then Param.KillSteal:addParam("UseIgnite", "Use (Ignite) Summoner Spell to KillSteal?", SCRIPT_PARAM_ONOFF, true) end
	--
	Param:addSubMenu("Miscellaneous", "Miscellaneous")
	if VIP_USER then Param.Miscellaneous:addSubMenu("Auto Lvl Spell", "AutoSpell") end
		if VIP_USER then Param.Miscellaneous.AutoSpell:addParam("Enable", "Enable Auto Level Spell?", SCRIPT_PARAM_ONOFF, true) end
		if VIP_USER then Param.Miscellaneous.AutoSpell:addParam("Combo", "Choose you'r Auto Level Spell Combo", SCRIPT_PARAM_LIST, 1, {"R > Q > W > E (Max Q)"}) end
		if VIP_USER then Param.Miscellaneous.AutoSpell:addParam("n1", "", SCRIPT_PARAM_INFO,"") end
		if VIP_USER then Param.Miscellaneous.AutoSpell:addParam("n2", "Press F9 twice if you change Level Spell Combo.", SCRIPT_PARAM_INFO,"") end
		if VIP_USER then Param.Miscellaneous.AutoSpell:addParam("n3", "If you need more Combo, go on forum and tell me which.", SCRIPT_PARAM_INFO,"") end
		if VIP_USER then Last_LevelSpell = 0 end
		--
		Param.Miscellaneous:addSubMenu("W Settings", "WSettings")
			Param.Miscellaneous.WSettings:addParam("EnableHeal", "Enable AutoHeal?", SCRIPT_PARAM_ONOFF, true)
			Param.Miscellaneous.WSettings:addParam("HealAuto", "Auto Heal allies under X %HP :", SCRIPT_PARAM_SLICE, 60, 0, 100)
			Param.Miscellaneous.WSettings:addParam("Mana", "Required Mana to AutoHeal :", SCRIPT_PARAM_SLICE, 50, 0, 100)
		--
		Param.Miscellaneous:addSubMenu("E Settings", "ESettings")
			Param.Miscellaneous.ESettings:addParam("FleeKey", "Flee Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
			Param.Miscellaneous.ESettings:addParam("Fast", "Enable fast come back to lane?", SCRIPT_PARAM_ONOFF, true)
		--
		Param.Miscellaneous:addSubMenu("R Settings", "RSettings")
			Param.Miscellaneous.RSettings:addParam("Enable", "Enable auto ult?", SCRIPT_PARAM_ONOFF, true)
			Param.Miscellaneous.RSettings:addParam("Auto", "Auto Ult if ", SCRIPT_PARAM_SLICE, 4, 0, 5)
		--
		if Ignite or Exhaust then Param.Miscellaneous:addSubMenu("Summoner", "SummonerSetting") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n10", "Here you can choose on who you want to cast Ignite and exhaust.", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n11", "", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("Enable", "Enable Summoner Support?", SCRIPT_PARAM_ONOFF, true) end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n16", "", SCRIPT_PARAM_INFO, "") end
			if Ignite and Exhaust == NONE then Param.Miscellaneous.SummonerSetting:addParam("n12", "Ignite :", SCRIPT_PARAM_INFO, "True") end
			if Exhaust and Ignite == NONE then Param.Miscellaneous.SummonerSetting:addParam("n13", "Exhaust :", SCRIPT_PARAM_INFO, "True") end
			if Exhaust and Ignite then Param.Miscellaneous.SummonerSetting:addParam("n14", "Ignite and Exhaust :", SCRIPT_PARAM_INFO, "True") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n19", "", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n17", "It's simple, just put on ON to use you'r summoner on the combo", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n18", "you choose in Combo Menu. Else, just put the caractere name on OFF.", SCRIPT_PARAM_INFO, "") end
			if Ignite or Exhaust then Param.Miscellaneous.SummonerSetting:addParam("n20", "", SCRIPT_PARAM_INFO, "") end
		--
		Param.Miscellaneous:addParam("n120", "", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("Enable", "Enable the Passive Logic?", SCRIPT_PARAM_ONOFF, true)
		Param.Miscellaneous:addParam("n128", "", SCRIPT_PARAM_INFO, "")
		--
		Param:addParam("Logic", "Which Passive Logic (F9x2) :", SCRIPT_PARAM_LIST, 1, {"Manual (Click) Switch", "Auto Switch (Configurable)"})
		--
		Param.Miscellaneous:addParam("n130", "", SCRIPT_PARAM_INFO, "")
		if Param.Logic == 1 then Param.Miscellaneous:addParam("CurrentSwitch", "Current Mode :", SCRIPT_PARAM_LIST, 1, {"DMGS", "SLOW", "EXHT"}) end
		if Param.Miscellaneous.Enable then Param:permaShow("Logic") else Param.Miscellaneous:permaShow("Enable") end
		if Param.Logic == 1 then Param.Miscellaneous:permaShow("CurrentSwitch") end
		Param.Miscellaneous:addParam("n121", "", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n122", "What is Passive Logic? Well, Be ready, it's hard to", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n123", "understand. On Sona, The Q, W, E have a special", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n124", "effect after 3 Spells casts. So, it's a fat", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n125", "algorithm. By default, if it's enable,", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n126", "which I advice, you will be on Manual ", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n127", "Switch, then you need toPress (Y) every time ", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n128", "you want to switch the mode. Like DMG mode ", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n129", "or SLOW mode... Well, there is another ", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n130", "function, more fast, more standlone with ", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n131", "everymode, but it need to F9 If you switch.", SCRIPT_PARAM_INFO, "")
		Param.Miscellaneous:addParam("n132", "Then this is a fat algorithm, always configurable in everymode menus.", SCRIPT_PARAM_INFO, "")
	--
	Param:addSubMenu("", "nil")
	--
	Param:addSubMenu("Drawing","drawing")
		Param.drawing:addParam("Enable", "Disable every draws?", SCRIPT_PARAM_ONOFF, false)
		Param.drawing:addParam("Qdraw","Display (Q) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Wdraw","Display (W) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Edraw","Display (E) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Rdraw","Display (R) Spell draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("AAdraw", "Display Auto Attack draw?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("Current", "Draw text on current target?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("drawKillable", "Draw Killable Text?", SCRIPT_PARAM_ONOFF, true)
		Param.drawing:addParam("drawDamage", "Draw Damage?", SCRIPT_PARAM_ONOFF, true)
	--
	Param:addSubMenu("", "nil")
	--
	CustomLoad()
end

function OnUnload()
	EnvoiMessage("Unloaded.")
	EnvoiMessage("There is no music anymore between us... Ciao!")
end

function CustomLoad()
	enemyMinions = minionManager(MINION_ENEMY, 700, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 700, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Sona"
	Param:addTS(ts)
	PriorityOnLoad()
	LoadVPred()
	AutoLvlSpellCombo()
	lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0
	range = 550
	DelayAction(function()EnvoiMessage("Remember, this is a Beta test. If you find a bug, just report it on the forum thread. This script is gonna improve himself because of you. Thanks guys.")end, 7)
end

function OnTick()
	if not myHero.dead then
		ts:update()
		target = GetCustomTarget()
		KillSteal()
		KeyPermaShow()
		Spell()
	end
end

function KeyPermaShow()
	ComboKey = Param.Combo.Key
	HarassKey = Param.Harass.Key
	HarassToggle = Param.Harass.Auto
	JungleClearKey = Param.JungleClear.Key
	WaveClearKey = Param.WaveClear.Key

	range = myHero.range + myHero.boundingRadius - 3
	ts.range = range

	if ComboKey then
		Param.n5 = 2
		Param.n170 = Param.Combo.Logic

		if Param.Logic == 2 then
			if Param.Combo.Logic == 1 then
				Damages()
			elseif Param.Combo.Logic == 2 then
				Ralentissement()
			elseif Param.Combo.Logic == 3 then
				Fatigue()
			end
		end

	elseif not ComboKey then

		if HarassKey then
			Param.n5 = 3
			Param.n170 = 1

			if Param.Logic == 2 then
				if Param.Harass.Logic == 1 then
					Damages()
				elseif Param.Harass.Logic == 2 then
					Ralentissement()
				elseif Param.Harass.Logic == 3 then
					Fatigue()
				end
			end

		elseif WaveClearKey then

			Param.n5 = 4
			Param.n170 = 1

			Damages()

		elseif JungleClearKey then

			Param.n5 = 5
			Param.n170 = Param.JungleClear.Logic


			if Param.Logic == 2 then
				if Param.JungleClear.Logic == 1 then
					Damages()
				elseif Param.JungleClear.Logic == 2 then
					Ralentissement()
				elseif Param.JungleClear.Logic == 3 then
					Fatigue()
				end
			end

		elseif HarassToggle then

			Param.n170 = Param.Harass.Logic
			Param.n5 = 6

			if Param.Logic == 2 then
				if Param.Harass.Logic == 1 then
					Damages()
				elseif Param.Harass.Logic == 2 then
					Ralentissement()
				elseif Param.Harass.Logic == 3 then
					Fatigue()
				end
			end
		end
	end
	if Param.n5 ~= 1 and not ComboKey and not HarassKey and not JungleClearKey and not WaveClearKey and not HarassToggle then
		Param.n5 = 1
	end
	if Param.n170 ~= 4 and not ComboKey and not HarassKey and not JungleClearKey and not WaveClearKey and not HarassToggle then
		Param.n170 = 4
	end
end

function Damages()
	if lastspell == "SonaQ" then
		CastAA()
	elseif lastspell ~= "SonaQ" and myHero:GetSpellData(_Q).currentCd < 4 and passivecount == 3 then
		if myHero:CanUseSpell(_Q) == READY then 
			LogicQ()
		end
	elseif lastspell ~= "SonaQ" and myHero:GetSpellData(_Q).currentCd > 4 then
		CastAA()
		if myHero:CanUseSpell(_W) == READY then 
			LogicW()
		end
		if myHero:CanUseSpell(_E) == READY then 
			LogicE()
		end
	elseif myHero:GetSpellData(_Q).currentCd == 0 then
		LogicQ()
	else
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function Ralentissement()
	if lastspell == "SonaW" then
		CastAA()
	elseif lastspell ~= "SonaW" and myHero:GetSpellData(_W).currentCd < 4 and passivecount == 3 then
		if myHero:CanUseSpell(_W) == READY then 
			LogicW()
		end
	elseif lastspell ~= "SonaW" and myHero:GetSpellData(_W).currentCd > 4 then
		CastAA()
		if myHero:CanUseSpell(_E) == READY then 
			LogicE() 
		end
		if myHero:CanUseSpell(_Q) == READY then 
			LogicQ() 
		end
	else
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function Fatigue()
	if lastspell == "SonaE" then
		CastAA()
	elseif lastspell ~= "SonaE" and myHero:GetSpellData(_E).currentCd < 4  and passivecount == 3 then
		if myHero:CanUseSpell(_E) == READY then 
			LogicE() 
		end
	elseif lastspell ~= "SonaE" and myHero:GetSpellData(_E).currentCd > 4 then
		CastAA()
		if myHero:CanUseSpell(_Q) == READY then 
			LogicQ() 
		end
		if myHero:CanUseSpell(_W) == READY then 
			LogicW() 
		end
	else
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function KillSteal()
	for _, unit in pairs(GetEnemyHeroes()) do
		health = unit.health
		Qdmg = ((40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap) or 0)
		QmagicDamage = myHero:CalcMagicDamage(unit, Qdmg)
		Rdmg = ((100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap) or 0)
		RmagicDamage = myHero:CalcMagicDamage(unit, Rdmg)
		if GetDistance(unit) < 850 then
			if Param.KillSteal.Active then
				if health <= QmagicDamage and Param.KillSteal.UseQ and myHero:CanUseSpell(_Q) == READY and ValidTarget(unit) then
					CastSpell(_Q)
				end
				if health <= RmagicDamage and Param.KillSteal.UseR and myHero:CanUseSpell(_R) == READY and ValidTarget(unit) then
					local HitPos = VP:GetLineAOECastPosition(target, 0.5, 140, 850, 2400, myHero, false)
					CastSpell(_R, HitPos.x, HitPos.z)
				end
				if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") or myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
					if health <= 40 + (20 * myHero.level) and Param.KillSteal.UseIgnite and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) then
						CastSpell(Ignite, unit)
					end
				end
			end
		end
	end
end

function Spell()
	if Param.Miscellaneous.Enable then
		if Param.Logic == 1 then
			if ComboKey or HarassKey or WaveClearKey or JungleClearKey or HarassToggle then
				if CurrentMode == "DMGS" then
					Damages()
				elseif CurrentMode == "SLOW" then
					Ralentissement()
				elseif CurrentMode == "EXHT" then
					Fatigue()
				end
			end
		end
	else
		if myHero:CanUseSpell(_Q) == READY then LogicQ() end
		if myHero:CanUseSpell(_W) == READY then LogicW() end
		if myHero:CanUseSpell(_E) == READY then LogicE() end
	end
	if myHero:CanUseSpell(_R) == READY then LogicR() end
	if Param.Miscellaneous.ESettings.FleeKey then myHero:MoveTo(mousePos.x, mousePos.z) end
	if VIP_USER then 
		if Param.Miscellaneous.AutoSpell.Enable then
			AutoLvlSpell()
		end
	end
	if Ignite or Exhaust then
		if Param.Miscellaneous.SummonerSetting.Enable then 
			SummonerManager() 
		end
	end
end

function LogicQ()
	if target and (GetDistance(target) < 850) and (ComboKey or HarassKey or HarassToggle) then
		if ComboKey then
			CastSpell(_Q)
			CastAA()
		elseif HarassKey or HarassToggle then
			if ((myHero.mana / myHero.maxMana)*100 > Param.Harass.Mana) then
				CastSpell(_Q)
				CastAA()
			end
		end
	end
	if WaveClearKey then
		enemyMinions:update()
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil and GetDistance(minion) < 850 and ((myHero.mana / myHero.maxMana)*100 > Param.WaveClear.Mana) then
				CastSpell(_Q)
			end
			if ValidTarget(minion) and minion ~= nil and GetDistance(minion) < myHero.range - 50 then
				if timeToShoot() then
					myHero:Attack(minion)
				elseif heroCanMove() then
					moveToCursor()
				end
			end
			if minion == nil then
				moveToCursor()
			end
		end
	end
	if JungleClearKey then
		jungleMinions:update()
		for i, jungleMinion in pairs(jungleMinions.objects) do
			if jungleMinion ~= nil and GetDistance(jungleMinion) < 850 and ((myHero.mana / myHero.maxMana)*100 > Param.JungleClear.Mana) then
				CastSpell(_Q)
			end
			if jungleMinion ~= nil and GetDistance(jungleMinion) < myHero.range - 50 then		
				if timeToShoot() then
					myHero:Attack(jungleMinion)
				elseif heroCanMove() then
					moveToCursor()
				end
			end
		end
	end
end

function LogicW()
	if Param.Miscellaneous.WSettings.EnableHeal then
		for _, unit in pairs(GetAllyHeroes()) do
			health = unit.health
			if GetDistance(unit) < 950 and (myHero.mana > (myHero.maxMana * ( Param.Miscellaneous.WSettings.Mana / 100))) then
				if unit.health < (unit.maxHealth * (Param.Miscellaneous.WSettings.HealAuto/100)) then
					CastSpell(_W)
				end
			elseif myHero.health < (myHero.maxHealth * (Param.Miscellaneous.WSettings.HealAuto/100)) and (myHero.mana > (myHero.maxMana * ( Param.Miscellaneous.WSettings.Mana / 100))) then
				CastSpell(_W)
			end
		end
	end
	if Param.Logic == 1 and passivecount == 2 and Param.Miscellaneous.Enable and CurrentMode == "EXHT" then
		CastSpell(_W)
		CastAA()
	end
	if ComboKey and Param.Combo.UseW and myHero.mana > Param.Combo.ManaSpam and passivecount ~= 3 then
		CastSpell(_W)
	else
		CastAA()
	end
end

function LogicE()
	if Param.Miscellaneous.ESettings.FleeKey then
		CastSpell(_E)
	end
	if Param.Logic == 1 and passivecount == 2 and Param.Miscellaneous.Enable and CurrentMode == "SLOW" then
		CastSpell(_E)
		CastAA()
	end
	if ComboKey and Param.Combo.UseE and myHero.mana > Param.Combo.ManaSpam and passivecount ~= 3 then
		CastSpell(_E)
	end
end

function LogicR()
	if target ~= nil and ValidTarget(target) and GetDistance(target) <= 1000 then
		local aoeCastPos, hitChance, castInfo, nTargets
		aoeCastPos, hitChance, nTargets = VP:GetLineAOECastPosition(target, 0.5, 120, 900, 2400, myHero)
		if Param.Miscellaneous.RSettings.Enable then
			if nTargets == Param.Miscellaneous.RSettings.Auto then
				CastSpell(_R, aoeCastPos.x, aoeCastPos.z) 
			end
		end
		if Param.Combo.UseR and ComboKey then
			if nTargets == Param.Combo.MinR then
				CastSpell(_R, aoeCastPos.x, aoeCastPos.z) 
			end
		end
	end
end


function heroCanMove()
	return (GetTickCount() + GetLatency() * 0.5 > lastAttack + lastWindUpTime + 20)
end 
 
function timeToShoot()
	return (GetTickCount() + GetLatency() * 0.5 > lastAttack + lastAttackCD)
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized() * (312 + GetLatency())
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end 
end

function CastAA()
	local myTarget = ts.target
	if myTarget ~=	nil and GetDistance(myTarget) < range - 50 then	
		if timeToShoot() then
			myHero:Attack(myTarget)
		elseif heroCanMove() then
			myHero:MoveTo(mousePos.x, mousePos.z)
		end
	end
end

function SummonerManager()
	if Exhaust then
		if Param.Miscellaneous.Summoner == 1 then
			if (unit.charName == Exhaust) and ComboKey and (myHero:CanUseSpell(Exhaust) == READY) and ValidTarget(unit) then
				CastSpell(Exhaust, unit)
			end
		elseif Param.Miscellaneous.Summoner == 2 then
			if (unit.charName == ExhaustI) and ComboKey and (myHero:CanUseSpell(Exhaust) == READY) and ValidTarget(unit) then
				CastSpell(Exhaust, unit)
			end
		end
	end
	if Ignite then
		if Param.Miscellaneous.Summoner == 1 then
			if ComboKey and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) and (unit.charName == Ignite or unit.lifeSteal > 9) then
				CastSpell(Ignite, unit)
			end
		end
	end
end

function CalcSpellDamage(enemy)
	if not enemy then return end 
		return ((myHero:GetSpellData(_Q).level >= 1 and myHero:CalcMagicDamage(enemy, (40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap))) or 0), ((myHero:GetSpellData(_R).level >= 1 and myHero:CalcMagicDamage(enemy, (100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap))) or 0)
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
	Qdmg = ((40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap) or 0)
	Rdmg = ((100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap) or 0)
    local damage = Qdmg + Rdmg
    local SPos, EPos = GetEnemyHPBarPos(enemy)
    if not SPos then return end
    local barwidth = EPos.x - SPos.x
    local Position = SPos.x + math.max(0, (enemy.health - damage) / enemy.maxHealth * barwidth)
    DrawText("=", 16, math.floor(Position), math.floor(SPos.y + 8), ARGB(255,0,255,0))
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
				Qdmg = ((40 * myHero:GetSpellData(_Q).level + 10 * myHero:GetSpellData(_R).level + .5 * myHero.ap) or 0)
				Rdmg = ((100 * myHero:GetSpellData(_R).level + 50 + .5 * myHero.ap) or 0)
				AAdmg = (myHero.level * 9 + 0.2 * myHero.ap)
				if AADmg > enemy.health then
					KillText[i] = 1
				elseif iDmg > enemy.health then
					KillText[i] = 2
				elseif Qdmg > enemy.health then
					KillText[i] = 3
				elseif Qdmg + iDmg > enemy.health then
					KillText[i] = 4
				elseif Qdmg + Rdmg > enemy.health then
					KillText[i] = 5
				elseif Qdmg + Rdmg + iDmg > enemy.health then
					KillText[i] = 6
				elseif Qdmg + Rdmg + iDmg + AADmg > enemy.health then
					KillText[i] = 7
				else
					KillText[i] = 8
				end 
			end 
		end 
	end 
end

function OnDraw()
	if not Param.drawing.Enable then
		if not myHero.dead then
			if Param.Miscellaneous.Enable and Param.Logic == 1 then
				DrawText3D("MODE : "..CurrentMode.."", myHero.x-100, myHero.y-50, myHero.z, 20, 0xFFFFFFFF)
			end
			if myHero:CanUseSpell(_Q) == READY and Param.drawing.Qdraw then 
				DrawCircle(myHero.x, myHero.y, myHero.z, 850, RGB(200, 0, 0))
			end
			if myHero:CanUseSpell(_W) == READY and Param.drawing.Wdraw then 
				DrawCircle(myHero.x, myHero.y, myHero.z, 1000, RGB(200, 0, 0))
			end
			if myHero:CanUseSpell(_E) == READY and Param.drawing.Edraw then 
				DrawCircle(myHero.x, myHero.y, myHero.z, 350, RGB(200, 0, 0))
			end
			if myHero:CanUseSpell(_R) == READY and Param.drawing.Rdraw then
				DrawCircle(myHero.x, myHero.y, myHero.z, 1000, RGB(200, 0, 0))
			end
			if Param.drawing.AAdraw then
				DrawCircle3D(myHero.x, myHero.y, myHero.z, range, 1, ARGB(0xff, 0xff, 0xff, 0xff), nil)
			end
			if target ~= nil and ValidTarget(target) then
				if Param.drawing.Current then
					DrawText3D("ACTUAL BITCH",target.x-100, target.y-50, target.z, 20, 0xFFFFFFFF) -- Acknowledgments to http://forum.botoflegends.com/user/25371-big-fat-corki/ and his Mark IV script for giving me the idea of the target name.
				end
			end
			if Param.drawing.drawKillable then
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
			if Param.drawing.drawDamage then 
				for i, enemy in ipairs(GetEnemyHeroes()) do
					if enemy and ValidTarget(enemy) then
						DrawIndicator(enemy)
					end
				end
			end
		end
	end
end

function OnRemoveBuff(unit, buff)
	if buff.name == "sonapassiveattack" then
		passivecount = 0
	end
	if myHero:CanUseSpell(_E) == READY and Param.Miscellaneous.ESettings.Fast then
	 	if unit and unit.valid and unit.isMe and buff.name == "recall" then
	 		DelayAction(function() CastSpell(_E) end, 10)
		end
	end
end

function OnUpdateBuff(unit, buff)
	if buff.name == "sonapassivecount" then
		passivecount = passivecount + 1
	end
end

function OnProcessSpell(unit, spell)
	if passivecount >= 2 then
		if spell.name == "SonaQ" then
		lastspell = "SonaQ"
		elseif spell.name == "SonaW" then
			lastspell = "SonaW"
		elseif spell.name == "SoneE" then
			lastspell = "SonaE"
		end
	end
end

function OnProcessAttack(object, spell)
	if object.isMe and spell.name:lower():find("attack") then
		lastAttack = GetTickCount() - GetLatency() * 0.5
		lastWindUpTime = spell.windUpTime * 1000
		lastAttackCD = spell.animationTime * 1000		 
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

function OnWndMsg(msg, key)
	if key == 89 then
		if CurrentMode == "DMGS" then
			CurrentMode = "SLOW"
			Param.Miscellaneous.CurrentSwitch = 2
		elseif CurrentMode == "SLOW" then
			CurrentMode = "EXHT"
			Param.Miscellaneous.CurrentSwitch = 3
		elseif CurrentMode == "EXHT" then
			CurrentMode = "DMGS"
			Param.Miscellaneous.CurrentSwitch = 1
		end
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
        	if Ignite or Exhaust then
	        	if MenuPerso == "Premier" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n1", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Second"
	        		n1 = hero.charName
	        	elseif MenuPerso == "Second" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n2", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Troisieme"
	        		n2 = hero.charName
	        	elseif MenuPerso == "Troisieme" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n3", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Quatrieme"
	        		n3 = hero.charName
	        	elseif MenuPerso == "Quatrieme" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n4", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "Cinquieme"
	        		n4 = hero.charName
	        	elseif MenuPerso == "Cinquieme" then
	        		Param.Miscellaneous.SummonerSetting:addParam("n5", hero.charName, SCRIPT_PARAM_ONOFF, false)
	        		MenuPerso = "0"
	        		n5 = hero.charName
	        	end
	        end
        end
    end
end

function arrangePrioritys()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        SetPriority(priorityTable.AD_Carry, enemy, 1)
        SetPriority(priorityTable.AP_Carry, enemy, 2)
        SetPriority(priorityTable.Support, enemy, 3)
        SetPriority(priorityTable.Bruiser, enemy, 4)
        SetPriority(priorityTable.Tank, enemy, 5)
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
 	if VIP_USER and os.clock()-Last_LevelSpell > 0.5 then
    	autoLevelSetSequence(levelSequence)
    	Last_LevelSpell = os.clock()
  	end
end

_G.LevelSpell = function(id)
	if (string.find(GetGameVersion(), 'Releases/6.3') ~= nil) then
		local offsets = { 
			[_Q] = 0x9C,
			[_W] = 0x7C,
			[_E] = 0xA5,
			[_R] = 0xC4,
		}
		local p = CLoLPacket(0x0016)
		p.vTable = 0xF3C42C
		p:EncodeF(myHero.networkID)
		p:Encode4(0x99)
		p:Encode1(0x83)
		p:Encode4(0x20)
		p:Encode1(offsets[id])
		p:Encode4(0xEB)
		SendPacket(p)
	end
end

function AutoLvlSpellCombo()
	if Param.Miscellaneous.AutoSpell.Combo == 1 then
		levelSequence =  { 1,2,1,3,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
	else return end
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

--===START UPDATE CLASS===--
class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function ScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function ScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end
--====END UPDATE CLASS====--
