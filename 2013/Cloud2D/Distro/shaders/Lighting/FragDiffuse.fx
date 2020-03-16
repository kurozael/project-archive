		#ifdef GL_ES
			precision mediump float;
		#endif
		
		uniform sampler2D TexSample;
		uniform vec4 uAmbient;
		varying vec2 vTexCoords;
		
		void main()
		{
			gl_FragColor = uAmbient + texture2D(TexSample, vTexCoords);
		};
	
