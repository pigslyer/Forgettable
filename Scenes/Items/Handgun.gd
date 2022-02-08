extends Gun

const DAMAGE_MIN = 20;
const DAMAGE_MAX = 40;

func _shoot():
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	Projectile.add_child(inst);
	inst.global_position = $FireFrom.global_position;
	inst.shoot(global_rotation,0b100,DAMAGE_MIN,DAMAGE_MAX);
	
