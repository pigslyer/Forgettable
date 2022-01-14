extends Node

const DROPPED_ITEM_KEY = "Dropped_Items";

var detecting: int = 0 setget set_detecting;

func set_detecting(new_val: int):
	detecting = new_val;
	Music.play_music(Music.MUSIC.AMBIENT if detecting == 0 else Music.MUSIC.COMBAT);

var save_data := {
	
};

func can_save() -> bool:
	return detecting == 0;

func save_my_data(node: Node):
	if node.is_in_group(Groups.SAVING):
		var room = Groups.get_my_room(node);
		save_data[room.my_save_group][room.get_path_to(node)] = node.data_save();
	elif !node.is_in_group(Groups.DROPPED_ITEM):
		push_error("Item which is neither saveable nor dropped tried to save.");
