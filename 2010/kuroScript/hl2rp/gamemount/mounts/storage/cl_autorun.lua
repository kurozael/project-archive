--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a user message.
usermessage.Hook("ks_ContainerPassword", function(msg)
	Derma_StringRequest("Password", "What is the password for this container?", nil, function(text)
		datastream.StreamToServer("ks_ContainerPassword", text);
	end);
end);