extends Sprite

const DAMAGE_MIN = 20;
const DAMAGE_MAX = 30;

const MAX_AMMO = 7;

var ammo = MAX_AMMO;

func shoot():
	if ammo > 0 && !is_reloading():
		ammo -= 1;
		if $AnimationPlayer.current_animation == "Shoot":
			$AnimationPlayer.seek(0,true);
		else:
			$AnimationPlayer.play("Shoot");
	
	else:
		$AnimationPlayer.play("Reload");
		ammo = MAX_AMMO;
	

func set_laser_energy(en: Vector2):
	$LaserSight.energy_min = en.x; $LaserSight.energy_max = en.y;

func throw_mag():
	var throw := preload("res://Scenes/Misc/Throwable.tscn").instance();
	throw.position = $Hand/Magazine.global_position;
	throw.rotation = $Hand/Magazine.global_rotation;
	Projectile.add_child(throw);
	throw.throw($Hand/Magazine.texture,Vector2(-25,-80).rotated(global_rotation),preload("res://Assets/Sounds/gun_mag_drop.wav"));
	

func is_reloading() -> bool:
	return $AnimationPlayer.current_animation == "Reload";

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

func _shoot():
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	inst.global_position = $Firefrom.global_position;
	inst.shoot(global_rotation,0b10,DAMAGE_MIN,DAMAGE_MAX);
	Projectile.add_child(inst);
