extends Sprite

const MAX_TURN = deg2rad(280-180);
const TURN_SPEED = 1.7;

var target_angle: float;
var dir: int;

var breath = true;

func _ready():
	set_physics_process(false);
	if Save.save_data.get("tortured",false):
		queue_free();

func dial_action(id):
	if id == "unbind":
		$AnimationPlayer.play("Unbind");
		$TalkTo.disable(true);
		Save.save_data["tortured"] = true;

func _on_TalkTo_interacted():
	_look_at(Groups.get_player().global_position);

func _look_at(pos: Vector2):
	target_angle = clamp(($Head.global_position-pos).angle(),-MAX_TURN,MAX_TURN);
	
	# this is mega retarded, but it works
	if (sign($Head.rotation) != sign(target_angle)) && $Head.rotation != 0:
		dir = -sign($Head.rotation)*sign($Head.rotation-(target_angle-$Head.rotation));
	else:
		dir = sign(abs(target_angle-$Head.rotation)-PI);
	
	set_physics_process(true);

func _physics_process(delta):
	$Head.rotation = wrapf(
			$Head.rotation-(target_angle-$Head.rotation)*
			delta*TURN_SPEED*dir,
	-PI,PI);
	
	if is_equal_approx($Head.rotation,target_angle):
		set_physics_process(false);



func _on_Breathing_finished():
	yield(get_tree().create_timer(rand_range(1.5,2.5)),"timeout");
	if breath:
		$Breathing.pitch_scale = rand_range(0.85,0.95);
		$Breathing.play();
