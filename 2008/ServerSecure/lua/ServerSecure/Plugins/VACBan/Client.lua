// Fake VAC Ban

SS.VACBan = {}

// Usermessage

function SS.VACBan.Usermessage()
	SS.VACBan.Panel = vgui.Create("VACBan")
	SS.VACBan.Panel:SetVisible(true)
	
	// Click
	
	gui.EnableScreenClicker(true)
	
	// Timer
	
	timer.Simple(10, function() LocalPlayer():ConCommand("quit\n") end)
end

usermessage.Hook("SS.VACBan", SS.VACBan.Usermessage)

// Panel

local PANEL = {}

// Init

function PANEL:Init()
	// Title
	
	self.Title = vgui.Create("Label", self)
	self.Title:SetText("VAC Banned")
	
	// Info
	
	self.Info = vgui.Create("Label", self)
	self.Info:SetText([[
	You have been banned by VAC for a cheating infraction!
	Please report to http://steampowered.com for
	a support ticket
	]])
end

// Paint

function PANEL:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(125, 125, 125, 255))
	
	draw.RoundedBox(4, 8, 20, self:GetWide() - 16, self:GetTall() - 28, Color(150, 150, 150, 255))
end

// Layout

function PANEL:PerformLayout()
	self:SetSize(300, 100)
	
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
	
	self.Title:SizeToContents()
	self.Title:SetPos(8, 4)
	
	self.Info:SizeToContents()
	self.Info:SetPos(16, 32)
	self.Info:SetFGColor(Color(75, 75, 75, 255))
end

vgui.Register("VACBan", PANEL, "Panel")