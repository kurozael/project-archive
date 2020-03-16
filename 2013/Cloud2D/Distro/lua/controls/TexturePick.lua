--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the size of the control is based on it's contents.
function CONTROL:OnSizeToContents()
	return 40 + math.max(self.m_label:GetW(), self.m_texLabel:GetW()), 36;
end;

-- A function to populate the picker control's items.
function CONTROL:PopulateItems(searchPath, files)
	self.m_textureList:Clear();
	
	for k, v in ipairs(files) do
		if (util.IsImage(v)) then
			local imageButton = controls.Create("ImageButton");
				imageButton:SetCallback(function()
					self:SetMaterial(imageButton:GetMaterial());
					self:ClosePicker();
				end);
				imageButton:SetBorderColor(Color(1, 1, 1, 1));
				imageButton:SetMaterial(searchPath..v);
				imageButton:SetToolTip(searchPath..v);
				imageButton:SetSize(32, 32);
			self.m_textureList:AddItem(imageButton);
		end;
	end;
	
	self.m_folderNav:SetHeight(
		math.min(self.m_folderNav:GetCanvas():GetH(), 125)
	);
	
	self.m_textureList:SetPos(8,
		self.m_folderNav:GetY(true) + self.m_folderNav:GetH() + 8
	);
	
	self.m_panel:SetHeight(
		self.m_textureList:GetY(true) + self.m_textureList:GetH() + 8
	);
end;

-- A function to close the texture picker controls.
function CONTROL:ClosePicker()
	if (self.m_panel) then
		self.m_panel:Remove();
		
		self.m_textureList = nil;
		self.m_folderNav = nil;
		self.m_panel = nil;
	end;
end;

-- A function to load the texture picker controls.
function CONTROL:LoadPicker()
	self.m_panel = controls.Create("Panel");
	self.m_panel:SetPos(self:GetX() + self:GetW() + 8, self:GetY());
	self.m_panel:SetWidth(200);
	
	self.m_folderNav = controls.Create("FolderNav", self.m_panel);
	self.m_folderNav:SetCallback(function(searchPath, files)
		self:PopulateItems(searchPath, files);
	end);
	self.m_folderNav:SetFolder("materials/textures");
	self.m_folderNav:SetSize(self.m_panel:GetW() - 16, 125);
	self.m_folderNav:SetPos(8, 8);
	
	self.m_textureList = controls.Create("ItemList", self.m_panel);
	self.m_textureList:SetPos(8,
		self.m_folderNav:GetY(true) + self.m_folderNav:GetH() + 8
	);
	self.m_textureList:SetSize(self.m_panel:GetW() - 16, 125);
	self.m_textureList:SetPadding(4);
	self.m_textureList:SetSpacing(4);
	self.m_textureList:SetHorizontal(true);
	
	self.m_panel:SetHeight(
		self.m_textureList:GetY(true) + self.m_textureList:GetH() + 8
	);
	
	self.m_folderNav:Populate();
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:SetDraggable(false);
	self:SetColor(Color(1, 1, 1, 0.1));
	self.m_texture = "missing.png";
	
	self.m_imageButton = controls.Create("ImageButton", self);
		self.m_imageButton:SetCallback(function()
			self:LoadPicker();
		end);
		self.m_imageButton:SetBorderColor(Color(1, 1, 1, 1));
		self.m_imageButton:SetMaterial("missing");
		self.m_imageButton:SetToolTip("missing");
		self.m_imageButton:SetSize(32, 32);
	self.m_imageButton:SetPos(2, 2);
	
	self.m_label = controls.Create("Label", self);
	self.m_label:SetVertAlign(5);
	self.m_label:SetFont("VerdanaTiny");
	self.m_label:SetText("Texture Picker");
	self.m_label:SetPos(38, 8);
	
	self.m_texLabel = controls.Create("Label", self);
	self.m_texLabel:SetVertAlign(5);
	self.m_texLabel:SetFont("VerdanaTiny");
	self.m_texLabel:SetColor(Color(1, 1, 1, 0.8));
	self.m_texLabel:SetText("Select a texture...");
	self.m_texLabel:SetPos(38, 24);
	
	self:SetHeight(36);
end;

-- Called every frame for the control.
function CONTROL:OnUpdate(deltaTime)
	if (self.m_panel) then
		self.m_panel:SetPos(self:GetX() + self:GetW() + 8, self:GetY());
	end;
end;

-- Called when the control is removed.
function CONTROL:OnRemove()
	self:ClosePicker();
end;

-- A function to set the control label.
function CONTROL:SetLabel(label)
	self.m_label:SetText(label);
end;

-- A function to set the control's material.
function CONTROL:SetMaterial(material)
	self.m_imageButton:SetMaterial(material);
	self.m_imageButton:SetToolTip(material);
	self.m_texture = material;
	
	if (self.m_callback) then
		self.m_callback(self.m_texture);
	end;
end;

-- Called when the control is drawn.
function CONTROL:OnDraw()
	render.DrawFill(self:GetX(), self:GetY(), self:GetW(), self:GetH(), self:GetColor());
end;

util.AddAccessor(CONTROL, "Draggable", "m_bDraggable");
util.AddAccessor(CONTROL, "Callback", "m_callback");