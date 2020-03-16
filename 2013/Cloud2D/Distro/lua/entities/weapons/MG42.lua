--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]
 
ENTITY.m_sBaseClass = "Weapon";
ENTITY.m_sMaterial = "sprites/weapons/mg42";
ENTITY.m_sHoldType = "rifle";
 
ENTITY.m_primary = {
	tracerColor = Color(1, 1, 1, 1),
       isAutomatic = true,
	fireSound = "weapons/pistol/primary_fire",
	ammoType = "pistol",
	damage = 15,
	force = 400,
       delay = 0.11
};
