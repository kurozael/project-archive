class "PointLight" (PositionalLight);

function PointLight:__init(rayHandler, rays, color, distance, x, y)
	PositionalLight.__init(self, rayHandler, rays, color, distance, x, y, 0);
	self:setEndPoints();
	self:update();
end;

local TO_DEGREES = function(angle)
	return angle * (180 / math.pi);
end;

local TO_RADIANS = function(angle)
	return angle * (math.pi / 180);
end;

function PointLight:setEndPoints()
	local angleNum = 360 / self.rayNum;
	
	for i = 0, self.rayNum do
		local angle = angleNum * i;
		self.sin[i] = math.sin(TO_RADIANS(angle));
		self.cos[i] = math.cos(TO_RADIANS(angle));
		self.endX[i] = self.distance * self.cos[i];
		self.endY[i] = self.distance * self.sin[i];
	end;
end;

function PointLight:setDirection(dirDegree) end;

function PointLight:setDistance(distance)
	distance = distance * self.rayHandler.gammaCorrectionParameter;
	distance = distance < 0.01 and 0.01 or distance;
	
	if (self.distance == distance) then
		return;
	end;
	
	self.distance = distance;
	self:setEndPoints();
	
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;