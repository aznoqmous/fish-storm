@tool
class_name Grid extends Node3D

@export var grid_size : Vector2i :
	set(value): grid_size = value; build_grid()
		
@export var tile_size: Vector2 :
	set(value): tile_size = value; build_grid()

@export var tile_height_variation: float:
	set(value): tile_height_variation = value; build_grid()

var tiles: Dictionary[Vector2, Tile]

const TILE = preload("res://scenes/tile.tscn")

func _ready() -> void:
	build_grid()

func build_grid():
	tiles.clear()
	for child in get_children(): child.free()
	for x in range(-grid_size.x / 2.0, grid_size.x / 2.0):
		for y in range(-grid_size.y / 2.0, grid_size.y / 2.0):
			if randf() < 0.2: continue
			var tile := TILE.instantiate() as Tile
			var pos = Vector2(x, y)
			tile.name = str("Tile ", x, ",", "y")
			add_child(tile)
			tile.global_position = Vector3(x * tile_size.x, randf_range(0, tile_height_variation), y * tile_size.y)
			tiles[pos] = tile

func world_to_grid_position(world_position: Vector3) -> Vector2:
	return Vector2(world_position.x, world_position.z) / tile_size

func grid_to_world_position(grid_position: Vector2):
	var tile = get_tile(grid_position)
	if not tile: return;
	var height = tile.position.y
	return Vector3(grid_position.x * tile_size.x, height, grid_position.y * tile_size.y)
	
func get_tile(pos: Vector2):
	return tiles[pos] if tiles.has(pos) else null
