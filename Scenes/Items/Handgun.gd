extends Gun

func _shoot():
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	Projectile.add_child(inst);
	inst.global_position = $FireFrom.global_position;
	inst.shoot(global_rotation);
	
