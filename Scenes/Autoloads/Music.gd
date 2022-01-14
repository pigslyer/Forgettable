extends Node

const FADE_OUT = 0.3;
const FADE_IN = 0.3;

const SILENT_VOLUME = -60;

const MUSIC := {
	AMBIENT = preload("res://Assets/Music/MenuTheme.wav"),
	COMBAT = preload("res://Assets/Music/BattleTheme.wav"),
};

var _player := AudioStreamPlayer.new();

var tween := Tween.new();

func _init():
	VisualServer.set_default_clear_color(Color.black);
	add_child(_player);
	_player.bus = "Music";
	add_child(tween);

func play_music(stream: AudioStream, fade: bool = true):
	if tween.is_active() || _player.stream == stream:
		return;
	
	if _player.playing && _player.stream != null && fade:
		tween.interpolate_property(_player,"volume_db",0,SILENT_VOLUME,FADE_OUT);
		tween.start();
		yield(tween,"tween_all_completed");
	
	_player.stream = stream;
	
	if stream != null && fade:
		_player.play();
		tween.interpolate_property(_player,"volume_db",SILENT_VOLUME,0,FADE_IN);
		tween.start();
	elif stream != null:
		_player.play();
	
