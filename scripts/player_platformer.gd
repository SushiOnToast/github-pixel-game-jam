extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var moving = false
var status = "idle"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
		moving = true
		velocity.x = direction * SPEED
	else:
		moving = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	animate(moving)

	move_and_slide()
	
func animate(is_moving):
	if not is_on_floor():
		if velocity.y < 0:
			status = "jump"
		else:
			status = "fall"
	elif is_moving:
		status = "run"
	else:
		status = "idle"

	if animated_sprite.animation != status:
		animated_sprite.play(status)
