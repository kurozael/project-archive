local BLUEPRINT = Clockwork.crafting:New();

BLUEPRINT.category = "Medical";
BLUEPRINT.description = "A bandage roll, there isn't much so use it wisely.";
BLUEPRINT.model = "models/props_wasteland/prison_toiletchunk01f.mdl";
BLUEPRINT.name = "Bandage";

BLUEPRINT.itemRequirements = {
	["cloth"] = 2
};

BLUEPRINT.takeItems = BLUEPRINT.itemRequirements;

BLUEPRINT.giveItems = "bandage";

-- Called just before crafting.
function BLUEPRINT:OnCraft(player)
	
end;

-- Called just after crafting.
function BLUEPRINT:PostCraft(player)
	
end;

-- Called when crafting is unsuccessful.
function BLUEPRINT:FailedCraft(player)
	
end;

BLUEPRINT:Register();