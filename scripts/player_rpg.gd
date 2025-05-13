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
	if direction != Vector2(0, 0):
		direction = direction.normalized()
		
	animate(direction)
	
	# change position
	position.x += delta * direction[0] * SPEED
	position.y += delta * direction[1] * SPEED

	move_and_slide()
	
func animate(direction):
	if direction[0] == -1:
		status = "left"
	elif direction[0] == 1:
		status = "right"
	
	if direction[1] == -1:
		status = "up"
	elif direction[1] == 1:
		status = "down"
	
	if direction == Vector2(0, 0):
		if not "idle" in status:
			status = status + "_idle"
	
	animated_sprite.play(status)
		#
