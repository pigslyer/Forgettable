extends Sprite

var picked_up: bool = false;

func data_save():
	return picked_up;

func data_load(data):
	picked_up = data
	if data:
		$Interactive.queue_free();

func _on_Interactive_interacted():
	var item := ItemInventory.new("res://Levels/Abandoned/Prison/PrisonKey.tscn");
	Groups.get_player().add_item(item);
	
	if item.count > 0:
		Projectile.drop_item(item,Groups.get_player_pos());
	
	data_load(true);
