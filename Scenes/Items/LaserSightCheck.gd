extends RayCast2D

func _physics_process(_delta):
	$LightOccluder2D.visible = is_colliding();
	if is_colliding():
		$LightOccluder2D.global_position = get_collision_point();
