extends Area2D


func recheck():
	$WallDetection.global_rotation = 0;
	for item in get_overlapping_areas():
		check_inter(item.get_parent());
	
func check_inter(inter):
	assert(inter is Interactive);
	
	$WallDetection.cast_to = inter.collision.global_position-global_position;
	$WallDetection.force_raycast_update();
	
	if $WallDetection.is_colliding():
		inter.cur_state = Interactive.STATE_UNAVAIL;
	else:
		if $Interaction.overlaps_area(inter.area):
			inter.cur_state = Interactive.STATE_CLICKABLE;
		else:
			inter.cur_state = Interactive.STATE_OUT_OF_RANGE;


func inter_entered(area):
	$WallDetection.global_rotation = 0;
	check_inter(area.get_parent());


func inter_left(area):
	$WallDetection.global_rotation = 0;
	area.get_parent().clickable(Interactive.STATE_UNAVAIL);
