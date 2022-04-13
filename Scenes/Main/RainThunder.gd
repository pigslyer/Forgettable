extends AudioStreamPlayer2D

const MIN_CHANCE = 3;
const MAX_CHANCE = 8;

var time = 2;

func fade_in():
	volume_db = -60;
	$Tween.interpolate_property(self,"volume_db",-60,0,4);
	$Tween.start();
	play();

func _on_RainThunder_finished():
	if time == 0:
		stream = preload("res://Assets/Sounds/thunder.wav");
		time = randi()%(MAX_CHANCE-MIN_CHANCE)+MIN_CHANCE;
		$Timer.start();
	else:
		stream = preload("res://Assets/Sounds/rain.wav");
	
	play();
	time -= 1;
