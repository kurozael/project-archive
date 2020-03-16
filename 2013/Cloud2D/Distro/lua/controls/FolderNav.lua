--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

CONTROL.m_sBaseClass = "ItemList";

-- A function to populate the control.
function CONTROL:Populate()
	if (#self:GetItems() > 0) then self:Clear(); end;
	
	local searchPath = self.m_sFolder..self.m_directory;
	local fileList = util.GrabFilesInDir(searchPath, nil, function(fileName)
		return (fileName ~= "." and fileName ~= "..");
	end);
	
	if (self.m_directory ~= "/") then
		local backButton = controls.Create("Button");
			backButton:SetText("../");
			backButton:SetFont("VerdanaTiny");
			backButton:SetHeight(20);
			backButton:SetColor(Color(0.2, 0.7, 0.2, 1));
			backButton:SetCallback(function()
				self.m_directory = self.m_history.directory;
				self.m_history = self.m_history.previous;
				self:Populate();
			end);
		self:AddItem(backButton);
	end;
	
	for k, v in ipairs(fileList) do
		if (util.IsDirectory(v)) then
			local folderButton = controls.Create("Button");
				folderButton:SetText(v);
				folderButton:SetFont("VerdanaTiny");
				folderButton:SetHeight(20);
				folderButton:SetCallback(function()
					self.m_history = {
						directory = self.m_directory,
						previous = self.m_history
					}
					self.m_directory = self.m_directory..v.."/";
					self:Populate();
				end);
			self:AddItem(folderButton);
			
			local folderImage = controls.Create("Image", folderButton);
			folderImage:SetMaterial("silkicons/folder");
			folderImage:SetSize(16, 16);
			folderImage:SetPos(1, 1);
		end;
	end;
	
	local callback = self:GetCallback();
	
	if (callback) then
		callback(searchPath, fileList);
	end;
end;

-- A function to set the folder of the control.
function CONTROL:SetFolder(folder)
	self.m_directory = "/";
	self.m_history = {
		directory = self.m_directory,
		previous = nil
	};
	self.m_sFolder = folder;
end;

-- Called when the control has initialized.
function CONTROL:OnInitialize(arguments)
	self:BaseClass().OnInitialize(self, arguments);
	self:SetPadding(4); self:SetSpacing(4);
	
	self.m_canvasPanel.OnGetClipBoundries = function(panel)
		return {x = self:GetX(), y = self:GetY() + 4, w = self:GetW(), h = self:GetH() - 8};
	end;
end;

util.AddAccessor(CONTROL, "Callback", "m_callback");