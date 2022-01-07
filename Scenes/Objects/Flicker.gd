extends Light2D

const interp_time = 0.15

export (float) var int_min = 0.6
export (float) var int_max = 1.4
export (int,1,50) var smoothing = 40

export (bool) var autoshadow = true

var last: float
var queue: Array

var tween: Tween = null
var scale_backup: Vector2 = scale

func _ready():
	range_height = 500
	shadow_enabled = autoshadow
	shadow_filter = Light2D.SHADOW_FILTER_PCF7
	
	set_physics_process(enabled)
	
	var notif := VisibilityNotifier2D.new()
	var size := texture.get_size()*texture_scale
	notif.rect = Rect2(-size/2,size)
	add_child(notif)
	
	notif.connect("screen_entered",self,"start")
	notif.connect("screen_exited",self,"set_physics_process",[false])


func set_enabled(state: bool):
	
	if state == enabled:
		return
	
	set_physics_process(state)
	
	if !is_instance_valid(tween):
		tween = Tween.new()
		tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
		add_child(tween)
	else:
		tween.stop_all()
	
	if state: # turn on
		enabled = true
		tween.interpolate_property(self,"scale",Vector2.ZERO,scale_backup,interp_time)
	else: # turn off
		tween.interpolate_property(self,"scale",scale_backup,Vector2.ZERO,interp_time)
		tween.interpolate_property(self,"enabled",true,false,interp_time)
	
	tween.interpolate_callback(tween,interp_time,"queue_free")
	
	if tween.is_inside_tree():
		tween.start()
	else:
		tween.call_deferred("start")


func start():
	set_physics_process(enabled)


# code yoinked from sinbad
func _physics_process(_delta):
	if (queue.size() > smoothing):
		last -= queue.pop_front()
	
	queue.push_back(rand_range(int_min,int_max))
	last += queue[-1]
	
	energy = last/queue.size()
