extends Node2D

const SCREAM_DELAY_MIN = 4.2;
const SCREAM_DELAY_MAX = 10;

var screaming := true;

func data_save(): return screaming;
func data_load(data): screaming = data;

func _ready():
	yield(get_tree(),"physics_frame")
	_reset_scream();

func _reset_scream():
	yield(get_tree().create_timer(rand_range(SCREAM_DELAY_MIN,SCREAM_DELAY_MAX)),"timeout");
	if screaming:
		$Tormentor/Screaming.play();

func dial_action(action):
	if action == "carry":
		$AnimationPlayer.playback_speed = 1.0;
		$AnimationPlayer.play("carry");
		screaming = false;
