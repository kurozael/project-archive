--[[
Name: "cl_storage.lua".
Product: "HL2 RP".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Storage and Safekeeping</font>
		</center>
		<p>
			If you own a locker key (which can be bought from a merchant), you can go 
			to any locker, hit F2, and open up a storage menu. Here you can store any items from your inventory into a locker.
			Items that are stored in lockers can still be searched by Civil Protection if you have been tied up by them. Items that you
			store in your locker will always be there, even over map changes or server crashes.
		</p>
		<p>
			There is also another method of storage. There are certain items in the map that can you can store items in. Stay for example a desk on the map, or a box.
			By hitting F2 you can store an item there. You double click the item you want transfered over and it will be stored there. Anything stored in said container is not safe from others.
			Anyone else who hits F2 on that desk, box, suitcase or whatever will be able to view the items in it and take them if they want.
			If an item is in a box and the box is destroyed, the item will pop out. If you leave an item in a container and log off the server, it will stay there until someone takes it.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Storage and Safekeeping", "HL2 RP", HELP);