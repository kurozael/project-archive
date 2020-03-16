--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the state is constructed.
function STATE:__init() end;

-- Called when the state is unloaded.
function STATE:OnUnload() end;

-- Called when the state is loaded.
function STATE:OnLoad() end;

-- A function to get the sprite's class.
function STATE:GetClass()
	return self.m_sClassName;
end;