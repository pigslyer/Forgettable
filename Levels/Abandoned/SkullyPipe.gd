extends Node2D

func _on_Area2D_body_entered(_body):
	var c = Groups.get_player().get_waffle().count_item("res://Scenes/Items/Pipe.tscn");
	if c > 0:
		$Skully.pop_out();
		Groups.get_player().start_dial("res://Levels/Abandoned/Prison/skully_pipe.txt",true,self);
		Groups.get_player().get_waffle().get_item("res://Scenes/Items/Pipe.tscn",c);
		if Groups.get_player().has_pipe:
			Groups.get_player().equip_special("res://Scenes/Items/Pipe.tscn",true);
		
		yield($Skully,"popped");
		
		Groups.get_player().turn_towards($Skully.global_position);
	
