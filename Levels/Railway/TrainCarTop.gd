extends Area2D

const SPEED = 300/255.0;

func _physics_process(delta):
	# collision bits are useful
	modulate.a = clamp(modulate.a - (SPEED*delta) * (-1 if get_overlapping_bodies().empty() else 1),0,1);

func _on_MineDetector_picked_up():
	Save.cur_state = Save.STATE.LORELEI;
	Save.cur_objective = "Escape through medical.";
