extends ItemBase

var charge: float;
var on := false;

func _use():
	on = !on;
	$Beam.set_enabled(on);
	update_hud();

func _equip_on():
	on = false;
	$Beam.enabled = false;

func _hud_primary() -> String:
	return "Turn off" if on else "Turn on";

func _hud_secondary() -> String:
	return "Crank";
