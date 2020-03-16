		#ifdef GL_ES
			precision mediump float;
		#endif
		
		varying vec2 vTexCoords;
		uniform sampler2D TexSample;
		
		void main()
		{
			gl_FragColor = texture2D(TexSample, vTexCoords);
		};
	
