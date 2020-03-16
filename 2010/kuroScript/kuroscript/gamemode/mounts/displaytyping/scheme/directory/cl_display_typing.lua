--[[
Name: "cl_display_typing.lua".
Product: "kuroScript".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Display Typing</font>
		</center>
		<p>
			Whenever a player is typing a message and you are within a certain distance of them a message pops up over their heads. You can use this to know
			that others are typing to stop and listen to them or engage a conversation. One thing you do not do is kill someone while they are typing. Try to
			avoid leaving a character who is typing, or ignoring them - let them say what they have to say.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Display Typing", "kuroScript", HELP);