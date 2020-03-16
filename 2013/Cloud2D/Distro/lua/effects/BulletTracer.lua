--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the effect has initialized.
function EFFECT:OnInitialize(arguments)
	self.m_killTime = time.CurTime() + (math.random(2, 4) * time.GetDT());
	self.m_muzzle = util.GetImage("effects/muzzleflash");
	self.m_tracer = util.GetImage("effects/bullettracer");
end;

-- Called when the effect is dispatched.
function EFFECT:OnDispatch()
	local startPos = self:GetData("StartPos");
	local color = self:GetData("Color");
	
	if (startPos) then
		self.m_light = lighting.AddPoint(Color(color.r, color.g, color.b, 1), 256, startPos);
		self.m_light:setBrushOnly(false);
	end;
end;

-- Called when the effect is removed.
function EFFECT:OnRemove()
	self.m_light:remove();
end;

-- Called every frame for the effect.
function EFFECT:OnUpdate(deltaTime)
	return (time.CurTime() >= self.m_killTime);
end;

-- Called when the effect is drawn.
function EFFECT:OnDraw()
	local startPos = self:GetData("StartPos");
	local endPos = self:GetData("EndPos");
	local color = self:GetData("Color") or Color(1, 1, 1, 1);
	local width = self:GetData("Width", 4);
	
	if (startPos and endPos) then
		local muzzlePos = startPos - Vec2(0, self.m_muzzle:GetH() / 2);
		local tracerPos = startPos - Vec2(0, width / 2);
		local angleObject = util.AngleBetweenVectors(startPos, endPos);
		local length = startPos:Distance(endPos);
		
		draw.RotatedImage(self.m_tracer, tracerPos.x, tracerPos.y, length, width, color, angleObject, startPos);
		draw.RotatedImage(self.m_muzzle, muzzlePos.x, muzzlePos.y, nil, nil, Color(1, 1, 1, 1), angleObject, startPos);
	end;
end;