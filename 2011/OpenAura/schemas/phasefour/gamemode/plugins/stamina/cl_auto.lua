--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

PLUGIN.heatwaveMaterial = Material("sprites/heatwave");
PLUGIN.heatwaveMaterial:SetMaterialFloat("$refractamount", 0);
PLUGIN.shinyMaterial = Material("models/shiny");