class_name PitchRandomizer
extends AudioStreamPlayer2D

onready var starting_pitch = pitch_scale;
export (float) var rng = 0.05;

func play(from: float = 0.0):
	pitch_scale = starting_pitch + rand_range(-rng,rng);
	.play(from);
