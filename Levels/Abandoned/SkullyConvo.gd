extends Node2D

signal open_cell;

var start_cutscene = true;

func data_save(): return null;
func data_load(_data): start_cutscene = false;

func _ready():
	# have to wait until next frame for data to load
	yield(get_tree(),"physics_frame");
	set_physics_process(false);
	if start_cutscene:
		Groups.get_player().start_dial("res://Levels/Abandoned/Prison/skully_intro.txt",false,self);
		# idk why but i have to call that manually
		Groups.get_player().follow_mouse(false);

func dial_action(id):
	if id == "reveal":
		$AnimationPlayer.play("Reveal");
		set_physics_process(true);
	elif id == "open_cell":
		emit_signal("open_cell");

func _physics_process(_delta):
	if $Skully/Visi.is_on_screen():
		$Skully.look_at(Groups.get_player().global_position)
