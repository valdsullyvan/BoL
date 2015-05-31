function OnLoad
	myEnemyTable = GetEnemyHeroes()
	myLastMessage = { }
	for i, data in pairs(myEnemyTable) do
		myLastMessage[i] = 0
	end
end

function OnTick()
	for i, data in pairs(myEnemyTable) do
		if ValidTarget(data) and GetDistance(data) <= 400 then
			local dmg = getDmg("R", data, myHero)
			if data.health <= dmg*0.99 and os.clock() - myLastMessage[i] > 1 then
				print("<font color=\"#FE2E64\"><b>[Garen]"..tostring(data.charName).." - </b></font><font color=\"#FA58D0\">is Killable with Ultimate </b></font>")
				myLastMessage[i] = os.clock()
			end
		end
	end
end
