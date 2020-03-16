--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "aura_book" and arguments == "aura_bookTake" or arguments == "aura_bookView") then
		if (arguments == "aura_bookView") then
			umsg.Start("aura_ViewBook", player);
				umsg.Entity(entity);
			umsg.End();
		else
			local success, fault = player:UpdateInventory(entity.book.uniqueID, 1);
			
			if (!success) then
				openAura.player:Notify(player, fault);
			else
				entity:Remove();
			end;
		end;
	end;
end;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	self:LoadBooks();
end;

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SaveBooks();
end;