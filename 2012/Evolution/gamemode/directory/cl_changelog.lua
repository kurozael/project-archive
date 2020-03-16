--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CHANGELOG = "";
local REMOVED = "http://script.cloudsixteen.com/icons/removed.gif";
local FIXED = "http://script.cloudsixteen.com/icons/fixed.gif";
local ADDED = "http://script.cloudsixteen.com/icons/added.gif";
local TIP = "http://script.cloudsixteen.com/icons/tip.gif";

local function AddVersion(version, changeLog)
	local explodedChanges = string.Explode("\n", changeLog);
	local tChanges = {};
	
	for k, v in ipairs(explodedChanges) do
		local tValue = string.Explode("|", (string.gsub(v, "\t", "")));
		
		if (tValue[1] and tValue[2]) then
			if (tValue[1] == "A") then
				tValue[1] = ADDED;
			elseif (tValue[1] == "F") then
				tValue[1] = FIXED;
			elseif (tValue[1] == "R") then
				tValue[1] = REMOVED;
			elseif (tValue[1] == "T") then
				tValue[1] = TIP;
			end;
			
			tChanges[#tChanges + 1] = tValue;
		end;
	end;
	
	CHANGELOG = CHANGELOG..[[
		<div class="cwTitleSeperator">]]..version..[[</div>
	]];
	
	for k, v in ipairs(tChanges) do
		local text = v[2];
		local icon = v[1];
		
		CHANGELOG = CHANGELOG..[[
			<div class="cwContentText">
				<img src="]]..icon..[[" style="vertical-align:text-bottom;"/>
				]]..text..[[
			</div>
		]];
	end;
end;

AddVersion("0.1c", [[
	T|Doubled the damage that landmines do when they explode.
	T|You now cannot tie or search a character in a Safe Zone.
]]);

AddVersion("0.1b", [[
	A|Increased the cost of ammunition just slightly.
	A|Lowered the amount of money earned in total per hour.
	A|Attributes now increase at 25% of the original speed.
	A|Significantly increased the amount of damage melee weapons do.
	F|Fixed the Safe Zone text being displayed to everyone.
	F|Fixed the 'leaving Safe Zone' text showing even when you aren't in one.
	F|Fixed the keys from not working on doors.
	F|Fixed stealthed landmines having an outline.
]]);

AddVersion("0.1a", [[
	A|The Landmine and Landmine upgrade/building system.
	A|The Backpack and Backpack upgrading system.
	A|Persistent Kevlar vests, with real time damage.
	A|A variety of new UI updates to both Clockwork and Aperture.
	A|New income and outcome costs (halved everything).
	A|When 'Hungry' your health will not regenerate.
	A|When 'Thirsty' your stamina will not regenerate.
]]);

Clockwork.directory:AddCategoryMatch("Aperture", "[icon]", "http://script.cloudsixteen.com/images/icons/text_dropcaps.png");
Clockwork.directory:AddCategoryPage("Aperture", nil, CHANGELOG);
Clockwork.directory:SetCategoryTip("Aperture", "Check out the latest revisions to the Aperture schema.");