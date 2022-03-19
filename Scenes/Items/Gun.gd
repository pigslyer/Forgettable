class_name Gun
extends ItemBase

const HOLDUP_TIME = 0.4;
const UNHELDUP_TIME = 0.4;

export (String) var ammo_type;
export (int) var ammo_max;
var ammo: int = 0;

# contains shys paired with true. useful to remove duplicates
var _aware: Dictionary;

func _shoot():
	pass;

func _reload():
	pass;

func _empty():
	pass;

func _unhandled_input(ev: InputEvent):
	if ev.is_action_pressed("reload"):
		reload();

func reload():
	if $ReloadTime.is_stopped() && ammo < ammo_max && 0 < Groups.get_player().get_waffle().count_item(ammo_type):
		$ReloadTime.start();
		$Reload.play();
		_reload();
		Groups.get_player().can_inventory = false;

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
		
		if ammo > 0:
			_shoot();
			
			for enemy in $Noise.get_overlapping_bodies():
				if !enemy.deaf:
					enemy.alerted = true;
			
			# EVERYONE who knew it was shot forgets that
			if !$ResetKnows.is_stopped():
				$ResetKnows.stop();
				_on_ResetKnows_timeout();
			
			
			update_hud();
		
		else:
			$Empty.play();
			_inform_empty();
			_empty();

func _inform_empty():
	$ResetKnows.start();
	
	for shy in $Noise.get_overlapping_bodies():
		if shy.collision_layer & 32 != 0:
			_aware[shy] = true;
			shy.knows_gun_empty = true;

func _hud_primary():
	return str(ammo,"/",Groups.get_player().get_waffle().count_item(ammo_type));


func _on_ReloadTime_timeout():
	ammo += Groups.get_player().get_item(ammo_type,ammo_max-ammo);
	update_hud();
	Groups.get_player().can_inventory = true;


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
