		uniform mat4 cl_ModelViewProjectionMatrix;
		attribute vec4 Position;
		attribute vec2 TexCoord;
		uniform vec2 uDir;
		
		varying vec2 vTexCoords0;
		varying vec2 vTexCoords1;
		varying vec2 vTexCoords2;
		varying vec2 vTexCoords3;
		varying vec2 vTexCoords4;
		
		#define FBO_W 800.0
		#define FBO_H 600.0
		
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
	
