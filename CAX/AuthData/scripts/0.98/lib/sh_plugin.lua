Clockwork.plugin.__Register = Clockwork.plugin.__Register or Clockwork.plugin.Register;
Clockwork.plugin.__Add = Clockwork.plugin.__Add or Clockwork.plugin.Add;

function Clockwork.plugin:Register(...)
	self:__Register(...);
	
	if (self.ClearHookCache) then
		self:ClearHookCache();
		self.sortedModules = nil;
		self.sortedPlugins = nil;
	end;
end;

function Clockwork.plugin:Add(...)
	self:__Add(...);
	
	if (self.ClearHookCache) then
		self:ClearHookCache();
		self.sortedModules = nil;
		self.sortedPlugins = nil;
	end;
end;