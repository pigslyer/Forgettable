extends Sprite

const IS_LOCKED = "The grate won't budge.";

export (bool) var open = false;

func data_save():
	return open;

func data_load(data):
	open = data;
	if data:
		open_vent(true);

func _ready():
	if open:
		open_vent(true);

func open_vent(instant: bool = false):
	
	open = true;
	$AnimationPlayer.play("Open");
	$Interactive.disabled = true;
	if instant:
		$AnimationPlayer.seek($AnimationPlayer.current_animation_length);
