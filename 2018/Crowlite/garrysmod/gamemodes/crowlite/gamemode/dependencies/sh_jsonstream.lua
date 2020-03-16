--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

jsonstream = {};

--[[ Private Members ]]--
jsonstream.__callbacks = jsonstream.__callbacks or {};
jsonstream.__currentId = jsonstream.__currentId or 0;
jsonstream.__awaitingId = jsonstream.__awaitingId or {};
jsonstream.__queue = jsonstream.__queue or {};
jsonstream.__data = jsonstream.__data or {};

if (SERVER) then
	util.AddNetworkString("js-client-start");
	util.AddNetworkString("js-client-data");
	util.AddNetworkString("js-server-start");
	util.AddNetworkString("js-server-data");
	util.AddNetworkString("js-receive-id");
	util.AddNetworkString("js-request-id");
end;

function jsonstream.Receive(id, callback)
	jsonstream.__callbacks[id] = callback;
end;

function jsonstream.Tick()
	local queue = jsonstream.__queue;
	
	for k, v in pairs(queue) do
		local data = v.data;
		local count = #data;
		
		if (count > 0) then
			net.Start("js-client-data");
			net.WriteInt(k, 32);
			net.WriteInt(count - 1, 32);
			net.WriteString(data[1]);
			
			if (SERVER) then
				net.Send(v.players);
			else
				net.SendToServer();
			end;
			
			table.remove(data, 1);
		else
			queue[k] = nil;
		end;
	end;
end;

hook.Add("Tick", "jsonstream.Tick", jsonstream.Tick);

if (SERVER) then
	function jsonstream.Send(id, data, players)
		local index = jsonstream.__currentId;
		local queue = {id = id, data = {}, players = players};
		local json = util.TableToJSON(data);
		
		while (string.len(json) > 0) do
			local len = math.min(string.len(json), 4096);
			local sub = string.sub(json, 0, len);
			
			table.insert(queue.data, sub);
			
			json = string.sub(json, len + 1);
		end;
		
		jsonstream.__queue[index] = queue;
		jsonstream.__currentId = index + 1;
		
		net.Start("js-client-start");
			net.WriteInt(index, 32);
			net.WriteString(id);
		net.Send(players);
	end;
	
	net.Receive("js-request-id", function(len, player)
		local serverIndex = jsonstream.__currentId;
		local clientIndex = net.ReadInt(32);
		
		net.Start("js-receive-id");
			net.WriteInt(serverIndex, 32);
			net.WriteInt(clientIndex, 32)
		net.Send(player);
		
		jsonstream.__currentId = serverIndex + 1;
	end);
	
	net.Receive("js-server-start", function(len, player)
		local index = net.ReadInt(32);
		local id = net.ReadString();
		
		if (not jsonstream.__data[index]) then
			jsonstream.__data[index] = {
				player = player,
				data = "",
				id = id
			}
		end;
	end);
	
	net.Receive("js-server-data", function(len, player)
		local index = net.ReadInt(32);
		local count = net.ReadInt(32);
		local data = net.ReadString();
		
		if (jsonstream.__data[index]) then
			jsonstream.__data[index].data = jsonstream.__data[index].data..data;
			
			if (count == 0) then
				local id = jsonstream.__data[index].id;
							
				if (jsonstream.__callbacks[id]) then
					jsonstream.__callbacks[id](
						util.JSONToTable(jsonstream.__data[index].data)
					);
				end;
				
				jsonstream.__data[index] = nil;
			end;
		end;
	end);
else
	function jsonstream.Send(id, data)
		local index = jsonstream.__currentId;
		local queue = {id = id, data = {}};
		local json = util.TableToJSON(data);
		
		while (string.len(json) > 0) do
			local len = math.min(string.len(json), 4096);
			local sub = string.sub(json, 0, len);
			
			table.insert(queue.data, sub);
			
			json = string.sub(json, len);
		end;
		
		jsonstream.__awaitingId[index] = queue;
		jsonstream.__currentId = index + 1;
		
		net.Start("js-request-id");
			net.WriteInt(index, 32);
		net.SendToServer();
	end;
	
	net.Receive("js-receive-id", function(len)
		local serverIndex = net.ReadInt(32);
		local clientIndex = net.ReadInt(32);
		
		if (jsonstream.__awaitingId[clientIndex]) then
			jsonstream.__queue[serverIndex] = jsonstrean.__awaitingId[clientIndex];
			jsonstream.__awaitingId[clientIndex] = nil;
		end;
	end);
	
	net.Receive("js-client-start", function(len)
		local index = net.ReadInt(32);
		local id = net.ReadString();
		
		if (not jsonstream.__data[index]) then
			jsonstream.__data[index] = {
				data = "",
				id = id
			}
		end;
	end);
	
	net.Receive("js-client-data", function(len)
		local index = net.ReadInt(32);
		local count = net.ReadInt(32);
		local data = net.ReadString();
			
		if (jsonstream.__data[index]) then
			jsonstream.__data[index].data = jsonstream.__data[index].data..data;
			
			if (count == 0) then
				local id = jsonstream.__data[index].id;

				if (jsonstream.__callbacks[id]) then
					jsonstream.__callbacks[id](
						util.JSONToTable(jsonstream.__data[index].data)
					);
				end;

				jsonstream.__data[index] = nil;
			end;
		end;
	end);
end;