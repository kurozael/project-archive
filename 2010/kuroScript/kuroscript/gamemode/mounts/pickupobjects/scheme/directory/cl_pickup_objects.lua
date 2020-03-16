--[[
Name: "cl_pickup_objects.lua".
Product: "kuroScript".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Pickup Objects</font>
		</center>
		<p>
			Pickup is a SWEP/Tool that can be used to pick up other items or objects. Look at the object you want to pick up and hit secondary fire. You can move around with
			the object in your hands, drop it again with reload, or throw it with your primary fire. Do not use this to prop kill OOCly. You can also drag bodies.
			When dragging a body, you cannot run while dragging it, you will lose your grip. Do not go around dragging dead bodies like an idiot. If you want to pull a dead
			body out of the streets and into an alley or something, okay.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Pickup Objects", "kuroScript", HELP);