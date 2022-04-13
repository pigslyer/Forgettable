class_name DoorTransition, "res://Assets/Base/door_transition.png"
extends Node2D

signal closed;

const GROUP = "DoorTransition"

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

export (bool) var opens_left = true;
onready var open_anim := "Open" if opens_left else "OpenRight";

func _ready():
	add_to_group(str(leads_to,":",leads_to_id));
	$WhenClosed/NamePlate/Interactive.message = leads_to_room;

func _on_Interactive_interacted():
	
	if Save.can_save():
		state = OPENING;
		
		$WhenClosed/Scanner/Interactive.disable(true);
		var loader := Loader.new(leads_to);
		add_child(loader);
		
		var new_room: PackedScene = yield(loader,"finished_loading");
		if state == OPENING:
			owner.spawn_room(new_room,self);
			
			state = OPEN;
			$AnimationPlayer.play(open_anim);
	else:
		Groups.say_line("I can't do that while they're after me.");

func open_instantly():
	state = OPEN;
	$AnimationPlayer.play(open_anim);
	$AnimationPlayer.seek($AnimationPlayer.current_animation_length,true);


func _on_DoorCloseArea_body_exited(_body):
	if state == OPEN:
		emit_signal("closed");
	elif state == OPENING:
		state = CLOSED;

func close_safely():
	$AnimationPlayer.play_backwards(open_anim);
	state = CLOSED;
	# i can't be fucked
	var data = get_signal_connection_list("closed");
	for conn in data:
		disconnect("closed",conn["target"],conn["method"]);

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


func get_foot_override():
	return [
		Rect2(
			Vector2(
				min($TopLeft.global_position.x,$BottomRight.global_position.x),
				min($TopLeft.global_position.y,$BottomRight.global_position.y)
			),
			(
				$BottomRight.position-$TopLeft.position
			).rotated(global_rotation).abs()
		),
		preload("res://Assets/Sounds/vent_floor.wav"),
	];
