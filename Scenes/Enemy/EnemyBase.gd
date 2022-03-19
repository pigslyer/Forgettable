class_name Enemy
extends KinematicBody2D

# if the enemy is in a Group:[name] then they'll automatically alert their whole group
# when they become alerted
var my_groups: PoolStringArray;

const FLINCH_CHANCE = 0.3;
const FRIC = 0.9;

const EYE_BASE_SCALE = 0.03;

const EYE_INTENSIFY = 0.6;
const EYE_INTENSIFY_SCALE = 0.1;

const DROP_OFFSET = 64;

enum BODIES{
	SCIENTIST,
	SECURITY,
	PRISONER
};

export (BODIES) var body;

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

func _ready():
	
	$Animation/Body.texture = [
		preload("res://Assets/Base/body_main.png"), 
		preload("res://Assets/Base/body_security.png"),
		preload("res://Assets/Player/player_body.png"),
	][body];
	
	$Animation/Body/Head.texture = [
		preload("res://Assets/Enemies/head1.png"),
		preload("res://Assets/Enemies/head2.png"),
		preload("res://Assets/Enemies/head3.png"),
		preload("res://Assets/Enemies/head4.png"),
	][str(get_path()).hash()%4];
	
	for group in get_groups():
		if group.begins_with("Group:"):
			my_groups.append(group);
	
	# so they each have a unique one
	material = material.duplicate();
	

# animations run this when an attack animation finishes
func attacked():
	pass;

func _physics_process(delta):
	
	if can_move && !dead && $Flinching.is_stopped():
		
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
		$PlayerWall.cast_to = Groups.get_player_pos()-global_position;
		$PlayerWall.force_raycast_update();
		
		if !$PlayerWall.is_colliding():
			set_alerted(true);

const DISSOLVE_SPEED = 0.6;
const STEPS = 10;

func set_health(new_val: int, loud: bool = true):
	
	if new_val <= 0 && 0 < health:
		$PostDeathDisableAlert.start();
		health = new_val;
		can_move = false;
		dead = true;
		$Animation/Body/Head/Flicker.set_enabled(false);
		$Animation/Body/Head/Flicker2.set_enabled(false);
		Save.save_my_data(self);
		$CollisionShape2D.set_deferred("disabled",true);
		
		var split: PoolStringArray;
		for drop in drops:
			split = drop.split(":");
			if split[0] == "item":
				Projectile.drop_item(ItemInventory.new("res://Scenes/Items/"+split[1],null,-Vector2.ONE,int(split[2])),global_position+Vector2(rand_range(-DROP_OFFSET,DROP_OFFSET),rand_range(-DROP_OFFSET,DROP_OFFSET)));
		
		if loud:
			Music.play_sfx(
				[
					preload("res://Assets/JakobNoises/DyingMoan1.wav"),
					preload("res://Assets/JakobNoises/DyingMoan2.wav"),
					preload("res://Assets/JakobNoises/DyingChoke.wav"),
				][randi()%3],
				rand_range(0.8,0.9),20
			);
			
			$Gibs.emitting = true;
			for step in STEPS:
				material.set_shader_param("percent",float(step)/STEPS*2);
				yield(get_tree().create_timer(DISSOLVE_SPEED/STEPS),"timeout");
			
		
		queue_free();
	
	# this should be painstate chance
	elif new_val < health && is_inside_tree():
		if loud:
			if FLINCH_CHANCE > rand_range(0,1):
				Music.play_sfx(
					[
						preload("res://Assets/JakobNoises/PaintGruntHighLong.wav"),
						preload("res://Assets/JakobNoises/PaintGruntNormal.wav")
					][randi()%2],
					rand_range(0.8,0.9),7
				);
				$Flinching.start();
		set_alerted(true);
	
	health = new_val;


func set_alerted(state: bool, grouped: bool = false):
	# can't hear through areas unless they can go through
	if state && Groups.get_simple_path_player(global_position).empty():
		pass;
	
	elif !(dead && state):
		if !my_groups.empty() && !grouped && state:
			for group in my_groups:
				get_tree().call_group(group,"set_alerted",true,true);
				remove_from_group(group);
			
			my_groups = [];
		
		alerted = state;
		
		if !state:
			path = [];
		
		set_detecting(state);

func set_detecting(state: bool):
	if detecting != state:
		Save.detecting += 1 if state else -1;
		detecting = state;


func _on_PostDeathDisableAlert_timeout():
	queue_free();
