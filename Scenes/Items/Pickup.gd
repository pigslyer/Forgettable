tool

extends Sprite;

var my_data: ItemInventory;

export (PackedScene) var drops setget set_drop;
export (bool) var disabled = false setget disable;
export (int) var count = 1;

func disable(state: bool):
	disabled = state;
	if !Engine.editor_hint:
		$Interactive.disable(state);

func _ready():
	if Engine.editor_hint:
		redo_inter();
	else:
		var inst = drops.instance();
		$Interactive.message = inst.get_item_name();
		texture = inst.get_texture();
		my_data = ItemInventory.new(drops.resource_path,inst);
		my_data.count = count;
		inst.free();


func set_drop(scene: PackedScene):
	drops = scene;
	if scene != null:
		var temp = scene.instance();
		texture = temp.texture;
		temp.free();
	else:
		texture = null;
	redo_inter();
	
func redo_inter():
	$Interactive.rect_position = get_rect().position;
	$Interactive.rect_size = get_rect().size;
	if !Engine.editor_hint && drops != null && is_inside_tree():
		$Interactive.replace();

func _on_Interactive_interacted():
	Groups.get_player().add_item(my_data);
	if my_data.count <= 0:
		if is_in_group(Groups.SAVING):
			Save.save_my_data(self);
		queue_free();


func data_save(): return my_data.count;
func data_load(data):
	if data > 0:
		my_data = data;
	else:
		queue_free();
