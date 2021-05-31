tool
extends Node2D
class_name DungeonGenerator

const SMALL_SQUARE = "small_square"
const SMALL_RECTANGLE = "small_rectangle"
const MEDIUM_SQUARE = "medium_square"
const MEDIUM_RECTANGLE = "medium_rectangle"
const LARGE_SQUARE = "large_square"
const LARGE_RECTANGLE = "large_rectangle"

export(int) var max_gremlins = 200
export(float) var gremlin_coverage = 0.2
export(int) var room_count = 100
export(int) var max_separation_iterations = 100
export(float) var key_room_percentage = 0.5
export(bool) var debug = false
export(bool) var generate = false setget _set_generate, _get_generate
export(bool) var draw_triangulation = false
export(bool) var draw_mst = false
export(bool) var draw_hallways = false
export(NodePath) var tile_map

var _spawn_radius = 25.0
var _room_cells = []
var _key_rooms = []
var _non_key_rooms = []
var _key_graph = PoolVector2Array()
var _key_edges = []
var _mst = []
var _hallways = []
var _extents = Rect2(0.0, 0.0, 1.0, 1.0)
var _open_tiles = []
var _size_map = {
	SMALL_SQUARE : Vector2(4.0, 4.0),
	SMALL_RECTANGLE : Vector2(5.0, 3.0),
	MEDIUM_SQUARE : Vector2(6.0, 6.0),
	MEDIUM_RECTANGLE : Vector2(7.0, 4.0),
	LARGE_SQUARE : Vector2(6.0, 6.0),
	LARGE_RECTANGLE : Vector2(9.0, 6.0),
}

var _room_sizes = [
	SMALL_SQUARE, # small, square
	SMALL_SQUARE, # small, square
	SMALL_SQUARE, # small, square
	SMALL_SQUARE, # small, square
	SMALL_SQUARE, # small, square
	SMALL_SQUARE, # small, square
	SMALL_RECTANGLE, # small, rectangle
	SMALL_RECTANGLE, # small, rectangle
	SMALL_RECTANGLE, # small, rectangle
	SMALL_RECTANGLE, # small, rectangle
	SMALL_RECTANGLE, # small, rectangle
	SMALL_RECTANGLE, # small, rectangle
#	MEDIUM_SQUARE, # medium, square
#	MEDIUM_SQUARE, # medium, square
#	MEDIUM_RECTANGLE, # medium, square
#	MEDIUM_RECTANGLE, # medium, rectangle
	LARGE_SQUARE, # large, square
	LARGE_SQUARE, # large, square
#	LARGE_RECTANGLE, # large, rectangle
]

var _room_chunks = {
	SMALL_SQUARE : [
		load("res://world/small/room_square_small_0.tscn"),
		load("res://world/small/room_square_small_1.tscn"),
		load("res://world/small/room_square_small_2.tscn"),
		load("res://world/small/room_square_small_3.tscn"),
		load("res://world/small/room_square_small_4.tscn"),
		load("res://world/small/room_square_small_5.tscn"),
		load("res://world/small/room_square_small_6.tscn"),
		load("res://world/small/room_square_small_7.tscn"),
		load("res://world/small/room_square_small_8.tscn"),
	],
	SMALL_RECTANGLE : [
		load("res://world/small/room_rectangle_small_0.tscn"),
		load("res://world/small/room_rectangle_small_1.tscn"),
		load("res://world/small/room_rectangle_small_2.tscn"),
		load("res://world/small/room_rectangle_small_3.tscn"),
		load("res://world/small/room_rectangle_small_4.tscn"),
		load("res://world/small/room_rectangle_small_5.tscn"),
		load("res://world/small/room_rectangle_small_6.tscn"),
	],
	MEDIUM_SQUARE : [
		
	],
	MEDIUM_RECTANGLE : [
		
	],
	LARGE_SQUARE : [
		load("res://world/large/room_square_large_0.tscn"),
		load("res://world/large/room_square_large_1.tscn"),
		load("res://world/large/room_square_large_2.tscn"),
		load("res://world/large/room_square_large_3.tscn"),
		load("res://world/large/room_square_large_4.tscn"),
		load("res://world/large/room_square_large_5.tscn"),
		load("res://world/large/room_square_large_6.tscn"),
		load("res://world/large/room_square_large_7.tscn"),
	],
	LARGE_RECTANGLE : [
		
	],
}
var _gremlins = [
	load("res://gremlins/green_gremlin.tscn"),
	load("res://gremlins/green_gremlin.tscn"),
	load("res://gremlins/green_gremlin.tscn"),
	load("res://gremlins/green_gremlin.tscn"),
	load("res://gremlins/blue_gremlin.tscn"),
	load("res://gremlins/blue_gremlin.tscn"),
	load("res://gremlins/pink_gremlin.tscn"),
	load("res://gremlins/pink_gremlin.tscn"),
]

