extends KinematicBody2D

const VELOCITY = 64*8;

const DAMAGE_MIN = 50;
const DAMAGE_MAX = 160;

var velocity: Vector2;

func shoot(dir: float):
	velocity = Vector2(VELOCITY,0).rotated(dir);
	global_rotation = dir;
	$ShotLight.pre_proc();

func _physics_process(delta):
	var data: KinematicCollision2D = move_and_collide(velocity*delta);
	
	if data != null:
		
		# we collided with an enemy
		if data.collider.collision_layer & 0b100 != 0:
			var enemy = data.collider;
			enemy.health -= rand_range(DAMAGE_MIN,DAMAGE_MAX);
			$Sparks.process_material.color = Color.crimson;
		else:
			$Sparks.process_material.color = Color(0x9bffffff);
		
		
		set_physics_process(false);
		
		$Sprite.hide();
		rotation = 0;
		$Sparks.process_material.direction = Vector3(data.normal.x,data.normal.y,0);
		
		yield(get_tree(),"physics_frame");
		$Sparks.emitting = true;
		
		yield(get_tree().create_timer($Sparks.lifetime),"timeout");
		$ShotLight.set_enabled(false);
		
		yield(get_tree().create_timer(1),"timeout");
		queue_free();
	
