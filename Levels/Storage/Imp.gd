extends Sprite

func dial_action(id):
	if id == "throw_key":
		$AnimationPlayer.play("ThrowCard");
	
	elif id == "throw_key2":
		$AnimationPlayer.play("ThrowCard2");
	
	elif id == "start_info":
		$ActedConvo.start_dial(true);
	
	elif id == "has_explosives":
		var c = Groups.get_player().get_waffle().count_item("");
		if c > 0:
			Groups.get_player().get_waffle().get_item("",c)
		else:
			Groups.get_player().get_dial_player().stop();

