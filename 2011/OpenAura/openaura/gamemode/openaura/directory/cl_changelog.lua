--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local REMOVED = "http://kurozael.com/openaura/icons/removed.gif";
local FIXED = "http://kurozael.com/openaura/icons/fixed.gif";
local ADDED = "http://kurozael.com/openaura/icons/added.gif";
local TIP = "http://kurozael.com/openaura/icons/tip.gif";

local changelog = "";

local function AddVersion(version, changes)
	local explodedChanges = string.Explode("\n", changes);
	local tblChanges = {};
	
	for k, v in ipairs(explodedChanges) do
		local tblValue = string.Explode( "|", string.gsub(v, "\t", "") );
		
		if (tblValue[1] == "A") then
			tblValue[1] = ADDED;
		elseif (tblValue[1] == "F") then
			tblValue[1] = FIXED;
		elseif (tblValue[1] == "R") then
			tblValue[1] = REMOVED;
		elseif (tblValue[1] == "T") then
			tblValue[1] = TIP;
		end;
		
		tblChanges[#tblChanges + 1] = tblValue;
	end;
	
	changelog = changelog..[[
		<div class="auraInfoTitle">]]..version..[[</div>
	]];
	
	for k, v in ipairs(tblChanges) do
		local text = v;
		local icon = ADDED;
		
		if (type(v) == "table") then
			icon = v[1]; text = v[2];
		end;
		
		changelog = changelog..[[
			<div class="auraInfoText">
				<img src="]]..icon..[[" style="vertical-align:text-bottom;"/>
				]]..text..[[
			</div>
		]];
	end;
end;

AddVersion("1.12", [[
	F|Error with Moderator when using the Color Modify setting server-side.
	F|Supposed issue with Salesman editing and other trivial bug fixes.
	R|Removed Cross Server Chat due to exploit, remove plugins/crossserverchat/ directory please.
	A|Added support for Attribute icons.
]] );

AddVersion("1.11", [[
	F|Error with openAura.option:GetColor for some schemas.
	F|Crashing at startup (tmysql issue).
]] );

AddVersion("1.1", [[
	A|Added the openAura.donator library (in preparation for OpenDonate).
	A|Added openAura:Replace as a better alternative to string.Replace.
	A|Added the OpenAura:OpenAuraItemInitialized(itemTable) hook.
	A|Added openAura.plugin:Add(name, module) to add a table as a module.
	A|Added a command to change the map (MapChange).
	A|Added a command to restart the map (MapRestart).
	A|Added a screen tilt when strafing for effect.
	R|Removed the background from the chatbox.
	F|Huge typing text on the display typing plugin.
	F|The flags directory panel from being messed up.
	T|Improved Combine Soldier based animations slightly.
	T|Increased the size of the model panel in the character menu.
	T|Improved the theme system and changed the default skin slightly.
	T|Altered the width of menu panels.
]] );

AddVersion("1.09", [[
	F|Fixed the module problems some users experienced (delete old gm_openaura_core.dll and replace with new).
	F|Fixed the problems with Clip1 being a nil value.
	A|Added mass to ragdoll bones to make their movement a bit more realistic.
	A|Added a faster explode function (this increases FPS on the client slightly).
	A|The openAura.theme library.
	R|Removed the 'typing_visible_only' config option.
	R|Fixed errors with the new GMod update.
	T|Switched the 'typing' plugin to 3D2D.
	T|Some minor optimizations.
]] );

AddVersion("1.08", [[
	A|Added the openAura:PlayerFireWeapon(player, weapon, clipType, ammoType) hook.
	A|Added the openAura:GetAmmoInformation(weapon) function.
	A|Added gm_sourcenet3 to add support for cool networking stuff.
	T|Updated the gm_openaura_core.dll module just slightly, encryption update will come later.
]] );

AddVersion( "1.07", [[
	A|Added the openAura:PlayerAdjustBulletInfo(player, bulletInfo) hook.
	A|Added a faint vignette by default which can be disabled in the config.
	F|Fixed the 3D2D text being visible through certain things that it shouldn't be.
	F|Fixed the generators not printing, finally fixed the generators for good.
	F|Fixed the Moderator from not rebuilding itself properly.
	T|The PlayerAdjustBulletInfo hook can be used for developers to adjust accuracy and other stuff.
	T|Reduced the loading time of the OpenAura authentication system.
]] );

AddVersion( "1.06", [[
	F|Fixed the generators from not depleting their power.
	F|Various other issues with the HL2 RP schema.
	F|The strange crashing that some users experienced.
	T|Secured the whitelisting system and reduced starting times.
]] );

AddVersion( "1.05", [[
	A|Added a Credits page to the directory under the OpenAura section.
	A|Added a new default sv_loadingurl for OpenAura customers (only if you don't have a custom one already).
	F|Fixed the generators from starting with zero power (sorry for this, it was a silly mistake).
	T|The Directory library has been altered slightly, with a new master formatting system.
	T|Updated the changelog to look nicer, did the same to the Updates page.
]] );

openAura.directory:AddCategoryPage("Changelog", nil, changelog);