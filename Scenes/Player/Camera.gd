extends Camera2D

const R = 80;
const MULT = 0.9*60;

const ZOOM_MULT = 0.9;

var target_pos: Vector2;
var target_zoom = Vector2(0.65,0.65);

onready var center := get_viewport_rect().size/2;

func _physics_process(delta):
	var pos = (get_viewport().get_mouse_position()-center).clamped(R);
	position = position.move_toward(pos,pos.distance_to(position)*MULT*delta);
	
	zoom += (target_zoom-zoom)*ZOOM_MULT*delta;
