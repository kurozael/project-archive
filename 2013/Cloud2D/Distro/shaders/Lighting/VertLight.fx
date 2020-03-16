		uniform mat4 cl_ModelViewProjectionMatrix;
		
		#ifdef GL_ES
			#define MED mediump			precision mediump float;
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
	
