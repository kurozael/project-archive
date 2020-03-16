local SHADER_NAME = "Gaussian";

_G["Create"..SHADER_NAME.."Shader"] = function(rayHandler)
	local vertexShader = [[
		uniform mat4 cl_ModelViewProjectionMatrix;
		attribute vec4 Position;
		attribute vec2 TexCoord;
		uniform vec2 uDir;
		
		varying vec2 vTexCoords0;
		varying vec2 vTexCoords1;
		varying vec2 vTexCoords2;
		varying vec2 vTexCoords3;
		varying vec2 vTexCoords4;
		
		#define FBO_W ]]..math.ceil(rayHandler.fboWidth)..[[.0
		#define FBO_H ]]..math.ceil(rayHandler.fboHeight)..[[.0
		
		const vec2 futher = vec2(3.2307692308 / FBO_W, 3.2307692308 / FBO_H);
		const vec2 closer = vec2(1.3846153846 / FBO_W, 1.3846153846 / FBO_H);
		
		void main()
		{
			vec2 f = futher * uDir;
			vec2 c = closer * uDir;
			vTexCoords0 = TexCoord - f;
			vTexCoords1 = TexCoord - c;
			vTexCoords2 = TexCoord;
			vTexCoords3 = TexCoord + c;
			vTexCoords4 = TexCoord + f;
			gl_Position = cl_ModelViewProjectionMatrix * Position;
		};
	]];
	
	local fragShader = [[
		#ifdef GL_ES
			#define MED ]]..rayHandler:getColorPrecision()..[[
			precision ]]..rayHandler:getColorPrecision()..[[ float;
		#else
			#define MED 
		#endif
		
		uniform MED sampler2D TexSample;
		varying vec2 vTexCoords0;
		varying vec2 vTexCoords1;
		varying vec2 vTexCoords2;
		varying vec2 vTexCoords3;
		varying vec2 vTexCoords4;
		
		const float center= 0.2270270270;
		const float close = 0.3162162162;
		const float far = 0.0702702703;
		
		void main()
		{	 
			gl_FragColor = far * texture2D(TexSample, vTexCoords0)
				+ close * texture2D(TexSample, vTexCoords1)
				+ center * texture2D(TexSample, vTexCoords2)
				+ close  * texture2D(TexSample, vTexCoords3)
				+ far    * texture2D(TexSample, vTexCoords4);
		};
	]];
	
	files.Write("shaders/Lighting/Vert"..SHADER_NAME..".fx", vertexShader);
	files.Write("shaders/Lighting/Frag"..SHADER_NAME..".fx", fragShader);
	
	return Shader("shaders/Lighting/Vert"..SHADER_NAME..".fx", "shaders/Lighting/Frag"..SHADER_NAME..".fx");
end;