class_name TextFade
extends Label

signal finished_line;

const TIME_PER_CHAR = 0.01;

const PITCH_OFF = 0.1;
const STAY_ON_SCREEN = 1.5;

# points at which interpolation stops and starts
const STOPS = [
	".",":","?","!",",","-",
];
const DELAY_PER_STOP = 0.08;
const DELAY_PER_SPACE = 0.02;

var interpolating := false;

func _init():
	autowrap = true;
	text = "";

func set_text(t: String):
	
	if interpolating:
		yield(self,"finished_line");
	
	text = "";
	
	interpolating = !t.empty();
	
	var cur := 0;
	while interpolating:
		if t[cur] in STOPS:
			yield(get_tree().create_timer(DELAY_PER_STOP+TIME_PER_CHAR),"timeout");
		elif t[cur] == " ":
			yield(get_tree().create_timer(DELAY_PER_SPACE+TIME_PER_CHAR),"timeout");
		else:
			yield(get_tree().create_timer(TIME_PER_CHAR),"timeout");
		
		if cur % 4 == 0:
			Music.play_sfx(preload("res://Assets/Sounds/typing2.mp3"),rand_range(0.85,0.95),-15);
		
		text += t[cur];
		
		cur += 1;
		interpolating = cur < t.length();
	
	yield(get_tree().create_timer(STAY_ON_SCREEN),"timeout");
	emit_signal("finished_line")
