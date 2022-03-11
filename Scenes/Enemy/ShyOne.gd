extends Enemy

const DAMAGE_MIN = 10
const DAMAGE_MAX = 20

# if he's within this distance he rushes the player no matter what
const MIN_DIST_TO_PLAYER = 64*1.5;
const RUN_AWAY_DIST = 64*12;

const TURN_MULT = 0.65;

const PLAYER_LOOKING_AT_US_ANGLE = deg2rad(30);

var attacking: bool = false;
var pointing_gun_at: bool = false;
var knows_gun_empty: bool = false;
var running_away: bool = false;
var surrendering: bool = false;

func attacked():
	for target in $Animation/Body/DamageArea.get_overlapping_bodies():
		target.health -= rand_range(DAMAGE_MIN,DAMAGE_MAX);
	
	running_away = true;
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
		if !$Animation/Body/DamageArea.get_overlapping_bodies().empty():
			_on_DamageArea_body_entered(null);
	
		elif (
				pointing_gun_at && !knows_gun_empty && 
				!global_position.distance_squared_to(Groups.get_player().global_position) < 
				MIN_DIST_TO_PLAYER*MIN_DIST_TO_PLAYER && $DontSurrender.is_stopped()
			):
			attacking = false;
			path = [];
		else:
			path = Groups.get_simple_path_player(global_position);
		
	
	elif detecting && !running_away && can_move && !surrendering:
		
		# the player sees us
		$PlayerWall.cast_to = Groups.get_player().global_position-global_position;
		$PlayerWall.global_rotation = 0;
		$PlayerWall.force_raycast_update();
		
		# the player doesn't see us, so we go towards him.
		if $PlayerWall.is_colliding():
			path = Groups.get_simple_path_player(global_position);
		
		# we go insta. player got too close
		elif (
				global_position.distance_squared_to(Groups.get_player().global_position) < 
				MIN_DIST_TO_PLAYER*MIN_DIST_TO_PLAYER
			):
			$Prerun.stop();
			_on_Prerun_timeout(true);
		
		
		# surrender, we're being held at gunpoint
		elif pointing_gun_at && !knows_gun_empty && $DontSurrender.is_stopped():
			$Animation/AnimationPlayer.play("shy_surrender");
			$Animation/AnimationPlayer.playback_speed = 1.0;
			path = [];
			can_move = false;
			surrendering = true;
			Music.play_sfx(
				[
					preload("res://Assets/JakobNoises/SurrenderGaspHighShort.wav"),
					preload("res://Assets/JakobNoises/SurrenderGaspLowShort.wav"),
					preload("res://Assets/JakobNoises/SurrenderGaspNormalLong2.wav"),
					preload("res://Assets/JakobNoises/SurrenderGaspNormalLong.wav"),
				][randi()%4],
				rand_range(0.9,1.1), 5, global_position
			);
		
		
		# we go after a while. player isn't looking at us/doesn't have a gun
		else:
			if $Prerun.is_stopped():
				$Prerun.start();
	
	# we go insta. player got too close or isn't holding us up
	elif (
			surrendering && (
			global_position.distance_squared_to(Groups.get_player().global_position) < 
			MIN_DIST_TO_PLAYER*MIN_DIST_TO_PLAYER ||
			!(pointing_gun_at && !knows_gun_empty))
		):
		unsurrender()
		
	
	elif path.empty() && running_away:
		running_away = false;
	
	
	if surrendering:
		look_at(Groups.get_player().global_position);
	
	if alerted && !running_away:
		$Animation/Body/Head.look_at(Groups.get_player().global_position);


# also autoattacks
func unsurrender():
	can_move = true;
	surrendering = false;
	$UnSurrenderGasp.play();
	$Prerun.stop();
	_on_Prerun_timeout(true);
	$DontSurrender.start();

func _on_DamageArea_body_entered(_body):
	if $AttackDelay.is_stopped() && !dead:
		set_physics_process(false);
		$AttackDelay.start();


func _on_AttackDelay_timeout():
	can_move = false;
	$Animation/AnimationPlayer.play("shy_attack");
	$Animation/AnimationPlayer.playback_speed = 1
	
	yield($Animation/AnimationPlayer,"animation_finished");
	can_move = true;
	set_physics_process(true);


func _on_Prerun_timeout(force: bool = false):
	if (
			!(pointing_gun_at && Groups.get_player().equipped_item is Gun) ||
			force
		):
		attacking = true;
		$ShySting.play();

func set_health(val: int, loud: bool = true):
	.set_health(val,loud);
	if surrendering && val < 40:
		unsurrender();
	
	if val < 0:
		$UnSurrenderGasp.stop();


func _on_AnimationPlayer_animation_started(anim_name: String):
	if anim_name == "idle" || anim_name == "walk":
		$Animation/Body/Hand.hide();
		$Animation/Body/HandOther.hide();
	elif anim_name == "shy_attacK":
		$Animation/Body/HandOther.hide();
