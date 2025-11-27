class_name SettingsControl extends VBoxContainer

@onready var master_slider: HSlider = $Master/MasterSlider
@onready var music_slider: HSlider = $Music/MusicSlider
@onready var sfx_slider: HSlider = $SFX/SFXSlider
@onready var visuals_checkbox: CheckBox = $Visuals/VisualsCheckbox


func _ready() -> void:
	load_values()
	master_slider.value_changed.connect(func(value):
		Game.master_value = value
		Game.save()
		update()
	)
	music_slider.value_changed.connect(func(value):
		Game.music_value = value
		Game.save()
		update()
	)
	sfx_slider.value_changed.connect(func(value):
		Game.sfx_value = value
		Game.save()
		update()
	)
	visuals_checkbox.toggled.connect(func(value):
		Game.visuals_value = value
		Game.save()
	)
	await Game.loaded
	load_values()
	
func load_values():
	master_slider.value = Game.master_value
	music_slider.value = Game.music_value
	sfx_slider.value = Game.sfx_value
	visuals_checkbox.button_pressed = Game.visuals_value
	
func update():
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), Game.master_value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), Game.music_value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), Game.sfx_value)
	
