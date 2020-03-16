class "ConeLight" (PositionalLight);

function ConeLight:__init(rayHandler, rays, color, distance, x, y, dirDegree, coneDegree)
	PositionalLight.__init(self, rayHandler, rays, color, distance, x, y, dirDegree);
	self:setConeDegree(coneDegree);
	self:setDirection(self.direction);
	self:update();
end;

local TO_RADIANS = function(angle)
	return angle * (math.pi / 180);
end;

function ConeLight:setDirection(direction)
	self.direction = direction;
	
	for i = 0, self.rayNum do
		local angle = direction + self.coneDegree - 2 * self.coneDegree * i / self.rayNum; -- no minus 1
		self.sin[i] = math.sin(TO_RADIANS(angle));
		self.cos[i] = math.cos(TO_RADIANS(angle));
		local s = self.sin[i];
		local c = self.cos[i];
		self.endX[i] = self.distance * c;
		self.endY[i] = self.distance * s;
	end;
	
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function ConeLight:getConeDegree()
	return self.coneDegree;
end;

function ConeLight:setConeDegree(coneDegree)
	if (coneDegree < 0) then coneDegree = 0; end;
	if (coneDegree > 180) then coneDegree = 180; end;
	self.coneDegree = coneDegree;
	self:setDirection(self.direction);
end;

function ConeLight:setDistance(distance)
	distance = distance * self.rayHandler.gammaCorrectionParameter;
	self.distance = distance;
	self:setDirection(self.direction);
end;