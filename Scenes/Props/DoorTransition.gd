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

# good name
export (String) var leads_to_room;

# literally just so we can get our room
func data_save(): return null;
func data_load(_data): pass;

func _ready():
	add_to_group(str(leads_to,":",leads_to_id));

func _on_Interactive_interacted():
	state = OPENING;
	
	$WhenClosed/NamePlate/Interactive.message = leads_to_room;
	$WhenClosed/Scanner/Interactive.disable(true);
	var loader := Loader.new(leads_to);
	add_child(loader);
	
	
	var new_room: PackedScene = yield(loader,"finished_loading");
	if state == OPENING:
		Groups.get_my_room(self).spawn_room(new_room,self);
		
		state = OPEN;
		$AnimationPlayer.play("Open");

func open_instantly():
	state = OPEN;
	$AnimationPlayer.play("Open");
	$AnimationPlayer.seek($AnimationPlayer.current_animation_length,true);


func _on_DoorCloseArea_body_exited(_body):
	if state == OPEN:
		emit_signal("closed");
	elif state == OPENING:
		state = CLOSED;

func close_safely():
	$AnimationPlayer.play_backwards("Open");
	state = CLOSED;
	# i can't be fucked
	var data = get_signal_connection_list("closed")[0];
	disconnect("closed",data["target"],data["method"]);

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

