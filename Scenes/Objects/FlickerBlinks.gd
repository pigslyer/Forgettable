class_name FlickerBlinks
extends Flicker

export (bool) var randomize_state = true;
export (float) var stays_on = 0.2;
export (float) var stays_off = 0.2;

export (bool) var pre_proc_on = true;

var stayed: float;

func _ready():
	if randomize_state:
		stayed = rand_range(0,max(stays_on,stays_off));

func _process(delta):
	if visi.is_on_screen() && (queue.empty() || queue.size() == smoothing):
		stayed += delta;
		
		if (stayed > stays_on && on) || (stayed > stays_off && !on):
			on = !on;
			stayed = 0;
			
			if on && pre_proc_on:
				pre_proc();
