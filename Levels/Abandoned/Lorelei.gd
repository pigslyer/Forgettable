extends Node2D

const ROOT = "res://Levels/Abandoned/Shower/";

enum{
	NONE, QUESTIONS, CONFRONT
};

var state: int = NONE;

func data_save():
	return state;

func data_load(data):
	state = data if Save.cur_state != Save.STATE.LORELEI && Save.save_data.get("tortured",false) else CONFRONT;

func _ready():
	$Blood.visible = Save.cur_state == Save.STATE.LORELEI && Save.save_data.get("tortured",false)

func dial_action(id):
	
	if id == "reveal":
		$AnimationPlayer.play("PukeItOut");
	
	if id == "lore":
		state = QUESTIONS;
		Groups.get_player().get_dial_player().start(ROOT+"lorelei1_lore.txt",false,self);

func _on_Interactive_interacted():
	
	var dial: String = ROOT;
	
	if state == NONE:
		dial += "lorelei_intro.txt";
	elif state == QUESTIONS:
		dial += "lorelei_lore1.txt";
	elif state == CONFRONT:
		dial += "lorelei_confront.txt";
	
	Groups.get_player().get_dial_player().start(dial,false,self);
