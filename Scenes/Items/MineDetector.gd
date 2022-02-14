extends ItemBase

const PITCH_MIN = 0.5;
const PITCH_MAX = 1.7;
const RANGE = 90;

var on := false;


func _use():
	on = !on;
	$Ping.playing = on;
	$Ping.pitch_scale = PITCH_MIN;
	update_hud();

func _hud_primary():
	return "Turn off" if on else "Turn on";

func _physics_process(_delta):
	
	if on:
		if !$End/MineDetection.get_overlapping_areas().empty():
			var closest: Node2D = $End/MineDetection.get_overlapping_areas()[0];
			
			for area in $End/MineDetection.get_overlapping_areas():
				if $Start.global_position.distance_squared_to(closest.global_position) > $Start.global_position.distance_squared_to(area.global_position):
					closest = area;
			
			$Ping.pitch_scale = (1-$Start.global_position.distance_to(closest.global_position)/RANGE)*(PITCH_MAX-PITCH_MIN)+PITCH_MIN;
		else:
			$Ping.pitch_scale = PITCH_MIN;
