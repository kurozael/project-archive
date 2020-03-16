--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local REMOVED = "http://kurozael.com/CloudScript/icons/removed.gif";
local FIXED = "http://kurozael.com/CloudScript/icons/fixed.gif";
local ADDED = "http://kurozael.com/CloudScript/icons/added.gif";
local TIP = "http://kurozael.com/CloudScript/icons/tip.gif";

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
		<div class="cloudInfoTitle">]]..version..[[</div>
	]];
	
	for k, v in ipairs(tblChanges) do
		local text = v;
		local icon = ADDED;
		
		if (type(v) == "table") then
			icon = v[1]; text = v[2];
		end;
		
		changelog = changelog..[[
			<div class="cloudInfoText">
				<img src="]]..icon..[[" style="vertical-align:text-bottom;"/>
				]]..text..[[
			</div>
		]];
	end;
end;

AddVersion("1.0", [[
	T|Began work on CloudScript, and added Linux support.
]] );

CloudScript.directory:AddCategoryPage("Changelog", nil, changelog);