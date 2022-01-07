class_name Dialogue
extends Reference

var talking_to: String;
var caret: int;
var lines: PoolStringArray;

func _init(path: String):
	var file := File.new();
	file.open(path,File.READ);
	lines = file.get_as_text().split("\n");
	file.close();
	caret = 0;

func get_line(next: int = -1):
	var cur_line := lines[caret];
	caret += 1;
	var split := cur_line.split(" ",false,2);
	return _read_line(cur_line,split[0],split[1] if split.size() > 1 else "",next);

func _read_line(line: String, first_word: String, second_word: String, next: int):
	match first_word:
		"/talking_to":
			talking_to = line.split(" ",false,1)[1];
		
		"/choice":
			return line.split(" ",true,1)[1].split("||",false);
		
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
			
		_:
			return line;
	
	return get_line();

static func compile(text: String) -> String:
	
	# remove indents
	text = text.replace("	","").replace("    ","")
	# ensure text is ended
	text += "\n/end"
	
	# remove comments
	text += "\n"
	var comment: int = text.find("##")
	while comment != -1:
		text.erase(comment,text.find("\n",comment)-comment)
		comment = text.find("##",comment)
	
	# compile choices
	
	var split: PoolStringArray = text.split("\n",false)
	var idx := 0
	var begin: int
	var poses: PoolIntArray
	var num_of: int
	var gotos: String
	
	while idx < split.size():
		split[idx] = split[idx].strip_edges();
		idx += 1;
	
	idx = 0;
	
	while (idx < split.size()):
		if (split[idx] == "{"):
			begin = idx
			poses = []
			num_of = 0
			idx += 1
			while (idx < split.size() && !(split[idx] == "}" && num_of == 0)):
				
				if (split[idx].begins_with("::") && num_of == 0):
					poses.append(idx)
				elif (split[idx] == "{"):
					num_of += 1
				elif (split[idx] == "}"):
					num_of -= 1
				idx += 1
			
			split[begin] = "/choice "
			gotos = "/choices "
			for pos in poses:
				split[begin] += split[pos].substr(2)+"||"
				gotos += str(pos+2,"||")
				split[pos] = "/goto "+str(idx+1)
			
			# this gives an out of bounds error, but everything *looks* fine so um, cool?
			if idx < split.size():
				split.remove(idx)
			split.insert(begin+1,gotos)
			idx = begin+2
		idx += 1
	
	return split.join("\n");
