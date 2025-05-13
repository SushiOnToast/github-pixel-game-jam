extends CharacterBody2D

@export var walk_speed: float = 200.0
@export_range(0, 1) var acceleration: float = 0.1
@export_range(0, 1) var deceleration: float = 0.1

@export var jump_force: float = -400.0
@export_range(0, 1) var decelerate_on_jump_release: float = 0.5
@export var wall_jump_pushback: float = 100.0
@export var wall_slide_speed: float = 100.0

@export var jump_buffer_time: float = 0.15  # seconds
@export var coyote_time: float = 0.15  # Time after leaving ground where you can still jump

@export var fall_multiplier: float = 1.5
@export var low_jump_multiplier: float = 2.0

var moving = false
var is_wall_sliding = false
var status = "idle"

var coyote_timer = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Track coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	jump_buffer_timer -= delta

	# Buffer jump input
	if Input.is_action_just_pressed("jump or interact"):
		jump_buffer_timer = jump_buffer_time

	# Gravity with better jump feel
	if not is_on_floor():
		if velocity.y > 0:
			velocity += get_gravity() * delta * fall_multiplier
		elif velocity.y < 0 and not Input.is_action_pressed("jump or interact"):
			velocity += get_gravity() * delta * low_jump_multiplier
		else:
			velocity += get_gravity() * delta
	else:
		velocity += get_gravity() * delta

	# Handle input
	var direction := Input.get_axis("left", "right")
	moving = direction != 0

	# Horizontal movement
	if moving:
		velocity.x = move_toward(velocity.x, direction * walk_speed, walk_speed * acceleration)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)

	# Wall detection and sliding
	var on_wall = is_on_wall() and not is_on_floor()
	is_wall_sliding = on_wall and direction != 0

	if is_wall_sliding:
		velocity.y = min(velocity.y + wall_slide_speed * delta, wall_slide_speed)

	# Jump if buffer and coyote time are valid
	if jump_buffer_timer > 0:
		if coyote_timer > 0.0:
			velocity.y = jump_force
			jump_buffer_timer = 0
			coyote_timer = 0
		elif on_wall and direction != 0:
			velocity.y = jump_force
			velocity.x = -sign(direction) * wall_jump_pushback
			jump_buffer_timer = 0

	# Short hop
	if Input.is_action_just_released("jump or interact") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	# Apply movement
	move_and_slide()

	# Update animation
	animate()

func animate():
	if is_wall_sliding:
		status = "wall_slide"
	elif not is_on_floor():
		status = "jump" if velocity.y < 0 else "fall"
	elif abs(velocity.x) > 10:
		status = "run"
	else:
		status = "idle"

	if animated_sprite.animation != status:
		animated_sprite.play(status)
