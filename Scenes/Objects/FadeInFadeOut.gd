class_name AudioStreamPlayerFade
extends AudioStreamPlayer

const SILENT_VOLUME = -60;

var tween := Tween.new();

export (float) var fade_in = 0.2;
export (float) var fade_out = 0.2;

onready var volume_default = volume_db;

func _ready():
	add_child(tween);

func set_playing(state: bool):
	if playing != state && !tween.is_active():
		if playing:
			tween.interpolate_property(self,"volume_db",null,SILENT_VOLUME,fade_out);
			tween.start();
			yield(tween,"tween_all_completed");
			playing = false;
		else:
			volume_db = SILENT_VOLUME;
			tween.interpolate_property(self,"volume_db",SILENT_VOLUME,volume_default,fade_in);
			tween.start();
			
			playing = true;
