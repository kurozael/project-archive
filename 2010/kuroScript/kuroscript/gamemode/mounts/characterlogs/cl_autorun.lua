--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Register a chat box class.
kuroScript.chatBox.RegisterClass("charlog", "ic", function(info)
	kuroScript.chatBox.Add(info.filtered, nil, "(Character Log) ", Color(255, 255, 150, 255), info.name..": "..info.text);
end);