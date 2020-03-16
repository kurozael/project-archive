		#ifdef GL_ES
			#define MED mediump			precision mediump float;
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
	
