extends Sprite

export (String) var display_name;
export (String) var key;

func _on_Interactive_interacted():
	Groups.get_player().add_keycard(display_name,key);
	queue_free();
