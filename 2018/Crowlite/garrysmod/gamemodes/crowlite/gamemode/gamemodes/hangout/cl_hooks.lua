--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local check = {
	CHudAmmo = true,
	CHudCrosshair = true,
	CHudHealth = true,
	CHudGeiger = true,
	CHudPoisonDamageIndicator = true,
	CHudSecondaryAmmo = true,
	CHudSquadStatus = true,
	CHudWeaponSelection = true,
	CHudZoom = true
};

function Hangout:HUDShouldDraw(HUDType)
	if (check[HUDType]) then
		return false;
	end;
end;

function Hangout:ScoreboardShow()
	return true;
end;