extends Node2D

export (float) var run_speed = 1.2;

export (String) var anim_idle = "idle";
export (String) var anim_walk = "walk";

var vel: Vector2 setget set_vel;

func set_vel(new_vel: Vector2):
	
	
	$AnimationPlayer.play(anim_idle if is_zero_approx(new_vel.x) && is_zero_approx(new_vel.y) else anim_walk);
	$AnimationPlayer.playback_speed = new_vel.length()*run_speed;
	


