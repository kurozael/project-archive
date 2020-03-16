--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.event = {};
openAura.event.stored = {};

-- A function to hook into an event.
function openAura.event:Hook(eventClass, eventName, isAllowed)
	if (eventName) then
		self.stored[eventClass] = {};
		self.stored[eventClass][eventName] = isAllowed;
	else
		self.stored[eventClass] = isAllowed;
	end;
end;

-- A function to get whether an event can run.
function openAura.event:CanRun(eventClass, eventName)
	local eventTable = self.stored[eventClass];
	
	if (type(eventTable) == "boolean") then
		return eventTable;
	elseif (eventTable != nil and type( eventTable[eventName] ) == "boolean") then
		return eventTable[eventName];
	end;
	
	return true;
end;