extends Node2D

# footsteps farther than this don't get updated
const NEAR_TO_PLAYER = 300;

var audio_override_rects: Array;
var audio_override_streams: Array;
export (Array,AudioStream) var footstep_sounds;

onready var tiles = $Navigation2D/TileMap;

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
	
	
