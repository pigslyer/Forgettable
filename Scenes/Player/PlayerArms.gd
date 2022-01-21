extends AnimationPlayer

var types = ItemBase.Anim;

var animations := {
	types.UNDEFINED : ["hide_idle","hide_walk","hide_walk"],
	types.ONE_HANDED : ["one_handed_idle","one_handed_walk","one_handed_walk"],
	types.TWO_HANDED : ["two_handed_idle","two_handed_walk","two_handed_run"],
};

var walking: bool setget set_walking
var sprinting: bool setget set_sprinting;
var type: int;

var last_update = -INF;

func update_anim():
	if walking:
		play(animations[type][1+int(sprinting)]);
	else:
		play(animations[type][0]);
	
	last_update = OS.get_ticks_msec();

func set_walking(state: bool):
	if walking != state:
		walking = state;
		update_anim();

func set_sprinting(state: bool):
	if state != sprinting:
		sprinting = state;
		update_anim();

func _on_Player_equipped_new():
	var equipped: ItemBase = Groups.get_player().equipped_item;
	if equipped == null: type = types.UNDEFINED;
	else:
		type = equipped.animation_type;
	update_anim();
