extends Node2D

func dial_action(action):
	if action == "carry":
		$AnimationPlayer.play("carry");
		$Tormentor/Interactive.disable(true);
