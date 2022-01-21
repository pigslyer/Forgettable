extends Node2D;

const UNLOCK_LINE = "It's now unlocked.";
const LOCK_LINE = "It's now locked.";
const NO_KEYCARD_LINE = "I haven't got the right keycard to";

export (String) var outer_text = "";
export (String) var keycard = "";

export (bool) var open = false;
export (bool) var locked = false;
export (bool) var enemies_can_open = true;

export (String,MULTILINE) var locked_line = "The door's locked";

onready var prev_open: bool = open;

func data_save(): return [open,locked];
func data_load(data): 
	open = data[0]; locked = data[1];

func _ready():
	if outer_text.empty():
		$WhenClosed/Text.hide();
	
	if open:
		$AnimationPlayer.play("open");
		$AnimationPlayer.seek($AnimationPlayer.current_animation_length,true);

func _on_open(force: bool = false):
	if locked && !force:
		Groups.say_line(locked_line);
	else:
		if open:
			$AnimationPlayer.play_backwards("open");
		else:
			$AnimationPlayer.play("open");
		open = !open;
		prev_open = open;

func _on_keycard():
	if !keycard.empty() && Groups.get_player().has_keycard(keycard):
		locked = !locked;
		$LockedSound.play();
		Groups.say_line(LOCK_LINE if locked else UNLOCK_LINE);
	else:
		Groups.say_line(str(NO_KEYCARD_LINE,"unlock it." if locked else "lock it."));

func _on_read():
	Groups.say_line(outer_text);


func _on_EnemyAutoOpen_body_entered(_body):
	if !open && enemies_can_open:
		_on_open(true);
		prev_open = false;

func _on_EnemyAutoOpen_body_exited(_body):
	if open && !prev_open && $EnemyAutoOpen.get_overlapping_bodies().empty():
		_on_open(true);
