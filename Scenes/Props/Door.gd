class_name Door, "res://Assets/Base/door_hand_scanner.png"
extends Node2D;

signal toggled_open;
signal toggled_lock;

const UNLOCK_LINE = "It's now unlocked.";
const LOCK_LINE = "It's now locked.";
const NO_KEYCARD_LINE = "I haven't got the right keycard to ";

const LIGHT_UNLOCKED = Color(0x8f8787);

const LIGHTS_LOCKED := {
	"handgun_storage" : Color.yellow,
	"storage1" : Color.teal,
	"railway": Color.purple,
	"prison": Color.chartreuse,
	"/": Color.red,
};

export (String) var outer_text = "";
export (String) var keycard = "";

export (bool) var open = false;
export (bool) var locked = false setget set_locked;
export (bool) var enemies_can_open = true;

export (String,MULTILINE) var locked_line = "The door's locked.";

onready var prev_open: bool = open;

func data_save():
	return [open,locked];

func data_load(data): 
	open = data[0]; locked = data[1];
	
	_ready();

func _ready():
	
	if outer_text.empty():
		$WhenClosed/Text.hide();
		$WhenClosed/Text/Interactive.disable(true);
	else:
		$WhenClosed/Text/Interactive.message = outer_text;
	
	if open:
		$AnimationPlayer.play("open");
		$AnimationPlayer.seek($AnimationPlayer.current_animation_length,true);
		$WhenClosed/OuterOpen/Interactive.message = "Close";
		$WhenClosed/InnerOpen/Interactive.message = "Close";
	
	_update_locked();


func _on_open(force: bool = false):
	if locked && !force:
		Groups.say_line(locked_line,self);
	elif enemies_can_open && open && !$EnemyAutoOpen.get_overlapping_bodies().empty():
		Groups.say_line("He's in the way!",self);
	
	else:
		if open:
			$AnimationPlayer.play_backwards("open");
		else:
			$AnimationPlayer.play("open");
		$WhenClosed/OuterOpen/Interactive.message = "Open" if open else "Close";
		$WhenClosed/InnerOpen/Interactive.message = "Open" if open else "Close";
		$WhenClosed/Skkrt.play();
		open = !open;
		prev_open = open;
		emit_signal("toggled_open");

func _on_keycard():
	if !keycard.empty() && Groups.get_player().has_keycard(keycard):
		toggle_locked();
	else:
		Groups.say_line(str(NO_KEYCARD_LINE,"unlock it." if locked else "lock it."),self);

func toggle_locked():
	locked = !locked;
	$LockedSound.play();
	Groups.say_line(LOCK_LINE if locked else UNLOCK_LINE, self);
	_update_locked();
	emit_signal("toggled_lock");

func _on_EnemyAutoOpen_body_entered(_body):
	if !open && enemies_can_open:
		_on_open(true);
		prev_open = false;

func _on_EnemyAutoOpen_body_exited(_body):
	if open && !prev_open && $EnemyAutoOpen.get_overlapping_bodies().empty():
		_on_open(true);

func get_foot_override():
	return [
		Rect2(
			Vector2(
				min($WhenOpen/TopLeft.global_position.x,$WhenOpen/BottomRight.global_position.x),
				min($WhenOpen/TopLeft.global_position.y,$WhenOpen/BottomRight.global_position.y)
			),
			(
				$WhenOpen/BottomRight.position-$WhenOpen/TopLeft.position
			).rotated(global_rotation).abs()
		),
		preload("res://Assets/Sounds/vent_floor.wav"),
	];

func set_locked(state: bool):
	if state != locked:
		locked = state;
		_update_locked();
		emit_signal("toggled_lock");

func _update_locked():
	if !locked:
		enemies_can_open = true;
	
	$WhenClosed/InnerKeycard/Interactive.message = "Unlock" if locked else "Lock";
	$WhenClosed/OuterKeycard/Interactive.message = "Unlock" if locked else "Lock";
	$WhenClosed/InnerOpen/Flicker.color = LIGHTS_LOCKED.get(keycard,LIGHTS_LOCKED["/"]) if locked else LIGHT_UNLOCKED;
	$WhenClosed/OuterOpen/Flicker.color = $WhenClosed/InnerOpen/Flicker.color;

func _physics_process(_delta):
	if $DeathZone.monitoring:
		for killable in $DeathZone.get_overlapping_bodies():
			killable.health = -1;
			Music.play_sfx(preload("res://Assets/Base/squelch.wav"),rand_range(0.9,1.1));
			killable.set_deferred("collision_layer",0);

const TOGGLE_TIME = 0.1;

onready var l1 = $WhenClosed/InnerKeycard/Flicker2;
onready var l2 = $WhenClosed/OuterKeycard/Flicker;

func _on_Door_toggled_lock():
	if is_inside_tree():
		
		l1.enabled = true;
		l2.enabled = true;
		
		yield(get_tree().create_timer(TOGGLE_TIME),"timeout");
		
		l1.enabled = false;
		l2.enabled = false;