onready var _tile_map := get_node(tile_map) as TileMap


class RoomCell:
	var bounds := Rect2(0.0, 0.0, 1.0, 1.0) setget _set_bounds, _get_bounds
	var center = Vector2.ZERO
	var radius = 0.0
	var velocity = Vector2.ZERO
	var size: String = SMALL_SQUARE

	func generate(radius: float, size: Vector2):
		var theta = (2.0 * PI) * randf()
		var x = cos(theta) * (radius * randf())
		var y = sin(theta) * (radius * randf())
		bounds = Rect2(x, y, size.x, size.y)


	func _set_bounds(value: Rect2):
		bounds = value
		center = Vector2(
			bounds.position.x + bounds.size.x * 0.5, 
			bounds.position.y + bounds.size.y * 0.5
		)
		radius = max(bounds.size.x * 0.5, bounds.size.y * 0.5)


	func _get_bounds() -> Rect2:
		return bounds


class Edge:
	var start = Vector2.ZERO
	var end = Vector2.ZERO


func generate_dungeon():
	generate(room_count)


func generate(num_rooms: int):
	randomize()
	
	_reset()
	_create_cells(num_rooms)
	_separate_cells()
	_find_key_rooms()
	_triangulate()
	
	var nodes = []
	for _point in _key_graph:
		var point = _point as Vector2
		nodes.push_back(Vector3(point.x, point.y, 0.0))
	
	_find_mst(nodes)
	_create_hallways()
	_add_non_key_rooms()
	_find_extents()
	
	if tile_map:
		_render_tiles()
		_spawn_gremlins()
	
	if debug:
		debug_render()


func _spawn_gremlins():
	var gremlin_count = min(max_gremlins, _open_tiles.size())	
	gremlin_count *= gremlin_coverage
	if gremlin_count == 0:
		return

	var entities = owner.find_node("Entities", true, false) as YSort
	if not entities:
		return
		
	for i in range(gremlin_count):
		var pos = _open_tiles[randi() % _open_tiles.size()]
		_open_tiles.erase(pos)
		var gremlin_type = _gremlins[randi() % _gremlins.size()] as PackedScene
		var gremlin = gremlin_type.instance() as Gremlin
		gremlin.global_position = pos
		entities.add_child(gremlin)


func _sort_nodes(a: Vector2, b: Vector2) -> bool:
	return a.y > b.y


func _reset():
	_room_cells.clear()
	_key_rooms.clear()
	_non_key_rooms.clear()
	_key_graph = PoolVector2Array()
	_key_edges.clear()
	_mst.clear()
	_hallways.clear()
	_extents = Rect2(0.0, 0.0, 1.0, 1.0)
	_open_tiles.clear()

	for child in get_children():
		child.queue_free()
	
	if owner:
		var entities = owner.find_node("Entities", true, false) as YSort
		if entities:
			for child in entities.get_children():
				child.queue_free()



func _create_cells(num_rooms: int):
	for i in range(num_rooms):
		var room_size = _room_sizes[randi() % _room_sizes.size()] as String
		var size = _size_map.get(room_size, Vector2.ZERO) as Vector2
		var room_cell = RoomCell.new()
		room_cell.size = room_size
		room_cell.generate(_spawn_radius, size)
		_room_cells.push_back(room_cell)


