--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	self:DrawShadow(true);
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:SetUseType(SIMPLE_USE);
end

-- A function to setup the salesman.
function ENT:SetupSalesman(name, physDesc, animation, showChatBubble)
	self:SetSharedVar("name", name);
	self:SetSharedVar("physDesc", physDesc);
	self:SetupAnimation(animation);
	
	if (showChatBubble) then
		self:MakeChatBubble();
	end;
end;

-- A function to talk to a player.
function ENT:TalkToPlayer(player, text, default)
	openAura.player:Notify(player, self:GetSharedVar("name").." says \""..(text or default).."\"");
end;

-- Called to setup the animation.
function ENT:SetupAnimation(animation)
	if (animation and animation != -1) then
		self:ResetSequence(animation);
	else
		self:ResetSequence(4);
	end;
end;

-- Called to make the chat bubble.
function ENT:MakeChatBubble()
	self.ChatBubble = ents.Create("aura_chatbubble");
	self.ChatBubble:SetParent(self);
	self.ChatBubble:SetPos( self:GetPos() + Vector(0, 0, 90) );
	self.ChatBubble:Spawn();
end;

-- A function to get the chat bubble.
function ENT:GetChatBubble()
	return self.ChatBubble;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( IsValid(activator) and activator:IsPlayer() ) then
		if (activator:GetEyeTraceNoCursor().HitPos:Distance( self:GetPos() ) < 196) then
			if (openAura.plugin:Call("PlayerCanUseSalesman", activator, self) != false) then
				openAura.plugin:Call("PlayerUseSalesman", activator, self);
			end;
		end;
	end;
end;