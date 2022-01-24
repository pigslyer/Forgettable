extends ItemBase

const HEAL_AMOUNT = 20;

func _use():
	if Groups.get_player().health >= Player.MAX_HEALTH:
		Groups.say_line("I'm not hurt!");
	else:
		Groups.get_player().health += HEAL_AMOUNT;
		Groups.get_player().get_item(filename,1);
		if Groups.get_player().get_waffle().count_item(filename) == 0:
			Groups.get_player().equip(null);

func _hud_primary():
	return "Bandage wounds";
