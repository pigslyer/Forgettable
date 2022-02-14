extends Node

signal world_state_changed(new_state);

enum STATE{
	PIPE = 0b1,
	DETECTOR = 0b10,
	LORELEI = 0b100,
};

# key for dictionary, not key for keycard
const DROPPED_ITEM_KEY = "Dropped_Items";

# DON'T FORGET TO SET THIS ON NEW GAME
var cur_state: int = STATE.PIPE setget cur_state_changed;
var cur_objective: String;
var detecting: int = 0 setget set_detecting;

func set_detecting(new_val: int):
	detecting = new_val;
	Music.play_music(Music.MUSIC.AMBIENT if detecting == 0 else Music.MUSIC.COMBAT);

func cur_state_changed(new_state: int):
	cur_state = new_state;
	emit_signal("world_state_changed",new_state);

# used for both room and normal data
var save_data := {
	
};

func can_save() -> bool:
	return detecting == 0;

func save_my_data(node: Node):
	if node.is_in_group(Groups.SAVING):
		var room = Groups.get_my_room(node);
		save_data[room.my_save_group][str(room.get_path_to(node))] = node.data_save();
	elif !node.is_in_group(Groups.DROPPED_ITEM):
		push_error("Item which is neither saveable nor dropped tried to save.");
