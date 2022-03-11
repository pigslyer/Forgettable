class_name ItemWaffle
extends ReferenceRect

signal items_changed(changed);

const BACKGROUND_COLOR = Color8(10,20,20);
const TAKEN_COLOR = Color8(0,15,15);
const DRAW_COLOR = Color.darkblue;
const UNAVAILABLE_COLOR = Color.black;
const CROSS_COLOR = Color.teal;
const CROSS_WIDTH = 3;
const LINE_WIDTH = 3;
const ITEM_NUM_OFF = Vector2(-32,-8);
const EDGE_CIRCLE_PERCENT = 0.55;

const PREVIEW_NO_RECT = Rect2(-Vector2.ONE,Vector2.ZERO);
const PREVIEW_COLOR_AVAIL = Color8(0,255,0);
const PREVIEW_COLOR_UNAVAIL = Color8(255,0,0);

var preview_rect: Rect2 = PREVIEW_NO_RECT;

var items: Array setget set_items;
var grid: Array;
export (Vector2) var size;
export (int) var height = size.y;

onready var step = rect_size/size;

func _ready():
	connect("mouse_exited",self,"_hide_preview");

func _hide_preview():
	preview_rect = PREVIEW_NO_RECT;
	update();

func add_item(item: ItemInventory):
	var diff: int;
	
	# adding to existing
	if item.stack > 1:
		
		for added in items:
			if added.path == item.path && added.count < item.stack:
				diff = min(item.stack-added.count,item.count);
				item.count -= diff;
				added.count += diff;
				
				if item.count == 0:
					update_data();
					return;
	
	# creating new item
	if item.count > 0:
		var has_space: bool = true;
		var item_size = item.get_size(false);
		
		for y in height-item_size.y+1:
			for x in size.x-item_size.x+1:
				
				for i in range(x,x+item_size.x):
					for j in range(y,y+item_size.y):
						if grid[i][j] != null:
							has_space = false;
				
				if has_space:
					items.append(ItemBase.dup(item,Vector2(x,y),min(item.count,item.stack)));
					items[-1].rotated = false;
					item.count -= min(item.count,item.stack);
					
					if item.count == 0:
						update_data();
						return;
					else:
						for i in range(x,x+item.size.x):
							for j in range(y,y+item.size.y):
								# non null value until we can
								# call update_data and clear it
								grid[i][j] = self;
				else:
					has_space = true;
		
		item_size = Vector2(item_size.y,item_size.x);
		
		for y in height-item_size.y+1:
			for x in size.x-item_size.x+1:
				
				for i in range(x,x+item_size.x):
					for j in range(y,y+item_size.y):
						if grid[i][j] != null:
							has_space = false;
				
				if has_space:
					items.append(ItemBase.dup(item,Vector2(x,y),min(item.count,item.stack)));
					items[-1].rotated = true;
					item.count -= min(item.count,item.stack);
					
					if item.count == 0:
						update_data();
						return;
					else:
						for i in range(x,x+item.size.y):
							for j in range(y,y+item.size.x):
								# non null value until we can
								# call update_data and clear it
								grid[i][j] = self;
				else:
					has_space = true;
	
	
	update_data();

func count_item(path: String) -> int:
	var ret := 0;
	
	for item in items:
		if item.path == path: ret += item.count;
	
	return ret;

func get_item(path: String, count: int) -> int:
	
	var ret := 0;
	var diff: int;
	var idx := 0;
	var item: ItemInventory;
	while idx < items.size() && ret < count:
		item = items[idx];
		if item.path == path:
			diff = min(item.count,count-ret)
			ret += diff;
			item.count -= diff;
			if item.count == 0:
				items.remove(items.find(item));
			else:
				idx += 1;
		else:
			idx += 1;
	
	update_data();
	return ret;

func can_drop_data(pos, data) -> bool:
	if data is DragData.ItemHotbar: return true;
	if !data is DragData.ItemDrag: return false;
	
	pos = (pos/step).floor();
	
	if pos.x + data.size_rot.x > size.x || pos.y + data.size_rot.y > height:
		return false;
	
	for x in range(pos.x,pos.x+data.size_rot.x):
		for y in range(pos.y,pos.y+data.size_rot.y):
			if grid[x][y] != null && grid[x][y] != data.item:
				return false;
	
	return true;


func drop_data(pos, data):
	if data is DragData.ItemHotbar:
		data.hotbar.items.remove(data.hotbar.items.find(data.item));
		data.hotbar.update();
	
	else:
		data.item.pos = (pos/step).floor();
		preview_rect = PREVIEW_NO_RECT;
		data.item.rotated = data.item.currently_rotated;
		emit_signal("items_changed",data.item);
		update_data();
	

func get_drag_data(pos):
	pos = (pos/step).floor();
	if grid[pos.x][pos.y] == null: return null;
	
	set_drag_preview(_make_preview(grid[pos.x][pos.y]));
	return DragData.ItemDrag.new(grid[pos.x][pos.y],self);

