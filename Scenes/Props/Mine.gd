extends Area2D

const DAMAGE = 45;

func _on_Mine_body_entered(_body):
	$BlowUp.set_enabled(true);
	set_block_signals(true);
	
	for i in $BlowUp.smoothing:
		yield(get_tree(),"physics_frame");
	
	for body in $DamageArea.get_overlapping_bodies():
		body.health -= DAMAGE;
	
	queue_free();
