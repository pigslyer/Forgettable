extends Node2D

# footsteps farther than this don't get updated
const NEAR_TO_PLAYER = 300;

var audio_override_rects: Array;
var audio_override_streams: Array;
export (Array,AudioStream) var footstep_sounds;

onready var my_save_group = str("Room:",filename);
onready var tiles = $Navigation2D/TileMap;

func _ready():
	
	if !my_save_group in Save.save_data:
		Save.save_data[my_save_group] = {};
	
	var path: String;
	Groups.rooms[my_save_group] = self;
	
	for saveable in get_tree().get_nodes_in_group(Groups.SAVING):
		path = str(get_path_to(saveable));
		
		# if the node IS our direct descendant
		if !path.begins_with(".."):
			saveable.add_to_group(my_save_group);
			
			if Save.save_data[my_save_group].has(path):
				saveable.load_data(Save.save_data[my_save_group][path]);
	
	if Save.DROPPED_ITEM_KEY in Save.save_data[my_save_group]:
		var dropped;
		for item in Save.save_data[my_save_group][Save.DROPPED_ITEM_KEY]:
			
			dropped = preload("res://Scenes/Items/Pickup.tscn").instance();
			dropped.add_to_group(my_save_group);
			dropped.add_to_group(Groups.DROPPED_ITEM);
			dropped.remove_from_group(Groups.SAVING);
			Projectile.add_child(dropped);
			dropped.drops = item[0];
			dropped.load_data(item[1]);
			dropped.global_position = global_position+item[2];
	
	Groups.call_deferred("refresh_popup_disable_follow");
	
	Save.save_data[my_save_group][Save.DROPPED_ITEM_KEY] = [];
	
	var exceps: Array;
	var cur: int;
	
	# corrects pathfinding over joining different tiles
#	for tile in tiles.get_used_cells():
#		cur = tiles.get_cellv(tile);
#		exceps = [TileMap.INVALID_CELL,1,cur];
#		if !(
#				tiles.get_cellv(tile+Vector2.RIGHT) in exceps &&
#				tiles.get_cellv(tile+Vector2.UP) in exceps &&
#				tiles.get_cellv(tile+Vector2.LEFT) in exceps &&
#				tiles.get_cellv(tile+Vector2.DOWN) in exceps
#			):
#			tiles.set_cell(tile.x,tile.y,cur,false,false,false,Vector2.ZERO);
#


func spawn_room(room: PackedScene, from: DoorTransition):
	var spawned = room.instance();
	get_parent().add_child(spawned);
	var door: DoorTransition = spawned.find_door_transition(from.leads_to_id);
	door.open_instantly();
	spawned.align_by(door,from.global_position);
	
	from.connect("closed",spawned,"unload_room");
	door.connect("closed",self,"unload_room");


func unload_room():
	for saveable in get_tree().get_nodes_in_group(my_save_group):
		Save.save_data[my_save_group][str(get_path_to(saveable))] = saveable.save_data();
	
	for dropped in get_tree().get_nodes_in_group(Groups.DROPPED_ITEM):
		if tiles.get_cellv(tiles.world_to_map(dropped.global_position)) != TileMap.INVALID_CELL:
			Save[my_save_group][Save.DROPPED_ITEM_KEY].append([
				dropped.drops,
				dropped.save_data(),
				dropped.global_position-global_position,
			]);
	
	queue_free();


func find_door_transition(id: int):
	for node in get_tree().get_nodes_in_group(my_save_group):
		if node is DoorTransition && node.my_id == id:
			return node;
	return null;

func align_by(what: DoorTransition, where: Vector2):
	global_position += where-what.global_position;

# updates footsteps
func _physics_process(_delta):
	
	var idx: int;
	for foot in get_tree().get_nodes_in_group(Groups.FOOTSTEP):
		
		var player_pos = Groups.get_player().global_position;
		
		if (
				tiles.get_cellv(tiles.world_to_map(foot.global_position)) != TileMap.INVALID_CELL && 
				foot.global_position.distance_squared_to(player_pos) < 
				NEAR_TO_PLAYER*NEAR_TO_PLAYER
			):
			
			var sample: AudioStream;
			
			idx = 0;
			while idx < audio_override_rects.size():
				if audio_override_rects[idx].has_point(foot.global_position):
					sample = audio_override_streams[idx];
					break;
				idx += 1;
			
			if idx == audio_override_rects.size():
				sample = footstep_sounds[tiles.get_cellv(tiles.world_to_map(foot.global_position))];
			
			if sample != foot.stream: foot.stream = sample;
