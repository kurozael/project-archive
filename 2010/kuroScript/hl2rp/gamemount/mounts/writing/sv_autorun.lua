--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a data stream.
datastream.Hook("ks_EditPaper", function(player, handler, uniqueID, rawData, procData)
	if ( ValidEntity( procData[1] ) ) then
		if (procData[1]:GetClass() == "ks_paper") then
			if ( player:GetPos():Distance( procData[1]:GetPos() ) <= 192 and player:GetEyeTraceNoCursor().Entity == procData[1] ) then
				if (string.len( procData[2] ) > 0) then
					procData[1]:SetText( string.sub(procData[2], 0, 500) );
				end;
			end;
		end;
	end;
end);

-- A function to load the paper.
function MOUNT:LoadPaper()
	local paper = kuroScript.frame:RestoreGameData( "mounts/paper/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(paper) do
		local entity = ents.Create("ks_paper");
		
		-- Give the property to an offline player.
		kuroScript.player.GivePropertyOffline(v.key, v.uniqueID, entity);
		
		-- Set some information.
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			entity:SetText(v.text);
		end;
		
		-- Check if a statement is true.
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the paper.
function MOUNT:SavePaper()
	local paper = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_paper") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		-- Check if a statement is true.
		if ( ValidEntity(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		-- Set some information.
		paper[#paper + 1] = {
			key = kuroScript.entity.QueryProperty(v, "key"),
			text = v._Text,
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/paper/"..game.GetMap(), paper);
end;