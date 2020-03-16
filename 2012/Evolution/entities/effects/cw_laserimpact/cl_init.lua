local GlowMaterial_quad = CreateMaterial( "plasmapistol/glow", "UnlitGeneric", {
	[ "$basetexture" ]    = "effects/FXBlueFlare",
	[ "$additive" ]        = "1",
	[ "$vertexcolor" ]    = "1",
	[ "$vertexalpha" ]    = "1",
} );

function EFFECT:Init( data )
	
	local pos = data:GetOrigin();
	local normal = data:GetNormal();
	
	self.Position = pos;
	self.Normal = normal;
	
	self.LifeTime = math.Rand( 0.25, 0.35 );    // 0.25, 0.35
	self.DieTime = CurTime() + self.LifeTime;
	self.Size = math.Rand( 32, 48 );
	
	// impact particles
	local emitter = ParticleEmitter( pos );
	for i = 1, 32 do
	
		local particle = emitter:Add( "effects/FXBlueFlare", pos + normal * 2 ); // HIT SPARKS
		particle:SetVelocity( ( normal + VectorRand() * 0.75 ):GetNormal() * math.Rand( 75, 125 ) );
		particle:SetDieTime( math.Rand( 0.5, 1.25 ) );
		particle:SetStartAlpha( 255 );
		particle:SetEndAlpha( 0 );
		particle:SetStartSize( math.Rand( 1, 2 ) );
		particle:SetEndSize( 0 );
		particle:SetRoll( 0 );
		particle:SetColor( 255, 255, 255 );
		particle:SetGravity( Vector( 0, 0, -250 ) );
		particle:SetCollide( true );
		particle:SetBounce( 0.3 );
		particle:SetAirResistance( 5 );

	end
	emitter:Finish();

	// emit a burst of light
	local light = DynamicLight( 0 );
		light.Pos            = pos;
		light.Size            = 64;
		light.Decay            = 256;
		light.R                = 77;
		light.G                = 77;
		light.B                = 255;
		light.Brightness    = 2;
		light.DieTime        = CurTime() + 0.35;
		
end


/*------------------------------------
	Think()
------------------------------------*/
function EFFECT:Think()

	return self.DieTime >= CurTime();
	
end


/*------------------------------------
	Render()
------------------------------------*/
function EFFECT:Render()

	local pos, normal = self.Position, self.Normal;
	
	local percent = math.Clamp( ( self.DieTime - CurTime() ) / self.LifeTime, 0, 1 );
	local alpha = 255 * percent;
	
	// draw the muzzle flash as a series of sprites
	render.SetMaterial( GlowMaterial_quad );
	render.DrawQuadEasy( pos + normal, normal, self.Size, self.Size, Color( 255, 255, 255, alpha ) );

end