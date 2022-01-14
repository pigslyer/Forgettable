class_name DoorTransition
extends Node2D

signal closed;

enum{
	CLOSED,
	OPENING,
	OPEN,
};
var state: int = CLOSED;

export (int) var my_id

# should contain filepath to other level
export (String) var leads_to
# should contain number id of other side
export (int) var leads_to_id

# literally just so we can get our room
func save_data(): return null;
func load_data(_data): pass;

func _ready():
	add_to_group(str(leads_to,":",leads_to_id));

func _on_Interactive_interacted():
	state = OPENING;
	
	$WhenClosed/Scanner/Interactive.disable(true);
	var loader := Loader.new(leads_to);
	add_child(loader);
	
	Groups.get_my_room(self).spawn_room(yield(loader,"finished_loading"),self);
	state = OPEN;
	$AnimationPlayer.play("Open");

func open_instantly():
	state = OPEN;
	$AnimationPlayer.play("Open");
	$AnimationPlayer.seek($AnimationPlayer.current_animation_length,true);


class Loader extends Node:
	
	signal finished_loading;
	const LOAD_PER_FRAME = 40;
	
	var data: ResourceInteractiveLoader;
	
	func _init(path: String):
		data = ResourceLoader.load_interactive(path);
	
	func _physics_process(_delta):
		var target_time = OS.get_ticks_msec()+LOAD_PER_FRAME;
		
		while OS.get_ticks_msec() < target_time:
			if data.poll() == ERR_FILE_EOF:
				emit_signal("finished_loading",data.get_resource());
				queue_free();
	
