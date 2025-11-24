@tool
class_name Grid extends Node3D

@onready var main: Main = $/root/Main

@export var grid_size : Vector2i
	#: set(value): grid_size = value; build_grid()
		
@export var tile_size: Vector2
	#: set(value): tile_size = value; build_grid()

@export var tile_height_variation: float
	#: set(value): tile_height_variation = value; build_grid()

var tiles: Dictionary[Vector2, Tile]

const TILE = preload("res://scenes/tile.tscn")

# generate a tile grid from parameters
func build_grid():
	clear()
	
	var ground_ratio = main.current_level.ground_ratio if main and main.current_level else 0.8
	for x in range(0, grid_size.x):
		for y in range(0, grid_size.y):
			var tile := TILE.instantiate() as Tile
			var pos = Vector2(x, y) - Vector2(grid_size) / 2.0
			tile.name = str("Tile ", x, ",", y)
			add_child(tile)
			tile.global_position = Vector3(pos.x * tile_size.x, randf_range(0, tile_height_variation), pos.y * tile_size.y)
			tiles[pos] = tile

	var ntiles = tiles.values()
	ntiles.shuffle()
	for i in range(0, (1.0 - ground_ratio) * ntiles.size()):
		var tile = ntiles[i]
		tiles.erase(world_to_grid_position(tile.position))
		tile.queue_free()

	var groups = get_tile_groups()
	groups.sort_custom(func(a,b): return a.size() > b.size())
	for i in range(1, groups.size()):
		for tile in groups[i]:
			tiles.erase(world_to_grid_position(tile.position))
			tile.queue_free()

func clear():
	tiles.clear()
	
	if level:
		for tile in level.tiles_container.get_children():
			if tile.object: tile.object.free()
		level.queue_free()
		
var level: Level
func load_level(scene:PackedScene):
	clear()
	level = scene.instantiate() as Level
	main.add_child(level)
	
	var positions = level.tiles_container.get_children().map(func(a): return a.position)
	positions.sort_custom((func(a,b): return a.x < b.x))
	var horizontal = Vector2(positions[0].x, positions[-1].x)
	positions.sort_custom((func(a,b): return a.z < b.z))
	var vertical = Vector2(positions[0].z, positions[-1].z)
	var width = abs(horizontal.x - horizontal.y)
	var height = abs(vertical.x - vertical.y)
	
	for tile in level.tiles_container.get_children():
		#tile.reparent(self)
		var pos = Vector2(tile.position.x, tile.position.z) - Vector2(width, height) / 2.0
		tile.global_position = Vector3(pos.x * tile_size.x, randf_range(0, tile_height_variation), pos.y * tile_size.y)
		tiles[pos] = tile
	
	var portal_pos = Vector2(level.end_portal.position.x, level.end_portal.position.z) - Vector2(width, height) / 2.0
	var portal_tile = get_tile(portal_pos)
	level.end_portal.global_position = Vector3(portal_pos.x * tile_size.x, portal_tile.position.y, portal_pos.y * tile_size.y)
	portal_tile.object = level.end_portal
	main.end_portal_instance = level.end_portal
		
func get_tile_groups():
	var groups = []
	var remaining_tiles = tiles.values()
	while remaining_tiles.size() > 0:
		var gtiles = get_tile_group(remaining_tiles[0])
		for tile in gtiles: remaining_tiles.erase(tile)
		groups.append(gtiles)
	return groups
	
func get_tile_group(tile, group=[]):
	group.append(tile)
	for ntile in get_tile_neighbours(tile):
		if group.has(ntile): continue;
		group = get_tile_group(ntile, group)
	return group
	
func get_tile_neighbours(tile):
	var ns = []
	var ntile = get_tile(world_to_grid_position(tile.position) + Vector2.LEFT)
	if ntile: ns.append(ntile)
	ntile = get_tile(world_to_grid_position(tile.position) + Vector2.UP)
	if ntile: ns.append(ntile)
	ntile = get_tile(world_to_grid_position(tile.position) + Vector2.RIGHT)
	if ntile: ns.append(ntile)
	ntile = get_tile(world_to_grid_position(tile.position) + Vector2.DOWN)
	if ntile: ns.append(ntile)
	return ns
	
func world_to_grid_position(world_position: Vector3) -> Vector2:
	return Vector2(world_position.x, world_position.z) / tile_size

func grid_to_world_position(grid_position: Vector2):
	var tile = get_tile(grid_position)
	if not tile: return;
	return Vector3(grid_position.x * tile_size.x, tile.position.y, grid_position.y * tile_size.y)
	
func get_tile(pos: Vector2):
	return tiles[pos] if tiles.has(pos) else null
	
func get_fish_tiles():
	return tiles.values().filter(func(a: Tile): return a.object and not a.object.is_upgrade and not a.object.is_portal)

func get_empty_tiles():
	return tiles.values().filter(func(a: Tile): return not a.object and a != main.character.target_tile)
	
