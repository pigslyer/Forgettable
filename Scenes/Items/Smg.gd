extends Gun

const DAMAGE_MIN = 30;
const DAMAGE_MAX = 45;

func _shoot():
	$Firerate.start();
	var inst = preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	Projectile.add_child(inst);
	inst.global_position = $FireFrom.global_position;
	inst.shoot(global_rotation,0b100,DAMAGE_MIN,DAMAGE_MAX);

func _on_Firerate_timeout():
	_use();

func _input(ev: InputEvent):
	if ev.is_action_released("lmb"):
		$Firerate.stop();
