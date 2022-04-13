extends Sprite

const DISSOLVE_TIME = 0.8;

var picked_up: bool = false;

func data_save():
	return picked_up;

func data_load(data):
	if data:
		queue_free();

func _on_Interactive_interacted():
	picked_up = true;
	Groups.get_player().get_waffle().height += 1;
	Music.play_sfx(preload("res://Assets/Sounds/belt.wav"),0.93,8);
	Save.save_my_data(self);
	
	$Interactive.disable(true);
	
	yield(get_tree(),"physics_frame");
	material = preload("res://Scenes/Objects/dissolve.tres").duplicate();
	
	$Tween.interpolate_method(self,"_dissolve",0,2,DISSOLVE_TIME);
	$Tween.start();

	yield($Tween,"tween_all_completed");
	queue_free();

func _dissolve(val: float):
	if material == null: 
		material = preload("res://Scenes/Objects/dissolve.tres").duplicate();
	material.set_shader_param("percent",val);
