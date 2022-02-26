extends Control

var sprite := Sprite.new();
var rot: bool;

func _ready():
	add_child(sprite);
	sprite.centered = false;

func setup(tex: Texture, target_size: Vector2, rotated: bool):
	sprite.texture = tex;
	sprite.scale = target_size/tex.get_size();
	rot = rotated;

func _input(ev: InputEvent):
	if ev.is_action_pressed("rmb"):
		rot = !rot;
		get_viewport().gui_get_drag_data().rotated = rot;
		
		if rot:
			sprite.rotation = PI/2;
			sprite.offset.y = sprite.texture.get_size().y*sprite.scale.y;
		
		else:
			sprite.rotation = 0;
			sprite.offset = Vector2.ZERO;
