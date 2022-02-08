extends Node2D

export (NodePath) var starting1;
export (NodePath) var starting2;
export (NodePath) var starting3;

export (NodePath) var door;

# door opens, enemies rush out
# each goes to his own point
# they're made undeaf
# door is unlocked
# general access keycard is "dropped" in the corner of the room

func _on_Handgun_picked_up():
	
	$Keycard.disabled = false;
	
	var exit: Door = get_node(door);
	exit.enemies_can_open = true;
	exit.locked = false;
	
	
	var enemy1: Enemy = get_node(starting1);
	enemy1.deaf = false;
	enemy1.path = [$Enemy1TargetPos.global_position];
	
	var enemy2: Enemy = get_node(starting2);
	enemy2.deaf = false;
	enemy2.path = Groups.get_simple_path(enemy2.global_position,$Enemy2TargetPos.global_position);
	
	var enemy3: Enemy = get_node(starting3);
	enemy3.deaf = false;
	enemy3.path = Groups.get_simple_path(enemy3.global_position,$Enemy3TargetPos.global_position);
