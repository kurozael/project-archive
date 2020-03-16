--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local CrowRounds = CrowRounds;
local CrowNest = Crow.nest;
local Crow = Crow;

local CrowPackage = CrowNest:GetLibrary("package");

CrowRounds.roundTypes = CrowRounds.roundTypes or {};
CrowRounds.currentStage = CrowRounds.currentStage or {};
CrowRounds.currentRound = CrowRounds.currentRound or nil;

CrowPackage:AddExtra("/rounds");

function CrowRounds:GetDefaultRound()
	return {
		{
			name = "Warmup",
			time = 15
		},
		{
			name = "Round",
			time = 120
		},
		{
			name = "Post-Round",
			time = 15
		}
	};
end;

function CrowRounds:GetRounds()
	return self.roundTypes;
end;

function CrowRounds:GetRoundByIndex(index)
	return self.roundTypes[index];
end;

function CrowRounds:AddRound(index, name, isTeamBased, stageTable, moduleTable, description)
	self.roundTypes[index] = {
		index = index,
		name = name,
		stageTable = stageTable or self:GetDefaultRound(),
		isTeamBased = isTeamBased,
		module = moduleTable,
		desc = description
	};
end;

function CrowRounds:GetRoundByName(name)
	for k, v in pairs(self.roundTypes) do
		if (string.lower(v.name) == string.lower(name)) then
			return v;
		end;
	end;
end;

function CrowRounds:SetCurrentRound(round)
	if (isstring(round)) then
		round = self:GetRoundByName(round);	
	end;

	if (round) then
		CrowPackage:RemoveModule("CROW_ROUNDS_MODULE");

		self.currentRound = round;

		if (SERVER) then
			jsonstream.Send("CrowRoundSync", round, _player.GetAll());

			self:StartRound(round.stageTable);
		end;

		if (round.module) then
			CrowPackage:AddModule("CROW_ROUNDS_MODULE", round.module);
		end;
	end;
end;

function CrowRounds:GetCurrentRound()
	return self.currentRound;
end;

function CrowRounds:GetRoundName()
	if (self.currentRound and self.currentRound.name) then
		return self.currentRound.name;
	end;
end;

function CrowRounds:GetTeamBased()
	if (self.currentRound and self.currentRound.isTeamBased != nil) then
		return self.currentRound.isTeamBased;
	end;
end;

function CrowRounds:GetRoundIndex()
	if (self.currentRound and self.currentRound.index) then
		return self.currentRound.index;
	end;
end;

function CrowRounds:GetTimeLeft()
	if (self:GetActive() and self.stageEndTime) then
		local timeLeft = self.stageEndTime - CurTime();

		if (timeLeft < 0) then
			timeLeft = 0;
		end;

		return math.Round(timeLeft);
	else
		return 0;
	end;
end;

function CrowRounds:GetIndex()
	if (self.currentStage and self.currentStage.index) then
		return self.currentStage.index;
	end;
end;

function CrowRounds:GetDuration()
	if (self.currentStage and self.currentStage.time) then
		return self.currentStage.time;
	end;
end;

function CrowRounds:GetActive()
	if (self.currentStage and self.currentStage.active) then
		return self.currentStage.active;
	end;
end;

function CrowRounds:GetName()
	if (self.currentStage and self.currentStage.name) then
		return self.currentStage.name;
	end;
end;

if (SERVER) then
	function CrowRounds:RotateRound()
		if (!CrowPackage:CallAll("PreCrowRoundRotate")) then
			local currentRound = self:GetCurrentRound();

			if (currentRound) then
				self:SetCurrentRound(currentRound);
			else
				local roundType = table.Random(self.roundTypes);

				self:SetCurrentRound(roundType);
			end;

			CrowPackage:CallAll("PostCrowRoundRotate");
		end;
	end;

	function CrowRounds:HandleStart()
	--	self.roundRepeats = 0;

		self:RotateRound();
	end;

	function CrowRounds:Tick()
		if (self:GetActive()) then
			local timeLeft = self:GetTimeLeft();

			if (timeLeft <= 0) then
				self:NextStage();
			end;
		end;
	end;

	function CrowRounds:StartRound(round)
		if (istable(round)) then
			if (!CrowPackage:CallAll("PreCrowRoundStart", round.stageTable, round)) then
				local stage = round[1];

				self:SetStageFromTable(1, stage);
				self.roundTable = round;

				CrowPackage:CallAll("PostCrowRoundStart", round.stageTable, round);
			end;
		end;
	end;

	function CrowRounds:StopRound()
		if (!CrowPackage:CallAll("PreCrowRoundFinished")) then
			self.currentStage.active = false;
			self.currentStage.duration = 0;
			self.currentStage.name = "N/A";

			jsonstream.Send("CrowRoundStageSync", self.currentStage, _player.GetAll());

			self.roundTable = nil;

			CrowPackage:CallAll("PostCrowRoundFinished");
		end;
	end;

	function CrowRounds:SetStageFromTable(index, stage)
		if (istable(stage)) then
			self.currentStage.time = stage.time or 120;
			self.currentStage.name = stage.name or "N/A";
			self.currentStage.index = index or 1;
			self.currentStage.active = true;

			self.stageEndTime = CurTime() + self:GetDuration();

			jsonstream.Send("CrowRoundStageSync", self.currentStage, _player.GetAll());
		end;
	end;

	function CrowRounds:NextStage()
		local curTime = CurTime();
		local index = self:GetIndex();

		if (index and self.roundTable) then
			local newIndex = index + 1;
			local newStage = self.roundTable[newIndex];

			if (newStage) then
				if (!CrowPackage:CallAll("PreCrowRoundAdvance", newIndex, newStage)) then
					self:SetStageFromTable(newIndex, newStage);

					CrowPackage:CallAll("PostCrowRoundAdvance", newIndex, newStage);
				end;
			else
				self:SetRoundOver();
			end;			
		end;
	end;

	function CrowRounds:SetRoundOver()
		if (!CrowPackage:CallAll("PreCrowRoundOver")) then
			self.currentStage.active = false;

			CrowPackage:CallAll("PostCrowRoundOver");
		end;
	end;
else
	jsonstream.Receive("CrowRoundStageSync", function(data)
		CrowRounds.currentStage = data;

		local duration = CrowRounds:GetDuration();

		if (duration) then
			CrowRounds.stageEndTime = CurTime() + duration;
		end;
	end);

	jsonstream.Receive("CrowRoundSync", function(data)
		CrowRounds:SetCurrentRound(data.name);
	--	CrowRounds.currentRound = data;
	end);
end;