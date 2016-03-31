AddLoadCallback(function() 

	print("<font color=\"#ffffff\">Loading</font><font color=\"#e74c3c\"><b> [Snowball Caster]</b></font> <font color=\"#ffffff\">by spyk</font>")


	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerSnowball") then Ball = SUMMONER_1 elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerSnowball") then Ball = SUMMONER_2 end

	require("VPrediction")

	VP = VPrediction()

	Param = scriptConfig("Snowball!", "Snowball")

	Param:addParam("Use", "Snowball Key :", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
	Param:setCallback("Use", function (DT)
		if DT then
			CastSnowball()
		end
	end)
end)

function CastSnowball()
	for _, unit in pairs(GetEnemyHeroes()) do
		if GetDistance(unit) < 1600 then
			local castPos, HitChance, pos = VP:GetLineCastPosition(unit, 0.33, 50, 1600, 1600, myHero, true)
			if HitChance >= 2 then
				CastSpell(Ball, castPos.x, castPos.z)
			end
		end
	end
end
