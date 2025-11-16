class_name Main extends Node3D

@onready var grid: Grid = $Grid
@onready var character: Character = $Character
@onready var camera_3d: Camera3D = $Camera3D
@onready var combo_label: Label = $CanvasLayer/Control/Combo
@onready var moves_left_label: Label = $CanvasLayer/Control/MovesLeft
@onready var final_score_control: Control = $CanvasLayer/Control/FinalScoreControl
@onready var final_score_label: Label = $CanvasLayer/Control/FinalScoreControl/FinalScoreLabel
@onready var combo_control: ComboControl = $CanvasLayer/Control/ComboControl
@onready var colors: Colors = $Colors
@onready var scene_transition_control: SceneTransitionControl = $CanvasLayer/SceneTransitionControl
@onready var restart_button: Button = $CanvasLayer/Control/FinalScoreControl/RestartButton
@onready var character_moves_left_label: Label3D = $Character/SpriteContainer/Sprite3D/CharacterMovesLeftLabel
@onready var score_label: Label = $CanvasLayer/Control/Control/ScoreLabel
@onready var level_label: Label = $CanvasLayer/Control/LevelLabel

const FISH = preload("res://scenes/fish.tscn")
const COMBO = preload("res://scenes/combo.tscn")

@export var levels: Array[LevelResource]

var credits = 10.0
var score := 0
var combo := 0
var is_combo : bool : 
	get: return combo > 1
var last_color: Color
var moves_left := 10
var max_moves_left := 10
var max_move_distance := 1.0
var max_combo_move_distance := 2.0
var move_per_combo := 0.2
var magnet_power := 0.0
var temporary_mov_distance := 0.0
var credits_gain = 1.0

@export_category("Fishes")
@export var fish_before_end_portal := 5
var current_fish_count := 0
var end_portal_instance: Fish
@export var fishes: Array[ObjectResource]
@export var upgrades: Array[ObjectResource]
@export var end_portal: ObjectResource
@export var fish_level := 1.05;
@export var upgrade_chance := 0.1;

var upgrade_random: FixedRandom
var current_level_index = 0
var current_level: LevelResource

func _ready() -> void:
	upgrade_random = FixedRandom.new()
	restart_button.pressed.connect(restart)
	character.moved.connect(handle_movement)
	load_level(levels[current_level_index])
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		next_level()
		
func next_level():
	current_level_index += 1
	load_level(levels[current_level_index % levels.size()])
	
func _process(delta: float) -> void:
	var pos = (get_viewport().get_mouse_position() / Vector2(get_viewport().size)) - Vector2.ONE / 2.0
	camera_3d.global_position.x = lerp(camera_3d.global_position.x, character.global_position.x + pos.x * 8.0, delta * 2.0)

func gain_score(value):
	score += value * (combo + 1.0)
	score_label.text = str(score)

func gain_combo(value):
	combo = max(combo + value, 0)
	if combo > 1:
		var new_combo := COMBO.instantiate() as Combo
		add_child(new_combo)
		new_combo.set_combo(combo)
		new_combo.global_position = character.global_position
		
func reset_combo():
	combo = 0
	combo_control.clear()

func update_tiles_color():
	var character_pos = Vector2(character.global_position.x, character.global_position.z)
	var max_distance = min(combo * move_per_combo, max_combo_move_distance) + max_move_distance + 0.1 + temporary_mov_distance
	for tile in grid.tiles.values():
		var tile_pos = Vector2(tile.global_position.x, tile.global_position.z)
		tile.is_available = tile != character.target_tile and character_pos.distance_to(tile_pos) / grid.tile_size.x <= max_distance
		tile.update_color()
		
func update_moves_left():
	character_moves_left_label.text = str(moves_left)
	
func handle_movement():
	temporary_mov_distance = 0.0
	
	for tile in grid.tiles.values():
		tile.label_3d.text = str(floor(character.global_position.distance_to(tile.global_position) / grid.tile_size.x * 10.0) / 10.0)
		
	character.target_tile.bump()
	if character.target_tile.object:
		var fish := character.target_tile.object as Fish
		handle_loot(fish)
		character.target_tile.object = null
		colors.base_color = fish.color if combo > 1 and fish else colors.default_color
	else:
		reset_combo()
		colors.base_color = colors.default_color

		
		moves_left -= 1
		character_moves_left_label.scale = Vector3.ONE * 2.0
		if moves_left <= 0:
			final_score_control.set_visible(true)
			final_score_label.text = str(score)
	update_moves_left()
	update_tiles_color()
	
	if not end_portal_instance:
		credits += randf_range(0.5, 1.0) * credits_gain;
		if credits > 1.0:
			spend_credits()
		else:
			if grid.get_fish_tiles().size() <= 0:
				spawn_fish()
				credits += 5.0
				

