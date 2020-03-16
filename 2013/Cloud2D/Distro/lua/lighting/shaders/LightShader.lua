local SHADER_NAME = "Light";

_G["Create"..SHADER_NAME.."Shader"] = function(rayHandler)
	local vertexShader = [[
		uniform mat4 cl_ModelViewProjectionMatrix;
		
		#ifdef GL_ES
			#define MED ]]..rayHandler:getColorPrecision()..[[
			precision ]]..rayHandler:getColorPrecision()..[[ float;
			#define PRES mediump
		#else
			#define MED 
			#define PRES 
		#endif
		
		attribute MED vec4 Position;
		attribute MED vec4 Color;
		attribute float Generic;
		varying MED vec4 vColor;
		
		void main()
		{
		   vColor = Generic * Color;
		   gl_Position = cl_ModelViewProjectionMatrix * Position;
		};
	]];
	
	local gammaVal = "";
	if (rayHandler:getGammaCorrection()) then
		gammaVal = "sqrt";
	end;
	
	local fragShader = [[
		#ifdef GL_ES
			#define MED ]]..rayHandler:getColorPrecision()..[[
			precision ]]..rayHandler:getColorPrecision()..[[ float;
		#else
			#define MED 
		#endif
		
		varying MED vec4 vColor;
		
		void main()
		{
		  gl_FragColor = ]]..gammaVal..[[(vColor);
		};
	]];
	files.Write("shaders/Lighting/Vert"..SHADER_NAME..".fx", vertexShader);
	files.Write("shaders/Lighting/Frag"..SHADER_NAME..".fx", fragShader);
	
	return Shader("shaders/Lighting/Vert"..SHADER_NAME..".fx", "shaders/Lighting/Frag"..SHADER_NAME..".fx");
end;