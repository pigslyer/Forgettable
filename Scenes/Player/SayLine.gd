extends VBoxContainer;

const TEXT_SPEED := 0.02;
const TIME_FULL := 5;
const STOPS = [".",",",":",";","?","!"];
const DELAY_PER_STOP = 0.16;
const TIME_PER_CHAR = 0.03;

var used: PoolStringArray;
var style_empty := StyleBoxEmpty.new();
var font := preload("res://Assets/UI/Font.tres").duplicate();

func _init():
	mouse_filter = MOUSE_FILTER_IGNORE;
	font.outline_size = 1;
	font.outline_color = Color.black;

func say_line(what: String):
	
	# bit of hardcoding, some messages are better displayed multiple times
	if what != "The door's locked." && what in used:
		return;
	
	var label := Label.new();
	used.append(what);
	add_child(label);
	label.autowrap = true;
	label.align = Label.ALIGN_CENTER;
	label.add_stylebox_override("normal",style_empty);
	label.add_font_override("font",font);
	
	var cur := 0;
	
	while cur < what.length():
		if what[cur-1] in STOPS:
			yield(get_tree().create_timer(DELAY_PER_STOP+TIME_PER_CHAR),"timeout");
		else:
			yield(get_tree().create_timer(TIME_PER_CHAR),"timeout");
		
		if cur%4==0:
			Music.play_sfx(preload("res://Assets/Sounds/typing2.mp3"),rand_range(0.85,0.95),-10);
		
		label.text += what[cur];
		cur += 1;
	
	$Tween.interpolate_callback(self,TEXT_SPEED*what.length()+TIME_FULL,"_remove_entry", what, label);
	$Tween.start();

func _remove_entry(what: String, label: Label):
	label.queue_free();
	
	var idx := 0;
	while idx < used.size():
		if used[idx] == what:
			used.remove(idx);
			break;
		idx += 1;



