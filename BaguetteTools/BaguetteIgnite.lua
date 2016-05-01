local LastMSG = 0

function EnvoiMessage(msg)
	PrintChat("<font color=\"#e74c3c\"><b>[BaguetteIgnite]</b></font> <font color=\"#ffffff\">" .. msg .. "</font>")
end

function OnLoad()

	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [BaguetteIgnite]</b></font> <font color=\"#ffffff\">by spyk</font>")

	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then Ignite = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then Ignite = SUMMONER_2 end

	Menu = scriptConfig("[Baguette] Ignite", "BaguetteIgnite")

	Menu:addParam("Use", "Enable Auto Ignite Finisher ?", SCRIPT_PARAM_ONOFF, true)

	Menu:addParam("Draw", "Enable Ignite Range Draw ?", SCRIPT_PARAM_ONOFF, true)

end

function OnUnload()
	EnvoiMessage(">>Unloaded<<")
end

function AutoIgnite()
	for _, unit in pairs(GetEnemyHeroes()) do
		health = unit.health
		if GetDistance(unit) <= 600 then
			if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") or myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
				if health+unit.shield < 40 + (20 * myHero.level) and (myHero:CanUseSpell(Ignite) == READY) and ValidTarget(unit) then
					CastSpell(Ignite, unit)
					if os.clock() - LastMSG > 2 then
						LastMSG = os.clock()
						EnvoiMessage("Casted Ignite.")
					end
				end
			end
		end
	end
end

function OnTick()
	if Menu.Use then
		AutoIgnite()
	end
end

function OnDraw()
	if not myHero.dead and Menu.Draw then
		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") or myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
			DrawCircle(myHero.x, myHero.y, myHero.z, 600, RGB(200, 0, 0))
		end
	end
end
