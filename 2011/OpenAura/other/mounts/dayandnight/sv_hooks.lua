--[[
Name: "sv_hooks.lua".
Product: "blueprint".
--]]

local PLUGIN = PLUGIN;

-- Called when the map has loaded all the entities.
function PLUGIN:InitPostEntity()
	if ( blueprint.config.Get("daynight_enabled"):Get() ) then
		self.lightEnvironments = ents.FindByClass("light_environment");
		self.shadowControl = ents.FindByClass("shadow_control")[1];
		self.suns = ents.FindByClass("env_sun");
		
		if ( !IsValid(self.shadowControl) ) then
			self.shadowControl = ents.Create("shadow_control");
		end;
		
		if (self.lightEnvironments) then
			for k, v in pairs(self.lightEnvironments) do
				v:Fire("FadeToPattern", string.char(LIGHT_LOW), 0);
				v:Activate();
			end;
		end;
		
		if (self.suns) then
			for k, v in pairs(self.suns) do
				v:SetKeyValue("material", "sprites/light_glow02_add_noz.vmt");
				v:SetKeyValue("overlaymaterial", "sprites/light_glow02_add_noz.vmt");
			end;
		end;
		
		self:BuildLightTable();
	end;
end;

-- Called when an entity's key value is defined.
function PLUGIN:EntityKeyValue(entity, key, value)
	if ( blueprint.config.Get("daynight_enabled"):Get() ) then
		local class = entity:GetClass();
		
		if (class == "worldspawn" and key == "skyname") then
			timer.Simple(FrameTime() * 0.5, function()
				BLUEPRINT:SetSharedVar("sh_SkyName", value);
			end);
		elseif ( string.find(class, "light") ) then
			if (key == "nightlight") then
				self.nightLights = self.nightLights or {};
				self.nightLights[#self.nightLights + 1] = entity;
				
				entity:Fire("TurnOff", "", 0);
			end;
		end;
	end;
end;