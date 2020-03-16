--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("vehicle_base");
ITEM.name = "Police Car";
ITEM.class = "prop_vehicle_jeep";
ITEM.model = "models/copcar.mdl";
ITEM.seatType = "Seat_Jeep";
ITEM.calcView = Vector(0, 0, 8);
ITEM.business = false;
ITEM.hideSeats = true;
ITEM.description = "A nice shiny police car, it's hot.";
ITEM.cwVehiclePhysDesc = "A sexy black car with sirens.";

ITEM.keyValues = {
	vehiclescript = "scripts/vehicles/corvette.txt"
};
ITEM.passengers = {
	passengerOne = { position = Vector(-6, 20, 5), angles = Angle(0, 0, 0) },
	passengerTwo = { position = Vector(-7, 63, 5), angles = Angle(0, 0, 0) },
	passengerThree = { position = Vector(-43, 63, 5), angles = Angle(0, 0, 0) }
};
ITEM.customExits = {
	Vector(-45.749549865723, -200.06011962891, 34.599822998047),
	Vector(72.214820861816, -154.81820678711, 34.72306060791),
	Vector(80.28955078125, -61.635520935059, 35.001205444336),
	Vector(75.838623046875, 29.963914871216, 35.275939941406),
	Vector(36.3659324646, 131.63920593262, 35.584438323975),
	Vector(-74.378387451172, 117.33410644531, 35.553043365479),
	Vector(-122.85635375977, 71.104507446289, 35.419654846191),
	Vector(-126.04415893555, -20.283185958862, 35.146373748779),
	Vector(-129.90051269531, -103.51369476318, 34.89758682251)
};

-- Called when the item's horn sound should be played.
function ITEM:PlayHornSound(player, vehicle)
	vehicle:SetNetworkedBool("Siren", !vehicle:GetNetworkedBool("Siren"));
end;

-- Called when the item should be setup.
function ITEM:OnSetup()
	self.OnDestroy = nil;
end;

Clockwork.item:Register(ITEM);