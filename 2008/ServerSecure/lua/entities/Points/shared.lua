// Basic stuff

ENT.Type = "anim"  
ENT.Base = "base_gmodentity"     
ENT.PrintName = "Points"  
ENT.Author	= "Conna"  
ENT.Contact	= "connacook@gmail.com"  
ENT.Purpose	= "Get some points!"  
ENT.Instructions = "Scrape them out of their box"  

ENT.Spawnable = false
ENT.AdminSpawnable = false

// Set label

function ENT:SetEntityLabel()
	local Label = SS.Config.Request("Points")..": "..self.Entity.Amount
	
	Label = Label.."\nPress (USE)"
	
	self:SetOverlayText(Label)
end