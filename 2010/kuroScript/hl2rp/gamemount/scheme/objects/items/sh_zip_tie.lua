--[[
Name: "sh_zip_tie.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Zip Tie";
ITEM.cost = 5;
ITEM.model = "models/items/crossbowrounds.mdl";
ITEM.weight = 0.2;
ITEM.access = "v";
ITEM.useText = "Tie";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.business = true;
ITEM.blacklist = {VOC_CPA_RCT};
ITEM.description = "An orange zip tie with Thomas and Betts printed on the side.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player._IsTying) then
		kuroScript.player.Notify(player, "You are already tying a character!");
		
		-- Return false to break the function.
		return false;
	else
		local trace = player:GetEyeTraceNoCursor();
		local target = kuroScript.entity.GetPlayer(trace.Entity);
		local tieTime = kuroScript.game:GetDexterityTime(player);
		
		-- Check if a statement is true.
		if (target) then
			if (target:GetSharedVar("ks_Tied") == 0) then
				if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
					if ( target:GetAimVector():DotProduct( player:GetAimVector() ) > 0 or target:IsRagdolled() ) then
						kuroScript.player.SetAction(player, "tie", tieTime);
						
						-- Set some information.
						target:SetSharedVar("ks_BeingTied", true);
						
						-- Set some information.
						kuroScript.player.EntityConditionTimer(player, target, trace.Entity, tieTime, 192, function()
							if (player:Alive() and !player:IsRagdolled() and target:GetSharedVar("ks_Tied") == 0
							and target:GetAimVector():DotProduct( player:GetAimVector() ) > 0) then
								return true;
							end;
						end, function(success)
							if (success) then
								player._IsTying = nil;
								
								-- Tie the player.
								kuroScript.game:TiePlayer( target, true, nil, kuroScript.game:PlayerIsCombine(player) );
								
								-- Check if a statement is true.
								if ( kuroScript.game:PlayerIsCombine(target) ) then
									local location = kuroScript.game:PlayerGetLocation(player);
									
									-- Add some Combine display lines.
									kuroScript.game:AddCombineDisplayLine("Downloading lost radio contact information...", Color(255, 255, 255, 255), nil, player);
									kuroScript.game:AddCombineDisplayLine("WARNING! Radio contact lost for unit at "..location.."...", Color(255, 0, 0, 255), nil, player);
								end;
								
								-- Update the player's inventory.
								kuroScript.inventory.Update(player, "zip_tie", -1);
								
								-- Progress the player's attribute.
								kuroScript.attributes.Progress(player, ATB_DEXTERITY, 15, true);
								
								-- Set some information.
								target:SetSharedVar("ks_BeingTied", false);
							else
								if ( ValidEntity(target) ) then
									target:SetSharedVar("ks_BeingTied", false);
								end;
								
								-- Set some information.
								player._IsTying = nil;
							end;
							
							-- Set some information.
							kuroScript.player.SetAction(player, "tie", false);
						end);
					else
						kuroScript.player.Notify(player, "You cannot tie characters that are facing you!");
						
						-- Return false to break the function.
						return false;
					end;
					
					-- Set some information.
					player._IsTying = true;
					
					-- Close the player's menu.
					kuroScript.player.SetMenuOpen(player, false);
					
					-- Return false to break the function.
					return false;
				else
					kuroScript.player.Notify(player, "This character is too far away!");
					
					-- Return false to break the function.
					return false;
				end;
			else
				kuroScript.player.Notify(player, "This character is already tied!");
				
				-- Return false to break the function.
				return false;
			end;
		else
			kuroScript.player.Notify(player, "That is not a valid character!");
			
			-- Return false to break the function.
			return false;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player._IsTying) then
		kuroScript.player.Notify(player, "You are currently tying a character!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);