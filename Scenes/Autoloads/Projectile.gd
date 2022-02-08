extends Node

func drop_item(drop: ItemInventory, pos: Vector2):
	var item = preload("res://Scenes/Items/Pickup.tscn").instance();
	item.drops = load(drop.path);
	item.count = drop.count;
	item.position = pos;
	add_child(item);
	item.add_to_group(Groups.DROPPED_ITEM);
	item.remove_from_group(Groups.SAVING);
