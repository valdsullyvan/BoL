function ManaManager(Mode, Spell)
	local reqMana = Param[Mode] and Param[Mode]["Mana"..Spell] or 101
	if 100 * myHero.mana / myHero.maxMana >= reqMana then
		return true
	else
		return false
	end
end

-- Credit Nebelwolfi!

-- Exemple


-- Param.Harass:addParam("ManaE", "Set a value for (E) in Mana :", SCRIPT_PARAM_SLICE, 80, 0, 100);
-- if not ManaManager("Harass", "E") then.... end
