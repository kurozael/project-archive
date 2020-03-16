------------------------------------------------
----[ SMART SELECT ]-------------------
------------------------------------------------

local SmartSelect = SS.Commands:New("SmartSelect")

// Smart select command

function SmartSelect.Command(Player, Args)
	Player.SmartSelect = not Player.SmartSelect
	
	if (not Player.SmartSelect) then
		SS.PlayerMessage(Player, "Smart select has been disabled", 0)
	else
		SS.PlayerMessage(Player, "Smart select has been enabled", 0)
	end
end

// Think function

SmartSelect.Time = 0

function SmartSelect.Think()
	local Cur = CurTime()
	
	if (SmartSelect.Time < Cur) then
		local Players = player.GetAll()
		
		for K, V in pairs(Players) do
			if (V.SmartSelect) then
				local TR = V:TraceLine()
				
				if (TR.Entity) then
					local Index = TR.Entity:EntIndex()
					
					if (TVAR.Request(V, "Selected") and TVAR.Request(V, "Selected")[Index]) then
						return
					else
						V:SelectEntity(TR.Entity)
					end
				end
			end
		end
		
		SmartSelect.Time = Cur + 0.25
	end
end

SS.Hooks.Add("SmartSelect.Think", "ServerThink", SmartSelect.Think)

SmartSelect:Create(SmartSelect.Command, {"basic"}, "Toggle smart select (hover over entities to select)")