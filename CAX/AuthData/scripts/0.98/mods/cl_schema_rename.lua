local cax_override = nil;

if (cax_override != nil and cax_override != "") then
	timer.Create("cw.GamemodeName", 1, 0, function()
		Clockwork.Name = cax_override;
		
		if (Schema) then
			Schema.name = cax_override;
		end;
	end);
end;