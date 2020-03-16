--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("vehicle_base");
ITEM.name = "Trabbi";
ITEM.cost = 2400;
ITEM.class = "prop_vehicle_jeep";
ITEM.model = "models/trabbi.mdl";
ITEM.seatType = "Seat_Jeep";
ITEM.calcView = Vector(0, 0, 12);
ITEM.hideSeats = true;
ITEM.description = "A really shitty car, but hey, whatever gets you from A to B.";
ITEM.cwVehiclePhysDesc = "A shitty old rundown car.";

ITEM.keyValues = {
	vehiclescript = "scripts/vehicles/trabbi.txt"
};
ITEM.passengers = {
	passengerOne = { position = Vector(16, 2, 12), angles = Angle(0, 0, 0) }
};
ITEM.customExits = {
	Vector(-75.345596313477, 45.022392272949, 23.1364402771),
	Vector(-79.7568359375, -19.58497428894, 24.770875930786),
	Vector(-68.636054992676, -99.910888671875, 26.777940750122),
	Vector(25.639087677002, -125.35977935791, 27.277189254761),
	Vector(80.815589904785, -62.380054473877, 25.607303619385),
	Vector(80.238693237305, 32.363185882568, 23.221099853516),
	Vector(7.7356305122375, 116.2345123291, 21.217151641846)
};

Clockwork.item:Register(ITEM);