		#ifdef GL_ES
			#define MED mediump			precision mediump float;
		#else
			#define MED 
		#endif
		
		varying MED vec4 vColor;
		
		void main()
		{
		  gl_FragColor = (vColor);
		};
	
