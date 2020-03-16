--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

NEXUS:HookDataStream("DynamicAdverts", function(data)
	for k, v in pairs(data) do
		MOUNT:CreateHTMLPanel(v);
	end;
	
	MOUNT.dynamicAdverts = data;
end);

NEXUS:HookDataStream("DynamicAdvertAdd", function(data)
	MOUNT.dynamicAdverts[#MOUNT.dynamicAdverts + 1] = data;
	MOUNT:CreateHTMLPanel(data);
end);

NEXUS:HookDataStream("DynamicAdvertRemove", function(data)
	for k, v in pairs(MOUNT.dynamicAdverts) do
		if (v.position == data) then
			MOUNT.dynamicAdverts[k] = nil;
			
			if ( IsValid(v.panel) ) then
				v.panel:Remove();
			end;
		end;
	end;
end);

-- A function to create a HTML panel.
function MOUNT:CreateHTMLPanel(dynamicAdvert)
	dynamicAdvert.panel = vgui.Create("HTML");
	dynamicAdvert.panel:SetPaintedManually(true);
	dynamicAdvert.panel:SetSize(dynamicAdvert.width, dynamicAdvert.height);
	dynamicAdvert.panel:SetPos(0, 0);
	dynamicAdvert.panel:SetHTML( [[
		<head>
			<style type="text/css">
				body, html {
					vertical-align: 50%;
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
		<body scroll="no">
			<img src="]]..dynamicAdvert.url..[["/>
		</body>
	]] );
end;