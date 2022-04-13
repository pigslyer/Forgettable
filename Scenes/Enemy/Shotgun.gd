extends Sprite

const DAMAGE_MIN = 10;
const DAMAGE_MAX = 15;

const ANGLE = deg2rad(2.3);
const PROJECTILES = 8;

var reloading: bool = false;
var can_do_stuff: bool = true;

const ammo_max = 8;
var ammo = ammo_max;

func use():
	if ammo > 0:
		$AnimationPlayer.play("Shoot")
	else:
		_reload();


func _reload():
	$AnimationPlayer.play("ReloadGetShells");
	can_do_stuff = false;
	
	yield($AnimationPlayer,"animation_finished");
	
	reloading = true;
	
	while reloading && ammo < ammo_max:
		$AnimationPlayer.play("ReloadLoadShell");
		yield($AnimationPlayer,"animation_finished");
		# ensures that at least 1 shell is loaded
		can_do_stuff = true;
	
	if reloading:
		can_do_stuff = false;
		$AnimationPlayer.play("ReloadPump");
		
		yield($AnimationPlayer,"animation_finished");
		can_do_stuff = true;
		reloading = false;

func shell_loaded():
	ammo += 1;

func shoot():
	ammo -= 1;
	var angle = $FireFrom.global_rotation-(ANGLE*PROJECTILES/2);
	var proj;
	
	for i in PROJECTILES:
		proj = preload("res://Scenes/Misc/ShotgunPellet.tscn").instance();
		Projectile.add_child(proj);
		proj.global_position = $FireFrom.global_position;
		proj.shoot(angle,0b10,DAMAGE_MIN,DAMAGE_MAX);
		angle += ANGLE;

func expunge_shell():
	var throw := preload("res://Scenes/Misc/Throwable.tscn").instance();
	throw.position = $CasingEject.global_position;
	throw.rotation = $CasingEject.global_rotation+deg2rad(30);
	throw.scale = Vector2(0.2,0.2);
	Projectile.add_child(throw);
	throw.starting_scale = Vector2(0.2,0.2);
	throw.ending_scale = Vector2(0.15,0.15);
	throw.throw(
			preload("res://Assets/Base/bullet.png"),
			Vector2(-50,180).rotated(global_rotation),
			preload("res://Assets/Sounds/shotgun_shell.wav"), true
	);
	throw.delay_z_reset(z_index+1,0.1);
	throw.set_pitch(rand_range(0.9,1.1));
