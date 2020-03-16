function Clockwork.kernel:ModifyPhysDesc(description)
	if (string.len(description) <= 256) then
		if (!string.find(string.sub(description, -2), "%p")) then
			return description..".";
		else
			return description;
		end;
	else
		return string.sub(description, 1, 253).."...";
	end;
end;