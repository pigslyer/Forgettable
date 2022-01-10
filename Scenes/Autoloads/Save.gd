extends Node

var detecting: int = 0 setget set_detecting;

func set_detecting(new_val: int):
	detecting = new_val;
	Music.play_music(Music.MUSIC.AMBIENT if detecting == 0 else Music.MUSIC.COMBAT);

var save_data := {
	
};

func can_save() -> bool:
	return detecting == 0;

func save_my_data(node: Node):
	assert(node.get_path() in Groups.saveables);
	var room = Groups.saveables[node.get_path()];
	
	save_data[room.my_save_group][room.get_path_to(node)] = node.data_save();
