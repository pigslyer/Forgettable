extends Node2D

# footsteps farther than this don't get updated
const NEAR_TO_PLAYER = 300;

var audio_override_rects: Array;
var audio_override_streams: Array;
export (Array,AudioStream) var footstep_sounds;

onready var my_save_group = str("Room:",filename);
onready var tiles = $Navigation2D/TileMap;

func _ready():
	
	if !is_instance_valid(Groups.cur_room):
		Groups.cur_room = self;
	
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
				saveable.data_load(Save.save_data[my_save_group][path]);
	
	Groups.call_deferred("refresh_popup_disable_follow");
	get_tree().call_group(Groups.TECH_GOGGLES,"tech_goggles",Groups.get_player().has_goggles)
	
	var exceps: Array;
	var cur: int;

	# corrects pathfinding over joining different tiles
	for tile in tiles.get_used_cells():
		# first one is always 0...?
		cur = max(1,tiles.get_cellv(tile));
		exceps = [TileMap.INVALID_CELL,1,cur];
		if !(
				cur in exceps || 
				tiles.get_cellv(tile+Vector2.RIGHT) in exceps ||
				tiles.get_cellv(tile+Vector2.UP) in exceps ||
				tiles.get_cellv(tile+Vector2.LEFT) in exceps ||
				tiles.get_cellv(tile+Vector2.DOWN) in exceps
			):
			tiles.set_cell(tile.x,tile.y,cur,false,false,false,Vector2.ZERO);
	
	if Save.DROPPED_ITEM_KEY in Save.save_data[my_save_group]:
		var dropped;
		for item in Save.save_data[my_save_group][Save.DROPPED_ITEM_KEY]:
			
			dropped = preload("res://Scenes/Items/Pickup.tscn").instance();
			dropped.add_to_group(Groups.DROPPED_ITEM);
			dropped.remove_from_group(Groups.SAVING);
			$DroppedItems.add_child(dropped);
			dropped.drops = item[0];
			dropped.data_load(item[1]);
			dropped.position = item[2];
	
	Save.save_data[my_save_group][Save.DROPPED_ITEM_KEY] = [];
	
	# add footstep overrides
	for override in get_tree().get_nodes_in_group(FootstepOverride.GROUP):
		# overrides mayn't have a global_rotation != 0
		audio_override_rects.append(override.get_global_rect());
		audio_override_streams.append(override.sound_effect);
		override.remove_from_group(FootstepOverride.GROUP);
	
	var data;
	for override in get_tree().get_nodes_in_group(Groups.FOOTSTEP_OVERRIDE):
		data = override.get_foot_override();
		
		audio_override_rects.append(data[0]);
		audio_override_streams.append(data[1]);
		
		override.remove_from_group(Groups.FOOTSTEP_OVERRIDE);
	
	if filename in Save.save_data[Save.EXPLOSIVES_KEY]:
		var expl = load("res://Scenes/Misc/PlantedExplosive.tscn").instance();
		add_child(expl);
		expl.position = Save.save_data[Save.EXPLOSIVES_KEY][filename];

# returns true if planted
func plant_explosive(where: Vector2) -> bool:
	if filename in Save.save_data.get(Save.EXPLOSIVES_KEY,{}):
		return false;
	
	var expl = load("res://Scenes/Misc/PlantedExplosive.tscn").instance();
	add_child(expl);
	expl.global_position = where;
	Save.save_data[Save.EXPLOSIVES_KEY][filename] = to_local(where);
	
	return true;

func spawn_room(room: PackedScene, from: DoorTransition):
	var spawned = room.instance();
	get_parent().add_child(spawned);
	var door: DoorTransition = spawned.find_door_transition(from.leads_to_id);
	door.open_instantly();
	spawned.position += from.global_position-door.global_position;
	
	from.connect("closed",self,"unload_room",[door]);
	from.connect("closed",Groups,"set",["cur_room",spawned]);
	door.connect("closed",spawned,"unload_room",[from]);
	get_tree().call_group(Interactive.GROUP,"check_delete");

func unload_room(other: DoorTransition):
	save_data();
	for saveable in get_tree().get_nodes_in_group(my_save_group):
		Save.save_data[my_save_group][str(get_path_to(saveable))] = saveable.data_save();
	
	for dropped in get_tree().get_nodes_in_group(Groups.DROPPED_ITEM):
		if tiles.get_cellv(tiles.world_to_map(tiles.to_local(dropped.global_position))) != TileMap.INVALID_CELL:
			dropped.queue_free();
	
	other.close_safely();
	queue_free();


func save_data():
	for saveable in get_tree().get_nodes_in_group(my_save_group):
		Save.save_data[my_save_group][str(get_path_to(saveable))] = saveable.data_save();
	
	for dropped in get_tree().get_nodes_in_group(Groups.DROPPED_ITEM):
		if tiles.get_cellv(tiles.world_to_map(tiles.to_local(dropped.global_position))) != TileMap.INVALID_CELL:
			Save.save_data[my_save_group][Save.DROPPED_ITEM_KEY].append([
				dropped.drops,
				dropped.data_save(),
				to_local(dropped.position),
			]);

func find_door_transition(id: int):
	for node in get_tree().get_nodes_in_group(my_save_group):
		if node is DoorTransition && node.my_id == id:
			return node;
	return null;

# updates footsteps
func _physics_process(_delta):
	
	var idx: int;
	var sample: AudioStream;
	var player_pos = Groups.get_player().global_position;
	var foot_local_pos: Vector2;
	var playing: bool;
	
	for foot in get_tree().get_nodes_in_group(Groups.FOOTSTEP):
		if (foot.global_position.distance_squared_to(player_pos) < NEAR_TO_PLAYER*NEAR_TO_PLAYER):
			foot_local_pos = tiles.to_local(foot.global_position)
			idx = 0;
			playing = foot.playing;
			
			while idx < audio_override_rects.size():
				if audio_override_rects[idx].has_point(foot_local_pos):
					sample = audio_override_streams[idx];
					break;
				idx += 1;
			
			if idx == audio_override_rects.size() && tiles.get_cellv(tiles.world_to_map(foot_local_pos)) != TileMap.INVALID_CELL:
				sample = footstep_sounds[tiles.get_cellv(tiles.world_to_map(foot_local_pos))];
			
			if sample != foot.stream:
				foot.stream = sample;
				foot.playing = playing;
			
			sample = null;
