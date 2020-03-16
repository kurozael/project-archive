--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to load the surface texts.
function PLUGIN:LoadSurfaceTexts()
	self.surfaceTexts = CloudScript:RestoreSchemaData( "plugins/texts/"..game.GetMap() );
end;

-- A function to save the surface texts.
function PLUGIN:SaveSurfaceTexts()
	CloudScript:SaveSchemaData("plugins/texts/"..game.GetMap(), self.surfaceTexts);
end;