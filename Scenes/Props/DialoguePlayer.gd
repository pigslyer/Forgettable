extends CanvasLayer

const CHOICE_GROUP = "choice"
const TIME_PER_CHAR = 0.03;
const STARTUP_TIME = 0.3;

const PITCH_OFF = 0.05;

# points at which interpolation stops and starts
const STOPS = [
	".",":","?","!",","
];
const DELAY_PER_STOP = 0.16;

var reader: Dialogue;
var one_timed: Array;

var last_choice_caret: int;

var interpolating := false;
onready var line: Label = $Theme/VSplitContainer/Line;

func start(path: String, one_time: bool = true, actions: Node = null):
	if !(path in one_timed && one_time):
		$Theme.popup();
		reader = Dialogue.new(path);
		last_choice_caret = -1;
		$Theme/VSplitContainer/Line.text = "";
		if one_time:
			one_timed.append(path);
		if actions != null:
			reader.connect("perform_action",actions,"dial_action");
		
		next(-1,true);


func stop():
	$Theme.hide();
	var data = reader.get_signal_connection_list("perform_action");
	if !data.empty():
		reader.disconnect("perform_action",data[0]["target"],data[0]["method"]);

func next(next: int = -1, startup: bool = false):
	
	var cur_line = reader.get_line(next);
	
	if !(cur_line is PoolStringArray && reader.caret == last_choice_caret):
		get_tree().call_group(CHOICE_GROUP,"queue_free");
	
	if cur_line is String:
		last_choice_caret = -1;
		# player line
		if cur_line.begins_with(":"):
			$Theme/VSplitContainer/Name.text = "You";
			if startup:
				yield(get_tree().create_timer(STARTUP_TIME),"timeout");
			show_line(cur_line.substr(1), 0);
		# anon line
		elif cur_line.begins_with(";"):
			$Theme/VSplitContainer/Name.text = "";
			if startup:
				yield(get_tree().create_timer(STARTUP_TIME),"timeout");
			show_line(cur_line.substr(1), 2);
		# other line
		else:
			$Theme/VSplitContainer/Name.text = reader.talking_to;
			if startup:
				yield(get_tree().create_timer(STARTUP_TIME),"timeout");
			show_line(cur_line, 1);
	
	elif cur_line is PoolStringArray && reader.caret != last_choice_caret:
		last_choice_caret = reader.caret;
		
		var idx := 0;
		var label: Button;
		for choice in cur_line:
			label = Button.new();
			label.text = choice;
			label.add_to_group(CHOICE_GROUP);
			label.grow_horizontal = Control.GROW_DIRECTION_BOTH;
			$Theme/Choices.add_child(label);
			label.connect("pressed",self,"next",[idx]);
			idx += 1;
	
	elif cur_line == null:
		stop();

# 0 - player, 1 - other, 2 - anon
func show_line(text: String, talking_to: int):
	interpolating = true;
	
	$Theme/VSplitContainer/Line.text = "";
	
	var idx := 0;
	
	var pitch_min: float; var pitch_max: float; var pitch: float;
	var speed: int;
	
	if talking_to == 0:
		pitch = reader.pitch_player; speed = reader.speed_player;
	elif talking_to == 1:
		pitch = reader.pitch_other; speed = reader.speed_other;
	else:
		pitch = reader.pitch_anon; speed = reader.speed_anon;
	
	pitch_min = pitch-PITCH_OFF; pitch_max = pitch+PITCH_OFF;
	
	while interpolating:
		if text[idx-1] in STOPS:
			yield(get_tree().create_timer(DELAY_PER_STOP+TIME_PER_CHAR),"timeout");
		else:
			yield(get_tree().create_timer(TIME_PER_CHAR),"timeout");
		
		if idx%speed==0:
			Music.play_sfx(preload("res://Assets/Sounds/typing2.mp3"),rand_range(pitch_min,pitch_max),-10);
		
		$Theme/VSplitContainer/Line.text += text[idx];
		idx += 1;
		
		interpolating = idx < text.length() && interpolating;
	
	$Theme/VSplitContainer/Line.text = text;

func _on_Panel_gui_input(ev):
	if ev.is_action_pressed("lmb"):
		if interpolating:
			interpolating = false;
		else:
			next();
