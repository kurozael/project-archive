--[[
Name: "cl_rations.lua".
Product: "HL2 RP".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Rations</font>
		</center>
		<p>
			Rations are packages that contain your daily supplies, and *NAME_CURRENCY_LOWER*. Each ration usually contains: food, water and some currency to spend.
			Rations are either dispensed from a ration dispenser, or handed out by Civil Protection.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Rations", "HL2 RP", HELP);