--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "cw_paper" and arguments == "cwPaperOption") then
		if (entity.cwPaperText) then
			if (!player.cwPaperIDs or !player.cwPaperIDs[entity.uniqueID]) then
				if (!player.cwPaperIDs) then
					player.cwPaperIDs = {};
				end;
				
				player.cwPaperIDs[entity.cwUniqueID] = true;
				Clockwork:StartDataStream(player, "ViewPaper", {entity, entity.cwUniqueID, entity.cwPaperText});
			else
				Clockwork:StartDataStream(player, "ViewPaper", {entity, entity.cwUniqueID});
			end;
		else
			umsg.Start("cwEditPaper", player);
				umsg.Entity(entity);
			umsg.End();
		end;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadPaper();
end;

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SavePaper();
end;