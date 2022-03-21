extends ItemBase

const NOT_HERE = "I can't plant the explosives here.";
const ALREADY_PLACED = "I've already planted explosives here.";
const PLACED = ["This might be a good spot.","This'll cause some damage.","Another one down.","That's all of 'em."];

func _use():
	
	if $Area2D.get_overlapping_areas().empty():
		Groups.say_line(NOT_HERE);
	elif Groups.cur_room.plant_explosive(global_position):
		Groups.say_line(PLACED[PLACED.size()-Save.save_data[Save.EXPLOSIVES_KEY].size()]);
		
		Groups.get_player().get_item(filename,1);
		if Groups.get_player().get_waffle().count_item(filename) == 0:
			Groups.get_player().equip(null);
	else:
		Groups.say_line(ALREADY_PLACED);
	
	
