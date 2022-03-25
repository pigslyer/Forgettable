extends Label

const SPEED = 300/255.0;

var vis := -1;

func _physics_process(delta):
	modulate.a = clamp(modulate.a + vis * SPEED * delta,0,1);

func show():
	vis = 1;

func hide():
	vis = -1;
