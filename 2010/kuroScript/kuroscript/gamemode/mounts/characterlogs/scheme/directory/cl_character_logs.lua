--[[
Name: "cl_character_logs.lua".
Product: "kuroScript".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Character Logs</font>
		</center>
		<p>
			You can use character logs as a recorder to log personal thoughts and the like. To write a character log type $command_prefix$charlog "This is a test character log."
			The writing must be in quotations. Once you have written the log it will be saved at http://kuromeku.com/forums/ under your User CP. You must have a forum account
			and have linked the account to your profile using your Steam ID. Anyone can view your logs when viewing your profile so be careful about what you say.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Character Logs", "kuroScript", HELP);