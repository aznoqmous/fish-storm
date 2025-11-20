@tool
class_name Grid extends Node3D

@onready var main: Main = $/root/Main

@export var grid_size : Vector2i :
	set(value): grid_size = value; build_grid()
		
@export var tile_size: Vector2 :
	set(value): tile_size = value; build_grid()

@export var tile_height_variation: float:
	set(value): tile_height_variation = value; build_grid()

var tiles: Dictionary[Vector2, Tile]

const TILE = preload("res://scenes/tile.tscn")

func build_grid():
	tiles.clear()
	for child in get_children():
		if child.object: child.object.free()
		child.free()
	
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
	var height = tile.position.y
	return Vector3(grid_position.x * tile_size.x, height, grid_position.y * tile_size.y)
	
func get_tile(pos: Vector2):
	return tiles[pos] if tiles.has(pos) else null
	
func get_fish_tiles():
	return tiles.values().filter(func(a: Tile): return a.object and not a.object.is_upgrade and not a.object.is_portal)

func get_empty_tiles():
	return tiles.values().filter(func(a: Tile): return not a.object and a != main.character.target_tile)
	
