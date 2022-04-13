extends Node2D

var flickers: Array;

func _ready():
	for child in get_children():
		if child is Line2D:
			flickers.append(TentacleFlicker.new(child));

func _physics_process(delta):
	for flicker in flickers:
		flicker.update_line(delta);

func update_tentacles():
	for flicker in flickers:
		flicker.update();


class TentacleFlicker extends Reference:
	
	const MAX_OFF = 30;
	const SMOOTHING = 10;
	const INTERP = 0.9;
	
	var queue: Array = [];
	var last: float;
	
	var line: Line2D;
	var points: PoolVector2Array;
	var points_target: PoolVector2Array = [];
	
	func _init(l: Line2D):
		line = l;
		points = l.points;
		points_target.resize(points.size());
		
		for point in SMOOTHING:
			queue.push_back(rand_range(-MAX_OFF,MAX_OFF));
			last += queue[-1];
		
		for i in 20:
			update();
		
		for i in points.size():
			points[i] = points_target[i];
	
	func update():
		
		if queue.size() == SMOOTHING:
			last -= queue.pop_front();
		
		queue.push_back(rand_range(-MAX_OFF,MAX_OFF));
		last += queue[-1];
		
		var val = last/SMOOTHING;
		
		# 0 stays in place so we can base future rotations on it
		for idx in range(1,points.size()):
			points_target[idx] = points[idx]+Vector2(val,0).rotated((line.points[idx]-line.points[idx-1]).angle()+PI/2);
	
	func update_line(delta: float):
		
		for idx in range(1,points.size()):
			line.points[idx] += (points_target[idx]-line.points[idx])*INTERP*delta;
