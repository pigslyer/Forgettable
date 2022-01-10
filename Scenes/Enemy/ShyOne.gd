extends Enemy

const DAMAGE_MIN = 10
const DAMAGE_MAX = 20

# if he's within this distance he rushes the player no matter what
const MIN_DIST_TO_PLAYER = 64*3;

const RUN_AWAY_DIST = 64*12;

var attacking: bool = false;
var knows_player_empty: bool = false;
var running_away: bool = false;

func attacked():
	for target in $Animation/Body/DamageArea.get_overlapping_bodies():
		target.health -= rand_range(DAMAGE_MIN,DAMAGE_MAX);
	
	running_away = true;
	knows_player_empty = false;
	attacking = false;
	
	$WallDetection.force_raycast_update();
	var target_pos = (
			$WallDetection.get_collision_point() + Vector2(64*2,0).rotated(global_rotation)
			if $WallDetection.is_colliding() else 
			global_position+Vector2(-RUN_AWAY_DIST,0).rotated(global_rotation)
	);
	
	path = Groups.get_simple_path(global_position,target_pos);


func _physics_process(_delta):
	
	if attacking:
		path = Groups.get_simple_path(global_position,Groups.get_player().global_position);
	
	if detecting && !running_away:
		# if we're off screen we be epic
		if !$VisibilityNotifier2D.is_on_screen() || !Groups.get_player().equipped_item is Gun:
			if $Prerun.is_stopped():
				$Prerun.start();
		
		elif ( # if we get focking triggered, we be fast
				knows_player_empty ||
				global_position.distance_squared_to(Groups.get_player().global_position) < 
				MIN_DIST_TO_PLAYER*MIN_DIST_TO_PLAYER
			):
			$Prerun.stop();
			_on_Prerun_timeout();
		else:
			path = [];
		
		$Animation/Body/Head.look_at(Groups.get_player().global_position);
	
	elif path.empty() && running_away:
		running_away = false;


func _on_DamageArea_body_entered(_body):
	if $AttackDelay.is_stopped() && !dead:
		$AttackDelay.start();


func _on_AttackDelay_timeout():
	can_move = false;
	$Animation/AnimationPlayer.play("shy_attack");
	$Animation/AnimationPlayer.playback_speed = 1
	
	yield($Animation/AnimationPlayer,"animation_finished");
	can_move = true;


func _on_Prerun_timeout():
	if (
			knows_player_empty || !Groups.get_player().equipped_item is Gun ||
			!$VisibilityNotifier2D.is_on_screen() || 
			global_position.distance_squared_to(Groups.get_player().global_position) < 
			MIN_DIST_TO_PLAYER*MIN_DIST_TO_PLAYER
		):
		attacking = true;
		$ShySting.play();

func heard_empty():
	knows_player_empty = true;
