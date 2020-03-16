--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to load the paper.
function cwWriting:LoadPaper()
	local paper = Clockwork.kernel:RestoreSchemaData("plugins/paper/"..game.GetMap());
	
	for k, v in pairs(paper) do
		local entity = ents.Create("cw_paper");
			Clockwork.player:GivePropertyOffline(v.key, v.uniqueID, entity);
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (IsValid(entity)) then
			entity:SetText(v.text);
		end;
		
		if (!v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the paper.
function cwWriting:SavePaper()
	local paper = {};
	
	for k, v in pairs(ents.FindByClass("cw_paper")) do
		local physicsObject = v:GetPhysicsObject();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		paper[#paper + 1] = {
			key = Clockwork.entity:QueryProperty(v, "key"),
			text = v.text,
			angles = v:GetAngles(),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		};
	end;
	
	Clockwork.kernel:SaveSchemaData("plugins/paper/"..game.GetMap(), paper);
end;

Clockwork.datastream:Hook("EditPaper", function(player, data)
	if (IsValid(data[1]) and data[1]:GetClass() == "cw_paper") then
		if (player:GetPos():Distance(data[1]:GetPos()) <= 192 and player:GetEyeTraceNoCursor().Entity == data[1]) then
			if (string.len(data[2]) > 0) then
				data[1]:SetText(string.sub(data[2], 0, 500));
			end;
		end;
	end;
end);