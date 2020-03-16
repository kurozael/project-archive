		#ifdef GL_ES
			#define MED mediump			precision mediump float;
		#else
			#define MED 
		#endif
		
		uniform MED sampler2D TexSample;
		varying vec2 vTexCoords0;
		varying vec2 vTexCoords1;
		varying vec2 vTexCoords2;
		varying vec2 vTexCoords3;
		varying vec2 vTexCoords4;
		
		const float center= 0.2270270270;
		const float close = 0.3162162162;
		const float far = 0.0702702703;
		
		void main()
		{	 
			gl_FragColor = far * texture2D(TexSample, vTexCoords0)
				+ close * texture2D(TexSample, vTexCoords1)
				+ center * texture2D(TexSample, vTexCoords2)
				+ close  * texture2D(TexSample, vTexCoords3)
				+ far    * texture2D(TexSample, vTexCoords4);
		};
	
