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
# don't need 'em
const A = (BODY_RUN_SPEED-SPEED_RUN/SPEED_WALK)/(SPEED_RUN*(SPEED_RUN-SPEED_WALK));
const B = (BODY_WALK_SPEED-A*SPEED_WALK*SPEED_WALK)/SPEED_WALK;

const CAM_SHAKE_DIST = Vector2(0,2);
const CAM_SHAKE_SPRINT_MULT = 4;
const CAM_SHAKE_MULT = 0.3;

const CAM_ZOOM_NORMAL = Vector2(0.38,0.38);
const CAM_ZOOM_SPRINT = Vector2(0.42,0.42);
const CAM_ZOOM_COMBAT = Vector2(0.47,0.47);

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

var has_goggles: bool = false;
var has_pipe: bool = false;

# so player can't do stupid shit while reloading
var can_inventory: bool = true;

func _ready():
	
	if !visible:
		show();
	
	var hotbar_items = [];
	hotbar_items.resize(hotbar.SLOTS);
	hotbar.items = hotbar_items;
	$HUD/Theme/Hotbar.items = hotbar_items;
	
	Music.play_music(Music.MUSIC.AMBIENT,false);

func equip(item: ItemInventory):
	if item != null || equipped_item != null:
		$HotbarDelay.start();
	
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
	
	if $DialoguePlayer/Theme.get_focus_owner() is Interactive:
		inter_label.visible = true;
		closest = $DialoguePlayer/Theme.get_focus_owner().area;
		inter_label.text = closest.get_parent().message;
	else:
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
			
			if closest == null || closest.get_parent().message.empty():
				inter_label.hide();
			else:
				inter_label.text = closest.get_parent().message;
	
	# cam shake
	cam_shake_off *= CAM_SHAKE_MULT;
	$Camera.offset = cam_shake_off;
	$Camera.target_zoom = (CAM_ZOOM_SPRINT if sprinting else CAM_ZOOM_NORMAL) if Save.can_save() else CAM_ZOOM_COMBAT;
	
	# it's retarded
	$CollisionShape2D.global_rotation = $Animated/Body.global_rotation;

func _unhandled_key_input(ev: InputEventKey):
	
	if ev.is_action_pressed("interact") && closest != null:
		closest.get_parent().interact();
	
	if can_inventory && ev.is_action_pressed("inventory"):
		$HUD/Theme/Inventory.popup();
	
	if ev.is_action_pressed("ui_cancel"):
		$HUD/Theme/Pause.popup();
	
	if can_inventory && $HotbarDelay.is_stopped() && ev.pressed && !ev.echo && ev.physical_scancode >= KEY_1 && ev.physical_scancode < KEY_1+hotbar.SLOTS:
		equip(hotbar.items[ev.physical_scancode-KEY_1]);
	
	if OS.is_debug_build():
		if ev.is_action_pressed("debug_fullbright"):
			$CanvasModulate.visible = !$CanvasModulate.visible;


func say_line(text: String):
	$HUD/Theme/SayLine.say_line(text);


const DEATH_SCREAMS = ["res://Assets/LiamNoises/death2.wav"];

func set_health(new_val: int):
	if health > 0 && new_val <= 0:
		set_control(false);
		$Animated/PlayerWalk.pause_mode = PAUSE_MODE_PROCESS;
		
		if equipped_item != null:
			equipped_item.queue_free();
		
		$HUD/Theme/SaveReminder.displaying(false);
		$HUD/Theme/SaveReminder/Timer.stop();
		$Animated/PlayerWalk.play("die");
	
	health = new_val;
	$HUD/Theme/Health.value = new_val/float(MAX_HEALTH);
	

func set_control(state: bool):
	# if we were controlling we want to, if we weren't it wasn't open
	$HUD/Theme/Inventory.hide();
	set_physics_process(state);
	set_process_unhandled_input(state);
	set_process_unhandled_key_input(state);
	set_process_input(state);
	follow_mouse(state);
	$Animated/PlayerWalk.set_walking(false);

func hide_hud():
	$DialoguePlayer/Tween.interpolate_property($HUD/Theme/Health,"modulate",null,Color8(255,255,255,0),0.9,Tween.TRANS_CUBIC);
	$DialoguePlayer/Tween.interpolate_property($HUD/Theme/Hotbar,"modulate",null,Color8(255,255,255,0),0.9,Tween.TRANS_CUBIC);
	$DialoguePlayer/Tween.start();

func _play_death():
	Music.play_sfx(load(DEATH_SCREAMS[randi()%DEATH_SCREAMS.size()]),rand_range(0.95,0.99),-4).pause_mode = PAUSE_MODE_PROCESS;

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

func start_dial(path: String, onetime: bool = true, actions: Node = null):
	$DialoguePlayer.start(path,onetime,actions);

func get_camera() -> Camera2D:
	return $Camera as Camera2D;

func turn_towards(point: Vector2):
	$Animated.angle = (point-global_position).angle();

func save_reminder(on: bool):
	$HUD/Theme/SaveReminder.displaying(on);

func save_data():
	
	return [
		health, 
		global_position,
		get_waffle().items.find(equipped) if equipped != null else null,
		equipped_item.ammo if equipped_item is Gun else null,
		get_waffle().save_data(),
		$HUD/Theme/Inventory.save_data(),
		has_goggles,
		$DialoguePlayer.one_timed,
	];

func load_data(data):
	health = data[0];
	global_position = data[1];
	get_waffle().load_data(data[4]);
	$HUD/Theme/Inventory.load_data(data[5]);
	
	# if we had a gun equipped
	if data[3] != null:
		equipped = get_waffle().items[data[2]];
		equipped_item = load(equipped.path).instance(); 
		$Animated/Body/ArmRight/Hand.add_child(equipped_item);
		has_gun = true;
		equipped_item.ammo = data[3];
		emit_signal("equipped_new")
	
	elif data[2] != null:
		equip(get_waffle().items[data[2]])
	
	if data[6]:
		equip_special("res://Scenes/Items/TechGoggles.tscn");
	
	$DialoguePlayer.one_timed = data[7];
	
	# better too many than too few imo
	get_tree().call_group(Groups.TECH_GOGGLES,"tech_goggles",has_goggles);

func equip_special(path: String, dropping: bool = false):
	match path:
		"res://Scenes/Items/TechGoggles.tscn":
			has_goggles = !has_goggles && !dropping;
			$Animated/Body/Head/TechGoggles.visible = has_goggles;
			get_tree().call_group(Groups.TECH_GOGGLES,"tech_goggles",has_goggles);
			say_line("I put on the goggles." if has_goggles else "I take off the goggles.");
		"res://Scenes/Items/Pipe.tscn":
			has_pipe = !has_pipe && !dropping;
			$Animated/Body/Head/Pipe.visible = has_pipe;
			say_line("I put the pipe in my mouth." if has_pipe else "I take the pipe out of my mouth.\nYuck!");

func special_equipped(path: String) -> bool:
	match path:
		"res://Scenes/Items/TechGoggles.tscn":
			return has_goggles;
		"res://Scenes/Items/Pipe.tscn":
			return has_pipe;
	
	return false;

func get_dial_player():
	return $DialoguePlayer;
