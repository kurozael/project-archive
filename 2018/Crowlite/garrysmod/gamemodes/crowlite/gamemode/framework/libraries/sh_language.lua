--[[
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;

--[[
	@codebase Shared
	@details Provides an interface for the language system.
--]]
local CrowLanguage = Crow.nest:GetLibrary("language");

--[[ Private Members ]]--
CrowLanguage.__stored = CrowLanguage.__stored or {};
--CrowLanguage.__default = CrowLanguage.__default or "english";
CrowLanguage.__default = CrowLanguage.__default or "en";
CrowLanguage.__language = CrowLanguage.__language or nil;

--[[
	@codebase Shared
	@details Find the language table for a given language or create if it doesn't exist.
	@param String The language table name to find.
	@returns The language table for the given language.
--]]
function CrowLanguage:Find(name)
	if (!self.__stored[name]) then
		self.__stored[name] = CrowNest:NewInstance(CROW_LANGUAGE);
	end;
	
	return self.__stored[name];
end;

--[[
	@codebase Shared
	@details Get a table containing all language data.
	@returns The table containing all language data.
--]]
function CrowLanguage:GetAll()
	return self.__stored;
end;

--[[
	@codebase Shared
	@details Add a table of phrases to the given language.
	@param String The language table name to add phrases to.
	@param Table A table of phrases to merge with the language table.
	@param Various A list of arguments to replace in the string.
	@returns The generated output phrase.
--]]
function CrowLanguage:AddPhrases(language, phrases)
	table.Merge(self:Find(language), phrases);
end;

--[[
	@codebase Shared
	@details Get the language string for the given phrase.
	@param String The language table name to search for.
	@param String The phrase name to search for.
	@param Various A list of arguments to replace in the string.
	@returns The generated output phrase.
--]]
function CrowLanguage:GetPhrase(language, phrase, ...)
	local output = nil;
	local arguments = {...};
	
	if (language and self.__stored[language]) then
		output = self.__stored[language][phrase];
	end;
	
	if (!output) then
		output = self.__stored[self.__default][phrase] or phrase;
	end;
	
	for k, v in pairs(arguments) do
		output = string.gsub(output, "#"..k, tostring(v), 1);
	end;
	
	return output;
end;

if (CLIENT) then
	function PHRASE(phrase, ...)
		return CrowLanguage:GetPhrase(nil, phrase, ...);
	end;
else
	function PHRASE(player, phrase, ...)
		return CrowLanguage:GetPhrase(nil, phrase, ...);
	end;
end;