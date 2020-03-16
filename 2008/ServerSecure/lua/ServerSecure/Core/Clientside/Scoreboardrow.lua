surface.CreateFont("coolvetica", 20, 500, true, false, "ScoreboardPlayerName")

local texGradient = surface.GetTextureID("gui/center_gradient")

local texRatings = {}

texRatings['none'] 		= surface.GetTextureID("gui/silkicons/user")
texRatings['smile'] 	= surface.GetTextureID("gui/silkicons/emoticon_smile")
texRatings['bad'] 		= surface.GetTextureID("gui/silkicons/exclamation")
texRatings['love'] 		= surface.GetTextureID("gui/silkicons/heart")
texRatings['artistic'] 	= surface.GetTextureID("gui/silkicons/palette")
texRatings['star'] 		= surface.GetTextureID("gui/silkicons/star")
texRatings['builder'] 	= surface.GetTextureID("gui/silkicons/wrench")

surface.GetTextureID("gui/silkicons/emoticon_smile")

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/

function PANEL:Paint()
	local color = team.GetColor(self.Player:Team())
	
	if self.Player:Team() == TEAM_CONNECTING then
		color = Color(200, 120, 50, 255)
	end
	
	if self.Player:Team() == TEAM_UNASSIGNED then
		color = Color(200, 120, 50, 255)
	end

	if (self.Open || self.Size != self.TargetSize) then
		draw.RoundedBox(4, 0, 16, self:GetWide(), self:GetTall() - 16, color)
		draw.RoundedBox(4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color(250, 250, 245, 255))
		
		surface.SetTexture(texGradient)
		surface.SetDrawColor(255, 255, 255, 225)
		surface.DrawTexturedRect(2, 16, self:GetWide()-4, self:GetTall() - 16 - 2) 
	end
	
	draw.RoundedBox(4, 0, 0, self:GetWide(), 24, color)
	
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 50)
	surface.DrawTexturedRect(0, 0, self:GetWide(), 24) 
	
	surface.SetTexture(self.texRating)
	surface.SetDrawColor(255, 255, 255, 225)
	surface.DrawTexturedRect(4, 4, 16, 16) 	
	
	return true
end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer(ply)
	self.Player = ply
	
	self.infoCard:SetPlayer(ply)
	
	self:UpdatePlayerData()
end

function PANEL:CheckRating(name, count)
	if (self.Player:GetNetworkedInt("Rating."..name, 0) > count) then
		count = self.Player:GetNetworkedInt("Rating."..name, 0)
		self.texRating = texRatings[name]
	end
	
	return count
end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if (!self.Player) then return end
	if (!self.Player:IsValid()) then return end

	self.lblName:SetText("[ "..team.GetName(self.Player:Team()).." ] "..self.Player:Nick())
	self.lblFrags:SetText(self.Player:Frags())
	self.lblDeaths:SetText(self.Player:Deaths())
	self.lblPing:SetText(self.Player:Ping())
	
	// Work out what icon to draw
	
	self.texRating = surface.GetTextureID("gui/silkicons/emoticon_smile")
	
	self.texRating = texRatings['none']
	
	local count = 0
	
	count = self:CheckRating('smile', count)
	count = self:CheckRating('love', count)
	count = self:CheckRating('artistic', count)
	count = self:CheckRating('star', count)
	count = self:CheckRating('builder', count)
	
	count = self:CheckRating('bad', count)
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()
	self.Size = 24
	self:OpenInfo(false)
	
	self.infoCard	= vgui.Create("ScorePlayerInfoCard", self)
	
	self.lblName 	= vgui.Create("Label", self)
	self.lblFrags 	= vgui.Create("Label", self)
	self.lblDeaths 	= vgui.Create("Label", self)
	self.lblPing 	= vgui.Create("Label", self)
	
	// If you don't do this it'll block your clicks
	
	self.lblName:SetMouseInputEnabled(false)
	self.lblFrags:SetMouseInputEnabled(false)
	self.lblDeaths:SetMouseInputEnabled(false)
	self.lblPing:SetMouseInputEnabled(false)
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont("ScoreboardPlayerName")
	self.lblFrags:SetFont("ScoreboardPlayerName")
	self.lblDeaths:SetFont("ScoreboardPlayerName")
	self.lblPing:SetFont("ScoreboardPlayerName")
	
	self.lblName:SetFGColor(color_white)
	self.lblFrags:SetFGColor(color_white)
	self.lblDeaths:SetFGColor(color_white)
	self.lblPing:SetFGColor(color_white)
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick()
	if (self.Open) then
		surface.PlaySound("ui/buttonclickrelease.wav")
	else
		surface.PlaySound("ui/buttonclick.wav")
	end

	self:OpenInfo(!self.Open)
	
	// Thanks to foszor for helping me with this
	
	if (self.infoCard) then
		local Avatar = self.Player:GetNetworkedString("Avatar")
		
		self.infoCard.HTML:OpenURL("http://conna.vs-hs.com/GMA/Check.php?GMA="..Avatar)
	end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo(bool)
	if (bool) then
		self.TargetSize = 175
	else
		self.TargetSize = 24
	end
	
	self.Open = bool
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
	if (self.Size != self.TargetSize) then
		self.Size = math.Approach(self.Size, self.TargetSize, (math.abs(self.Size - self.TargetSize) + 1) * 10 * FrameTime())
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end
	
	if (!self.PlayerUpdate || self.PlayerUpdate < CurTime()) then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(self:GetWide(), self.Size)
	
	self.lblName:SizeToContents()
	self.lblName:SetPos(24, 2)
	
	local COLUMN_SIZE = 50
	
	self.lblPing:SetPos(self:GetWide() - COLUMN_SIZE * 1, 0)
	self.lblDeaths:SetPos(self:GetWide() - COLUMN_SIZE * 2, 0)
	self.lblFrags:SetPos(self:GetWide() - COLUMN_SIZE * 3, 0)
	
	if (self.Open || self.Size != self.TargetSize) then
		self.infoCard:SetVisible(true)
		self.infoCard:SetPos(4, self.lblName:GetTall() + 10)
		self.infoCard:SetSize(self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10)
	else
		self.infoCard:SetVisible(false)
	end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower(row)
	local Player = self.Player:Team()
	local Row    = row.Player:Team()
	
	return (SS.Groups.Rank(Player) < SS.Groups.Rank(Row))
end

vgui.Register("ScorePlayerRow", PANEL, "Button")