class_name ComboControl extends Control

@onready var combo_label: Label = $ComboLabel
@onready var unit_container: GridContainer = $UnitContainer
const COMBO_UNIT_CONTROL = preload("res://scenes/combo_unit_control.tscn")

func clear():
	for child in unit_container.get_children(): child.queue_free()
	combo_label.set_visible(false)

func add_fish(fish: Fish):
	var new_unit := COMBO_UNIT_CONTROL.instantiate() as ComboUnitControl
	unit_container.add_child(new_unit)
	new_unit.set_color(fish.color)
	new_unit.set_texture(fish.resource.texture)
	
func set_combo(value):
	combo_label.set_visible(value > 1)
	unit_container.set_visible(value > 0)
	combo_label.text = str("x", value)
