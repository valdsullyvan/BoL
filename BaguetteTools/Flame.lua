-- 11/03 SendChat() broken need to do with packets
local Last_MSG_Check = 0
local Last_Kill_Check = 0

function OnLoad()
	SendChat("/mute all")
	print("loaded")
end

function OnTick()
	SendChat("/mute all")
	if os.clock() > Last_MSG_Check then
		if myHero:GetInt("CHAMPIONS_KILLED") > Last_Kill_Check then
			local MSG_Rand = math.random(1,8)
			if MSG_Rand > 0 then
				if MSG_Rand == 1 then
					SendChat("Your mother is a whore")
				elseif MSG_Rand == 2 then
					SendChat("/ALL Cya stupid noob")
				elseif MSG_Rand == 3 then
					SendChat("/ALL The bottom lane belongs to me")
				elseif MSG_Rand == 4 then
					SendChat("/ALL Get Rekt trash feeding noob")
				elseif MSG_Rand == 5 then
					SendChat("/ALL EZ")
				elseif MSG_Rand == 6 then
					SendChat("/ALL RIP trash feeder")
				elseif MSG_Rand == 7 then
					SendChat("/ALL Summoner's Rift is in my control")
				elseif MSG_Rand == 8 then
					SendChat("/ALL Get rekt you victim of sexual molestation")
				end
				Last_Kill_Check = myHero:GetInt("CHAMPIONS_KILLED")
			end
		else 
			return
		end
		Last_MSG_Check = os.clock() + 0.5
	end
end
