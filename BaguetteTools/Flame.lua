-- 11/03 SendChat() broken need to do with packets 
-- 27/03 Working
-- 30/03 Added comment in the code if you want to add anothers messages.
-- 21/04 Also, This script was requested by discord people's, then, I took message from them, I'm not a flamer Kappa

-- You can also do this script with a tab, but it's more easy for new peoples to understand how flame.lua is working with this way, tabs are usefull with many values.
local Last_MSG_Check = 0
local Last_Kill_Check = 0

function OnLoad()
	Last_Kill_Check = myHero:GetInt("CHAMPIONS_KILLED")
	PrintChat("<font color=\"#e74c3c\"><b>[Flame]</b></font> <font color=\"#ffffff\">Loaded (by spyk)</font>")
end

function OnTick()
	if os.clock() > Last_MSG_Check then
		if myHero:GetInt("CHAMPIONS_KILLED") > Last_Kill_Check then
			local MSG_Rand = math.random(1,8) -- Modify the last number, by default 8, and input you'r total of message.
			if MSG_Rand > 0 then
				if MSG_Rand == 1 then
					SendChat("/ALL Your mother is a whore")
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
				-- elseif MSG_Rand == '9 or more depend of the number before' then
				--	SendChat("(MSG)")
				end
				Last_Kill_Check = myHero:GetInt("CHAMPIONS_KILLED")
			end
		else 
			return
		end
		Last_MSG_Check = os.clock() + 0.5
	end
end
