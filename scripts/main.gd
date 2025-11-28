class_name Main extends Node3D

@onready var grid: Grid = $Grid
@onready var character: Character = $Character
@onready var camera_3d: Camera3D = $Camera3D
@onready var combo_label: Label = $CanvasLayer/Control/ComboControl/ComboLabel
@onready var combo_control: ComboControl = $CanvasLayer/Control/ComboControl
@onready var colors: Colors = $Colors
@onready var score_label: Label = $CanvasLayer/Control/Control/ScoreLabel
@onready var level_label: Label = $CanvasLayer/Control/LevelLabel
@onready var character_moves_left_label: Label3D = $Character/SpriteContainer/CharacterMovesLeftLabel
@onready var unlock_control_container: UnlockControlContainer = $CanvasLayer/Control/UnlockControlContainer
@onready var final_score_control: FinalScoreControl = $CanvasLayer/Control/FinalScoreControl
@onready var leader_board_container_control: LeaderBoardContainerControl = $CanvasLayer/Control/FinalScoreControl/LeaderBoardContainerControl

const FISH = preload("res://scenes/fish.tscn")
const COMBO = preload("res://scenes/combo.tscn")
const HEART = preload("res://scenes/heart.tscn")
const HEART_LOSS = preload("res://scenes/heart_loss.tscn")

@export var levels: Array[LevelResource]
var score := 0
var score_display := 0.0
var credits = 10.0
var combo := 0

var max_combo := 10.0
var moves_left := 10
var max_moves_left := 10
var max_move_distance := 1.0
var max_combo_move_distance := 2.0
var move_per_combo := 0.2
var magnet_power := 0.0
var temporary_mov_distance := 0.0
var credits_gain = 1.0

var is_combo : bool : 
	get: return combo > 1
var last_color: Color

var loop_index: int:
	get: return floor(float(current_level_index) / levels.size())
var level_in_loop: int:
	get: return current_level_index % levels.size()

@export_category("Fishes")
@export var fish_before_end_portal := 5
var current_fish_count := 0
var end_portal_instance: Portal
@export var fishes: Array[ObjectResource]
@export var upgrades: Array[ObjectResource]
@export var end_portal: ObjectResource
@export var fish_level := 1.05;
@export var upgrade_chance := 0.1;

var upgrade_random: FixedRandom
var current_level_index = 0
var current_level: LevelResource

var available_upgrades : Array[ObjectResource]

@export_category("Actions")
@onready var active_control: ActiveControl = $CanvasLayer/Control/ActiveControl
var is_free_move := false

var start_time := 0.0

func _ready() -> void:
	upgrade_random = FixedRandom.new()
	character.moved.connect(handle_movement)
	
	active_control.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
			trigger_active_effect()
	)
	
	max_moves_left = Game.selected_character.max_moves_left
	moves_left = max_moves_left
	load_level(levels[current_level_index])
	reset_upgrades()
	load_character(Game.selected_character)
	reset_active_charges()
	bind_character_unlocks()

	start_time = get_time()
	
func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_up"):
		#next_level()
	if event.is_action_pressed("ui_down"):
		Game.clear()
	#if event.is_action_pressed("ui_right"):
		#gain_combo(1)
	#if event.is_action_pressed("ui_left"):
		#reset_combo()
	if event.is_action_pressed("Power"):
		trigger_active_effect()
		
func load_character(res: CharacterResource):
	max_combo += res.max_combo
	#max_moves_left += res.max_moves_left
	max_move_distance += res.max_move_distance
	max_combo_move_distance += res.max_combo_move_distance
	move_per_combo *= res.move_per_combo
	magnet_power += res.magnet_power
	temporary_mov_distance += res.temporary_mov_distance
	credits_gain *= res.credits_gain
	character.load_resource(res)
	
	active_control.charges_control.max_charges = res.active_cooldown
	active_control.charges_control.build()
	active_control.charges_control.update()
	active_control.update()
	active_control.active_effect_sprite.material.set("shader_parameter/texture_albedo", res.active_effect_sprite)
	
	available_upgrades = upgrades.filter(func(u): return not res.banned_upgrades.has(u))
	

		
