extends Popup

const x = 30;
const y = 2;

func _on_Options_about_to_show():
	$Panel/VBoxContainer/Master.value = pow(10,bus_vol("Master")/x+y);
	$Panel/VBoxContainer/Music.value = pow(10,bus_vol("Music")/x+y);
	$Panel/VBoxContainer/SFX.value = pow(10,bus_vol("SFX")/x+y);

func bus_vol(bus: String):
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus));

func _on_Options_popup_hide():
	Save.global_save();


func _on_value_changed(volume: float, bus: String):
	# thanks fiza
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus),x*(log(volume)/log(10)-y));


func _on_Button_pressed():
	hide();
