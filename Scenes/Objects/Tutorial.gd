class_name Tutorial
extends SayLine

export (Array,String) var actions;

func _detected_player(_body):
	if !disabled:
		Groups.get_player().tutorial_show(message,actions);
		if onetime:
			queue_free();
			Save.save_my_data(self);

func finish():
	Groups.get_player().tutorial_hide();
	if onetime:
		queue_free();
		Save.save_my_data(self);
