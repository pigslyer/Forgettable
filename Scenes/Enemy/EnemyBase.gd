class_name Enemy
extends KinematicBody2D

const FRIC = 0.9;

const EYE_BASE_SCALE = 0.03;

const EYE_INTENSIFY = 0.6;
const EYE_INTENSIFY_SCALE = 0.1;

const DROP_OFFSET = 64;

export (int) var health = 100 setget set_health;
var dead: bool = false;

export (float) var accel = 200;
export (float) var max_speed = 100;
export (bool) var deaf = false;

# format: ["path:count"] for items
# keycards can't be droped. fuck you
export (Array,String,MULTILINE) var drops: Array;
var velocity: Vector2;

var path: PoolVector2Array;
var can_move: bool = true;

var alerted: bool = false setget set_alerted;
var detecting: bool = false setget set_detecting;

onready var detection: Area2D = $Animation/Body/Head/PlayerDetection;

func data_save():
	if dead: return [global_position];
	return null;

func data_load(data):
	if data is Array:
		set_health(-1,false);
		global_position = data[0];

# animations run this when an attack animation finishes
func attacked():
	pass;

func _physics_process(delta):
	
	if can_move && !dead:
		
		velocity *= FRIC;
		
		if !path.empty():
			velocity = (velocity+(path[0]-global_position).clamped(accel*delta)).clamped(max_speed);
			
			if (
					velocity.length()*delta > (global_position-path[0]).length() || 
					velocity.length_squared() < 0.5 ||
					(global_position-path[0]).length_squared() < 4
				):
				path.remove(0);
		
		if !(is_zero_approx(velocity.x) || is_zero_approx(velocity.y)):
			$Animation.vel = velocity/max_speed;
			global_rotation = velocity.angle();
		else: 
			velocity = Vector2.ZERO;
			$Animation/AnimationPlayer.playback_speed = 1;
		
		velocity = move_and_slide(velocity);
	
	if !(detecting || detection.get_overlapping_bodies().empty()):
		$PlayerWall.global_rotation = 0;
		$PlayerWall.cast_to = Groups.get_player().global_position-global_position;
		$PlayerWall.force_raycast_update();
		
		if !$PlayerWall.is_colliding():
			set_alerted(true);

func set_health(new_val: int, loud: bool = true):
	
	if new_val <= 0 && 0 < health:
		$PostDeathDisableAlert.start();
		can_move = false;
		dead = true;
		$Animation/Body/Head/Flicker.set_enabled(false);
		$Animation/Body/Head/Flicker2.set_enabled(false);
		Save.save_my_data(self);
		
		var split: PoolStringArray;
		for drop in drops:
			split = drop.split(":");
			Projectile.drop_item(ItemInventory.new(split[0],null,-Vector2.ONE,int(split[1])),global_position+Vector2(rand_range(-DROP_OFFSET,DROP_OFFSET),rand_range(-DROP_OFFSET,DROP_OFFSET)));
		
		if loud:
			Music.play_sfx(
				[
					preload("res://Assets/JakobNoises/DyingMoan1.wav"),
					preload("res://Assets/JakobNoises/DyingMoan2.wav"),
					preload("res://Assets/JakobNoises/DyingChoke.wav"),
				][randi()%3],
				rand_range(0.8,0.9),5
			)
	elif new_val < health && is_inside_tree():
		if loud:
			Music.play_sfx(
				[
					preload("res://Assets/JakobNoises/PaintGruntHighLong.wav"),
					preload("res://Assets/JakobNoises/PaintGruntNormal.wav")
				][randi()%2],
				rand_range(0.8,0.9),2
			);
		set_alerted(true);
	
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
		
		if state:
			var tween := Tween.new();
			add_child(tween);
			
			# intensity up
			tween.interpolate_property(
					$Animation/Body/Head/Flicker,"texture_scale",
					null, EYE_INTENSIFY_SCALE, EYE_INTENSIFY,
					Tween.TRANS_SINE
			);
			tween.interpolate_property(
					$Animation/Body/Head/Flicker2,"texture_scale",
					null, EYE_INTENSIFY_SCALE, EYE_INTENSIFY,
					Tween.TRANS_SINE
			);
			
			# intensity down
			tween.interpolate_property(
					$Animation/Body/Head/Flicker,"texture_scale",
					EYE_INTENSIFY_SCALE,EYE_BASE_SCALE, EYE_INTENSIFY,
					Tween.TRANS_SINE, 2, EYE_INTENSIFY
			);
			tween.interpolate_property(
					$Animation/Body/Head/Flicker2,"texture_scale",
					EYE_INTENSIFY_SCALE,EYE_BASE_SCALE, EYE_INTENSIFY,
					Tween.TRANS_SINE, 2, EYE_INTENSIFY
			);
			
			tween.interpolate_callback(tween,EYE_INTENSIFY*2,"queue_free");
			tween.start();



func _on_PostDeathDisableAlert_timeout():
	queue_free();
