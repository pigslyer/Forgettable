extends Gun

const DAMAGE_MIN = 30;
const DAMAGE_MAX = 45;

func _shoot():
	if $FireratePause.is_stopped():
		$Firerate.start();
		$FireratePause.start();
		$AnimationPlayer.play("Fire")

func _reload():
	$AnimationPlayer.play("Reload");

func _on_Firerate_timeout():
	if ammo > 0:
		$AnimationPlayer.play("Fire");
		$FireratePause.start();

func _unhandled_input(ev: InputEvent):
	if ev.is_action_released("lmb"):
		$Firerate.stop();

func shoot():
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	Projectile.add_child(inst);
	inst.position = $FireFrom.global_position;
	inst.shoot(global_rotation,0b100,DAMAGE_MIN,DAMAGE_MAX);
	ammo -= 1;
	update_hud();

func expunge_shell():
	var throw := preload("res://Scenes/Misc/Throwable.tscn").instance();
	throw.position = $ShellFrom.global_position;
	throw.rotation = $ShellFrom.global_rotation+deg2rad(30);
	Projectile.add_child(throw);
	throw.throw(
			preload("res://Assets/Base/handgun_casing.png"),
			Vector2(-50,180*4).rotated(global_rotation),
			preload("res://Assets/Sounds/casing_dropping.wav"), true,
			PoolVector2Array([Vector2(0,0),Vector2(6,0),Vector2(6,2),Vector2(0,2)])
	);
	throw.set_pitch(rand_range(0.9,1.1));

func throw_mag():
	var throw := preload("res://Scenes/Misc/Throwable.tscn").instance();
	throw.position = $Hand/Mag.global_position;
	throw.rotation = $Hand/Mag.global_rotation;
	Projectile.add_child(throw);
	throw.throw($Hand/Mag.texture,Vector2(-25,-80).rotated(global_rotation),preload("res://Assets/Sounds/gun_mag_drop.wav"));

