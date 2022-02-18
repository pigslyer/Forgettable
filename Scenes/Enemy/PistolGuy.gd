extends Enemy

const GUN_MAX_ANGLE = deg2rad(50);
const GUN_SEARCH_SPEED = ( 3 )/GUN_MAX_ANGLE*2;

const TURN_MULT = 1.6;
const GUN_ANGLE_OFF_PLAYER = deg2rad(5);
const MAX_RANGE_FROM_PLAYER = 400;

const DAMAGE_MIN = 25;
const DAMAGE_MAX = 35;

const LASER_DEFAULT = Vector2(0.8,1.2);
const LASER_TARGETTING = Vector2(1.2,1.6);

var search_mult := 1;

onready var starting_angle = global_rotation;
onready var angle_max = global_rotation+GUN_MAX_ANGLE;
onready var angle_min = global_rotation-GUN_MAX_ANGLE;

onready var gun: Node2D = $Animation/Body/Hand/Handgun;
onready var gun_ray: RayCast2D = $Animation/Body/Hand/Handgun/LaserSight/RayCast2D;

func _physics_process(delta):
	
	if !dead && can_move && velocity.is_equal_approx(Vector2.ZERO) && $ShootTime.is_stopped():
		
		# follow laser sight
		var prev_rot: float = gun.global_rotation;
		rotation = wrapf(rotation-(prev_rot-rotation)*delta*TURN_MULT*sign(abs(prev_rot-rotation)-PI),-PI,PI);
		gun.global_rotation = prev_rot;
		
		$Head.global_rotation = gun.global_rotation;
		
		if alerted:
			
			# player has exited range
			if global_position.distance_squared_to(Groups.get_player_pos()) > MAX_RANGE_FROM_PLAYER*MAX_RANGE_FROM_PLAYER:
				set_alerted(false);
				angle_min = starting_angle-GUN_MAX_ANGLE;
				angle_max = starting_angle+GUN_MAX_ANGLE;
			
			else:
				# we aren't looking at him, follow him for a little bit
				if gun_ray.get_collider() != Groups.get_player():
					if $ReactionTime.is_stopped():
						$ReactionTime.start();
				
				elif $NoShoot.is_stopped() && $ShootTime.is_stopped():
					$ShootTime.start();
					$Animation/Body/Hand/Handgun/LaserSight.energy_min = LASER_TARGETTING.x;
					$Animation/Body/Hand/Handgun/LaserSight.energy_max = LASER_TARGETTING.y;
				
				angle_min = get_angle_to(Groups.get_player_pos())-GUN_ANGLE_OFF_PLAYER;
				angle_max = angle_min+2*GUN_ANGLE_OFF_PLAYER;
		
		elif $ReactionTime.is_stopped() && gun_ray.get_collider() == Groups.get_player():
			$ReactionTime.start();
		
		if !$ShootTime.is_stopped():
			return;
		
		# move laser sight
		gun.global_rotation += search_mult+GUN_SEARCH_SPEED*delta;
		if gun.global_rotation > angle_max || gun.global_rotation < angle_min:
			gun.global_rotation = clamp(gun.global_rotation,angle_min,angle_max);
			search_mult *= -1;


func _on_LosePlayer_timeout():
	if gun_ray.get_collider() != Groups.get_player() && $Animation/Body/Head/PlayerDetection.get_overlapping_bodies().empty():
		set_alerted(false);
	else:
		set_alerted(true);


func _on_ShootTime_timeout():
	var bullet := preload("res://Scenes/Misc/1911Bullet.tscn").instance();
	Projectile.add_child(bullet);
	bullet.shoot(gun.global_rotation,0b10,DAMAGE_MIN,DAMAGE_MAX);
	bullet.global_position = $Animation/Body/Hand/Handgun/FireFrom.global_position;
	$Animation/Body/Hand/Handgun/LaserSight.energy_min = LASER_DEFAULT.x;
	$Animation/Body/Hand/Handgun/LaserSight.energy_max = LASER_DEFAULT.y;
