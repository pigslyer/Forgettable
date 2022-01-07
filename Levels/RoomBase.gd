extends Node2D

# footsteps farther than this don't get updated
const NEAR_TO_PLAYER = 300;

var audio_override_rects: Array;
var audio_override_streams: Array;
export (Array,AudioStream) var footstep_sounds;

onready var my_save_group = filename;
onready var tiles = $Navigation2D/TileMap;

func _ready():
	
	VisualServer.set_default_clear_color(Color.black);
	
	Save.save_data[my_save_group] = {};
	
	var path: String;
	
	for saveable in get_tree().get_nodes_in_group(Groups.SAVING):
		path = str(get_path_to(saveable));
		
		# if the node IS our direct descendant
		if !path.begins_with(".."):
			saveable.add_to_group(my_save_group);
			Groups.saveables[saveable.get_path()] = self;
			
			if Save.save_data[my_save_group].has(path):
				saveable.load_data(Save.save_data[my_save_group][path]);

func _physics_process(_delta):
	
	var idx: int;
	for foot in get_tree().get_nodes_in_group(Groups.FOOTSTEP):
		
		if foot.global_position.distance_squared_to(Groups.get_player().global_position) < NEAR_TO_PLAYER*NEAR_TO_PLAYER:
			
			idx = 0;
			while idx < audio_override_rects.size():
				if audio_override_rects[idx].has_point(foot.global_position):
					foot.stream = audio_override_streams[idx];
					continue;
			
			foot.stream = footstep_sounds[tiles.get_cellv(tiles.world_to_map(foot.global_position))];
	

