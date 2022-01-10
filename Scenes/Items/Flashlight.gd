extends ItemBase

var charge: float;
var on := false;

func _use():
	on = !on;
	$Beam.set_enabled(on);
	$Click.play();
	update_hud();

func _equip_on():
	on = false;
	$Beam.set_enabled(false);

func _hud_primary() -> String:
	return "Turn off" if on else "Turn on";
