--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("vehicle_base");
ITEM.name = "Green Golf";
ITEM.cost = 4800;
ITEM.skin = 2;
ITEM.class = "prop_vehicle_jeep";
ITEM.model = "models/golf/golf.mdl";
ITEM.seatType = "Seat_Jeep";
ITEM.hideSeats = true;
ITEM.description = "It's a green Golf, an alright car, I guess.";
ITEM.cwVehiclePhysDesc = "A green, smooth and classy car.";

ITEM.keyValues = {
	vehiclescript = "scripts/vehicles/golf.txt"
};
ITEM.passengers = {
	passengerOne = { position = Vector(19, 5, 10), angles = Angle(0, 0, 0) },
	passengerTwo = { position = Vector(18, 58, 15), angles = Angle(0, 0, 0) },
	passengerThree = { position = Vector(-18, 58, 15), angles = Angle(0, 0, 0) }
};
ITEM.customExits = {
	Vector(48.513771057129, -122.42366790771, 34.874473571777),
	Vector(85.719947814941, -76.769134521484, 34.909526824951),
	Vector(88.66764831543, -13.789080619812, 35.070163726807),
	Vector(92.468566894531, 62.036567687988, 35.263011932373),
	Vector(60.1962890625, 129.78788757324, 35.518100738525),
	Vector(-11.931774139404, 145.80778503418, 35.728088378906),
	Vector(-77.066986083984, 99.046257019043, 35.754878997803),
	Vector(-87.041709899902, 38.696018218994, 35.617530822754),
	Vector(-92.983581542969, -49.912063598633, 35.395656585693),
	Vector(-78.105773925781, -122.39897918701, 35.168384552002),
	Vector(-12.869844436646, -158.94761657715, 34.919776916504)
};

Clockwork.item:Register(ITEM);