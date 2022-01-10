extends Sprite

const DISSOLVE_TIME = 0.3;

export (String) var display_name;
export (String) var key;

func _on_Interactive_interacted():
	$Interactive.disable(true);
	
	yield(get_tree(),"physics_frame");
	material = preload("res://Scenes/Objects/dissolve.tres");
	
	$Tween.interpolate_method(self,"_interpolate_shader",0,2,DISSOLVE_TIME);
	$Tween.start();
	
	yield($Tween,"tween_all_completed");
	
	Groups.get_player().add_keycard(display_name,key);
	queue_free();


func _interpolate_shader(val: float):
	material.set_shader_param("percent",val);
