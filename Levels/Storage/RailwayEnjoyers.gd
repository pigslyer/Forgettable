extends WorldState

export (NodePath) var door;

func _ready():
	yield(get_tree(),"idle_frame");
	
	if !is_queued_for_deletion():
		var d: Door = get_node(door);
		d.locked = false;
		if !d.open:
			d._on_open(true);
		d.enemies_can_open = true;
		d.prev_open = true;
