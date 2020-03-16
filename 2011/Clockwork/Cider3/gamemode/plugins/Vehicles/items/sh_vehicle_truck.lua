--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("vehicle_base");
ITEM.name = "Truck";
ITEM.cost = 5600;
ITEM.class = "prop_vehicle_jeep";
ITEM.model = "models/tideslkw.mdl";
ITEM.seatType = "Seat_Jeep";
ITEM.calcView = Vector(0, 0, 12);
ITEM.hideSeats = true;
ITEM.description = "It's a fucking truck, what more do you want?";
ITEM.cwVehiclePhysDesc = "An old blue truck.";

ITEM.keyValues = {
	vehiclescript = "scripts/vehicles/tideslkw.txt"
};
ITEM.passengers = {
	passengerOne = { position = Vector(21, -78, 40), angles = Angle(0, 0, 0) },
	passengerTwo = { position = Vector(17, -115, 50), angles = Angle(0, 180, 0) },
	passengerThree = { position = Vector(-16, -116, 52), angles = Angle(0, 180, 0) }
};
ITEM.customExits = {
	Vector(-12.949952125549, -177.55667114258, 17.010656356812),
	Vector(68.35774230957, -138.8106842041, 17.027835845947),
	Vector(82.385200500488, -11.585611343384, 16.436128616333),
	Vector(82.305290222168, 58.103088378906, 16.092123031616),
	Vector(62.286880493164, 146.4446105957, 15.605009078979),
	Vector(-76.383743286133, -139.91772460938, 16.662437438965),
	Vector(-84.545387268066, 24.270711898804, 15.831538200378),
	Vector(-83.769081115723, 85.609252929688, 15.530905723572),
	Vector(-26.583194732666, 155.31753540039, 15.333546638489)
}

Clockwork.item:Register(ITEM);