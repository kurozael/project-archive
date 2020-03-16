--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a HUD element should be drawn.
function PLUGIN:HUDShouldDraw(name)
	if (name == "CHudWeaponSelection") then
		return false;
	elseif (name == "CHudCrosshair") then
		if (self.displayAlpha > 0) then
			return false;
		end;
	end;
end;

-- Called when the important HUD should be painted.
function PLUGIN:HUDPaintImportant()
	local informationColor = CloudScript.option:GetColor("information");
	local activeWeapon = CloudScript.Client:GetActiveWeapon();
	local newWeapons = {};
	local colorWhite = CloudScript.option:GetColor("white");
	local frameTime = FrameTime();
	local weapons = CloudScript.Client:GetWeapons();
	local curTime = UnPredictedCurTime();
	local x = ScrW() / 3;
	local y = ScrH() / 3;
	
	if (IsValid(activeWeapon) and self.displayAlpha > 0) then
		CloudScript:OverrideMainFont( CloudScript.option:GetFont("menu_text_tiny") );
			for k, v in pairs(weapons) do
				local secondaryAmmo = CloudScript.Client:GetAmmoCount( v:GetSecondaryAmmoType() );
				local primaryAmmo = CloudScript.Client:GetAmmoCount( v:GetPrimaryAmmoType() );
				local clipOne = v:Clip1();
				local clipTwo = v:Clip2();
				
				if ( clipOne > 0 or clipTwo > 0 or (clipOne == -1 and clipTwo == -1)
				or (clipOne == -1 and clipTwo > 0 and secondaryAmmo > 0)
				or (clipTwo == -1 and clipOne > 0 and primaryAmmo > 0)
				or (clipOne != -1 and primaryAmmo > 0)
				or (clipTwo != -1 and secondaryAmmo > 0) ) then
					table.insert(newWeapons, v);
				end;
			end;
			
			if (self.displaySlot < 1) then
				self.displaySlot = #newWeapons;
			elseif (self.displaySlot > #newWeapons) then
				self.displaySlot = 1;
			end;
			
			local currentWeapon = newWeapons[self.displaySlot];
			local beforeWeapons = {};
			local afterWeapons = {};
			local weaponLimit = math.Clamp(#newWeapons, 2, 4);
			
			if (#newWeapons > 1) then
				for k, v in ipairs(newWeapons) do
					if (k < self.displaySlot) then
						table.insert(beforeWeapons, v);
					elseif (k > self.displaySlot) then
						table.insert(afterWeapons, v);
					end;
				end;
				
				if (#beforeWeapons < weaponLimit) then
					local i = 0;
					
					while (#beforeWeapons < weaponLimit) do
						local possibleWeapon = newWeapons[#newWeapons - i];
						
						if (possibleWeapon) then
							table.insert(beforeWeapons, 1, possibleWeapon);
							
							i = i + 1;
						else
							i = 0;
						end;
					end;
				end;
				
				if (#afterWeapons < weaponLimit) then
					local i = 0;
					
					while (#afterWeapons < weaponLimit) do
						local possibleWeapon = newWeapons[1 + i];
						
						if (possibleWeapon) then
							table.insert(afterWeapons, possibleWeapon);
							
							i = i + 1;
						else
							i = 0;
						end;
					end;
				end;
				
				while (#beforeWeapons > weaponLimit) do
					table.remove(beforeWeapons, 1);
				end;
				
				while (#afterWeapons > weaponLimit) do
					table.remove(afterWeapons, #afterWeapons);
				end;
				
				for k, v in ipairs(beforeWeapons) do
					y = CloudScript:DrawInfo(string.upper( self:GetWeaponPrintName(v) ), x, y, colorWhite, math.min( (255 / weaponLimit) * k, self.displayAlpha ), true);
				end;
			end;
			
			if ( IsValid(currentWeapon) ) then
				local currentWeaponName = string.upper( self:GetWeaponPrintName(currentWeapon) );
				local weaponInfoY = y;
				local weaponInfoX = x - 276;
				
				y = CloudScript:DrawInfo(currentWeaponName, x, y, informationColor, self.displayAlpha, true);
				
				CloudScript:OverrideMainFont(false);
					self:DrawWeaponInformation(CloudScript.item:GetWeapon(currentWeapon), currentWeapon, weaponInfoX, weaponInfoY, self.displayAlpha);
					
					if (#newWeapons == 1) then
						y = CloudScript:DrawInfo("There are no other weapons.", x, y, colorWhite, self.displayAlpha, true);
					end;
				CloudScript:OverrideMainFont( CloudScript.option:GetFont("menu_text_tiny") );
			end;
			
			if (#newWeapons > 1) then
				for k, v in ipairs(afterWeapons) do
					y = CloudScript:DrawInfo(string.upper( self:GetWeaponPrintName(v) ), x, y, colorWhite, math.min( 255 - ( (255 / weaponLimit) * k ), self.displayAlpha ), true);
				end;
			end;
		CloudScript:OverrideMainFont(false);
	end;
	
	if (self.displayAlpha > 0 and curTime >= self.displayFade) then
		self.displayAlpha = math.max(self.displayAlpha - (frameTime * 64), 0);
	end;
end;

-- Called when a player presses a bind at the top level.
function PLUGIN:TopLevelPlayerBindPress(player, bind, press)
	local activeWeapon = CloudScript.Client:GetActiveWeapon();
	local newWeapons = {};
	local curTime = UnPredictedCurTime();
	local weapons = CloudScript.Client:GetWeapons();
	
	if ( !IsValid(activeWeapon) ) then
		return;
	end;
	
	if ( CloudScript.Client:InVehicle() ) then
		return;
	end;
	
	if (activeWeapon:GetClass() == "weapon_physgun") then
		if ( player:KeyDown(IN_ATTACK) ) then
			return;
		end;
	end;
	
	for k, v in pairs(weapons) do
		local secondaryAmmo = CloudScript.Client:GetAmmoCount( v:GetSecondaryAmmoType() );
		local primaryAmmo = CloudScript.Client:GetAmmoCount( v:GetPrimaryAmmoType() );
		local clipOne = v:Clip1();
		local clipTwo = v:Clip2();
		
		if ( clipOne > 0 or clipTwo > 0 or (clipOne == -1 and clipTwo == -1)
		or (clipOne == -1 and clipTwo > 0 and secondaryAmmo > 0)
		or (clipTwo == -1 and clipOne > 0 and primaryAmmo > 0)
		or (clipOne != -1 and primaryAmmo > 0)
		or (clipTwo != -1 and secondaryAmmo > 0) ) then
			table.insert(newWeapons, v);
		end;
	end;

	if ( #newWeapons == 1 and CloudScript.config:Get("weapon_selection_multi"):Get() ) then
		return;
	end;
	
	if ( string.find(bind, "invnext") or string.find(bind, "slot2") ) then
		if (curTime >= self.displayDelay and !press) then
			if (#newWeapons > 1) then
				surface.PlaySound("common/talk.wav");
			end;
			
			self.displayDelay = curTime + 0.05;
			self.displayAlpha = 255;
			self.displayFade = curTime + 2;
			self.displaySlot = self.displaySlot + 1;
			
			if (self.displaySlot > #newWeapons) then
				self.displaySlot = 1;
			end;
		end;
		
		return true;
	elseif ( string.find(bind, "invprev") or string.find(bind, "slot1") ) then
		if (curTime >= self.displayDelay and !press) then
			if (#newWeapons > 1) then
				surface.PlaySound("common/talk.wav");
			end;
			
			self.displayDelay = curTime + 0.05;
			self.displayAlpha = 255;
			self.displayFade = curTime + 2;
			self.displaySlot = self.displaySlot - 1;
			
			if (self.displaySlot < 1) then
				self.displaySlot = #newWeapons;
			end;
		end;
		
		return true;
	elseif ( string.find(bind, "+attack") ) then
		if (#newWeapons > 1) then
			if ( self.displayAlpha >= 128 and IsValid( newWeapons[self.displaySlot] ) ) then
				CloudScript:StartDataStream( "SelectWeapon", newWeapons[self.displaySlot]:GetClass() );
				
				CloudScript.option:PlaySound("click_release");
				
				self.displayAlpha = 0;
				
				return true
			end;
		end;
	end;
end;