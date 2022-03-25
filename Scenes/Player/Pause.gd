extends Popup

export (NodePath) var loadgame;

func _on_Pause_about_to_show():
	get_tree().paused = true;
	# button 2 is save button
	$Panel/VBoxContainer/Button2.disabled = !Save.can_save();

func _on_Pause_popup_hide():
	get_tree().paused = false;
	Save.global_save();
	

func _on_quit_pressed():
	$ConfirmQuit.popup();


func _on_save_pressed():
	$Save.popup();


func _on_load_pressed():
	get_node(loadgame).popup();


func _on_Button5_pressed():
	$Options.popup();


func _on_Quit_confirmed():
	get_tree().paused = false;
	get_tree().change_scene("res://Scenes/Main/MainMenu.tscn");
