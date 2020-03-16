--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.game.name = "HL2 RP";
kuroScript.game.author = "kuromeku";
kuroScript.game.customPermits = {};

-- Set some information.
DEFAULT_DATE = {month = 1, year = 20, day = 1};
DEFAULT_TIME = {minute = 0, hour = 0, day = 1};

-- Set some information.
NAME_MENU = "Standard Issue Catalog";
NAME_CURRENCY = "Tokens";
MODEL_CURRENCY = "models/props_lab/box01a.mdl";
NAME_CURRENCY_LOWER = "tokens";

-- A function to format currency.
function FORMAT_CURRENCY(amount, single, lower)
	amount = math.Round(amount);
	
	-- Check if a statement is true.
	if (!single) then
		if (lower) then
			return string.format( "%s "..NAME_CURRENCY_LOWER, tostring(amount) );
		else
			return string.format( "%s "..NAME_CURRENCY, tostring(amount) );
		end;
	else
		return string.format( "%s", tostring(amount) );
	end;
end;

-- Register a global networked table.
RegisterNWTableGlobal( {
	{"ks_PKMode", 0, NWTYPE_CHAR, REPL_EVERYONE}
} );

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_Antidepressants", 0, NWTYPE_NUMBER, REPL_PLAYERONLY},
	{"ks_PermaKilled", false, NWTYPE_BOOL, REPL_PLAYERONLY},
	{"ks_DonatorIcon", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_CustomClass", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_HiddenItem", "", NWTYPE_STRING, REPL_PLAYERONLY},
	{"ks_BeingTied", false, NWTYPE_BOOL, REPL_PLAYERONLY},
	{"ks_CitizenID", "", NWTYPE_STRING, REPL_PLAYERONLY},
	{"ks_NameScan", false, NWTYPE_BOOL, REPL_PLAYERONLY},
	{"ks_Scanner", NULL, NWTYPE_ENTITY, REPL_EVERYONE},
	{"ks_Donator", false, NWTYPE_BOOL, REPL_EVERYONE},
	{"ks_Clothes", "", NWTYPE_STRING, REPL_PLAYERONLY},
	{"ks_Icon", "", NWTYPE_STRING, REPL_EVERYONE},
	{"ks_Tied", 0, NWTYPE_CHAR, REPL_EVERYONE}
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/sh_voices.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");

-- Set some information.
kuroScript.quiz.SetEnabled(true);
kuroScript.quiz.AddQuestion("How many hours did it take for the Universal Union to take over Earth?", 3, "Three.", "Five.", "Seven.");
kuroScript.quiz.AddQuestion("Do you understand that you can still be banned even if you disconnect?", 1, "Yes.", "No.");
kuroScript.quiz.AddQuestion("Can you type properly, using capital letters and full-stops?", 2, "yes i can", "Yes, I can.");
kuroScript.quiz.AddQuestion("Can you roleplay without being the centre of attention?", 1, "Yes.", "No.");
kuroScript.quiz.AddQuestion("Do you understand that this is set before Gordon Freeman?", 1, "Yes.", "No.");
kuroScript.quiz.AddQuestion("Who volunteered to be the administrator of Earth?", 3, "Eli Vance.", "Isaac Kleiner.", "Wallace Breen.");
kuroScript.quiz.AddQuestion("Can you roleplay without crime and weapons?", 1, "Yes.", "No.");
kuroScript.quiz.AddQuestion("What type of game is roleplay?", 1, "Slow paced and relaxed.", "Fast paced shoot 'em up.", "Get rich and collect items.");
kuroScript.quiz.AddQuestion("What universe is this set in?", 2, "Real Life.", "Half-Life 2.");
kuroScript.quiz.AddQuestion("What is passive roleplay?", 2, "Gaining access to something significant.", "Roleplay you do when no events are happening.");
kuroScript.quiz.AddQuestion("What is powergaming?", 2, "Informing an administrator about a punchwhore.", "Forcing an action upon a character.", "Using OOC information IC");
kuroScript.quiz.AddQuestion("What is metagaming?", 1, "Using OOC information IC.", "Forcing an action upon a character.");
kuroScript.quiz.AddQuestion("What is OOC?", 2, "Out-of-Context.", "Out-of-Character.");
kuroScript.quiz.AddQuestion("What is IC?", 1, "In-Character.", "In-Context.");

