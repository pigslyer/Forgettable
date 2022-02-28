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

export (String) var pipe_intro;
export (String) var pipe_lore;

export (String) var detec_intro;
export (String) var detec_lore;

export (String) var lorel_intro;
export (String) var lorel_lore;

onready var dials = [pipe_intro,pipe_lore,detec_intro,detec_lore,lorel_intro,lorel_lore];

func start_dial():
	state = clamp(state+1,get_state()-2,get_state());
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
