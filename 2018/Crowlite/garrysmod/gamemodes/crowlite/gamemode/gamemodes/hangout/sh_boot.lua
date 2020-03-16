--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

Crow.nest:IncludeFile("cl_hooks.lua");
Crow.nest:IncludeFile("sv_hooks.lua");

function Hangout:OnInitialize()
	for k, v in pairs(_player.GetAll()) do
		v:Spawn();
	end;
end;

function Hangout:OnUnloaded()
end;

function Hangout:PlayerNoClip(player)
	return false;
end;