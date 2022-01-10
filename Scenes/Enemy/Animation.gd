extends Node2D

export (float) var run_speed = 1.2;

var vel: Vector2 setget set_vel;

func set_vel(new_vel: Vector2):
	
	$AnimationPlayer.play("idle" if is_zero_approx(new_vel.x) && is_zero_approx(new_vel.y) else "walk");
	$AnimationPlayer.playback_speed = new_vel.length()*run_speed;
	