func next_level():
	print("Level ", current_level_index, " : ", get_time() - start_time)
	start_time = get_time()
	if current_level_index + 1 >= levels.size():
		Game.complete_run(Game.selected_character)
		end_game()
		combo = 10
		for tile in grid.tiles.values():
			tile.bump_strength = 10.0
		return
	current_level_index += 1
	load_level(levels[current_level_index % levels.size()])
	reset_upgrades()
	load_character(Game.selected_character)
	
func _process(delta: float) -> void:
	var pos = (get_viewport().get_mouse_position() / Vector2(get_viewport().size)) - Vector2.ONE / 2.0
	camera_3d.global_position.x = lerp(camera_3d.global_position.x, character.global_position.x + pos.x * 8.0, delta * 2.0)
	score_display = lerp(score_display, float(score), delta * 5.0)
	score_label.text = str(int(ceil(score_display)))
	
func gain_score(value):
	score += value * (combo + 1.0)
	#score_label.text = str(score)
	on_score.emit()

func gain_combo(value):
	combo = clamp(0, combo + value, max_combo)
	combo_control.set_combo(combo)
	if combo > 1:
		var new_combo := COMBO.instantiate() as Combo
		add_child(new_combo)
		new_combo.set_combo(combo)
		new_combo.global_position = character.global_position
	on_combo.emit()
	
func reset_combo():
	combo = 0
	combo_control.clear()
	
func reset_active_charges():
	active_control.charges_control.charges = 0
	active_control.charges_control.update()
	active_control.update()

func update_tiles_color():
	var character_pos = Vector2(character.global_position.x, character.global_position.z)
	var max_distance = min(combo * move_per_combo, max_combo_move_distance) + max_move_distance + 0.1 + temporary_mov_distance
	for tile in grid.tiles.values():
		var tile_pos = Vector2(tile.global_position.x, tile.global_position.z)
		tile.is_available = (not tile.object or tile.object.is_available()) and tile != character.target_tile and character_pos.distance_to(tile_pos) / grid.tile_size.x <= max_distance
		tile.update_color()
		tile.is_last_position = false
	if active_control.is_charged and Game.selected_character.active_effect == CharacterResource.ActiveEffect.ReturnToLastPosition:
		var tile = grid.get_tile(grid.world_to_grid_position(character.last_position))
		if tile: tile.is_last_position = true
func update_moves_left():
	character_moves_left_label.text = str(moves_left)
	
func handle_movement():
	temporary_mov_distance = 0.0
	
	#for tile in grid.tiles.values():
		#tile.label_3d.text = str(floor(character.global_position.distance_to(tile.global_position) / grid.tile_size.x * 10.0) / 10.0)
	character.target_tile.bump()
	if Game.visuals_value:
		for tile in grid.tiles.values():
			tile.bump_strength = (1.0 - min(tile.global_position.distance_to(character.global_position) / 5.0, 1.0)) * ((combo / 10.0) * 2.0)
	
	if character.target_tile.object:
		var fish := character.target_tile.object as Fish
		handle_loot(fish)
		character.target_tile.object = null
		colors.base_color = fish.color if combo > 1 and fish else colors.default_color
	elif not is_free_move:
		reset_combo()
		colors.base_color = colors.default_color
		moves_left -= 1
		var heart_loss = HEART_LOSS.instantiate()
		add_child(heart_loss)
		heart_loss.global_position = character.global_position
		character_moves_left_label.scale = Vector3.ONE * 2.0
		character.damage_particles_3d.emitting = true
		if moves_left <= 0:
			end_game()
			
	update_moves_left()
	update_tiles_color()
	
	
	
	if not current_fish_count >= fish_before_end_portal:
		gain_credits()
		
	is_free_move = false
	
		
func gain_credits():
	var fish_count = grid.get_fish_tiles().size()
	if fish_count <= 2: credits += 1
	credits += credits_gain;
	if credits > 1.0:
		spend_credits()
	else:
		if grid.get_fish_tiles().size() <= 0:
			spawn_fish()
			credits += 5.0
			
