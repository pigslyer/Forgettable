extends Area2D

const FADE_IN_TIME = 1.8;
const FADE_OUT_TIME = 0.7;

func _on_TrainCarTop_body_entered(_body):
	
	$Tween.stop_all();
	$Tween.interpolate_property(self,"modulate",null,Color8(255,255,255,0),FADE_IN_TIME);
	$Tween.start();


func _on_TrainCarTop_body_exited(_body):
	
	$Tween.stop_all();
	$Tween.interpolate_property(self,"modulate",null,Color8(255,255,255,255),FADE_OUT_TIME);
	$Tween.start();
