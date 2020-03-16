AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')     

function ENT:Initialize() 	
	self.Entity:PhysicsInitSphere(4, "metal_bouncy")
	
	self.Entity:SetMoveType(MOVETYPE_NONE)
	
	local Phys = self.Entity:GetPhysicsObject()  
	
	if (Phys:IsValid()) then
		Phys:EnableMotion(false)
		Phys:Wake()  	
	end
	
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionBounds(Vector(4, 4, 4), Vector(4, 4, 4))
end

// Think function called every frame

function ENT:SetPlayer(Player)
	self.Entity:SetNetworkedEntity("Selected.Player", Player)
end