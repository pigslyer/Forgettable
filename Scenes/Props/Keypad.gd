extends Sprite

signal entered;

var filled_in: String = "";

export (String) var code: String;

func _ready():
	
	if code.empty():
		push_error(str("Code in ",get_path()," isn't set."));
	
	for child in $CanvasLayer/PopupPanel/Panel/VBoxContainer.get_children():
		for button in child.get_children():
			button.connect("pressed",self,"_key_entered",[button.text]);


func _key_entered(key: String):
	if key.is_valid_integer() && filled_in.length() < code.length():
		filled_in += key;
	elif key == "ENTER":
		if filled_in == code:
			emit_signal("entered");
			$Correct.play();
		else:
			$Incorrect.play();
		filled_in = "";
	elif key == "DELETE" && !filled_in.empty():
		filled_in = filled_in.substr(0,filled_in.length()-1);
	
	$CanvasLayer/PopupPanel/Panel/LineEdit.text = filled_in;
	$Click.pitch_scale = rand_range(0.9,1.1);
	$Click.play();

# for whatever reason shortcuts don't want to work
func _input(ev):
	if $CanvasLayer/PopupPanel.visible:
		if ev.is_action_pressed("ui_accept"):
			_key_entered("ENTER");
		elif ev.is_action_pressed("backspace"):
			_key_entered("DELETE");
