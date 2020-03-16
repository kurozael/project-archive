--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura:HookDataStream("DynamicAdverts", function(data)
	for k, v in pairs(data) do
		PLUGIN:CreateHTMLPanel(v);
	end;
	
	PLUGIN.dynamicAdverts = data;
end);

openAura:HookDataStream("DynamicAdvertAdd", function(data)
	PLUGIN.dynamicAdverts[#PLUGIN.dynamicAdverts + 1] = data;
	PLUGIN:CreateHTMLPanel(data);
end);

openAura:HookDataStream("DynamicAdvertRemove", function(data)
	for k, v in pairs(PLUGIN.dynamicAdverts) do
		if (v.position == data) then
			PLUGIN.dynamicAdverts[k] = nil;
			
			if ( IsValid(v.panel) ) then
				v.panel:Remove();
			end;
		end;
	end;
end);

-- A function to create a HTML panel.
function PLUGIN:CreateHTMLPanel(dynamicAdvert)
	dynamicAdvert.panel = vgui.Create("HTML");
	dynamicAdvert.panel:SetPaintedManually(true);
	dynamicAdvert.panel:SetSize(dynamicAdvert.width, dynamicAdvert.height);
	dynamicAdvert.panel:SetPos(0, 0);
	dynamicAdvert.panel:SetHTML( [[
		<head>
			<style type="text/css">
				body, html {
					vertical-align: 50%;
					overflow: hidden;
					text-align: center;
					padding: 0;
					margin: 0;
					height: 100%;
				}
				img {
					position: relative;
					margin-top: -]]..(dynamicAdvert.height / 2)..[[px;
					heigth: ]]..dynamicAdvert.height..[[;
					width: ]]..dynamicAdvert.width..[[;
					top: 50%;
				}
			</style>
		</head>
		<body scroll="no" scrolling="no">
			<img src="]]..dynamicAdvert.url..[["/>
		</body>
	]] );
end;