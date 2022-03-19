extends Area2D

var save: bool = false;

func data_save():
	return save;

func data_load(data):
	if data:
		queue_free();

func _on_Warning_body_entered(_body):
	
	if !save:
		Groups.get_player().start_dial("res://Levels/Railway/warning.txt");
		$Skully.pop_out();
		
		yield(get_tree().create_timer(0.6),"timeout");
		Groups.get_player().look_at($Skully.global_position);
		
		save = true;
