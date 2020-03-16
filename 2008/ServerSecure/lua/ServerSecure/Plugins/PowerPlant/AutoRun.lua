local Plugin = SS.Plugins:New("PowerPlant")

// Tables

Plugin.PowerPlants = {}

// Variables

Plugin.Sound = Sound("weapons/c4/c4_beep1.wav")
Plugin.Timer = 25 // Time before it explodes

// PowerPlant command

local PowerPlant = SS.Commands:New("PowerPlant")

// Branch flag

SS.Flags.Branch("Server", "PowerPlant")

function PowerPlant.Command(Player, Args)
	SS.PlayerMessage(0, Player:Name().." has created a Power Plant!", 0)
	
	local Trace = Player:TraceLine()
	
	local Plant = ents.Create("prop_physics")
	
	Plant:SetModel("models/props_wasteland/cargo_container01b.mdl")
	Plant:SetPos(Trace.HitPos + Vector(0, 0, 128))
	Plant:SetAngles(Angle(0, 90, 270))
	Plant:SetMaterial("models/debug/debugwhite")
	Plant:SetColor(255, 60, 60, 255)
	Plant:Spawn()
	
	// PropSecure should pick this up too
	
	Player:AddCleanup("props", Plant)
	
	Player:AddCount("props", Plant)
	
	// Undo
	
	undo.Create("prop")
		undo.AddEntity(Plant)
		undo.SetPlayer(Player)
	undo.Finish()
	
	// Add it to the trees list
	
	local Index = Plant:EntIndex()
	
	Plugin.PowerPlants[Index] = {Plant, 0}
	
	// Physics
	
	local Phys = Plant:GetPhysicsObject():EnableMotion(false)
	
	// Effect
	
	local Effect = EffectData()
	
	Effect:SetEntity(Plant)
	Effect:SetOrigin(Plant:GetPos())
	Effect:SetStart(Plant:GetPos())
	Effect:SetScale(500)
	Effect:SetMagnitude(250)
	
	util.Effect("ThumperDust", Effect)
end

PowerPlant:Create(PowerPlant.Command, {"server", "powerplant"}, "Spawn a Power Plant")

// Think

function Plugin.ServerSecond()
	for K, V in pairs(Plugin.PowerPlants) do
		if (SS.Lib.Valid(V[1])) then
			local Found = false
			local Entities = ents.FindInSphere(V[1]:GetPos(), V[1]:BoundingRadius())
			
			// Loop
			
			for B, J in pairs(Entities) do
				local Model = J:GetModel()
				
				if (Model == "models/props_borealis/bluebarrel001.mdl") then
					SS.Lib.EntityExplode(J)
					
					V[2] = 0
					
					Found = true
				end
			end
			
			// Reduce
			
			if not (Found) then
				V[2] = V[2] + 1
				
				if (V[2] >= Plugin.Timer) then
					// Sound
					
					V[1]:EmitSound(Plugin.Sound)
					
					// Function
					
					local function Function(Entity)
						// Beep
						
						Entity:EmitSound(Plugin.Sound)
						Entity:EmitSound(Plugin.Sound)
						Entity:EmitSound(Plugin.Sound)
						
						// Spawn nuke
						
						local Nuke = ents.Create("sent_nuke")
						
						Nuke:SetPos(Entity:GetPos())
						Nuke:Spawn()
						Nuke:Activate()
						
						// Remove
						
						Entity:Remove()
					end
					
					timer.Simple(0.5, Function, V[1])
				end
			end
		else
			Plugin.PowerPlants[K] = nil
		end
	end
end

// Finish plugin

Plugin:Create()