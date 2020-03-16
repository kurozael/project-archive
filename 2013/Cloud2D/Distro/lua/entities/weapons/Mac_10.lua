--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]
 
ENTITY.m_sBaseClass = "Weapon";
ENTITY.m_sMaterial = "sprites/weapons/mac_10";
ENTITY.m_sHoldType = "rifle";
 
ENTITY.m_primary = {
	tracerColor = Color(50, 50, 50, 1),
	isAutomatic = true,
	fireSound = "weapons/pistol/primary_fire",
	ammoType = "pistol",
	damage = 8,
	force = 130,
	delay = 0.15
};
