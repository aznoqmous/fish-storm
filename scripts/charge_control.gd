@tool
class_name ChargeControl extends TileScaleContainer
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect

var color: Color
@export var disabled_color: Color
 
func set_color(value):
	color = value

func set_enabled(value:bool):
	nine_patch_rect.modulate = color if value else disabled_color
