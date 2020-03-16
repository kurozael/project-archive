--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.limb = {};
CloudScript.limb.bones = {
	["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_Pelvis"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
	["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD
};

-- A function to convert a bone to a hit group.
function CloudScript.limb:BoneToHitGroup(bone)
	return self.bones[bone] or HITGROUP_CHEST;
end;

-- A function to get whether limb damage is active.
function CloudScript.limb:IsActive()
	return CloudScript.config:Get("limb_damage_system"):Get();
end;

if (SERVER) then
	function CloudScript.limb:TakeDamage(player, hitGroup, damage)
		local newDamage = math.ceil(damage);
		local limbs = player:GetCharacterData("limbs");
		
		if (limbs) then
			limbs[hitGroup] = math.min( (limbs[hitGroup] or 0) + newDamage, 100 );
			
			umsg.Start("cloud_TakeLimbDamage", player);
				umsg.Short(hitGroup);
				umsg.Short(newDamage);
			umsg.End();
			
			CloudScript.plugin:Call("PlayerLimbTakeDamage", player, hitGroup, newDamage);
		end;
	end;
	
	-- A function to heal a player's body.
	function CloudScript.limb:HealBody(player, amount)
		local limbs = player:GetCharacterData("limbs");
		
		if (limbs) then
			for k, v in pairs(limbs) do
				self:HealDamage(player, k, amount);
			end;
		end;
	end;
	
	-- A function to heal a player's limb damage.
	function CloudScript.limb:HealDamage(player, hitGroup, amount)
		local newAmount = math.ceil(amount);
		local limbs = player:GetCharacterData("limbs");
		
		if ( limbs and limbs[hitGroup] ) then
			limbs[hitGroup] = math.max(limbs[hitGroup] - newAmount, 0);
			
			if (limbs[hitGroup] == 0) then
				limbs[hitGroup] = nil;
			end;
			
			umsg.Start("cloud_HealLimbDamage", player);
				umsg.Short(hitGroup);
				umsg.Short(newAmount);
			umsg.End();
			
			CloudScript.plugin:Call("PlayerLimbDamageHealed", player, hitGroup, newAmount);
		end;
	end;
	
	-- A function to reset a player's limb damage.
	function CloudScript.limb:ResetDamage(player)
		player:SetCharacterData( "limbs", {} );
		
		umsg.Start("cloud_ResetLimbDamage", player);
		umsg.End();
		
		CloudScript.plugin:Call("PlayerLimbDamageReset", player);
	end;
	
	-- A function to get whether any of a player's limbs are damaged.
	function CloudScript.limb:IsAnyDamaged(player)
		local limbs = player:GetCharacterData("limbs");
		
		if (limbs and table.Count(limbs) > 0) then
			return true;
		else
			return false;
		end;
	end
	
	-- A function to get a player's limb health.
	function CloudScript.limb:GetHealth(player, hitGroup, asFraction)
		return 100 - self:GetDamage(player, hitGroup, asFraction);
	end;
	
	-- A function to get a player's limb damage.
	function CloudScript.limb:GetDamage(player, hitGroup, asFraction)
		if ( !CloudScript.config:Get("limb_damage_system"):Get() ) then
			return 0;
		end;
		
		local limbs = player:GetCharacterData("limbs");
		
		if ( limbs and limbs[hitGroup] ) then
			if (asFraction) then
				return limbs[hitGroup] / 100;
			else
				return limbs[hitGroup];
			end;
		end;
		
		return 0;
	end;
else
	CloudScript.limb.bodyTexture = surface.GetTextureID("CloudScript/limbs/body");
	CloudScript.limb.stored = {};
	CloudScript.limb.hitGroups = {
		[HITGROUP_RIGHTARM] = surface.GetTextureID("CloudScript/limbs/rarm"),
		[HITGROUP_RIGHTLEG] = surface.GetTextureID("CloudScript/limbs/rleg"),
		[HITGROUP_LEFTARM] = surface.GetTextureID("CloudScript/limbs/larm"),
		[HITGROUP_LEFTLEG] = surface.GetTextureID("CloudScript/limbs/lleg"),
		[HITGROUP_STOMACH] = surface.GetTextureID("CloudScript/limbs/stomach"),
		[HITGROUP_CHEST] = surface.GetTextureID("CloudScript/limbs/chest"),
		[HITGROUP_HEAD] = surface.GetTextureID("CloudScript/limbs/head")
	};
	CloudScript.limb.names = {
		[HITGROUP_RIGHTARM] = "Right Arm",
		[HITGROUP_RIGHTLEG] = "Right Leg",
		[HITGROUP_LEFTARM] = "Left Arm",
		[HITGROUP_LEFTLEG] = "Left Leg",
		[HITGROUP_STOMACH] = "Stomach",
		[HITGROUP_CHEST] = "Chest",
		[HITGROUP_HEAD] = "Head"
	};
	
	-- A function to get a limb's texture.
	function CloudScript.limb:GetTexture(hitGroup)
		if (hitGroup == "body") then
			return self.bodyTexture;
		else
			return self.hitGroups[hitGroup];
		end;
	end;
	
	-- A function to get a limb's name.
	function CloudScript.limb:GetName(hitGroup)
		return self.names[hitGroup] or "Generic";
	end;
	
	-- A function to get a limb color.
	function CloudScript.limb:GetColor(health)
		if (health > 75) then
			return Color(166, 243, 76, 255);
		elseif (health > 50) then
			return Color(233, 225, 94, 255);
		elseif (health > 25) then
			return Color(233, 173, 94, 255);
		else
			return Color(222, 57, 57, 255);
		end;
	end;
	
	-- A function to get the local player's limb health.
	function CloudScript.limb:GetHealth(hitGroup, asFraction)
		return 100 - self:GetDamage(hitGroup, asFraction);
	end;
	
	-- A function to get the local player's limb damage.
	function CloudScript.limb:GetDamage(hitGroup, asFraction)
		if ( !CloudScript.config:Get("limb_damage_system"):Get() ) then
			return 0;
		end;
		
		if ( self.stored[hitGroup] ) then
			if (asFraction) then
				return self.stored[hitGroup] / 100;
			else
				return self.stored[hitGroup];
			end;
		end;
		
		return 0;
	end;
	
	-- A function to get whether any of the local player's limbs are damaged.
	function CloudScript.limb:IsAnyDamaged()
		return table.Count(self.stored) > 0;
	end;
	
	CloudScript:HookDataStream("ReceiveLimbDamage", function(data)
		CloudScript.limb.stored = data;
		CloudScript.plugin:Call("PlayerLimbDamageReceived");
	end);

	usermessage.Hook("cloud_ResetLimbDamage", function(msg)
		CloudScript.limb.stored = {};
		CloudScript.plugin:Call("PlayerLimbDamageReset");
	end);
	
	usermessage.Hook("cloud_TakeLimbDamage", function(msg)
		local hitGroup = msg:ReadShort();
		local damage = msg:ReadShort();
		
		CloudScript.limb.stored[hitGroup] = math.min( (CloudScript.limb.stored[hitGroup] or 0) + damage, 100 );
		CloudScript.plugin:Call("PlayerLimbTakeDamage", hitGroup, damage);
	end);
	
	usermessage.Hook("cloud_HealLimbDamage", function(msg)
		local hitGroup = msg:ReadShort();
		local amount = msg:ReadShort();
		
		if ( CloudScript.limb.stored[hitGroup] ) then
			CloudScript.limb.stored[hitGroup] = math.max(CloudScript.limb.stored[hitGroup] - amount, 0);
			
			if (CloudScript.limb.stored[hitGroup] == 100) then
				CloudScript.limb.stored[hitGroup] = nil;
			end;
			
			CloudScript.plugin:Call("PlayerLimbDamageHealed", hitGroup, amount);
		end;
	end);
end;