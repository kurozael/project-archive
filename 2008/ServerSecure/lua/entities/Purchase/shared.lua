// Basic stuff

ENT.Type = "anim"  
ENT.Base = "base_gmodentity"     
ENT.PrintName = "Purchase"  
ENT.Author	= "Conna"  
ENT.Contact	= "connacook@gmail.com"  
ENT.Purpose	= "Get a new purchase!"  
ENT.Instructions = "Rip it out of it's packaging"  

ENT.Spawnable = false
ENT.AdminSpawnable = false

// Set label

function ENT:SetEntityLabel()
	local Label = "Purchase: "..self.Entity.Purchase[2]
	
	Label = Label.."\nPress (USE)"
	
	self:SetOverlayText(Label)
end