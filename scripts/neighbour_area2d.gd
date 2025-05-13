extends Area2D

@onready var prompt: RichTextLabel = $prompt
@onready var state_manager: StateManager

var player_in_area = false

func _ready() -> void:
	prompt.visible = false
	state_manager = get_tree().get_root().find_child("StateManager", true, false)
	
func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("jump or interact"):
		state_manager.switch_world()

func _on_body_entered(body: Node2D) -> void:
	prompt.visible = true
	player_in_area = true


func _on_body_exited(body: Node2D) -> void:
	prompt.visible = false
	player_in_area = false
