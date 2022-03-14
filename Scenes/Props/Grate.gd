extends Node2D

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
		open = false;
		open_vent(true);

func open_vent(instant: bool = false):
	
	if !open:
		open = true;
		$Grate/AnimationPlayer.play("Open");
		$Grate/Interactive.disabled = true;
		if instant:
			$Grate/AnimationPlayer.seek($Grate/AnimationPlayer.current_animation_length);
