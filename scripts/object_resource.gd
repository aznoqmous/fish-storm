class_name ObjectResource extends Resource

@export var texture: CompressedTexture2D
@export var score := 1.0
@export var combo : bool = false

@export_category("Effect")
@export var effect: ObjectEffect
@export var value := 1.0
@export_multiline var description: String

@export_category("Charge")
@export var max_charges = 3
@export var charge_trigger: ChargeTrigger
@export var charge_effect: ChargeEffect

@export_category("Spawn")
@export var charge_spawn_position: SpawnPosition
@export var spawned_objects: Array[ObjectResource]
@export var spawned_objects_count := 1
@export var destroy_on_spawn: bool = true

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

enum ChargeEffect {
	None,
	Spawn
}

enum ChargeTrigger {
	None,
	OnMaxCharge,
}

enum SpawnPosition {
	None,
	Self,
	Random,
}
