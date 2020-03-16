--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;
local BLUE_SIREN_LOCAL = Vector(-0.6974, -41.8885, 66.1966);
local RED_SIREN_LOCAL = Vector(-43.1840, -41.8382, 66.3215);

PLUGIN.policeCars = {};
PLUGIN.getPoliceCarsTime = 0;
PLUGIN.nextRedDynamicLight = 0;
PLUGIN.nextBlueDynamicLight = 0;

-- Called each frame.
function PLUGIN:Think()
	local curTime = UnPredictedCurTime();
	
	if (curTime >= self.getPoliceCarsTime) then
		self.getPoliceCarsTime = curTime + 4;
		
		for k, v in ipairs(ents.FindByClass("prop_vehicle_jeep")) do
			if (v:GetModel() == "models/copcar.mdl") then
				table.insert(self.policeCars, v);
			end;
		end;
		
		for k, v in ipairs(self.policeCars) do
			if (!IsValid(v)) then
				table.remove(self.policeCars, k);
			end;
		end;
	end;
	
	if (curTime >= self.nextRedDynamicLight) then
		self.nextRedDynamicLight = curTime + 1;
		self.nextBlueDynamicLight = curTime + 0.5;
		
		for k, v in ipairs(self.policeCars) do
			if (IsValid(v) and v:GetNetworkedBool("Siren")) then
				local dynamicLight = DynamicLight("siren_red");
				local sirenPos = v:LocalToWorld(RED_SIREN_LOCAL);
				
				if (!v.NextSirenSoundTime or curTime >= v.NextSirenSoundTime) then
					v.NextSirenSoundTime = curTime + 4;
					v:EmitSound("police_siren.wav", 100, 100);
				end;
				
				if (dynamicLight) then
					dynamicLight.Brightness = 8;
					dynamicLight.DieTime = curTime + 0.5;
					dynamicLight.Decay = 256;
					dynamicLight.Size = 256;
					dynamicLight.Pos = sirenPos;
					dynamicLight.r = 255;
					dynamicLight.g = 0;
					dynamicLight.b = 0;
				end;
			end;
		end;
	elseif (curTime >= self.nextBlueDynamicLight) then
		self.nextBlueDynamicLight = curTime + 0.5;
		
		for k, v in ipairs(self.policeCars) do
			if (IsValid(v) and v:GetNetworkedBool("Siren")) then
				local dynamicLight = DynamicLight("siren_blue");
				local sirenPos = v:LocalToWorld(BLUE_SIREN_LOCAL);
				
				if (dynamicLight) then
					dynamicLight.Brightness = 8;
					dynamicLight.DieTime = curTime + 0.5;
					dynamicLight.Decay = 256;
					dynamicLight.Size = 256;
					dynamicLight.Pos = sirenPos;
					dynamicLight.r = 0;
					dynamicLight.g = 0;
					dynamicLight.b = 255;
				end;
			end;
		end;
	end;
end;

-- Called when the calc view table should be adjusted.
function PLUGIN:CalcViewAdjustTable(view)
	if (Clockwork.Client:InVehicle()) then
		local vehicle = Clockwork.Client:GetVehicle();
		local index = vehicle:GetNetworkedInt("Index");

		if (index != 0) then
			local itemTable = Clockwork.item:FindByID(index);

			if (itemTable and itemTable("calcView")) then
				view.origin = view.origin + itemTable("calcView");
			end;
		end;
	end;
end;

-- Called when a player presses a bind.
function PLUGIN:PlayerBindPress(player, bind, pressed)
	if (player:InVehicle()) then
		if (string.find(bind, "+attack2")) then
			Clockwork:StartDataStream("ManageCar", "unlock");
		elseif (string.find(bind, "+attack")) then
			Clockwork:StartDataStream("ManageCar", "lock");
		elseif (string.find(bind, "+reload")) then
			Clockwork:StartDataStream("ManageCar", "horn");
		end;
	end;
end;

-- Called when the bars are needed.
function PLUGIN:GetBars(bars)
	local fuel = Clockwork.Client:GetSharedVar("Fuel");

	if (self.cwFuelAmt) then
		self.cwFuelAmt = math.Approach(self.cwFuelAmt, fuel, 1);
	else
		self.cwFuelAmt = fuel;
	end;
	
	if (self.cwFuelAmt < 75) then
		bars:Add("FUEL", Color(175, 50, 200, 255), "Fuel", self.cwFuelAmt, 100, self.cwFuelAmt < 10);
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function PLUGIN:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local physDesc = entity:GetNetworkedString("PhysDesc");
	local index = entity:GetNetworkedInt("Index");
	
	if (!Clockwork.Client:InVehicle() and entity:GetClass() == "prop_vehicle_jeep") then
		local wrappedTable = {};
		local itemTable = Clockwork.item:FindByID(index);
		
		if (itemTable) then
			if (physDesc == "" and itemTable.cwVehiclePhysDesc) then
				physDesc = Clockwork:ModifyPhysDesc(itemTable.cwVehiclePhysDesc);
			end;
			
			info.y = Clockwork:DrawInfo(itemTable("name"), info.x, info.y, colorTargetID, info.alpha);

			if (physDesc != "") then
				Clockwork:WrapText(physDesc, Clockwork.option:GetFont("target_id_text"), math.max(ScrW() / 8, 384), wrappedTable);
				
				for k, v in ipairs(wrappedTable) do
					info.y = Clockwork:DrawInfo(v, info.x, info.y, colorWhite, info.alpha);
				end;
			end;
		end;
	end;
end;