func handle_loot(fish: Fish):
	if not fish.resource: return;
	
	if fish.resource.effect == ObjectResource.ObjectEffect.None:
		current_fish_count += 1
	
	if fish.resource.effect: character.add_upgrade(fish.resource)
	
	last_color = fish.color if fish else colors.default_color
	
	if not fish: return
	
	if not end_portal_instance.is_active:
		active_control.charges_control.gain_charge(fish.resource.charge_gain)
		active_control.update()
	
	fish.loot()
	if fish.resource.score: gain_score(fish.resource.score)
	if fish.resource.combo and combo < max_combo:
		gain_combo(1)
		combo_control.add_fish(fish)
		
	# upgrade
	if fish.resource.description:
		var new_combo := COMBO.instantiate() as Combo
		add_child(new_combo)
		new_combo.set_description(fish.resource.description)
		new_combo.global_position = character.global_position
		
		if fish.is_portal:
			if grid.get_fish_tiles().size() <= 0 and moves_left >= max_moves_left:
				new_combo.set_description("WOOOOOOW !")
				gain_score(5)
				on_wooow.emit()
			elif grid.get_fish_tiles().size() <= 0:
				new_combo.set_description("Perfect !")
				gain_score(3)
				on_perfect.emit()
			elif moves_left >= max_moves_left:
				new_combo.set_description("Flawless !")
				gain_score(3)
				on_flawless.emit()
	
	match fish.resource.effect:
		ObjectResource.ObjectEffect.SpawnFishes:
			for i in range(0, fish.resource.value):
				var fishh = spawn_fish()
				if fishh: fishh.load_resource(fishes[min(floor(randf() * fish_level), fishes.size()-1)])
				await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		ObjectResource.ObjectEffect.TemporaryMoveDistance:
			temporary_mov_distance += fish.resource.value
		ObjectResource.ObjectEffect.AttractFishes:
				var char_pos = grid.world_to_grid_position(character.global_position)
				var tile = grid.get_fish_tiles()
				if tile.size():
					tile.shuffle()
					tile.sort_custom(func(a,b): return a.global_position.distance_to(character.global_position) < b.global_position.distance_to(character.global_position))
					for i in range(0, min(fish.resource.value, tile.size())):
						var f := tile[i].object as Fish
						if not f: continue
						f.move_toward_grid_position(char_pos)
						#await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		ObjectResource.ObjectEffect.CollectFarestFishes:
			for i in range(0, fish.resource.value):
				var tiles = grid.get_fish_tiles()
				if not tiles.size(): break;
				tiles.shuffle()
				tiles.sort_custom(func(a,b): return a.global_position.distance_to(character.global_position) > b.global_position.distance_to(character.global_position))
				var tile = tiles[0]
				if tile and tile.object:
					handle_loot(tile.object)
					tile.object = null
					update_tiles_color()
					if not end_portal_instance.is_active:
						gain_credits()
					await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
				else: break
			update_moves_left()
		ObjectResource.ObjectEffect.RegainMovesLeft:
			moves_left = min(moves_left + fish.resource.value, max_moves_left)
			update_moves_left()
		ObjectResource.ObjectEffect.EndLevel:
			next_level()
			
func spend_credits_spaced():
	while credits >= 1.0:
		spawn_random_spaced_fish()
		credits -= 1.0
		await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		
func spawn_random_spaced_fish():
	var fish = spawn_spaced_fish()
	if fish:
		if upgrade_random.pick():
			fish.load_resource(available_upgrades.pick_random())
			fish.is_upgrade = true
			upgrade_random.reset()
		else:
			fish.load_resource(fishes[min(floor(randf() * fish_level), fishes.size()-1)])
	return fish
	
