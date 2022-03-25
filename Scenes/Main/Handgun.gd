extends Sprite

func shoot_bullet():
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	inst.global_position = $FireFrom.global_position;
	inst.shoot(global_rotation,0b100,0,0);
	Projectile.add_child(inst);

func expunge_shell():
	var throw := preload("res://Scenes/Misc/Throwable.tscn").instance();
	throw.position = $CasingEject.global_position;
	throw.rotation = $CasingEject.global_rotation+deg2rad(30);
	Projectile.add_child(throw);
	throw.throw(
			preload("res://Assets/Base/handgun_casing.png"),
			Vector2(-50,180).rotated(global_rotation),
			preload("res://Assets/Sounds/casing_dropping.wav"), true,
			PoolVector2Array([Vector2(0,0),Vector2(6,0),Vector2(6,2),Vector2(0,2)])
	);
	throw.delay_z_reset(Groups.get_absolute_z_index($Top)+1,0.1);
	throw.set_pitch(rand_range(0.9,1.1));
