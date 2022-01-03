extends Node2D;

const UNLOCK_LINE = "It's now unlocked.";
const LOCK_LINE = "It's now locked.";
const NO_KEYCARD_LINE = "I haven't got the right keycard."

export (String) var outer_text = "";
export (String) var keycard = "";

export (bool) var open = false;
export (bool) var locked = false;
export (bool) var powered = true;

export (String,MULTILINE) var no_power_line = "The door isn't powered";
export (String,MULTILINE) var locked_line = "The door's locked";

func _ready():
	if outer_text.empty():
		$WhenClosed/Text.hide();
	
	if open:
		$AnimationPlayer.play("open");
		$AnimationPlayer.seek($AnimationPlayer.current_animation_length,true);

func _on_open():
	if !powered:
		Groups.say_line(no_power_line);
	elif locked:
		Groups.say_line(locked_line);
	else:
		if open:
			$AnimationPlayer.play_backwards("open");
		else:
			$AnimationPlayer.play("open");
		open = !open;


func _on_keycard():
	if !keycard.empty() && Groups.get_player().has_keycard(keycard):
		locked = !locked;
		$LockedSound.play();
		Groups.say_line(LOCK_LINE if locked else UNLOCK_LINE);
	else:
		Groups.say_line(NO_KEYCARD_LINE);


func _on_read():
	Groups.say_line(outer_text);
