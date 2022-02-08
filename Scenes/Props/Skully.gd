extends Node2D

const TURN_TIME = 0.3;

func _ready():
	set_physics_process(false);

func pop_out():
	$AnimationPlayer.play("Reveal");

func start_following():
	$Tween.interpolate_property($Skully,"rotation",null,($Skully.global_position-Groups.get_player().global_position).angle(),TURN_TIME);
	$Tween.interpolate_callback(self,TURN_TIME,"set_physics_process",true);
	$Tween.start();
	
	yield($Tween,"tween_all_completed");
	$Tween.queue_free();

func _physics_process(_delta):
	$Skully.look_at(Groups.get_player().global_position);
