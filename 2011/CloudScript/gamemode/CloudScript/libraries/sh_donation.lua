--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.donation = {};
CloudScript.donation.stored = {};

-- A function to register a new donation subscription.
function CloudScript.donation:Register(uniqueID, friendlyName, description, imageName)
	self.stored[uniqueID] = {
		friendlyName = friendlyName,
		description = description,
		imageName = imageName
	};
	
	if (imageName and SERVER) then
		resource.AddFile("materials/"..imageName..".vtf");
		resource.AddFile("materials/"..imageName..".vmt");
	end;
end;

-- A function to get a donation subscription table.
function CloudScript.donation:Get(uniqueID)
	return self.stored[uniqueID];
end;

if (SERVER) then
	function CloudScript.donation:IsSubscribed(player, uniqueID)
		local expireTime = player.donations[uniqueID];
		
		if ( expireTime and (expireTime == 0 or os.clock() < expireTime) ) then
			return expireTime;
		end;
		
		return false;
	end;
else
	CloudScript.donation.active = {};
	CloudScript.donation.hasDonated = false;
	
	-- A function to get whether the local player is subscribed to a donation.
	function CloudScript.donation:IsSubscribed(uniqueID)
		return self.active[uniqueID] or false;
	end;
	
	-- A function to get whether the local player has donated at all.
	function CloudScript.donation:HasDonated()
		return self.hasDonated;
	end;
	
	CloudScript:HookDataStream("Donations", function(data)
		CloudScript.donation.active = data;
		
		if (table.Count(data) > 0) then
			CloudScript.donation.hasDonated = true;
		end;
	end);
end;