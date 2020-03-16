------------------------------------------------
----[ TRANSLATE ]-----------------------
------------------------------------------------

local Plugin = SS.Plugins:New("Translate")

// Create command

local Translate = SS.Commands:New("Translate")

// Branch flag

SS.Flags.Branch("Moderator", "Translate")

// Space for other plugins

function Plugin.ServerLoad()
	if (PurchaseFlags) then
		PurchaseFlags.Add("Translate", "Flags [Translate]", 5, "Translate", "Like a stacker but you control it with arrow keys")
	end
end

// Command

function Translate.Command(Player, Args)
	if not (Player:EntitiesSelected()) then
		SS.PlayerMessage(Player, "Select some entities first using "..SS.Commands.Prefix().."select!", 1)
		
		return
	end
	
	Player.Translate = Player.Translate or {}

	if (Player.Translate.Active) then
		Player.Translate.Active = false
		
		SS.PlayerMessage(Player, "You have exited translate mode!", 0)
	else
		Player.Translate.Active = true
		Player.Translate.Freeze = Args[1]
		
		SS.PlayerMessage(Player, "You have entered translate mode!", 0)
	end
end

// Key pressed

function Translate.KeyPress(Player, Key)
	local Cur = CurTime()
	
	if (Player.Translate and Player.Translate.Active) then
		if (Key == IN_FORWARD or Key == IN_BACK or Key == IN_MOVELEFT or Key == IN_MOVERIGHT
			or Key == IN_JUMP or Key == IN_DUCK) then
			
			if (Player.Translate.Next) then
				if (Player.Translate.Next > Cur) then
					local Time = Player.Translate.Next - Cur
					
					Time = string.ToMinutesSeconds(Time)
					
					if (Time != "00:00") then
						SS.PlayerMessage(Player, "You must wait "..Time.." before you can use Translate again!", 1)
						
						return
					end
				end
			end
			
			local Selected = Player:EntitiesSelected()
			
			if not (Selected) then
				Player.Translate.Active = false
				
				return
			end
			
			Selected = table.Copy(Selected)
			
			// Deselect current entities
			
			Player:DeselectEntities()
			
			// Do the main shit
			
			undo.Create("Translate")
			
			for K, V in pairs(Selected) do
				local Class      = V:GetClass()
				local Model      = V:GetModel()
				local Angles     = V:GetAngles()
				local Material   = V.Mat or V:GetMaterial()
				local Col        = V.Col
				
				if not (V.Col) then
					local R, G, B, A = V:GetColor()
					
					Col = {R, G, B, A}
				end
				
				local Entity = ents.Create(Class)
				
				Entity:SetModel(Model)
				Entity:SetAngles(Angles)
				Entity:SetMaterial(Material)
				Entity:SetColor(Col[1], Col[2], Col[3], Col[4])
				
				local VectorOBBMaxs = V:OBBMaxs()
				local VectorOBBMins = V:OBBMins()
				
				local TempUp = V:GetUp()
				local TempRight = V:GetRight()
				local TempForward = V:GetForward()
				
				local VectorPos = V:GetPos()
				
				local Len = (VectorOBBMaxs.z - VectorOBBMins.z)
				local VectorUp = VectorPos + TempUp * Len
				local VectorDown = VectorPos + TempUp * -Len
				
				local Len = (VectorOBBMaxs.y - VectorOBBMins.y)
				local VectorRight = VectorPos + TempRight * Len
				local VectorLeft = VectorPos + TempRight * -Len
				
				local Len = (VectorOBBMaxs.x - VectorOBBMins.x)
				local VectorForward = VectorPos + TempForward * Len
				local VectorBackward = VectorPos + TempForward * -Len
				
				if (Key == IN_FORWARD) then
					VectorPos = VectorBackward
				elseif (Key == IN_BACK) then
					VectorPos = VectorForward
				elseif (Key == IN_MOVERIGHT) then
					VectorPos = VectorLeft
				elseif (Key == IN_MOVELEFT) then
					VectorPos = VectorRight
				elseif (Key == IN_JUMP) then
					VectorPos = VectorUp
				elseif (Key == IN_DUCK) then
					VectorPos = VectorDown
				end
				
				Entity:SetPos(VectorPos)
				Entity:Spawn()
				
				if not (Entity:IsInWorld()) then Entity:Remove() end
				
				local Area = ents.FindInSphere(Entity:GetPos(), 128)
				
				for B, J in pairs(Area) do
					if (J != Entity and J != V) then
						if (J:GetModel() == Entity:GetModel()) then
							local VectorJ = J:GetPos()
							
							VectorJ.x = math.Round(VectorJ.x)
							VectorJ.y = math.Round(VectorJ.y)
							VectorJ.z = math.Round(VectorJ.z)
							
							local VectorEntity = Entity:GetPos()
							
							VectorEntity.x = math.Round(VectorEntity.x)
							VectorEntity.y = math.Round(VectorEntity.y)
							VectorEntity.z = math.Round(VectorEntity.z)
							
							if (VectorJ == VectorEntity) then
								J:Remove()
							end
						end
					end
				end
				
				if (SS.Lib.Valid(Entity)) then
					Player:AddCount("props", Entity)
					Player:AddCleanup("props", Entity)
					
					undo.AddEntity(Entity)
					
					if (Player.Translate.Freeze == 1) then
						Entity:GetPhysicsObject():EnableMotion(false)
						
						Player:AddFrozenPhysicsObject(Entity, Entity:GetPhysicsObject())
					end
					
					Player:SelectEntity(Entity)
				end
			end
			
			undo.SetPlayer(Player)
			
			undo.Finish()
			
			Player.Translate.Next = Cur + math.Clamp(0.25 * table.Count(Selected), 0, 5)
			
			Player:EmitSound("common/talk.wav")
		end
	end
end

hook.Add("KeyPress", "Translate.KeyPress", Translate.KeyPress)

Translate:Create(Translate.Command, {"moderator", "translate"}, "Stack props with movement keys", "<Freeze 0-1>", 1, " ")

// Create plugin

Plugin:Create()