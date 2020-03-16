--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ATTRIBUTE = openAura.attribute:New();
ATTRIBUTE.name = "Aerodynamics";
ATTRIBUTE.image = "aperture/attributes/aerodynamics";
ATTRIBUTE.maximum = 100;
ATTRIBUTE.uniqueID = "aer";
ATTRIBUTE.category = "Skills";
ATTRIBUTE.description = "Affects the speed at which you fly with jetpacks.";

ATB_AERODYNAMICS = openAura.attribute:Register(ATTRIBUTE);