extends Node2D

signal open_cell;

var start_cutscene = true;

func data_save(): return start_cutscene;
func data_load(data): start_cutscene = data;

func dial_action(id):
	start_cutscene = false;
	
	if id == "reveal":
		$Skully.pop_out();
		$Tween.interpolate_property(Groups.get_player().get_camera(),"global_position",Groups.get_player().global_position,$CameraTarget.global_position,0.3);
		$Tween.start();
		set_physics_process(true);
		
		yield(get_tree().create_timer(0.6),"timeout");
		Groups.get_player().turn_towards($CameraTargetSkully.global_position);
		
	
	elif id == "open_cell":
		emit_signal("open_cell");
		
		yield(get_tree().create_timer(0.7),"timeout");
		Groups.get_player().turn_towards($CameraTargetDoor.global_position);
		yield(get_tree().create_timer(1.4),"timeout");
		Groups.get_player().turn_towards($CameraTargetSkully.global_position);
