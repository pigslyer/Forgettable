extends TileMap

signal connected(state);

const UNPOWERED_ID = 0;
const NODE_ID = 1;
const START_ID = 2;
const END_ID = 3;
const POWERED_ID = 4;

var unpowered: Dictionary = {};
var starts: Array = [];
var middles: Dictionary = {};
var ends: Array = [];

export (bool) var enabled = true setget set_enabled;

func set_enabled(state: bool):
	enabled = state;
	visible = enabled && Groups.get_player().special_equipped("res://Scenes/Items/TechGoggles.tscn");

func _ready():
	
	var nodes: Dictionary = {};
	
	for node in get_used_cells_by_id(UNPOWERED_ID):
		unpowered[node] = Unpowered.new(self,node);
	
	for node in get_used_cells_by_id(NODE_ID):
		middles[node] = WireNode.new(node,self);
		nodes[node] = middles[node];
		var inter := Interactive.new();
		inter.message = "Rotate";
		inter.rect_size = cell_size;
		inter.rect_position = map_to_world(node);
		inter.connect("interacted",self,"rotated",[nodes[node]]);
		add_child(inter);
	
	for node in get_used_cells_by_id(START_ID):
		starts.append(WireStart.new(node,self));
		nodes[node] = starts[-1];
	
	for node in get_used_cells_by_id(END_ID):
		ends.append(Wire.new(node,self));
		nodes[node] = ends[-1];
	
	var cons: Array;
	
	for node in nodes.keys():
		
		cons = fill_start(node,LEFT+UP+DOWN+RIGHT if nodes[node] is WireNode else _get_rot(node))
		
		for dir in cons:
			for conn in dir:
				conn.to = nodes[conn.pos];
		
		nodes[node].connections = cons;
	
	
	for start in starts:
		start.propogate();
	
	for start in starts:
		start.visualize(unpowered);
	
	var c: int = 0;
	for end in ends:
		c += int(end.powered);
	
	emit_signal("connected",c == ends.size());
	
	set_enabled(enabled);

func rotated(node: WireNode):
	node.rotate(self);
	
	for start in starts:
		start.clear();
	
	for start in starts:
		start.propogate();
	
	for node in unpowered.values():
		node.set_powered(false);
	
	for start in starts:
		start.visualize(unpowered);
	
	var c: int = 0;
	for end in ends:
		c += int(end.powered);
	
	emit_signal("connected",c == ends.size());

func _get_rot(pos: Vector2) -> int:
	# up or down
	if is_cell_transposed(pos.x,pos.y):
		return UP if is_cell_y_flipped(pos.x,pos.y) else DOWN;
	
	# left or right
	else:
		return LEFT if is_cell_x_flipped(pos.x,pos.y) else RIGHT;



func data_save():
	var ret := {};
	
	for mid in middles.values():
		ret[mid.pos] = mid.rot;
	
	return ret;

func data_load(data):
	
	for mid in data.keys():
		middles[mid].rot = data[mid];
	
	
	for start in starts:
		start.clear();
	
	for start in starts:
		start.propogate();
	
	for node in unpowered.values():
		node.set_powered(false);
	
	for start in starts:
		start.visualize(unpowered);
	
	var c: int = 0;
	for end in ends:
		c += int(end.powered);
	
	emit_signal("connected",c == ends.size());

func tech_goggles(on: bool):
	visible = enabled && on;


enum{
	RIGHT = 0b1, UP = 0b10, LEFT = 0b100, DOWN = 0b1000
};

func fill_start(from: Vector2, dir: int) -> Array:
	var points = [[],[],[],[]];
	
	if dir & RIGHT != 0 && get_cellv(from+Vector2.RIGHT) != INVALID_CELL:
		_fill_search(from+Vector2.RIGHT,points[0],RIGHT+UP+DOWN, Wire.DIRS.LEFT);
	
	if dir & UP != 0 && get_cellv(from+Vector2.UP) != INVALID_CELL:
		_fill_search(from+Vector2.UP,points[1],RIGHT+UP+LEFT, Wire.DIRS.DOWN);
	
	if dir & LEFT != 0 && get_cellv(from+Vector2.LEFT) != INVALID_CELL:
		_fill_search(from+Vector2.LEFT,points[2],UP+LEFT+DOWN, Wire.DIRS.RIGHT);
	
	if dir & DOWN != 0 && get_cellv(from+Vector2.DOWN) != INVALID_CELL:
		_fill_search(from+Vector2.DOWN,points[3],LEFT+DOWN+RIGHT, Wire.DIRS.UP);
	
	var ret: Array = [];
	
	for point in points:
		ret.append(_normalize(point));
	
	return ret;

