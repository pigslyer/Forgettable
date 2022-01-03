extends VBoxContainer;

const TEXT_SPEED := 0.02;
const TIME_FULL := 5;

var used: PoolStringArray;
var style_empty := StyleBoxEmpty.new();

func say_line(what: String):
	
	if what in used:
		return;
	
	var label := Label.new();
	used.append(what);
	add_child(label);
	label.autowrap = true;
	label.align = Label.ALIGN_CENTER;
	label.add_stylebox_override("normal",style_empty);
	
	var cur := 1;
	
	while cur <= what.length():
		$Tween.interpolate_callback(label,TEXT_SPEED*cur,"set_text",what.substr(0,cur));
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



