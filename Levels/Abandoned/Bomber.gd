extends "res://Scenes/Enemy/Shotgunner.gd"

var look = true;

export (NodePath) var door;
export (NodePath) var keycard;

func _ready():
	set_physics_process(false);


func dial_action(id):
	if id == "spawn":
		Save.save_data["guard_bomb"] = true;
	elif id == "to_info":
		$ActedConvo.start_dial(true);
	elif id == "aggro":
		_alerted();

func set_health(new_val: int, loud: bool = true):
	if look && new_val < health:
		_alerted();
	
	# hacky, but it lets us drop keycards
	if new_val <= 0:
		var key = get_node(keycard);
		key.global_position = global_position;
	
	.set_health(new_val,loud);

func heard_noise():
	if look:
		_alerted();

func _alerted():
	look = false;
	set_physics_process(true);
	set_alerted(true);
	$Animation/Body/Hand.show();
	$Interactive.disable(true);
	
	var d: Door = get_node(door);
	if d.open:
		d._on_open();
	d.set_locked(true);


const PATH = "res://Levels/Abandoned/";

func _on_Interactive_interacted():
	if Save.save_data.get("guard_bomb",false):
		Groups.get_player().start_dial(PATH+"bomber.txt",true,self);
	elif Save.save_data[Save.EXPLOSIVES_KEY].size() == 4:
		Groups.get_player().start_dial(PATH+"bomber_reward.txt",true,self);
	else:
		Groups.get_player().start_dial(PATH+"bomber_info.txt",false,self);
	
