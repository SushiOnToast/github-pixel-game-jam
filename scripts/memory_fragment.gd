extends Area2D

class_name MemoryFragment

@onready var state_manager: StateManager
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var player_in_area = false

func _ready() -> void:
	texture_rect.visible = false
	label.visible = false
	state_manager = get_tree().get_root().find_child("StateManager", true, false)
	
func _process(delta: float) -> void:
	if player_in_area:
		texture_rect.visible = true
		label.visible = true
	else:
		texture_rect.visible = false
		label.visible = false
	
	if player_in_area and Input.is_action_just_pressed("interact"):
		state_manager.collected_fragments[get_parent().name.to_lower()] = true
		state_manager.switch_to("res://scenes/neighbourhood.tscn", "Neighbourhood")
		queue_free()

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_area = true
	
func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_area = false
