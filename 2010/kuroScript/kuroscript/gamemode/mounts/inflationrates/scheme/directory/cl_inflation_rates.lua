--[[
Name: "cl_inflation_rates.lua".
Product: "kuroScript".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Inflation Rates</font>
		</center>
		<p>
			With kuroScript, almost everything that has a price - has a dynamic one. For example, the price of doors
			will change depending on how much *NAME_CURRENCY_LOWER* is in circulation, and how many characters there are in total.
			This isn't just for the characters online, it is for every character that exists.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Inflation Rates", "kuroScript", HELP);