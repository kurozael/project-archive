class "LightMap";

function LightMap:__init(rayHandler, fboWidth, fboHeight)
	self.frameBuffer = FrameBuffer(fboWidth, fboHeight);
	self.blurShader = CreateGaussianShader(rayHandler);
	self.shadowShader = CreateShadowShader(rayHandler);
	self.diffuseShader = CreateDiffuseShader(rayHandler);
	self.pingPongBuffer = FrameBuffer(fboWidth, fboHeight);
	self.withoutShadowShader = CreateWithoutShadowShader();
	self.lightMapMesh = self:createLightMapMesh();
	self.rayHandler = rayHandler;
end;

function LightMap:render()
	local bNeeded = self.rayHandler.lightRenderedLastFrame > 0;
	
	if (bNeeded and self.rayHandler.blur) then
		self:gaussianBlur();
	end;

	self.frameBuffer:BindTexture();

	if (self.rayHandler.shadows) then
		local color = self.rayHandler.ambientLight;
		local shader = self.shadowShader;
		
		if (self.rayHandler.isDiffuse) then
			shader = self.diffuseShader;
			shader:Bind();
			shader:SetColor("uAmbient", color);
			render.SetBlendFunc(BLEND_DST_COLOR, BLEND_SRC_COLOR);
		else
			shader:Bind();
			shader:SetColor(
				"uAmbient", Color(color.r * color.a, color.g * color.a, color.b * color.a, 1 - color.a)
			);
			render.SetBlendFunc(BLEND_ONE, BLEND_ONE_MINUS_SRC_ALPHA);
		end;
		
		shader:SetTexture("TexSample", self.frameBuffer:GetTexture(), 0);
			camera.Finish();
				self.lightMapMesh:Draw(shader, CL_TRIANGLE_FAN);
			camera.Begin();
		shader:Unbind();
	elseif (bNeeded) then
		render.SetBlendFunc(BLEND_SRC_ALPHA, BLEND_ONE);
		self.withoutShadowShader:Bind();
			self.withoutShadowShader:SetTexture("TexSample", self.frameBuffer:GetTexture(), 0);
			camera.Finish();
				self.lightMapMesh:Draw(self.withoutShadowShader, CL_TRIANGLE_FAN);
			camera.Begin();
		self.withoutShadowShader:Unbind();
	end

	render.StopBlending();
end;

function LightMap:gaussianBlur()
	render.StopBlending();
	
	for i = 0, self.rayHandler.blurNum do
		self.frameBuffer:BindTexture();
		
		self.pingPongBuffer:StartCapture();
			self.blurShader:Bind();
			self.blurShader:SetTexture("TexSample", self.frameBuffer:GetTexture(), 0);
			self.blurShader:SetVec2("uDir", Vec2(1, 0));
			camera.Finish();
				self.lightMapMesh:Draw(self.blurShader, CL_TRIANGLE_FAN);
			camera.Begin();
			self.blurShader:Unbind();
		self.pingPongBuffer:StopCapture();
		
		self.pingPongBuffer:BindTexture();
		
		self.frameBuffer:StartCapture();
			self.blurShader:Bind();
			self.blurShader:SetTexture("TexSample", self.pingPongBuffer:GetTexture(), 0);
			self.blurShader:SetVec2("uDir", Vec2(1, 0));
			camera.Finish();
				self.lightMapMesh:Draw(self.blurShader, CL_TRIANGLE_FAN);
			camera.Begin();
			self.blurShader:Unbind();
		self.frameBuffer:StopCapture();
	end;

	render.StartBlending();
end;

function LightMap:createLightMapMesh()
	local attributes = VertexAttributes();
		attributes:Add(VertexAttribute(VERTEX_POSITION, 0, "Position"));
		attributes:Add(VertexAttribute(VERTEX_TEX_COORDS, 1, "TexCoord"));
	
	local lightMapMesh = Mesh(true, 4, attributes);
		local vertex = Vertex(Vec2(0, 0));
			vertex:SetCoord(Vec2(0, 0));
		lightMapMesh:AddVertex(vertex);
		
		local vertex = Vertex(Vec2(display.GetW(), 0));
			vertex:SetCoord(Vec2(1, 0));
		lightMapMesh:AddVertex(vertex);
	
		local vertex = Vertex(Vec2(display.GetW(), display.GetH()));
			vertex:SetCoord(Vec2(1, 1));
		lightMapMesh:AddVertex(vertex);
		
		local vertex = Vertex(Vec2(0, display.GetH()));
			vertex:SetCoord(Vec2(0, 1));
		lightMapMesh:AddVertex(vertex);
	return lightMapMesh;
end;