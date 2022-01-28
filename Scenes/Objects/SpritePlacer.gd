tool

class_name SpritePlacer
extends StaticBody2D

const KNEE_WORLD = 128;

export (Texture) var texture setget set_texture;

func _ready():
	collision_layer = KNEE_WORLD;
	collision_mask = 0;

func set_texture(tex: Texture):
	texture = tex;
	name = tex.resource_path.get_basename().get_file();
	
	if get_child_count() == 0:
		add_child(Sprite.new());
		add_child(CollisionPolygon2D.new());
		get_child(1).hide();
		for child in get_children():
			child.owner = owner;
	
	get_child(0).texture = tex;
	
	var bm := BitMap.new();
	bm.create_from_image_alpha(tex.get_data(),0.001);
	var rect := Rect2(
		Vector2.ZERO,tex.get_size()
	);
	get_child(1).polygon = PoolVector2Array(bm.opaque_to_polygons(rect)[0]);
	get_child(1).position = -tex.get_size()/2;
