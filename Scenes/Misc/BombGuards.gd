extends Node2D

func _ready():
	
	if Save.save_data.get("guard_bomb",true):
		queue_free();
	
	visible = true;
