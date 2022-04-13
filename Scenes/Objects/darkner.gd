extends Node2D

export (Color) var min_col: Color = Color.white;
export (Color) var max_col: Color = Color8(90,90,90);

func _ready():
	
	var rng := RandomNumberGenerator.new();
	rng.seed = hash(owner.get_path_to(self));
	
	for child in get_children():
		
		if child is CanvasItem:
			child.modulate = min_col.linear_interpolate(max_col,rng.randfn(0.5,0.5));
