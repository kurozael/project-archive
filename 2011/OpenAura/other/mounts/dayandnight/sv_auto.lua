--[[
Name: "sv_auto.lua".
Product: "blueprint".
--]]

local PLUGIN = PLUGIN;

BLUEPRINT:IncludePrefixed("sh_auto.lua");

-- Whether or not to enable day and night.
blueprint.config.Add("daynight_enabled", false, nil, nil, nil, nil, true);

-- A function to build the light table.
function PLUGIN:BuildLightTable()
	self.lightTable = {};
	
	for i = 1, DAY_LENGTH do
		self.lightTable[i] = {};
		
		local shadowColor = 255;
		local skyAlpha = math.floor( math.Clamp(math.abs( (i - NOON_EXACT) / NOON_EXACT ), 0, 0.7) );
		local pattern = string.char(LIGHT_LOW);
		local green = 255;
		local blue = 255;
		local red = 255;
		
		if (i >= DAY_START and i < NOON_EXACT) then
			local progress = (NOON_EXACT - i) / (NOON_EXACT - DAY_START);
			local letterProgress = 1 - math.EaseInOut(progress, 0, 1);
			
			pattern = ( (LIGHT_HIGH - LIGHT_LOW) * letterProgress ) + LIGHT_LOW;
			pattern = string.char( math.ceil(pattern) );
		elseif (i >= NOON_EXACT and i < DAY_END) then
			local progress = (i - NOON_EXACT) / (DAY_END - NOON_EXACT);
			local letterProgress = 1 - math.EaseInOut(progress, 0, 1);
			
			pattern = ( (LIGHT_HIGH - LIGHT_LOW) * letterProgress ) + LIGHT_LOW;
			pattern = string.char( math.ceil(pattern) );
		end;
		
		if (i >= DAWN_START and i <= DAWN_END) then
			local fraction = (i - DAWN_START) / (DAWN_END - DAWN_START);
			
			if (i < DAWN_EXACT) then
				green = 128 * fraction;
				red = 200 * fraction;
			else
				green = 128 - (128 * fraction);
				red = 200 - (200 * fraction);
			end;
		elseif (i >= DUSK_START and i <= DUSK_END) then
			local fraction = (i - DUSK_START) / (DUSK_END - DUSK_START);
			
			if (i < DUSK_EXACT) then
				red = 85 * fraction;
			else
				red = 85 - (85 * fraction);
			end;
		elseif (i >= DUSK_END or i <= DAWN_START) then
			if (i > DUSK_END) then
				blue = 30 * ( (i - DUSK_END) / (DAY_LENGTH - DUSK_END) );
			else
				blue = 30 - ( 30 * (i / DAWN_START) );
			end;
		end;
		
		if (i > DAWN_EXACT and i < DUSK_EXACT) then
			if (i < NOON_EXACT) then
				shadowColor = math.floor( 255 - ( ( (i - DAWN_EXACT) / (NOON_EXACT - DAWN_EXACT) ) * 127 ) );
			else
				shadowColor = math.floor( 128 + ( ( (i - NOON_EXACT) / (DUSK_EXACT - NOON_EXACT) ) * 127 ) );
			end;
		end;
		
		self.lightTable[i].skyColor = Vector( math.floor(red / 255), math.floor(green / 255), math.floor(blue / 255) );
		self.lightTable[i].skyColor.x = math.Clamp(self.lightTable[i].skyColor.x, 0.2, 1);
		self.lightTable[i].skyColor.y = math.Clamp(self.lightTable[i].skyColor.y, 0.2, 1);
		self.lightTable[i].skyColor.z = math.Clamp(self.lightTable[i].skyColor.z, 0.2, 1);
		self.lightTable[i].pattern = pattern;
		
		self.lightTable[i].shadowLength = tostring(skyAlpha * 300);
		self.lightTable[i].shadowAngle = math.Approach( -1, 1, (NOON_EXACT / i) ).." 0 -1";
		self.lightTable[i].shadowColor = shadowColor.." "..shadowColor.." "..shadowColor;
		
		self.lightTable[i].sunAngle = (i / DAY_LENGTH) * 360;
		self.lightTable[i].sunAngle = self.lightTable[i].sunAngle + 90;
		
		if (self.lightTable[i].sunAngle > 360) then
			self.lightTable[i].sunAngle = self.lightTable[i].sunAngle - 360;
		end;
		
		self.lightTable[i].sunAngle = "pitch "..self.lightTable[i].sunAngle;
	end;
	
	self.entity = ents.Create("bp_daynight");
	self.entity:SetPos( Vector(0, 0, -2048) );
	self.entity:Spawn();
end;

-- A function to make a light flicker.
function PLUGIN:MakeLightFlicker(entity)
	local pattern;
	local delay = math.random(0, 400) * 0.01;
	
	if (math.random(1, 2) == 1) then
		pattern = "az";
	else
		pattern = "za";
	end;
	
	entity:Fire("SetPattern", pattern, delay);
	entity:Fire("TurnOn", "", delay);
	
	timer.Simple(delay, function()
		if ( IsValid(entity) ) then
			entity:EmitSound( "buttons/button1.wav", math.random(70, 80), math.random(95, 105) );
		end;
	end);
	
	entity:Fire("SetPattern", "z", delay + math.random(10, 50) * 0.0);
end;

-- A function to turn the lights on.
function PLUGIN:TurnLightsOn()
	if (!self.lightsOn and self.nightLights) then
		for k, v in pairs(self.nightLights) do
			if ( IsValid(v) ) then
				self.makeLightFlicker(v);
			end;
		end;
		
		self.lightsOn = true;
	end;
end;

-- A function to turn the lights off.
function PLUGIN:TurnLightsOff()
	if (self.lightsOn and self.nightLights) then
		for k, v in pairs(self.nightLights) do
			if ( IsValid(v) ) then
				v:Fire("TurnOff", "", 0);
			end;
		end;
		
		self.lightsOn = nil;
	end;
end;

-- A function to calculate the light.
function PLUGIN:CalculateLight()
	local minute = (blueprint.time.GetHour() * 60) + blueprint.time.GetMinute();
	
	if ( self.lightTable[minute] ) then
		local pattern = self.lightTable[minute].pattern;
		
		if (self.lightEnvironments and self.pattern != pattern) then
			for k, v in pairs(self.lightEnvironments) do
				if ( IsValid(v) ) then
					v:Fire("FadeToPattern", pattern, 0);
					v:Activate();
				end;
			end;
		end;
		
		local shadowLength = self.lightTable[minute].shadowLength;
		local shadowAngle = self.lightTable[minute].shadowAngle;
		local shadowColor = self.lightTable[minute].shadowColor;
		local skyColor = self.lightTable[minute].skyColor;
		local sunAngle = self.lightTable[minute].sunAngle;
		
		if ( IsValid(self.shadowControl) ) then
			self.shadowControl:Fire("SetDistance", shadowLength, 0);
			self.shadowControl:Fire("Direction", shadowAngle, 0);
			self.shadowControl:Fire("Color", shadowColor, 0);
		end;
		
		if (self.suns and self.sunAngle != sunAngle) then
			for k, v in pairs(self.suns) do
				v:Fire("AddOutput", sunAngle, 0);
				v:Activate();
			end;
		end;
		
		BLUEPRINT:SetSharedVar("sh_SkyColor", skyColor);
		
		self.sunAngle = sunAngle;
		self.pattern = pattern;
		
		if (minute >= DUSK_EXACT or minute < DAWN_EXACT) then
			self:TurnLightsOn();
		else
			self:TurnLightsOff();
		end;
	end;
end;