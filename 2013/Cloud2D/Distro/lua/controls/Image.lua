--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetClickable(false);
	self:SetMaterial("missing");
	self:SetSize(32, 32);
end;

-- Called when the control should be drawn.
function CONTROL:OnDraw()
	render.DrawImage(
		self.m_image,
		self:GetX(),
		self:GetY(),
		self:GetW(),
		self:GetH(),
		self:GetColor()
	);
end;

-- A function to set the control's material.
function CONTROL:SetMaterial(material, bSetSize)
	self.m_image = util.GetImage(material);
	self.m_sMaterial = material;
	
	if (bSetSize) then
		self:SetSize(self.m_image:GetW(), self.m_image:GetH());
	end;
end;

-- A function to get the control's material.
function CONTROL:GetMaterial()
	return self.m_sMaterial;
end;