func _separate_cells():
	var overlap = true
	var iterations = 0
	
	while overlap and iterations < max_separation_iterations:
		overlap = false
		for _a in _room_cells:
			var a = _a as RoomCell
			a.velocity = Vector2.ZERO
			var neighbors = 0
			
			for _b in _room_cells:
				var b = _b as RoomCell
				if a == b:
					continue
					
				if a.bounds.intersects(b.bounds):
					overlap = true
					a.velocity += (a.center - b.center)
					neighbors += 1
			
			if neighbors > 0:
				a.velocity /= neighbors
				a.velocity = a.velocity.normalized()

		for _a in _room_cells:
			var a = _a as RoomCell
			a.bounds.position += a.velocity
			a.bounds.position = Vector2(
				round(a.bounds.position.x),
				round(a.bounds.position.y)
			)
		
		iterations += 1


func _find_key_rooms():
	_key_rooms.clear()
	_non_key_rooms.clear()
	_room_cells.sort_custom(self, "_sort_room_cells")
	var num = int(_room_cells.size() * key_room_percentage)
	for i in range(_room_cells.size()):
		if i < num:
			_key_rooms.push_back(_room_cells[i])
		else:
			_non_key_rooms.push_back(_room_cells[i])


func _sort_room_cells(a: RoomCell, b: RoomCell) -> bool:
	return a.bounds.size > b.bounds.size


func _triangulate():
	_key_graph = PoolVector2Array()
	_key_edges.clear()
	
	for _room_cell in _key_rooms:
		var room_cell = _room_cell as RoomCell
		_key_graph.push_back(room_cell.center)

	var indices = Geometry.triangulate_delaunay_2d(_key_graph) as PoolIntArray
	assert(indices.size() != 0)
	var count = indices.size() / 3
	for i in range(0, count):
		var v0 = _key_graph[indices[i * 3]]
		var v1 = _key_graph[indices[i * 3 + 1]]
		var v2 = _key_graph[indices[i * 3 + 2]]
		
		var e0 = Edge.new()
		e0.start = v0
		e0.end = v1
		_key_edges.push_back(e0)

		var e1 = Edge.new()
		e1.start = v1
		e1.end = v2
		_key_edges.push_back(e1)

		var e2 = Edge.new()
		e2.start = v2
		e2.end = v0
		_key_edges.push_back(e2)


# https://kidscancode.org/blog/2018/12/godot3_procgen7/
func _find_mst(nodes):
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object

	# Initialize the AStar and add the first point
	var path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())

	# Repeat until no more nodes remain
	while nodes:
		var min_dist = INF  # Minimum distance found so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through the points in the path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			# Loop through the remaining nodes in the given array
			for p2 in nodes:
				# If the node is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_p)

	_mst.clear()	
	for i in range(path.get_point_count() - 1):
		var start = path.get_point_position(i)
		var end = path.get_point_position(i + 1)
		var edge = Edge.new()
		edge.start = Vector2(start.x, start.y)
		edge.end = Vector2(end.x, end.y)
		_mst.push_back(edge)


func _create_hallways():
	_hallways.clear()
	for _edge in _mst:
		var edge = _edge as Edge
		var xdiff = abs(edge.end.x - edge.start.x)
		var ydiff = abs(edge.end.y - edge.start.y)
		
		if xdiff <= ydiff:
			var h0 = Edge.new()
			h0.start = edge.start
			h0.end = Vector2(edge.end.x, edge.start.y)
			_hallways.push_back(h0)

			var h1 = Edge.new()
			h1.start = edge.end
			h1.end = Vector2(edge.end.x, edge.start.y)
			_hallways.push_back(h1)
		else:
			var h0 = Edge.new()
			h0.start = edge.start
			h0.end = Vector2(edge.start.x, edge.end.y)
			_hallways.push_back(h0)

			var h1 = Edge.new()
			h1.start = edge.end
			h1.end = Vector2(edge.start.x, edge.end.y)
			_hallways.push_back(h1)


