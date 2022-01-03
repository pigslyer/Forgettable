class_name Player
extends KinematicBody2D

const SPEED_WALK = 100;
const SPEED_RUN = 200;
const MIN_SPEED_MOD = 0.6;
const RUN_ANIM_SPEED = 1.2;

var input := Vector2.ZERO;

var health := 100 setget set_health;
var dead := false;
var sprinting := false;

onready var body = $Animated;
onready var interactive: Area2D = $Animated/Body/Head/InteractiveArea/Interaction;
onready var inter_label: Label = $HUD/Theme/InteractiveDisplay;
# this is the area2d child of interactive
var closest = null;
var following_mouse := false setget follow_mouse;

var equipped_item: ItemBase = null;
var equipped: ItemInventory setget equip;

func _ready():
	$HUD/Theme.show();
	$HUD/Theme/Inventory.add_item(ItemInventory.new("res://Scenes/Items/Flashlight.tscn",Vector2(1,1)));


func equip(item: ItemInventory):
	
	# just unequip
	if item == equipped:
		equipped_item.unequip(); equipped_item.queue_free(); equipped_item = null;
		equipped = null;
	
	else:
		if equipped_item != null:
			equipped_item.unequip(); equipped_item.queue_free(); equipped_item = null;
			equipped = null;
		
		if item != null:
			equipped_item = load(item.path).instance(); $Animated/Body/RightHand.add_child(equipped_item);
			equipped_item.equip(); equipped = item;

func _update_hud(primary: String, secondary: String):
	$HUD/Theme/Primary.visible = !primary.empty();
	$HUD/Theme/Primary.text = primary;
	$HUD/Theme/Secondary.visible = !secondary.empty();
	$HUD/Theme/Secondary.text = secondary;

func _physics_process(_delta):
	
	# movement
	sprinting = Input.is_action_pressed("sprint");
	var move := input.normalized();
	
	body.walking = move.length_squared() != 0;
	body.sprinting = sprinting;
	$LoudArea.sprinting = sprinting;
	
	if move.length_squared() != 0:
		var speed_mod = max(cos(move.rotated(-$Animated/Body/Head.global_rotation).angle()),MIN_SPEED_MOD);
		move_and_slide(move * (SPEED_RUN if sprinting else SPEED_WALK) * speed_mod);
		body.speed = speed_mod * (RUN_ANIM_SPEED if sprinting else 1.0);
	
	# interactive display
	
	closest = null;
	inter_label.visible = !interactive.get_overlapping_areas().empty();
	if inter_label.visible:
		var closest_angle: float;
		
		for inter in interactive.get_overlapping_areas():
			if (
					inter.get_parent().cur_state == Interactive.STATE_CLICKABLE && 
					(closest == null || 
					abs((interactive.global_position-inter.global_position).angle()-interactive.global_rotation) < closest_angle)):
					
				closest = inter;
				closest_angle = abs((interactive.global_position-global_position).angle()-interactive.global_rotation);
		
		if closest == null:
			inter_label.hide();
		else:
			inter_label.text = closest.get_parent().message;
	

func _unhandled_input(ev):
	if equipped != null && following_mouse:
		if ev.is_action_pressed("lmb"): 
			equipped_item._use();
		if ev.is_action_pressed("rmb"):
			equipped_item._use_secondary();

func _unhandled_key_input(ev: InputEventKey):
	
	if ev.is_action_pressed("ui_left") || ev.is_action_released("ui_right"):
		input.x -= 1;
	if ev.is_action_pressed("ui_right") || ev.is_action_released("ui_left"):
		input.x += 1;
	if ev.is_action_pressed("ui_up") || ev.is_action_released("ui_down"):
		input.y -= 1;
	if ev.is_action_pressed("ui_down") || ev.is_action_released("ui_up"):
		input.y += 1;
	
	if ev.is_action_pressed("interact") && closest != null:
		closest.get_parent().emit_signal("interacted");
	
	if ev.is_action_pressed("inventory"):
			$HUD/Theme/Inventory.popup();
	
	if ev.is_action_pressed("ui_cancel"):
		$HUD/Theme/Pause.popup();


func say_line(text: String):
	$HUD/Theme/SayLine.say_line(text);

# justin case
func _notification(what):
	if what == NOTIFICATION_WM_FOCUS_IN:
		input = Vector2(Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left"),Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up"));


func set_health(new_val: int):
	health = new_val;


func follow_mouse(state: bool):
	$Camera.set_physics_process(state);
	body.follow_mouse = state;
	following_mouse = state;

func add_item(item: ItemInventory) -> void:
	$HUD/Theme/Inventory.add_item(item);

func add_keycard(display_name: String, key: String) -> void:
	$HUD/Theme/Inventory.add_keycard(display_name,key);

func has_keycard(key: String) -> bool:
	return key in $HUD/Theme/Inventory.keycard_ids;
