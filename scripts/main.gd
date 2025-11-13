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
var moves_left := 20
var max_moves_left := 20

func _ready() -> void:
	character.moved.connect(handle_movement)
	camera_3d.global_position.x = character.global_position.x
	score_label.text = str(0)
	update_tiles_color()
	for i in range(0, 20): spawn_fish()
	
func _process(delta: float) -> void:
	camera_3d.global_position.x = lerp(camera_3d.global_position.x, character.global_position.x, delta * 5.0)

func handle_movement():
	credits += randf_range(0.0, 1.0);
	if not combo: moves_left -= 1
	if moves_left <= 0:
		final_score_control.set_visible(true)
		final_score_label.text = str(score)
	update_movements()
	if credits > 1.0:
		spawn_fish()
		credits -= 1.0
	pass

func spawn_fish():
	var tile : Tile = grid.tiles.values().filter(func(a): return not a.object and a != character.target_tile).pick_random()
	if not tile: return;
	var new_fish := FISH.instantiate() as Fish
	new_fish.global_position = tile.global_position
	tile.object = new_fish
	add_child(new_fish)

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
		tile.is_available = character_pos.distance_to(tile_pos) <= combo + 1.5
		tile.update_color()
		
func update_movements():
	moves_left_label.text = str(moves_left, "/", max_moves_left)
