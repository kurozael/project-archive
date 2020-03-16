local SHADER_NAME = "Shadow";

_G["Create"..SHADER_NAME.."Shader"] = function(rayHandler)
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
			#define MED ]]..rayHandler:getColorPrecision()..[[
			precision ]]..rayHandler:getColorPrecision()..[[ float;
		#else
			#define MED 
		#endif
		
		varying vec2 vTexCoords;
		uniform MED sampler2D TexSample;
		uniform MED vec4 uAmbient;
		
		void main()
		{
			vec4 vC = texture2D(TexSample, vTexCoords);
			vC.rgb = uAmbient.rgb + vC.rgb* vC.a;
			vC.a = uAmbient.a - vC.a;
			gl_FragColor = vC;
		};
	]];
	
	files.Write("shaders/Lighting/Vert"..SHADER_NAME..".fx", vertexShader);
	files.Write("shaders/Lighting/Frag"..SHADER_NAME..".fx", fragShader);
	
	return Shader("shaders/Lighting/Vert"..SHADER_NAME..".fx", "shaders/Lighting/Frag"..SHADER_NAME..".fx");
end;