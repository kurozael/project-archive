--[[
Name: "sh_book_cos.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.base = "book_base";
ITEM.name = "Chapter One - Sorrow";
ITEM.model = "models/props_lab/bindergreenlabel.mdl";
ITEM.uniqueID = "book_cos";
ITEM.description = "A green, tattered diary-like book.";
ITEM.bookInformation = [[
<font color='blue' size='4'>Written by Man With Sorrow.</font>

Back then, I were younger and Combine had already taken over the control of our cities.
I watched it, without any kind of anger. I were confused with my own agenda at the time.
There was a girl, in same block where I lived. I loved her, but never talked to her.
She was stunning. She had beautiful, blond, curly hair. Her skin looked like milk.
I was shy, so I left presents at her door.
Messages, flowers, water...
She picked them up, I believe, because they weren't there when I came back to leave new presents.
One day, I decided I would talk to her.
But she never came back to her apartment...
I became worried. I asked around and found out that she had been taken to Nexus.
She never came back.
I saw the world engulfed in flames, when there was no fire.
I saw the world crying in sorrow, when the only sorrow was in my heart.
That was the day... the day I vowed /revenge/.
[This part seems to be ripped here from the remnants of the book].
]];

-- Register the item.
kuroScript.item.Register(ITEM);