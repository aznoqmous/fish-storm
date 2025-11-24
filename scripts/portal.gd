class_name Portal extends Fish

@export var disabled_color: Color
@onready var count_label: Label3D = $ShadowSpriteContainer/SpriteContainer/CountLabel

var is_active: bool:
	get: return main.current_fish_count >= main.fish_before_end_portal

func _process(delta: float) -> void:
	super(delta)
	color = lerp(color, disabled_color if not is_active else end_portal_color, delta * 5.0)
	sprite_3d.material_override.set("shader_parameter/alpha", color.a)
	count_label.text = str(main.fish_before_end_portal - main.current_fish_count)
	count_label.set_visible(not is_active)
