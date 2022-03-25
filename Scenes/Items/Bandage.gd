extends ItemBase

const HEAL_AMOUNT = 20;

const HEAL_SOUNDS := [
	preload("res://Assets/LiamNoises/health1.wav"),
	preload("res://Assets/LiamNoises/health2.wav"),
];
# add wrapping sound play

func _use():
	if Groups.get_player().health >= Player.MAX_HEALTH:
		Groups.say_line("I'm not hurt!");
	else:
		Music.play_sfx(HEAL_SOUNDS[randi()%HEAL_SOUNDS.size()],1,5);
		Groups.get_player().health += HEAL_AMOUNT;
		Groups.get_player().get_item(filename,1);
		if Groups.get_player().get_waffle().count_item(filename) == 0:
			Groups.get_player().equip(null);

func _hud_primary():
	return "Bandage wounds";
