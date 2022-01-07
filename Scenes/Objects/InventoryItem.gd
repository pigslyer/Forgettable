class_name ItemInventory
extends Reference

var path: String;

var pos: Vector2;
var size: Vector2;
var count: int;
var stack: int;

var name: String;
var tooltip: String;
var texture: Texture;

# use item should be itemBase. can't declare it because of cyclic reference
func _init(file: String, use_item = null, p: Vector2 = -Vector2.ONE, c: int = -1):
	path = file;
	pos = p;
	
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
