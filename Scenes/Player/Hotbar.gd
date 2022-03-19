extends ReferenceRect

const SLOTS = 3;
const SPACING_PERCENT = 0.05;
const COLOR_BACK = Color8(10,25,25);
const COLOR_BORDER = Color.darkblue;
const COLOR_EQUIP = Color8(194,173,58);
const HOTBAR_GROUP = "HOTBAR_GROUP";

var SPACING = rect_size.y*SPACING_PERCENT;
var rect_width = (rect_size.x - (SLOTS+1)*SPACING)/SLOTS;
var rect_height = rect_size.y - 2*SPACING;

const PREVIEW_NONE = -1;
const PREVIEW_COLOR = ItemWaffle.PREVIEW_COLOR_AVAIL;
var preview_cur := PREVIEW_NONE;

# contains ItemInventory of selected items
var items: Array;

func _ready():
	add_to_group(HOTBAR_GROUP);
	set_physics_process(false);
	connect("mouse_entered",self,"set_physics_process",[true]);
	connect("mouse_exited",self,"_stop_physics");

func _stop_physics():
	set_physics_process(false);
	if preview_cur != PREVIEW_NONE:
		preview_cur = PREVIEW_NONE;
		update();

func update_hotbars():
	get_tree().call_group(HOTBAR_GROUP,"update");

func get_drag_data(pos):
	if get_at_pos(pos) == null: return null;
	return DragData.ItemHotbar.new(get_at_pos(pos),self);

func can_drop_data(_position, data):
	return data is DragData.ItemDrag || data is DragData.ItemHotbar;

func drop_data(pos, data):
	#BIG TITTIES
	
	if data is DragData.ItemDrag:
		if data.item in items:
			items[items.find(data.item)] = null;
		
		items[floor(pos.x/(rect_width+SPACING))] = data.item;
	
	else:
		if get_at_pos(pos) != null:
			items[items.find(data.item)] = get_at_pos(pos);
		else:
			items[items.find(data.item)] = null;
		
		items[floor(pos.x/(rect_width+SPACING))] = data.item;
	
	preview_cur = PREVIEW_NONE;
	update_hotbars();

func _draw():
	SPACING = rect_size.y*SPACING_PERCENT;
	rect_width = (rect_size.x - (SLOTS+1)*SPACING)/SLOTS;
	rect_height = rect_size.y-2*SPACING;
	
	draw_rect(Rect2(Vector2.ZERO,get_rect().size),COLOR_BORDER)
	
	for i in SLOTS:
		draw_rect(Rect2(i*(rect_width+SPACING)+SPACING,SPACING,rect_width,rect_height),COLOR_BACK);
	
	var idx := 0;
	var size: Vector2;
	var offset: Vector2;
	
	for item in items:
		if item != null:
			# maintain aspect ratio, centered
			size = item.texture.get_size();
			size /= max(size.x/rect_width,size.y/rect_height);
			offset = (Vector2(rect_width,rect_height)-size)/2;
			
			draw_texture_rect(
					item.texture,
					Rect2(Vector2(idx*(rect_width+SPACING)+SPACING,SPACING)+offset,
					size),
					false
			)
			
		idx += 1;
	
	var equipped = Groups.get_player().equipped;
	if equipped != null && equipped in items:
		draw_rect(
				Rect2(items.find(equipped)*(rect_width+SPACING)+SPACING,SPACING,rect_width,rect_height),
				COLOR_EQUIP,false,SPACING
		);
	
	idx = 0;
	
	for item in items:
		if item != null:
			draw_string(get_theme_default_font(),Vector2(idx*(rect_width+SPACING)+SPACING,2*SPACING),str(idx+1));
		idx += 1;
	
	if preview_cur != PREVIEW_NONE:
		draw_rect(
			Rect2(Vector2(preview_cur*(rect_width+SPACING)+2*SPACING,2*SPACING),Vector2(rect_width-2*SPACING,rect_height-2*SPACING)),
			PREVIEW_COLOR,
			false
		);

func get_at_pos(pos: Vector2):
	if (int(pos.x)%int(rect_width+SPACING) > rect_width): return null;
	return items[floor(pos.x/(rect_width+SPACING))];

func _gui_input(ev):
	if ev is InputEventMouseButton && ev.pressed:
		if ev.button_index == BUTTON_LEFT && ev.doubleclick:
			Groups.get_player().equip(get_at_pos(ev.position));
		elif ev.button_index == BUTTON_RIGHT:
			items[items.find(get_at_pos(ev.position))] = null;
			update_hotbars();

func _physics_process(_delta):
	if get_viewport().gui_is_dragging():
		var data = get_viewport().gui_get_drag_data();
		if data is DragData.ItemDrag || data is DragData.ItemHotbar:
			var temp = floor(get_local_mouse_position().x/rect_width)
			if temp != preview_cur:
				preview_cur = temp;
				update();

