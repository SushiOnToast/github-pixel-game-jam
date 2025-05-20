extends Resource

class_name MindDuelAction

enum ActionType { ATTACK, DEFEND }

@export var name: String
@export var type: ActionType = ActionType.ATTACK
@export var damage: int = 10
@export var triggers_minigame: bool = false
@export var defend_type: String = "RESIST" # SHIELD / HEAL / NULLIFY / CUSTOM
@export var description: String
