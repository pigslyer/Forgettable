class_name WorldState
extends Node2D

export (Save.STATE,FLAGS) var exists_in = 0b111;

func _ready():
	if exists_in & Save.cur_state == 0:
		queue_free();
	else:
		visible = true;
