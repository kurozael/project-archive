local GlowMaterial = CreateMaterial( "plasmapistol/glow_mat", "UnlitGeneric", {
	[ "$basetexture" ]    = "effects/EXNiceBigFlare",
	[ "$additive" ]        = "1",
	[ "$vertexcolor" ]    = "1",
	[ "$vertexalpha" ]    = "1",
} );

function EFFECT:Init( data )

	self.Weapon = data:GetEntity();
	
	self.Entity:SetRenderBounds( Vector( -16, -16, -16 ), Vector( 16, 16, 16 ) );
	self.Entity:SetParent( self.Weapon );
	
	self.LifeTime = math.Rand( 0.15, 0.15 );
	self.DieTime = CurTime() + self.LifeTime;
	self.Size = math.Rand( 32, 48 );
	
	local pos, ang = Clockwork.entity:GetMuzzlePos( self.Weapon );
	
	// emit a burst of light
	local light = DynamicLight( self.Weapon:EntIndex() );
		light.Pos            = pos;
		light.Size            = 200;
		light.Decay            = 400;
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

	return IsValid( self.Weapon ) && self.DieTime >= CurTime();
	
end


/*------------------------------------
	Render()
------------------------------------*/
function EFFECT:Render()

	// how'd this happen?
	if( !IsValid( self.Weapon ) ) then
		return;
	end

	local pos, ang = Clockwork.entity:GetMuzzlePos( self.Weapon );
	
	local percent = math.Clamp( ( self.DieTime - CurTime() ) / self.LifeTime, 0, 1 );
	local alpha = 255 * percent;
	
	render.SetMaterial( GlowMaterial );
	
	// draw it twice to double the brightness D:
	for i = 1, 2 do
		render.DrawSprite( pos, self.Size, self.Size, Color( 255, 255, 255, alpha ) );
		render.StartBeam( 2 );
			render.AddBeam( pos - ang:Forward() * 48, 16, 0, Color( 255, 255, 255, alpha ) );
			//render.AddBeam( pos + ang:Forward() * 64, 16, 1, Color( 255, 255, 255, 0 ) );
		render.EndBeam();
	end

end