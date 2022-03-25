extends Enemy

const GUN_MAX_ANGLE = deg2rad(36);
const GUN_ANGLE_OFF_PLAYER = deg2rad(20);
const MAX_RANGE_FROM_PLAYER_SQUARED = 400 * 400;

const SHOOT_TIME = 0.3;

const DAMAGE_MIN = 25;
const DAMAGE_MAX = 35;

const LASER_DEFAULT = Vector2(0.8,1.2);
const LASER_TARGETTING = Vector2(1.2,1.6);

var rotator := Rotator.new(self);

onready var starting_angle = global_rotation;
onready var gun_ray: RayCast2D = $Animation/Body/Hand/Handgun/LaserSight/PlayerCheck;

func _physics_process(delta: float):
	
	# if we're reloading we don't do jack diddly
	if !Groups.get_player().dead && !$Animation/Body/Hand/Handgun.is_reloading() && $Flinching.is_stopped():
		
		# shoot player
		if gun_ray.get_collider() == Groups.get_player() && $NoShootTime.is_stopped():
			$Animation/Body/Hand/Handgun.set_laser_energy(LASER_TARGETTING);
			set_physics_process(false);
			$Animation/Body/Hand/Handgun.shoot();
			
			return;
		
		# focus on player, conditionally unalert
		elif alerted:
			
			# player is hiding, start stop hiding timer
			if !is_detecting_player() && $PlayerNotSeen.is_stopped():
				$PlayerNotSeen.start();
			
			# player isn't hiding anymore, don't do above. demorganed
			elif is_detecting_player() && !$PlayerNotSeen.is_stopped():
				$PlayerNotSeen.stop();
			
			# follow player anyway
			rotator.rotate((Groups.get_player_pos()-global_position).angle(),GUN_ANGLE_OFF_PLAYER);
		
		# look around
		else:
			
			if gun_ray.get_collider() == Groups.get_player():
				set_alerted(true);
			
			rotator.rotate(starting_angle,GUN_MAX_ANGLE);
		
		rotator.update(delta);


func is_detecting_player() -> bool:
	
	if Groups.get_player_pos().distance_squared_to(global_position) > MAX_RANGE_FROM_PLAYER_SQUARED:
		return false;
	
	$PlayerWall.cast_to = Groups.get_player_pos()-global_position;
	$PlayerWall.global_rotation = 0;
	$PlayerWall.force_raycast_update();
	
	return !$PlayerWall.is_colliding();


func _on_PlayerNotSeen_timeout():
	set_alerted(is_detecting_player());


class Rotator extends Reference:
	
	const ROTATE_PERCENT = 0.8;
	const CYCLE_DELAY = 0.3;
	const MIN_DIFF = deg2rad(5); # if we're within this, switch direction
	
	var _target: Node2D;
	var _base: float; var _off: float;
	var _target_angle: float;
	var _go: bool = true;
	var _timer := Timer.new();
	
	func _init(node: Node2D):
		_target = node; _timer.one_shot = true;
		node.add_child(_timer);
	
	func rotate(base: float, off: float):
		
		if base != _base || off != _off:
			_base = base; _off = off;
			_go = off != 0;
			_timer.stop();
			
			# if we're between, go in the direction we were going (don't change _go_up)
			# if we aren't, snap to the closer one and go away from it
			if !_go:
				_target.global_rotation = base;
			
			_target.global_rotation = clamp(_target.global_rotation,base-off,base+off);
			
			_target_angle = base + (off if _target.global_rotation < base else -off);
	
	func update(delta: float):
		
		if _go && _timer.is_stopped():
			_target.global_rotation = lerp_angle(_target.global_rotation,_target_angle,ROTATE_PERCENT*delta)
			
			if is_equal_approx(Vector2.RIGHT.rotated(_target.global_rotation).angle(),Vector2.RIGHT.rotated(_target_angle).angle()):
				_target_angle = 2*_base-_target_angle;
				_timer.start(CYCLE_DELAY);
			

func stop_shooting():
	$Animation/Body/Hand/Handgun.set_laser_energy(LASER_DEFAULT);
	$NoShootTime.start();
	set_physics_process(true);
	
