extends Node2D

var is_done: bool = false

func data_save(): return is_done;
func data_load(data): is_done = data;

export (NodePath) var starting1;
export (NodePath) var starting2;
export (NodePath) var starting3;

export (NodePath) var door;

# door opens, enemies rush out
# each goes to his own point
# they're made undeaf
# door is unlocked
# general access keycard is "dropped" in the corner of the room

func _ready():
	yield(get_tree(),"idle_frame");
	if !is_done:
		$Banging.play();

func _on_Handgun_picked_up():
	
	$Keycard.disabled = false;
	
	var exit: Door = get_node(door);
	exit.enemies_can_open = true;
	exit._on_open(true);
	exit.locked_line = "The door's broken.";
	
	is_done = true;
	$Banging.stop();
	
	var enemy1: Enemy = get_node(starting1);
	enemy1.deaf = false;
	enemy1.path = [$Enemy1TargetPos.global_position];
	
	var enemy2: Enemy = get_node(starting2);
	enemy2.deaf = false;
	enemy2.path = Groups.get_simple_path(enemy2.global_position,$Enemy2TargetPos.global_position);
	
	var enemy3: Enemy = get_node(starting3);
	enemy3.deaf = false;
	enemy3.path = Groups.get_simple_path(enemy3.global_position,$Enemy3TargetPos.global_position);
	
	Save.save_my_data(self);
	
	yield(get_tree().create_timer(3),"timeout");
	enemy2.rotation_degrees = -90;
	

func _on_Banging_finished():
	
	yield(get_tree().create_timer(rand_range(0.8,2.5)),"timeout");
	if !is_done:
		$Banging.play();