-- A function to add a custom permit.
function kuroScript.game:AddCustomPermit(name, flag, model)
	local formattedName = string.gsub(name, "[%s%p]", "");
	
	-- Set some information.
	self.customPermits[ string.lower(formattedName) ] = {
		model = model,
		name = name,
		flag = flag,
		key = kuroScript.frame:SetCamelCase(formattedName, true)
	};
end;

-- A function to check if a string is a Combine rank.
function kuroScript.game:IsStringCombineRank(text, rank)
	if (type(rank) == "table") then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(rank) do
			if ( self:IsStringCombineRank(text, v) ) then
				return true;
			end;
		end;
	elseif (rank == "EpU") then
		if ( string.find(text, "%pSeC%p") or string.find(text, "%pDvL%p")
		or string.find(text, "%pEpU%p") ) then
			return true;
		end;
	else
		return string.find(text, "%p"..rank.."%p");
	end;
end;

-- A function to check if a player is a Combine rank.
function kuroScript.game:IsPlayerCombineRank(player, rank)
	local name = player:Name();
	
	-- Check if a statement is true.
	if (type(rank) == "table") then
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs(rank) do
			if ( self:IsPlayerCombineRank(player, v) ) then
				return true;
			end;
		end;
	elseif (rank == "EpU") then
		if ( string.find(name, "%pSeC%p") or string.find(name, "%pDvL%p")
		or string.find(name, "%pEpU%p") ) then
			return true;
		end;
	else
		return string.find(name, "%p"..rank.."%p");
	end;
end;

-- A function to get a player's Combine rank.
function kuroScript.game:GetPlayerCombineRank(player)
	local class;
	
	-- Check if a statement is true.
	if (SERVER) then
		class = player:QueryCharacter("class");
	else
		class = kuroScript.player.GetClass(player);
	end;
	
	-- Check if a statement is true.
	if (class == CLASS_OTA) then
		if ( self:IsPlayerCombineRank(player, "OWS") ) then
			return 0;
		elseif ( self:IsPlayerCombineRank(player, "EOW") ) then
			return 2;
		elseif ( self:IsPlayerCombineRank(player, "COMM") ) then
			return 3;
		else
			return 1;
		end;
	elseif ( self:IsPlayerCombineRank(player, "RCT") ) then
		return 0;
	elseif ( self:IsPlayerCombineRank(player, "04") ) then
		return 1;
	elseif ( self:IsPlayerCombineRank(player, "03") ) then
		return 2;
	elseif ( self:IsPlayerCombineRank(player, "02") ) then
		return 3;
	elseif ( self:IsPlayerCombineRank(player, "01") ) then
		return 4;
	elseif ( self:IsPlayerCombineRank(player, "OfC") ) then
		return 6;
	elseif ( self:IsPlayerCombineRank(player, "EpU") ) then
		return 7;
	elseif ( self:IsPlayerCombineRank(player, "DvL") ) then
		return 8;
	elseif ( self:IsPlayerCombineRank(player, "SeC") ) then
		return 9;
	elseif ( self:IsPlayerCombineRank(player, "SCANNER") ) then
		if ( !self:IsPlayerCombineRank(player, "SYNTH") ) then
			return 10;
		else
			return 11;
		end;
	else
		return 5;
	end;
end;

-- A function to get if a class is Combine.
function kuroScript.game:IsCombineClass(class)
	return (class == CLASS_CPA or class == CLASS_OTA);
end;