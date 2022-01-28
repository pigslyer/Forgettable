extends Node2D

const BUTTON_GROUP = "cell_control_button";

const BUTT_GREEN = preload("res://Assets/Base/button_green.png");
const BUTT_RED = preload("res://Assets/Base/button.png");

# ensure the starting door is open
var open: String;
var locked := false;

onready var opened: AnimationPlayer = $Cell1/AnimationPlayer;

func data_save(): return [locked,open];
func data_load(data):
	locked = data[0]; 
	
	if !data[1].empty():
		open = data[1];
		buttons[open].texture = BUTT_RED;
		opened.play("Close"); opened.seek(opened.current_animation_length,true);
		opened = _get_cell(open);
		opened.play("Open"); opened.seek(opened.current_animation_length,true)
		buttons[open].texture = BUTT_GREEN;

var buttons: Dictionary;

func _ready():
	for button in get_tree().get_nodes_in_group(BUTTON_GROUP):
		button.connect("pressed",self,"_cell_selected",[button.text]);
		buttons[button.text] = button.get_parent().get_child(0);

func _cell_selected(which: String):
	if !locked:
		if open == which:
			open = "";
			opened.play("Close");
			buttons[which].texture = BUTT_RED;
			
		else:
			if !open.empty():
				opened.play("Close");
				buttons[open].texture = BUTT_RED;
			
			opened = _get_cell(which);
			opened.play("Open");
			open = which;
			buttons[open].texture = BUTT_GREEN;
	else:
		$Locked.play();

func _get_cell(which) -> AnimationPlayer:
	return get_node(str("Cell",which,"/AnimationPlayer")) as AnimationPlayer;
