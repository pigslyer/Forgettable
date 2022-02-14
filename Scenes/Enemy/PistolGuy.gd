extends Enemy

const GUN_MAX_ANGLE = deg2rad(50);
const GUN_SEARCH_SPEED = ( 3 )/GUN_MAX_ANGLE*2;

# time until he realizes player is out of cover
const REACTION_TIME = 1.4;

var search_mult := 1;


func _physics_process(_delta):

	if !dead && can_move && velocity.is_equal_approx(Vector2.ZERO):
		
		# stay in place and try to find the player by aiming at the last known position
		if alerted:
			pass
		
		# just aim left and right or sth, idk
		else:
			pass;
		
		
