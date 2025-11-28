class_name Fish extends Node3D

@onready var main: Main = $/root/Main
@onready var sprite_container: Node3D = $ShadowSpriteContainer/SpriteContainer
@onready var shadow_sprite_container: Node3D = $ShadowSpriteContainer
@onready var sprite_3d: Sprite3D = $ShadowSpriteContainer/SpriteContainer/Sprite3D
@onready var sprite_light: OmniLight3D = $ShadowSpriteContainer/SpriteContainer/SpriteLight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var splash_particles: GPUParticles3D = $SplashParticles
@onready var loot_particles: GPUParticles3D = $LootParticles
@onready var bubble_particles: GPUParticles3D = $BubbleParticles

@onready var spawn_audio: AudioStreamPlayer3D = $SpawnAudio
@onready var loot_audio: AudioStreamPlayer3D = $LootAudio
@onready var land_audio: AudioStreamPlayer3D = $LandAudio
@onready var portal_loot_audio: AudioStreamPlayer = $PortalLootAudio
@onready var upgrade_loot_audio: AudioStreamPlayer = $UpgradeLootAudio

@export var colors: Array[Color]
@export var upgrade_color: Color
@export var end_portal_color: Color

var color: Color
var animation := 0.0
var animation_height := 5.0
var animation_depth := -10.0
@export var resource: ObjectResource

@export var is_upgrade := false
@export var is_portal := false
var is_fish : bool :
	get: return not is_upgrade and not is_portal

var charges = 0
var max_charges = 0

func _ready() -> void:
	animation_depth = randf_range(-10, -6)
	shadow_sprite_container.position.y = 0
	shadow_sprite_container.position.z = animation_depth
	shadow_sprite_container.scale = Vector3.ZERO
	splash_particles.global_position = shadow_sprite_container.global_position
	splash_particles.emitting = true
	
	color = colors.pick_random()
	#sprite_light.light_color = color
	#sprite_3d.material_override.set("shader_parameter/color", color)
	#splash_particles.material_override.set("albedo_color", color)
	#loot_particles.material_override.set("albedo_color", color)
	set_color(color)
	spawn_audio.play()
	bubble_particles.emitting = false
	
func _process(delta: float) -> void:
	if animation < 1.0:
		animation += delta
		shadow_sprite_container.position.y = sin(animation * PI) * animation_height
		shadow_sprite_container.position.z = lerp(animation_depth, 0.0, animation)
		shadow_sprite_container.scale = lerp(Vector3.ZERO, Vector3.ONE, animation)
	else:
		if shadow_sprite_container.position.y != 0:
			land_audio.play()
		shadow_sprite_container.position.y = 0.0
		bubble_particles.emitting = is_fish
	
	if not is_portal: animation_player.speed_scale = main.combo / 20.0 + 1.0
	sprite_3d.scale = lerp(sprite_3d.scale, Vector3.ONE, delta * 5.0)
	
func loot():
	if is_portal: portal_loot_audio.play()
	elif is_upgrade: upgrade_loot_audio.play()
	else: 
		#loot_audio.pitch_scale = 1.0 + float(main.combo / 10.0)
		loot_audio.play()
		
	animation_player.play("looted")
	if not is_portal and not is_upgrade:
		get_tree().create_tween().tween_property(self, "global_position", main.end_portal_instance.global_position, animation_player.current_animation_length / 2.0)
		await get_tree().create_timer(animation_player.current_animation_length / 2.0).timeout
		main.end_portal_instance.bump()
	if is_upgrade:
		get_tree().create_tween().tween_property(sprite_container, "global_position", sprite_container.global_position + Vector3.UP * 3.0, animation_player.current_animation_length / 2.0)

func bump(value:=1.5):
	sprite_3d.scale = Vector3.ONE * value
	
func set_color(value):
	color = value
	sprite_3d.material_override.set("shader_parameter/color", value)
	bubble_particles.material_override.set("albedo_color", value.lightened(0.5))
	splash_particles.material_override.set("albedo_color", value)
	loot_particles.material_override.set("albedo_color", value)
	
func load_resource(res: ObjectResource):
	resource = res
	sprite_3d.material_override.set("shader_parameter/texture_albedo", res.texture)
	sprite_3d.texture = res.texture
	
	if res.effect == ObjectResource.ObjectEffect.EndLevel:
		set_color(end_portal_color)
	elif res.effect != ObjectResource.ObjectEffect.None:
		set_color(upgrade_color)


func is_available():
	#not (tile.object and tile.object is Fish and not tile.object.resource.walkable) 
	if is_portal and not main.current_fish_count >= main.fish_before_end_portal: return false
	if resource and not resource.walkable: return false
	return true

func move_to_grid_position(grid_position):
	var current_pos = main.grid.world_to_grid_position(global_position)
	var target_tile = main.grid.get_tile(grid_position)
	
	if not target_tile or (not target_tile.is_empty() and target_tile != main.character.target_tile): return;
	#global_position = main.grid.grid_to_world_position(grid_position)
	get_tree().create_tween().tween_property(self, "global_position", main.grid.grid_to_world_position(grid_position), 0.2)
	target_tile.object = self
	
	var current_tile = main.grid.get_tile(current_pos)
	if current_tile: current_tile.object = null
	if target_tile == main.character.target_tile:
		target_tile.object = null
		await get_tree().create_timer(0.2).timeout
		main.handle_loot(self)
	
func move_toward_grid_position(grid_position):
	var current_pos = main.grid.world_to_grid_position(global_position)
	var distance = current_pos - grid_position
	var direction = Vector2(sign(distance.x), sign(distance.y))
	var directions = []
	directions = [Vector2(direction.x, 0), Vector2(0, direction.y)]
	if abs(distance.x) > abs(distance.y): directions = [Vector2(0, direction.y), Vector2(direction.x, 0)]
	
	for dir in directions:
		if not dir.length(): continue
		var target_tile = main.grid.get_tile(current_pos - dir)
		if not target_tile or (not target_tile.is_empty() and target_tile != main.character.target_tile): continue
		move_to_grid_position(current_pos - dir)
		
