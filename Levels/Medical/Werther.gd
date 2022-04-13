extends Node2D

const VEL_MULTI = 1.4;
const ENERGY_NORMAL = Vector2(0.8,1.2);
const ENERGY_SHOOTING = Vector2(1.2,1.6);

var is_shooting := false;

onready var werther: Sprite = $Podium/Podium/Werther;
onready var player_check: RayCast2D = $Podium/Podium/Werther/Hand/Handgun/LaserSight/PlayerCheck;
onready var handgun = $Podium/Podium/Werther/Hand/Handgun;
onready var laser: Flicker = $Podium/Podium/Werther/Hand/Handgun/LaserSight;

func data_save():
	return is_shooting;

func data_load(data):
	if data:
		start_shooting();

func _physics_process(delta):
	
	if $ShootTime.is_stopped() && $StopTime.is_stopped():
		
		var target = (Groups.get_player_pos()+Groups.get_player().velocity*VEL_MULTI-werther.global_position).angle()+PI/2;
		werther.global_rotation = lerp_angle(werther.global_rotation,target,0.91*delta);
		
		if is_shooting && player_check.is_colliding():
			$ShootTime.start();
			handgun.set_laser_energy(ENERGY_SHOOTING);
			laser.clear();

func _on_PlayerEntered_body_entered(_body):
	if Save.save_data[Save.EXPLOSIVE_KEY].size() < 4:
		Groups.get_player().start_dial("res://Levels/Medical/werther_warning.txt",true,self);

func dial_action(id):
	if id == "start":
		start_shooting();
	elif id == "disable_mines":
		for mine in get_tree().get_nodes_in_group("Mines")[0].get_children():
			mine.disabled = true;

func start_shooting():
	is_shooting = true;
	Save.detecting = 1;
	$Podium/Podium/Werther/Interactive.disabled = true;
	$InvisibleWall/CollisionShape2D.set_deferred("disabled",false);
	$InvisibleWall/NoGoingBack.disabled = false;
	$Podium/Podium/Werther/Handgun/LaserSight.enabled = true;


func shoot():
	laser.set_enabled(false);
	handgun.set_laser_energy(ENERGY_NORMAL);
	laser.clear();
	handgun.shoot();
	$StopTime.start();


func _on_StopTime_timeout():
	laser.set_enabled(true);
