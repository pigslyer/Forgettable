extends KinematicBody2D

const VELOCITY_IN_CELLS = 8;

var velocity: Vector2;
var damage_min: int; var damage_max: int;
var damage_target: int;

func shoot(dir: float, target_layer: int, dmg_min: int, dmg_max: int, vel: float = VELOCITY_IN_CELLS):
	velocity = Vector2(vel*64,0).rotated(dir);
	global_rotation = dir;
	$ShotLight.pre_proc(); damage_min = dmg_min; damage_max = dmg_max;
	collision_mask = 0b1 | target_layer; damage_target = target_layer;

func _physics_process(delta):
	var data: KinematicCollision2D = move_and_collide(velocity*delta);
	
	if data != null:
		
		# we collided with an enemy
		if data.collider.collision_layer & damage_target != 0:
			var enemy = data.collider;
			enemy.health -= rand_range(damage_max,damage_max);
			$Sparks.process_material.color = Color.crimson;
		else:
			$Sparks.process_material.color = Color(0x9bffffff);
		
		
		set_physics_process(false);
		
		$Sprite.hide();
		rotation = 0;
		set_deferred("collision_mask",0);
		$Sparks.process_material.direction = Vector3(data.normal.x,data.normal.y,0);
		
		yield(get_tree(),"physics_frame");
		$Sparks.emitting = true;
		
		yield(get_tree().create_timer($Sparks.lifetime),"timeout");
		$ShotLight.set_enabled(false);
		
		yield(get_tree().create_timer(1),"timeout");
		queue_free();
	
