class_name ItemBase
extends Sprite

enum Anim{
	UNDEFINED,
	ONE_HANDED,
	TWO_HANDED,
};

export (String) var item_name;
export (String,MULTILINE) var item_tooltip;

export (int) var count = 1;
export (int) var stack_size = 1;
export (Vector2) var item_size = Vector2.ONE;

export (Anim) var animation_type;

func _equip():
	pass;

func _unequip():
	pass;

func _use():
	pass;

func _use_secondary():
	pass;

func _hud_primary() -> String:
	return "";

func update_hud():
	Groups.get_player()._update_hud(_hud_primary());

func equip():
	update_hud();
	_equip();

func unequip():
	_unequip();

func get_texture():
	return texture;

func get_item_name():
	return item_name;

func get_item_tooltip():
	return item_tooltip;

# if left at -1, it uses item's
static func dup(org: ItemInventory, new_pos: Vector2 = -Vector2.ONE, new_count: int = -1):
	var item := ItemInventory.new(
			org.path, null, 
			org.pos if new_pos == -Vector2.ONE else new_pos,
			org.count if new_count == -1 else new_count
	);
	
	item.texture = org.texture;
	item.tooltip = org.tooltip;
	item.name = org.name;
	item.stack = org.stack;
	item.size = org.size;
	
	return item;

