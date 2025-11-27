extends Node

var selected_character: CharacterResource
var characters: Array[CharacterResource]
var unlocked_characters: Array[CharacterResource]
var save_path := "user://savegame.save"
var username := "" :
	set(value):
		username = value
		username_changed.emit()

var master_value := 1.0
var music_value := 1.0
var sfx_value := 1.0
var visuals_value := true

func save():
	var data = {
		"characters": unlocked_characters.map(func(a: CharacterResource): return a.id),
		"username": username,
		"master_value": master_value,
		"music_value": music_value,
		"sfx_value": sfx_value,
		"visuals_value": visuals_value,
	}
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(data))

func load():
	if not FileAccess.file_exists(save_path):
		unlocked_characters = characters.filter(func(a: CharacterResource): return not a.locked) 
		return
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var data = JSON.parse_string(save_file.get_as_text())
	unlocked_characters = characters.filter(func(a: CharacterResource): return not a.locked or data.characters.has(a.id)) 
	if data.has("username"): username = data.username
	if data.has("master_value"): master_value = data.master_value
	if data.has("music_value"): music_value = data.music_value
	if data.has("sfx_value"): sfx_value = data.sfx_value
	if data.has("visuals_value"): visuals_value = data.visuals_value
	loaded.emit()
	
func unlock_character(character: CharacterResource):
	if not unlocked_characters.has(character): unlocked_characters.append(character)
	save()

func unlock_character_by_id(id: String):
	var character = get_character_resource_by_id(id)
	if not character: return;
	unlock_character(character)
	
func get_character_resource_by_id(id: String):
	var matching_characters = characters.filter(func(a): return a.id == id)
	if not matching_characters.size(): return;
	return matching_characters[0]
	
func clear():
	unlocked_characters.clear()
	save()

func get_locked_characters() -> Array[CharacterResource]:
	return characters.filter(func(c): return not unlocked_characters.has(c))

signal loaded
signal username_changed
