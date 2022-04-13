extends Node2D

const SCREAM_DELAY_MIN = 4.2;
const SCREAM_DELAY_MAX = 10;

var screaming := true;

func data_save(): return screaming;
func data_load(data): 
	screaming = data;
	$EmergencyLight.set_enabled(screaming);

func _ready():
	yield(get_tree(),"idle_frame");
	if screaming:
		_reset_scream();
	else:
		queue_free();

func _reset_scream():
	if screaming:
		$ScreamReset.start(rand_range(SCREAM_DELAY_MIN,SCREAM_DELAY_MAX));

func dial_action(action):
	if action == "carry":
		$AnimationPlayer.playback_speed = 1.0;
		$AnimationPlayer.play("carry");
		screaming = false;

func start_screaming():
	if screaming:
		$Tormentor/Screaming.play();
