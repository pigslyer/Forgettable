extends Control

signal fade_rain

func _ready():
	$VBoxContainer/Button4.disabled = Save.get_saves().empty();
	if $VBoxContainer/Button4.disabled:
		$VBoxContainer/Button.grab_focus();
	else:
		$VBoxContainer/Button4.grab_focus();
	
	Music.play_music(null);
	
	if Save.global_save_exists():
		Save.global_load();
	else:
		Save.global_save();
	
	Music.music_in_game(false);
	
	if Save.ending == Save.ENDS.NASIF:
		$Label.text = "Unforgettable";

func _on_Button4_pressed():
	$Fade.blocking = true;
	yield($Fade,"finished_fade");
	
	Save.load_game(Save.get_saves()[0].get_basename());

func _on_Button_pressed():
	$Fade.blocking = true;
	yield($Fade,"finished_fade");
	
	Save.cur_state = Save.STATE.PIPE;
	get_tree().change_scene("res://Scenes/Main/Main.tscn");

func _on_Button2_pressed():
	$LoadGame.popup();


func _on_Button3_pressed():
	$Fade.blocking = true;
	yield($Fade,"finished_fade");
	yield(get_tree().create_timer(0.7),"timeout");
	
	get_tree().quit();

var not_shot := true;

func _input(ev):
	if ev.is_action_pressed("lmb") && not_shot:
		not_shot = false;
		$Shoot.play();
		emit_signal("fade_rain");
		yield(get_tree().create_timer(0.1),"timeout");
		$Casing.play();
		yield(get_tree().create_timer(0.3),"timeout");
		$Dying.play();
		$Falling.play();
		yield(get_tree().create_timer(1.8),"timeout");
		$Fade.blocking = false;
		Music.play_music(preload("res://Assets/Music/MenuTheme.wav"))
		
		yield($Fade,"finished_fade");
		$Fade/Label.hide();
		$Cutscene1.start();

func _unhandled_input(ev):
	if ev.is_action_pressed("ui_cancel"):
		if $Fade.blocking:
			get_tree().quit();
		else:
			$Fade.blocking = true;
			yield($Fade,"finished_fade");
			get_tree().quit();
	
	elif has_focus() != null:
		if ev.is_action_pressed("ui_up"):
			$VBoxContainer/Button3.grab_focus();
		elif ev.is_action_pressed("ui_down"):
				if $VBoxContainer/Button4.disabled:
					$VBoxContainer/Button.grab_focus();
				else:
					$VBoxContainer/Button4.grab_focus();
		


func _on_Addons_pressed():
	pass # Replace with function body.


func _on_Button5_pressed():
	$Options.popup();


func _on_Cutscene1_timeout():
	if Save.ending != Save.ENDS.NONE:
		$AnimationPlayer.play("Cutscene1");


func _on_Cutscene2_timeout():
	if Save.ending == Save.ENDS.NASIF:
		$AnimationPlayer.play("Cutscene2");
