--[[
Name: "sv_chatbox.lua".
Product: "kuroScript".
--]]

kuroScript.chatBox = {};

-- A function to add a new chat message.
function kuroScript.chatBox.Add(listeners, speaker, class, text, data)
	if (type(listeners) != "table") then
		if (!listeners) then
			listeners = g_Player.GetAll();
		else
			listeners = {listeners};
		end;
	end;
	
	-- Set some information.
	local info = {
		listeners = {},
		speaker = speaker,
		class = class,
		text = text,
		data = data
	};
	
	-- Check if a statement is true.
	if (type(info.data) != "table") then
		info.data = {info.data};
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(listeners) do
		if (type(k) == "Player") then
			info.listeners[k] = k;
		elseif (type(v) == "Player") then
			info.listeners[v] = v;
		end;
	end;
	
	-- Call a gamemode hook.
	hook.Call("ChatBoxAdjustInfo", kuroScript.frame, info);
	hook.Call("ChatBoxMessageAdded", kuroScript.frame, info);
	
	-- Check if a statement is true.
	if ( ValidEntity(info.speaker) ) then
		datastream.StreamToClients( info.listeners, "ks_ChatBoxPlayerMessage", {
			speaker = info.speaker,
			class = info.class,
			text = info.text,
			data = info.data
		} );
	else
		datastream.StreamToClients( info.listeners, "ks_ChatBoxMessage", {
			class = info.class,
			text = info.text,
			data = info.data
		} );
	end;
	
	-- Return the info.
	return info;
end;

-- A function to add a new chat message in a radius.
function kuroScript.chatBox.AddInRadius(speaker, class, text, position, radius, data)
	local listeners = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (position:Distance( v:GetPos() ) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;
	
	-- Add a chat box message.
	kuroScript.chatBox.Add(listeners, speaker, class, text, data);
end;