extends Sprite

const DISSOLVE_TIME = 0.3;

export (String) var display_name;
export (String) var key;

export (bool) var disabled = false setget set_disable;

func data_save(): return is_queued_for_deletion();
func data_load(data):
	if data:
		queue_free();

func _on_Interactive_interacted():
	$Interactive.disable(true);
	
	yield(get_tree(),"physics_frame");
	material = preload("res://Scenes/Objects/dissolve.tres").duplicate();
	
	$Tween.interpolate_method(self,"_interpolate_shader",0,2,DISSOLVE_TIME);
	$Tween.start();
	
	yield($Tween,"tween_all_completed");
	
	queue_free();
	Groups.get_player().add_keycard(display_name,key);
	Save.save_my_data(self);
	Groups.say_line(str("Picked up ", display_name, " keycard."));
	

func set_disable(state: bool):
	$Interactive.disable(state);
	visible = !state;

func _interpolate_shader(val: float):
	material.set_shader_param("percent",val);
