class_name Enemy
extends KinematicBody2D

const FRIC = 0.9;

export (int) var health = 100 setget set_health;
var dead: bool = false;

export (float) var accel = 200;
export (float) var max_speed = 100;
export (bool) var deaf = false;
var velocity: Vector2;

var path: PoolVector2Array;
var can_move: bool = true;

var alerted: bool = false setget set_alerted;
var detecting: bool = false setget set_detecting;

onready var detection: Area2D = $Animation/Body/Head/PlayerDetection;

# animations run this when an attack animation finishes
func attacked():
	pass;

func _physics_process(delta):
	
	if can_move:
		
		velocity *= FRIC;
		
		if !path.empty():
			velocity = (velocity+(path[0]-global_position).clamped(accel*delta)).clamped(max_speed);
			
			if (
					velocity.length()*delta > (global_position-path[0]).length() || 
					velocity.length_squared() < 0.5 ||
					(global_position-path[0]).length_squared() < 4
				):
				path.remove(0);
		
		$Animation.vel = velocity/max_speed;
		
		if !(is_zero_approx(velocity.x) || is_zero_approx(velocity.y)):
			global_rotation = velocity.angle();
		else: velocity = Vector2.ZERO;
		
		velocity = move_and_slide(velocity);
	
	if !(detecting || detection.get_overlapping_bodies().empty()):
		$PlayerWall.global_rotation = 0;
		$PlayerWall.cast_to = Groups.get_player().global_position-global_position;
		$PlayerWall.force_raycast_update();
		
		if !$PlayerWall.is_colliding():
			set_alerted(true);

func set_health(new_val: int):
	
	if new_val <= 0 && 0 < health:
		$PostDeathDisableAlert.start();
		can_move = false;
		set_physics_process(false);
		$Animation.vel = Vector2.ZERO;
		dead = true;
		$Animation/Body/Head/Flicker.set_enabled(false);
		$Animation/Body/Head/Flicker2.set_enabled(false);
		$GruntDeath.play();
	else:
		$GruntPain.play();
	
	health = new_val;
	

func set_alerted(state: bool):
	if !(dead && state):
		
		alerted = state;
		
		if !state:
			path = [];
		
		set_detecting(state);

func set_detecting(state: bool):
	if detecting != state:
		Save.detecting += 1 if state else -1;
		detecting = state;


