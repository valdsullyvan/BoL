AddTickCallback(function()
	if myHero:CanUseSpell(_Q) == READY then
	  CastSpell(_Q)
	end
end)
