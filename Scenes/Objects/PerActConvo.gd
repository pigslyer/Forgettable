class_name ActedConvo
extends Node

var state := -1;

func data_save():
	return state;

func data_load(data):
	state = data;

func _ready():
	add_to_group(Groups.SAVING);

export (NodePath) var actions;

export (String, MULTILINE) var pipe_intro;
export (String, MULTILINE) var pipe_lore;

export (String, MULTILINE) var detec_intro;
export (String, MULTILINE) var detec_lore;

export (String, MULTILINE) var lorel_intro;
export (String, MULTILINE) var lorel_lore;

onready var dials = [pipe_intro,pipe_lore,detec_intro,detec_lore,lorel_intro,lorel_lore];

func start_dial(to_info: bool = false):
	state = clamp(state+(1 if to_info else 0),get_state()-2,get_state());
	if !dials[state].empty():
		Groups.get_player().start_dial(dials[state],state%2==1,get_node(actions) if actions != null else null);

func get_state() -> int:
	match Save.cur_state:
		1:
			return 2;
		2:
			return 4;
		4:
			return 6;
	
	return -1;
