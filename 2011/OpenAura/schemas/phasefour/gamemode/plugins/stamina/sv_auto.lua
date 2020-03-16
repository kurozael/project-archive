--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

local playerMeta = FindMetaTable("Player");

-- A function to handle a player's implants.
function playerMeta:HandleImplants()
	local thermalVision = self:GetWeapon("aura_thermalvision");
	local stealthCamo = self:GetWeapon("aura_stealthcamo");
	local isRagdolled = self:IsRagdolled();
	local isAlive = self:Alive();
	
	if (ValidEntity(thermalVision) and thermalVision:IsActivated() and isAlive and !isRagdolled) then
		if (self:GetCharacterData("stamina") > 5) then
			self:SetSharedVar("thermal", true);
		else
			self:EmitSound("items/nvg_off.wav");
			thermalVision:SetActivated(false);
		end;
	else
		self:SetSharedVar("thermal", false);
	end;
	
	if (ValidEntity(stealthCamo) and stealthCamo:IsActivated() and isAlive and !isRagdolled) then
		if (self:GetCharacterData("stamina") > 5) then
			if (!self.lastMaterial) then
				self.lastMaterial = self:GetMaterial();
			end;
			
			if (!self.lastColor) then
				self.lastColor = { self:GetColor() };
			end;
			
			self:SetMaterial("sprites/heatwave");
			self:SetColor(255, 255, 255, 0);
		else
			self:EmitSound("items/nvg_off.wav");
			stealthCamo:SetActivated(false);
		end;
	elseif (self.lastMaterial and self.lastColor) then
		self:SetMaterial(self.lastMaterial);
		self:SetColor( unpack(self.lastColor) );
		
		self.lastMaterial = nil;
		self.lastColor = nil;
	end;
end;