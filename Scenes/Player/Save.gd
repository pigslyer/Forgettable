extends Popup

const NEW_SAVE = null;

onready var list: ItemList = $Panel/VBoxContainer/List;

func _on_Save_about_to_show():
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = true;
	list.clear();
	
	list.add_item("New save");
	list.set_item_metadata(0,NEW_SAVE);
	
	var saves := Save.get_saves();
	
	for save in saves:
		list.add_item(save.get_file());
		list.set_item_metadata(list.get_item_count()-1,save);


func _on_List_item_activated(index):
	
	if list.get_item_metadata(index) == NEW_SAVE:
		$NewSave.popup();
	
	else:
		Save.save_game(list.get_item_metadata(index));


func _on_Button2_pressed():
	hide();


func _on_Button_pressed():
	_on_List_item_activated(list.get_selected_items()[0]);


func _on_List_item_selected(_index):
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = false;


func _on_List_nothing_selected():
	$Panel/VBoxContainer/HBoxContainer/Button.disabled = true;
