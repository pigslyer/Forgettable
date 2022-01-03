extends PopupPanel



func _on_Pause_about_to_show():
	get_tree().paused = true;

func _on_Pause_popup_hide():
	get_tree().paused = false;

func _on_quit_pressed():
	get_tree().quit();
