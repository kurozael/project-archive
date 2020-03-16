--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.cooldown = {};
openAura.cooldown.sizes = {};

-- A function to get a cooldown table.
function openAura.cooldown:GetTable(width, height, bAdd)
	local cooldownTable = self.sizes[width.." "..height];
	
	if (cooldownTable) then
		return cooldownTable;
	elseif (bAdd) then
		return self:AddSize(width, height);
	end;
end;

-- A function to add a cooldown size.
function openAura.cooldown:AddSize(width, height)
	local verticies = {
		{
			{x = 0, y = -(height / 2), u = 0.5, v = 0},
			{x = width / 2, y = -(height / 2), u = 1, v = 0, c = function()
				return -(width / 2), 0;
			end},
		},
		{
			{x = width / 2, y = -(height / 2), u = 1, v = 0},
			{x = width / 2, y = 0, u = 1, v = 0.5, c = function()
				return 0, -(height / 2);
			end},
		},
		{
			{x = width / 2, y = 0, u = 1, v = 0.5},
			{x = width / 2, y = height / 2, u = 1, v = 1, c = function()
				return 0, -(height / 2);
			end},
		},
		{
			{x = width / 2, y = height / 2, u = 1, v = 1},
			{x = 0, y = height / 2, u = 0.5, v = 1, c = function()
				return width / 2, 0;
			end},
		},
		{
			{x = 0, y = height / 2, u = 0.5, v = 1},
			{x = -(width / 2), y = height / 2, u = 0, v = 1, c = function()
				return width / 2, 0;
			end},
		},
		{
			{x = -(width / 2), y = height / 2, u = 0, v = 1},
			{x = -(width / 2), y = 0, u = 0, v = 0.5, c = function()
				return 0, height / 2;
			end},
		},
		{
			{x = -(width / 2), y = 0, u = 0, v = 0.5},
			{x = -(width / 2), y = -(height / 2), u = 0, v = 0, c = function()
				return 0, height / 2;
			end},
		},
		{
			{x = -(width / 2), y = -(height / 2), u = 0, v = 0},
			{x = 0, y = -(height / 2), u = 0.5, v = 0, c = function()
				return -(width / 2), 0;
			end},
		},
	};

	local editTable = table.Copy(verticies);
	
	self.sizes[width.." "..height] = {
		verticies = verticies,
		editTable = editTable
	};
	
	return self.sizes[width.." "..height];
end;

-- A function to draw a cooldown box.
function openAura.cooldown:DrawBox(x, y, width, height, progress, color, textureID, bCenter)
	local cooldownTable = self:GetTable(width, height, true);
	local octant = math.Clamp( (8 / 100) * progress, 0, 8 );
	
	if (!bCenter) then
		x = x + (width / 2);
		y = y + (height / 2);
	end;
	
	surface.SetTexture(textureID);
	surface.SetDrawColor(color.r, color.g, color.b, color.a);
	
	local polygons = { {x = x, y = y, u = 0.5, v = 0.5} };
	
	for i = 1, 8 do
		if (math.ceil(octant) == i) then
			local fraction = 1 - (i - octant);
			local nx, ny = cooldownTable.editTable[i][2].c();
			
			cooldownTable.editTable[i][2].x = x + cooldownTable.verticies[i][2].x + nx + (-nx * fraction);
			cooldownTable.editTable[i][2].y = y + cooldownTable.verticies[i][2].y + ny + (-ny * fraction);
			cooldownTable.editTable[i][1].x = x + cooldownTable.verticies[i][1].x;
			cooldownTable.editTable[i][1].y = y + cooldownTable.verticies[i][1].y;
			
			table.Add( polygons, cooldownTable.editTable[i] );
		elseif (octant > i) then
			for j = 1, 2 do
				cooldownTable.editTable[i][j].x = x + cooldownTable.verticies[i][j].x;
				cooldownTable.editTable[i][j].y = y + cooldownTable.verticies[i][j].y;
			end;
			
			table.Add( polygons, cooldownTable.editTable[i] );
		end;
	end;
	
	surface.DrawPoly(polygons);
end;

openAura.cooldown:AddSize(64, 64);
openAura.cooldown:AddSize(32, 32);