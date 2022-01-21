class_name FreeCam
extends Camera2D

const SPEED = 300;

func _ready():
	pause_mode = PAUSE_MODE_PROCESS;

func _physics_process(delta):
	position += delta* SPEED * Vector2(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"),Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up"));
