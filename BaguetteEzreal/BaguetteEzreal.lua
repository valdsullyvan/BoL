function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteKalista]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function OnLoad()
	Param = scriptConfig("[Baguette] Ezreal", "BaguetteEzreal")
		Param:addParam("Enable", "Enable Q spell in combo ?", SCRIPT_PARAM_ONOFF, true)
		Param:addParam("Harass", "Harass Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
	print("BaguetteEz loaded")
	enemyMinions = minionManager(MINION_ENEMY, 3000, myHero, MINION_SORT_HEALTH_ASC)
	jungleMinions = minionManager(MINION_JUNGLE, 3000, myHero, MINION_SORT_MAXHEALTH_DEC)
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_MAGIC)
	ts.name = "Kalista"
	Param:addTS(ts)
	LoadVPred()
	LoadNEBOrb()
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

function Keys()
	if _G.AutoCarry and _G.AutoCarry.Keys and _G.Reborn_Loaded ~= nil then
		if _G.AutoCarry.Keys.AutoCarry then 
			Combo(Target)
		elseif  _G.AutoCarry.Keys.MixedMode then 
			Harass()
		elseif  _G.AutoCarry.Keys.LaneClear then 
			Harass()
		elseif  _G.AutoCarry.Keys.LastHit then 
			Harass()
		end
	end
end

function OnTick()
	if myHero.dead then return end
	ts:update()
	Target = GetCustomTarget()
	KillSteal()
	Keys()
	if Param.Harass then
		Harass()
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and GetDistance(Target) < SkillQ.range and not unit.dead then
		local castPos, HitChance, pos = VP:GetLineCastPosition(Target, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
		if HitChance >= 2 then
			CastSpell(_Q, castPos.x, castPos.z)
		end
	end
end

SkillQ = { name = "Mystic Shot", range = 1150, delay = 0.5, speed = 1200, width = 80, ready = false}

function KillSteal()
	for _, unit in pairs(GetEnemyHeroes()) do
		local health = unit.health
		local dmgQ = getDmg("Q", myHero, unit) + ((myHero.damage)*1.1) + ((myHero.ap)*0.4)
		if health < dmgQ and GetDistance(unit) < SkillQ.range and unit ~= nil and not unit.dead  then
			local castPos, HitChance, pos = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
			if HitChance >= 2 then
				CastSpell(_Q, castPos.x, castPos.z)
			end
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and GetDistance(unit) < SkillQ.range and not unit.dead  then
		local castPos, HitChance, pos = VP:GetLineCastPosition(Target, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
		if HitChance >= 3 then
			CastSpell(_Q, castPos.x, castPos.z)
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

function OnWndMsg(msg, key)
	if key == 32 then
		Combo(Target)
	end
end
