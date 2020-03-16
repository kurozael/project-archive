--[[
Name: "cl_biosignal.lua".
Product: "HL2 RP".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Biosignal</font>
		</center>
		<p>
			Biosignal is a system by which the Combine can identify items and doors which you own if they have recorded yours. Your biosignal can only be recorded
			by the Combine if you are tied up. Once your biosignal is recorded, it is permanent, there is no way around it. Once your biosignal is on record
			any door you own will be recognized as yours. So if you're on the run or something, and you buy a door, the Combine can scan the door and know it's yours and you may
			possibly be in there.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Biosignal", "HL2 RP", HELP);