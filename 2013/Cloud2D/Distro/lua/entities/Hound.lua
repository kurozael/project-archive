--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

ENTITY.m_sBaseClass = "Zombie";
ENTITY.m_iMoveSpeed = 550;
ENTITY.m_iAnimSpeed = 0.09;
ENTITY.m_sMaterial = "sprites/npcs/hound/idle";
ENTITY.m_sWalkAnim = "hound_run";
ENTITY.m_iHealth = 70;

sprites.AddSequence("hound_run", "sprites/npcs/hound/run/");