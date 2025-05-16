extends PointLight2D

var base_energy: float = 1.2
var pulse_strength: float = 0.2
var pulse_speed: float = 3.0
var flicker_noise_strength: float = 0.05
var flicker_noise_speed: float = 20.0

var time := 0.0
var parent_name: String

@onready var day_night_manager: DayNightManager

func _ready() -> void:
	parent_name = check_parent()
	if parent_name == "Neighbourhood":
		day_night_manager = get_tree().get_root().find_child("DayNightManager", true, false)

func _process(delta):
	if parent_name == "Neighbourhood":
		if day_night_manager.is_night:
			show_light(delta)
		else:
			self.visible = false	
	else:
		show_light(delta)

func check_parent():
	var chain = []
	var current = self
	for i in range(3):
		chain.append(current.name)
		current = current.get_parent()
		
	return chain[-1]

func show_light(delta):
	self.visible = true
	time += delta

	var pulse = sin(time * pulse_speed) * pulse_strength
	var flicker = randf_range(-1.0, 1.0) * flicker_noise_strength * sin(time * flicker_noise_speed)

	self.energy = base_energy + pulse + flicker
