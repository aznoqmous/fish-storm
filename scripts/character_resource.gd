class_name CharacterResource extends Resource

@export var character_name: String
@export var head_sprite: CompressedTexture2D
@export var active_effect_sprite: CompressedTexture2D
@export_multiline var description: String


@export_category("Passive Effect")
@export var max_combo := 0.0
@export var max_moves_left := 0
@export var max_move_distance := 0.0
@export var max_combo_move_distance := 0.0
@export var move_per_combo := 1.0
@export var magnet_power := 0.0
@export var temporary_mov_distance := 0.0
@export var credits_gain := 1.0

@export_category("Active Effect")
@export var active_effect: ActiveEffect
@export var value := 1.0
@export var active_cooldown := 3

@export_category("Unlock")
@export var locked := true
@export_multiline var unlock_description: String
@export var unlock_min_level := 0
@export var unlock_type : UnlockType
@export var unlock_value := 0

var id : String :
	get: return get_path().split("/")[-1].replace(".tres", "")

enum PassiveEffect {
	
}

enum ActiveEffect {
	None,
	AddCombo,
	SpawnUpgrade,
	SpawnFishes,
	TemporaryMovementIncrease,
	LootFishesForMaxMoves,
	AttractFishes,
	ReturnToLastPosition
}

enum UnlockType {
	Level,
	Combo,
	Score,
	Flawless,
	Perfect,
	Wooow,
	FishCount,
	TotalFishCount
}
