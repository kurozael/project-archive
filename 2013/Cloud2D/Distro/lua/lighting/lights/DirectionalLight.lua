class "DirectionalLight" (Light);

function DirectionalLight:__init(rayHandler, rays, color, dirDegree)
	Light.__init(self, rayHandler, rays, color, 4096, dirDegree);
	
	self.sin = 0;
	self.cos = 0;
	self.start = {};
	self.endPos = {};
	self.vertexNum = (self.vertexNum - 1) * 2;

	for i = 0, self.rayNum do
		self.start[i] = Vec2();
		self.endPos[i] = Vec2();
	end;
	
	self:setDirection(self.direction);
	
	local attributes = VertexAttributes();
		attributes:Add(VertexAttribute(VERTEX_POSITION, 0, "Position"));
		attributes:Add(VertexAttribute(VERTEX_COLOR, 2, "Color"));
		attributes:Add(VertexAttribute(VERTEX_GENERIC, 3, "Generic"));
		
	self.lightMesh = Mesh(self.staticLight, self.vertexNum, attributes);
	self.softShadowMesh = Mesh(self.staticLight, self.vertexNum, attributes);
	self:update();
end;

local TO_RADIANS = function(angle)
	return angle * (math.pi / 180);
end;

function DirectionalLight:setDirection(direction)
	self.direction = direction;
	self.sin = math.sin(TO_RADIANS(direction));
	self.cos = math.cos(TO_RADIANS(direction));
	
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function DirectionalLight:update()
	if (self.staticLight) then return; end;

	local width = display.GetW();
	local height = display.GetH();
	local sizeOfScreen = width > height and width or height;
	local xAxelOffSet = sizeOfScreen * self.cos;
	local yAxelOffSet = sizeOfScreen * self.sin;

	if ((xAxelOffSet * xAxelOffSet < 0.1) and (yAxelOffSet * yAxelOffSet < 0.1)) then
		xAxelOffSet = 1;
		yAxelOffSet = 1;
	end;

	local widthOffSet = sizeOfScreen * -self.sin;
	local heightOffSet = sizeOfScreen * self.cos;
	local x = width * 0.5 - widthOffSet;
	local y = height * 0.5 - heightOffSet;
	local portionX = 2 * widthOffSet / self.rayNum; -- / rayNum - 1
	x = (math.floor(x / (portionX * 2))) * portionX * 2;
	
	local portionY = 2 * heightOffSet / self.rayNum; -- / rayNum - 1
	y = (math.ceil(y / (portionY * 2))) * portionY * 2;
	
	for i = 0, self.rayNum do
		local steppedX = i * portionX + x;
		local steppedY = i * portionY + y;
		
		self.index = i;
		self.start[i].x = steppedX - xAxelOffSet;
		self.start[i].y = steppedY - yAxelOffSet;
		self.endPos[i].x = steppedX + xAxelOffSet;
		self.endPos[i].y = steppedY + yAxelOffSet;
		self.mx[i] = self.endPos[i].x;
		self.my[i] = self.endPos[i].y;
		self:castRay(self.start[i], self.endPos[i], self.entity);
	end;
	
	self.lightMesh:Reset();
	
	for i = 0, self.rayNum do
		local vertex = Vertex(Vec2(self.start[i].x, self.start[i].y));
			vertex:SetColor(self.color);
			vertex:SetData(0.85);
		self.lightMesh:AddVertex(vertex);
		
		local vertex = Vertex(Vec2(self.mx[i], self.my[i]));
			vertex:SetColor(self.color);
			vertex:SetData(0.7);
		self.lightMesh:AddVertex(vertex);
	end;
	
	if (not self.soft or self.xray) then
		return;
	end;
	
	self.softShadowMesh:Reset();
	
	for i = 0, self.rayNum do
		local vertex = Vertex(Vec2(self.mx[i], self.my[i]));
			vertex:SetColor(self.color);
			vertex:SetData(1);
		self.softShadowMesh:AddVertex(vertex);
		
		local vertex = Vertex(Vec2(self.mx[i] + self.softShadowLength * self.cos, self.my[i] + self.softShadowLength * self.sin));
			vertex:SetColor(Color(0, 0, 0, 0));
			vertex:SetData(0);
		self.softShadowMesh:AddVertex(vertex);
	end;
end;

function DirectionalLight:render()
	self.rayHandler.lightRenderedLastFrame = self.rayHandler.lightRenderedLastFrame + 1;
	self.lightMesh:Draw(self.rayHandler.lightShader, CL_TRIANGLE_STRIP); --GL_TRIANGLE_STRIP
	
	if (self.soft and not self.xray) then
		self.softShadowMesh:Draw(self.rayHandler.lightShader, CL_TRIANGLE_STRIP); -- CL_TRIANGLE_STRIP
	end;
end;

function DirectionalLight:attachToEntity(entity) end;

function DirectionalLight:setPosition(x, y) end;

function DirectionalLight:getBody() end;

function DirectionalLight:getX() end;

function DirectionalLight:getY() end;

function DirectionalLight:contains(x, y)
	local oddNodes = false;
	local x2 = self.mx[self.rayNum] or self.start[0].x;
	local y2 = self.my[self.rayNum] or self.start[0].y;
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
	
	for i = 0, self.rayNum do
		x1 = self.start[i].x;
		y1 = self.start[i].y;
		
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