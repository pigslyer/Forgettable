extends Sprite

func dial_action(id):
	if id == "throw_key":
		$AnimationPlayer.play("ThrowCard");
