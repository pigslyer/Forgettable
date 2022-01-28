extends Node2D

signal open_cell;

var start_cutscene = true;

func data_save(): return null;
func data_load(_data): start_cutscene = false;

func _ready():
	set_physics_process(false);
	yield(get_tree(),"physics_frame");
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

func start_following():
	var tween := Tween.new();
	add_child(tween);
	tween.interpolate_property($Skully,"rotation",null,(Groups.get_player().global_position-$Skully.global_position).angle(),0.3);
	tween.start();
	tween.connect("tween_all_completed",self,"_free_tween",[tween]);

func _free_tween(tween):
	tween.queue_free();
	set_physics_process(true);

func _physics_process(_delta):
	if $Skully/Visi.is_on_screen():
		$Skully.look_at(Groups.get_player().global_position)
