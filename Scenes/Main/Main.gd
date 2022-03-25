extends Node2D

onready var tf := $CanvasLayer/Fade/TextFade;
var skipped := false;

func _ready():
	$Player.set_health(40,false);
	$Player.set_control(false);
	$Player/PassiveLight.set_enabled(false);
	Music.music_in_game(true);
	Save.cur_objective = "Reconsider your life?";
	
	tf.set_text("At some point in time, deep within a place where angels fear to tread...");
	yield(tf,"finished_line");
	
	if skipped: 
		$CanvasLayer/Fade/TextFade.queue_free();
		return;
	
	tf.set_text("A disaster has struck the facility. Monsters from another world.");
	yield(tf,"finished_line");
	
	if skipped: 
		$CanvasLayer/Fade/TextFade.queue_free();
		return;
	
	tf.set_text("Somewhere far above you, it's raining. Time to wake up.");
	yield(tf,"finished_line");
	
	if skipped:
		$CanvasLayer/Fade/TextFade.queue_free();
		return;
	
	$CanvasLayer/Fade.set_blocking(false);
	yield($CanvasLayer/Fade,"finished_fade");
	
	_fin();

func _input(ev):
	if ev is InputEventKey:
		$CanvasLayer/Fade.set_blocking(false);
		yield($CanvasLayer/Fade,"finished_fade");
		_fin();

func _fin():
	$CanvasLayer.queue_free();
	$Player.set_control(true);
	$Player/PassiveLight.set_enabled(true);
	set_process_input(false);
	$Player.tutorial_show("Use WASD to move.",["ui_up","ui_left","ui_right","ui_down"]);
