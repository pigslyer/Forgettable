extends WorldState

export (NodePath) var door;

func _ready():
	# this'll post an error, it's unavoiadable tho
	yield(get_tree(),"idle_frame");
	
	if !is_queued_for_deletion():
		var d: Door = get_node(door);
		d.locked = false;
