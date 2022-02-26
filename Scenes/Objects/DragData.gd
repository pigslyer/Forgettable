class_name DragData

class ItemDrag extends Reference:
	var waffle;
	var item: ItemInventory;
	var pos setget ,get_pos; func get_pos() -> Vector2: return item.pos;
	var size setget ,get_size; func get_size() -> Vector2: return item.size;
	var rot: bool setget set_rot, get_rot;
	
	func set_rot(state: bool):
		item.rotated = state;
	func get_rot() -> bool: return item.rot;
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			if waffle.preview_rect != waffle.PREVIEW_NO_RECT:
				waffle.preview_rect = waffle.PREVIEW_NO_RECT;
				waffle.update();
	
	func _init(d: ItemInventory, waff):
		item = d; waffle = waff;
		

class ItemHotbar extends Reference:
	var hotbar: ReferenceRect; var item: ItemInventory;
	func _init(d: ItemInventory, ht): 
		hotbar = ht; item = d;