func spawn_spaced_fish():
	var tiles = grid.tiles.values()
	for tile in tiles: tile.fish_weight = 0.0
	var fish_tiles = tiles.filter(func(a): return a.object)
	for tile in fish_tiles:
		for ntile in grid.get_tile_neighbours(tile):
			ntile.fish_weight += 1.0
			
	#for tile in tiles: tile.label_3d.text = str(tile.fish_weight)
		
	var empty_tiles = tiles.filter(func(a): return not a.object and a != character.target_tile)
	empty_tiles.shuffle()
	empty_tiles.sort_custom(func(a,b):
		return a.fish_weight < b.fish_weight and randf() < 0.5
	)
	
	if not empty_tiles.size(): return;
	
	var tile : Tile = empty_tiles[0]
	
	var new_fish := FISH.instantiate() as Fish
	add_child(new_fish)
	tile.object = new_fish
	new_fish.global_position = tile.global_position
	return new_fish

func spend_credits():
	while credits >= 1.0:
		spawn_random_fish()
		credits -= 1.0
		await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		
func spawn_object_at_position(resource: ObjectResource, pos:Vector3):
	var tile = grid.tiles[grid.world_to_grid_position(pos)]
	if not tile: return;
	var new_fish := FISH.instantiate() as Fish
	new_fish.global_position = tile.global_position
	add_child(new_fish)
	tile.object = new_fish
	new_fish.load_resource(resource)
	return new_fish
	
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
	add_child(new_fish)
	tile.object = new_fish
	new_fish.global_position = tile.global_position
	return new_fish
	
func spawn_random_fish()-> Fish:
	var fish = spawn_fish()
	if fish:
		if upgrade_random.pick():
			fish.load_resource(available_upgrades.pick_random())
			fish.is_upgrade = true
		else:
			fish.load_resource(fishes[min(floor(randf() * fish_level), fishes.size()-1)])
	return fish

func reset_upgrades():
	# Upgrades
	max_combo = 10.0
	max_move_distance = 1.0
	max_combo_move_distance = 2.0
	move_per_combo = 0.2
	magnet_power = 0.0
	temporary_mov_distance = 0.0
	credits_gain = 0.6
	upgrade_chance = 0.1

func load_level(level: LevelResource):
	upgrade_random.rate = upgrade_chance
	
	current_level = level
	level_label.text = str("Level ", current_level_index + 1)
	
	final_score_control.set_visible(false)

	await SceneManager.scene_transition_control.open()
	
	# Level
	grid.load_level(current_level.levels.pick_random())
	
	colors.base_color = level.base_color
	fish_before_end_portal = floor(level.fish_before_end_portal * (1.0 + pow(loop_index * 1.6, 1.6) / 10.0))
	credits = level.starting_credits * 1.0 / (1.0 + pow(loop_index * 1.2, 1.2)/10.0)

	current_fish_count = 0
	reset_combo()
	last_color = colors.default_color
	
	# Character
	var empty_tiles = grid.get_empty_tiles().filter(func(t):
		return grid.get_tile_neighbours(t).size() > 2
	)
	var tile = empty_tiles.pick_random()
	camera_3d.global_position.x = character.global_position.x
	character.set_tile(tile)
	
	if moves_left < max_moves_left:
		var heart_tile = grid.get_empty_tiles().pick_random()
		var heart := HEART.instantiate() as Fish
		add_child(heart)
		heart_tile.object = heart
		heart.global_position = heart_tile.global_position
		
	update_tiles_color()
	update_moves_left()
	
	
	await SceneManager.scene_transition_control.close()
	
	await spend_credits()
	#await spend_credits_spaced()
	
	on_enter_level.emit()
	


func restart():
	score = 0
	score_label.text = str(score)
	current_level_index = 0
	moves_left = max_moves_left
	upgrade_random.reset()
	update_moves_left()
	reset_upgrades()
	load_level(levels[current_level_index])
	load_character(Game.selected_character)
	reset_active_charges()
	
