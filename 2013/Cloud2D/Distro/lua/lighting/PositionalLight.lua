class "PositionalLight" (Light);

function PositionalLight:__init(rayHandler, rays, color, distance, x, y, dirDegree)
	Light.__init(self, rayHandler, rays, color, distance, dirDegree);
	
	self.tmpEnd = Vec2();
	self.start = Vec2(x, y);
	self.sin = {};
	self.cos = {};
	self.endX = {};
	self.endY = {};
	
	for i = 0, self.rayNum do
		self.endX[i] = 0;
		self.endY[i] = 0;
		self.cos[i] = 0;
		self.sin[i] = 0;
	end;
	
	local attributes = VertexAttributes();
		attributes:Add(VertexAttribute(VERTEX_POSITION, 0, "Position"));
		attributes:Add(VertexAttribute(VERTEX_COLOR, 2, "Color"));
		attributes:Add(VertexAttribute(VERTEX_GENERIC, 3, "Generic"));
		
	self.lightMesh = Mesh(self.staticLight, self.vertexNum * 2, attributes);
	self.softShadowMesh = Mesh(self.staticLight, self.vertexNum * 2, attributes);
end;

function PositionalLight:attachToEntity(entity, offsetX, offSetY)
	if (self.entity == entity) then return; end;
	
	self.entityOffsetX = offsetX or 0;
	self.entityOffsetY = offSetY or 0;
	self.entity = entity;
	
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function PositionalLight:getPosition()
	return Vec2(self.start.x, self.start.y);
end;

function PositionalLight:getEntity()
	return self.entity;
end;

function PositionalLight:getX() return self.start.x; end;

function PositionalLight:getY() return self.start.y; end;

function PositionalLight:setPosition(position)
	if (self.start.x == position.x
	and self.start.y == position.y) then
		return;
	end;
	
	self.start.x = position.x;
	self.start.y = position.y;
	
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function PositionalLight:update()
	if ((self.entity and self.entity:IsValid()) and not self.staticLight) then
		local entPos = self.entity:GetCenter();
		local angleD = self.entity:GetAngle():Degrees();
		local angleR = self.entity:GetAngle():Radians();
		local aCos = math.cos(angleR);
		local aSin = math.sin(angleR);
		local dX = self.entityOffsetX * aCos - self.entityOffsetY * aSin;
		local dY = self.entityOffsetX * aSin + self.entityOffsetY * aCos;
		self.start.x = entPos.x + dX;
		self.start.y = entPos.y + dY;
		
		self:setDirection(angleD);
	end;

	if (self.rayHandler.culling) then
		self.culled = (not self.rayHandler:intersect(
			self.start.x, self.start.y, self.distance + self.softShadowLength)
		);
		
		if (self.culled) then return; end;
	end;

	if (self.staticLight) then
		return;
	end;

	for i = 0, self.rayNum do
		self.tmpEnd.x = self.endX[i] + self.start.x;
		self.tmpEnd.y = self.endY[i] + self.start.y;
		self.index = i;
		self.mx[i] = self.tmpEnd.x;
		self.my[i] = self.tmpEnd.y;
		self.f[i] = 1;
		
		if (not self.xray) then
			self:castRay(self.start, self.tmpEnd, self.entity);
		end;
	end;
	
	self:setMesh();
end;

local PosToOpenGL = function(position)
	local camPos = camera.GetPos();
		local cX = ((2 / display.GetW()) * camPos.x) - 1;
		local cY = ((2 / display.GetH()) * camPos.y) - 1;
		local x = ((2 / display.GetW()) * position.x) - 1;
		local y = ((2 / display.GetH()) * position.y) - 1;
	return Vec2(x - cX, y - cY);
end;

function PositionalLight:setMesh()
	self.segments = {};
	self.lightMesh:Reset();
	
	local vertex = Vertex(self.start);
		vertex:SetColor(self.color);
		vertex:SetData(0.85);
	self.lightMesh:AddVertex(vertex);
	
	for i = 0, self.rayNum do
		local vertex = Vertex(Vec2(self.mx[i], self.my[i]));
			vertex:SetColor(self.color);
			vertex:SetData(math.min(1 - self.f[i], 0.85));
		self.lightMesh:AddVertex(vertex);
	end;
	
	if (not self.soft or self.xray) then
		return;
	end;
	
	self.segments = {};
	self.softShadowMesh:Reset();
	
	for i = 0, self.rayNum do
		local generic = (1 - self.f[i]);
		
		local vertex = Vertex(Vec2(self.mx[i], self.my[i]));
			vertex:SetColor(self.color);
			vertex:SetData(generic);
		self.softShadowMesh:AddVertex(vertex);
		
		local vertex = Vertex(Vec2(
			self.mx[i] + generic * self.softShadowLength * self.cos[i],
			self.my[i] + generic * self.softShadowLength * self.sin[i]
		));
		
		vertex:SetColor(Color(0, 0, 0, 0));
		vertex:SetData(0);
		
		self.softShadowMesh:AddVertex(vertex);
	end;
end;

function PositionalLight:render()
	if (self.rayHandler.culling and self.culled) then
		return;
	end;
	
	self.rayHandler.lightRenderedLastFrame = self.rayHandler.lightRenderedLastFrame + 1;
	self.lightMesh:Draw(self.rayHandler.lightShader, CL_TRIANGLE_FAN); --CL_TRIANGLE_FAN
	
	if (self.soft and not self.xray) then
		self.softShadowMesh:Draw(self.rayHandler.lightShader, CL_TRIANGLE_STRIP); -- CL_TRIANGLE_STRIP
	end;
end;

function PositionalLight:contains(x, y)
	local dX = self.start.x - x;
	local dY = self.start.y - y;
	local dst2 = dX * dX + dY * dY;
	
	if (self.distance * self.distance <= dst2) then
		return false;
	end;
	
	local oddNodes = false;
	local x2 = (self.mx[self.rayNum] or self.start.x);
	local y2 = (self.my[self.rayNum] or self.start.y);
	local x1, y1 = nil;
	
	for i = 0, self.rayNum do
		x1 = self.mx[i];
		y1 = self.my[i];
		
		if (((y1 < y) and (y2 >= y)) or (y1 >= y) and (y2 < y)) then
			if ((y - y1) / (y2 - y1) * (x2 - x1) < (x - x1)) then
				oddNodes = not oddNodes;
			end;
		end;
		
		x2 = x1;
		y2 = y1;
	end;
	
	return oddNodes;
end;