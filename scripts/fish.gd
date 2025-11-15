class_name Fish extends Node3D

@onready var main: Main = $/root/Main
@onready var sprite_container: Node3D = $ShadowSpriteContainer/SpriteContainer
@onready var shadow_sprite_container: Node3D = $ShadowSpriteContainer
@onready var sprite_3d: Sprite3D = $ShadowSpriteContainer/SpriteContainer/Sprite3D
@onready var sprite_light: OmniLight3D = $ShadowSpriteContainer/SpriteContainer/SpriteLight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var splash_particles: GPUParticles3D = $SplashParticles
@onready var loot_particles: GPUParticles3D = $LootParticles

@export var colors: Array[Color]
@export var upgrade_color: Color
@export var end_portal_color: Color

var color: Color
var animation := 0.0
var animation_height := 5.0
var animation_depth := -10.0
var resource: ObjectResource

func _ready() -> void:
	animation_depth = randf_range(-10, -6)
	shadow_sprite_container.position.y = 0
	shadow_sprite_container.position.z = animation_depth
	shadow_sprite_container.scale = Vector3.ZERO
	splash_particles.global_position = shadow_sprite_container.global_position
	splash_particles.emitting = true
	
	color = colors.pick_random()
	sprite_3d.material_override.set("shader_parameter/color", color)
	sprite_light.light_color = color
	splash_particles.material_override.set("albedo_color", color)
	loot_particles.material_override.set("albedo_color", color)
	
func _process(delta: float) -> void:
	if animation < 1.0:
		animation += delta
		shadow_sprite_container.position.y = sin(animation * PI) * animation_height
		shadow_sprite_container.position.z = lerp(animation_depth, 0.0, animation)
		shadow_sprite_container.scale = lerp(Vector3.ZERO, Vector3.ONE, animation)

func loot():
	animation_player.play("looted")

func set_color(value):
	color = value
	sprite_3d.material_override.set("shader_parameter/color", value)
	splash_particles.material_override.set("albedo_color", value)
	loot_particles.material_override.set("albedo_color", value)

func load_resource(res: ObjectResource):
	resource = res
	sprite_3d.texture = res.texture
	sprite_3d.material_override.set("shader_parameter/texture_albedo", res.texture)
	
	if res.effect == ObjectResource.ObjectEffect.EndLevel:
		set_color(end_portal_color)
	elif res.effect != ObjectResource.ObjectEffect.None:
		set_color(upgrade_color)
