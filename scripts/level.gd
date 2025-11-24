@tool
class_name Level extends Node3D
@onready var tiles_container: Node3D = $TilesContainer
@onready var end_portal: Fish = $EndPortal

@export var tiles_count_display : int :
	get(): return tiles_container.get_child_count()
