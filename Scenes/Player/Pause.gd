extends PopupPanel



func _on_Pause_about_to_show():
	get_tree().paused = true;
	$VBoxContainer/SliderMusic.value = AudioServer.get_bus_volume_db(1);
	$VBoxContainer/SliderSFX.value = AudioServer.get_bus_volume_db(2);

func _on_Pause_popup_hide():
	get_tree().paused = false;
	AudioServer.set_bus_volume_db(1,$VBoxContainer/SliderMusic.value);
	AudioServer.set_bus_volume_db(2,$VBoxContainer/SliderSFX.value);
	

func _on_quit_pressed():
	# otherwise ^^ complains we're not in the tree
	set_block_signals(true);
	get_tree().quit();
	

func _on_restart_pressed():
	get_tree().reload_current_scene();