func _add_non_key_rooms():
	for _edge in _hallways:
		var edge = _edge as Edge
		for _room_cell in _non_key_rooms:
			var room_cell = _room_cell as RoomCell
			# top segment
			var top0 = room_cell.bounds.position
			var top1 = Vector2(room_cell.bounds.end.x, room_cell.bounds.position.y)
			# bottom segment
			var bottom0 = Vector2(room_cell.bounds.position.x, room_cell.bounds.end.y)
			var bottom1 = Vector2(room_cell.bounds.end.x, room_cell.bounds.end.y)
			# left segment
			var left0 = room_cell.bounds.position
			var left1 = Vector2(room_cell.bounds.position.x, room_cell.bounds.end.y)
			# right segment
			var right0 = Vector2(room_cell.bounds.end.x, room_cell.bounds.position.y)
			var right1 = Vector2(room_cell.bounds.end.x, room_cell.bounds.end.y)
			
			var intersects = false
			if Geometry.segment_intersects_segment_2d(edge.start, edge.end, top0, top1) is Vector2:
				intersects = true
			if Geometry.segment_intersects_segment_2d(edge.start, edge.end, bottom0, bottom1) is Vector2:
				intersects = true
			if Geometry.segment_intersects_segment_2d(edge.start, edge.end, left0, left1) is Vector2:
				intersects = true
			if Geometry.segment_intersects_segment_2d(edge.start, edge.end, right0, right1) is Vector2:
				intersects = true
				
			if intersects:
				_key_rooms.push_back(room_cell)


func _draw_line(start: Vector2, end: Vector2, color: Color, width: float = 0.3):
	var l0 = Line2D.new()
	l0.position = Vector2(0.0, 0.0)
	l0.default_color = color
	l0.width = width
	l0.add_point(start)
	l0.add_point(end)
	add_child(l0)


func debug_render():
	for child in get_children():
		child.queue_free()

	for r in _key_rooms:
		var room_cell = r as RoomCell
		var debug_rect = ColorRect.new()
		debug_rect.color = Color(0.2, 0.9, 1.0, 0.3)
		debug_rect.rect_position = room_cell.bounds.position
		debug_rect.rect_size = room_cell.bounds.size
		add_child(debug_rect)


	for r in _non_key_rooms:
		var room_cell = r as RoomCell
		var debug_rect = ColorRect.new()
		debug_rect.color = Color(1.0, 0.9, 0.2, 0.3)
		debug_rect.rect_position = room_cell.bounds.position
		debug_rect.rect_size = room_cell.bounds.size
		add_child(debug_rect)


	if draw_triangulation:	
		for _edge in _key_edges:
			var edge = _edge as Edge
			_draw_line(edge.start, edge.end, Color.yellow)

	if draw_mst:
		for _edge in _mst:
			var edge = _edge as Edge
			_draw_line(edge.start, edge.end, Color.purple)
			
	if draw_hallways:
		for _edge in _hallways:
			var edge = _edge as Edge
			_draw_line(edge.start, edge.end, Color.red)


func _set_generate(value: bool):
	generate = value
	if generate:
		generate_dungeon()


func _get_generate():
	return generate


func _find_extents():
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	for _room_cell in _key_rooms:
		var room_cell = _room_cell as RoomCell
		if room_cell.bounds.position.x < min_x:
			min_x = room_cell.bounds.position.x
		if room_cell.bounds.position.y < min_y:
			min_y = room_cell.bounds.position.y

		if room_cell.bounds.end.x > max_x:
			max_x = room_cell.bounds.end.x
		if room_cell.bounds.end.y > max_y:
			max_y = room_cell.bounds.end.y

	_extents = Rect2(min_x, min_y, max_x, max_y)	


func _render_tiles():
	_tile_map.clear()
	_tile_map.update_bitmask_region()

	_render_chunks()
	_render_hallways()


