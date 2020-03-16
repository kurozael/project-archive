--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when a player earns cash from the generator.
function ENT:OnEarned(player, cash)
	if (cash > 0) then
		local entityPosition = self:GetPos();
		local endPosition = entityPosition + (self:GetUp() * 128);
		local traceLine = util.TraceLine({
			endpos = endPosition,
			filter = self,
			start = entityPosition,
			mask = MASK_NPCWORLDSTATIC
		});
		
		Clockwork.entity:CreateCash(player, cash, traceLine.HitPos - (self:GetUp() * 64), self:GetAngles());
		return true;
	end;
end;

-- Called when the damage should be adjusted.
function ENT:AdjustDamage(damageInfo)
	local bCashGuarder = true;
	local curTime = CurTime();
	
	for k, v in ipairs(ents.FindByClass("cw_cash_guarder")) do
		if (self:GetPos():Distance(v:GetPos()) < 512) then
			local owner = Clockwork.entity:GetOwner(v);
			
			if (IsValid(owner) and !owner.cwNextCashAlert
			or curTime >= owner.cwNextCashAlert) then
				Clockwork.chatBox:Add(owner, nil, "alert",
					"Your cash guarder has detected that a generator is under attack!"
				);
				owner.cwNextCashAlert = curTime + 60;
			end;
			
			bCashGuarder = true;
		end;
	end;
	
	if (bCashGuarder) then
		damageInfo:ScaleDamage(0.5);
	end;
end;