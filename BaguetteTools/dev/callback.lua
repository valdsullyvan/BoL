-- To use Draw function callback
AddDrawCallback(function() self:OnDraw() end);
-- Each tick callback
AddTickCallback(function() self:OnTick() end);
-- Load callback
AddLoadCallback(function() self:OnLoad() end);
AddUnloadCallback(function() self:Unload() end);
-- Path callback
AddNewPathCallback(function(unit, startPos, endPos, isDash ,dashSpeed,dashGravity, dashDistance) self:OnNewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance) end);
-- Champ callback
AddAnimationCallback(function(unit, action) self:Animation(unit, action) end);
AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end);
AddProcessAttackCallback(function(unit, spell) self:OnProcessAttack(unit, spell) end)
-- Keyboard / Mouse
AddMsgCallback(function(msg,key) self:OnWndMsg(msg,key) end);
-- Packets
AddSendPacketCallback(function(p) self:OnSendPacket(p) end);
AddRecvPacketCallback(function(p) self:OnRecvPacket(p) end);
AddRecvPacketCallback2(function(p) self:OnRecvPacket2(p) end);
-- Objects
AddCreateObjCallback(function(object) self:OnCreateObj(object) end);
AddDeleteObjCallback(function(object) self:OnDeleteObj(object) end);
-- Chat
AddChatCallback(function(msg, prefix) self:OnSendChat(msg, prefix) end);
-- Buff
AddApplyBuffCallback(function(source, unit, buff) self:OnApplyBuff(source, unit, buff) end);
AddRemoveBuffCallback(function(unit, buff) self:OnRemoveBuff(unit, buff) end);
AddUpdateBuffCallback(function(unit, buff, stacks) self:OnUpdateBuff(unit, buff, stacks) end):
