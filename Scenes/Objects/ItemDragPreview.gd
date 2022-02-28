extends Control

signal rotated;

var sprite := Sprite.new();
var item: ItemInventory;
var step: Vector2;

func _ready():
	add_child(sprite);
	sprite.centered = false;

func setup(i: ItemInventory, s: Vector2, waffle):
	sprite.texture = i.texture;
	step = s;
	sprite.scale = step*i.size/i.texture.get_size();
	item = i;
	item.currently_rotated = i.rotated;
	connect("rotated",waffle,"update_preview_rect");
	
	if item.currently_rotated:
		sprite.rotation = PI/2;
		sprite.offset.y = -sprite.get_rect().size.y;
		sprite.flip_v = true;
		sprite.scale = Vector2(step.y,step.x)*item.get_size(false)/sprite.texture.get_size();

func _input(ev: InputEvent):
	if ev.is_action_pressed("rotate"):
		item.currently_rotated = !item.currently_rotated;
		
		if item.currently_rotated:
			sprite.rotation = PI/2;
			sprite.offset.y = -sprite.get_rect().size.y;
			sprite.flip_v = true;
			sprite.scale = Vector2(step.y,step.x)*item.get_size(false)/sprite.texture.get_size();
		
		else:
			sprite.rotation = 0;
			sprite.offset = Vector2.ZERO;
			sprite.flip_v = false;
			sprite.scale = step*item.get_size(false)/sprite.texture.get_size();
		
		emit_signal("rotated");
