extends Node2D

const MAX_TURN_ANGLE = deg2rad(35);
const TURN_MULT = 1.6;
const HAND_FOLLOW = 0.85;
const BODY_AUTO_ADJUST_MULT = 0.95;

var walking := false setget set_walking;
var sprinting := false setget set_sprinting;
var follow_mouse: bool setget set_follow_mouse;
var speed: float setget set_speed;
var equipped: bool = false;
var has_gun: bool = false;
var equipped_item: ItemBase = null;

onready var hand = $Body/ArmRight/Hand;

func _physics_process(delta):
	
	var angle := (get_global_mouse_position()-global_position).angle();
	
	if equipped || abs(angle-rotation) >= MAX_TURN_ANGLE:
		rotation = wrapf(rotation-(angle-rotation)*delta*TURN_MULT*sign(abs(angle-rotation)-PI),-PI,PI);
	
	$Body/Head.global_rotation = angle;
	
	if !(sprinting || walking):
		$Body.rotation *= BODY_AUTO_ADJUST_MULT;
	
	if equipped && (!(sprinting || walking) || $PlayerWalk.type != ItemBase.Anim.TWO_HANDED):
		if has_gun:
			hand.look_at(get_global_mouse_position());
		else:
			hand.global_rotation = lerp_angle(hand.global_rotation,angle,_calc_weight(hand.global_rotation,angle)*HAND_FOLLOW);
		
	

func set_walking(state: bool):
	walking = state;
	$PlayerWalk.walking = state;
	if state:
		global_rotation = (get_global_mouse_position()-global_position).angle();

func set_sprinting(state: bool):
	sprinting = state;
	$PlayerWalk.sprinting = state;

func set_speed(value: float):
	$PlayerWalk.playback_speed = value;


func set_follow_mouse(state: bool):
	set_physics_process(state);

func _calc_weight(from: float, to: float) -> float:
	return abs(atan2(sin(from-to),cos(from-to)));

func _on_Player_equipped_new():
	equipped_item = Groups.get_player().equipped_item;
	equipped = equipped_item != null;
	has_gun = equipped_item is Gun;
