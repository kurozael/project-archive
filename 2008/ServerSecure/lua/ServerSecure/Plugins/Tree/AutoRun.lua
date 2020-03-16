local Plugin = SS.Plugins:New("Tree")

Plugin.Trees = {}

// Tree command

local Tree = SS.Commands:New("Tree")

SS.Flags.Branch("Server", "Tree")

function Tree.Command(Player, Args)
	SS.PlayerMessage(0, Player:Name().." has planted a "..SS.Config.Request("Points").." tree!", 0)
	
	local Trace = Player:TraceLine()
	
	local Bush = ents.Create("prop_physics")
	
	Bush:SetModel("models/props/cs_militia/tree_large_militia.mdl")
	Bush:SetPos(Trace.HitPos)
	Bush:Spawn()
	
	// PropSecure should pick this up too
	
	Player:AddCleanup("props", Bush)
	
	Player:AddCount("props", Bush)
	
	// Undo
	
	undo.Create("prop")
		undo.AddEntity(Bush)
		undo.SetPlayer(Player)
	undo.Finish()
	
	// Add it to the trees list
	
	local Index = Bush:EntIndex()
	
	Plugin.Trees[Index] = {Bush, CurTime() + Args[2], Args[1], Args[2], Player}
	
	// Physics
	
	local Phys = Bush:GetPhysicsObject():EnableMotion(false)
	
	// Effect
	
	local Effect = EffectData()
	
	Effect:SetEntity(Bush)
	Effect:SetOrigin(Bush:GetPos())
	Effect:SetStart(Bush:GetPos())
	Effect:SetScale(500)
	Effect:SetMagnitude(250)
	
	util.Effect("ThumperDust", Effect)
end

Tree:Create(Tree.Command, {"server", "tree"}, "Spawn a tree that drops points", "<Amount> <Time>", 2, " ")

// Think

function Plugin.ServerSecond()
	for K, V in pairs(Plugin.Trees) do
		if (SS.Lib.Valid(V[1])) then
			if (CurTime() > V[2]) then
				local Entity = ents.Create("Points")
				
				Entity:SetPos(V[1]:GetPos() + Vector(math.random(-64, 64), math.random(-64, 64), 64))
				
				Entity:SetNetworkedInt("Points", V[3])
				
				Entity:Spawn()
				
				if (V[5]:IsConnected()) then
					Entity:SetPlayer(V[5])
					
					V[5]:AddCleanup("props", Entity)
					V[5]:AddCount("props", Entity)
				end
				
				local Effect = EffectData()
				
				Effect:SetEntity(V[1])
				Effect:SetOrigin(V[1]:GetPos())
				Effect:SetStart(V[1]:GetPos())
				Effect:SetScale(9999)
				Effect:SetMagnitude(250)
				
				util.Effect("WaterSplash", Effect)
				
				V[2] = CurTime() + V[4]
			end
		else
			Plugin.Trees[K] = nil
		end
	end
end

// Finish plugin

Plugin:Create()