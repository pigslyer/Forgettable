extends Area2D

const DAMAGE = 45;

export (bool) var disabled = false setget set_disabled;

func data_save(): return [disabled,false];

func data_load(data):
	disabled = data[0];
	
	if data[1]:
		queue_free();

func set_disabled(state: bool):
	monitoring = !state;
	
	if state:
		$Beep.stop();
	else:
		$Beep.start();

func _on_Mine_body_entered(_body):
	$BlowUp.set_enabled(true);
	set_block_signals(true);
	
	for i in $BlowUp.smoothing:
		yield(get_tree(),"physics_frame");
	
	for body in $DamageArea.get_overlapping_bodies():
		body.health -= DAMAGE;
	
	Save.save_my_data(self,[null,true]);
	queue_free();
