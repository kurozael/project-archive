NOTIFY_GENERIC = 0
NOTIFY_ERROR   = 1
NOTIFY_UNDO	   = 2
NOTIFY_HINT	   = 3
NOTIFY_CLEANUP = 4

local Materials = {}

Materials[NOTIFY_GENERIC] = surface.GetTextureID("vgui/notices/generic")
Materials[NOTIFY_ERROR]   = surface.GetTextureID("vgui/notices/error")
Materials[NOTIFY_UNDO]    = surface.GetTextureID("vgui/notices/undo")
Materials[NOTIFY_HINT]    = surface.GetTextureID("vgui/notices/hint")
Materials[NOTIFY_CLEANUP] = surface.GetTextureID("vgui/notices/cleanup")

local Note_C = 0
local Note_I = 1
local Note_H = {}

// New

function GAMEMODE:AddNotify(String, Type, Leng)
	local Tab = {}
	
	Tab.text 	= String
	Tab.recv 	= CurTime()
	Tab.len 	= Leng
	Tab.velx	= -5
	Tab.vely	= 0
	Tab.x		= ScrW() + 200
	Tab.y		= ScrH()
	Tab.a		= 255
	Tab.type	= Type
	
	table.insert(Note_H, Tab)
	
	Note_C = Note_C + 1
	Note_I = Note_I + 1
end

// Draw it

local function Create(self, k, v, i)
	local Border = 1
	
	local H = ScrH() / 1024
	local x = v.x - 75 * H
	local y = v.y - 300 * H
	
	if (!v.w) then
		surface.SetFont("ChatFont")
		v.w, v.h = surface.GetTextSize(v.text)
	end
	
	local w = v.w
	local h = v.h
	
	w = w + 16
	h = h + 16
	
	local X = x - w - h + 8
	local Y = y - 8
	local W = w + h
	local H = h
	
	local Col = Color(255, 255, 255, 255)

	draw.RoundedBox(0, X - Border, Y - Border, Border, H + Border, Col)
	draw.RoundedBox(0, X - Border, Y - Border, W + Border, Border, Col)
	draw.RoundedBox(0, X + W, Y - Border, Border, H + Border, Col)
	draw.RoundedBox(0, X - Border, Y + H, W + (Border * 2), Border, Col)
	draw.RoundedBox(0, X, Y, W, H, Color(0, 0, 0, 200))
	
	surface.SetDrawColor(0, 0, 0, 50)
	surface.SetTexture(Materials[v.type])
	surface.DrawTexturedRect(x - w - h + 17, y - 3, h - 8, h - 8)
	
	surface.SetDrawColor(255, 255, 255, v.a)
	surface.SetTexture(Materials[v.type])
	surface.DrawTexturedRect(x - w - h + 16, y - 4, h - 8, h - 8)
	
	draw.SimpleText(v.text, "ChatFont", x, y, Color(255,255,255,v.a), TEXT_ALIGN_RIGHT)
	
	local ideal_y = ScrH() - (Note_C - i) * (h + 4)
	
	local ideal_x = ScrW()
	
	local timeleft = v.len - (CurTime() - v.recv)
	
	if (timeleft < 0.8 ) then
		ideal_x = ScrW() - 50
	end
	
	if (timeleft < 0.5 ) then
	
		ideal_x = ScrW() + w * 2
	
	end
	
	local spd = FrameTime() * 15
	
	v.y = v.y + v.vely * spd
	v.x = v.x + v.velx * spd
	
	local dist = ideal_y - v.y
	v.vely = v.vely + dist * spd * 1
	if (math.abs(dist) < 2 && math.abs(v.vely) < 0.1) then v.vely = 0 end
	local dist = ideal_x - v.x
	v.velx = v.velx + dist * spd * 1
	if (math.abs(dist) < 2 && math.abs(v.velx) < 0.1) then v.velx = 0 end
	
	v.velx = v.velx * (0.95 - FrameTime() * 8)
	v.vely = v.vely * (0.95 - FrameTime() * 8)
end

// Paint them

function GAMEMODE:PaintNotes()
	if (!Note_H) then return end
	
	local i = 0
	
	for k, v in pairs(Note_H) do
		if (v != 0) then
			i = i + 1
			Create(self, k, v, i)		
		end
	end
	
	for k, v in pairs(Note_H) do
		if (v != 0 && v.recv + v.len < CurTime()) then
		
			Note_H[k] = 0
			Note_C = Note_C - 1
			
			if (Note_C == 0) then Note_H = {} end
		end
	end
end