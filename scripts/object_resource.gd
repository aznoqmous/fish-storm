class_name ObjectResource extends Resource

@export var texture: CompressedTexture2D
@export var alternate_textures : Array[CompressedTexture2D]
@export var score := 1.0
@export var combo : bool = false
@export var walkable: bool = true
@export var charge_gain := 0

@export_category("Effect")
@export var effect: ObjectEffect
@export var value := 1.0
@export_multiline var description: String

enum ObjectEffect {
	None,
	
#	Upgrades
	SpawnFishes, # Umbrella
	TemporaryMoveDistance, # Shoe
	AttractFishes, # Magnet
	CollectFarestFishes, # Cane
	
#	Meta
	EndLevel,
	
	#Health
	RegainMovesLeft,
	GainCombo
}
