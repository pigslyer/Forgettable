class_name Player
extends KinematicBody2D

signal equipped_new;

const SPEED_WALK = 100.0;
const SPEED_RUN = 400.0;
const ACCEL = 400;
const MIN_SPEED_MOD = 0.6;
const RUN_ACC_MOD = 2.5;
const FRIC = 0.9;
const MAX_HEALTH = 100;

# max body animation speed when running and walking
const BODY_RUN_SPEED = 1.3;
const BODY_WALK_SPEED = 1.0;

# trust me bro, these are good
# for quadratic equation that determines body speed
const A = (BODY_RUN_SPEED-SPEED_RUN/SPEED_WALK)/(SPEED_RUN*(SPEED_RUN-SPEED_WALK));
const B = (BODY_WALK_SPEED-A*SPEED_WALK*SPEED_WALK)/SPEED_WALK;

const CAM_SHAKE_DIST = Vector2(0,2);
const CAM_SHAKE_SPRINT_MULT = 4;
const CAM_SHAKE_MULT = 0.3;

var health := MAX_HEALTH setget set_health;
var dead := false;

var velocity := Vector2.ZERO;
var sprinting := false;

onready var body = $Animated;
onready var interactive: Area2D = $Animated/Body/Head/InteractiveArea/Interaction;
onready var inter_label: Label = $HUD/Theme/InteractiveDisplay;

onready var hotbar := $HUD/Theme/Inventory/VSplitContainer/HSplitContainer/VSplitContainer/Hotbar;
# this is the area2d child of interactive
var closest = null;
var following_mouse := false setget follow_mouse;

var equipped_item: ItemBase = null;
var equipped: ItemInventory setget equip;
var has_gun: bool = false;

var cam_last_shake_down := false;
var cam_shake_off := Vector2.ZERO;

func _ready():
	
	add_item(ItemInventory.new("res://Scenes/Items/Handgun.tscn"));
	add_item(ItemInventory.new("res://Scenes/Items/Flashlight.tscn"));
	add_item(ItemInventory.new("res://Scenes/Items/Ammo1911.tscn",null,-Vector2.ONE,50));
	
	
	var hotbar_items = [get_waffle().items[0],get_waffle().items[1]];
	hotbar_items.resize(hotbar.SLOTS);
	hotbar.items = hotbar_items;
	$HUD/Theme/Hotbar.items = hotbar_items;
	
	Music.play_music(Music.MUSIC.AMBIENT,false);

func equip(item: ItemInventory):
	
	# just unequip
	if item == equipped && item != null:
		equipped_item.unequip(); equipped_item.queue_free(); equipped_item = null;
		equipped = null;
		$HUD/Theme/Primary.hide();
	
	else:
		if equipped_item != null:
			equipped_item.unequip(); equipped_item.queue_free(); equipped_item = null;
			equipped = null;
			$HUD/Theme/Primary.hide();
		
		if item != null:
			equipped_item = load(item.path).instance(); $Animated/Body/ArmRight/Hand.add_child(equipped_item);
			equipped_item.equip(); equipped = item;
			has_gun = equipped_item is Gun;
			$EquippingDelay.start();
	
	emit_signal("equipped_new");


func _update_hud(primary: String):
	$HUD/Theme/Primary.visible = !primary.empty();
	if primary.begins_with("!"):
		$HUD/Theme/Primary.text = primary.substr(1);
		$HUD/Theme/Primary.modulate = Color.red;
	else:
		$HUD/Theme/Primary.text = primary;
		$HUD/Theme/Primary.modulate = Color.white;


func _physics_process(delta):
	
	var input := Vector2.ZERO;
	sprinting = false;
	
	if is_processing_unhandled_key_input():
		input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
		input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
		input = input.normalized();
		sprinting = Input.is_action_pressed("sprint");
	
	# movement
	var moving = !(is_zero_approx(input.x) && is_zero_approx(input.y));
	
	body.walking = moving;
	body.sprinting = sprinting;
	$LoudArea.sprinting = sprinting;
	
	velocity *= FRIC;
	
	if moving:
		var max_speed = (SPEED_RUN if sprinting else SPEED_WALK);
		
		if velocity.length_squared() < max_speed*max_speed:
			velocity = (velocity + input * ACCEL * delta * (RUN_ACC_MOD if sprinting else 1.0)).clamped(max_speed);
		
		body.speed = A*velocity.length_squared()+B*velocity.length();
	else:
		velocity *= FRIC;
	
	move_and_slide(velocity);
	
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
	
	# cam shake
	cam_shake_off *= CAM_SHAKE_MULT;
	$Camera.offset = cam_shake_off;

