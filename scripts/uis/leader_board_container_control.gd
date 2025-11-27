class_name LeaderBoardContainerControl extends Control
const LEADERBOARD_CONTROL = preload("res://scenes/uis/leaderboard_control.tscn")
@onready var upload_results_request: HTTPRequest = $UploadResultsRequest
@onready var update_request: HTTPRequest = $UpdateRequest
@export var domain_url := "https://ooqo.aznoqmous.com"
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var loading_label: Label = $LoadingLabel

var scores: Array[LeaderboardControl]

func _ready() -> void:
	v_box_container.set_visible(false)

func send_data(character: CharacterResource, _name: String, score: int, level: int):
	var json = JSON.stringify({
		"Character": character.id,
		"Name": _name,
		"Score": score,
		"Level": level
	})
	upload_results_request.request(
		str(domain_url, "/run"),
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		json
	)
	var res = await upload_results_request.request_completed
	var data = JSON.parse_string(res[3].get_string_from_utf8())
	return int(data["id"])
	
func update():
	update_request.request(
		str(domain_url, "/leaderboard"),
		["Content-Type: application/json"],
		HTTPClient.METHOD_GET
	)
	var res = await update_request.request_completed
	var data = JSON.parse_string(res[3].get_string_from_utf8())
	var i = 0
	
	for child in v_box_container.get_children(): child.queue_free()

	scores.clear()
	for run_data in data["Runs"]:
		i += 1
		var new_score = LEADERBOARD_CONTROL.instantiate() as LeaderboardControl
		v_box_container.add_child(new_score)
		new_score.load_character(Game.get_character_resource_by_id(run_data["Character"]))
		new_score.score_label.text = str(int(run_data["Score"]))
		new_score.name_label.text = str(run_data["Name"])
		new_score.rank_label.text = str("#", i)
		new_score.background.set_visible(i % 2)
		new_score.run_id = int(run_data["id"])
		
		
		scores.append(new_score)
	v_box_container.set_visible(true)
	loading_label.set_visible(false)

func set_current(id):
	for new_score in scores:
		new_score.is_current = new_score.run_id == id
