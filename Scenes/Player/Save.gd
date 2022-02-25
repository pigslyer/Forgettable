extends Popup

signal saved;

const NEW_SAVE = null;

onready var list: ItemList = $Panel/VBoxContainer/List;

func _on_Save_about_to_show():
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = true;
	list.clear();
	
	var saves := Save.get_saves();
	
	for save in saves:
		list.add_item(save.get_basename());
		list.set_item_metadata(list.get_item_count()-1,save.get_basename());


func _on_List_item_activated(index):
	Save.save_game(list.get_item_metadata(index));
	emit_signal("saved");
	hide();


func _on_Button2_pressed():
	hide();


func _on_Button_pressed():
	$NewSave.popup();


func _on_List_item_selected(_index):
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = false;


func _on_List_nothing_selected():
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = true;
	list.unselect_all();


func _on_Overwrite_pressed():
	_on_List_item_activated(list.get_selected_items()[0]);
