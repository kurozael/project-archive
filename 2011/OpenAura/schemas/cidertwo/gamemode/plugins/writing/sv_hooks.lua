--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "aura_paper" and arguments == "aura_paperOption") then
		if (entity.text) then
			if ( !player.paperIDs or !player.paperIDs[entity.uniqueID] ) then
				if (!player.paperIDs) then
					player.paperIDs = {};
				end;
				
				player.paperIDs[entity.uniqueID] = true;
				
				openAura:StartDataStream( player, "ViewPaper", {entity, entity.uniqueID, entity.text} );
			else
				openAura:StartDataStream( player, "ViewPaper", {entity, entity.uniqueID} );
			end;
		else
			umsg.Start("aura_EditPaper", player);
				umsg.Entity(entity);
			umsg.End();
		end;
	end;
end;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	self:LoadPaper();
end;

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SavePaper();
end;