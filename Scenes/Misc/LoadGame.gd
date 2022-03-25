extends Popup

var loading: bool;

onready var prompt = $Popup/Panel/Label;
onready var items: ItemList = $Panel/VBoxContainer/Saves;


func _on_LoadGame_about_to_show():
	
	var saves := Save.get_saves();
	items.clear();
	$Panel/VBoxContainer/HBoxContainer/Load.disabled = true;
	$Panel/VBoxContainer/HBoxContainer/Delete.disabled = true;
	$Popup/Panel/Cancel.grab_focus();
	
	if saves.empty():
		items.mouse_filter = MOUSE_FILTER_IGNORE;
		items.add_item("No saves!");
		items.set_item_tooltip_enabled(0,false);
	
	else:
		items.mouse_filter = MOUSE_FILTER_STOP;
		
		for save in saves:
			items.add_item(save.get_basename());
			items.set_item_metadata(items.get_item_count()-1,save.get_basename());
			items.set_item_tooltip_enabled(items.get_item_count()-1,false);

func _on_Load_pressed():
	loading = true;
	prompt.text = str("Are you sure you'd like to load ",items.get_item_metadata(items.get_selected_items()[0]),"?");
	$Popup.popup();

func _on_Delete_pressed():
	loading = false;
	prompt.text = str("Are you sure you'd like to delete ",items.get_item_metadata(items.get_selected_items()[0]),"?");
	$Popup.popup();
	$Popup/Panel/Cancel.grab_focus();

func _on_Cancel_pressed():
	hide();

func _on_Saves_item_selected(_index):
	$Panel/VBoxContainer/HBoxContainer/Load.disabled = false;
	$Panel/VBoxContainer/HBoxContainer/Delete.disabled = false;

func _on_Saves_item_activated(_index):
	_on_Load_pressed();

func _on_Saves_nothing_selected():
	$Panel/VBoxContainer/HBoxContainer/Load.disabled = true;
	$Panel/VBoxContainer/HBoxContainer/Delete.disabled = true;
	items.unselect_all();

func _on_Confirm_pressed():
	if loading:
		get_tree().paused = false;
		get_parent().set_block_signals(true);
		Save.load_game(items.get_item_metadata(items.get_selected_items()[0]));
	else:
		Save.delete_save(items.get_item_metadata(items.get_selected_items()[0]));
		_on_LoadGame_about_to_show();
		$Popup.hide();
