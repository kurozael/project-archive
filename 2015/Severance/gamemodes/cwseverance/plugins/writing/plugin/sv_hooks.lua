--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- Called when an entity's menu option should be handled.
function cwWriting:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "cw_paper" and arguments == "cwPaperOption") then
		if (entity.cwPaperText) then
			if (!player.cwPaperIDs or !player.cwPaperIDs[entity.uniqueID]) then
				if (!player.cwPaperIDs) then
					player.cwPaperIDs = {};
				end;
				
				player.cwPaperIDs[entity.cwUniqueID] = true;
				Clockwork.datastream:Start(player, "ViewPaper", {entity, entity.cwUniqueID, entity.cwPaperText});
			else
				Clockwork.datastream:Start(player, "ViewPaper", {entity, entity.cwUniqueID});
			end;
		else
			umsg.Start("cwEditPaper", player);
				umsg.Entity(entity);
			umsg.End();
		end;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function cwWriting:ClockworkInitPostEntity()
	self:LoadPaper();
end;

-- Called just after data should be saved.
function cwWriting:PostSaveData()
	self:SavePaper();
end;