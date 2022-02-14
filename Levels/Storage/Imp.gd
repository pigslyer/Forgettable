extends Sprite

const DIALS := [
	"res://Levels/Storage/imp_greeting.txt",
	"res://Levels/Storage/imp_questions.txt",
	"res://Levels/Storage/imp_detector.txt",
	"res://Levels/Storage/imp_questions2.txt",
	"res://Levels/Storage/imp_ask_lorelei.txt",
	"res://Levels/Storage/imp_questions2.txt",
];

var state: int = 0;

func data_save():
	return state;

func data_load(data):
	if data < 2 && Save.cur_state == Save.STATE.DETECTOR:
		state = 2;
	elif data < 4 && Save.cur_state == Save.STATE.LORELEI:
		state = 4;
	else:
		state = data;


func dial_action(id):
	if id == "throw_key":
		$AnimationPlayer.play("ThrowCard");
	elif id == "throw_key_2":
		pass;
	
	elif id == "start_info":
		state += 1;
		# wait until the dialogue wraps up
		yield(get_tree(),"idle_frame");
		Groups.get_player().start_dial(DIALS[state],false,self);


func _on_Interactive_interacted():
	Groups.get_player().start_dial(DIALS[state],false,self);
