extends Node

signal world_state_changed(new_state);

enum STATE{
	PIPE = 0b1,
	DETECTOR = 0b10,
	LORELEI = 0b100,
};

# key for dictionary, not key for keycard
const DROPPED_ITEM_KEY = "Dropped_Items";
const EXPLOSIVES_KEY = "Explosives";

# DON'T FORGET TO SET THIS ON NEW GAME
var cur_state: int = STATE.PIPE setget cur_state_changed;
var cur_objective: String = "No objective.";
var detecting: int = 0 setget set_detecting;

func set_detecting(new_val: int):
	detecting = new_val;
	Music.play_music(Music.MUSIC.AMBIENT if detecting == 0 else Music.MUSIC.COMBAT);

func cur_state_changed(new_state: int):
	cur_state = new_state;
	emit_signal("world_state_changed",new_state);

# used for both room and normal data
var save_data := {
	EXPLOSIVES_KEY : {}
};

func can_save() -> bool:
	return detecting == 0;

# if null, it'll call save_data, otherwise it'll take the data passed along
func save_my_data(node: Node, data = null):
	if node.is_in_group(Groups.SAVING):
		var room = Groups.get_my_room(node);
		save_data[room.my_save_group][str(room.get_path_to(node))] = node.data_save() if data == null else data;
	elif !node.is_in_group(Groups.DROPPED_ITEM):
		push_error("Item which is neither saveable nor dropped tried to save.");

const SAVE_DIR = "user://saves/";

func _ready():
	var dir := Directory.new();
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR);

func get_saves() -> PoolStringArray:
	var ret: Array = [];
	
	var dir := Directory.new();
	dir.open(SAVE_DIR);
	
	dir.list_dir_begin();
	
	var next = dir.get_next();
	
	while !next.empty():
		if next.get_extension() == "sav":
			ret.append(next);
		next = dir.get_next();
	
	ret.sort_custom(self,"_sort_custom");
	
	return PoolStringArray(ret);

func _sort_custom(a: String, b: String):
	# i love memory inefficient things
	var file := File.new();
	return file.get_modified_time(SAVE_DIR+a) > file.get_modified_time(SAVE_DIR+b);

func save_game(path: String):
	
	var conf := ConfigFile.new();
	
	Groups.cur_room.save_data();
	conf.set_value("DATA","save_data",save_data);
	conf.set_value("DATA","player_data",Groups.get_player().save_data());
	conf.set_value("DATA","current_room",[Groups.cur_room.filename,Groups.cur_room.global_position]);
	conf.set_value("DATA","state",cur_state);
	conf.set_value("DATA","objective",cur_objective);
	
	conf.save(SAVE_DIR+path+".sav");

func load_game(path: String):
	
	var conf := ConfigFile.new();
	conf.load(SAVE_DIR+path+".sav");
	
	save_data = conf.get_value("DATA","save_data",{});
	cur_objective = conf.get_value("DATA","objective","");
	cur_state = conf.get_value("DATA","state");
	
	for node in Projectile.get_children():
		node.queue_free();
	
	get_tree().change_scene("res://Scenes/Main/MainLoad.tscn");
	
	# wait for scene switch
	yield(get_tree(),"idle_frame");
	
	Groups.get_player().load_data(conf.get_value("DATA","player_data"));
	get_tree().current_scene.load_room(conf.get_value("DATA","current_room"));
	get_tree().call_group(Interactive.GROUP,"check_delete");

func delete_save(path: String):
	var dir := Directory.new();
	dir.remove(SAVE_DIR+path+".sav");
	

const GLOBAL_SAVE = "user://settings.ini";

# hue hue hue, someone might think that they can hack the saves but they'd
# be wrong
enum ENDS{
	NONE = 0,
	FINISHED = 1014118,
	NASIF = 8535155,
};

var ending = ENDS.NONE;

func global_save():
	var conf := ConfigFile.new();
	
	conf.set_value("DATA","ending",ending);
	
	conf.set_value("DATA","vol_master",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")));
	conf.set_value("DATA","vol_music",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")));
	conf.set_value("DATA","vol_sfx",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")));
	
	conf.save(GLOBAL_SAVE);

func global_load():
	var conf := ConfigFile.new();
	conf.load(GLOBAL_SAVE);
	
	ending = conf.get_value("DATA","ending",ENDS.NONE);
	if !(ending in ENDS.values()):
		ending = ENDS.NONE;
		# i don't know if anyone will ever hear this, but it's funny
		Music.play_sfx(load("res://Assets/LiamNoises/death1.wav"));
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),conf.get_value("DATA","vol_master",-10));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),conf.get_value("DATA","vol_music",-10));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),conf.get_value("DATA","vol_sfx",-10));

func global_save_exists() -> bool:
	var dir := Directory.new();
	return dir.file_exists(GLOBAL_SAVE);
