extends Area2D

@onready var state_manager: StateManager
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var player_in_area = false

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	state_manager = get_tree().get_root().find_child("StateManager", true, false)
	
func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("jump or interact"):
		#state_manager.switch_world()
		pass

func _on_body_entered(body: Node2D) -> void:
	texture_rect.visible = true
	label.visible = true
	player_in_area = true


func _on_body_exited(body: Node2D) -> void:
	texture_rect.visible = false
	label.visible = false
	player_in_area = false
