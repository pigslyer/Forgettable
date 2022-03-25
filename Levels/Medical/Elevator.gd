extends Area2D

func _ready():
	set_physics_process(false);

func _physics_process(_delta):
	var cam := Groups.get_player().get_camera();
	
	if is_zero_approx(cam.offset.y):
		cam.offset.y = rand_range(-2,2);
	else:
		cam.offset *= 0.6;
	

func _on_Elevator_body_entered(body: Player):
	body.set_control(false);
	
	if $Door.open:
		$Door._on_open(true);
	
	$Tween.interpolate_property(body.get_camera(),"zoom",null,Vector2(3,3),10,Tween.TRANS_CUBIC,Tween.EASE_IN);
	$Tween.start();
	
	$Elevator.play();
	Music.play_music(load("res://Assets/Sounds/scpradio0.ogg"))
	set_physics_process(true);
	
	yield(get_tree().create_timer(6),"timeout");
	body.hide_hud();
	
	body.get_node("PassiveLight").remove_from_group(Flicker.GROUP_LIGHTS);
	$Door/WhenClosed/OuterOpen/Flicker.remove_from_group(Flicker.GROUP_LIGHTS);
	
	get_tree().call_group(Flicker.GROUP_LIGHTS,"set_enabled",false);
	get_tree().call_group(FlickerBlinks.GROUP_BLINKS,"set_blink",false);
	
	yield(get_tree().create_timer(3),"timeout");
	$CanvasLayer/Fade.blocking = true;
	
	yield($CanvasLayer/Fade,"finished_fade");
	yield(get_tree().create_timer(0.5),"timeout");
	
	get_tree().change_scene("res://Levels/Endings/Endings.tscn");
	
