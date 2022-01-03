class_name ItemWaffle
extends ReferenceRect

signal items_changed(changed);

const BACKGROUND_COLOR = Color8(10,25,25);
const DRAW_COLOR = Color.darkblue;
const LINE_WIDTH = 3;
const ITEM_NUM_OFF = Vector2(-32,-8);
const EDGE_CIRCLE_PERCENT = 0.55;

var items: Array setget set_items;
var grid: Array;
export (Vector2) var size;

onready var step = rect_size/size;

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
		var has_space: bool;
		
		for x in size.x-item.size.x+1:
			for y in size.y-item.size.y+1:
				
				has_space = true;
				
				for i in range(x,x+item.size.x):
					for j in range(x,x+item.size.y):
						if grid[i][j] != null:
							has_space = false;
				
				if has_space:
					items.append(ItemBase.dup(item,Vector2(x,y),min(item.count,item.stack)));
					item.count -= min(item.count,item.stack);
					
					if item.count == 0:
						update_data();
						return;

	update_data();

func can_drop_data(pos, data) -> bool:
	if !data is ItemDragData: return false;
	
	pos = (pos/step).floor();
	
	if pos.x + data.size.x > size.x || pos.y + data.size.y > size.y:
		return false;
	
	for x in range(pos.x,pos.x+data.size.x):
		for y in range(pos.y,pos.y+data.size.y):
			if grid[x][y] != null && grid[x][y] != data.item:
				return false;
	
	return true;


func drop_data(pos, data: ItemDragData):
	pos = (pos/step).floor();
	
	for x in range(data.pos.x,data.pos.x+data.size.x):
		for y in range(data.pos.y,data.pos.y+data.size.y):
			data.grid[x][y] = null;
	
	for x in range(pos.x,pos.x+data.size.x):
		for y in range(pos.y,pos.y+data.size.y):
			data.grid[x][y] = data.item;
	
	# before modifying position, in case we want to use it
	if data.waffle != self:
		data.waffle.items.remove(data.waffle.items.find(data.item));
		items.append(data.item);
		if Groups.get_player().equipped == data.item: Groups.get_player().equip(null);
		data.waffle.emit_signal("items_changed",data.item);
		data.waffle.update();
	
	data.item.pos = pos;
	emit_signal("items_changed",data.item);
	update();


func get_drag_data(pos):
	pos = (pos/step).floor();
	if grid[pos.x][pos.y] == null: return null;
	
	set_drag_preview(_make_preview(grid[pos.x][pos.y]));
	return ItemDragData.new(grid[pos.x][pos.y],self);


class ItemDragData extends Reference:
	var waffle: ItemWaffle;
	var item: ItemInventory;
	var pos setget ,get_pos; func get_pos() -> Vector2: return item.pos;
	var size setget ,get_size; func get_size() -> Vector2: return item.size;
	var grid setget ,get_grid; func get_grid() -> Array: return waffle.grid;
	
	func _init(d: ItemInventory, waff: ItemWaffle):
		item = d; waffle = waff;


func _draw():
	
	draw_rect(get_rect(),BACKGROUND_COLOR);
	
	for x in size.x+1:
		draw_line(Vector2(x*step.x,0),Vector2(x*step.x,rect_size.y),DRAW_COLOR,LINE_WIDTH);
	
	for y in size.y:
		draw_line(Vector2(0,y*step.y),Vector2(rect_size.x,y*step.y),DRAW_COLOR,LINE_WIDTH);
	
	draw_line(Vector2(0,rect_size.y),Vector2(rect_size.x,rect_size.y),DRAW_COLOR,LINE_WIDTH);
	
	draw_circle(Vector2.ZERO,LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	draw_circle(Vector2(rect_size.x,0),LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	draw_circle(Vector2(0,rect_size.y),LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	draw_circle(Vector2(rect_size.x,rect_size.y),LINE_WIDTH*EDGE_CIRCLE_PERCENT,DRAW_COLOR);
	
	for item in items:
		draw_texture_rect(item.texture,Rect2(item.pos*step,item.size*step),false);
		if item.stack > 1:
			draw_string(get_theme_default_font(),(item.pos+item.size)*step+ITEM_NUM_OFF,str(item.count));


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
	var tex := TextureRect.new();
	tex.expand = true;
	tex.texture = item.texture;
	tex.rect_size = item.size*step;
	
	return tex;


# set mouse cursor when hovering item
func _gui_input(ev: InputEvent):
	if ev is InputEventMouseMotion:
		mouse_default_cursor_shape = CURSOR_ARROW if get_at_pos(ev.position) == null else CURSOR_POINTING_HAND;
