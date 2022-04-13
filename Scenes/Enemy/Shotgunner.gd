extends Enemy

const TURN_MULT = 0.7;

const MELEE_DAMAGE_MIN = 10;
const MELEE_DAMAGE_MAX = 15;

onready var area_shotgun: Area2D = $Animation/Body/ShotgunRange;
onready var area_melee: Area2D = $Animation/Body/MeleeRange;

const NOT_SEEN = -1;
const FIRE_TIME = 0.25*1000;
const POST_FIRE_DELAY = 0.4;
var first_seen: int = NOT_SEEN;

# melee. ranged is triggered in code
func attacked():
	if !area_melee.get_overlapping_bodies().empty():
		Groups.get_player().health -= rand_range(MELEE_DAMAGE_MIN,MELEE_DAMAGE_MAX);

func _physics_process(_delta):
	if !dead && alerted && can_move && $Flinching.is_stopped() && !Groups.get_player().dead && $Animation/Body/Hand/Shotgun.can_do_stuff:
		
		$PlayerWall.global_rotation = 0;
		$PlayerWall.cast_to = Groups.get_player_pos()-global_position;
		$PlayerWall.force_raycast_update();
		
		if $PlayerWall.is_colliding():
			path = Groups.get_simple_path_player(global_position);
		
		else:
			look_at(Groups.get_player_pos());
			
			if area_shotgun.get_overlapping_bodies().empty():
				first_seen = NOT_SEEN;
			
			if !area_shotgun.get_overlapping_bodies().empty():
				if first_seen == NOT_SEEN:
					first_seen = OS.get_ticks_msec();
				
				if first_seen + FIRE_TIME < OS.get_ticks_msec():
					can_move = false;
					$Animation/AnimationPlayer.play("shotgun_idle");
					
					yield(get_tree().create_timer(0.6),"timeout");
					$Animation/Body/Hand/Shotgun.use();
					
					yield(get_tree().create_timer(POST_FIRE_DELAY),"timeout");
					can_move = true;
					
					first_seen = NOT_SEEN;
			
			elif !area_melee.get_overlapping_bodies().empty():
				can_move = false;
				$Animation/AnimationPlayer.play("shotgun_melee");
				$Animation/AnimationPlayer.playback_speed = 1.0;
				yield($Animation/AnimationPlayer,"animation_finished");
				
				can_move = true;
			else:
				path = Groups.get_simple_path_player(global_position);
