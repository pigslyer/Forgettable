class_name FlickerAlerts
extends Flicker

const FLICKER_ALERT = 64;
const ALERT_TIME = 0.3;

var ray := RayCast2D.new();
var area := Area2D.new();
var collision := CollisionPolygon2D.new();

var alerting := [];

export (float) var area_scale = 1;

func _ready():
	# generate polygon from texture, 
	# credit to Austin on Godot forums
	
	var bm := BitMap.new();
	bm.create_from_image_alpha(texture.get_data(),0.001);
	var rect := Rect2(
		Vector2.ZERO,texture.get_size()
	);
	
	collision.polygon = PoolVector2Array(bm.opaque_to_polygons(rect)[0]);
	collision.scale = Vector2(texture_scale,texture_scale);
	collision.position = (offset-texture.get_size()*texture_scale/2);
	
	area.collision_mask = FLICKER_ALERT;
	area.collision_layer = 0;
	area.monitorable = false;
	area.scale = Vector2(area_scale,area_scale);
	
	area.add_child(collision);
	add_child(area); add_child(ray);
	

func _physics_process(_delta):
	
	if on:
		ray.global_rotation = 0;
		ray.global_scale = Vector2.ONE;
		
		for body in area.get_overlapping_bodies():
			if !body in alerting:
				ray.cast_to = body.global_position-global_position;
				ray.force_raycast_update();
				if !ray.is_colliding():
					
					alerting.append(body);
					yield(get_tree().create_timer(ALERT_TIME),"timeout");
					alerting.remove(alerting.find(body));
					
					body.set_alerted(true);

