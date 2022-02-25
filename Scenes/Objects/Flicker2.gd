class_name Flicker
extends Light2D

# the currnet iteration of me doesn't know why this exists
const GROUP_LIGHTS = "GROUP_FLICKERS";

export (float) var energy_min = 0.8;
export (float) var energy_max = 1.2;
export (int) var smoothing = 40;

var queue: Array;
var last: float;

var visi := VisibilityNotifier2D.new();

var on: bool;

func _ready():
	on = enabled;
	energy = 0;
	enabled = true;
	add_to_group(GROUP_LIGHTS);
	var size = texture.get_size()*texture_scale;
	visi.rect = Rect2(-size/2+offset,size);
	add_child(visi);

func pre_proc():
	while queue.size() < smoothing:
		queue.append(rand_range(energy_min,energy_max));
		last += queue[-1];

func fill_to(percent: float):
	var target = smoothing*min(percent,1);
	
	if queue.size() > target:
		# using pop back while faster would cause the light to reverse its light level
		# which i'd rather not do. performance gain could be achieved by subtracting in one
		# step wtihout editing the array, then editing it to the correct size manually
		while queue.size() > target:
			last -= queue.pop_front();
		
	elif queue.size() < target:
		while queue.size() < target:
			queue.push_back(rand_range(energy_min,energy_max));
			last += queue[-1];

func set_enabled(state: bool):
	on = state;

# code mostly yoinked from sinbad
func _physics_process(_delta):
	
	if visi.is_on_screen():
		
		if queue.size() >= smoothing:
			last -= queue.pop_front();
		
		if on:
			queue.push_back(rand_range(energy_min,energy_max));
			last += queue[-1]
		
		elif !queue.empty():
			last -= queue.pop_back();
		
		# this does a nice turn on effect automatiacally
		energy = last/smoothing;
	
	enabled = visi.is_on_screen() && energy > 0;
