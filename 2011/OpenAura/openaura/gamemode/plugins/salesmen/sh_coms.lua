--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = openAura.command:New();
COMMAND.tip = "Add a salesman at your target position.";
COMMAND.text = "[number Animation]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player.settingUpSalesman = true;
	player.salesmanAnimation = tonumber( arguments[1] );
	player.salesmanHitPos = player:GetEyeTraceNoCursor().HitPos;
	
	if (!player.salesmanAnimation and type( arguments[1] ) == "string") then
		player.salesmanAnimation = tonumber( _G[ arguments[1] ] );
	end;
	
	umsg.Start("aura_SalesmanAdd", player);
	umsg.End();
end;

openAura.command:Register(COMMAND, "SalesmanAdd");

COMMAND = openAura.command:New();
COMMAND.tip = "Edit a salesman at your target position.";
COMMAND.text = "[number Animation]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(target) ) then
		if (target:GetClass() == "aura_salesman") then
			local salesmanTable = PLUGIN:GetTableFromEntity(target);
			
			player.settingUpSalesman = true;
			player.salesmanAnimation = tonumber( arguments[1] );
			player.salesmanPosition = target:GetPos();
			player.salesmanAngles = target:GetAngles();
			player.salesmanHitPos = player:GetEyeTraceNoCursor().HitPos;
			
			if (!player.salesmanAnimation and type( arguments[1] ) == "string") then
				player.salesmanAnimation = tonumber( _G[ arguments[1] ] );
			end;
			
			if (!player.salesmanAnimation and salesmanTable.animation) then
				player.salesmanAnimation = salesmanTable.animation;
			end;
			
			openAura:StartDataStream(player, "SalesmanEdit", salesmanTable);
			
			for k, v in pairs(PLUGIN.salesmen) do
				if (target == v) then
					target:Remove();
					PLUGIN.salesmen[k] = nil;
					PLUGIN:SaveSalesmen();
					
					return;
				end;
			end;
		else
			openAura.player:Notify(player, "This entity is not a salesman!");
		end;
	else
		openAura.player:Notify(player, "You must look at a valid entity!");
	end;
end;

openAura.command:Register(COMMAND, "SalesmanEdit");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove a salesman at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(target) ) then
		if (target:GetClass() == "aura_salesman") then
			for k, v in pairs(PLUGIN.salesmen) do
				if (target == v) then
					target:Remove();
					PLUGIN.salesmen[k] = nil;
					PLUGIN:SaveSalesmen();
					
					openAura.player:Notify(player, "You have removed a salesman.");
					
					return;
				end;
			end;
		else
			openAura.player:Notify(player, "This entity is not a salesman!");
		end;
	else
		openAura.player:Notify(player, "You must look at a valid entity!");
	end;
end;

openAura.command:Register(COMMAND, "SalesmanRemove");