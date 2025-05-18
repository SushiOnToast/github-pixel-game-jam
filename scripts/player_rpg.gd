extends CharacterBody2D

const SPEED = 100.0
var status = "down_idle"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var control_prompt: TextureRect = $ControlPrompt
@onready var state_manager: StateManager = get_tree().get_root().find_child("StateManager", true, false)

func _physics_process(delta: float) -> void:
	if state_manager.dialogue:
		# Disable movement and force down_idle animation during dialogue
		control_prompt.visible = false
		status = "down_idle"
		animated_sprite.play(status)
		return
	
	var direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		control_prompt.visible = false
	
	animate(direction)

	position += direction * SPEED * delta
	move_and_slide()

func animate(direction: Vector2) -> void:
	if direction == Vector2.LEFT:
		status = "left"
	elif direction == Vector2.RIGHT:
		status = "right"
	elif direction == Vector2.UP:
		status = "up"
	elif direction == Vector2.DOWN:
		status = "down"
	elif direction == Vector2.ZERO and not "idle" in status:
		status += "_idle"
	
	animated_sprite.play(status)
