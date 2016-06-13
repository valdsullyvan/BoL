AddDrawCallback(function() self:OnDraw() end);
AddTickCallback(function() self:OnTick() end);
AddLoadCallback(function() self:OnLoad() end);
AddUnloadCallback(function() self:Unload() end);
AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end);
AddAnimationCallback(function(unit, action) self:Animation(unit, action) end);
AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end);
AddProcessAttackCallback(function(unit, spell) self:OnProcessAttack(unit, spell) end)
AddMsgCallback(function(msg,key) self:OnWndMsg(msg,key) end);
AddSendPacketCallback(function(p) self:OnSendPacket(p) end);
AddRecvPacketCallback(function(p) self:OnRecvPacket(p) end);
AddCreateObjCallback(function(object) self:OnCreateObj(object) end);
AddDeleteObjCallback(function(object) self:OnDeleteObj(object) end);
AddChatCallback(function(msg, prefix) self:OnSendChat(msg, prefix) end);
