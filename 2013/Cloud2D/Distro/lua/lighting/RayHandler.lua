class "RayHandler";

COLOR_PREC_HIGH = "highp";
COLOR_PREC_MED = "mediump";
COLOR_PREC_LOW = "lowp";
GAMMA_COR = 0.625;

function RayHandler:__init(fboWidth, fboHeight)
	self.gammaCorrectionParameter = 1;
	self.lightRenderedLastFrame = 0;
	self.gammaCorrection = false;
	self.disabledLights = {};
	self.ambientLight = Color(0, 0, 0, 1);
	self.colorPrecision = COLOR_PREC_MED;
	self.lightList = {};
	self.isDiffuse = false;
	self.combined = Matrix4();
	self.fboWidth = fboWidth;
	self.fboHeight = fboHeight;
	self.blurNum = 1;
	self.culling = true;
	self.shadows = true;
	self.blur = true;
	self.x1 = 0;
	self.x2 = 0;
	self.y1 = 0;
	self.y2 = 0;
	self.lightShader = CreateLightShader(self);
	self.lightMap = LightMap(self, fboWidth, fboHeight);
end;

function RayHandler:updateCamera()
	local cameraPos = camera.GetPos();
	self.x1 = math.floor(cameraPos.x)
	self.x2 = math.floor(cameraPos.x + camera.GetW());
	self.y1 = math.floor(cameraPos.y);
	self.y2 = math.floor(cameraPos.y + camera.GetH());
end;

function RayHandler:intersect(x, y, side)
	return (self.x1 < (x + side) and self.x2 > (x - side) and self.y1 < (y + side) and self.y2 > (y - side));
end;

function RayHandler:updateAndRender()
	self:update(); return self:render();
end;

function RayHandler:update()
	for k, v in ipairs(self.lightList) do
		v:update();
	end;
end;

function RayHandler:render()
	self.lightRenderedLastFrame = 0;
	
	render.StartBlending();
	render.SetBlendFunc(BLEND_SRC_ALPHA, BLEND_ONE);
		self:renderWithShaders();
	render.StopBlending();
end;

function RayHandler:renderWithShaders()
	if (self.shadows or self.blur) then
		self.lightMap.frameBuffer:StartCapture();
		display.Clear(Color(0, 0, 0, 1));
	end;

	self.lightShader:Bind();
		for k, v in ipairs(self.lightList) do
			v:render();
		end;
	self.lightShader:Unbind();
	
	if (self.shadows or self.blur) then
		self.lightMap.frameBuffer:StopCapture();
		self.lightMap:render();
	end;
end;

function RayHandler:pointAtLight(x, fy)
	for k, v in ipairs(self.lightList) do
		if (v:contains(x, y)) then
			return true;
		end;
	end;
	
	return false;
end;

function RayHandler:pointAtShadow(x, y)
	for k, v in ipairs(self.lightList) do
		if (v:contains(x, y)) then
			return false;
		end;
	end;
	
	return true;
end;

function RayHandler:dispose()
	for k, v in ipairs(self.lightList) do
		v:remove();
	end;
	
	self.lightList = {};
	
	for k, v in ipairs(self.disabledLights) do
		v:remove();
	end;
	
	self.disabledLights = {};
end;

function RayHandler:setCulling(bCulling)
	self.culling = bCulling;
end;

function RayHandler:setBlur(bBlur)
	self.blur = bBlur;
end;

function RayHandler:setBlurNum(blurNum)
	self.blurNum = blurNum;
end;

function RayHandler:setShadows(bShadows)
	self.shadows = bShadows;
end;

function RayHandler:setAmbientLight(r, g, b, a)
	self.ambientLight.r = r;
	self.ambientLight.g = g;
	self.ambientLight.b = b;
	self.ambientLight.a = a;
end;

function RayHandler:setActive(light, bActive)
	if (bActive) then
		for k, v in ipairs(self.disabledLights) do
			if (v == light) then
				table.remove(self.disabledLights, k);
				break;
			end;
		end;
		
		self:addLight(light);
	else
		table.insert(self.disabledLights, light);
		self:removeLight(light);
	end;
end;

function RayHandler:addLight(light)
	for k, v in ipairs(self.lightList) do
		if (v == light) then return; end;
	end;
	
	table.insert(self.lightList, light);
end;

function RayHandler:removeLight(light)
	for k, v in ipairs(self.lightList) do
		if (v == light) then
			table.remove(self.lightList, k);
			break;
		end;
	end;
	
	-- Dispose meshes?
end;

function RayHandler:setWorld(world)
	self.world = world;
end;

function RayHandler:setColorPrecisionHighp()
	self.colorPrecision = COLOR_PREC_HIGH;
end;

function RayHandler:setColorPrecisionMediump() 
	self.colorPrecision = COLOR_PREC_MED;
end;

function RayHandler:setColorPrecisionLowp()
	self.colorPrecision = COLOR_PREC_LOW;
end;

function RayHandler:getColorPrecision()
	return self.colorPrecision;
end;

function RayHandler:getGammaCorrection()
	return self.gammaCorrection;
end;

function RayHandler:setGammaCorrection(bGammeCorrectionWanted)
	self.gammaCorrection = bGammeCorrectionWanted;
	
	if (bGammeCorrectionWanted) then
		self.gammaCorrectionParameter = GAMMA_COR;
	else
		self.gammaCorrectionParameter = 1;
	end;
end;

function RayHandler:useDiffuseLight(bUseDiffuse)
	self.isDiffuse = bUseDiffuse;
end;