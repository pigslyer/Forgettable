extends Label

const FADE_IN_TIME = 5;

func _on_Timer_timeout():
	displaying(true);

func displaying(on: bool):
	if on && !$Tween.is_active():
		$Tween.interpolate_property(self,"self_modulate",Color8(255,255,255,0),Color8(255,255,255,255),FADE_IN_TIME);
		$Tween.start();
		$Timer.stop();
	elif on:
		$Timer.stop();
		$Timer.start();
	else:
		modulate.a = 0;
		$Timer.start();
