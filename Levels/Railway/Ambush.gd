extends Area2D


func _on_Ambush_body_exited(_body):
	get_tree().call_group("Group:GuardProc","set_detected",true);
