extends Node

func _ready():
	Music.play_music(Music.MUSIC.AMBIENT);
	Music.music_in_game(false);
	
	var ending = "res://Levels/Endings/ending_norm.txt";
	
	if Save.ending == Save.ENDS.NONE:
		Save.ending = Save.ENDS.FINISHED;
	
	if Save.save_data.get("did_nasif",false):
		ending = "res://Levels/Endings/ending_nasif.txt";
		Save.ending = Save.ENDS.NASIF;
		
	elif (Save.save_data[Save.EXPLOSIVES_KEY] as Dictionary).size() == 4:
		ending = "res://Levels/Endings/ending_bombs.txt";
	
	$DialoguePlayer.start(ending,false,self);
	
	

func dial_action(id: String):
	if id == "finished":
		
		yield(get_tree().create_timer(2),"timeout");
		get_tree().change_scene("res://Scenes/Main/Credits.tscn");
