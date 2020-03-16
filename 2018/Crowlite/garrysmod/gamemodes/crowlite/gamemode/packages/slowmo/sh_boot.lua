--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

if (SERVER) then
	function SlowMo:SlowTime(amount, duration)
		self.slowStart = CurTime();
		self.slowAmount = amount;
		self.slowDuration = duration;

		game.SetTimeScale(amount);		
	end;

	function SlowMo:ResetTime()
		game.SetTimeScale(1);

		self.slowStart = nil;
		self.slowDuration = nil;
		self.slowAmount = nil;
	end;

	function SlowMo:Tick()
		if (self.slowStart and self.slowStart + (self.slowDuration * self.slowAmount) <= CurTime()) then
			self:ResetTime();
		end;
	end;
else
	local slowMat = Material("effects/tp_eyefx/tpeye3");

	function SlowMo:HUDPaint()
		if (game.GetTimeScale() < 1) then
			render.SetMaterial(slowMat);

			-- We draw it twice to make it more noticable.
			render.DrawScreenQuad();
			render.DrawScreenQuad();
		end;
	end;
end;

function SlowMo:EntityEmitSound(data)
	local time = game.GetTimeScale();

	if (time != 1) then
		data.Pitch = data.Pitch * time;

		return true;
	end;
end;