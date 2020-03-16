function Clockwork:ClockworkSchemaLoaded()
	if (tonumber(Clockwork.kernel:GetVersion()) >= 0.97) then
		self.directory:AddCategoryPage("HelpCredits", "HelpClockwork", "http://authx.cloudsixteen.com/credits.php", true);
		self.directory:AddPage("HelpBugsIssues", "http://github.com/CloudSixteen/Clockwork/issues", true);
		self.directory:AddPage("HelpCloudSixteen", "https://eden.cloudsixteen.com", true);
	else
		self.directory:AddCategoryPage("Credits", "Clockwork", "http://authx.cloudsixteen.com/credits.php", true);
		self.directory:AddPage("Bugs/Issues", "http://github.com/CloudSixteen/Clockwork/issues", true);
		self.directory:AddPage("Cloud Sixteen", "https://eden.cloudsixteen.com", true);
	end;
end;