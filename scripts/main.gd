class_name Main extends Node3D

@onready var grid: Grid = $Grid
@onready var character: Character = $Character
@onready var camera_3d: Camera3D = $Camera3D
@onready var score_label: Label = $CanvasLayer/Control/Score
@onready var combo_label: Label = $CanvasLayer/Control/Combo
@onready var moves_left_label: Label = $CanvasLayer/Control/MovesLeft
@onready var final_score_control: Control = $CanvasLayer/Control/FinalScoreControl
@onready var final_score_label: Label = $CanvasLayer/Control/FinalScoreControl/FinalScoreLabel

const FISH = preload("res://scenes/fish.tscn")
const COMBO = preload("res://scenes/combo.tscn")

var credits = 0.0
var score := 0
var combo := 0
var is_combo : bool : 
	get: return combo > 1
var last_color: Color
var moves_left := 20
var max_moves_left := 20
var max_move_distance := 1.0
var max_combo_move_distance := 2.0
var move_per_combo := 0.5
var magnet_power := 0.0

@export_category("Fishes")
@export var fishes: Array[ObjectResource]
@export var upgrades: Array[ObjectResource]
@export var fish_level := 1.05;
@export var upgrade_chance := 0.1;

func _ready() -> void:
	character.moved.connect(handle_movement)
	camera_3d.global_position.x = character.global_position.x
	score_label.text = str(0)
	update_tiles_color()
	
	var tile = grid.tiles.values().pick_random()
	character.move_to(tile)
	for i in range(0, 20):
		await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		spawn_fish()
	
func _process(delta: float) -> void:
	camera_3d.global_position.x = lerp(camera_3d.global_position.x, character.global_position.x, delta * 5.0)

func gain_score(value):
	score += value * (combo + 1.0)
	score_label.text = str(score)

func gain_combo(value):
	combo = max(combo + value, 0)
	combo_label.text = str("x", combo)
	if combo > 1:
		var new_combo := COMBO.instantiate() as Combo
		add_child(new_combo)
		new_combo.set_combo(combo)
		new_combo.global_position = character.global_position
		
func reset_combo():
	combo = 0
	combo_label.text = str("x", combo)

func update_tiles_color():
	var character_pos = Vector2(character.global_position.x, character.global_position.z)
	for tile in grid.tiles.values():
		var tile_pos = Vector2(tile.global_position.x, tile.global_position.z)
		tile.is_available = character_pos.distance_to(tile_pos) / grid.tile_size.x <= min(combo * move_per_combo, max_combo_move_distance) + max_move_distance + 0.1
		tile.update_color()
		
func update_moves_left():
	moves_left_label.text = str(moves_left, "/", max_moves_left)

func handle_movement():
	for tile in grid.tiles.values():
		tile.label_3d.text = str(floor(character.global_position.distance_to(tile.global_position) / grid.tile_size.x * 10.0) / 10.0)
		
	character.target_tile.bump()
	if character.target_tile.object:
		var fish := character.target_tile.object as Fish
		handle_loot(fish)
		character.target_tile.object = null
	else: 
		reset_combo()
		
	credits += randf_range(0.0, 1.0);
	if not combo: moves_left -= 1
	if moves_left <= 0:
		final_score_control.set_visible(true)
		final_score_label.text = str(score)
	update_moves_left()
	
	if credits > 1.0:
		spawn_fish()
		credits -= 1.0
	else:
		if grid.get_fish_tiles().size() <= 0:
			spawn_fish()
			credits += 5.0
			
	update_tiles_color()

func handle_loot(fish: Fish):
	match fish.resource.effect:
		ObjectResource.ObjectEffect.IncreaseMovement:
			max_move_distance += fish.resource.value
		ObjectResource.ObjectEffect.IncreaseComboMovement:
			max_combo_move_distance += fish.resource.value
		ObjectResource.ObjectEffect.IncreaseMagnet:
			magnet_power += fish.resource.value
		
	last_color = fish.color
	fish.loot()
	gain_score(1)
	gain_combo(1)
	
func spawn_fish():
	var tiles = grid.tiles.values()
	for tile in tiles: tile.fish_weight = 0.0
	var fish_tiles = tiles.filter(func(a): return a.object)
	for tile in fish_tiles:
		var ntile = grid.get_tile(grid.world_to_grid_position(tile.position) + Vector2.LEFT)
		if ntile: ntile.fish_weight += 1.0
		ntile = grid.get_tile(grid.world_to_grid_position(tile.position) + Vector2.UP)
		if ntile: ntile.fish_weight += 1.0
		ntile = grid.get_tile(grid.world_to_grid_position(tile.position) + Vector2.RIGHT)
		if ntile: ntile.fish_weight += 1.0
		ntile = grid.get_tile(grid.world_to_grid_position(tile.position) + Vector2.DOWN)
		if ntile: ntile.fish_weight += 1.0
		
	var empty_tiles = tiles.filter(func(a): return not a.object and a != character.target_tile)
	empty_tiles.shuffle()
	empty_tiles.sort_custom(func(a,b):
		return (a.fish_weight > b.fish_weight and randf() < magnet_power)
	)
	var tile : Tile = empty_tiles[0]
	if not tile: return;
	var new_fish := FISH.instantiate() as Fish
	new_fish.global_position = tile.global_position
	tile.object = new_fish
	add_child(new_fish)
	if randf() < upgrade_chance:
		new_fish.load_resource(upgrades.pick_random())
	else:
		new_fish.load_resource(fishes[min(floor(randf() * fish_level), fishes.size()-1)])
