extends Control

signal result(success: bool)

@export var speed := 500.0  # Starting speed (pixels per second)
@export var min_hit_zone_width := 0.1  # Minimum width as % of bar width
@export var max_hit_zone_width := 0.4  # Maximum width as % of bar width

const TOTAL_ROUNDS := 3
const SPEED_INCREASE_FACTOR := 1.1  # Increase speed by 10% each round

var initial_speed := 0.0
var direction := 1
var running := true
var current_round := 0
var successful := true

@onready var indicator = $TextureRect/Indicator
@onready var bar = $TextureRect/Bar
@onready var hit_zone_visual = $TextureRect/Bar/HitZoneVisual

var left_bound := 0.0
var right_bound := 0.0
var hit_zone_left := 0.0
var hit_zone_right := 0.0

func _ready():
	initial_speed = speed
	left_bound = bar.position.x
	right_bound = bar.position.x + bar.size.x

	start_round()
	set_process(true)

func start_round():
	# Reset indicator position and direction
	indicator.position.x = left_bound
	direction = 1
	running = true

	# Speed increases per round
	speed = initial_speed * pow(SPEED_INCREASE_FACTOR, current_round)

	# Generate hit zone
	var bar_width = bar.size.x
	var random_width_percent = randf_range(min_hit_zone_width, max_hit_zone_width)
	var hit_zone_width = random_width_percent * bar_width

	var max_left_percent = 1.0 - random_width_percent
	var random_left_percent = randf_range(0.0, max_left_percent)
	hit_zone_left = left_bound + random_left_percent * bar_width
	hit_zone_right = hit_zone_left + hit_zone_width

	# Display hit zone visually
	hit_zone_visual.position.x = hit_zone_left - bar.position.x
	hit_zone_visual.size.x = hit_zone_width
	hit_zone_visual.visible = true

func _process(delta):
	if not running:
		return

	indicator.position.x += direction * speed * delta

	if indicator.position.x >= right_bound or indicator.position.x <= left_bound:
		direction *= -1

func _input(event):
	if running and event.is_action_pressed("ui_accept"):
		running = false

		var x = indicator.position.x
		var success = (x >= hit_zone_left and x <= hit_zone_right)

		if not success:
			successful = false
			emit_signal("result", false)
			queue_free()
			return

		current_round += 1

		if current_round >= TOTAL_ROUNDS:
			emit_signal("result", true)
			queue_free()
		else:
			await get_tree().create_timer(0.5).timeout
			start_round()
