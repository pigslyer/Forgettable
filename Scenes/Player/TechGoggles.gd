extends Sprite

const MAX_DIST = 200;
const MULT = 30;

onready var pairs = [
	[$Light1,$Delay/Light1],
	[$Light2,$Delay/Light2],
	[$Light3,$Delay/Light3],
];

func _physics_process(delta):
	for light in pairs:
		if light[0].global_position.distance_squared_to(light[1].global_position) < MAX_DIST:
			light[1].global_position += (light[0].global_position-light[1].global_position)*MULT*delta;
		else:
			light[1].global_position = light[0].global_position;
		
		light[1].global_rotation = light[0].global_rotation;


func _on_TechGoggles_visibility_changed():
	for light in pairs:
		light[1].visible = visible;