func _unhandled_input(ev: InputEvent):
	if equipped != null && ev.is_action_pressed("lmb") && $EquippingDelay.is_stopped(): 
			equipped_item._use();
	
	# not sure if scrolling should skip over empties (why would you want it not to?)
	# or if it should auto move you to the hotbar if you've got a non hotbar thing on
	# (probably should)
	
	if ev.is_action_pressed("wheel_down") != ev.is_action_pressed("wheel_up"):
		if equipped in hotbar.items:
			var diff: int = Input.get_action_strength("wheel_up") - Input.get_action_strength("wheel_down");
			var starting: int = hotbar.items.find(equipped);
			var idx: int = wrapi(starting+diff,0,hotbar.SLOTS);
			
			while starting != idx && hotbar.items[idx] != null:
				idx = wrapi(idx+diff,0,hotbar.SLOTS);
			
			if starting != idx: equip(hotbar.items[idx]);
		else:
			var diff: int = -1 if ev.is_action_pressed("wheel_down") else 1;
			var idx: int = hotbar.SLOTS-1 if ev.is_action_pressed("wheel_down") else 0;
			
			while !(idx == -1 || idx == hotbar.SLOTS) && hotbar.items[idx] != null:
				idx = wrapi(idx+diff,0,hotbar.SLOTS);
			
			if !(idx == -1 || idx == hotbar.SLOTS):
				equip(hotbar.items[idx]);

func _unhandled_key_input(ev: InputEventKey):
	
	if ev.is_action_pressed("interact") && closest != null:
		closest.get_parent().emit_signal("interacted");
	
	if ev.is_action_pressed("inventory"):
		$HUD/Theme/Inventory.popup();
	
	if ev.is_action_pressed("ui_cancel"):
		$HUD/Theme/Pause.popup();
	
	if ev.pressed && !ev.echo && ev.physical_scancode >= KEY_1 && ev.physical_scancode < KEY_1+hotbar.SLOTS:
		equip(hotbar.items[ev.physical_scancode-KEY_1]);
	
	if has_gun && ev.is_action_pressed("reload"):
		equipped_item.reload();
	
	if OS.is_debug_build():
		if ev.is_action_pressed("debug_fullbright"):
			$CanvasModulate.visible = !$CanvasModulate.visible;


func say_line(text: String):
	$HUD/Theme/SayLine.say_line(text);


func set_health(new_val: int):
	if health > 0 && new_val <= 0:
		$HUD/Theme/YouDied.popup();
	
	health = new_val;
	$HUD/Theme/Health.value = new_val/float(MAX_HEALTH);
	

func follow_mouse(state: bool):
	set_process_unhandled_key_input(state);
	set_process_unhandled_input(state);
	$Camera.set_physics_process(state);
	body.follow_mouse = state;
	following_mouse = state;

func add_item(item: ItemInventory) -> void:
	$HUD/Theme/Inventory.add_item(item);

func add_keycard(display_name: String, key: String) -> void:
	$HUD/Theme/Inventory.add_keycard(display_name,key);

func get_waffle() -> ItemWaffle:
	return $HUD/Theme/Inventory/VSplitContainer/HSplitContainer/VSplitContainer/ItemWaffle as ItemWaffle;

func has_keycard(key: String) -> bool:
	return key in $HUD/Theme/Inventory.keycard_ids;

func shake_cam():
	cam_shake_off = CAM_SHAKE_DIST if cam_last_shake_down else -CAM_SHAKE_DIST;
	if sprinting: cam_shake_off *= CAM_SHAKE_SPRINT_MULT;
	cam_shake_off = cam_shake_off.rotated($Animated/Body/Head.global_rotation);
	cam_last_shake_down = !cam_last_shake_down;

func get_item(path: String, count: int) -> int:
	return $HUD/Theme/Inventory.get_item(path,count);
