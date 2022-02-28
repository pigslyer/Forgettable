class_name ItemInventory
extends Reference

var path: String;

var pos: Vector2;
var size: Vector2 setget , get_size;
var rotated: bool; # rotated doesn't change item size, getter rotates
var count: int;
var stack: int;

var name: String;
var tooltip: String;
var texture: Texture;

var currently_rotated: bool;
var size_rot: Vector2 setget , get_rot_size;

func get_size(rot: bool = true) -> Vector2:
	return Vector2(size.y,size.x) if rotated && rot else size;

func get_rot_size() -> Vector2:
	return Vector2(size.y,size.x) if currently_rotated else size;

# use item should be itemBase. can't declare it because of cyclic reference
func _init(file: String, use_item = null, p: Vector2 = -Vector2.ONE, c: int = -1, rot: bool = false):
	path = file;
	pos = p;
	rotated = rot;
	
	if use_item == null:
		use_item = load(file).instance();
		use_item.queue_free();
	
	name = use_item.get_item_name();
	tooltip = use_item.get_item_tooltip();
	texture = use_item.get_texture();
	
	size = use_item.item_size;
	count = use_item.count if c == -1 else c;
	stack = use_item.stack_size;

func _to_string():
	return str(name," ",count," ",stack," ",pos," ",size);

func save_data():
	return [path,pos,count,rotated];

