extends KinematicBody2D

const VELOCITY = 64*8;

var velocity: Vector2;

func shoot(dir: float):
	velocity = Vector2(VELOCITY,0).rotated(dir);
	global_rotation = dir;
	$ShotLight.pre_proc();

func _physics_process(delta):
	var data: KinematicCollision2D = move_and_collide(velocity*delta);
	
	if data != null:
		# we collided with something that *isn't* an enemy
		if data.collider.collision_layer ^ 0b100 != 0:
			$Sprite.hide();
			$Sparks.emitting = true;
			$Sparks.process_material.direction = Vector3(data.normal.x,data.normal.y,0);
			set_physics_process(false);
			yield(get_tree().create_timer($Sparks.lifetime),"timeout");
			$ShotLight.set_enabled(false);
			yield(get_tree().create_timer(1),"timeout");
			queue_free();
