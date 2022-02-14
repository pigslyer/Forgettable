extends FlickerBlinks

var player: Player;

func _ready():
	player = Groups.get_player();

func _physics_process(_delta):
	
	look_at(player.global_position);
