tool

class_name FootstepOverride
extends TextureRect

# removed from group by room
const GROUP = "Footstep_override_group";

export (AudioStream) var sound_effect;

func _ready():
	expand = true;
	stretch_mode = STRETCH_TILE;
	add_to_group(GROUP);
	mouse_filter = MOUSE_FILTER_IGNORE;
	if rect_size == Vector2(40,40):
		rect_size = Vector2(32,32);
	
	if get_parent() is Control:
		push_warning(str(get_path()," may have issues correctly playing sound."));
