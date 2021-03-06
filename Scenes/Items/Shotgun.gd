extends Gun

const DAMAGE_MIN = 13;
const DAMAGE_MAX = 18;

const ANGLE = deg2rad(2.3);
const PROJECTILES = 8;

var reloading: bool = false;
var can_do_stuff: bool = true;

func _use():
	if can_do_stuff:
		# stop reload
		if reloading:
			reloading = false;
			can_do_stuff = false;
			$AnimationPlayer.play("ReloadPump");
			yield($AnimationPlayer,"animation_finished");
			can_do_stuff = true;
		
		elif $ShootTimer.is_stopped():
			._use();

func reload():
	if !reloading && $ShootTimer.is_stopped() && can_do_stuff:
		.reload();

func _shoot():
	$AnimationPlayer.play("Shoot");
	$ShootTimer.start();

func _reload():
	Groups.get_player().can_inventory = false;
	$AnimationPlayer.play("ReloadGetShells");
	can_do_stuff = false;
	
	yield($AnimationPlayer,"animation_finished");
	
	reloading = true;
	
	while reloading && ammo < ammo_max && Groups.get_player().get_waffle().count_item(ammo_type) > 0:
		$AnimationPlayer.play("ReloadLoadShell");
		yield($AnimationPlayer,"animation_finished");
		# ensures that at least 1 shell is loaded
		can_do_stuff = true;
	
	Groups.get_player().can_inventory = true;
	if reloading:
		can_do_stuff = false;
		$AnimationPlayer.play("ReloadPump");
		
		yield($AnimationPlayer,"animation_finished");
		can_do_stuff = true;
		reloading = false;

func shell_loaded():
	ammo += Groups.get_player().get_item(ammo_type,1);
	update_hud();

func _equip():
	._equip();
	ammo += Groups.get_player().get_item(ammo_type,ammo_max-ammo);
	update_hud();

# funny
func _on_ReloadTime_timeout():
	pass;

func shoot():
	ammo -= 1;
	var angle = $FireFrom.global_rotation-(ANGLE*PROJECTILES/2);
	var proj;
	
	for i in PROJECTILES:
		proj = preload("res://Scenes/Misc/ShotgunPellet.tscn").instance();
		Projectile.add_child(proj);
		proj.global_position = $FireFrom.global_position;
		proj.shoot(angle,0b100,DAMAGE_MIN,DAMAGE_MAX);
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