# we don't acutally check if the wires are "properly" connected,
# just don't have them be adjacent

func _fill_search(from: Vector2, results: Array, directions: int, to: int) -> void:
	if get_cellv(from) == NODE_ID || get_cellv(from) == START_ID || get_cellv(from) == END_ID:
		if !from in results:
			results.append(WireConnection.new(from,to));
		return;
	
	if directions & RIGHT != 0 && get_cellv(from+Vector2.RIGHT) != INVALID_CELL:
		_fill_search(from+Vector2.RIGHT,results,RIGHT+UP+DOWN, Wire.DIRS.LEFT);
	
	if directions & UP != 0 && get_cellv(from+Vector2.UP) != INVALID_CELL:
		_fill_search(from+Vector2.UP,results,LEFT+UP+RIGHT, Wire.DIRS.DOWN);
	
	if directions & LEFT != 0 && get_cellv(from+Vector2.LEFT) != INVALID_CELL:
		_fill_search(from+Vector2.LEFT,results,UP+LEFT+DOWN, Wire.DIRS.RIGHT);
	
	if directions & DOWN != 0 && get_cellv(from+Vector2.DOWN) != INVALID_CELL:
		_fill_search(from+Vector2.DOWN,results,LEFT+DOWN+RIGHT, Wire.DIRS.UP);

func _normalize(arr: Array) -> Array:
	var ret := [];
	var used: Dictionary = {};
	
	for val in arr:
		if !used.has(val):
			ret.append(val);
			used[val] = null;
	
	return ret;

class WireConnection extends Reference:
	var dir_to: int;
	var to: Wire;
	var pos: Vector2;
	
	func _init(p: Vector2,dir: int):
		pos = p; dir_to = dir;
	
	func _to_string():
		return str(pos,"	",dir_to,"	",to);

class Wire extends Reference:
	enum DIRS{
		RIGHT,UP,LEFT,DOWN
	};
	const DIRV = [Vector2.RIGHT,Vector2.UP,Vector2.LEFT,Vector2.DOWN];
	
	# 2d array. 1st d is 0-3 (DIRS), next is WireConnections
	var connections: Array setget set_connections;
	var connected_to: Dictionary;
	var rot: int;
	var powered: bool = false;
	var p: Vector2;
	
	func propogate():
		powered = true;
	
	func set_connections(cons: Array):
		connections = cons;
		
		for dir in cons:
			for conn in dir:
				connected_to[conn.pos] = conn.to;
	
	func visualize(_unpowers: Dictionary, _done: Dictionary = {}):
		pass;
	
	func _visualize(pos: Vector2, unpowers: Dictionary, done: Dictionary):
		if !pos in done:
			done[pos] = true;
			if pos in unpowers && !unpowers[pos].is_powered:
				unpowers[pos].set_powered(true);
				
				for i in [Vector2.RIGHT,Vector2.UP,Vector2.LEFT,Vector2.DOWN]:
					_visualize(pos+i,unpowers, done);
			elif pos in connected_to && !pos in done:
				connected_to[pos].visualize(unpowers);

	func can_receive(_dir: int):
		return true;
	
	
	func _init(pos: Vector2, map: TileMap):
		rot = _get_rot(pos,map);
		p = pos;
	
	
	func _get_rot(pos: Vector2, map: TileMap) -> int:
		# up or down
		if map.is_cell_transposed(pos.x,pos.y):
			return DIRS.UP if map.is_cell_y_flipped(pos.x,pos.y) else DIRS.DOWN;
		
		# left or right
		else:
			return DIRS.RIGHT if map.is_cell_x_flipped(pos.x,pos.y) else DIRS.LEFT;

