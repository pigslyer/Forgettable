extends Node

const FADE_OUT = 0.3;
const FADE_IN = 0.3;

const SILENT_VOLUME = -60;

const MUSIC := {
	AMBIENT = preload("res://Assets/Music/MenuTheme.wav"),
	COMBAT = preload("res://Assets/Music/BattleTheme.wav"),
};

var _player := AudioStreamPlayer.new();

func _ready():
	add_child(_player);

func play_music(stream: AudioStream):
	var tween := Tween.new();
	add_child(tween);
	
	if _player.playing:
		tween.interpolate_property(_player,"volume_db",0,SILENT_VOLUME,FADE_OUT);
		tween.start();
		yield(tween,"tween_all_completed");
	
	_player.stream = stream;
	_player.play();
	tween.interpolate_property(_player,"volume_db",SILENT_VOLUME,0,FADE_IN);
	tween.interpolate_callback(tween,FADE_IN,"queue_free");
	tween.start();
	
