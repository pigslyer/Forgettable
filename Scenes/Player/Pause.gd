extends Popup

func _on_Pause_about_to_show():
	get_tree().paused = true;
	# button 2 is save button
	$Panel/VBoxContainer/Button2.disabled = !Save.can_save();
	$Panel/VBoxContainer/SliderMusic.value = AudioServer.get_bus_volume_db(1);
	$Panel/VBoxContainer/SliderSFX.value = AudioServer.get_bus_volume_db(2);

func _on_Pause_popup_hide():
	get_tree().paused = false;
	AudioServer.set_bus_volume_db(1,$Panel/VBoxContainer/SliderMusic.value);
	AudioServer.set_bus_volume_db(2,$Panel/VBoxContainer/SliderSFX.value);
	

func _on_quit_pressed():
	# otherwise ^^ complains we're not in the tree
	set_block_signals(true);
	get_tree().quit();
	

func _on_restart_pressed():
	Save.save_data = {};
	get_tree().reload_current_scene();


func _on_save_pressed():
	$Save.popup();


func _on_load_pressed():
	$LoadGame.popup();
