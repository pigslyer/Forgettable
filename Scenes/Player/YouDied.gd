extends Popup;

export (NodePath) var loadgame;

func _on_YouDied_about_to_show():
	get_tree().paused = true;
	$Panel/VBoxContainer/Reload.disabled = Save.get_saves().empty();

func _on_Reload_pressed():
	get_tree().paused = false;
	Save.load_game(Save.get_saves()[0].get_basename());

func _on_Load_pressed():
	get_node(loadgame).popup();


func _on_MainMenu_pressed():
	push_warning("You haven't added the main menu yet m8.");
