class_name SayLine
extends Control

const PLAYER_BIT = 0b10;

export (String,MULTILINE) var message;
export (bool) var onetime = true;

func _ready():
	
	var area := Area2D.new();
	area.collision_mask = PLAYER_BIT;
	area.monitorable = false;
	
	var shape := CollisionShape2D.new();
	shape.shape = RectangleShape2D.new()
	shape.shape.extents = rect_size/2;
	
	area.add_child(shape);
	shape.position = rect_size/2;
	add_child(area);
	
	area.connect("body_entered",self,"_detected_player");
	

func _detected_player(_body):
	Groups.say_line(message);
	if onetime: queue_free();
