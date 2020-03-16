Clockwork.cloudnet = Clockwork.cloudnet or {};
Clockwork.cloudnet.cache = Clockwork.cloudnet.cache or {};
Clockwork.cloudnet.stored = Clockwork.cloudnet.stored or {};
Clockwork.cloudnet.NET_KEY = "CloudNet";
Clockwork.cloudnet.PRUNE_KEY = "PruneNet";
	
Clockwork.cloudnet.INT = 1;
Clockwork.cloudnet.FLOAT = 2;
Clockwork.cloudnet.BOOL = 3;
Clockwork.cloudnet.VECTOR = 4;
Clockwork.cloudnet.ANGLE = 5;
Clockwork.cloudnet.ENTITY = 6;
Clockwork.cloudnet.STRING = 7;

function Clockwork.cloudnet:GetVar(entity, key, default)
	local index = entity:EntIndex();
	
	if (self.stored[index]) then
		if (self.stored[index][key] ~= nil) then
			return self.stored[index][key];
		end;
	end;
	
	return default;
end;

function Clockwork.cloudnet:Debug(text)
	if (Clockwork.DeveloperVersion) then
		MsgN(text);
	end;
end;