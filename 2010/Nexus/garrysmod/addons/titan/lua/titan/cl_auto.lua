--[[
Name: "cl_auto.lua".
Product: "titan".
--]]

g_LocalPlayer = LocalPlayer();

CreateClientConVar("fn_debug", 0, true, true);

usermessage.Hook("fn_UpdateReady", function(msg)
	titan.nextFullUpdate = UnPredictedCurTime() + 1;
end);

-- Called to get the world entity.
function GetWorldEntity()
	return Entity(0);
end

-- Called when a variable is received.
function titan:OnRecieve(entity, key, oldValue, newValue)
	if ( entity.fn_Proxies and entity.fn_Proxies[key] ) then
		entity.fn_Proxies[key](entity, key, oldValue, newValue);
	end;
	
	if (GetConVarNumber("fn_debug") == 1) then
		print("[titan] ", entity, ", ", key, ", ", newValue);
	end;
	
	return true;
end;

-- A function to update an entity's variable.
function titan:UpdateVar(entity, key, newValue, varType)
	local oldValue = entity["GetNetworked"..varType](entity, key);
	
	if ( self:OnRecieve(entity, key, oldValue, newValue) ) then
		entity["SetNetworked"..varType](entity, key, newValue);
	end;
end;

hook.Add("Think", "titan.Think", function()
	local localPlayer = LocalPlayer();
	
	if ( IsValid(localPlayer) ) then
		local entIndex = localPlayer:EntIndex();
		
		if ( !localPlayer.fn_IsReady or !titan.netVars[entIndex] ) then
			titan.netVars[entIndex] = {};
			
			localPlayer.fn_IsReady = true;
		end;
		
		hook.Remove("Think", "titan.Think");
		g_LocalPlayer = localPlayer;
	end;
end);

hook.Add("Tick", "titan.Tick", function()
	local curTime = UnPredictedCurTime();
	
	if ( titan.timedOut and IsValid(g_LocalPlayer) ) then
		titan.nextFullUpdate = curTime + 2;
		titan.timedOut = nil;
	end;
	
	if (titan.nextFullUpdate) then
		if (curTime >= titan.nextFullUpdate) then
			RunConsoleCommand("fn_fullupdate");
			
			titan.nextFullUpdate = nil;
			
			if (GetConVarNumber("fn_debug") == 1) then
				print("[titan] Requesting a full update from the server...");
			end;
		end;
	end;
	
	for k, v in pairs(titan.onCreatedQueue) do
		local entity = Entity(k);
		
		if ( titan:IsValidEntity(entity) ) then
			for k2, v2 in pairs(v) do
				titan:UpdateVar(entity, k2, v2.value, v2.varType);
			end;
			
			titan.onCreatedQueue[k] = nil;
		end;
	end;
end);

hook.Add("OnEntityCreated", "titan.OnEntityCreated", function(entity)
	local entIndex = entity:EntIndex();
	
	if ( !entity.fn_IsReady or !self.netVars[entIndex] ) then
		titan.netVars[entIndex] = {};
		
		entity.fn_IsReady = true;
	end;
	
	if ( entity == LocalPlayer() ) then
		g_LocalPlayer = localPlayer;
	end;
end);

usermessage.Hook("x", function(msg)
	local success, decodedData = pcall( glon.decode, msg:ReadString() );
	
	if (success and decodedData) then
		local entIndex = decodedData[1];
		local entity = Entity(entIndex);
		local value = decodedData[3];
		local class = titan:GetVarClass(value);
		local key = decodedData[2];
		
		if ( !titan:IsValidEntity(entity) ) then
			if ( !titan.onCreatedQueue[entIndex] ) then
				titan.onCreatedQueue[entIndex] = {};
			end;
			
			titan.onCreatedQueue[entIndex][key] = {
				varType = class.varType,
				value = value
			};
		else
			titan:UpdateVar(entity, key, value, class.varType);
		end;
	end;
end);