func trigger_active_effect():
	if character.is_jumping: return;
	if not active_control.is_charged: return;
	active_control.trigger_effect_audio.play()
	update_moves_left()
	
	reset_active_charges()
	
	var ch := Game.selected_character
	match ch.active_effect:
		CharacterResource.ActiveEffect.AddCombo:
			gain_combo(ch.value)
			update_tiles_color()
		CharacterResource.ActiveEffect.SpawnUpgrade:
			credits = 0
			var fish = spawn_fish()
			if fish: 
				fish.load_resource(available_upgrades.pick_random())
				fish.is_upgrade = true
		CharacterResource.ActiveEffect.SpawnFishes:
			for i in range(0, ch.value):
				var fish = spawn_fish()
				if fish: fish.load_resource(fishes[min(floor(randf() * fish_level), fishes.size()-1)])
				await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
		CharacterResource.ActiveEffect.TemporaryMovementIncrease:
			temporary_mov_distance += ch.value
			combo = floor(combo/2.0)
			combo_control.set_combo(combo)
			update_tiles_color()
		CharacterResource.ActiveEffect.LootFishesForMaxMoves:
			var tiles = grid.get_fish_tiles()
			if tiles.size():
				tiles.shuffle()
				tiles.sort_custom(func(a,b): return a.global_position.distance_to(character.global_position) > b.global_position.distance_to(character.global_position))
				for i in range(0, ch.value):
					if i >= tiles.size(): break
					var tile = tiles[i]
					if tile and tile.object:
						handle_loot(tile.object)
						tile.object = null
						update_tiles_color()
						if not end_portal_instance.is_active:
							gain_credits()
						await get_tree().create_timer(randf_range(1.0, 2.0) * 0.1).timeout
					else: break
					
				update_tiles_color()
			
		CharacterResource.ActiveEffect.ReturnToLastPosition:
			var pos = grid.world_to_grid_position(character.last_position)
			var tile = grid.get_tile(pos)
			is_free_move = true
			character.move_to(tile)

	reset_active_charges()
	
func get_time():
	return Time.get_ticks_msec() / 1000.0

signal on_enter_level()
signal on_combo()
signal on_score()
signal on_flawless()
signal on_perfect()
signal on_wooow()

func bind_character_unlocks():
	var characters = Game.get_locked_characters()
	for c in characters:
		match c.unlock_type:
			CharacterResource.UnlockType.Level: 
				on_enter_level.connect(func():
					if not current_level_index >= c.unlock_min_level: return;
					if c.unlock_with_character and c.unlock_with_character != Game.selected_character: return;
					if current_level_index >= c.unlock_value: unlock_character(c)
				)
			CharacterResource.UnlockType.Combo:
				on_combo.connect(func():
					if not current_level_index >= c.unlock_min_level: return;
					if c.unlock_with_character and c.unlock_with_character != Game.selected_character: return;
					if combo >= c.unlock_value: unlock_character(c)
				)
			CharacterResource.UnlockType.Score:
				on_combo.connect(func():
					if not current_level_index >= c.unlock_min_level: return;
					if c.unlock_with_character and c.unlock_with_character != Game.selected_character: return;
					if score >= c.unlock_value: unlock_character(c)
				)
			CharacterResource.UnlockType.Flawless: 
				on_flawless.connect(func():
					if not current_level_index >= c.unlock_min_level: return;
					if c.unlock_with_character and c.unlock_with_character != Game.selected_character: return;
					unlock_character(c)
				)
			CharacterResource.UnlockType.Perfect: 
				on_perfect.connect(func():
					if not current_level_index >= c.unlock_min_level: return;
					if c.unlock_with_character and c.unlock_with_character != Game.selected_character: return;
					unlock_character(c)
				)
			CharacterResource.UnlockType.Wooow: 
				on_wooow.connect(func():
					if not current_level_index >= c.unlock_min_level: return;
					if c.unlock_with_character and c.unlock_with_character != Game.selected_character: return;
					unlock_character(c)
				)
			#CharacterResource.UnlockType.FishCount: pass
			#CharacterResource.UnlockType.TotalFishCount: pass
			
func unlock_character(cr: CharacterResource):
	if Game.unlocked_characters.has(cr): return;
	unlock_control_container.display_unlock(cr)
	Game.unlock_character(cr)

func end_game():
	moves_left = 0
	
	final_score_control.set_visible(true)
	final_score_control.animate()
	
	var id := 0
	if Game.username.length():
		id = await leader_board_container_control.send_data(
			Game.selected_character,
			Game.username,
			score,
			current_level_index
		)
	await leader_board_container_control.update()
	if id: leader_board_container_control.set_current(id)
