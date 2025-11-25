extends Node

var current_scene = null
var game_scene = "res://scenes/main.tscn"
var title_scene = "res://scenes/title.tscn"

var run_time = 0
var coin_count = 0
var max_coins = 0
var reset_count = 0

const SCENE_TRANSITION_CONTROL = preload("res://scenes/uis/scene_transition_control.tscn")
var scene_transition_control

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	scene_transition_control = SCENE_TRANSITION_CONTROL.instantiate()
	add_child(scene_transition_control)
	
func load_title():
	load_scene_progress(title_scene)

func load_character_select():
	var title := await load_scene_progress(title_scene) as TitleControl
	title.select_character()

func load_game():
	load_scene_progress(game_scene)

func load_scene(path):
	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	var s = ResourceLoader.load(path)
	set_scene(s.instantiate())
	
func set_scene(scene):
	get_tree().current_scene.free()
	current_scene = scene
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func load_scene_progress(path):
	await scene_transition_control.open()
	
	var s = await _thread_load(path)
	var s_instance = s.instantiate()
	set_scene(s_instance)
	
	scene_transition_control.close()
	return s_instance

func _thread_load(path):
	ResourceLoader.load_threaded_request(path)
	var tree = get_tree()
	var progress = 0
	var arrProgress = [0]
	while progress < 1:
		await tree.process_frame
		ResourceLoader.load_threaded_get_status(path, arrProgress)
		progress = arrProgress[0]
	return ResourceLoader.load_threaded_get(path)
	
