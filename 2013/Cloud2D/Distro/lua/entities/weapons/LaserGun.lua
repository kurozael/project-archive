--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_sBaseClass = "Weapon";
ENTITY.m_sMaterial = "sprites/weapons/lasergun";

ENTITY.m_primary = {
	tracerColor = Color(1, 0, 0, 1),
	fireSound = "weapons/lasergun/primary_fire",
	ammoType = "lasergun",
	damage = 32,
	force = 256
};