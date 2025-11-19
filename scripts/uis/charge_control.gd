@tool
class_name ChargeControl extends TileScaleContainer
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var main: Main = $/root/Main
@export var disabled_color: Color
var color: Color
var is_enabled:= false

func set_color(value):
	color = value

func set_enabled(value:bool):
	is_enabled = value

func _process(_delta: float) -> void:
	nine_patch_rect.modulate = main.colors.current_color if is_enabled else disabled_color