func handle_loot(fish: Fish):
	current_fish_count += 1
	if not end_portal_instance and current_fish_count >= fish_before_end_portal:
		var portal = spawn_fish()
		if portal:
			portal.load_resource(end_portal)
			end_portal_instance = portal
		
	match fish.resource.effect:
		ObjectResource.ObjectEffect.IncreaseMovement:
			max_move_distance += fish.resource.value
		ObjectResource.ObjectEffect.IncreaseComboMovement:
			max_combo_move_distance += fish.resource.value
		ObjectResource.ObjectEffect.IncreaseMagnet:
			magnet_power += fish.resource.value
		ObjectResource.ObjectEffect.TemporaryMoveDistance:
			temporary_mov_distance += fish.resource.value
		ObjectResource.ObjectEffect.UpgradeDropChance:
			upgrade_chance += fish.resource.value
		ObjectResource.ObjectEffect.EndLevel:
			next_level()
	
	last_color = fish.color if fish else colors.default_color
	
	if not fish: return
	fish.loot()
	gain_score(fish.resource.value)
	if fish.resource.combo:
		gain_combo(1)
		combo_control.add_fish(fish)
		combo_control.set_combo(combo)
	if fish.resource.description:
		var new_combo := COMBO.instantiate() as Combo
		add_child(new_combo)
		new_combo.set_description(fish.resource.description)
		new_combo.global_position = character.global_position

func spend_credits():
	while credits >= 1.0:
		spawn_random_fish()
		credits -= 1.0
		await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		
func spawn_fish() -> Fish:
	var tiles = grid.tiles.values()
	for tile in tiles: tile.fish_weight = 0.0
	var fish_tiles = tiles.filter(func(a): return a.object)
	for tile in fish_tiles:
		for ntile in grid.get_tile_neighbours(tile):
			ntile.fish_weight += 1.0
		
	var empty_tiles = tiles.filter(func(a): return not a.object and a != character.target_tile)
	empty_tiles.shuffle()
	empty_tiles.sort_custom(func(a,b):
		return (a.fish_weight > b.fish_weight and randf() < magnet_power)
	)
	
	if not empty_tiles.size(): return;
	
	var tile : Tile = empty_tiles[0]
	
	var new_fish := FISH.instantiate() as Fish
	new_fish.global_position = tile.global_position
	tile.object = new_fish
	add_child(new_fish)
	return new_fish
	
func spawn_random_fish()-> Fish:
	var fish = spawn_fish()
	if fish:
		if upgrade_random.pick():
			fish.load_resource(upgrades.pick_random())
		else:
			fish.load_resource(fishes[min(floor(randf() * fish_level), fishes.size()-1)])
	return fish

func load_level(level: LevelResource):
	upgrade_random.reset()
	upgrade_random.rate = upgrade_chance
	
	current_level = level
	level_label.text = str("Level ", current_level_index + 1)
	
	final_score_control.set_visible(false)

	await SceneManager.scene_transition_control.open()
	
	# Level
	grid.grid_size = level.grid_size
	colors.base_color = level.base_color
	max_moves_left = level.max_moves_left
	fish_before_end_portal = level.fish_before_end_portal
	credits = level.starting_credits
	
	# Upgrades
	max_move_distance = 1.0
	max_combo_move_distance = 2.0
	move_per_combo = 0.2
	magnet_power = 0.0
	temporary_mov_distance = 0.0
	credits_gain = 1.0
	upgrade_chance = 0.1
		
	current_fish_count = 0
	reset_combo()
	last_color = colors.default_color
	moves_left = max_moves_left
	
	var tile = grid.tiles.values().pick_random()
	camera_3d.global_position.x = character.global_position.x
	character.set_tile(tile)
	await spend_credits()
	update_tiles_color()
	update_moves_left()
	
	await SceneManager.scene_transition_control.close()

func restart():
	score = 0
	score_label.text = str(score)
	current_level_index = 0
	load_level(levels[current_level_index])
