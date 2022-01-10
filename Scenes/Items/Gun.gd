class_name Gun
extends ItemBase

export (PackedScene) var ammo_type;
export (int) var ammo_max;
var ammo: int = 0;

export (int) var jam_base = 5;

export (int) var unjam_min;
export (int) var unjam_max;
export (int) var jam_inc_max;
export (int) var jam_inc_min;
var jam_chance: int = jam_base;
var jams: int = 0;

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
		var data = ItemInventory.new(ammo_type.resource_path);
		data.count = ammo;
		Groups.get_player().add_item(data);
		if data.count > 0:
			Projectile.drop_item(data);
	.unequip();

func _use():
	if jams != 0:
		$Jammed.play();
	
	elif ammo > 0:
		if randi()%100 < jam_chance:
			$JamReset.stop();
			jams = int(rand_range(unjam_min,unjam_max));
			Groups.say_line("Jammed!");
			
			for carer in $GunEmpty.get_overlapping_bodies():
				carer.heard_empty();
		else:
			jam_chance += int(rand_range(jam_inc_min,jam_inc_max));
			ammo -= 1;
			_shoot();
			
			$Shoot.play();
			for enemy in $Noise.get_overlapping_bodies():
				enemy.alerted = true;
			
			$JamReset.start();
		
		update_hud();
	
	else:
		$Empty.play();
		
		for carer in $GunEmpty.get_overlapping_bodies():
			carer.heard_empty();


func _hud_primary():
	if jams > 0: return "!Unjam (R)";
	return str(ammo,"/",Groups.get_player().get_waffle().count_item(ammo_type.resource_path));


func _on_ReloadTime_timeout():
	ammo += Groups.get_player().get_item(ammo_type.resource_path,ammo_max-ammo);
	update_hud();

func _on_UnjamTime_timeout():
	jams -= 1;
	if jams == 0:
		jam_chance = jam_base;
		update_hud();

func _on_JamReset_timeout():
	jam_chance = jam_base;
