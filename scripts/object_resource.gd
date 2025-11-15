class_name ObjectResource extends Resource

@export var texture: CompressedTexture2D
@export var score := 1.0
@export var combo : bool = false

@export_category("Effect")
@export var effect: ObjectEffect
@export var value := 1.0
@export_multiline var description: String

enum ObjectEffect {
	None,
	
#	Upgrades
	IncreaseMovement,
	IncreaseComboMovement,
	IncreaseMagnet,
	TemporaryMoveDistance,
	UpgradeDropChance,
	
#	Meta
	EndLevel,
	
}
