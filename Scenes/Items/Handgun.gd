extends Gun

const DAMAGE_MIN = 75;
const DAMAGE_MAX = 120;

func _shoot():
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	Projectile.add_child(inst);
	inst.global_position = $FireFrom.global_position;
	inst.shoot(global_rotation,0b100,DAMAGE_MIN,DAMAGE_MAX);
	
