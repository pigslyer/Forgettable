extends Node2D

func _ready():
	$Player.health = 40;
	Save.cur_objective = "Reconsider your life?";
	Save.cur_state = Save.STATE.PIPE;
	push_warning("If you're about to release, move cur state change to init/to main menu");
