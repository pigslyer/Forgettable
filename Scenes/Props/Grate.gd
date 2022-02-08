extends Sprite

const IS_LOCKED = "The grate won't budge.";

export (bool) var open = false;
export (bool) var locked = false;

func data_save():
	return [open,locked];

func data_load(data):
	open = data[0]; locked = data[1];


func _ready():
	
	yield(get_tree(),"idle_frame");
	
	

func toggle_locked():
	locked = !locked;

func _on_Interactive_interacted():
	if locked:
		Groups.say_line(IS_LOCKED);
	else:
		pass;
