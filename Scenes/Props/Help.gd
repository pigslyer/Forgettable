extends Sprite

export (String,MULTILINE) var help;
# leaving empty will put message to help
export (String) var special_message;

func _ready():
	$CanvasLayer/WindowDialog.dialog_text = help;


func _on_Interactive_interacted():
	$CanvasLayer/WindowDialog.popup();