func _render_chunks():
	var tileX = _tile_map.cell_size.x
	var tileY = _tile_map.cell_size.y
	var halfX = tileX * 0.5
	var halfY = tileY * 0.5
	
	for z in range(_key_rooms.size()):
		var first_room = z == 0
		var second_room = z == 1
		var last_room = z == _key_rooms.size() - 1
		
		var room_cell = _key_rooms[z] as RoomCell
		var chunks = _room_chunks.get(room_cell.size, []) as Array
		
		var chunk = null
		if chunks and chunks.size() > 0:
			chunk = chunks[randi() % chunks.size()] as PackedScene
			if chunk:
				chunk = chunk.instance()		
		
		var chunk_map: TileMap = null
		var player_spawn: Node2D = null
		var stairs_spawn: Node2D = null
		if chunk:
			chunk_map = chunk.find_node("TileMap") as TileMap
			player_spawn = chunk.find_node("PlayerSpawn") as Node2D
			stairs_spawn = chunk.find_node("StairsSpawn") as Node2D
			
		var x = floor(room_cell.bounds.position.x)
		var y = floor(room_cell.bounds.position.y)

		var _spawn_point: Node2D = null
		if first_room and player_spawn:
			_spawn_point = owner.find_node("PlayerSpawn", true, false) as Node2D
			if _spawn_point:			
				_spawn_point.global_position = Vector2(x * tileX, y * tileY) + player_spawn.global_position

		if last_room and stairs_spawn:
			var _stairs_point = owner.find_node("StairsSpawn", true, false) as Node2D
			if _stairs_point:
				_stairs_point.global_position = Vector2(x * tileX, y * tileY) + stairs_spawn.global_position
		
		for i in range(x, x + floor(room_cell.bounds.size.x)):
			for j in range(y + floor(room_cell.bounds.size.y), y - 1, -1):
				var globalX = i * tileX + halfX
				var globalY = j * tileY + halfY
				var globalVec = Vector2(globalX, globalY)
				var too_close = false
				
				if _spawn_point:
					too_close = globalVec.distance_to(_spawn_point.global_position) <= 300.0
				
				if chunk_map:
					var val = chunk_map.get_cell(i - x, j - y)
					_tile_map.set_cell(i, j, val)
					if val != -1 and not too_close:
						_open_tiles.push_back(globalVec)
				else:
					_tile_map.set_cell(i, j, 0)
					if not too_close:
						_open_tiles.push_back(globalVec)

	_tile_map.update_bitmask_region()
	_tile_map.update_dirty_quadrants()


func _render_hallways():
	var tileX = _tile_map.cell_size.x
	var tileY = _tile_map.cell_size.y
	var halfX = tileX * 0.5
	var halfY = tileY * 0.5

	for _hallway in _hallways:
		var hallway = _hallway as Edge
		var xdiff = abs(hallway.end.x - hallway.start.x)
		var ydiff = abs(hallway.end.y - hallway.start.y)
		
		if xdiff >= ydiff:
			var dir = sign(hallway.end.x - hallway.start.x)
			for i in range(floor(hallway.start.x), floor(hallway.end.x) + dir, dir):
				_dig_hallway(i, floor(hallway.start.y))
				_dig_hallway(i, floor(hallway.start.y) - 1)
				_open_tiles.push_back(Vector2(i * tileX + halfX, floor(hallway.start.y) * tileY + halfY))
				_open_tiles.push_back(Vector2(i * tileX + halfX, (floor(hallway.start.y) - 1) * tileY + halfY))
				#uncomment for 3 wide
				#_dig_hallway(i, floor(hallway.start.y) + 1)
		else:
			var dir = sign(hallway.end.y - hallway.start.y)
			for j in range(floor(hallway.start.y), floor(hallway.end.y) + dir, dir):
				_dig_hallway(floor(hallway.start.x), j)
				_dig_hallway(floor(hallway.start.x) - 1, j)
				_open_tiles.push_back(Vector2(floor(hallway.start.x) * tileX + halfX, j * tileY + halfY))
				_open_tiles.push_back(Vector2((floor(hallway.start.x) - 1) * tileX + halfX, j * tileY + halfY))
				#uncomment for 3 wide
				#_dig_hallway(floor(hallway.start.x) + 1, j)

	_tile_map.update_bitmask_region()
	_tile_map.update_dirty_quadrants()


func _dig_hallway(x: float, y: float):
	var cell = _tile_map.get_cell(x, y)
	if cell == -1:
		_tile_map.set_cell(x, y, 0)
