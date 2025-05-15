extends PointLight2D

var base_energy: float = 1.2
var pulse_strength: float = 0.2
var pulse_speed: float = 3.0
var flicker_noise_strength: float = 0.05
var flicker_noise_speed: float = 20.0

var time := 0.0

func _process(delta):
	time += delta

	var pulse = sin(time * pulse_speed) * pulse_strength
	var flicker = randf_range(-1.0, 1.0) * flicker_noise_strength * sin(time * flicker_noise_speed)

	self.energy = base_energy + pulse + flicker
