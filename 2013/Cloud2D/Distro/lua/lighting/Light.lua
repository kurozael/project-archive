class "Light";

DEFAULT_LIGHT_COLOR = Color(0.75, 0.75, 0.5, 0.75);
CUR_LIGHT_ID = 0;
MIN_RAYS = 3;

function Light:__init(rayHandler, rays, color, distance, dirDegree)
	CUR_LIGHT_ID = CUR_LIGHT_ID + 1;
	distance = distance * rayHandler.gammaCorrectionParameter;
	
	self.softShadowLength = 32;
	self.rayHandler = rayHandler;
	self.staticLight = false;
	self.lightID = CUR_LIGHT_ID;
	self.direction = dirDegree;
	self.distance = distance;
	self.active = true;
	self.culled = false;
	self.soft = true;
	self.xray = false;
	self.index = 0;
	
	rayHandler:addLight(self);
	self:setRayNum(rays);
	self.color = color;
end;

function Light:__eq(other)
	return (other.lightID and other.lightID == self.lightID);
end;

function Light:getID() return self.lightID; end;

function Light:setColor(newColor, bNoUpdate)
	if (not newColor) then
		newColor = DEFAULT_LIGHT_COLOR;
	end;
	
	if (self.color.r == newColor.r
	and self.color.g == newColor.g
	and self.color.b == newColor.b
	and self.color.a == newColor.a) then
		return;
	end;
	
	self.color = newColor;
	
	if (self.staticLight and not bNoUpdate) then
		self:staticUpdate();
	end;
end;

function Light:setDistance() end;

function Light:update() end;

function Light:render() end;

function Light:setDirection(dirDegree) end;

function Light:remove()
	self.rayHandler:removeLight(self);
end;

function Light:attachToEntity(entity, offsetX, offsetY) end;

function Light:getBody() end;

function Light:setPosition(position) end;

function Light:getPosition() return Vec2(0, 0); end;

function Light:getX() end;

function Light:getY() end;

function Light:staticUpdate()
	local bTemp = self.rayHandler.culling;
	
	self.staticLight = not self.staticLight;
		self.rayHandler.culling = false;
			self:update();
		self.rayHandler.culling = bTemp;
	self.staticLight = not self.staticLight;
end;

function Light:isActive() return self.active; end;

function Light:setActive(bActive)
	if (self.active == bActive) then return; end;
	
	if (bActive) then
		self.rayHandler:setActive(self, true);
	else
		self.rayHandler:setActive(self, false);
	end;
	
	self.active = bActive;
end;

function Light:isXray() return self.xray; end;

function Light:setXray(bXray)
	self.xray = bXray;
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function Light:isStaticLight()
	return self.staticLight;
end;

function Light:setStaticLight(bIsStatic)
	self.staticLight = bIsStatic;
	if (bIsStatic) then
		self:staticUpdate();
	end;
end;

function Light:isSoft()
	return self.soft;
end;

function Light:setSoft(bSoft)
	self.soft = bSoft;
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function Light:getSoftShadowLength()
	return self.softShadowLength;
end;

function Light:setSoftnessLength(softShadowLength)
	self.softShadowLength = softShadowLength;
	
	if (self.staticLight) then
		self:staticUpdate();
	end;
end;

function Light:setRayNum(rays)
	if (rays < MIN_RAYS) then
		rays = MIN_RAYS;
	end;

	self.vertexNum = rays + 1;
	self.rayNum = rays;
	self.segments = {};
	self.mx = {};
	self.my = {};
	self.f = {};
end;

function Light:getColor()
	return self.color;
end;

function Light:getDistance()
	return distance / self.rayHandler.gammaCorrectionParameter;
end;

function Light:contains(x, y) return false; end;

function Light:setBrushOnly(bBrushOnly)
	self.brushOnly = bBrushOnly;
end;

function Light:castRay(start, finish, filter)
	local rayData = util.RayCast(start, finish, filter, function(entity)
		if (self.brushOnly and entity:GetDrawLayer() ~= LAYER_BRUSH) then
			return false;
		end;
		
		return entity:IsShadowCaster();
	end);
	
	self.f[self.index] = (1 / start:Distance(finish)) * start:Distance(rayData.hitPos);
	self.mx[self.index] = rayData.hitPos.x;
	self.my[self.index] = rayData.hitPos.y;
	
	return rayData;
end;