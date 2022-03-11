extends Sprite

func dial_action(id):
	if id == "throw_key":
		$AnimationPlayer.play("ThrowCard");
	
	elif id == "start_info":
		# wait until the dialogue wraps up
		yield(get_tree(),"idle_frame");
		$ActedConvo.start_dial(true);
	
	elif id == "has_explosives":
		var c = Groups.get_player().get_waffle().count_item("");
		if c > 0:
			Groups.get_player().get_waffle().get_item("",c)
		else:
			Groups.get_player().get_dial_player().stop();

