extends Node

# every node in footstep has to be an audiostreamplayer2d
const FOOTSTEP = "FOOTSTEP";
# should contain a method "get_foot_override" which returns
# an array with the structure [rect2, audiostream]
const FOOTSTEP_OVERRIDE = "Overrides_footstep";
const DROPPED_ITEM = "dropped_item_group";
# every saving node has to have a data_save and data_load method, which return save data and use it respectively
const SAVING = "SAVES"

const ENEMY = "ENEMY";

# has to be attached to popup. that popup will automatically stop the player's mouse from following while
# popped up and allow it again once hidden
const DISABLE_FOLLOW = "popup_disable_follow";

# when tech goggles are taken on/off, calls these classes'
# tech_goggles/1 method with the parameter on/off
const TECH_GOGGLES = "goggles";

# maps room group to room node
var rooms := {
	
};

var cur_room: Node;

func refresh_popup_disable_follow():
	var player = get_player();
	for popup in get_tree().get_nodes_in_group(DISABLE_FOLLOW):
		if !popup.is_connected("about_to_show",player,"follow_mouse"):
			popup.connect("about_to_show",player,"follow_mouse",[false]);
			popup.connect("popup_hide",player,"follow_mouse",[true],CONNECT_DEFERRED);
			popup.connect("popup_hide",get_viewport(),"set_input_as_handled");
			popup.connect("popup_hide",popup,"release_focus");


func get_player() -> Player:
	return get_tree().get_nodes_in_group("Player")[0];

func get_player_pos() -> Vector2:
	return get_tree().get_nodes_in_group("Player")[0].global_position;

func say_line(what: String, obj: Object = null):
	if !get_tree().get_nodes_in_group("Player").empty():
		get_player().say_line(what, obj);

func get_simple_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var navis = get_tree().get_nodes_in_group("Navigator");
	var path;
	var navi: Navigation2D;
	if navis.size() == 1:
		navi = navis[0];
	elif navis[0].get_closest_point(from).distance_squared_to(from) < navis[1].get_closest_point(from).distance_squared_to(from):
		navi = navis[0];
	else:
		navi = navis[1];
	
	path = navi.get_simple_path(from-navi.global_position,to-navi.global_position);
	
	# we never need point 0
	if !path.empty(): 
		path.remove(0);
		for idx in path.size():
			path[idx] += navi.global_position;
	
	return path;

func get_simple_path_player(from: Vector2) -> PoolVector2Array:
	return get_simple_path(from,get_player().global_position);

func get_my_room(node: Node) -> Node2D:
	for group in node.get_groups():
		if group.begins_with("Room:"):
			return rooms[group];
	return null;


# copy pasted, not very complex so idc
# literally here cuz it's a useful utility
static func get_absolute_z_index(target: Node2D) -> int:
	var node = target;
	var z_index = 0;
	while node and node.is_class('Node2D'):
		z_index += node.z_index;
		if !node.z_as_relative:
			break;
		node = node.get_parent();
	return z_index;
