extends AudioStreamPlayer

export (float) var off = 0.05;

onready var starting_scale = pitch_scale;

func play(from: float = 0.0):
	pitch_scale = starting_scale + rand_range(-off,off);
	.play(from);
