class_name PitchRandomizer
extends AudioStreamPlayer2D

onready var starting_pitch = pitch_scale;
export (float) var rng = 0.05;

export (bool) var autoloop = false;
export (float) var autoloop_interval = 0.2;

func _ready():
	if autoloop:
		var timer := Timer.new();
		add_child(timer);
		timer.wait_time = autoloop_interval;
		connect("finished",timer,"start");
		timer.connect("timeout",self,"play");

func play(from: float = 0.0):
	pitch_scale = starting_pitch + rand_range(-rng,rng);
	.play(from);
