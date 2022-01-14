extends PopupPanel



func _on_YouDied_about_to_show():
	get_tree().paused = true;


func _on_YouDied_popup_hide():
	get_tree().paused = false;


func _on_Button2_pressed():
	get_tree().reload_current_scene();
