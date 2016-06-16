if ((Target ~= nil) and (GetDistance(Target) < 1050)) then
	enemyMinions:update();
	for i, minion in pairs(enemyMinions.objects) do
		if ((minion ~= nil) and (GetDistance(minion) < SkillQ.range)) then
			AB = math.sqrt((Target.x-myHero.x)*(Target.x-myHero.x)+(Target.y-myHero.y)*(Target.y-myHero.y)+(Target.z-myHero.z)*(Target.z-myHero.z));
			AP = math.sqrt((minion.x-myHero.x)*(minion.x-myHero.x)+(minion.y-myHero.y)*(minion.y-myHero.y)+(minion.z-myHero.z)*(minion.z-myHero.z));
			PB = math.sqrt((Target.x-minion.x)*(Target.x-minion.x)+(Target.y-minion.y)*(Target.y-minion.y)+(Target.z-minion.z)*(Target.z-minion.z));
			if ((AB > AP+PB-5) or (AB > AP+PB+5)) then
				CastSpell(iSpell, minion);
			end
		end
	end
end

-- Casting through minion
