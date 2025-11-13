class_name Wave extends Node3D

@export var SPEED := 1.0
@onready var area_3d: Area3D = $Area3D

func _ready():
	area_3d.area_entered.connect(func(tile: Tile):
		tile.explode()
	)

func _process(delta):
	global_position.x += delta * SPEED
