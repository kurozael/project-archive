--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "vehicle_base";
ITEM.name = "Tacoma";
ITEM.cost = 6200;
ITEM.calcView = Vector(0, 0, 8);
ITEM.class = "prop_vehicle_jeep";
ITEM.model = "models/tacoma2.mdl";
ITEM.seatType = "Seat_Jeep";
ITEM.hideSeats = true;
ITEM.description = "A dirty Tacoma, it can hold eight people.";
ITEM.vehiclePhysDesc = "A dirty but well-handled vehicle.";
ITEM.useLocalPositioning = true;

ITEM.keyValues = {
	vehiclescript = "scripts/vehicles/tideslkw.txt"
};
ITEM.passengers = {
	passengerOne = { position = Vector(20.3835, -32.9409, 21.3003), angles = Angle(0, 0, 0) },
	passengerTwo = { position = Vector(15.0381, 7.7387, 23.2659), angles = Angle(0, 0, 0) },
	passengerThree = { position = Vector(-9.4026, -109.1625, 41.3960), angles = Angle(-0.189, 178.759, -0.125) },
	passengerFour = { position = Vector(16.2030, -109.9903, 42.0092), angles = Angle(-0.189, 178.759, -0.125) },
	passengerFive = { position = Vector(15.0381, 7.7387, 23.2659), angles = Angle(0, 0, 0) },
	passengerSix = { position = Vector(-6.8691, -32.9664, 22.8183), angles = Angle(0.427, 4.890, 0.290) },
	passengerSeven = { position = Vector(-23.3682, -74.2946, 37.6410), angles = Angle(-0.238, 91.899, -0.647) },
	passengerEight = { position = Vector(31.8432, -74.5028, 39.7141), angles = Angle(0.255, -89.943, -0.111) }
};
ITEM.customExits = {
	Vector(61.9045, -3.8202, 17.9935),
	Vector(63.4078, 55.0964, 20.3295),
	Vector(35.1916, 103.2800, 18.7763),
	Vector(-20.9556, 106.7029, 18.8967),
	Vector(-54.8621, 71.0253, 21.9451),
	Vector(-56.4721, 17.2782, 19.6183),
	Vector(-56.9286, -37.3291, 14.6850),
	Vector(-53.1111, -92.0793, 21.4682),
	Vector(16.2030, -109.9902, 42.0092),
	Vector(43.6512, -132.7718, 16.0631)
};

openAura.item:Register(ITEM);