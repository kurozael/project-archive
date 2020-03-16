--[[
Name: "cl_dispatch_voices.lua".
Product: "HL2 RP".
--]]

local k, v;

-- Check if a statement is true.
if (kuroScript.game and kuroScript.game.voices) then
	local HELP = [[
	<html>
		<font face="Arial" size="2">
			<center>
				<font color="red" size="4">Dispatch Voices</font>
			</center>
	]];

	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.game.dispatchVoices) do
		if (k == #kuroScript.game.dispatchVoices) then
			HELP = HELP..[[<font color="blue">]]..v.command..[[</font><br>]]..v.phrase;
		else
			HELP = HELP..[[<font color="blue">]]..v.command..[[</font><br>]]..v.phrase..[[<br><br>]];
		end;
	end;

	-- Set some information.
	HELP = HELP..[[
		</body>
	</html>
	]];

	-- Add a HTML category.
	kuroScript.directory.AddHTMLCategory("Dispatch Voices", "Voice Commands", HELP);
end;