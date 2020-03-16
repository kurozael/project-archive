--[[
Name: "cl_combine_voices.lua".
Product: "HL2 RP".
--]]

local amount = 0;
local k, v;

-- Check if a statement is true.
if (kuroScript.game and kuroScript.game.voices) then
	local HELP = [[
	<html>
		<font face="Arial" size="2">
			<center>
				<font color="red" size="4">Combine Voices</font>
			</center>
	]];

	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.game.voices) do
		if (v.class == "Combine") then
			amount = amount + 1;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.game.voices) do
		if (v.class == "Combine") then
			amount = amount - 1;
			
			-- Check if a statement is true.
			if (amount == 0) then
				HELP = HELP..[[<font color="blue">]]..v.command..[[</font><br>]]..v.phrase;
			else
				HELP = HELP..[[<font color="blue">]]..v.command..[[</font><br>]]..v.phrase..[[<br><br>]];
			end;
		end;
	end;

	-- Set some information.
	HELP = HELP..[[
		</body>
	</html>
	]];

	-- Add a HTML category.
	kuroScript.directory.AddHTMLCategory("Combine Voices", "Voice Commands", HELP);
end;