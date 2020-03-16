--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.config:AddSystem("weapon_selection_multi", "Should the weapon selection be hidden if the player has only one weapon.");

-- A function to override a markup's draw function.
function PLUGIN:OverrideMarkupDraw(markupObject)
	function markupObject:Draw(xOffset, yOffset, hAlign, vAlign, alphaOverride)
		for k, v in pairs(self.blocks) do
			local alpha = v.colour.a;
			local y = yOffset + (v.height - v.thisY) + v.offset.y;
			local x = xOffset;
			
			if (alphaOverride) then
				alpha = alphaOverride;
			end;
			
			CloudScript:OverrideMainFont(v.font);
				CloudScript:DrawSimpleText(v.text, x, y, Color(v.colour.r, v.colour.g, v.colour.b, alpha), hAlign, vAlign);
			CloudScript:OverrideMainFont(false);
		end;
	end;
end;

-- A function to draw a weapon's information.
function PLUGIN:DrawWeaponInformation(itemTable, weapon, x, y, alpha)
	local informationColor = CloudScript.option:GetColor("information");
	local backgroundColor = CloudScript.option:GetColor("background");
	local clipTwoAmount = CloudScript.Client:GetAmmoCount( weapon:GetSecondaryAmmoType() );
	local clipOneAmount = CloudScript.Client:GetAmmoCount( weapon:GetPrimaryAmmoType() );
	local mainTextFont = CloudScript.option:GetFont("main_text");
	local secondaryAmmo;
	local primaryAmmo;
	local clipTwo = weapon:Clip2();
	local clipOne = weapon:Clip1();
	
	if (!weapon.Primary or !weapon.Primary.ClipSize or weapon.Primary.ClipSize > 0) then
		if (clipOne >= 0) then
			primaryAmmo = "Primary: "..clipOne.."/"..clipOneAmount..".";
		end;
	end;
	
	if (!weapon.Secondary or !weapon.Secondary.ClipSize or weapon.Secondary.ClipSize > 0) then
		if (clipTwo >= 0) then
			secondaryAmmo = "Secondary: "..clipTwo.."/"..clipTwoAmount..".";
		end;
	end;
	
	if (!weapon.Instructions) then weapon.Instructions = ""; end;
	if (!weapon.Purpose) then weapon.Purpose = ""; end;
	if (!weapon.Contact) then weapon.Contact = ""; end;
	if (!weapon.Author) then weapon.Author = ""; end;
	
	if ( itemTable or primaryAmmo or secondaryAmmo or ( weapon.DrawWeaponInfoBox
	and (weapon.Author != "" or weapon.Contact != "" or weapon.Purpose != ""
	or weapon.Instructions != "") ) ) then
		local text = "<font="..mainTextFont..">";
		local textColor = "<color=255,255,255,255>";
		local titleColor = "<color=230,230,230,255>";
		
		if (informationColor) then
			titleColor = "<color="..informationColor.r..","..informationColor.g..","..informationColor.b..",255>";
		end;
		
		if (itemTable and itemTable.description != "") then
			text = text..titleColor.."DESCRIPTIPON</color>\n"..textColor..CloudScript.config:Parse(itemTable.description).."</color>\n";
		end;
		
		if (primaryAmmo or secondaryAmmo) then
			text = text..titleColor.."AMMUNITION</color>\n";
			
			if (secondaryAmmo) then
				text = text..textColor..secondaryAmmo.."</color>\n";
			end;
			
			if (primaryAmmo) then
				text = text..textColor..primaryAmmo.."</color>\n";
			end;
		end;
		
		if (weapon.Instructions != "") then
			text = text..titleColor.."INSTRUCTIONS</color>\n"..textColor..weapon.Instructions.."</color>\n";
		end;
		
		if (weapon.Purpose != "") then
			text = text..titleColor.."PURPOSE</color>\n"..textColor..weapon.Purpose.."</color>\n";
		end;
		
		if (weapon.Contact != "") then
			text = text..titleColor.."CONTACT</color>\n"..textColor..weapon.Contact.."</color>\n";
		end;
		
		if (weapon.Author != "") then
			text = text..titleColor.."AUTHOR</color>\n"..textColor..weapon.Author.."</color>\n";
		end;
		
		weapon.InfoMarkup = markup.Parse(text.."</font>", 248);
		self:OverrideMarkupDraw(weapon.InfoMarkup);
		
		local weaponMarkupHeight = weapon.InfoMarkup:GetHeight();
		local realY = y - (weaponMarkupHeight / 2);
		local info = {
			drawBackground = true,
			weapon = weapon,
			height = weaponMarkupHeight + 8,
			width = 260,
			alpha = alpha,
			x = x - 4,
			y = realY
		};
		
		CloudScript.plugin:Call("PreDrawWeaponSelectionInfo", info);
		
		if (info.drawBackground) then
			CloudScript:DrawTexturedGradientBox( 2, x - 4, realY, 260, weaponMarkupHeight + 8, Color( backgroundColor.r, backgroundColor.g, backgroundColor.b, math.min(backgroundColor.a, alpha) ) );
		end;
		
		if (weapon.InfoMarkup) then
			weapon.InfoMarkup:Draw(x + 4, realY + 4, nil, nil, alpha);
		end;
	end;
end;

-- A function to get a weapon's print name.
function PLUGIN:GetWeaponPrintName(weapon)
	local printName = weapon:GetPrintName();
	local class = string.lower( weapon:GetClass() );
	
	if (printName and printName != "") then
		self.weaponPrintNames[class] = printName;
	end;
	
	return self.weaponPrintNames[class] or printName;
end;