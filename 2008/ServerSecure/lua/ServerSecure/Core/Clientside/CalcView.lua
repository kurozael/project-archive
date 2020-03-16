function GAMEMODE:CalcView(Player, Origin, Angles, FOV)
	if (Player and Player:IsValid() and Player:IsPlayer()) then
		if (Player.GetScriptedVehicle and Player:GetScriptedVehicle() and Player:GetScriptedVehicle():IsValid()) then
			local View = Player:GetScriptedVehicle():GetTable():CalcView(Player, Origin, Angles, FOV)
			
			if (View) then return View end
		end
	end

	local View = {}
	
	View.origin = Origin
	View.angles	= Angles
	View.fov 	= FOV
	
	// Give the active weapon a go at changing the viewmodel position
	
	if (Player and Player:IsValid() and Player:IsPlayer()) then
		local Wep = Player:GetActiveWeapon()
		
		if (Wep && Wep != NULL) then
		
			local Func = Wep:GetTable().GetViewModelPosition
			
			if (Func) then
				View.vm_origin, View.vm_angles = Func(Wep:GetTable(), Origin, Angles)
			end
		end
	end
	
	return View
end