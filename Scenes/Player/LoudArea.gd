extends Area2D

var sprinting: bool setget set_sprinting;

func loud():
	
	for enemy in get_overlapping_bodies():
		if !enemy.deaf:
			enemy.set_alerted(true);

func set_sprinting(state: bool):
	$SprintArea.set_deferred("disabled",!state);
