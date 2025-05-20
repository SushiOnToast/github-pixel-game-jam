extends Resource
class_name EnemyResource

@export var name: String = "Enemy"
@export var texture: Texture = null
@export var health: int = 30
@export var damage: int = 20
@export var actions: Array[Resource] = []
@export var dialogue: Array[String] = []
