--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to load the character views.
function MOUNT:LoadCharacterViews()
	self.characterViews = {};
	
	-- Set some information.
	local characterViews = kuroScript.frame:RestoreGameData( "mounts/characterviews/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(characterViews) do
		local data = {
			position = v.position,
			angles = v.angles,
			class = v.class
		};
		
		-- Set some information.
		self.characterViews[#self.characterViews + 1] = data;
	end;
end;

-- Load the character views.
MOUNT:LoadCharacterViews();

-- A function to save the character views.
function MOUNT:SaveCharacterViews()
	local characterViews = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(self.characterViews) do
		local data = {
			position = v.position,
			angles = v.angles,
			class = v.class
		};
		
		-- Set some information.
		characterViews[#characterViews + 1] = data;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/characterviews/"..game.GetMap(), characterViews);
end;