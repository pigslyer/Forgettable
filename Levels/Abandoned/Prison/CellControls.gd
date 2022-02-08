extends Node2D

const BUTTON_GROUP = "cell_control_button";

# ensure the starting door is open
var open: String;
var locked := true;

onready var opened: AnimationPlayer = $Cell1/AnimationPlayer;
onready var line_edit: LineEdit = $CanvasLayer/CellControls/Panel/Panel/LineEdit;

func data_save(): return [locked,open];
func data_load(data):
	locked = data[0]; 
	if !locked:
		line_edit.text = str("OPENED: -1");
	
	if !data[1].empty():
		open = data[1];
		opened.play("Close"); opened.seek(opened.current_animation_length,true);
		opened = _get_cell(open);
		opened.play("Open"); opened.seek(opened.current_animation_length,true)
		line_edit.text = str("OPENED: ",open);

func _ready():
	for button in get_tree().get_nodes_in_group(BUTTON_GROUP):
		button.connect("pressed",self,"_cell_selected",[button.text]);


func _on_Keyhole_gui_input(ev):
	if ev.is_action_pressed("lmb"):
		# locked and the player has a key
		if locked && Groups.get_player().get_waffle().count_item("res://Levels/Abandoned/Prison/PrisonKey.tscn") > 0:
			Groups.get_player().get_item("res://Levels/Abandoned/Prison/PrisonKey.tscn",1);
			locked = false;
			$ToggleLock.play();
			if open.empty():
				line_edit.text = str("OPENED: -1");
			else:
				line_edit.text = str("OPENED: ",open);
		# unlocked and the player wants the key
		elif !locked:
			var item := ItemInventory.new("res://Levels/Abandoned/Prison/PrisonKey.tscn");
			Groups.get_player().add_item(item);
			if item.count > 0: Projectile.drop_item(item,Groups.get_player().global_position);
			locked = true;
			line_edit.text = "LOCKED";
		
		# locked and player hasn't got the key
		else:
			Groups.say_line("It looks like a keyhole, but I haven't got the key.");

func _cell_selected(which: String, force: bool = false):
	if !locked || force:
		if open == which:
			open = "";
			opened.play("Close");
			if !(force && locked):
				line_edit.text = str("OPENED: NONE");
			
		else:
			if !open.empty():
				opened.play("Close");
			
			opened = _get_cell(which);
			opened.play("Open");
			open = which;
			
			if !(force && locked):
				line_edit.text = str("OPENED: ",open);
	else:
		$Locked.play();

func _get_cell(which) -> AnimationPlayer:
	return get_node(str("Cell",which,"/AnimationPlayer")) as AnimationPlayer;