class WireNode extends Wire:
	
	enum{
		TYPE_LINE, TYPE_TURN, TYPE_T, TYPE_CROSS
	};
	
	const ATLAS_TO_TYPE = {
		Vector2.ZERO : TYPE_LINE, Vector2(1,0) : TYPE_TURN, Vector2(0,1) : TYPE_T, Vector2(1,1) : TYPE_CROSS
	};
	const TYPE_TO_ATLAS = [
		Vector2.ZERO, Vector2(1,0), Vector2(0,1), Vector2(1,1)
	];
	
	var type: int;
	
	func _init(pos: Vector2, map: TileMap).(pos,map):
		type = ATLAS_TO_TYPE[map.get_cell_autotile_coord(pos.x,pos.y)];
	
	func rotate(map: TileMap):
		
		print(rot);
		rot = (rot+1)%4;
		print(rot)
		
		var sets: int;
		match rot:
			DIRS.RIGHT:
				sets = 0;
			DIRS.UP:
				sets = 0b101;
			DIRS.LEFT:
				sets = 0b011;
			DIRS.DOWN:
				sets = 0b110;
		
		map.set_cellv(p,NODE_ID,bool(sets&0b1),bool(sets&0b10),bool(sets&0b100),TYPE_TO_ATLAS[type])
	
	func propogate():
		powered = true;
		
		var to: Array = [];
		
		for dir in _get_outgoing():
			to.append_array(connections[dir]);
		
#		match type:
#			TYPE_LINE:
#				to = connections[rot];
#				to.append_array(connections[rot^0b10]);
#
#			TYPE_TURN:
#				to = connections[~rot & 0b11];
#				to.append_array(connections[rot^((rot&0b1)<<1)]);
#
#			TYPE_T:
#				var val: int = (rot ^ 0b1 + 1) % 4;
#
#				to = connections[val];
#				to.append_array(connections[(val+1)%4]);
#				to.append_array(connections[(val+2)%4]);
#
#			TYPE_CROSS:
#				to = connections[0]; to.append_array(connections[1]); 
#				to.append_array(connections[2]); to.append_array(connections[3]);
		
		for conn in to:
			if !conn.to.powered && conn.to.can_receive(conn.dir_to):
				conn.to.propogate();
	
	func visualize(unpowers: Dictionary, done: Dictionary = {}):
		for dir in _get_outgoing():
			_visualize(p+DIRV[dir], unpowers, done);
	
	func _get_outgoing() -> Array:
		
		match type:
			TYPE_LINE:
				return [rot,rot^0b10];
			TYPE_TURN:
				return [~rot & 0b11,rot^((rot&0b1)<<1)];
			TYPE_T:
				var val: int = (rot ^ 0b1 + 1) % 4;
				return [val,(val+1)%4,(val+2)%4];
		
		return [RIGHT,UP,LEFT,DOWN];
		
	
	# dir it's coming from (--> LINE; 2)
	func can_receive(dir: int) -> bool:
		match type:
			TYPE_LINE:
				return dir%2 == rot%2;
			TYPE_TURN:
				return (dir+rot)%4 == 0 || (dir+rot)%4 == 3;
			TYPE_T:
				# and they say bitwise operations are a waste of time
				return (rot ^ 0b1) != dir;
		return true;
	

class WireStart extends Wire:
	
	func _init(pos: Vector2, tilemap: TileMap).(pos,tilemap):
		pass;
	
	func clear():
		_clear(connections,{});
	
	func propogate():
		powered = true;
		
		for dir in connections:
			for connection in dir:
				if !connection.to.powered && connection.to.can_receive(connection.dir_to):
					connection.to.propogate();
	
	func visualize(unpowers: Dictionary, done: Dictionary = {}):
		if !((p+DIRV[rot]) in done):
			_visualize(p+DIRV[rot],unpowers, done);
	
	func _clear(targets: Array, used: Dictionary):
		powered = false;
		for dir in targets:
			for target in dir:
				if !used.has(target):
					used[target] = false;
					_clear(target.to.connections,used);

class Unpowered extends Reference:
	# xflip, yflip, transpose;
	var t: TileMap;
	var settings: int;
	var atlas_pos: Vector2;
	var p: Vector2;
	var is_powered: bool = false setget set_powered;
	
	func _init(tile: TileMap, pos: Vector2):
		t = tile;
		p = pos;
		atlas_pos = tile.get_cell_autotile_coord(pos.x,pos.y);
		settings = int(tile.is_cell_x_flipped(pos.x,pos.y))+(int(tile.is_cell_y_flipped(pos.x,pos.y))<<1)+(int(tile.is_cell_transposed(pos.x,pos.y))<<2);
	
	func set_powered(state: bool):
		is_powered = state;
		t.set_cellv(p,POWERED_ID if state else UNPOWERED_ID,bool(settings&0b1),bool(settings&0b10),bool(settings&0b100),atlas_pos);
