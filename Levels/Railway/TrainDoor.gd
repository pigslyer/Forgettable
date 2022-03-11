extends StaticBody2D;

var open := false;

func data_save():
	return open;

func data_load(data):
	open = data;
	
	if open:
		$AnimationPlayer.play("Open");
		$AnimationPlayer.seek($AnimationPlayer.current_animation_length);

func _on_Keypad_entered():
	open = !open;
	$AnimationPlayer.play("Open" if open else "Close");