func _draw():
	
	draw_rect(Rect2(Vector2.ZERO,Vector2(rect_size.x,rect_size.y/size.y*height)),BACKGROUND_COLOR);
	draw_rect(Rect2(Vector2(0,rect_size.y/size.y*height),Vector2(rect_size.x,rect_size.y/size.y*(size.y-height))),UNAVAILABLE_COLOR);
	
	for x in size.x+1:
		draw_line(Vector2(x*step.x,0),Vector2(x*step.x,rect_size.y/size.y*height),DRAW_COLOR,LINE_WIDTH);
	
	for y in height+1:
		draw_line(Vector2(0,y*step.y),Vector2(rect_size.x,y*step.y),DRAW_COLOR,LINE_WIDTH);
	
	draw_line(Vector2.ZERO,Vector2(0,rect_size.y),DRAW_COLOR,LINE_WIDTH);
	draw_line(Vector2(rect_size.x,0),rect_size,DRAW_COLOR,LINE_WIDTH);
	draw_line(Vector2(0,rect_size.y),rect_size,DRAW_COLOR,LINE_WIDTH);
	
	draw_circle(Vector2.ZERO,LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	draw_circle(Vector2(rect_size.x,0),LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	draw_circle(Vector2(0,rect_size.y),LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	draw_circle(Vector2(rect_size.x,rect_size.y),LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	
	
	var tex_size: Vector2;
	var offset: Vector2;
	# i am so done with creative names
	var values: Vector2;
	
	for item in items:
		for x in range(item.pos.x,item.pos.x+item.size.x):
			for y in range(item.pos.y,item.pos.y+item.size.y):
				draw_rect(Rect2(Vector2(x,y)*step+Vector2(1,1),step-Vector2(2,2)),TAKEN_COLOR);
		
		tex_size = item.texture.get_size();
		values = tex_size/((Vector2(step.y,step.x) if item.rotated else step)*item.get_size(false))
		tex_size /= max(values.x,values.y);
		offset = (step*item.get_size(false)-tex_size)/2;
		
		draw_texture_rect(item.texture,Rect2(item.pos*step+offset,tex_size),false,Color8(255,255,255),item.rotated);
		if item.stack > 1:
			draw_string(get_theme_default_font(),(item.pos+item.size)*step+ITEM_NUM_OFF,str(item.count));
	
	
	if preview_rect != PREVIEW_NO_RECT:
		var has_space: bool = true;
		var item = get_viewport().gui_get_drag_data().item;
		for x in range(preview_rect.position.x,preview_rect.position.x+preview_rect.size.x):
			for y in range(preview_rect.position.y,preview_rect.position.y+preview_rect.size.y):
				if (grid[x][y] != null && grid[x][y] != item) || y >= height:
					has_space = false;
					break;
		
		draw_rect(
				Rect2(preview_rect.position*step,preview_rect.size*step),
				PREVIEW_COLOR_AVAIL if has_space else PREVIEW_COLOR_UNAVAIL,
				false,4
		);
	

func set_items(new_items: Array):
	items = new_items;
	update_data();


func update_data():
	grid = [];
	grid.resize(size.x);
	for x in size.x:
		grid[x] = [];
		grid[x].resize(size.y);
	
	for item in items:
		for x in item.size.x:
			for y in item.size.y:
				grid[item.pos.x+x][item.pos.y+y] = item;
	
	update();

# local coordinates, not grid
func get_at_pos(pos: Vector2) -> ItemInventory:
	pos = (pos/step).floor();
	if pos.x < 0 || pos.y < 0 || pos.x >= size.x || pos.y >= size.y: return null;
	return grid[pos.x][pos.y];


func _make_preview(item: ItemInventory) -> Control:
	var tex := Control.new();
	tex.set_script(load("res://Scenes/Objects/ItemDragPreview.gd"))
	tex.setup(item, step, self);
	
	return tex;


# set mouse cursor when hovering item
func _gui_input(ev: InputEvent):
	if ev is InputEventMouseMotion:
		mouse_default_cursor_shape = CURSOR_ARROW if get_at_pos(ev.position) == null else CURSOR_POINTING_HAND;
		
		if get_viewport().gui_is_dragging():
			var data = get_viewport().gui_get_drag_data();
			if data is DragData.ItemDrag:
				var rect = Rect2((ev.position/step).floor(),data.size_rot);
				var bounds = rect.position+rect.size;
				if rect != preview_rect && bounds.x <= size.x && bounds.y <= size.y && rect.position != preview_rect.position:
					update_preview_rect();

func update_preview_rect():
	preview_rect = Rect2((get_local_mouse_position()/step).floor(),get_viewport().gui_get_drag_data().size_rot);
	update();

func save_data():
	
	var ret: Array = [];
	
	for item in items:
		ret.append(item.save_data());
	
	ret.push_back(height);
	
	print(ret);
	return ret;

func load_data(data: Array):
	
	print(data)
	height = data.pop_back();
	print(data)
	items.resize(data.size());
	
	for idx in data.size():
		items[idx] = ItemInventory.new(data[idx][0],null,data[idx][1],data[idx][2]);
		items[idx].rotated = data[idx][3];
	
	update_data();
