--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]
usermessage.Hook("cwStorageMessage", function(msg)
	local entity = msg:ReadEntity();
	local message = msg:ReadString();
	
	if (IsValid(entity)) then
		entity.cwMessage = message;
	end;
end);

usermessage.Hook("cwContainerPassword", function(msg)
	local entity = msg:ReadEntity();
	
	Derma_StringRequest("Password", "What is the password for this container?", nil, function(text)
		Clockwork:StartDataStream("ContainerPassword", {text, entity});
	end);
end);