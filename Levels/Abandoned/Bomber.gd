extends Sprite

func _physics_process(_delta):
	if $VisibilityNotifier2D.is_on_screen() && !$AnimationPlayer/Area2D.get_overlapping_bodies().empty():
		Groups.get_player().start_dial("res://Levels/Abandoned/bomber.txt",true,self);
		set_physics_process(false);
