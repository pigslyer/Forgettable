class_name FlickerBlinks
extends Flicker

const GROUP_BLINKS = "FlickerBlinks";

export (bool) var randomize_state = true;
export (float) var stays_on = 0.2;
export (float) var stays_off = 0.2;

export (bool) var pre_proc_on = true;

var stayed: float;

export (bool) var blink = true setget set_blink;

func _ready():
	add_to_group(GROUP_BLINKS);
	if randomize_state:
		stayed = rand_range(0,max(stays_on,stays_off));

func set_blink(state: bool):
	blink = state;

func _process(delta):
	if visi.is_on_screen() && (queue.empty() || queue.size() == smoothing):
		stayed += delta;
		
		if (stayed > stays_on && on) || (stayed > stays_off && !on) && blink:
			on = !on;
			stayed = 0;
			
			if on && pre_proc_on:
				fill_to(0.5);
