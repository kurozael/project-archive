local SparkMaterial = CreateMaterial( "arcadiumsoft/tracer", "UnlitGeneric", {
	[ "$basetexture" ]    = "effects/FXTracerAlienHeroic",
	[ "$additive" ]        = "1",
	[ "$vertexcolor" ]    = "1",
	[ "$vertexalpha" ]    = "1",
} );

/*---------------------------------------------------------
   Init(data table)
---------------------------------------------------------*/
function EFFECT:Init(data)
	local startPos = data:GetStart();
	local endPos = data:GetOrigin();
	local distance = ( startPos - endPos ):Length();
	
	self.StartPos = startPos;
	self.EndPos = endPos;
	self.Normal = ( endPos - startPos ):GetNormal();
	self.Length = math.random( 128, 500 );
	self.StartTime = CurTime();
	self.DieTime = CurTime() + ( distance + self.Length ) / 15000;
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think()
	
	return self.DieTime >= CurTime();
	
end

function EFFECT:Render()

	local time = CurTime() - self.StartTime;

	local endDistance = 15000 * time;
	local startDistance = endDistance - self.Length;
	
	// clamp the start distance so we don't extend behind the weapon
	startDistance = math.max( 0, startDistance );
	
	local startPos = self.StartPos + self.Normal * startDistance;
	local endPos = self.StartPos + self.Normal * endDistance;
	
	// draw the beam
	render.SetMaterial( SparkMaterial );
	render.DrawBeam( startPos, endPos, 8, 0, 1, Color( 255, 255, 255, 255 ) );

end