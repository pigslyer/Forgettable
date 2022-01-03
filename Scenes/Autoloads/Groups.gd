extends Node

# every node in footstep has to be an audiostreamplayer2d
const FOOTSTEP = "FOOTSTEP";
const DROPPED_ITEM = "dropped_item_group";
# every saving node has to have a data_save and data_load method, which return save data and use it respectively
const SAVING = "SAVES"

# has to be attached to popup. that popup will automatically stop the player's mouse from following while
# popped up and allow it again once hidden
const DISABLE_FOLLOW = "popup_disable_follow";

func refresh_popup_disable_follow():
	var player = get_player();
	for popup in get_tree().get_nodes_in_group(DISABLE_FOLLOW):
		if !popup.is_connected("about_to_show",player,"follow_mouse"):
			popup.connect("about_to_show",player,"follow_mouse",[false]);
			popup.connect("popup_hide",player,"follow_mouse",[true]);


func get_player() -> Player:
	return get_tree().get_nodes_in_group("Player")[0];

func say_line(what: String):
	get_player().say_line(what);

func get_simple_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var navis = get_tree().get_nodes_in_group("Navigator");
	if navis.size() == 1:
		return navis[0].get_simple_path(from,to);
	elif navis[0].get_closest_point(from).distance_squared_to(from) < navis[1].get_closest_point(from).distance_squared_to(from):
		return navis[0].get_simple_path(from,to);
	return navis[1].get_simple_path(from,to);
