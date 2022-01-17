tool

class_name Pickup
extends Sprite;

const DISSOLVE_TIME = 0.3;

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
	elif drops != null:
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
		texture = temp.texture if temp.override_icon == null else temp.override_icon;
		name = temp.name;
		if !Engine.editor_hint:
			my_data = ItemInventory.new(drops.resource_path,temp);
			$Interactive.message = temp.get_item_name();
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
		
		$Interactive.disable(true);
		
		yield(get_tree(),"physics_frame");
		material = preload("res://Scenes/Objects/dissolve.tres");
		
		$Tween.interpolate_method(self,"_dissolve",0,2,DISSOLVE_TIME);
		$Tween.start();
		yield($Tween,"tween_all_completed");
		
		queue_free();
	else:
		Groups.say_line(str("I haven't got enough space to\npick up ",my_data.count," ",my_data.name,"(s)."));

func _dissolve(val: float):
	material.set_shader_param("percent",val);

func data_save(): return my_data.count;
func data_load(data):
	if data > 0:
		my_data.count = data;
	else:
		queue_free();
