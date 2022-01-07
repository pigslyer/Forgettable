extends Control

enum{
	SAVING,
	LOADING,
};

const COMPILED_EXTENSION = ".dial"

var mode: int;
var in_use: String;

var current_opened := false;
var current_compiled := false;

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
	current_compiled = file.file_exists(path.get_basename()+COMPILED_EXTENSION);
	file.close();

func compile():
	if current_opened:
		var file := File.new();
		file.open(in_use,File.READ);
		var compiled = Dialogue.compile(file.get_as_text());
		file.close();
		file.open(in_use.get_basename()+COMPILED_EXTENSION,File.WRITE);
		file.store_string(compiled);
		file.close();
		current_compiled = true;

func play():
	if current_compiled:
		$DialoguePlayer.path = in_use.get_basename()+COMPILED_EXTENSION;
		$DialoguePlayer.start();

