extends VBoxContainer;

const TEXT_SPEED := 0.02;
const TIME_FULL := 5;
const STOPS = [".",",",":",";","?","!"];
const DELAY_PER_STOP = 0.16;
const TIME_PER_CHAR = 0.03;

var used: PoolStringArray;
var used_objs: Dictionary
var style_empty := StyleBoxEmpty.new();
var font := preload("res://Assets/UI/Font.tres").duplicate();

var to_remove: Array = [];

func _init():
	mouse_filter = MOUSE_FILTER_IGNORE;
	font.outline_size = 1;
	font.outline_color = Color.black;

func say_line(what: String, obj: Object = null):
	
	var new_msg := Message.new(what,obj);
	
	for msg in to_remove:
		if msg.equals(new_msg):
			return;
	
	to_remove.append(new_msg);
	
	var label := Label.new();
	new_msg.label = label;
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
	
	new_msg.time = OS.get_ticks_msec()+1000*(TEXT_SPEED*what.length()+TIME_FULL);

func _process(_delta):
	var idx := 0;
	while idx < to_remove.size():
		if to_remove[idx].check_delete():
			to_remove.remove(idx);
		else:
			idx += 1;

class Message extends Reference:
	var time: int = -1; var what: String; var label: Label; var obj: Object; 
	
	func _init(w: String, o: Object):
		what = w; obj = o;
	
	func check_delete() -> bool:
		if time != -1 && OS.get_ticks_msec() > time:
			label.queue_free();
			
			return true;
		
		return false;
	
	# if this returns true, this message is already in and we can't readd it
	func equals(msg: Message) -> bool:
		return msg.obj != null && msg.obj == obj && msg.what == what;

