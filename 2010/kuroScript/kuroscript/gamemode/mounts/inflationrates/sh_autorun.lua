--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Inflation Rates";
MOUNT.author = "kuromeku";
MOUNT.economy = 0;
MOUNT.characters = 0;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");

-- A function to convert currency.
function MOUNT:ConvertCurrency(originalCost)
	local inflationScale = kuroScript.config.Get("inflation_scale"):Get();
	
	-- Check if a statement is true.
	if (inflationScale != 1) then
		return math.ceil( ( originalCost + ( (originalCost / 2000) * (self.economy / self.characters) ) ) * inflationScale );
	else
		return math.ceil( originalCost + ( (originalCost / 2000) * (self.economy / self.characters) ) );
	end;
end;