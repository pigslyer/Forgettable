extends WorldState

func _on_AlertPlace_player_entered(_body):
	$Skully.pop_out();
