class_name Gun
extends ItemBase

const HOLDUP_TIME = 0.4;
const UNHELDUP_TIME = 0.4;

export (String) var ammo_type;
export (int) var ammo_max;
var ammo: int = 0;

export (int) var jam_base = 5;

export (int) var unjam_min;
export (int) var unjam_max;
export (int) var jam_inc_max;
export (int) var jam_inc_min;
var jam_chance: int = jam_base;
var jams: int = 0;

# contains shys paired with true. useful to remove duplicates
var _aware: Dictionary;

func _shoot():
	pass;

func reload():
	if jams > 0 && $UnjamTime.is_stopped():
		$UnjamTime.start();
		$Unjam.play();
	elif jams == 0 && $ReloadTime.is_stopped():
		$ReloadTime.start();
		$Reload.play();

func equip():
	_on_ReloadTime_timeout();
	.equip();

func unequip():
	if ammo > 0:
		var data = ItemInventory.new(ammo_type);
		data.count = ammo;
		Groups.get_player().add_item(data);
		if data.count > 0:
			Projectile.drop_item(data,Groups.get_player().global_position);
	
	
	# inform all aware people that there's no more gun
	_on_ResetKnows_timeout();
	for shy in $PointingGun.get_overlapping_bodies():
		shy.pointing_gun_at = false;

	.unequip();

func _use():
	if $ReloadTime.is_stopped():
	
		if jams != 0:
			$Jammed.play();
		
		elif ammo > 0:
			if randi()%100 < jam_chance:
				$JamReset.stop();
				jams = int(rand_range(unjam_min,unjam_max));
				Groups.say_line("Jammed!");
				
				_inform_empty();
				
			else:
				jam_chance += int(rand_range(jam_inc_min,jam_inc_max));
				ammo -= 1;
				_shoot();
				
				$FireFrom/Flash.pre_proc();
				$Shoot.play();
				for enemy in $Noise.get_overlapping_bodies():
					if !enemy.deaf:
						enemy.alerted = true;
				
				# EVERYONE who knew it was shot forgets that
				if !$ResetKnows.is_stopped():
					$ResetKnows.stop();
					_on_ResetKnows_timeout();
				
				$JamReset.start();
			
			update_hud();
		
		else:
			$Empty.play();
			_inform_empty();

func _inform_empty():
	$ResetKnows.start();
	
	for shy in $Noise.get_overlapping_bodies():
		if shy.collision_layer & 32 != 0:
			_aware[shy] = true;
			shy.knows_gun_empty = true;

func _hud_primary():
	if jams > 0: return "!Unjam (R)";
	return str(ammo,"/",Groups.get_player().get_waffle().count_item(ammo_type));


func _on_ReloadTime_timeout():
	ammo += Groups.get_player().get_item(ammo_type,ammo_max-ammo);
	update_hud();

func _on_UnjamTime_timeout():
	jams -= 1;
	if jams == 0:
		jam_chance = jam_base;
		_on_ReloadTime_timeout();

func _on_JamReset_timeout():
	jam_chance = jam_base;


# everyone who was made aware that the gun is empty is now made unaware
func _on_ResetKnows_timeout():
	for shy in _aware.keys():
		shy.knows_gun_empty = false;
	
	_aware.clear();

# make aware that gun is pointed at him
func _on_PointingGun_body_entered(body):
	yield(get_tree().create_timer(HOLDUP_TIME),"timeout");
	if $PointingGun.overlaps_body(body):
		body.pointing_gun_at = true;

# make aware that gun isn't pointed at him
func _on_PointingGun_body_exited(body):
	yield(get_tree().create_timer(UNHELDUP_TIME),"timeout");
	if !$PointingGun.overlaps_body(body):
		body.pointing_gun_at = false;
