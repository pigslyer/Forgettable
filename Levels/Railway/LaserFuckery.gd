extends Node2D



func _on_PlayerDetection_body_exited(body: Node2D):
	$Platform.visible = body.global_position.distance_squared_to($Top.global_position) > body.global_position.distance_squared_to($Bottom.global_position);
	$Stairs.visible = $Platform.visible;
