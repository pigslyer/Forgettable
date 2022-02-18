extends Popup


func _on_NewSave_about_to_show():
	$Panel/LineEdit.text = "";
	$Panel/HBoxContainer/Save.disabled = true;


func _on_LineEdit_text_changed(new_text: String):
	$Panel/HBoxContainer/Save.disabled = !new_text.is_valid_filename();


func _on_LineEdit_text_entered(_new_text):
	_on_Save_pressed();


func _on_Save_pressed():
	Save.save_game($Panel/LineEdit.text);
	hide();


func _on_Cancel_pressed():
	hide();
