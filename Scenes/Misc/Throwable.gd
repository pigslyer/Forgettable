extends RigidBody2D

const DROP_TIME = 0.2;
const STARTING_SCALE = Vector2(1.3,1.3);
const ENDING_SCALE = Vector2(0.8,0.8);
const DROPPED_MODULATE = Color8(179,179,179);

const DISAPPEAR_TIME = 0.4;
const STREAM_MAX_SPEED_SQUARED = 1*1;

var starting_scale = STARTING_SCALE;
var ending_scale = ENDING_SCALE;

var _positional: bool;
var _stream: AudioStream;
var _pitch: float = 1.0;

func _ready():
	set_physics_process(false);

# custom collision should be a pool vector2 array
func throw(texture: Texture, force: Vector2, drop_sound: AudioStream = null, positional: bool = true, custom_collision = null):
	$Sprite.texture = texture;
	
	if custom_collision == null:
		var bm := BitMap.new();
		bm.create_from_image_alpha(texture.get_data(),0.001);
		var rect := Rect2(
			Vector2.ZERO,texture.get_size()
		);
		custom_collision = PoolVector2Array(bm.opaque_to_polygons(rect)[0]);
	
	var collision := CollisionPolygon2D.new();
	
	collision.polygon = custom_collision;
	collision.position = -texture.get_size()*scale/2;
	add_child(collision);
	
	apply_central_impulse(force);
	
	if drop_sound != null:
		_stream = drop_sound;
		_positional = positional;
		set_physics_process(true);
	
	$Tween.interpolate_property($Sprite,"scale",starting_scale,ending_scale,DROP_TIME);
	$Tween.interpolate_property(self,"modulate",null,DROPPED_MODULATE,DROP_TIME);
	$Tween.start();

func delay_z_reset(normal_z: int, delay: float):
	z_index = normal_z;
	yield(get_tree().create_timer(delay),"timeout");
	z_index = 10;

func set_pitch(pitch: float = 1.0):
	_pitch = pitch;

func _physics_process(_delta):
	if linear_velocity.length_squared() < STREAM_MAX_SPEED_SQUARED:
		Music.play_sfx(_stream,_pitch,0.0,global_position if _positional else null);
		_stream = null;
		set_physics_process(false);


func _on_DeathTime_timeout():
	$Tween.interpolate_property(self,"modulate",null,Color8(255,255,255,0),DISAPPEAR_TIME);
	$Tween.interpolate_callback(self,DISAPPEAR_TIME,"queue_free");
	$Tween.start();

