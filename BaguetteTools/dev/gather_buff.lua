function OnApplyBuff(source, unit, buff)
	if unit and unit.isMe then
		print("Apply : "..buff.name);
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe then
		print("Remove : "..buff.name);
	end
end

function OnUpdateBuff(unit, buff, stacks)
	if unit and unit.isMe then
		print("Upd : "..buff.name);
	end
end

function OnAnimation(unit, animation)
	if unit and unit.isMe then
		print("Anim : "..animation);
	end
end

function OnLoad()
	print("Little debugger loaded");
end
