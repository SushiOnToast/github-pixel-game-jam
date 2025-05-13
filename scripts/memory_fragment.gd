extends Area2D

@onready var prompt: RichTextLabel = $prompt

var player_in_area = false

func _ready() -> void:
	prompt.visible = false
	
func _process(delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("pick up"):
		queue_free()

func _on_body_entered(body: CharacterBody2D) -> void:
	prompt.visible = true
	player_in_area = true
	
func _on_body_exited(body: CharacterBody2D) -> void:
	prompt.visible = false
	player_in_area = false
