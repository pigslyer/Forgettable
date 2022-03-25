class_name Fade
extends ColorRect

# warning-ignore:unused_signal
signal finished_fade

var blocking: bool setget set_blocking;

export (bool) var start_blocking;
export (float) var trans_time = 0.7;

func _init():
	visible = true;

func _ready():
	color = Color.black;
	modulate = Color8(255,255,255,255 if start_blocking else 0);
	blocking = start_blocking;
	mouse_filter = MOUSE_FILTER_STOP if start_blocking else MOUSE_FILTER_IGNORE;

func set_blocking(state: bool):
	if blocking != state:
		blocking = state;
		
		var tween := Tween.new();
		add_child(tween);
		
		tween.interpolate_property(self,"modulate",null,Color8(255,255,255,255 if blocking else 0),trans_time,Tween.TRANS_CUBIC,Tween.EASE_IN);
		tween.start();
		
		yield(tween,"tween_all_completed");
		emit_signal("finished_fade");
		mouse_filter = MOUSE_FILTER_STOP if blocking else MOUSE_FILTER_IGNORE;
		tween.queue_free();
