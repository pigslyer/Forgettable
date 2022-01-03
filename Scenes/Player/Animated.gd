extends Node2D

const MAX_TURN_ANGLE = deg2rad(35);
const TURN_MULT = 1.6;
const HAND_FOLLOW = 0.6;

var walking := false setget set_walking;
var sprinting := false;
var follow_mouse: bool setget set_follow_mouse;
var speed: float setget set_speed;

func _physics_process(delta):
	
	var angle := (get_global_mouse_position()-global_position).angle();
	
	if abs(angle-rotation) >= MAX_TURN_ANGLE:
		rotation = wrapf(rotation-(angle-rotation)*delta*TURN_MULT*sign(abs(angle-rotation)-PI),-PI,PI);
	
	$Body/Head.global_rotation = angle;
	
	if !sprinting:
		$Body/RightHand.look_at(get_global_mouse_position());
	elif walking && sprinting:
		$Body/RightHand.rotation = 0;


func set_walking(state: bool):
	walking = state;
	if state:
		$AnimationPlayer.play("Walk");
		global_rotation = (get_global_mouse_position()-global_position).angle();
	else:
		$AnimationPlayer.stop();
		$Body.rotation = 0;
		$Body/Head.rotation = 0;


func set_speed(value: float):
	$AnimationPlayer.playback_speed = value;


func set_follow_mouse(state: bool):
	set_physics_process(state);
