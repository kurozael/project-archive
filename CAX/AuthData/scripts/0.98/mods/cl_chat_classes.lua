Clockwork.chatBox:RegisterClass("cw_news", "ooc", function(info)
	Clockwork.chatBox:SetMultiplier(0.825);
	Clockwork.chatBox:Add(info.filtered, "icon16/newspaper.png", Color(204, 102, 153, 255), info.text);
end);