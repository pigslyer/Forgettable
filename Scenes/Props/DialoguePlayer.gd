extends CanvasLayer

const CHOICE_GROUP = "choice"
const TIME_PER_CHAR = 0.02;

var reader: Dialogue;
var one_timed: Array;

var last_choice_caret: int;

func start(path: String, one_time: bool = true, actions: Node = null):
	if !(path in one_timed && one_time):
		$Theme.popup();
		reader = Dialogue.new(path);
		last_choice_caret = -1;
		if one_time:
			one_timed.append(path);
		if actions != null:
			reader.connect("perform_action",actions,"dial_action");
		next();


func stop():
	$Theme.hide();
	var data = reader.get_signal_connection_list("perform_action");
	if !data.empty():
		reader.disconnect("perform_action",data[0]["target"],data[0]["method"]);

func next(next: int = -1):
	
	var line = reader.get_line(next);
	
	if !(line is PoolStringArray && reader.caret == last_choice_caret):
		get_tree().call_group(CHOICE_GROUP,"queue_free");
	
	if line is String:
		# player line
		if line.begins_with(":"):
			$Theme/Panel/VSplitContainer/Name.text = "You";
			show_line(line.substr(1));
		# other line
		else:
			$Theme/Panel/VSplitContainer/Name.text = reader.talking_to;
			show_line(line);
	
	elif line is PoolStringArray && reader.caret != last_choice_caret:
		last_choice_caret = reader.caret;
		
		var idx := 0;
		var label: Button;
		for choice in line:
			label = Button.new();
			label.text = choice;
			label.add_to_group(CHOICE_GROUP);
			label.grow_horizontal = Control.GROW_DIRECTION_BOTH;
			$Theme/Choices.add_child(label);
			label.connect("pressed",self,"next",[idx]);
			idx += 1;
	
	elif line == null:
		stop();

func show_line(text: String):
	$Theme/Panel/VSplitContainer/Line.percent_visible = 0;
	$Theme/Panel/VSplitContainer/Line.text = text;
	$Tween.interpolate_property($Theme/Panel/VSplitContainer/Line,"percent_visible",0,1,text.length()*TIME_PER_CHAR,Tween.TRANS_SINE);
	$Tween.start();

func _on_Panel_gui_input(ev):
	if ev.is_action_pressed("lmb"):
		if $Tween.is_active():
			$Tween.seek($Tween.get_runtime());
		else:
			next();
