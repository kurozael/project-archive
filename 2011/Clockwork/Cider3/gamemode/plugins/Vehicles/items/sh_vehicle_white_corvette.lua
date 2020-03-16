--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("vehicle_base");
ITEM.name = "White Corvette";
ITEM.cost = 12000;
ITEM.skin = 1;
ITEM.class = "prop_vehicle_jeep";
ITEM.model = "models/corvette/corvette.mdl";
ITEM.seatType = "Seat_Jeep";
ITEM.hideSeats = true;
ITEM.description = "It's a white Corvette, a pretty sweet ride.";
ITEM.cwVehiclePhysDesc = "A white, fast and sexy car.";

ITEM.keyValues = {
	vehiclescript = "scripts/vehicles/corvette.txt"
};
ITEM.passengers = {
	passengerOne = { position = Vector(22, 19, 10), angles = Angle(0, 0, 0) }
};
ITEM.customExits = {
	Vector(-98.694023132324, -14.892520904541, 47.669937133789),
	Vector(-87.526542663574, -110.98418426514, 48.202754974365),
	Vector(-31.135004043579, -148.55577087402, 48.603675842285),
	Vector(34.505981445313, -155.99627685547, 48.884742736816),
	Vector(109.35216522217, -81.04369354248, 48.778495788574),
	Vector(112.69560241699, -22.718614578247, 48.492546081543),
	Vector(112.67849731445, 35.597953796387, 48.194229125977),
	Vector(102.08125305176, 98.245147705078, 47.834579467773),
	Vector(53.170146942139, 144.70620727539, 47.415855407715),
	Vector(-12.73712348938, 158.98406982422, 47.098846435547),
	Vector(-76.72386932373, 133.09642028809, 46.994365692139),
	Vector(-98.883544921875, 70.204292297363, 47.233997344971),
	Vector(-98.694023132324, -14.892520904541, 47.669937133789), 
};

Clockwork.item:Register(ITEM);