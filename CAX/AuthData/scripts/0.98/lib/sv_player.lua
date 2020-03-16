if (Clockwork.UseNetworkLib) then
	function Clockwork.player:SetSharedVar(player, key, value)
		player:SetNetVar(key, value);
	end;

	function Clockwork.player:GetSharedVar(player, key)
		if (IsValid(player)) then
			local sharedVars = Clockwork.kernel:GetSharedVars():Player();
			local cloudnetVar = player:GetNetVar(key);
			
			if (cloudnetVar == nil and sharedVars and sharedVars[key]) then
				return Clockwork.kernel:GetDefaultNetworkedValue(sharedVars[key].class);
			else
				return cloudnetVar;
			end;
		end;
	end;
end;

if (Clockwork.UseCloudnet) then
	function Clockwork.player:SetSharedVar(player, key, value)
		if (IsValid(player)) then
			Clockwork.cloudnet:SetVar(player, key, value);
		end;
	end;

	function Clockwork.player:GetSharedVar(player, key)
		if (IsValid(player)) then
			local sharedVars = Clockwork.kernel:GetSharedVars():Player();
			local cloudnetVar = Clockwork.cloudnet:GetVar(player, key);
			
			if (cloudnetVar == nil and sharedVars and sharedVars[key]) then
				return Clockwork.kernel:GetDefaultNetworkedValue(sharedVars[key].class);
			else
				return cloudnetVar;
			end;
		end;
	end;
	
	Clockwork.cloudnet:SetSendCallback(function(entity, target, key)
		if (not entity:IsPlayer()) then
			return true;
		end;
		
		local sharedVars = Clockwork.kernel:GetSharedVars():Player();
		
		if (sharedVars and sharedVars[key] and (sharedVars[key].playerOnly or sharedVars[key].bPlayerOnly)) then
			return (entity == target);
		else
			return true;
		end;
	end);
end;