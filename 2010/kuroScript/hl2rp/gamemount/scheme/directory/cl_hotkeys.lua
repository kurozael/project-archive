--[[
Name: "cl_hotkeys.lua".
Product: "HL2 RP".
--]]

local HELP = [[
<html>
	<font face="Arial" size="2">
		<center>
			<font color="red" size="4">Hotkeys</font>
		</center>
		<br>
		<center>
			<font color="blue">F1 - Main Menu.</font>
		</center>
		<p>
			Here you will be able to access the main menu of kuroScript where you can do various things like: read the help menu, access your inventory, change
			your vocation (if applicable), or check the scoreboard where you can view how many characters are online.
		</p>
		<center>
			<font color="blue">F2 - Door Menu.</font>
		</center>
		<p>
			Most doors you see around the map are ownable. When looking at a door press F2 to purchase it. If the door is already owned the menu will not pop up 
			and you will not be able to purchase the door. When you have purchased a door, you can give characters access to it with the menu (press F2 on it again).
			In some cases, you can sell the door again and gain back some of your *CURRENY_NAME*.
		</p>
		<center>
			<font color="blue">F3 - Tie</font>
		</center>
		<p>
			With this button, you can tie up other characters. (Be sure to have a good reason, don't be a minge.) You must have a zip-tie in your inventory. If you have a zip-tie in your inventory hit F3 while 
			facing the back of a character to tie them up. Again, you MUST be facing the characters back and must stay that way while tying up a character. If the person moves away for faces you, you will stop
			tying the character. Once a few seconds pass the character will be tied up. The person can no longer open doors, use items, punch, or use keys. While tied a character can be searched, that will be discussed
			later on. If you want to untie a character, look at them and hit Shift + Use.
		</p>
		<center>
			<font color="blue">F4 - Search</font
		</center>
		<p>
			If a character is tied up, you have the option to search them. Look at the character and hit the F4 button. A menu will pop up and you'll be able to search their inventory. If want to take away any items, double
			click the item and it will transfer to your inventory. Be sure not to abuse this. You must have a valid reason (Say disarming someone who is a threat to you).
			Also if you wish to give or plant an item on someone from your inventory, double click the item from your inventory column and transfer it over, now they own the item. Hit okay to go back to the game.
		</p>
	</font>
</html>
]];

-- Add a HTML category.
kuroScript.directory.AddHTMLCategory("Hotkeys", "HL2 RP", HELP);