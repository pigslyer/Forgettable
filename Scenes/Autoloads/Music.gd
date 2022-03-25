extends Node

const FADE_OUT = 0.7;
const FADE_IN = 0.4;

const INGAME_MUSIC = -10;
const SILENT_VOLUME = -60;

const MUSIC := {
	AMBIENT = preload("res://Assets/Music/MenuTheme.wav"),
	COMBAT = preload("res://Assets/Music/BattleTheme.wav"),
};

var _player := AudioStreamPlayer.new();

var tween := Tween.new();

func music_in_game(state: bool):
	tween.interpolate_property(_player,"volume_db",null,INGAME_MUSIC if state else -5,2.4,Tween.TRANS_EXPO);
	tween.start();

func _init():
	VisualServer.set_default_clear_color(Color.black);
	add_child(_player);
	_player.bus = "Music";
	add_child(tween);
	_player.connect("finished",_player,"play");
	_player.volume_db = -5;
	_player.pause_mode = PAUSE_MODE_PROCESS;

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

func play_sfx(stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0, pos = null):
	var player;
	if pos == null:
		player = AudioStreamPlayer.new();
	else:
		player = AudioStreamPlayer2D.new();
		player.position = pos;
	
	player.stream = stream;
	player.pitch_scale = pitch;
	player.volume_db = volume_db;
	player.bus = "SFX"
	add_child(player);
	player.connect("finished",player,"queue_free");
	player.play();
	
	return player;
