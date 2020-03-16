--[[
Name: "init.lua".
Product: "HL2 RP".
--]]

KS_GAMEMODE = GM;

-- Add a shared Lua file.
AddCSLuaFile("cl_init.lua");

-- Derive the gamemode from kuroScript.
DeriveGamemode("kuroScript");