--- Starting AutoUpdate.
local version = "0.02"
local author = "spyk"
local SCRIPT_NAME = "BaguetteIgnite"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.githubusercontent.com"
local UPDATE_PATH = "/spyk1/BoL/master/BaguetteTools/BaguetteIgnite.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/spyk1/BoL/master/BaguetteTools/BaguetteIgnite.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				EnvoiMessage("New version available "..ServerVersion)
				EnvoiMessage(">>Updating, please don't press F9<<")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () EnvoiMessage("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
				whatsnew = 1
			else
				DelayAction(function() EnvoiMessage("Hello, "..GetUser()..". You got the latest version! :) ("..ServerVersion..") Enjoy you'r game!") end, 3)
			end
		end
		else
			EnvoiMessage("Error downloading version info")
	end
end
 --- End Of AutoUpdate.

function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteIgnite]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function OnLoad()

	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteIgnite]</b></font> <font color=\"#ffffff\">by spyk</font>")

	if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then Ignite = SUMMONER_2 end

	Menu = scriptConfig("[Baguette] Ignite", "BaguetteIgnite")

	Menu:addParam("Use", "Enable Auto Ignite Finisher ?", SCRIPT_PARAM_ONOFF, true)

	Menu:addParam("Draw", "Enable Ignite Range Draw ?", SCRIPT_PARAM_ONOFF, true)

end

function OnUnload()
	EnvoiMessage(">>Unloaded<<")
end

function Ignite()
	for _, unit in pairs(GetEnemyHeroes()) do
		health = unit.health
		if GetDistance(unit) <= 600 then
			if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") or myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
				if health < 40 + (20 * myHero.level) and Param.KillSteal.UseIgnite and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) then
					CastSpell(Ignite, unit)
					EnvoiMessage("Casted Ignite.")
				end
			end
		end
	end
end

function OnTick()
	if Menu.Use then
		Ignite()
	end
end

function OnDraw()
	if not myHero.dead and Menu.Draw then
		if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") or myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
			DrawCircle(myHero.x, myHero.y, myHero.z, 600, RGB(200, 0, 0))
		end
	end
end
