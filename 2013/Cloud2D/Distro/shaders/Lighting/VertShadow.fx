		uniform mat4 cl_ModelViewProjectionMatrix;
		attribute vec4 Position;
		attribute vec2 TexCoord;
		varying vec2 vTexCoords;

		void main()
		{
		   vTexCoords = TexCoord;
		   gl_Position = cl_ModelViewProjectionMatrix * Position;
		};
	
