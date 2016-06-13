function ManaManager(Mode, Spell)
	local String = "Param."..""..Mode..".Mana"..Spell..""
	if myHero.mana < (myHero.maxMana * (Mv(String) / 100)) then
		return true
	else
		return false
	end
end

function Mv(String)
	return string.byte(String)
end

-- Exemple


-- Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 80, 0, 100);
-- if not ManaManager("Harass", "E") then.... end
