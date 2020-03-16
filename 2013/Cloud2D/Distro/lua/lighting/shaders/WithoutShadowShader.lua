local SHADER_NAME = "WithoutShadow";

_G["Create"..SHADER_NAME.."Shader"] = function()
	local vertexShader = [[
		uniform mat4 cl_ModelViewProjectionMatrix;
		attribute vec4 Position;
		attribute vec2 TexCoord;
		varying vec2 vTexCoords;

		void main()
		{
		   vTexCoords = TexCoord;
		   gl_Position = cl_ModelViewProjectionMatrix * Position;
		};
	]];
	
	local fragShader = [[
		#ifdef GL_ES
			precision mediump float;
		#endif
		
		varying vec2 vTexCoords;
		uniform sampler2D TexSample;
		
		void main()
		{
			gl_FragColor = texture2D(TexSample, vTexCoords);
		};
	]];
	
	files.Write("shaders/Lighting/Vert"..SHADER_NAME..".fx", vertexShader);
	files.Write("shaders/Lighting/Frag"..SHADER_NAME..".fx", fragShader);
	
	return Shader("shaders/Lighting/Vert"..SHADER_NAME..".fx", "shaders/Lighting/Frag"..SHADER_NAME..".fx");
end;