extends CharacterBody2D


const SPEED = 100.0
var status = "down_idle"
#
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	var direction = Vector2(0, 0)
	
	# input 
	direction[0] = Input.get_axis("left", "right")
	direction[1] = Input.get_axis("up", "down")
	
	# normalise so that the diagonal movement isnt too fast
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		
	animate(direction)
	
	# change position
	position.x += delta * direction[0] * SPEED
	position.y += delta * direction[1] * SPEED

	move_and_slide()
	
func animate(direction):
	if direction == Vector2.LEFT:
		status = "left"
	elif direction == Vector2.RIGHT:
		status = "right"
	elif direction == Vector2.UP:
		status = "up"
	elif direction == Vector2.DOWN:
		status = "down"
	
	elif direction == Vector2.ZERO:
		if not "idle" in status:
			status = status + "_idle"
	
	animated_sprite.play(status)
		#
