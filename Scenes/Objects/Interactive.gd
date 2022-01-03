class_name Interactive
extends Control

signal interacted;

# out of PICKUP range. i.e., not close enough to pick up, still shaderable
enum{
	STATE_UNAVAIL, STATE_OUT_OF_RANGE, STATE_CLICKABLE
};

export (Material) var shader = preload("res://Scenes/Objects/outline.tres");
export (String) var message = "";
export (bool) var disabled = false setget disable;

var cur_state: int setget clickable;
var area: Area2D;
var collision: CollisionShape2D;

func _ready():
	clickable(STATE_UNAVAIL);
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
	_place();

func replace():
	area.queue_free();
	collision.queue_free();
	_place();

func _place():
	area = Area2D.new();
	collision = CollisionShape2D.new();
	add_child(area);
	area.add_child(collision);
	area.position = rect_size/2;
	area.monitoring = false;
	area.collision_layer = 0b1000;
	collision.shape = CircleShape2D.new();

func disable(state: bool):
	if !is_inside_tree():
		call_deferred("disable",state)
		return
	
	area.monitorable = !state;
	clickable(STATE_UNAVAIL);
	disabled = state;


func clickable(state: int):
	
	cur_state = state;
	_update_shader();
	
	if (state != STATE_CLICKABLE):
		mouse_filter = Control.MOUSE_FILTER_IGNORE;
	else:
		mouse_filter = Control.MOUSE_FILTER_PASS;


func _input(event):
	if event is InputEventKey && event.scancode == KEY_ALT:
		_update_shader();


func _update_shader():
	assert(get_parent() is CanvasItem);
	
	if Input.is_key_pressed(KEY_ALT) && cur_state != STATE_UNAVAIL && !disabled:
		get_parent().material = shader;
	else:
		get_parent().material = null;


func _gui_input(event: InputEvent):
	if event.is_action_pressed("lrmb"):
		emit_signal("interacted")
		accept_event()
