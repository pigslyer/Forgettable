extends Sprite

const GREETING = "res://Levels/Medical/helpless.txt";
const LORE = "res://Levels/Medical/helpless_lore.txt";

# presuppose scale x and y are equal
const MAX_SCALE = 1;
const MIN_SCALE = 0.6;

const MAX_MODULATE = Color8(255,255,255);
export (Color) var MIN_MODULATE: Color;

var talked_to := false;
var following := false;

func data_save(): talked_to;
func data_load(data):
	if data: queue_free();


func _process(_delta):
	if following:
		if !$Tween.is_active():
			look_at(Groups.get_player_pos());
		
	else:
		$Hand.modulate = MIN_MODULATE.linear_interpolate(
			MAX_MODULATE,($Hand.scale.x-MIN_SCALE)/(MAX_SCALE-MIN_SCALE)
		);
		$Hand2.modulate = MIN_MODULATE.linear_interpolate(
			MAX_MODULATE,($Hand2.scale.x-MIN_SCALE)/(MAX_SCALE-MIN_SCALE)
		);
		
		$Foot.rotation = -rotation;
		$Foot2.rotation = -$Foot.rotation;


func _on_Hit_body_entered(_body):
	$AnimationPlayer.play("Die");
	Save.save_my_data(self,true);
	
	yield($AnimationPlayer,"animation_finished");
	queue_free();


func _on_Interactive_interacted():
	if $AnimationPlayer.current_animation != "Die":
		Groups.get_player().start_dial(LORE if talked_to else GREETING,!talked_to,self);
		talked_to = true;
		following = true;
		
		$Tween.interpolate_property(self,"global_rotation",null,(Groups.get_player_pos()-global_position).angle(),1.2,Tween.TRANS_CUBIC,Tween.EASE_IN);
		$Tween.start();
		$AnimationPlayer.play("Plead");		

func _on_FollowRange_area_exited(_area):
	if following:
		following = false;
		global_rotation = 0;
		$AnimationPlayer.play("Searching");
