extends Node2D

export (NodePath) var enemy1;
export (NodePath) var enemy2;

onready var ray: RayCast2D = $FlickerBlinks/RayCast2D;

func data_save():
	return is_physics_processing();

func data_load(data):
	set_physics_process(data);
	if data:
		$Alarm.play();

func tech_goggles(state: bool):
	visible = state;

func _physics_process(_delta):
	
	if ray.is_colliding():
		
		if !visible || $FlickerBlinks.queue.size() == $FlickerBlinks.smoothing:
			set_physics_process(false);
			$Alarm.play();
			$Mine.disabled = false;
			
			$Shotgunner.path = Groups.get_simple_path($Shotgunner.global_position,$Enemy1Pos.global_position);
			
			$Shotgunner2.path = Groups.get_simple_path($Shotgunner2.global_position,$Enemy2Pos.global_position);
