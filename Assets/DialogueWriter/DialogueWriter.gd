extends Control

enum{
	SAVING,
	LOADING,
};

var mode: int;
var in_use: String = "";

var current_opened := false;

func _ready():
	$DialoguePlayer/Theme.popup_exclusive = false;
	$FileDialog.current_dir = OS.get_executable_path().get_base_dir();

func open():
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE;
	$FileDialog.popup();
	mode = LOADING;

func save():
	if current_opened:
		mode = SAVING;
		file_chosen(in_use);
	else:
		save_as();

func save_as():
	$FileDialog.mode = FileDialog.MODE_SAVE_FILE;
	$FileDialog.popup();
	mode = SAVING;

func file_chosen(path: String):
	var file := File.new();
	
	if mode == SAVING:
		file.open(path,File.WRITE);
		file.store_string($TextEdit.text);
	elif mode == LOADING:
		file.open(path,File.READ);
		$TextEdit.text = file.get_as_text();
	
	$VBoxContainer/Name.text = path.get_file();
	
	in_use = path;
	current_opened = true;
	file.close();

func play():
	if !in_use.empty():
		$DialoguePlayer.start(in_use,false,self);

func dial_action(id):
	$VBoxContainer/SayLine.say_line(str("Performed action: ",id));
