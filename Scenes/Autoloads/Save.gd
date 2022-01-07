extends Node

var save_data := {
	
};

func save_my_data(node: Node):
	assert(node.get_path() in Groups.saveables);
	var room = Groups.saveables[node.get_path()];
	
	save_data[room.my_save_group][room.get_path_to(node)] = node.data_save();
