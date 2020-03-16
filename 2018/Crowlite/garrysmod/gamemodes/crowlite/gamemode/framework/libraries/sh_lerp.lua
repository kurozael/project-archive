--[[
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;

--[[ Localized Methods ]]--
local isnumber = isnumber;
local isvector = isvector;
local isangle = isangle;
local IsColor = IsColor;
local Color = Color;
local Lerp = Lerp;
local MsgC = MsgC;

--[[ Localized Colors ]]--
local colorRed = Color(255, 0, 0);

--[[
	@codebase Shared
	@details Provides an easier alternative to using the Lerp functions for linear interpolation provided with GMod.
--]]
local CrowLerp = Crow.nest:GetLibrary("lerp");

--[[ Private Members ]]--
CrowLerp.__stored = CrowLerp.__stored or {};

--[[
	@codebase Shared
	@details A function to return the local stored table, which would otherwise be inaccessible.
	@returns Table The table containing all the current Lerp information.
--]]
function CrowLerp:GetStored()
	return self.__stored;
end;

--[[
	@codebase Shared
	@details A function to return a Lerp table by the name it was given upon creation.
	@params String The name used to search the stored table for.
	@returns Table The Lerp table or stored target value (can be either number, vector, angle, or color) found by its name, if it exists currently.
--]]
function CrowLerp:FindByID(uniqueID)
	return self.__stored[uniqueID];
end;

--[[
	@codebase Shared
	@details A function to remove a Lerp table by the name it was given upon creation.
	@params String The name used to remove from the stored table.
--]]
function CrowLerp:RemoveByID(uniqueID)
	if (self.__stored[uniqueID]) then
		self.__stored[uniqueID] = nil;
	end;
end;

--[[
	@codebase Shared
	@details A function to get if a Lerp has reached its target value or not.
	@params String The name of the Lerp to check.
	@returns Bool Whether the Lerp is finished or not, returns false if it doesn't exist.
--]]
function CrowLerp:IsFinished(uniqueID)
	local lerpObj = self.__stored[uniqueID];

	return (lerpObj and !istable(lerpObj) or IsColor(lerpObj) or isvector(lerpObj) or isangle(lerpObj));
end;

--[[
	@codebase Shared
	@details A function to create a new Lerp and assign its variables.
	@params String The name of the Lerp.
	@params Number The time that the Lerp will start (should usually be the time of creation with CurTime).
	@params Number The time it will take until the Lerp finishes (in seconds).
	@params Variable The starting point of the Lerp (can be a color object, vector, angle, or number).
	@params Variable The ending point of the Lerp (can be a color object, vector, angle, or number). This will be stored in place of the Lerp table upon completion.
	@returns String The name used for the first parameter.
--]]
function CrowLerp:Register(uniqueID, startTime, duration, startValue, targetValue)
	self.__stored[uniqueID] = {
		startTime = startTime,
		duration = duration,
		endTime = startTime + duration,
		startValue = startValue,
		targetValue = targetValue,
		progress = startValue
	};

	return uniqueID;
end;

--[[
	@codebase Shared
	@details A function to progress a number Lerp, use only if the start and end values are numbers.
	@params String The name of the Lerp to progress.
	@params Number The current time used for calculation (should be from the CurTime global function).
	@returns Number The current point between the start and target value according to the time progressed and Lerp duration.
--]]
function CrowLerp:Run(uniqueID, curTime)
	local lerpObj = self.__stored[uniqueID];

	if (!lerpObj) then
		return nil;
	elseif (isnumber(lerpObj)) then
		return lerpObj;
	end;

	if (lerpObj.progress != lerpObj.targetValue) then
		local fraction = (curTime - lerpObj.startTime) / lerpObj.duration;

		lerpObj.progress = Lerp(fraction, lerpObj.startValue, lerpObj.targetValue);
	else
		self.__stored[uniqueID] = lerpObj.targetValue;
	end;

	return lerpObj.progress;
end;

--[[
	@codebase Shared
	@details A function to progress a color Lerp, use only if the start and end values are colors.
	@params String The name of the Lerp to progress.
	@params Number The current time used for calculation (should be from the CurTime global function).
	@returns Color The current point between the start and target value according to the time progressed and Lerp duration.
--]]
function CrowLerp:RunColor(uniqueID, curTime)
	local lerpObj = self.__stored[uniqueID];

	if (!lerpObj) then
		return nil;
	elseif (IsColor(lerpObj)) then
		return lerpObj;
	end;

	if (lerpObj.progress != lerpObj.targetValue) then
		local fraction = (curTime - lerpObj.startTime) / lerpObj.duration;

		lerpObj.progress = Color(
			Lerp(fraction, lerpObj.startValue.r, lerpObj.targetValue.r),
			Lerp(fraction, lerpObj.startValue.g, lerpObj.targetValue.g),
			Lerp(fraction, lerpObj.startValue.b, lerpObj.targetValue.b),
			Lerp(fraction, lerpObj.startValue.a, lerpObj.targetValue.a)
		);
	else
		self.__stored[uniqueID] = lerpObj.targetValue;
	end;

	return lerpObj.progress;
end;

--[[
	@codebase Shared
	@details A function to progress a vector Lerp, use only if the start and end values are vectors.
	@params String The name of the Lerp to progress.
	@params Number The current time used for calculation (should be from the CurTime global function).
	@returns Vector The current point between the start and target value according to the time progressed and Lerp duration.
--]]
function CrowLerp:RunVector(uniqueID, curTime)
	local lerpObj = self.__stored[uniqueID];

	if (!lerpObj) then
		return nil;
	elseif (isvector(lerpObj)) then
		return lerpObj;
	end;

	if (lerpObj.endTime >= curTime) then
		local fraction = (curTime - lerpObj.startTime) / lerpObj.duration;

		lerpObj.progress = LerpVector(fraction, lerpObj.startValue, lerpObj.targetValue);
	else
		self.__stored[uniqueID] = lerpObj.targetValue;
	end;

	return lerpObj.progress;
end;

--[[
	@codebase Shared
	@details A function to progress an angle Lerp, use only if the start and end values are angles.
	@params String The name of the Lerp to progress.
	@params Number The current time used for calculation (should be from the CurTime global function).
	@returns Angle The current point between the start and target value according to the time progressed and Lerp duration.
--]]
function CrowLerp:RunAngle(uniqueID, curTime)
	local lerpObj = self.__stored[uniqueID];

	if (!lerpObj) then
		return nil;
	elseif (isangle(lerpObj)) then
		return lerpObj;
	end;

	if (lerpObj.endTime >= curTime) then
		local fraction = (curTime - lerpObj.startTime) / lerpObj.duration;

		lerpObj.progress = LerpAngle(fraction, lerpObj.startValue, lerpObj.targetValue);
	else
		self.__stored[uniqueID] = lerpObj.targetValue;
	end;

	return lerpObj.progress;
end;