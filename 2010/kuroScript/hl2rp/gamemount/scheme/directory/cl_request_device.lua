--[[
Name: "cl_request_device.lua".
Product: "HL2 RP".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>Request Device</center>
		<p>
			Request devices allow citizens to ask for help remotely. A sort of one way radio to the Civil Protection. You can buy a request device off any local merchant.
			Once you have a request device in your possesion, type "$command_prefix$request <message>." Example. "$command_prefix$request I need help at the 45th Apartments, second floor, hurry!". Use these
			anytime you need help from Civil Protection, like if you need help with an intruder or you're a loyalist who found someone selling contraband.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Request Device", "HL2 RP", HELP);