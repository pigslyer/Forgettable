extends Area2D

const KEY_PATH = "res://Levels/Abandoned/Prison/PrisonKey.tscn";
const DIAL_PATH = "";

func data_save():
	return false;

func data_load(data):
	if data: queue_free();

func _on_LoreleiCall_body_entered(body: Player):
	if body.get_waffle().count_item(KEY_PATH) > 0:
		body.start_dial(DIAL_PATH);
		Save.save_my_data(self,true);
		queue_free();
