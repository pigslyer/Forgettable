class_name Dialogue
extends Reference

signal perform_action(id);

var talking_to: String;
var caret: int = 0;
var lines: PoolStringArray;

var speed_player: int = 4;
var speed_other: int = 4;
var speed_anon: int = 4;

const SPEED := {
	"low" : 5,
	"medium" : 4,
	"high" : 3,
};

var pitch_player: float = 1.1;
var pitch_other: float = 0.8;
var pitch_anon: float = 1;

const PITCH = {
	"low" : 0.7,
	"medium" : 0.9,
	"high" : 1.1,
};

func _init(path: String):
	var file := File.new();
	file.open(path,File.READ);
	lines = compile(file.get_as_text());
	file.close();

func get_line(next: int = -1):
	var cur_line := lines[caret];
	caret += 1;
	var split := cur_line.split(" ",false,2);
	return _read_line(cur_line,split[0],split[1] if split.size() > 1 else "",next);

func _read_line(line: String, first_word: String, second_word: String, next: int):
	match first_word:
		"/talking_to":
			var split = line.split(" ",false,1);
			talking_to = split[1] if split.size() > 1 else "";
		
		"/choice":
			return line.split(" ",true,1)[1].split("||",true);
		
		"/choices":
			var split := second_word.split("||",false);
			if next == -1 || next >= split.size():
				caret -= 2;
			else:
				caret = int(split[next]);
		
		"/goto":
			caret = int(second_word);
		
		"/end":
			return null;
		
		"/action":
			emit_signal("perform_action",second_word);
		
		"/speed":
			var val = SPEED.get(line.split(" ",false)[2],4);
			if second_word == "player":
				speed_player = val;
			elif second_word == "other":
				speed_other = val;
			elif second_word == "anon":
				speed_anon = val;
			else:
				push_error(str("Couldn't set speed at line ",caret,"."));
		
		"/pitch":
			var val = PITCH.get(line.split(" ",false)[2],PITCH["medium"]);
			if second_word == "player":
				pitch_player = val;
			elif second_word == "other":
				pitch_other = val;
			elif second_word == "anon":
				pitch_anon = val;
			else:
				push_error(str("Couldn't set pitch at line ",caret,"."));
		
		"/update":
			Save.cur_objective = line.split(" ",false,1)[1];
		
		_:
			return line;
	
	return get_line();

static func compile(text: String) -> PoolStringArray:
	
	var start = OS.get_ticks_usec();
	
	# ensure text is ended
	text += "\n/end\n"

	# compile choices
	
	var split: PoolStringArray = text.split("\n",false)
	var idx := 0
	var begin: int
	var poses: PoolIntArray
	var num_of: int
	var gotos: String
	var return_from: Array = [];
	
	while idx < split.size():
		split[idx] = split[idx].strip_edges();
		if split[idx].empty():
			split.remove(idx);
		else:
			idx += 1;
	
	idx = 0;
	
	while (idx < split.size()):
		if (split[idx] == "{"):
			begin = idx
			poses = []
			num_of = 0
			idx += 1
			return_from.clear();
			while (idx < split.size() && !(split[idx] == "}" && num_of == 0)):
				if (split[idx].begins_with("::") && num_of == 0):
					poses.append(idx)
					return_from.append(split[idx].begins_with(":::"));
				elif (split[idx] == "{"):
					num_of += 1
				elif (split[idx] == "}"):
					num_of -= 1
				idx += 1
			
			# if last choice is a return from choice
			# yes, i agree
			if return_from[-1]:
				split.insert(idx,"::/");
				poses.append(idx);
				idx += 1;
			
			split[begin] = "/choice "
			gotos = "/choices "
			var jdx: int = 0;
			for pos in poses:
				gotos += str(pos+2,"||")
				# you may hate me, future me, but it works
				
				if split[pos] != "::/":
					if return_from[jdx]:
						split[begin] += split[pos].substr(3)+"||";
					else:
						split[begin] += split[pos].substr(2)+"||"
				
				if return_from[jdx-1]:
					split[pos] = str("/goto ",begin);
				else:
					split[pos] = "/goto "+str(idx+1)
				
				jdx += 1;
			
			# this gives an out of bounds error, but everything *looks* fine so um, cool?
			if idx < split.size():
				split.remove(idx)
			split.insert(begin+1,gotos)
			idx = begin+2
		idx += 1
	
	prints(OS.get_ticks_msec(),": compiling took:",OS.get_ticks_usec()-start, " usecs.");
	
	return split
