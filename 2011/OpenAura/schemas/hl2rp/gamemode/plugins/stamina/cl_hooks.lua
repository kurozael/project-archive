--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when the bars are needed.
function PLUGIN:GetBars(bars)
	local stamina = openAura.Client:GetSharedVar("stamina");
	
	if (!self.stamina) then
		self.stamina = stamina;
	else
		self.stamina = math.Approach(self.stamina, stamina, 1);
	end;
	
	if (self.stamina < 75) then
		bars:Add("STAMINA", Color(100, 175, 100, 255), "", self.stamina, 100, self.stamina < 10);
	end;
end;

-- Called each tick.
function PLUGIN:Tick()
	if ( IsValid(openAura.Client) ) then
		if ( openAura.schema:PlayerIsCombine(openAura.Client) ) then
			local curTime = CurTime();
			local stamina = openAura.Client:GetSharedVar("stamina");
			
			if (!self.nextStaminaWarning or curTime >= self.nextStaminaWarning) then
				if (self.lastStamina and self.lastStamina > 0 and stamina == 0) then
					openAura.schema:AddCombineDisplayLine( "WARNING! Internal power consumption exhausted...", Color(255, 0, 0, 255) );
					
					self.nextStaminaWarning = curTime + 5;
				elseif (self.lastStamina and self.lastStamina > 50 and stamina < 50) then
					openAura.schema:AddCombineDisplayLine( "WARNING! Internal power consumption high...", Color(255, 0, 0, 255) );
					
					self.nextStaminaWarning = curTime + 5;
				elseif (self.lastStamina and stamina > self.lastStamina) then
					if (stamina == 100) then
						openAura.schema:AddCombineDisplayLine( "Internal power restored...", Color(0, 255, 0, 255) );
					else
						openAura.schema:AddCombineDisplayLine( "Internal power regenerating...", Color(0, 0, 255, 255) );
					end;
					
					self.nextStaminaWarning = curTime + 5;
				end;
			end;
			
			self.lastStamina = stamina;
		end;
	end;
end;