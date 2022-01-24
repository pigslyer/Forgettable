class_name AudioStreamPlayerFade
extends AudioStreamPlayer

const SILENT_VOLUME = -60;

var tween := Tween.new();

export (float) var fade_in = 0.2;
export (float) var fade_out = 0.2;

func _ready():
	add_child(tween);

func set_playing(state: bool):
	if playing != state && !tween.is_active():
		if playing:
			tween.interpolate_property(self,"volume_db",0,SILENT_VOLUME,fade_out);
			tween.start();
			yield(tween,"tween_all_completed");
			playing = false;
		else:
			playing = true;
			tween.interpolate_property(self,"volume_db",SILENT_VOLUME,0,fade_in);
			tween.start();
