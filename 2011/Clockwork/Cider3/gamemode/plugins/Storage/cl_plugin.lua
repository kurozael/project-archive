--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.config:AddToSystem("max_locker_weight", "The maximum weight a player's locker can hold.");

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

Clockwork.chatBox:RegisterClass("wire", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(275, 255, 200, 255), info.text);
end);