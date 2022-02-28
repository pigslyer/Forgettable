extends Node2D

func load_room(data: Array):
	
	var room = load(data[0]).instance();
	room.position = data[1];
	add_child(room);
	
