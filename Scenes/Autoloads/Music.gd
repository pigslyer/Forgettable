extends Node

const MUSIC := [
	
];

var _player := AudioStreamPlayer.new();

func _ready():
	add_child(_player);

func play_music(stream: AudioStream):
	_player.stream = stream;
	_player.play();
